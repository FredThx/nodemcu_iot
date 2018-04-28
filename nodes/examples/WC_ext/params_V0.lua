-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               WC_ext pour affichage état WC
--                      - des leds
-------------------------------------------------
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

LED_0 = 1 -- VERT
LED_1 = 2 -- JAUNE
LED_2 = 3 -- RED
LED_3 = 4 -- RED
LED_4 = 5 -- RED
LED_LIBRE = 6
LED_OCCUPE = 7

gpio.mode(LED_1, gpio.OUTPUT)
gpio.mode(LED_2, gpio.OUTPUT)
gpio.mode(LED_3, gpio.OUTPUT)
gpio.mode(LED_4, gpio.OUTPUT)
gpio.mode(LED_0, gpio.OUTPUT)
gpio.mode(LED_LIBRE, gpio.OUTPUT)
gpio.mode(LED_OCCUPE, gpio.OUTPUT)
gpio.write(LED_1,gpio.LOW)
gpio.write(LED_2,gpio.LOW)
gpio.write(LED_3,gpio.LOW)
gpio.write(LED_4,gpio.LOW)
gpio.write(LED_0,gpio.LOW)
gpio.write(LED_LIBRE,gpio.LOW)
gpio.write(LED_OCCUPE,gpio.LOW)

--------------------------------------
-- Modules a charger
--------------------------------------
modules={}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME2",'WIFI_THOME1'}
PASSWORD = "plus33324333562"
HOST = "NODE-WC_EXT"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/WC_EXT/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

-- Messages MQTT sortants sur test 
test_period = 500
mqtt_test_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}

----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

mqtt_in_topics[mqtt_base_topic.."LED_1"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_1,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_1,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_1,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_1,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_1,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_1,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
mqtt_in_topics[mqtt_base_topic.."LED_2"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_2,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_2,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_2,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_2,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_2,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_2,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
mqtt_in_topics[mqtt_base_topic.."LED_3"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_3,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_3,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_3,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_3,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_3,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_3,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
mqtt_in_topics[mqtt_base_topic.."LED_4"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_4,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_4,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_4,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_4,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_4,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_4,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
mqtt_in_topics[mqtt_base_topic.."LED_0"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_0,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_0,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_0,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_0,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_0,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_0,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
mqtt_in_topics[mqtt_base_topic.."LED_LIBRE"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_LIBRE,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_LIBRE,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_LIBRE,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_LIBRE,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_LIBRE,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_LIBRE,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
mqtt_in_topics[mqtt_base_topic.."LED_OCCUPE"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_OCCUPE,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_OCCUPE,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_OCCUPE,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_OCCUPE,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_OCCUPE,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_OCCUPE,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
            
