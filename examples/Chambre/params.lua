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
    pin_detect = 3
    
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
        client_name = "NODE-CHAMBRE",
        base_topic = "T-HOME/CHAMBRE/"
    }
    
    -- Messages MQTT sortants
    --App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}

    -- Messages sur trigger GPIO
    App.mqtt_trig_topics = {}
    App.mqtt_trig_topics[App.mqtt.base_topic.."DETECT"]={
                    pin = pin_detect,
                    pullup = false,
                    type = "up", -- or "down", "both", "low", "high"
                    message = function(level, when, eventcount)
                            if level==gpio.HIGH and eventcount == 1 then
                                return level
                            end
                        end
                    }   

end
return App
