gpio.write(LED_PIN, gpio.HIGH)-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - ........
-------------------------------------------------


--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

LED_PIN = 3
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { }

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
        "ds1820_reader"
--        "DTH_reader",
--        "BMP_reader",
--        "433_switch",
--        "i2c_display"
}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = "WIFI_THOME2"
PASSWORD = "plus33324333562"
HOST = "NODE-HAUT"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/HAUT/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        t = readDSSensor()
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        gpio.write(LED_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_PIN, gpio.LOW)
                    end}

