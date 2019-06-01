-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--					- capteurs de température DS18b20
--						- frigo
--						- congélateur
--						- ambiance cuisine
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, ds1820
-------------------------------------------------

local App = {}

do

    App.msg_debug = true
    App.watchdog = {timeout = 30*60}

    LED_PIN = 3
    BUZZER_PIN = 1
    BT_PIN = 7
    gpio.mode(LED_PIN, gpio.OUTPUT)
    gpio.write(LED_PIN, gpio.LOW)
    gpio.mode(BT_PIN, gpio.INPUT)

    --------------------------------------
    -- PARAMETRES CAPTEURS - ACTIONEURS
    --------------------------------------

    -- Capteur température DSx20
    DS1820_PIN = 4
    thermometres=_dofile("ds1820_reader")
    thermometres.init(DS1820_PIN)

    sensors = {
        frigo = "28:FF:4A:90:51:14:00:FA",
        cuisine = "28:FF:32:E2:50:14:00:AD",
        congelateur = "28:FF:75:5C:A0:16:03:6F"
    }


    --------------------------------------
    -- Params WIFI
    --------------------------------------
    App.net = {
            ssid = {"WIFI_THOME1",'WIFI_THOME2'},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }
    ----------------------------------------
    -- Params MQTT
    ----------------------------------------
    App.mqtt = {
        host = "192.168.10.155",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-CUISINE",
        base_topic = "T-HOME/CUISINE/"
    }
    ----------------------------------------
    -- Messages MQTT sortants
    ----------------------------------------
    App.mesure_period = 10*60 * 1000
    App.mesure_interval = 20000 -- 20 secondes entre chaque mesure
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."REFRIGERATEUR/temperature"]={
                    result_on_callback = function(callback)
                            thermometres.read(sensors["frigo"],callback)
                        end,
                    qos = 0, retain = 0, callback = nil}
    App.mqtt_out_topics[App.mqtt.base_topic.."CONGELATEUR/temperature"]={
                    result_on_callback = function(callback)
                            thermometres.read(sensors["congelateur"],callback)
                        end,
                    qos = 0, retain = 0, callback = nil}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                    result_on_callback = function(callback)
                            thermometres.read(sensors["cuisine"],callback)
                        end,
                    qos = 0, retain = 0, callback = nil}
    ----------------------------------------
    -- Messages sur trigger GPIO
    ----------------------------------------
    App.mqtt_trig_topics = {}
    App.mqtt_trig_topics[App.mqtt.base_topic.."BT"]={
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
    App.mqtt_in_topics = {}
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
    App.mqtt_in_topics[App.mqtt.base_topic.."BUZZER"]={
                ["ON"]=function()
                            gpio.write(BUZZER_PIN, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            gpio.write(BUZZER_PIN, gpio.LOW)
                        end}
    ----------------------------------------
    --Gestion du display : mqtt(json)=>affichage
    ----------------------------------------
    --App.disp_texts = {}

end

return App
