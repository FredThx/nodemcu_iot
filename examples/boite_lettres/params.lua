-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               BOITE AU LETTRES
--               avec
--					- detecteur de mvt
--                  - bouton de RAZ
--                  - LED
-------------------------------------------------

local App = {}

do
	App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

	-- Hardware

	IRD_PIN = 3
	LED_PIN = 1
	BT_PIN = 2
	PRT_PIN = 5

	gpio.mode(LED_PIN, gpio.OUTPUT)
	
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
		client_name = "NODE-BAL",
		base_topic = "T-HOME/BAL/"
	}
	
	App.mqtt.connected_callback = function()
							print("La connexion MQTT est ok.")
						end

	----------------------------------------
	-- Messages sur trigger GPIO
	----------------------------------------
	App.mqtt_trig_topics = {}
	App.mqtt_trig_topics[mqtt_base_topic.."CAPTEUR_IR"]={
					pin = IRD_PIN,
					pullup = false,
					type = "up", -- or "down", "both", "low", "high"
					qos = 0, retain = 0, callback = nil}
	App.mqtt_trig_topics[mqtt_base_topic.."BOUTON"]={
					pin = BT_PIN,
					pullup = true,
					type = "down", -- or "down", "both", "low", "high"
					qos = 0, retain = 0, callback = nil}
	App.mqtt_trig_topics[mqtt_base_topic.."PORTE"]={
					pin = PRT_PIN,
					pullup = true,
					type = "up", -- or "down", "both", "low", "high"
					qos = 0, retain = 0, callback = nil}
	----------------------------------------
	-- Actions sur messages MQTT entrants
	----------------------------------------
	App.mqtt_in_topics = {}
	--Soit avec une fonction par valeur du message
	App.mqtt_in_topics[mqtt_base_topic.."LED"]={
				["ON"]=function()
							gpio.write(LED_PIN,gpio.HIGH)
						end,
				["OFF"]=function()
							gpio.write(LED_PIN,gpio.LOW)
						end}
end

return App