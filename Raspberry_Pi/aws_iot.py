import time,json
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient
# import ledcontrol

CLIENT_ID = "test"
ENDPOINT = "ap4kh4z0lzjzp-ats.iot.ap-northeast-1.amazonaws.com"
PORT = 8883

ROOT_CA = "./cert/AmazonRootCA1.pem"
PRIVATE_KEY = "./cert/3ff9f2ac35-private.pem.key"
CERTIFICATE = "./cert/3ff9f2ac35-certificate.pem.crt"

TOPIC = "animo/move"

def main():
    # https://s3.amazonaws.com/aws-iot-device-sdk-python-docs/sphinx/html/index.html
    client = AWSIoTMQTTClient(CLIENT_ID)
    client.configureEndpoint(ENDPOINT, PORT)
    client.configureCredentials(ROOT_CA, PRIVATE_KEY, CERTIFICATE)

    client.configureAutoReconnectBackoffTime(1, 32, 20)
    client.configureOfflinePublishQueueing(-1)
    client.configureDrainingFrequency(2)
    client.configureConnectDisconnectTimeout(10)
    client.configureMQTTOperationTimeout(5)

    client.connect()
    client.subscribe(TOPIC, 1, subscribe_callback)

    payload = json.dumps({'timestamp':'a','move': '1'})
    client.publish(TOPIC,payload,1)
    print('published')
    time.sleep(1)

    # while True:
    #     time.sleep(5)

def subscribe_callback(client, userdata, message):
    print("subscribed")
    # print("Received a new message: ")
    # print(message.payload)
    # print("from topic: ")
    # print(message.topic)

    # content = message.payload.decode()
    # j_payload = json.loads(content)

    # command = j_payload['message']
    # print(command)

    # if command == 'turnon':
    #         print('turnon')
    # elif command == 'turnon':
    #         print('turnoff')
    # else:
    #         print('nocommand')

    # print("--------------\n\n")

if __name__ == "__main__":
    main()