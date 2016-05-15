-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--					- ........
-------------------------------------------------

LOGGER = true

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { }

-- Capteur DTH11-22
DTH_pin = 4

-- Capteur BMP180
BMP_SDA_PIN = 1
BMP_SCL_PIN = 2

-- prises Radio frequence 433Mhz
PIN_433 = 1

-- dsiplay en i2c
disp_sda = 5 
disp_scl = 6 
disp_sla = 0x3c

-- AUTREs
FAN_RELAY_PIN = 3
IRD_PIN = 3

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
--        "ds1820_reader",
--        "DTH_reader",
--        "BMP_reader",
--        "433_switch",
        "i2c_display"}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-TEST"
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
---------------------------------------- TODO : mettre des exemples
mesure_period = 1*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics["T-HOME/TEST/temperature"]={
                message = function()
                        print("Envoie de T_HOME/TEST/temperature : 42")
                        return 42
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics["T-HOME/TEST/pression"]={
                message = function()
                        print("Envoie de T_HOME/TEST/pression : 1030")
                        return 1030
                    end,
                qos = 0, retain = 0, callback = nil}

-- Messages MQTT sortants sur test ###NON UTILISE !!!####
test_period = 1000
mqtt_test_topics = {}
mqtt_test_topics["T-HOME/SALON/ALERTE"]={{
                test = function()
                        return false
                    end,
                value = "NEVER",
                mqtt_repeat = false,
                qos = 0, retain = 0, callback = nil},{
                test = function()
                        return true
                    end,
                value = "ALWAYS",
                mqtt_repeat = false,
                qos = 0, retain = 0, callback = nil}}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}
mqtt_trig_topics["T-HOME/TEST/CAPTEUR_IR"]={
                pin = IRD_PIN,
                type = "up", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil}

----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
--Soit avec une fonction par valeur du message
mqtt_in_topics["T-HOME/TEST/ACTION1"]={
            ["ON"]=function()
                        set433Switch("00010","10000",true)
                    end,
            ["OFF"]=function()
                        set433Switch("00010","10000",false)
                    end}
--Soit avec une fonction par topic
mqtt_in_topics["T-HOME/TEST/ACTIONS2"]=function(data)
                print("Envoi via 433 : "..data)
                transmit433(data)
            end
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
mqtt_in_topics["T-HOME/TEST/DISPLAY"]=function(data)
                disp_add_data(data)
            end
            
