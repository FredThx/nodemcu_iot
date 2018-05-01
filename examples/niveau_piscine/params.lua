-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--            - VL6160X Time-of-Flight Distance Sensor Carrier
--              pour niveau d'eau piscine
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, i2c
-------------------------------------------------
LOGGER = false
WATCHDOG = true
WATCHDOG_TIMEOUT = 30*60 -- 30 minutes
MSG_DEBUG = true -- if true : send messages (ex : "MQTT send : ok")
WEB_SERVEUR = true

-- Capteur Niveau d'eau
capteur = require 'vl6180x'
capteur.init(5,6,0x29)
capteur.init=nil --free memory

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-NIVEAU-PISCINE"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/PISCINE/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."NIVEAU"]={
                message = function()
                        local niveaux = {}
                        local min_key = 1
                        local max_key = 1
                        for i = 1,10 do
                            table.insert(niveaux,capteur.distance())
                            if niveaux[i] > niveaux[max_key] then max_key = i end
                            if niveaux[i] < niveaux[min_key] then min_key = i end    
                        end
                        table.remove(niveaux,min_key)
                        table.remove(niveaux,max_key)
                        local result = 0
                        for k, niveau in pairs(niveaux) do
                            result = result + niveau
                        end
                        return math.floor(result / 8 + 0.5)
                    end}
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}     
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}                        
--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
