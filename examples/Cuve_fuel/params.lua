-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour Cuve Fuel
--               avec
--                  - capteur de distance branché sur MCP3008
--                  - Led
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, (spi)
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = true
WATCHDOG_TIMEOUT = 30*60 -- 30 minutes

-- MPC3008
MPC_PIN = 0
mpc = dofile('mcp3008.lc')
mpc.init() -- default pins
mpc.init = nil -- to free memory

--gpio.mode(LED_PIN, gpio.INPUT)

-- LED
GREEN_LED_PIN = 2
RED_LED_PIN = 1
gpio.mode(GREEN_LED_PIN, gpio.OUTPUT)
gpio.write(GREEN_LED_PIN, gpio.LOW)
gpio.mode(RED_LED_PIN, gpio.OUTPUT)
gpio.write(RED_LED_PIN, gpio.LOW)
------------------------------
-- Modules a charger
------------------------------
modules={ --"ds1820_reader.lua","DTH_reader.lua",

    }

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-CUVE-FUEL"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/CUVE-FUEL/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."distance"]={
                message = function()
                        return mpc.read(MPC_PIN) * 5000 * 5 / 4.88 /1024
                    end,
                qos = 0, retain = 0, callback = nil}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."green_led"]={
            ["ON"]=function()
                        gpio.write(GREEN_LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(GREEN_LED_PIN,gpio.LOW)
                    end
                    }
mqtt_in_topics[mqtt_base_topic.."red_led"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(RED_LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(RED_LED_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(RED_LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(RED_LED_PIN,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(RED_LED_PIN,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(RED_LED_PIN,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
