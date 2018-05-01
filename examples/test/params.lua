-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--				uniquement des examples
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------

local App = {}

do
	App.logger = false
	App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
	App.web_server = {} --todo

	-- Hardware

	local my_device = { read = function() return 42 end}
	
	App.modules = {} -- for compatibility with old devices
	
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
		client_name = "NODE-TEST",
		base_topic = "T-HOME/TEST/"
	}
	
	App.mqtt.connected_callback = function()
							print("La connexion MQTT est ok.")
						end
	
	-- Messages MQTT sortants
	App.mesure_period = 10*60 * 1000
	App.mqtt_out_topics = {}
	App.mqtt_out_topics[App.mqtt.base_topic.."42"]={
					message = function()
							print("Lecture de my_device")
							return my_device.read()
						end}
	App.mqtt_out_topics[App.mqtt.base_topic.."8"]={
					message = 8}
	-- Messages MQTT sortants sur test
	App.test_period = 10000
	App.mqtt_test_topics = {}
	App.mqtt_test_topics[App.mqtt.base_topic.."TEST"] = {
			test = function()
					return false or true
                 end,
			value = "Cest vrai",
            usb = true,
			mqtt_repeat = false,
			qos = 0, retain = 0, callback = nil}	
	-- Messages sur trigger GPIO
	App.mqtt_trig_topics = {}     
	App.mqtt_trig_topics[App.mqtt.base_topic.."BT"]={
                pin = 1,
                pullup = true,
                type = "down", -- or "down", "both", "low", "high"
                qos = 0, retain = 0, callback = nil,
                message = function()
                        print("Bt pushed")
                        return "PUSCHED"
                    end
                }     
	-- Actions sur messages MQTT entrants
	App.mqtt_in_topics = {}    
	App.mqtt_in_topics[App.mqtt.base_topic.."IN"]={
            ["42"]="QUARANTE-DEUX",
            ["OFF"]=function()
                        print("OFF")
                    end,
            ["QUI"]=function()
                        return "Cest moi"
                    end,
					qos = 0, retrain = 0, --callback = function() print("Bien envoyé") end
			}
	App.mqtt_in_topics[App.mqtt.base_topic.."IN_F"]= function(data)
														print(data .. "received.")
														return "OK" 
													end
	--Gestion du display : mqtt(json)=>affichage
	App.disp_texts = {}
end

return App
