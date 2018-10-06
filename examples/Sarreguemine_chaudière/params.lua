-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres Gestion du chauffage
--               avec
--                  - 1 relais 10A pour pilotage chaudiere
--                  - 2 LEDs
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = true
WATCHDOG_TIMEOUT = 30*60 -- 30 minutes


-- Relais

R_CHAUF_PIN = 1
gpio.mode(R_CHAUF_PIN, gpio.OUTPUT)
gpio.write(R_CHAUF_PIN, gpio.LOW)

-- LED
LED_1_PIN = 7
LED_2_PIN = 5
gpio.mode(LED_1_PIN, gpio.OUTPUT)
gpio.write(LED_1_PIN, gpio.LOW)
gpio.mode(LED_2_PIN, gpio.OUTPUT)
gpio.write(LED_2_PIN, gpio.LOW)

------------------------------
-- Modules a charger
------------------------------
modules={}

------------------
-- Params WIFI 
------------------
SSID = {"THOME_24"}
PASSWORD = "plus33324333562"
HOST = "NODE-SARREG-CHAUFF"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
--mqtt_host = "31.29.97.206"
mqtt_host = "192.168.0.20"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-SARREG/CHAUFF/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}

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
mqtt_in_topics[mqtt_base_topic.."chauffe"]={
            ["ON"]=function()
                        gpio.write(R_CHAUF_PIN,gpio.LOW)
                    end,
            ["OFF"]=function()
                        gpio.write(R_CHAUF_PIN,gpio.HIGH)
                    end
					}

					
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
