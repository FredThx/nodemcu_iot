-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres module pilotage vmc Salle de bain
--               avec
--              - 1 relais pour pilotage moteur VMC
--              - 1 DHT11 pour mesure température et humidité
--              - 1 photorésustance pour détection allumage lumière
--
-------------------------------------------------
--  Wiring
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, dht, adc
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = false -- if true : send messages (ex : "MQTT send : ok")

    -- Relais 
    pin_rel = 1
    -- dht11
    pin_dht = 2
    -- photoresistance
    if adc.force_init_mode(adc.INIT_ADC) then
        node.restart()
    end
    seuil_luminosite = 50

    -- Initialisation
    gpio.mode(pin_rel, gpio.OUTPUT)
    gpio.write(pin_rel, gpio.LOW)

    ------------------
    -- Params WIFI 
    ------------------
    App.net = {
            ssid = {"WIFI_THOME1",'WIFI_THOME2'},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = "192.168.10.155",
        port = 1883,
        client_name = "NODE-SDBE-VMC",
        base_topic = "T-HOME/SDBE/VMC/"
    }
    
    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000 * 10
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                message = function()
                        local status,temp,humi = dht.read(pin_dht)
                        if status == dht.OK then
                            return temp
                        end
                    end}
    App.mqtt_out_topics[App.mqtt.base_topic.."humidite"]={
                message = function()
                        local status,temp,humi = dht.read(pin_dht)
                        if status == dht.OK then
                            return humi
                        end
                    end}
    App.mqtt_out_topics[App.mqtt.base_topic.."luminosite"]={
                message = function()
                        return adc.read(0)
                    end,
                manual = true}
    -- actions sur test
    App.mqtt_out_topics[App.mqtt.base_topic.."lumiere"]={
                message = function()
                        if adc.read(0) > seuil_luminosite then
                            return "ON"
                        else
                            return "OFF"
                        end
                    end,
                manual = true,
                on_change = true}    
    -- Test luminosité
    App.test_period = 1000
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}    
    alarm_fil_pilote = tmr.create()
    App.mqtt_in_topics[App.mqtt.base_topic.."VMC"] = {
            ["ON"]=function()
                        print_log("RELAIS ON")
                        gpio.write(pin_rel, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print_log("RELAIS OFF")
                        gpio.write(pin_rel, gpio.LOW)
                    end}
end
return App
