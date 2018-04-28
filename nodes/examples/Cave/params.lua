-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                  - capteur de température et humidité DHT11
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, dht
-------------------------------------------------
-----------------

-- Capteur DTH11-22
DTH_pin = 4

------------------------------
-- Modules a charger
------------------------------
modules={"DTH_reader"}

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
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
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}
disp_texts = {}
