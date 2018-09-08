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
WATCHDOG = true

LED_PIN = 3
BUZZER_PIN = 1
BT_PIN = 7
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)
gpio.mode(BT_PIN, gpio.INPUT)

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- Capteur température DSx20
DS1820_PIN = 4 
thermometres=_dofile("ds1820_reader")
thermometres.init(DS1820_PIN)

sensors = { 
    --[string.char(40,255,74,144,81,20,0,250)] = "frigo",
    --[string.char(40,255,143,78,80,20,0,181)] 
    --[string.char(40,255,158,90,160,22,3,204)]= "congelateur",
    --[string.char(40,255,50,226,80,20,0,173)] = "cuisine"--,
    --[string.char(40,255,202,79,80,20,0,1)] = "test"
    frigo = "28:70:BC:2C:06:00:00:5B",
    congelateur = "28:BE:2E:2D:06:00:00:6C",
    cuisine =  "28:05:85:2E:06:00:00:58"
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
--HOST = "NODE-CUISINE"
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
--mqtt_base_topic = "T-HOME/CUISINE/"
mqtt_base_topic = "T-HOME/TEST/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."REFRIGERATEUR/temperature"]={
                result_on_callback = function(callback)
                        thermometres.read(sensors["frigo"],callback)
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."CONGELATEUR/temperature"]={
                result_on_callback = function(callback)
                        thermometres.read(sensors["congelateur"],callback)
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                result_on_callback = function(callback)
                        thermometres.read(sensors["cuisine"],callback)
                    end,
                qos = 0, retain = 0, callback = nil}
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
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_PIN, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_PIN, gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_PIN,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_PIN,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_PIN,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
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
