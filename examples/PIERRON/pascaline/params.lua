-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour interface PIERRON/Mesura
--               avec
--                  - 1 MCP3201 avec Vref = 3.3V
--                  
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, spi, sjson
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = false
WATCHDOG_TIMEOUT = 30*60 -- 30 minutes
MSG_DEBUG = true -- if true : send messages (ex : "MQTT send : ok")


-- Rotary encoder
rot = _dofile('rotary')
rot.init(0,1,2)
rot.init(1,3,4)
rot.init(2,5,6)

mqtt_connected_callback = function()
        rot.on(0,rot.TURN, function(sens, count)
                mqtt_publish(sens,mqtt_base_topic.."ROT\1")
            end)
        rot.on(1,rot.TURN, function(sens, count)
                mqtt_publish(sens,mqtt_base_topic.."ROT\10")
            end)
        rot.on(2,rot.TURN, function(sens, count)
                mqtt_publish(sens,mqtt_base_topic.."ROT\100")
            end)
    end

-- display en i2c
pin_sda = 8
pin_scl = 7 
disp_sla = 0x3c

------------------------------
-- Modules a charger
------------------------------
modules={"i2c_display"}

------------------
-- Params WIFI 
------------------
--SSID = {"PIERRON"}
--PASSWORD = "Pierr0neducAction57206ruegutenberg"
SSID = "WIFI_THOME2"
PASSWORD = "plus33324333562"
HOST = "PI_NODE_TEST"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
--mqtt_host = "31.29.97.206"
--mqtt_host = "10.10.1.156"
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = nil
mqtt_pass = nil
mqtt_client_name = HOST
mqtt_base_topic = "PIERRON/" .. HOST .. "/"

-- Messages MQTT sortants
mesure_period =  nil
mqtt_out_topics = {}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
					
-- Messages MQTT sortants sur test
test_period = false
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
mqtt_in_topics[mqtt_base_topic.."DISPLAY"]=function(data)
                disp_add_data(data)
            end