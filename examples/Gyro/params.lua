-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--					- Gyroscope
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, i2c, cjson, bit
-------------------------------------------------

LOGGER = false
WATCHDOG = true
TELNET = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- MPU_6050

mpu6050 = _dofile('mpu6050')
mpu6050.init(7, 6, 1, 1)
mpu6050.init = nil

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
	}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_GYRO","FILEUROPE"}
PASSWORD = {"plus33324333562","vosges433"}
HOST = "NODE-GYRO"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.7.17"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "FILEUROPE/GYRO/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."datas"]={
                message = function()
                        return cjson.encode(mpu6050.read())
                    end,
                qos = 1, retain = 1, callback = nil}
----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}    
mqtt_trig_topics[mqtt_base_topic.."datas"]={
                pin = 1,
                pullup = false,
                type = "up", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = mqtt_out_topics[mqtt_base_topic.."datas"].message}            
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
disp_texts = {}
