-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu CROQUETTES 3
--               avec
--                  moteur pas à pas
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, cjson | sjson
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- moteur

moteur = require("stepper")
moteur.init({1,2,3,4})

-- bouton

BT_PIN = 5


--------------------------------------
-- Modules a charger
--------------------------------------
modules={}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-CROQ3"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/CROQ3/"
----------------------------------------
-- Messages MQTT sortants
---------------------------------------- 
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

-- Messages MQTT sortants sur test
test_period = nil
test_init = false
mqtt_test_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}
mqtt_trig_topics[mqtt_base_topic.."BT"]={
                pin = BT_PIN,
                pullup = true,
                type = "down", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = function()
                        print("Bt pushed")
                        --mqtt_in_topics[mqtt_base_topic.."RELAIS"]["CHANGE"]()
                        -- TODO : régler problème de déclenchement intempestif quand relais activé via WIFI
                        return 1
                    end
                }  
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

mqtt_in_topics[mqtt_base_topic.."MOTEUR"] = function(data)
                        local data = cjson.decode(data)
                        moteur.rotate(
                                data.sens or moteur.FORWARD,
                                data.pas or 1 , 
                                data.interval or 1,
                                6,
                                function () 
                                    mqtt_client:publish(
                                        mqtt_base_topic.."MOTEUR_DONE",
                                        1,
                                        0,0) 
                                end)
                    end

----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
            
