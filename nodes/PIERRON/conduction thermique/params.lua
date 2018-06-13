-------------------------------------------------
--  Projet : 
-------------------------------------------------
--  Auteur :   
-------------------------------------------------
--  Ce fichier : paramètres pour interface PIERRON/33552
--               avec
--                  - 7 MCP9804
--                  
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, i2c, sjson
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = true
WATCHDOG_TIMEOUT = 30*60 -- 30 minutes
MSG_DEBUG = false -- if true : send messages (ex : "MQTT send : ok")


-- thermometres
mcp9803 = _dofile('mcp9803')
mcp9803.init(1,2,mcp9803.RES00625)
offsets={}
--mcp9803.i2c_init(1,2,mcp9803.res05)

modele = {
    MODELE="33552",
    VERSION="1"
    }


------------------------------
-- Lecture fichier offset   
------------------------------

if file.open("offset.json","r") then
    local txt = file.read()
    local ok, json = pcall(sjson.decode, txt)
    if ok then
        offsets = json
    end
end


------------------
-- Params WIFI 
------------------
SSID = {"PIERRON"}
PASSWORD = "Pierr0neducAction57206ruegutenberg"
HOST = "PI_33552"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
--mqtt_host = "31.29.97.206"
mqtt_host = "10.10.1.156"
mqtt_port = 1883
mqtt_user = nil
mqtt_pass = nil
mqtt_client_name = HOST
mqtt_base_topic = "PIERRON/" .. HOST .. "/"





-- Messages MQTT sortants
mesure_period =  1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperatures"]={
                message = function() 
                         local t = {}
                         t.MODELE = modele
                         t.DATAS={}
                        t.DATAS["T1"]=mcp9803.read(0x48)
                        t.DATAS["T2"]=mcp9803.read(0x49) + (offsets['T2'] or 0)
                        t.DATAS["T3"]=mcp9803.read(0x4A) + (offsets['T3'] or 0)
                        t.DATAS["T4"]=mcp9803.read(0x4B) + (offsets['T4'] or 0)
                        t.DATAS["T5"]=mcp9803.read(0x4C) + (offsets['T5'] or 0)
                        t.DATAS["T6"]=mcp9803.read(0x4D) + (offsets['T6'] or 0)
                        t.DATAS["T7"]=mcp9803.read(0x4E) + (offsets['T7'] or 0)
                        return t -- return 0 at 0V and 1 at 2V
                    end,
                usb = true,
                qos = 0, retain = 0, callback = nil}

-- Messages sur trigger GPIO
mqtt_trig_topics = {}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."ACTION"]={
            ["CALIBRE"]=function()
                        print("calibration")
                        offsets['T2'] =  mcp9803.read(0x48) - mcp9803.read(0x49)
                        offsets['T3'] =  mcp9803.read(0x48) - mcp9803.read(0x4A)
                        offsets['T4'] =  mcp9803.read(0x48) - mcp9803.read(0x4B)
                        offsets['T5'] =  mcp9803.read(0x48) - mcp9803.read(0x4C)
                        offsets['T6'] =  mcp9803.read(0x48) - mcp9803.read(0x4D)
                        offsets['T7'] =  mcp9803.read(0x48) - mcp9803.read(0x4E)

                        local f_offset = file.open("offset.json","w")
                        f_offset:write(sjson.encode(offsets))
                        f_offset:write('\r\n')
                        f_offset:close()
                    end}
-- Scrute aussi le port usb (pour appli pianode_usb)
uart.on("data", "\r",
  function(txt)
        local ok, data = pcall(sjson.decode, txt)
        if ok and data.ACTION then
            local action = mqtt_in_topics[mqtt_base_topic.."ACTION"][data.ACTION]
            if type(action)=='function' then action() end            
        else
            print("execution code : "..txt)
            ok, rep = pcall(loadstring(txt))
            if rep then print(rep) end
        end
end, 0)


-- Messages MQTT sortants sur test
test_period = false
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
