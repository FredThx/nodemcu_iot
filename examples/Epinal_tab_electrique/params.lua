-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour Tableau electrique - Gestion du chauffage
--               avec
--                  - 2 relais 10A pour coupure Chauffage
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, ow
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = true
WATCHDOG_TIMEOUT = 30*60 -- 30 minutes

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { 
    [string.char(40,190,46,45,6,0,0,108)] = "cuisine"
}
-- Relais

R_CHAUF_1_PIN = 5
R_CHAUF_2_PIN = 6
gpio.mode(R_CHAUF_1_PIN, gpio.OUTPUT)
gpio.write(R_CHAUF_1_PIN, gpio.LOW)
gpio.mode(R_CHAUF_2_PIN, gpio.OUTPUT)
gpio.write(R_CHAUF_2_PIN, gpio.LOW)

-- LED
LED_1_PIN = 7
LED_2_PIN = 8
gpio.mode(LED_1_PIN, gpio.OUTPUT)
gpio.write(LED_1_PIN, gpio.LOW)
gpio.mode(LED_2_PIN, gpio.OUTPUT)
gpio.write(LED_2_PIN, gpio.LOW)

------------------------------
-- Modules a charger
------------------------------
modules={ "ds1820_reader"
    }

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME"}
PASSWORD = "plus33324333562"
HOST = "NODE-EPINAL-TAB_ELECTRIQE"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
--mqtt_host = "31.29.97.206"
mqtt_host = "192.168.0.15"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-EPINAL/CUISINE/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        t = readDSSensors("cuisine")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."led_1"]={
            ["ON"]=function()
                        gpio.write(LED_1_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_1_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_1_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_1_PIN,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_1_PIN,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_1_PIN,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
					end
                    }
mqtt_in_topics[mqtt_base_topic.."led_2"]={
            ["ON"]=function()
                        gpio.write(LED_2_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_2_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_1_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_1_PIN,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_1_PIN,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_1_PIN,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
					end
                    }
mqtt_in_topics[mqtt_base_topic.."chauff_1"]={
            ["ON"]=function()
                        gpio.write(R_CHAUF_1_PIN,gpio.LOW)
                    end,
            ["OFF"]=function()
                        gpio.write(R_CHAUF_1_PIN,gpio.HIGH)
                    end
					}
mqtt_in_topics[mqtt_base_topic.."chauff_2"]={
            ["ON"]=function()
                        gpio.write(R_CHAUF_2_PIN,gpio.LOW)
                    end,
            ["OFF"]=function()
                        gpio.write(R_CHAUF_2_PIN,gpio.HIGH)
                    end
					}
					
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
