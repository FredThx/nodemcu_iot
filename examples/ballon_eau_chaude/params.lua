-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - entrée impulsion compteur débit d'eau
--                          1 litre = 1 changement d'état
--                    - sonde température du tuyau cuivre
--                    - une LED
-------------------------------------------------

local App = {}

do
	App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

	-- HARDWARE	

	-- Capteur température DSx20
	DS1820_PIN = 3
	thermometres = require("ds1820_reader")
	thermometres.init(DS1820_PIN)
	--sensors = {[string.char(40,255,182,97,80,20,0,40)] = "ballon"}
		
	-- Entree débimetre
	INPUT_PIN = 7
	-- LED pour renvoie information CONSO enregistree
	LED_PIN = 1

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
		client_name = "NODE-BALLON",
		base_topic = "T-HOME/BALLON/"
	}
	
	-- Messages MQTT sortants
	App.mesure_period = 10*60 * 1000
	App.mqtt_out_topics = {}
	App.mqtt_out_topics[mqtt_base_topic .. "temperature"]={
						result_on_callback = function(callback)
								thermometres.read(nil,callback)
							end,
						qos = 0, retain = 0, callback = nil}

	-- Messages sur trigger GPIO
	App.mqtt_trig_topics = {}                
	App.mqtt_trig_topics[mqtt_base_topic.."CONSO"]={
					pin = INPUT_PIN,
					pullup = false,
					type = "both", -- or "down", "both", "low", "high"
					qos = 0, retain = 0, callback = nil,
					message = 1}
	-- Actions sur messages MQTT entrants
	App.mqtt_in_topics = {}
	App.mqtt_in_topics[mqtt_base_topic.."LED"]={
				["ON"]=function()
							gpio.write(LED_PIN,gpio.HIGH)
						end,
				["OFF"]=function()
							gpio.write(LED_PIN,gpio.LOW)
						end,
				["BLINK"]=function()
							gpio.write(LED_PIN,gpio.HIGH)
							tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
									gpio.write(LED_PIN,gpio.LOW)
								end)
						end}
end

return App