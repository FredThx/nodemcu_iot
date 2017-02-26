-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--					- capteurs de température DS18b20
--						- ambiance Salon
--					- display
--					- led
--					- prise RF
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, , i2c, u8g(avec font ssd1306_128x64_i2c), cjson, ow
-------------------------------------------------

LOGGER = false
WATCHDOG = true
TELNET = false

LED_PIN = 8
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- Capteur température DSx20
DS1820_PIN = 4 
sensors = { 
    [string.char(16,202,160,164,2,8,0,6)] = "salon"
}

-- prises Radio frequence 433Mhz
PIN_433 = 3
groupePrises = "00010"
priseA = "10000"

-- display en i2c
pin_sda = 5 
pin_scl = 6 
disp_sla = 0x3c
--------------------------------------
-- Modules a charger
--------------------------------------
modules={
	"ds1820_reader",
	"433_switch",
    "i2c_display"
	}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = "WIFI_THOME"
PASSWORD = "plus33324333562"
HOST = "NODE-EPINAL-SALON"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
--mqtt_host = "31.29.97.206"
mqtt_host = "192.168.0.16"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-EPINAL/SALON/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 10*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."temperature"]={
                message = function()
                        t = readDSSensors("salon")
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
mqtt_in_topics[mqtt_base_topic.."433"]=function(data)
                print("Envoi via 433 : ", data)
                transmit433(data)
            end
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
disp_texts = {}
mqtt_in_topics[mqtt_base_topic.."DISPLAY"]=function(data)
                disp_add_data(data)
            end
