------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
------------------

-- Capteur température DSx20
DS1820_PIN = 4 
thermometres=_dofile("ds1820_reader")
thermometres.init(DS1820_PIN)

-- AUTREs
FAN_RELAY_PIN = 5
gpio.mode(FAN_RELAY_PIN,gpio.OUTPUT)
gpio.write(FAN_RELAY_PIN,gpio.LOW)

------------------------------
-- Modules a charger
------------------------------
modules={"ds1820_reader"}

------------------
-- Params WIFI 
------------------
SSID = "WIFI_THOME2"
PASSWORD = "plus33324333562"
HOST = "NODE-BAIE"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/BAIE/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                result_on_callback = function(callback)
                        thermometres.read(nil,callback)
                    end,
                qos = 0, retain = 0, callback = nil}

-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."fan"]={
            ["ON"]=function()
                        print("FAN ON")
                        gpio.write(FAN_RELAY_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("FAN OFF")
                        gpio.write(FAN_RELAY_PIN, gpio.LOW)
                    end}
