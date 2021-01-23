-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour capteur de vitesse d'air
--               avec
--              - 1 OMRON DF6_V
--
-------------------------------------------------
--  Wiring : voir DF6_V.lua
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, adc
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- Capteur
    sensor = require("DF6_V")

    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {"OLFA_PRODUCTION", "WIFI_THOME2"},
            password = {"79073028", "plus33324333562"},
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        --host = "192.168.0.11",
        host = "192.168.10.155",
        port = 1883,
        --user = "fredthx",
        --pass = "GaZoBu",
        client_name = "CAB1-FLOW",
        base_topic = "OLFA/PEINTURE/CAB1_FLOW/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 1 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."flow"]={
                message = function()
                        return sensor.read()
                    end}
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}

end
return App
