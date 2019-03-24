-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--                  programmation chaudière
--               avec
--              - relais pour pilotage chaudière
--			        - led
--              - capteur température (ds18b20) pour température chaudière
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt,ds18b20,ow
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
    -- Relais
    RELAIS_PIN=1
    gpio.mode(RELAIS_PIN, gpio.OUTPUT)
    gpio.write(RELAIS_PIN, gpio.LOW)
    -- Led
    LED_PIN = 8
    gpio.mode(LED_PIN, gpio.OUTPUT)
    gpio.write(LED_PIN, gpio.LOW)
    -- THERMOMETRE
    thermometer = require 'ds1820_reader'
    thermometer.init(5) -- pin D5


    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {'WIFI_THOME2',"WIFI_THOME1","WIFI_THOME3"},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = "192.168.10.155",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-CHAUDIERE",
        base_topic = "T-HOME/CHAUDIERE/"
    }

    -- Messages MQTT sortants
    App.mesure_period = nil
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."EAU"]={
                message = function()
                        thermometer.read(nil, function(temp)
                                App.mqtt_publish(temp, App.mqtt.base_topic.."EAU")
                            end)
                    end}
    -- Messages sur trigger GPIO

    App.mqtt_trig_topics = {}

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."REGUL"] = {
            ["ON"]=function()
                        gpio.write(RELAIS_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(RELAIS_PIN, gpio.LOW)
                    end}
    led_alarm = tmr.create()
    App.mqtt_in_topics[App.mqtt.base_topic.."LED"]={
                ["ON"]=function()
                            led_alarm:stop()
                            gpio.write(LED_PIN, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            led_alarm:stop()
                            gpio.write(LED_PIN, gpio.LOW)
                        end,
                ["BLINK"]=function()
                            gpio.write(LED_PIN,gpio.HIGH)
                            led_alarm:alarm(500,tmr.ALARM_SINGLE, function()
                                    gpio.write(LED_PIN,gpio.LOW)
                                end)
                        end,
                ["BLINK_ALWAYS"]=function()
                            led_alarm:alarm(500,tmr.ALARM_AUTO, function()
                                    if led_alarm then
                                        gpio.write(LED_PIN,gpio.LOW)
                                        led_alarm = false
                                    else
                                        gpio.write(LED_PIN,gpio.HIGH)
                                        led_alarm = true
                                    end
                                end)
                            end}



end
return App
