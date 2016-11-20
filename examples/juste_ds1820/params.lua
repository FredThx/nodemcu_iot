-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                  - Capteur(s) de température DS18x20
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, ow
-------------------------------------------------

LOGGER = false
TELNET = false

LED_PIN = 3
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = {
    [string.char(40,36,233,44,6,0,0,238)] = "eau",
    [string.char(40,255,14,211,80,20,0,207)] = "ambiance"}

--------------------------------------
-- Modules a charger
--------------------------------------
modules={
        "ds1820_reader"
}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-CHAUDIERE"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/CHAUDIERE/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."EAU"]={
                message = function()
                        t = readDSSensors("eau")
                        return t
                    end,
                qos = 0, retain = 0, callback = nil}
mqtt_out_topics[mqtt_base_topic.."AMBIANCE"]={
                message = function()
                        t = readDSSensors("ambiance")
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
                    end,
            ["BLINK"]=function()
                        gpio.write(GREEN_LED_PIN,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(GREEN_LED_PIN,gpio.LOW)
                            end)
                    end}

