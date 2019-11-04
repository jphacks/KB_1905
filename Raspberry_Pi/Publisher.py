import time,json
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient

class Publisher():
    CLIENT_ID = "test"
    ENDPOINT = "ap4kh4z0lzjzp-ats.iot.ap-northeast-1.amazonaws.com"
    PORT = 8883
    TOPIC = "animo/move"

    ROOT_CA = "./cert/AmazonRootCA1.pem"
    PRIVATE_KEY = "./cert/3ff9f2ac35-private.pem.key"
    CERTIFICATE = "./cert/3ff9f2ac35-certificate.pem.crt"

    def __init__(self):
        self.client = AWSIoTMQTTClient(self.CLIENT_ID)
        self.client.configureEndpoint(self.ENDPOINT, self.PORT)
        self.client.configureCredentials(self.ROOT_CA, self.PRIVATE_KEY, self.CERTIFICATE)

        self.client.configureAutoReconnectBackoffTime(1, 32, 20)
        self.client.configureOfflinePublishQueueing(-1)
        self.client.configureDrainingFrequency(2)
        self.client.configureConnectDisconnectTimeout(10)
        self.client.configureMQTTOperationTimeout(5)

        self.client.connect()
        # self.client.subscribe(TOPIC, 1, subscribe_callback)

    def publish(self,timestamp,move):
        payload = json.dumps({'timestamp':str(timestamp),'move': str(move)})
        res = self.client.publish(self.TOPIC,payload,1)
        print('published:{}'.format(payload))
        time.sleep(1)

if __name__ == "__main__":
    myinstance = Publisher()
    myinstance.publish(55,555)