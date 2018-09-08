-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--            - Ruban de LED WS2812 (sur pin D4)
--              organisé pour représenter un horloge
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, ws2812
-------------------------------------------------
local App = {}

do
    --App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = false -- if true : send messages (ex : "MQTT send : ok")

    -- ruban de leds
    ws2812.init()
    buffer=ws2812.newBuffer(150,3)
    buffer:fill(0, 0, 0)
    ws2812.write(buffer)
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
        client_name = "NODE-HORLOGE-LEDS",
        base_topic = "T-HOME/HORLOGE-LEDS/"
    }
    
    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    
    ----------------------------------------
    -- Messages sur trigger GPIO
    ----------------------------------------
    App.mqtt_trig_topics = {}
    
    ----------------------------------------
    -- Actions sur messages MQTT entrants
    ----------------------------------------
    App.mqtt_in_topics = {}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."LEDS"] = {
                ["OFF"]=function()
                        buffer:fill(0, 0, 0)
                        ws2812.write(buffer)   
                    end}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."FADE"]= function(data)
                data = tonumber(data)
                if data then
                    if data > 0 then 
                        buffer:fade(data, ws2812.FADE_OUT)
                    else
                        buffer:fade(-data, ws2812.FADE_IN)
                    end
                    ws2812.write(buffer)   
                end
            end
    
    App.mqtt_in_topics[App.mqtt.base_topic.."SHIFT"]= function(data)
                if tonumber(data) then
                    buffer:shift(tonumber(data))
                else
                    local isjson, datas = pcall(sjson.decode, data)
                    if isjson then
                        buffer:shift(datas.value, datas.mode , datas.i , datas.j)
                    end
                end
                ws2812.write(buffer)   
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."SET"]= function(data)
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buffer:set(datas.index, datas.color)
                end
                ws2812.write(buffer)
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."FILL"]= function(data)
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buffer:fill(unpack(datas))
                end
                ws2812.write(buffer)
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."REPLACE"]= function(data)
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buffer:replace(datas.source, datas.offset)
                end
                ws2812.write(buffer)
            end
end

return App
