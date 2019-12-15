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

    -- Capteur DTH11-22
    DHT_pin = 2

    ------------------
    -- Params WIFI 
    ------------------
    App.net = {
            ssid = {"WIFI_THOME2","OLFA_PRODUCTION", "OLFA_WIFI"},
            password = {"plus33324333562", "79073028", "Olfa08SignyLePetit"},
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = "192.168.0.11",
        --host = "192.168.10.155",
        port = 1883,
        client_name = "NODE-ETUVE1",
        base_topic = "OLFA/ETUVE1/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 10*60 * 1000
    App.mesure_interval = 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                    message = function()
                            local status,temp,humi = dht.read(DHT_pin)
                            if status == 0 then
                                return temp
                             end
                        end}
    App.mqtt_out_topics[App.mqtt.base_topic.."humidite"]={
                    message = function()
                            local status,temp,humi = dht.read(DHT_pin)
                            if status == 0 then
                                return humi
                            end
                        end}

    App.mqtt_out_topics[App.mqtt.base_topic.."RSSI"]={
                    message = function()
                            
                            return wifi.sta.getrssi()
                        end}
    
end
return App
