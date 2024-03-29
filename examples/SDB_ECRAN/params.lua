-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour Ecran TFT TOUCH SCREEN
--               avec
--              - 1 écran TFT 2.4 Touch Shield Wemos
--
-------------------------------------------------
--  Wiring : voir tft_24_ts.lua
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, sjson, spi, ucg (with ili9341_18x240x320_hw_spi), xpt2046
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- ECRAN
    tft_ts = require 'tft_24_ts'
    tft_ts.init(0,8,3,1,4,nil,90) -- default pins : cs=0, dc=8, cs=3, irq=1, led = 4
    tft_ts.init = nil --freememory

    -- THERMOMETRE
    thermometer = require 'ds1820_reader'
    thermometer.init(2) -- pin D2
    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {"WIFI_THOME1",'WIFI_THOME2',"WIFI_THOME3"},
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
        client_name = "NODE-SDB-ECRAN",
        base_topic = "T-HOME/SDB/ECRAN/"
    }

    -- Messages MQTT sortants
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                message = function()
                        thermometer.read(nil, function(temp)
                                App.mqtt_publish(temp, App.mqtt.base_topic.."temperature")
                            end)
                    end}

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."ADD_BUTTON"] =
                function(data)
                    --pcall(function()
                                local button = sjson.decode(data)
                                button.callback = function()
                                        App.mqtt_publish(button.button, App.mqtt.base_topic.."PRESSED")
                                    end
                                tft_ts.add_button(button)
                    --       end)
                end

    App.mqtt_in_topics[App.mqtt.base_topic.."ADD_LABEL"] =
                function(data)
                    local label = sjson.decode(data)
                    tft_ts.add_label(label)
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."SET_LABEL"] =
                function(data)
                    local var = sjson.decode(data)
                    tft_ts.set_label(var.variable, var.text)
                end

    App.mqtt_in_topics[App.mqtt.base_topic.."CMD"] = {
            ["RAZ"]=function()
                        tft_ts.disp:clearScreen()
                        tft_ts.buttons={}
                    end,
            }


end
return App
