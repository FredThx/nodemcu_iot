-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--					- capteurs de température DS18b20
--						- frigo
--						- congélateur
--						- ambiance cuisine
-------------------------------------------------

LOGGER = false


LED_PIN = 3
BUZZER_PIN = 1
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { 
    [string.char(40,255,74,144,81,20,0,250)] = "frigo",
    [string.char(40,255,143,78,80,20,0,181)] = "congelateur",
    [string.char(40,255,50,226,80,20,0,173)] = "cuisine"--,
    --[string.char(40,255,202,79,80,20,0,1)] = "test"
}

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
	"ds1820_reader"--,
	--"DTH_reader",
    --"BMP_reader",
    --"433_switch",
    --"i2c_display"
	}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = "WIFI_THOME2"
PASSWORD = "plus33324333562"
HOST = "NODE-CUISINE"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/CUISINE/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."REFRIGERATEUR/temperature"]={
                message = function()
                        t = readDSSensors("frigo")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."CONGELATEUR/temperature"]={
                message = function()
                        t = readDSSensors("congelateur")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."TEST/temperature"]={
                message = function()
                        t = readDSSensors("test")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        t = readDSSensors("cuisine")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}                
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        gpio.write(LED_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(LED_PIN, gpio.LOW)
                    end}
mqtt_in_topics[mqtt_base_topic.."BUZZER"]={
            ["ON"]=function()
                        gpio.write(BUZZER_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        gpio.write(BUZZER_PIN, gpio.LOW)
                    end}
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
disp_texts = {}
