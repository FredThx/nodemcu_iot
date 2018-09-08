-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec

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
        base_topic = "T-HOME/PISCINE/"
    }
    
    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."NIVEAU"]={
                    message = function()
                            local pression
                            pression = can.read(0) / 1023 * 5 -- Vref = 5V
                            pression = pression / 25 * 10000 -- Gain ampli-op = 1000 & 25mV -> 10kpa
                            return math.floor(pression)
                            --return math.floor(pression * 0.09 + 17) -- en cm (10m = 10^5 Pa) & correrction
                        end}
end

return App
