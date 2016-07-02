-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - sonde humidité terre
--                    - sonde humidité air
--                    - sonde pluie
--                    - sonde luminosité
--                    - sonde température
-- TODO : tester ajout un relay pour piloter pompe
-------------------------------------------------

LOGGER = false

-- Module MCP3008 pour entree analogiques
mcp = _dofile("mcp3008")
mcp.init(7,6,8,5)
-- Capteur DTH11-22
DTH_pin = 4
-- Capteur température DSx20
DS1820_PIN = 3
sensors = { 
    [string.char(40,255,213,74,1,21,4,230)] = "piscine"
}
-- Relay pompe
POMPE_PIN = 2

------------------------------
-- Modules a charger
------------------------------
modules={"DTH_reader","ds1820_reader"}
------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-EXTERIEUR"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/EXTERIEUR/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."humidite_terre"]={
                message = function()
                        return (1023 - mcp.read(0))/1023
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
mqtt_out_topics[mqtt_base_topic.."luminosite"]={
                message = function()
                        return mcp.read(1)
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
mqtt_out_topics[mqtt_base_topic.."pluie"]={
                message = function()
                        return (1023-mcp.read(2))/1023
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        t,h=readDht()    
                        return t
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
mqtt_out_topics[mqtt_base_topic.."humidite"]={
                message = function()
                        t,h=readDht()
                        return h
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
mqtt_out_topics["T-HOME/PISCINE/temperature"]={
                message = function()
                        t = readDSSensors("piscine")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}
               
-- Messages sur trigger GPIO
mqtt_trig_topics = {}                
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics["T-HOME/PISCINE/pompe"]={
            ["ON"]=function()
                        print("POMPE ON")
                        gpio.write(POMPE_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("POMPE OFF")
                        gpio.write(POMPE_PIN, gpio.LOW)
                    end}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
