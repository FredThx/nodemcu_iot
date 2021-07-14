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
local App = {}
do

    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    
    --------------------------------------
    -- PARAMETRES CAPTEURS - ACTIONEURS
    --------------------------------------
    LEDS_AIR = {1,2,3,4,5}
    LED_LIBRE = 6
    LED_OCCUPE = 7

    -- Quelles les sont allumées seront entrée?
    matrice = {
        ["0"]={1,0,0,0,0},
        ["1"]={0,1,0,0,0},
        ["2"]={0,0,1,0,0},
        ["3"]={0,0,1,1,0},
        ["4"]={0,0,1,1,1}}

    for k, pin in pairs(LEDS_AIR) do 
            gpio.mode(pin, gpio.OUTPUT)
            gpio.write(pin,gpio.LOW)
        end
    gpio.mode(LED_LIBRE, gpio.OUTPUT)
    gpio.mode(LED_OCCUPE, gpio.OUTPUT)
    gpio.write(LED_LIBRE,gpio.LOW)
    gpio.write(LED_OCCUPE,gpio.LOW)
    
    ------------------------------
    -- Modules a charger
    ------------------------------
    App.modules={}

    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {'WIFI_THOME2'},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }


    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = "192.168.10.155",
        port = 1883,
        --user = "fredthx",
        --pass = "GaZoBu",
        client_name = "NODE-WC_EXT",
        base_topic = "T-HOME/WC_EXT/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 10*60 * 1000
    App.mqtt_out_topics = {}
    -- Messages sur trigger GPIO
    App.mqtt_trig_topics = {}

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."AIR"]=
                function(data)
                    for k, level in pairs(matrice[data]) do
                            gpio.write(LEDS_AIR[k],level)
                        end
                end
    
    App.mqtt_in_topics[App.mqtt.base_topic.."ETAT"]={
                ["LIBRE"] = function()
                            gpio.write(LED_LIBRE, gpio.HIGH)
                            gpio.write(LED_OCCUPE, gpio.LOW)
                        end,
                ["OCCUPE"] = function()
                            gpio.write(LED_LIBRE, gpio.LOW)
                            gpio.write(LED_OCCUPE, gpio.HIGH)
                        end}

end
return App