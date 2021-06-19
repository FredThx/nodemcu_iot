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
        host = "192.168.10.155",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-WIFI_SCANNER",
        base_topic = "T-HOME/WIFI_SCANNER/"
    }
    
    -- Messages MQTT sortants
    --App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."SCAN"]={
                message = function()
                        wifi.sta.getap(1, function(t)
                                App.mqtt_publish(t, App.mqtt.base_topic.."SCAN")
                            end)
                    end}
    -- Messages sur trigger GPIO
    App.mqtt_trig_topics = {}
end
return App
