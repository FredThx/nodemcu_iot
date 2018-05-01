-- projet Standart NodeMCU & MQTT
-- 
-- Base sur ESP8266
--


-- Lecture des parametres propres du projets

App = require("params")

if App.msg_debug == nil then App.msg_debug = true end

print_log("******************************")
print_log("**   " .. App.mqtt.client_name .. "              **")
print_log("******************************")
print_log("")


if App.logger then 
    _dofile("logger")
    node.output(logger,1)
    print_log("----- NODE RESTART -----")
end

if App.watchdog then
    tmr.softwd(App.watchdog.timeout or 3600)
end

_dofile("add_reverse_topics")

for key, reader in pairs(App.modules or {}) do
    print_log("Load " .. reader)
    _dofile(reader)
end

-- Fonction de publication des données (via mqtt et usb sérial)
function mqtt_publish(rep,topic,action)
            if not action then action = {} end
            if type(rep)=="table" then
                rep = sjson.encode(rep)
            end
			print_log("publish ".. topic.. "=>" ..rep)
			if App.mqtt.connected then
				if App.mqtt.client:publish(topic,rep,
									action.qos or 0,
									action.retain or 0,
									action.callback) then
					print_log("MQTT send : ok")
				else
					print_log("MQTT not send : mqtt error")
				end
				--tmr.delay(1000000) Pourquoi ca a ete mis??? Il ne faut pas !!!
				collectgarbage()       
			end
	        if action.usb then
                print(rep)
            end
    end
	
-- 	Creation du timer pour lecture et envoie des App.mqtt_out_topics
if App.mesure_period then
	tmr.create():alarm(App.mesure_period, tmr.ALARM_AUTO, function () -- avant : 4
			_dofile("read_and_send")
			if App.logger then
				check_logfile_size()
			end
		end)
end

-- 	Creation du timer pour lecture et envoie des App.mqtt_test_topics
if App.test_period then
	tmr.create():alarm(App.test_period, tmr.ALARM_AUTO, function() -- avant : 5
			_dofile("test_and_send")
		end)
end						

-- Création des triggers GPIO
_dofile("init_trig")

-- Connection WIFI
function on_wifi_connected()
    if TELNET then
        _dofile("telnet")
    end
    _dofile("init_mqtt")
end

_dofile("wifi")
