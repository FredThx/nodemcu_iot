-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--                  Pour Intérupteur_iot
--               avec
--                    - capteur Touch Sensor
--                    - led
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------
LOGGER = false

-- Sensor Touch
TOUCH_PIN = 1
-- LED
LED_PIN = 5
gpio.mode(LED_PIN,gpio.OUTPUT)
gpio.write(LED_PIN, gpio.HIGH)
------------------------------
-- Modules a charger
------------------------------
modules={}
------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME2",'WIFI_THOME1'}
PASSWORD = "plus33324333562"
HOST = "NODE-INTER_1"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/SALON/INTER-1/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
                       
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}
               
-- Messages sur trigger GPIO
mqtt_trig_topics = {}     
mqtt_trig_topics[mqtt_base_topic.."BOUTON"]={
            pin = TOUCH_PIN,
            type = "both",
            message = "TOUCHE"
}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        gpio.write(LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_PIN,gpio.LOW)
                            end)
                    end}
                        
--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
