-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu SERVO
--               avec un servomoteur S1123
--              pour pilotage VMC

-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, pwm
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = true

-- MCP3008
--mcp = _dofile("mcp3008")
--mcp.init() -- default pins
--mcp.init = nil -- 952 bytes released

SERVO = _dofile('servo')
SERVO.init(1)

-- Relay pour piloter petite vitesse (LOW) et grande vitesse (HIGH)
RELAY_PIN = 4
gpio.mode(RELAY_PIN, gpio.OUTPUT)
gpio.write(RELAY_PIN, gpio.LOW)
------------------------------
-- Modules a charger
------------------------------
modules={}

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-VMC"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/VMC/"

-- Messages MQTT sortants
mesure_period = 1*60 * 1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."_WATCHDOG"]={
                message = "INIT",
                qos = 0, retain = 0, callback = nil}
-- Messages sur trigger GPIO
mqtt_trig_topics = {}

-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
mqtt_in_topics[mqtt_base_topic.."WC/angle"]=function(data)
                SERVO.angle(tonumber(data))
            end
mqtt_in_topics[mqtt_base_topic.."WC"]={
            ["ON"]=function()
                        SERVO.angle(90)
                    end,
            ["OFF"]=function()
                        SERVO.angle(0)
                    end}
					
mqtt_in_topics[mqtt_base_topic.."vitesse"]={
            ["HIGH"]=function()
                      print("Vitesse : HIGH.")
                        gpio.write(RELAY_PIN,gpio.HIGH)
                    end,
            ["LOW"]=function()
                        print("Vitesse : LOW.")
                        gpio.write(RELAY_PIN,gpio.LOW)
                    end}
					
-- Messages MQTT sortants sur test
test_period = 500
--test_etat_porte = false
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}

          
