-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                  - capteur de température et humidité DHT11
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, dht
-------------------------------------------------


local App = {}

do
	App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

	-- Capteur DTH11-22
	DHT_pin = 2

	------------------
	-- Params WIFI 
	------------------
	App.net = {
			ssid = {"WIFI_THOME1",'WIFI_THOME2','WIFI_THOME3'},
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
		client_name = "NODE-CAVE",
		base_topic = "T-HOME/CAVE/"
	}

	-- Messages MQTT sortants
	App.mesure_period = 10*60 * 1000
    App.mesure_interval = 1000
	App.mqtt_out_topics = {}
	App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
					message = function()
							local status,temp,humi = dht.read(DHT_pin)
							if status == 0 then
							    return temp
                             end
						end}
	App.mqtt_out_topics[App.mqtt.base_topic.."humidite"]={
					message = function()
							local status,temp,humi = dht.read(DHT_pin)
							if status == 0 then
							    return humi
                            end
						end}
end
return App
