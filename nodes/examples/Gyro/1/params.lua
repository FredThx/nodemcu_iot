-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--					- Gyroscope
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, i2c, cjson, bit
-------------------------------------------------

LOGGER = false
WATCHDOG = true
TELNET = false

cjson = sjson

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- MPU_6050

mpu6050 = _dofile('mpu6050')
mpu6050.init(7, 6, 1, 1)
mpu6050.init = nil

-- LED
LED_pin = 2
gpio.mode(LED_pin,gpio.OUTPUT)
gpio.write(LED_pin,gpio.LOW)
-- Bouton
BT_pin = 3


--------------------------------------
-- Modules a charger
--------------------------------------
modules={
	}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"FILEUROPE_GYRO"}
PASSWORD = {"vosges433"}
HOST = "NODE-GYRO-1"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "10.3.141.1"
mqtt_port = 1883
mqtt_user = ""
mqtt_pass = ""
mqtt_client_name = HOST
mqtt_base_topic = "FILEUROPE/GYRO/1/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."datas"]={
                message = function()
                        return cjson.encode(mpu6050.read())
                    end,
                qos = 1, retain = 1, callback = nil}
----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}    
mqtt_trig_topics[mqtt_base_topic.."datas"]={
                pin = 1,
                pullup = false,
                type = "up", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = mqtt_out_topics[mqtt_base_topic.."datas"].message}            

mqtt_trig_topics[mqtt_base_topic.."bt"]={
                pin = BT_pin,
                pullup = false,
                type = "both", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = function()
                            return gpio.read(BT_pin)
                        end}            
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."LED"]={
            ["ON"]=function()
                        tmr.stop(6)
                        gpio.write(LED_pin,gpio.HIGH)
                    end,
            ["OFF"]=function()
                        tmr.stop(6)
                        gpio.write(LED_pin,gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(LED_pin,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(LED_pin,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(LED_pin,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(LED_pin,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                        end}
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
disp_texts = {}
