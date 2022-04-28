-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--                  programmation chaudière
--               avec
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
    -- THERMOMETRE
    thermometer = require("ds18b20")
    pin_thermometer = 4 -- pin D4

    ------------------
    -- Params WIFI
    ------------------
    App.net = {
        ssid = {"OLFA_PRODUCTION", "OLFA_WIFI","WIFI_THOME2"},
        password = {"79073028", "Olfa08SignyLePetit", "plus33324333562"},
        wifi_time_retry = 10, -- minutes
        }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        --host = "192.168.10.155",
        host = "192.168.0.11",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-ROBOT-TEMP",
        base_topic = "OLFA/ROBOT/CABINES/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 10000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."TEMPERATURES"]={
                message = function()
                        thermometer:read_temp(function(temps)
                                for addr, temp in pairs(temps) do
                                    local sensor = ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8))
                                    App.mqtt_publish(temp, App.mqtt.base_topic.."TEMPERATURES/"..sensor)
                                end
                            end, pin_thermometer, thermometer.C)
                    end}
 
    -- Messages sur trigger GPIO

    App.mqtt_trig_topics = {}

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
 
end
return App
