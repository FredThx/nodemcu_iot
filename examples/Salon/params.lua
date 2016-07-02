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

LOGGER = true

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { }

-- Capteur DTH11-22
DTH_pin = 4

-- Capteur BMP180
BMP_SDA_PIN = 1
BMP_SCL_PIN = 2

-- prises Radio frequence 433Mhz
PIN_433 = 3
groupePrises = "00010"
priseA = "10000"

-- display en i2c
pin_sda = 5 
pin_scl = 6 
disp_sla = 0x3c

-- AUTREs
IRD_PIN = 4

------------------------------
-- Modules a charger
------------------------------
modules={ --"ds1820_reader.lua","DTH_reader.lua",
    "BMP_reader",
    "433_switch",
    "i2c_display"}

------------------
-- Params WIFI 
------------------
SSID = "WIFI_THOME1"
PASSWORD = "plus33324333562"
HOST = "NODE-SALON"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/SALON/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        return readBMP_temperature()
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."pression"]={
                message = function()
                        return readBMP_pressure()
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."luminosite"]={             
                message = function()
                        local lum = adc.read(0)
                        return lum
                    end,
                qos = 0, retain = 0, callback = nil}
                
-- Messages sur trigger GPIO
mqtt_trig_topics = {}
mqtt_trig_topics[mqtt_base_topic.."CAPTEUR_IR"]={
                pin = IRD_PIN,
                type = "up",
                qos = 0, retain = 0, callback = nil}
                
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."433"]=function(data)
                print("Envoi via 433 : ", data)
                transmit433(data)
            end
--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
mqtt_in_topics[mqtt_base_topic.."DISPLAY"]=function(data)
                disp_add_data(data)
            end
          
