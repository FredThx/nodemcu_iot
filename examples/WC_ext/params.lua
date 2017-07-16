-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               WC_ext pour affichage état WC
--                      - des leds
-------------------------------------------------
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------
LEDS_AIR = {1,2,3,4,5}
LED_LIBRE = 6
LED_OCCUPE = 7

for k, pin in pairs(LEDS_AIR) do 
        gpio.mode(pin, gpio.OUTPUT)
        gpio.write(pin,gpio.LOW)
    end
gpio.mode(LED_LIBRE, gpio.OUTPUT)
gpio.mode(LED_OCCUPE, gpio.OUTPUT)
gpio.write(LED_LIBRE,gpio.LOW)
gpio.write(LED_OCCUPE,gpio.LOW)

--------------------------------------
-- Modules a charger
--------------------------------------
modules={}
--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME2",'WIFI_THOME1'}
PASSWORD = "plus33324333562"
HOST = "NODE-WC_EXT"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/WC_EXT/"
----------------------------------------
-- Messages MQTT sortants
----------------------------------------
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

-- Messages MQTT sortants sur test 
test_period = 500
mqtt_test_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}

----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

-- Quelles les sont allumées seront entrée?
matrice = {
    ["0"]={1,0,0,0,0},
    ["1"]={0,1,0,0,0},
    ["2"]={0,0,1,0,0},
    ["3"]={0,0,1,1,0},
    ["4"]={0,0,1,1,1}}

mqtt_in_topics[mqtt_base_topic.."AIR"]=
            function(data)
                for k, level in pairs(matrice[data]) do
                        gpio.write(LEDS_AIR[k],level)
                    end
            end

mqtt_in_topics[mqtt_base_topic.."ETAT"]={
            ["LIBRE"] = function()
                        gpio.write(LED_LIBRE, gpio.HIGH)
                        gpio.write(LED_OCCUPE, gpio.LOW)
                    end,
            ["OCCUPE"] = function()
                        gpio.write(LED_LIBRE, gpio.LOW)
                        gpio.write(LED_OCCUPE, gpio.HIGH)
                    end}
