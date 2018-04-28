-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               WC pour gestion de la qualité de l'air
--                      - un capteur MQ-2   sur A0 de MCP3008
--                      - un capteur MQ-5   sur A1 de MCP3008
--                      - un capteur MQ-7   sur A2 de MCP3008
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- Capteur température DSx20
--DS1820_PIN = 4 
--sensors = { }

-- display en i2c
--disp_sda = 5 
--disp_scl = 6 
--disp_sla = 0x3c

-- AUTREs

-- Module MCP3008 pour entree analogiques
mcp = _dofile("mcp3008")
mcp.init(7,6,8,5) -- miso, mosi, clk, cs

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
--        "ds1820_reader",
--        "DTH_reader",
--        "BMP_reader",
--        "433_switch",
--        "i2c_display"
}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-WC"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/WC/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."MQ-7"]={
                message = function()
                        return mcp.read(0)/1023*100
                    end,
                qos = 0, retain = 0, callback = nil,
                manual = false}
mqtt_out_topics[mqtt_base_topic.."MQ-5"]={
                message = function()
                        return mcp.read(1)/1023*100
                    end,
                qos = 0, retain = 0, callback = nil,
                manual = false}
mqtt_out_topics[mqtt_base_topic.."MQ-2"]={
                message = function()
                        return mcp.read(2)/1023*100
                    end,
                qos = 0, retain = 0, callback = nil,
                manual = false}                
-- Messages MQTT sortants sur test 
test_period = 1000
mqtt_test_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}


----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
            
