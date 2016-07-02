-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - entrée impulsion compteur débit d'eau
--                          1 litre = 1 changement d'état
--                    - sonde température du tuyau cuivre
--                    - une LED
-------------------------------------------------

LOGGER = false

-- Capteur température DSx20
DS1820_PIN = 3
sensors = { 
    [string.char(40,255,182,97,80,20,0,40)] = "ballon"
}
-- Entree débimetre
INPUT_PIN = 7
-- LED pour renvoie information CONSO enregistree
LED_PIN = 1

------------------------------
-- Modules a charger
------------------------------
modules={"ds1820_reader"}
------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1",'WIFI_THOME2'}
PASSWORD = "plus33324333562"
HOST = "NODE-BALLON"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/BALLON/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic .. "temperature"]={
                message = function()
                        t = readDSSensors("ballon")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}
               
-- Messages sur trigger GPIO
mqtt_trig_topics = {}                
mqtt_trig_topics[mqtt_base_topic.."CONSO"]={
                pin = INPUT_PIN,
                pullup = false,
                type = "both", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = 1}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        gpio.write(LED_PIN,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_PIN,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_PIN,gpio.LOW)
                            end)
                    end}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
