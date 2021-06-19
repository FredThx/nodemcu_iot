-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                  - capteur de luminosité sur A0
--                  - Capteur BMP180 (pression atm + température
--                  - Emetteur FR pour piloter prises
--                  - Display oled en i2c
--                  - Leds
--                  - détecteur de mouvement IR
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, i2c, u8g(avec font ssd1306_128x64_i2c), sjson, adc, bmp085
-------------------------------------------------
local App = {}
do

    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    
    
    
    -- prises Radio frequence 433Mhz
    PIN_433 = 3
    groupePrises = "00010"
    priseA = "10000"

    --Port i2c : capteur BMP180 & display
    pin_sda = 5
    pin_scl = 6
    disp_sla = 0x3c
    i2c.setup(0,pin_sda, pin_scl, i2c.SLOW)
    bmp085.setup()

    -- AUTREs
    IRD_PIN = 4
    GREEN_LED_PIN = 7
    gpio.mode(GREEN_LED_PIN, gpio.OUTPUT)
    gpio.write(GREEN_LED_PIN, gpio.LOW)
    ------------------------------
    -- Modules a charger
    ------------------------------
    -- TODO : ne plus utiliser cette technique!!!
    
    App.modules={ --"ds1820_reader.lua","DTH_reader.lua",
        --"BMP_reader",
        "433_switch",
        "i2c_display"
        }

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
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-SALON",
        base_topic = "T-HOME/SALON/"
    }


    -- Messages MQTT sortants
    App.mesure_period = 10*60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                    message = function()
                            return bmp085.temperature()/10
                        end,
                    qos = 0, retain = 0, callback = nil}
    App.mqtt_out_topics[App.mqtt.base_topic.."pression"]={
                    message = function()
                            return bmp085.pressure()/100
                        end,
                    qos = 0, retain = 0, callback = nil}
    App.mqtt_out_topics[App.mqtt.base_topic.."luminosite"]={
                    message = function()
                            return adc.read(0)
                        end,
                    qos = 0, retain = 0, callback = nil}
    -- Messages sur trigger GPIO
    App.mqtt_trig_topics = {}
    App.mqtt_trig_topics[App.mqtt.base_topic.."CAPTEUR_IR"]={
                    pin = IRD_PIN,
                    type = "up",
                    qos = 0, retain = 0, callback = nil}

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."433"]=function(data)
                    print("Envoi via 433 : ", data)
                    transmit433(data)
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."green_led"]={
                ["ON"]=function()
                            gpio.write(GREEN_LED_PIN,gpio.HIGH)
                        end,
                ["OFF"]=function()
                            gpio.write(GREEN_LED_PIN,gpio.LOW)
                        end,
                ["BLINK"]=function()
                            gpio.write(GREEN_LED_PIN,gpio.HIGH)
                            tmr.create():alarm(500,tmr.ALARM_SINGLE, function()
                                    gpio.write(GREEN_LED_PIN,gpio.LOW)
                                end)
                        end}
    -- Messages MQTT sortants sur test
    App.test_period = 1000
    App.mqtt_test_topics = {}

    --Gestion du display : mqtt(json)=>affichage
    disp_texts = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."DISPLAY"]=function(data)
                    disp_add_data(data)
                end
end
return App
