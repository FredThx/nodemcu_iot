-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                  - capteur de température et humidité DHT11
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, dht
-------------------------------------------------


local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")



    ------------------
    -- Params WIFI 
    ------------------
    App.net = {
            ssid = {"WIFI_THOME1",'WIFI_THOME2','WIFI_THOME3'},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = nil,-- '192.168.10.155', --automatique
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-TEST",
        base_topic = "T-HOME/TEST/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 10*60 * 1000
    App.mesure_interval = 1000
    App.mqtt_out_topics = {}

end
return App
