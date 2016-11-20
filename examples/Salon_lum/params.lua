-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - ........
-------------------------------------------------

LOGGER = false

------------------------------
-- Modules a charger
------------------------------
modules={}

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-SALON-LUM"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/SALON-LUM/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."luminosite"]={             
                message = function()
                        local lum = adc.read(0)
                        return lum
                    end,
                qos = 0, retain = 0, callback = nil}
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}
               
-- Messages sur trigger GPIO
mqtt_trig_topics = {}                
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
