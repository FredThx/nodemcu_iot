-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu CROQUETTES
--               avec
--                    - ecran LCD en i2c
--                    - 3 boutons
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- display en i2c
disp_sda = 5 
disp_scl = 6 
--disp_sla = 0x3c

-- AUTREs
PIN_BT1 = 1
PIN_BT2 = 2
PIN_BT3 = 3

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
--        "ds1820_reader",
--        "DTH_reader",
--        "BMP_reader",
--        "433_switch",
        "i2c_lcd"}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-CROQ"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
----------------------------------------
-- Messages MQTT sortants
---------------------------------------- 
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

-- Messages MQTT sortants sur test
test_period = 1000
test_init = false
mqtt_test_topics = {}
mqtt_test_topics["T-HOME/CROQ/INIT"]={{
                test = function()
                        if test_init then
                            return false
                        else
                            test_init = true
                            return true
                        end
                    end,
                value = "INIT",
                mqtt_repeat = false,
                qos = 0, retain = 0, callback = nil}}
----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}
mqtt_trig_topics["T-HOME/CROQ/BT1"]={
                pin = PIN_BT1,
                type = "_down", -- or "down", "both", "low", "high"
                pullup = true,
                qos = 0, retain = 0, callback = nil}
mqtt_trig_topics["T-HOME/CROQ/BT2"]={
                pin = PIN_BT2,
                type = "_down", -- or "down", "both", "low", "high"
                pullup = true,
                qos = 0, retain = 0, callback = nil}
mqtt_trig_topics["T-HOME/CROQ/BT3"]={
                pin = PIN_BT3,
                type = "_down", -- or "down", "both", "low", "high"
                pullup = true,
                qos = 0, retain = 0, callback = nil}

----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
mqtt_in_topics["T-HOME/CROQ/DISPLAY"]=function(data)
                disp_add_data(data)
            end
            
