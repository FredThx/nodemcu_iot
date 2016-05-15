------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
------------------

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { }

-- Capteur DTH11-22
DTH_pin = 4

-- AUTREs
FAN_RELAY_PIN = 3

------------------
-- Params WIFI 
------------------
SSID = "WIFI_THOME1"
PASSWORD = "plus33324333562"
HOST = "NODE-CAVE"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/CAVE/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        t,h=readDht()    
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."humidite"]={
                message = function()
                        t,h=readDht()
                        return h
                    end,
                qos = 0, retain = 0, callback = nil}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}

