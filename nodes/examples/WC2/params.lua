-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               WC pour gestion de la qualité de l'air
--                      - un capteur MQ-5   sur A7 de MCP3008
--                      - un capteur luminosite   sur A0 de MCP3008
--                      - des leds
-------------------------------------------------
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

LED_0 = 0 -- VERT
LED_1 = 5 -- JAUNE
LED_2 = 6 -- RED
LED_3 = 7 -- RED
LED_4 = 8 -- RED
gpio.mode(LED_0, gpio.OUTPUT)
gpio.mode(LED_1, gpio.OUTPUT)
gpio.mode(LED_2, gpio.OUTPUT)
gpio.mode(LED_3, gpio.OUTPUT)
gpio.mode(LED_4, gpio.OUTPUT)
gpio.write(LED_0,gpio.LOW)
gpio.write(LED_1,gpio.LOW)
gpio.write(LED_2,gpio.LOW)
gpio.write(LED_3,gpio.LOW)
gpio.write(LED_4,gpio.LOW)



-- Module MCP3008 pour entree analogiques
mcp = _dofile("mcp3008")
mcp.init(2,3,1,4) -- miso, mosi, clk, cs
-- Analog pins on mcp3008
PIN_MQ5 = 7
PIN_LUM = 0
--------------------------------------
-- Modules a charger
--------------------------------------
modules={}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME2",'WIFI_THOME1'}
PASSWORD = "plus33324333562"
HOST = "NODE-WC2"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/WC2/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."MQ-5"]={
                message = function()
                        return mcp.read(PIN_MQ5)/1023*100
                    end,
                qos = 0, retain = 0, callback = nil,
                manual = false}
mqtt_out_topics[mqtt_base_topic.."LUM"]={
                message = function()
                        return mcp.read(PIN_LUM)/1023*100
                    end,
                qos = 0, retain = 0, callback = nil,
                manual = false}
-- Messages MQTT sortants sur test 
test_period = 500
mqtt_test_topics = {}
luminosite = 0
mqtt_test_topics[mqtt_base_topic.."LUM"]={{
                test = function()
                            local l = mcp.read(PIN_LUM)
                            if math.abs(l-luminosite)>100 then
                                luminosite = l
                                return true
                            else
                                return false
                            end
                        end,
                value = function()
                            return luminosite/1023*100
                        end,
                mqtt_repeat = false,
                qos = 0, retain = 0, callback = nil}}
mq5 = 0
mqtt_test_topics[mqtt_base_topic.."MQ-5"]={{
                test = function()
                            local v = mcp.read(PIN_MQ5)
                            if math.abs(v-mq5)>100 then
                                mq5 = v
                                return true
                            else
                                return false
                            end
                        end,
                value = function()
                            return mq5/1023*100
                        end,
                mqtt_repeat = false,
                qos = 0, retain = 0, callback = nil}}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}


----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
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
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
            
