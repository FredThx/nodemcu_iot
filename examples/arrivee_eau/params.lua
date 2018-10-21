-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--              - VANNE EAU pilotée par REALAIS
--			    - capteur de debit
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, sjson
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- Relais qui pilote la vanne
    pin_vanne=7
    gpio.mode(pin_vanne, gpio.OUTPUT)

    -- débitmetre
    pin_debit = 1
    flowmeter = require("flowmeter")


    ------------------
    -- Params WIFI 
    ------------------
    App.net = {
            ssid = {"WIFI_THOME3",'WIFI_THOME2',"WIFI_THOME1"},
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
        client_name = "NODE-ARRIVEE-EAU",
        base_topic = "T-HOME/ARRIVEE-EAU/"
    }
    
    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}

    flowmeter.init(pin_debit,8.1,5,1000,tmr.ALARM_AUTO,function(debit)
        if App.mqtt_publish then
            App.mqtt_publish(debit,App.mqtt.base_topic.."FLOW")
        end
    end)
    
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}    
    App.mqtt_in_topics[App.mqtt.base_topic.."VANNE"] = {
            ["ON"]=function()
                        gpio.write(pin_vanne, gpio.LOW)
                    end,
            ["OFF"]=function()
                        gpio.write(pin_vanne, gpio.HIGH)
                    end}
    App.mqtt_in_topics[App.mqtt.base_topic.."VOLUME_"] = {
            ["SENDIT"] = function()
                            return flowmeter.volume
                         end
            }
    App.mqtt_in_topics[App.mqtt.base_topic.."SET_VOLUME"] = function(data)
                            flowmeter.volume = tonumber(data)
                         end

    App.mqtt.connected_callback = function()
            App.mqtt_publish("ON",App.mqtt.base_topic.."VANNE")
        end
    

        
end
return App
