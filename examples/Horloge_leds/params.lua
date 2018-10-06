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
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- ruban de leds
    ws2812.init()
    buffer=ws2812.newBuffer(150,3)
    buffer:fill(0, 0, 0)
    ws2812.write(buffer)

    --Bouton
    pin_bt = 5

    gpio.mode(pin_bt,gpio.INT)
    gpio.trig(pin_bt, "up", function(level)
            node.restart()
        end)
    
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
                -- Turn off all the leds
                -- TODO : faire une copie du buffer pour faire un "ON"
                ["OFF"]=function()
                        buffer:fill(0, 0, 0)
                        ws2812.write(buffer)   
                    end}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."FADE"]= function(data)
                -- Change the luminosity
                -- ex : msg.payload = "10" ou "-5"
                data = tonumber(data)
                if data then
                    if data > 0 then 
                        buffer:fade(data, ws2812.FADE_OUT)
                        -- TODO : stocker état actuel pour faire un "UNFADE"
                    else
                        buffer:fade(-data, ws2812.FADE_IN)
                    end
                    ws2812.write(buffer)   
                end
            end
    
    App.mqtt_in_topics[App.mqtt.base_topic.."SHIFT"]= function(data)
                -- Shift all the leds
                -- ex : msg.payload = "1" (or -2)
                -- ex : msg.payload = "{"value":1,"mode":1,"i":1,"j":10}"
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
                -- Set a led
                -- ex : msg.payload = "{"index":5,"color":[0,255,0]}"
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buffer:set(datas.index, datas.color)
                end
                ws2812.write(buffer)
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."FILL"]= function(data)
                -- Fill all the leds
                -- ex : mag.payload = "[0,0,10]"
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buffer:fill(unpack(datas))
                end
                ws2812.write(buffer)
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."REPLACE"]= function(data)
                -- don't work!
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buffer:replace(datas.source, datas.offset)
                end
                ws2812.write(buffer)
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."WRITE_BUFFER"]= function(data)
                -- Write leds 
                -- ex : msg.payload = "{"offset":5,"source":[1,0,0,1,0,0,1],"color":[255,255,0],"fond":[50,50,50]}"
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    local source = ""
                    local color = datas.color or {255,255,255}
                    local fond = datas.fond or {0,0,0}
                    local i, led
                    for i, led in ipairs(datas.source) do
                        if led == 1 then
                            source = source .. string.char(unpack(color))
                        else
                            source = source .. string.char(unpack(fond))
                        end
                    end
                    if #source>0 then
                        buffer:replace(source, datas.offset)
                    end
                end
                ws2812.write(buffer)
            end
end

return App
