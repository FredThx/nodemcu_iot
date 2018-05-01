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

	--nada

	------------------
	-- Params WIFI 
	------------------
	App.net = {
			ssid = {"WIFI_THOME1",'WIFI_THOME2'},
			password = "plus33324333562",
			wifi_time_retry = 10, -- minutes
			}
	--HOST = "NODE-TEST"

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
	-- Messages MQTT sortants
	mesure_period = 10*60 * 1000
	mqtt_out_topics = {}
	mqtt_out_topics[App.mqtt.base_topic.."42"]={
					message = function()
							print("Envoie de 42!")
							return 42
						end}
	mqtt_out_topics[App.mqtt.base_topic.."8"]={
					message = 8}
	-- Messages MQTT sortants sur test
	test_period = 1000
	mqtt_test_topics = {}
	-- Messages sur trigger GPIO
	mqtt_trig_topics = {}     
	-- Actions sur messages MQTT entrants
	mqtt_in_topics = {}                        
	--Gestion du display : mqtt(json)=>affichage
	disp_texts = {}
end

return App