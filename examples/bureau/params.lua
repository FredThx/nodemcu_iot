-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour detection présence
--               avec
--              - 1 detecteur IR type SEN0018
--
-------------------------------------------------
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")


    -- Detecteur de mouvement
    pin_detect = 2
    -- led
    pin_led = 5
    gpio.mode(pin_led, gpio.OUTPUT)
    gpio.write(pin_led,gpio.LOW)
    
    ------------------
    -- Params WIFI 
    ------------------
    App.net = {
            ssid = {'WIFI_THOME2'},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = nil, --"192.168.10.155",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-BUREAU",
        base_topic = "T-HOME/BUREAU/"
    }
    
    -- Messages MQTT sortants
    App.mesure_period = nil --60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."DETECT"]={
                    message = function()
                            return gpio.read(pin_detect)
                        end,
                    qos = 0, retain = 0, callback = nil}
    
    -- Messages sur trigger GPIO
    App.mqtt_trig_topics = {}
    detect_level = 0
    App.mqtt_trig_topics[App.mqtt.base_topic.."DETECT"]={
                    pin = pin_detect,
                    pullup = false,
                    type = "both", -- or "down", "both", "low", "high"
                    message = function(level, when, eventcount)
                            if level ~= detect_level then
                                detect_level = level
                                
                            end
                            return level
                        end
                    }   
 -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    led_alarm = tmr.create()
    App.mqtt_in_topics[App.mqtt.base_topic.."LED"]={
                ["ON"]=function()
                            led_alarm:stop()
                            gpio.write(pin_led, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            led_alarm:stop()
                            gpio.write(pin_led, gpio.LOW)
                        end,
                ["BLINK"]=function()
                            gpio.write(pin_led,gpio.HIGH)
                            led_alarm:alarm(500,tmr.ALARM_SINGLE, function()
                                    gpio.write(pin_led,gpio.LOW)
                                end)
                        end,
                ["BLINK_ALWAYS"]=function()
                            led_alarm:alarm(500,tmr.ALARM_AUTO, function()
                                    if led_state then
                                        gpio.write(pin_led,gpio.LOW)
                                        led_state = false
                                    else
                                        gpio.write(pin_led,gpio.HIGH)
                                        led_state = true
                                    end
                                end)
                            end}
    App.mqtt_in_topics[App.mqtt.base_topic.."LED"]["BLINK_ALWAYS"]()
end
return App
