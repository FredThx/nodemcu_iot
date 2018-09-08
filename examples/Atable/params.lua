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
	--App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
	App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
	

	-- Hardware


    pin_bt = 5
    pin_moteur = 2
    pin_led = 3
    pin_buzzer = 1
    
    gpio.mode(pin_moteur,gpio.OUTPUT)
    gpio.mode(pin_led,gpio.OUTPUT)
    gpio.mode(pin_buzzer,gpio.OUTPUT)
    gpio.write(pin_moteur,gpio.LOW)
    gpio.write(pin_led,gpio.LOW)
    gpio.write(pin_buzzer,gpio.LOW)
	
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
		client_name = "NODE-ATABLE",
		base_topic = "T-HOME/ATABLE/"
	}
 
	-- Actions sur messages MQTT entrants
	App.mqtt_in_topics = {}    
	App.mqtt_in_topics[App.mqtt.base_topic.."MOTEUR"] = {
            ["ON"]=function()
                        print("MOTEUR ON")
                        gpio.write(pin_moteur, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("MOTEUR OFF")
                        gpio.write(pin_moteur, gpio.LOW)
                    end}
    App.mqtt_in_topics[App.mqtt.base_topic.."BUZZER"]={
            ["ON"]=function()
                        print("BUZZER ON")
                        gpio.write(pin_buzzer, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("BUZZER OFF")
                        tmr.stop(0)
                        pwm.stop(pin_buzzer)
                        gpio.write(pin_buzzer, gpio.LOW)
                    end,
             ["WAVE"]=function()
                           print("BUZZER WAVE")
                           buzzer_freq = 300
                           pwm.setup(pin_buzzer,buzzer_freq,200)
                           pwm.start(pin_buzzer)
                           tmr.alarm(0,100,tmr.ALARM_AUTO, function()
                                pwm.setclock(pin_buzzer,buzzer_freq)
                                buzzer_freq = buzzer_freq + 20
                                if buzzer_freq > 500 then buzzer_freq = 300 end
                                end)
                        end
                    }
end

return App
