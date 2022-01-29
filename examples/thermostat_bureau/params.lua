-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                  - capteur de luminosité sur A0
--                  - Capteur BMP180 (pression atm + température
--                  - Emetteur FR pour piloter prises
--                  - Display oled en i2c
--                  - Leds
--                  - détecteur de mouvement IR
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, ds18b20
-------------------------------------------------
local App = {}
do

    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
  
    --CAPTEUR DHT
    DHT_pin = 4
    
    
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
        client_name = "NODE-BUREAUZ",
        base_topic = "T-HOME/BUREAUZ/"
    }

    local function read_temps(temps, callback)
        for addr, temp in pairs(temps) do
            callback(temp)
        end
    end

    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                    message = function()
                            local status,temp,humi = dht.read(DHT_pin)
                            if status == 0 then
                                return temp
                             end
                        end}
end
return App
