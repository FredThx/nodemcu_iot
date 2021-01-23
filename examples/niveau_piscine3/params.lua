-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--            - LPS35HW  (capteur de pression)
--                  en liaison i2
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, i2c
-------------------------------------------------
local App = {}

do
    --App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- Convertisseur Analogique Nnumérique MCP3008
    sensor = require 'LPS35HW'
    --gpio.mode(5, gpio.OUTPUT) -- CS
    --gpio.write(5,gpio.HIGH) -- CS : select i2C
    --gpio.mode(3, gpio.OUTPUT) -- SDO
    --gpio.write(3,gpio.HIGH) -- SA0 : select 0x5D as addr
    sensor.init(1,3) -- SDA, SCL
    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {"WIFI_THOME1",'WIFI_THOME2'},
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
        client_name = "NODE-NIVEAU-PISCINE",
        base_topic = "T-HOME/PISCINE/FOND/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 10*60*1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."PRESSION"]={
                    message = function()
                            return sensor.read_pressure()
                        end}
    App.mqtt_out_topics[App.mqtt.base_topic.."TEMPERATURE"]={
                    message = function()
                            return sensor.read_temperature()
                        end}
end

return App
