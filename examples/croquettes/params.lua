-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu CROQUETTES
--               avec
--                    - ecran LCD en i2c
--                    - 1 bouton
--                      - grove gesture en i2c
-------------------------------------------------
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    i2c, u8g(avec font ssd1306_128x64_i2c), bit, mqtt, sjson
-------------------------------------------------
local App = {}

do
	App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    --------------------------------------
    -- Modules a charger
    --------------------------------------
    --App.modules={"i2c_lcd"}
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
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-CROQ",
        base_topic = "T-HOME/CROQ/"
    }
	--------------------------------------
	-- HARDWARE
	--------------------------------------

	-- display et grove gesture en i2c
	local pin_sda = 5 
	local pin_scl = 6 
	i2c.setup(0, pin_sda, pin_scl, i2c.SLOW)
	
	-- Grove Gesture
	local G = require("paj7620")
	G.init()
    G.init=nil
	local GEST_TOPIC = App.mqtt.base_topic.."GESTE"
	G.scan(function(c)
			App.mqtt_publish(c,GEST_TOPIC)
		end)
	
	-- LCD
	local lcd = _dofile("i2c_lcd")
	
	
	-- Button
	local pin_bt = 1

    -- When mqtt connected : send INIT
    App.mqtt.connected_callback = function()
                            App.mqtt_publish("INIT",App.mqtt.base_topic.."INIT")
                        end
	----------------------------------------
	-- Messages sur trigger GPIO
	----------------------------------------
	App.mqtt_trig_topics = {}
	App.mqtt_trig_topics[App.mqtt.base_topic.."BT"]={
					pin = pin_bt,
					pullup = true,
					type = "down", -- or "down", "both", "low", "high"
					qos = 0, retain = 0, callback = nil,
					message = function()
							return gpio.read(pin_bt)
						end
					}  
	----------------------------------------
	--Gestion du display : mqtt(json)=>affichage
	----------------------------------------
	App.mqtt_in_topics = {}
	App.mqtt_in_topics[App.mqtt.base_topic.."DISPLAY"]=function(data)
					lcd.disp_add_data(data)
				end
end
return App
