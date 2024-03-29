# -*- coding: utf-8 -*-
import time
import threading
import smbus
import math
from time import sleep
import datetime
import requests
from datetime import datetime
import random
import json
import subprocess
import re
import pigpio
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

def sensor():
    DEV_ADDR = 0x68

    ACCEL_XOUT = 0x3b
    ACCEL_YOUT = 0x3d
    ACCEL_ZOUT = 0x3f
    TEMP_OUT = 0x41
    GYRO_XOUT = 0x43
    GYRO_YOUT = 0x45
    GYRO_ZOUT = 0x47

    PWR_MGMT_1 = 0x6b
    PWR_MGMT_2 = 0x6c

    bus = smbus.SMBus(1)
    bus.write_byte_data(DEV_ADDR, PWR_MGMT_1, 0)

    def read_word(adr):
        high = bus.read_byte_data(DEV_ADDR, adr)
        low = bus.read_byte_data(DEV_ADDR, adr+1)
        val = (high << 8) + low
        return val

    def read_word_sensor(adr):
        val = read_word(adr)
        if (val >= 0x8000):  return -((65535 - val) + 1)
        else:  return val

    def get_temp():
        temp = read_word_sensor(TEMP_OUT)
        x = temp / 340 + 36.53      # data sheet(register map)記載の計算式.
        return x

    def getAccel():
        x = read_word_sensor(ACCEL_XOUT)/ 16384.0
        y= read_word_sensor(ACCEL_YOUT)/ 16384.0
        z= read_word_sensor(ACCEL_ZOUT)/ 16384.0
        return [x, y, z]
    class speaker(threading.Thread):
        # 起動時か
        init = False
        def __init__(self, arg):
            super().__init__()
            self.init = arg
        # Ture（起動時）は音を一回、検知時は音を10回
        def run(self):
            counter = 0
            if self.init:
                print("\n********\ninit\n********\n")
                counter = 1
            else:
                print('\n\n********\nspeaker\n********\n\n')
                counter = 10

            gpio_pin0 = 18
            gpio_pin1 = 19

            pi = pigpio.pi()
            pi.set_mode(gpio_pin0, pigpio.OUTPUT)

            for i in range(counter):
                pi.hardware_PWM(gpio_pin0,500,500000)
                time.sleep(0.1)
                pi.hardware_PWM(gpio_pin0, 1000, 100000)
                time.sleep(0.2)

            pi.set_mode(gpio_pin0, pigpio.INPUT)
            pi.stop()
            return


    # 動いたと判断する閾値
    SCR_MOVE = 0.2
    # 加速度のスカラー値の最大
    SCR_MAX = 0.5

    # 検知する時間感覚
    judge_time = 1
    # push間隔
    PUSH_INTERVAL_SEC = 10

    # judge_timeにavb_count回加速度を取得して平均
    avg_count = 5
    scr_l = [0] * avg_count

    # 音再生用スレッド
    thread = speaker(True)
    thread.start()

    before_dt = 0

    while True:
        if(FLG==1):
            # 誤差を小さくするために平均を取る
            for i in range(avg_count):
                ax,ay,az = getAccel()
                scr_l[i] = math.sqrt(ax*ax+ay*ay+az*az)
                time.sleep(judge_time/avg_count)

            # 動いた判定
            dif = 0
            for i in range(avg_count-1):
                dif += abs(scr_l[i+1] - scr_l[i])
            # print(dif)

            # 動いた
            if(dif>SCR_MAX):
                move = 100
            else:
                move = dif * 200
            print(move)
            #異常検知post
            dt = datetime.now().strftime('%s')
            # print(type(dt))
            samp = {'move':str(move),'timestamp':str(dt)}
            headers = {'Content-Type':'application/json'}
            #センサ情報送信
            try:
                response = requests.post('https://www.55g-jphacks2019.tk/sensors',data=json.dumps(samp),headers=headers,verify=False)
                print('--------move post--------')
                print(response)
            except:
                print('error')

            if dif > SCR_MOVE:
                if thread.is_alive():
                    print('\n\n********\nalive\n********\n\n')
                else:
                    thread = speaker(False)
                    thread.start()
                # 30秒に1回
                if int(dt) - before_dt > PUSH_INTERVAL_SEC:
                #動いたプッシュ通知
                    print('push')
                    try:
                        response = requests.post('https://www.55g-jphacks2019.tk/push/move',data=json.dumps(samp),headers=headers,verify=False)
                        print('*******move push*******')
                        print(response)
                        before_dt = int(dt)
                    except:
                        print('error')


def blue_tooth():
    # shellのコマンドを使ってRSSI取得（ペアリング必要）
    def readRSSI():
        sum = 0
        count = 10
        try:
            for i in range(count):
                res = subprocess.check_output("hcitool rssi 38:89:2C:34:15:BB",shell=True)
                res = res.decode("utf8")
                res = re.sub(" |\n", "", res)
                num = res.split(":")[1]
                sum += int(num)
            return sum/count
        except:
            return -20

    global FLG
    # 0:荷物に近い、1：荷物から遠い
    FLG = 0
    # push間隔
    PUSH_INTERVAL_SEC = 10
    # pushしたか
    pushed = False

    # 最後にpush通知した時間
    pushed_dt = 0

    while True:
        # RSSIの取得と時間の取得
        rssi = readRSSI()
        time.sleep(1)
        dt = datetime.now().strftime('%s')
        payload = {'dist':str(rssi),'timestamp':str(dt)}
        headers = {'Content-Type':'application/json'}

        # 距離は常にpost
        try:
            response = requests.post('https://www.55g-jphacks2019.tk/sensors/rssi',data=json.dumps(payload),headers=headers,verify=False)
            print('--------rssi post--------')
            # print(response)
            print(rssi)
        except:
            print('error')

        #離れたらpush通知
        if(rssi<-2):
            FLG = 1
            dt = int(datetime.now().strftime('%s'))
            # if dt - pushed_dt > PUSH_INTERVAL_SEC:
            if not pushed:
                try:
                    response = requests.post('https://www.55g-jphacks2019.tk/push/leave',data=json.dumps(payload),headers=headers,verify=False)
                    print('*******leave push*******')
                    pushed = True
                    # print(response)
                    # pushed_dt = dt
                except:
                    print('error')
        else:
            print("-------------------")
            FLG = 0
            pushed = False

if __name__=='__main__':
    thread1 = threading.Thread(target=blue_tooth)
    thread2 = threading.Thread(target=sensor)
    thread1.start()
    thread2.start()