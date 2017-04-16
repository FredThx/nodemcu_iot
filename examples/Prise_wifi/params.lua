-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu PRISE_WIFI
--               avec
--					- relais
--                  - bouton
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------

LOGGER = false
WATCHDOG = true
TELNET = false



--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------


BT_PIN = 6
LED_PIN = 4
RELAIS_PIN = 8

gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.mode(RELAIS_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)
gpio.write(RELAIS_PIN, gpio.LOW)

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
	}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = "WIFI_THOME"
PASSWORD = "plus33324333562"
HOST = "NODE-PRISE-WIFI"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
--mqtt_host = "31.29.97.206"
mqtt_host = "192.168.0.15"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-EPINAL/PRISE-WIFI/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 10*60 * 1000
mqtt_out_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}       
mqtt_trig_topics[mqtt_base_topic.."BT"]={
                pin = BT_PIN,
                pullup = true,
                type = "down", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = function()
                        print("Bt pushed")
                        --mqtt_in_topics[mqtt_base_topic.."RELAIS"]["CHANGE"]()
                        -- TODO : régler problème de déclenchement intempestif quand relais activé via WIFI
                        return 1
                    end
                }         
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
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
mqtt_in_topics[mqtt_base_topic.."RELAIS"]={
            ["ON"]=function()
                        gpio.write(RELAIS_PIN,gpio.HIGH)
                        gpio.write(LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(RELAIS_PIN,gpio.LOW)
                        gpio.write(LED_PIN,gpio.LOW)
                    end,
            ["CHANGE"]=function()
                        if gpio.read(RELAIS_PIN)==gpio.HIGH then
                            gpio.write(RELAIS_PIN,gpio.LOW)
                            gpio.write(LED_PIN,gpio.LOW)
                        else
                            gpio.write(RELAIS_PIN,gpio.HIGH)
                            gpio.write(LED_PIN,gpio.HIGH)
                        end
                    end}
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
disp_texts = {}

