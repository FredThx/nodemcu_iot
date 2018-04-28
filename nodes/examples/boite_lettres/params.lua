-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               BOITE AU LETTRES
--               avec
--					- detecteur de mvt
--                  - bouton de RAZ
--                  - LED
-------------------------------------------------


--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- AUTREs
IRD_PIN = 3
LED_PIN = 1
BT_PIN = 2
PRT_PIN = 5

gpio.mode(LED_PIN, gpio.OUTPUT)
--------------------------------------
-- Modules a charger
--------------------------------------
modules={}
--        "ds1820_reader",
--        "DTH_reader",
--        "BMP_reader",
--        "433_switch",
--        "i2c_display"}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = "WIFI_THOME2"
PASSWORD = "plus33324333562"
HOST = "NODE-BAL"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/BAL/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}
mqtt_trig_topics[mqtt_base_topic.."CAPTEUR_IR"]={
                pin = IRD_PIN,
                pullup = false,
                type = "up", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil}
mqtt_trig_topics[mqtt_base_topic.."BOUTON"]={
                pin = BT_PIN,
                pullup = true,
                type = "down", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil}
mqtt_trig_topics[mqtt_base_topic.."PORTE"]={
                pin = PRT_PIN,
                pullup = true,
                type = "up", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil}
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
--Soit avec une fonction par valeur du message
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        gpio.write(LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_PIN,gpio.LOW)
                    end}
            
