-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--            - VL6160X Time-of-Flight Distance Sensor Carrier
--              pour niveau d'eau piscine
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, i2c
-------------------------------------------------
local App = {}

do
    --App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    --App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- Capteur Niveau d'eau
    capteur = require 'vl6180x'
    capteur.init(5,6,0x29) --sda, scl, _addr
    --capteur.init=nil --free memory

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
        client_name = "NODE-NIVEAU-PISCINE-OLD",
        base_topic = "T-HOME/PISCINE-OLD/"
    }
    
    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."NIVEAU"]={
                    message = function()
                            local min = 255
                            local max = 0
                            local somme_mesures = 0
                            local nb_mesures = 0
                            for i = 1,10 do
                                local niveau = capteur.distance()
                                if niveau then
                                    nb_mesures = nb_mesures + 1
                                    somme_mesures = somme_mesures + niveau
                                    if niveau > max then max = niveau end
                                    if niveau< min then min = niveau end    
                                end
                            end
                            if nb_mesures >= 3 then
                                somme_mesures = somme_mesures - min - max
                                nb_mesures = nb_mesures - 2
                            end
                            return math.floor(somme_mesures / nb_mesures + 0.5)
                        end}
    App.mqtt_out_topics[App.mqtt.base_topic.."AMBIENT"]={
                       message = capteur.ambient
                       }
end

return App
