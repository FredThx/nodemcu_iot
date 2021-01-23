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

local App = {}

do
    
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
    
    LED_PIN = 8
    gpio.mode(LED_PIN, gpio.OUTPUT)
    gpio.write(LED_PIN, gpio.LOW)
    
    --------------------------------------
    -- PARAMETRES CAPTEURS - ACTIONEURS
    --------------------------------------
    
    -- Capteur température DSx20
    DS1820_PIN = 4 
 --   sensors = { 
 --       [string.char(40,11,234,46,6,0,0,53)] = "salon"
 --   }
        -- THERMOMETRE
    thermometer = require 'ds1820_reader'
    thermometer.init(DS1820_PIN) 
    
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
    App.modules={
    	--"ds1820_reader",
    	"433_switch",
        --"i2c_display"
    	}


    ------------------
    -- Params WIFI 
    ------------------
    App.net = {
            ssid = {"THOME_24"},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = "192.168.0.20",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-SARREG-SALON",
        base_topic = "T-SARREG/SALON/"
    }
    
        
    ----------------------------------------
    -- Messages MQTT sortants
    ----------------------------------------
    App.mesure_period = 10*60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                message = function()
                        thermometer.read(nil, function(temp)
                                App.mqtt_publish(temp, App.mqtt.base_topic.."temperature")
                            end)
                    end}
    ----------------------------------------
    -- Messages sur trigger GPIO
    ----------------------------------------
    App.mqtt_trig_topics = {}                
    ----------------------------------------
    -- Actions sur messages MQTT entrants
    ----------------------------------------
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."LED"]={
                ["ON"]=function()
                            gpio.write(LED_PIN, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            gpio.write(LED_PIN, gpio.LOW)
                        end}
    App.mqtt_in_topics[App.mqtt.base_topic.."433"]=function(data)
                    print("Envoi via 433 : ", data)
                    transmit433(data)
                end
    ----------------------------------------
    --Gestion du display : mqtt(json)=>affichage
    ----------------------------------------
    disp_texts = {}
    --App.mqtt_in_topics[App.mqtt.base_topic.."DISPLAY"]=function(data)
    --                disp_add_data(data)
    --            end
end
return App
