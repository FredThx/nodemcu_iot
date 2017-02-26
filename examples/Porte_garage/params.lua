-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu PORTE GARAGE
--               avec
--                  - 2 capteurs optoptique
--                      - sur mpc3008
--                  - 1 sortie 
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = true

-- MCP3008
mcp = _dofile("mcp3008")
mcp.init() -- default pins
mcp.init = nil -- 952 bytes released

-- AUTREs
POS_CLOSED_MCP_PIN = 1
POS_OPEN_MCP_PIN = 0
LIMIT = 600 -- Limite pour détection optique

MOTOR_PIN = 1
gpio.mode(MOTOR_PIN, gpio.OUTPUT)
------------------------------
-- Modules a charger
------------------------------
modules={}

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-GARAGE"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/GARAGE/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."opto_closed"]={
                message = function()
                        return mcp.read(POS_CLOSED_MCP_PIN)
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
mqtt_out_topics[mqtt_base_topic.."opto_open"]={
                message = function()
                        return mcp.read(POS_OPEN_MCP_PIN)
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
                
mqtt_out_topics[mqtt_base_topic.."etat_porte"]={
                message = function()
                        if mcp.read(POS_CLOSED_MCP_PIN)<LIMIT then
                            if mcp.read(POS_OPEN_MCP_PIN)<LIMIT then
                                return "error"
                            else
                                return "close"
                            end
                        else
                            if mcp.read(POS_OPEN_MCP_PIN)<LIMIT then
                                return "open"
                            else
                                return "on_action"
                            end
                        end
                    end,
                qos = 0, retain = 0, callback = nil, on_change = true}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}

-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."action"]=function(data)
                print("Action porte garage.")
                gpio.write(MOTOR_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(MOTOR_PIN,gpio.LOW)
                            end)
            end
-- Messages MQTT sortants sur test
test_period = 500
--test_etat_porte = false
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}

          
