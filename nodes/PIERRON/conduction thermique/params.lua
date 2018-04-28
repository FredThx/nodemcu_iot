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
mcp9804 = _dofile('mcp9804')
mcp9804.init(1,2)
------------------------------
-- Modules a charger
------------------------------
modules={}

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
                        t["T1"]=mcp9804.read(0x48)
                        t["T2"]=mcp9804.read(0x49)
                        t["T3"]=mcp9804.read(0x4A)
                        t["T4"]=mcp9804.read(0x4B)
                        t["T5"]=mcp9804.read(0x4C)
                        t["T6"]=mcp9804.read(0x4D)
                        t["T7"]=mcp9804.read(0x4E)
                        return t -- return 0 at 0V and 1 at 2V
                    end,
                usb = true,
                qos = 0, retain = 0, callback = nil}

-- Messages sur trigger GPIO
mqtt_trig_topics = {}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
                    
-- Messages MQTT sortants sur test
test_period = false
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
