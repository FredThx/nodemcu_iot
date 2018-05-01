-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu Gestion BAIE
--               avec
--				capteur de température ds18b20
--				relay pour allumer ventillateur
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------

local App = {}

do
	App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
	
	-- HARDWARE
	
	-- Capteur température DSx20
	DS1820_PIN = 4 
	thermometres = require("ds1820_reader")
	thermometres.init(DS1820_PIN)

	-- AUTREs
	FAN_RELAY_PIN = 5
	gpio.mode(FAN_RELAY_PIN,gpio.OUTPUT)
	gpio.write(FAN_RELAY_PIN,gpio.LOW)


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
		client_name = "NODE-BAIE",
		base_topic = "T-HOME/BAIE/"
	}
	
	-- Messages MQTT sortants
	App.mesure_period = 10*60 * 1000
	App.mqtt_out_topics = {}
	App.mqtt_out_topics[mqtt_base_topic.."temperature"]={
					result_on_callback = function(callback)
							thermometres.read(nil,callback)
						end,
					qos = 0, retain = 0, callback = nil}

	-- Actions sur messages MQTT entrants
	App.mqtt_in_topics = {}
	App.mqtt_in_topics[mqtt_base_topic.."fan"]={
				["ON"]=function()
							print("FAN ON")
							gpio.write(FAN_RELAY_PIN, gpio.HIGH)
						end,
				["OFF"]=function()
							print("FAN OFF")
							gpio.write(FAN_RELAY_PIN, gpio.LOW)
						end}
end

return App