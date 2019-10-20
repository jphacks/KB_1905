# URL
- https://www.55g-jphacks2019.tk

# /sensor
## /
- GET
    - タイムスタンプと加速度、ジャイロの最新の値
    - 例：{"acc_Y":"5","acc_Z":"5","acc_X":"5","timestamp":"11456789","gyro_Z":"1","gyro_Y":"1","gyro_X":"5"}
- POST
    - センサー情報をデータベースに登録
    - 例：{"acc_Y":"5","acc_Z":"5","acc_X":"5","timestamp":"11456789","gyro_Z":"1","gyro_Y":"1","gyro_X":"5"}
## /rssi
- GET
    - タイムスタンプとrssiの最新の値
    - 例：{"dist":"1290","timestamp":"1789"}
- POST
    - rssi情報をデータベースに登録
    - 例：{"dist":"1290","timestamp":"1789"}

# /users
- POST
    - デバイストークンの設定
    - 例：{"name":"akanda","deviceToken":"xxxxxxxxxxxxx"}

# /push
## /leave
- POST
    - 荷物から離れたときのpush通知
    - 何送ってもOK
## /move
- POST
    - 荷物が動いたときのpush通知
    - 何送ってもOK


