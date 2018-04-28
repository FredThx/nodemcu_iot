-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour MINI-BALLON EAU CHAUDE
--                  reporte les infos du Ballon EC.
--               avec
--                  - display i2c 128x64
--                  - LED rouget et verte
--                  - boutons (TODO)
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, i2c, cjson, u8g, mqtt
-------------------------------------------------
LOGGER = true

-- display en i2c
pin_sda = 5 
pin_scl = 6 
disp_sla = 0x3c

-- AUTREs
RED_LED_PIN = 7
GREEN_LED_PIN = 8

------------------------------
-- Modules a charger
------------------------------
modules={ --"ds1820_reader.lua","DTH_reader.lua",
    "i2c_display"}

------------------
-- Params WIFI 
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
--SSID = "WIFI_THOME1"
PASSWORD = "plus33324333562"
HOST = "NODE-EXTERIEUR"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/BALLON/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}

-- Messages sur trigger GPIO
mqtt_trig_topics = {}
                
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}

mqtt_in_topics[mqtt_base_topic.."red_led"]={
            ["ON"]=function()
                        gpio.write(RED_LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(RED_LED_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(RED_LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(RED_LED_PIN,gpio.LOW)
                            end)
                    end}
mqtt_in_topics[mqtt_base_topic.."green_led"]={
            ["ON"]=function()
                        gpio.write(RED_LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(RED_LED_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(RED_LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(RED_LED_PIN,gpio.LOW)
                            end)
                    end}
--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
mqtt_in_topics[mqtt_base_topic.."DISPLAY"]=function(data)
                disp_add_data(data)
            end
         