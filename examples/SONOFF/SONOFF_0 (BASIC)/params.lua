-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--                  hack d'une prise SONOFF BASIC
--               avec
--              - relais
--			        - led
--              - bouton
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 5*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
    -- Relais
    RELAIS_PIN=6
    gpio.mode(RELAIS_PIN, gpio.OUTPUT)
    gpio.write(RELAIS_PIN, gpio.LOW)
    -- Led
    LED_PIN = 7
    gpio.mode(LED_PIN, gpio.OUTPUT)
    gpio.write(LED_PIN, gpio.HIGH)--HIGH : led off!
    -- Bouton
    pin_bt = 3
    gpio.mode(pin_bt, gpio.INPUT)

    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {'WIFI_THOME2'},--,"WIFI_THOME3"},
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
        client_name = "NODE-SONOFF-0",
        base_topic = "T-HOME/SONOFF/0/"
    }

    -- Messages MQTT sortants
    App.mesure_period = nil
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."ETAT"]={
                message = function()
                        if gpio.read(RELAIS_PIN)==gpio.HIGH then
                            return "ON"
                        else
                            return "OFF"
                        end
                    end}
    -- Messages sur trigger GPIO

    App.mqtt_trig_topics = {}
    App.mqtt_trig_topics[App.mqtt.base_topic.."BT"]={
                    pin = pin_bt,
                    --pullup = true,
                    type = "down",
                    qos = 0, retain = 0, callback = nil,
                    message = function()
                            print("Bt pushed")
                            if gpio.read(RELAIS_PIN)==gpio.HIGH then
                                gpio.write(RELAIS_PIN,gpio.LOW)
                                gpio.write(LED_PIN, gpio.HIGH)
                            else
                                gpio.write(RELAIS_PIN,gpio.HIGH)
                                gpio.write(LED_PIN, gpio.LOW)
                            end
                            return 1
                        end
                    }

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."RELAIS"] = {
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
                            gpio.write(LED_PIN, gpio.LOW)
                        end,
                ["OFF"]=function()
                            led_alarm:stop()
                            gpio.write(LED_PIN, gpio.HIGH)
                        end,
                ["BLINK"]=function()
                            gpio.write(LED_PIN,gpio.HIGH)
                            led_alarm:alarm(500,tmr.ALARM_SINGLE, function()
                                    gpio.write(LED_PIN,gpio.LOW)
                                end)
                        end,
                ["BLINK_ALWAYS"]=function()
                            led_alarm:alarm(500,tmr.ALARM_AUTO, function()
                                    if led_on then
                                        gpio.write(LED_PIN,gpio.LOW)
                                        led_on = false
                                    else
                                        gpio.write(LED_PIN,gpio.HIGH)
                                        led_on = true
                                    end
                                end)
                            end}

-- At start
    App.mqtt_in_topics[App.mqtt.base_topic.."LED"]['BLINK_ALWAYS']()
    App.mqtt.on_connected = function()
        App.mqtt_in_topics[App.mqtt.base_topic.."LED"]['OFF']()
        end
    App.mqtt.disconnected_callback = function()
            App.mqtt_in_topics[App.mqtt.base_topic.."LED"]['BLINK_ALWAYS']()
        end

end
return App
