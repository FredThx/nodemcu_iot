import paho.mqtt.client as mqtt
import random
import time
import math

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    #client.subscribe("$SYS/#")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("10.10.1.156", 1883, 60)


#client.loop_forever()

while True:
	now = time.time()
	value = random.randrange(1,500) +500* math.sin(now/10/math.pi)
	client.publish("PIERRON/PY/TEST",value)
	time.sleep(0.5)
	