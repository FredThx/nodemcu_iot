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

--TODO
-- * finir multibuffer
--      * FADE et mettre en place un vrai fade durable sur les 3 buffers
-- * du vrai multi buffers (nb dynamique)


local App = {}

do
    --App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = false -- if true : send messages (ex : "MQTT send : ok")

    -- ruban de leds
    ws2812.init()
    nb_leds = 7*21
    buffer=ws2812.newBuffer(nb_leds,3)
    buffers={}
    buffers.horloge=ws2812.newBuffer(nb_leds,3)
    buffers.fond=ws2812.newBuffer(nb_leds,3)
    buffers.jeux=ws2812.newBuffer(nb_leds,3)
    luminosite = 256
    ws2812.write(buffer)
    leds_on = true
    -- Fonctions pour gestion LEDS
    function write_buffers()
        buffer:fill(0, 0, 0)
        buffer:mix(luminosite,buffers.horloge,luminosite,buffers.fond,luminosite,buffers.jeux)
        if leds_on then
            -- inverse les colonnes paires (ce qui a été gagné en cablage est pardu en efficacité ici!)
            local buf_str=buffer:dump()
            for i=0,nb_leds/7-1 do
                local colonne = ""
                if i%2==1 then
                    for pixel in string.gmatch(buf_str:sub(i*7*3+1,(i*7+7)*3),"...") do
                        colonne = pixel .. colonne
                    end
                    buffer:replace(colonne,i*7+1)
                end
            end
            ws2812.write(buffer)
        end
    end


    function select_buffer(buffer_name)
        if buffer_name then
            return buffers[buffer_name]
        else
            return buffers['fond']
        end
    end
    
    --Bouton
    pin_bt = 5

    gpio.mode(pin_bt,gpio.INT)
    gpio.trig(pin_bt, "up", function(level)
            if leds_on then
                App.mqtt_in_topics[App.mqtt.base_topic.."LEDS"]["OFF"]()
            else
                App.mqtt_in_topics[App.mqtt.base_topic.."LEDS"]["ON"]()
            end
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
                ["OFF"]=function()
                            leds_on = false
                            buffer:fill(0, 0, 0)
                            ws2812.write(buffer)   
                        end,
                ["ON"]=function()
                            leds_on = true
                            write_buffers()
                        end,
                 ["CLEAR"]=function()
                            for k,buf in pairs(buffers) do
                                buf:fill(0,0,0)
                            end
                            write_buffers()
                        end
                        }
    
    App.mqtt_in_topics[App.mqtt.base_topic.."LUMINOSITE"]= function(data)
                -- Change the luminosity
                -- ex : msg.payload = "10" ou "-5"
                --TODO : voir multibuffers
                data = tonumber(data)
                if data then
                    luminosite = data
                    write_buffers()
                end
            end
    
    App.mqtt_in_topics[App.mqtt.base_topic.."SHIFT"]= function(data)
                -- Shift all the leds
                -- ex : msg.payload = "1" (or -2)
                -- ex : msg.payload = "{"value":1,"mode":1,"i":1,"j":10}"
                if tonumber(data) then
                    for k,buf in pairs(buffers) do
                        buf:shift(tonumber(data))
                    end
                else
                    local isjson, datas = pcall(sjson.decode, data)
                    if isjson then
                        local buf = select_buffer(datas.buffer)
                        buf:shift(datas.value, datas.mode , datas.i , datas.j)
                    end
                end
                write_buffers()
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."SET"]= function(data)
                -- Set a led
                -- ex : msg.payload = "{"index":5,"color":[0,255,0],"buffer":"horloge"}"
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    local buf = select_buffer(datas.buffer)
                    if type(datas.index)== 'table' then
                        for k,index in ipairs(datas.index) do
                            if type(datas.color[1])=='table' then
                                buf:set(index, datas.color[k])
                            else
                                buf:set(index, datas.color)
                            end
                        end
                    else
                        buf:set(datas.index, datas.color)
                    end
                end
                write_buffers()
            end
    App.mqtt_in_topics[App.mqtt.base_topic.."FILL"]= function(data)
                -- Fill all the leds
                -- ex : msg.payload = "[0,0,10]" ou msg.payload = "{buffer:"jeux",color:"[0,255,0]}"
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    buf = select_buffer(datas.buffer)
                    if datas.color then
                        buf:fill(unpack(datas.color))
                    else
                        buf:fill(unpack(datas))
                    end
                end
                ws2812.write(buffer)
            end

    App.mqtt_in_topics[App.mqtt.base_topic.."WRITE_BUFFER"]= function(data)
                -- Write leds 
                -- ex : msg.payload = "{"offset":5,"source":[1,0,0,1,0,0,1],"color":[255,255,0],"fond":[50,50,50],"buffer":"horloge"}"
                local isjson, datas = pcall(sjson.decode, data)
                if isjson then
                    local buf = select_buffer(datas.buffer)
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
                        buf:replace(source, datas.offset)
                    end
                end
                write_buffers()
            end
end

return App
