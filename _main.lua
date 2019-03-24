-- projet Standart NodeMCU & MQTT
-- Lecture des parametres propres du projets
-- Liste des timers
App.mqtt_in_topics = App.mqtt_in_topics or {}

-- Debug

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
    local timeout = App.watchdog.timeout or 3600
    local topic = App.mqtt.base_topic.."_WATCHDOG"
        ["INIT"]=function()
                tmr.softwd(timeout)
            end}
    tmr.create():alarm(timeout*100, tmr.ALARM_AUTO, function() -- dix fois plus souvent que timeout
        App.mqtt_publish("INIT", topic)
    end)
    print_log("Mqtt watchdog created.")
end

_dofile("add_reverse_topics")

if App.modules then
    for key, reader in pairs(App.modules or {}) do
        print_log("Load " .. reader)
        _dofile(reader)
    end
end

-- Fonction de publication des données (via mqtt et usb sérial)
function App.mqtt_publish(rep,topic,action)
            if type(rep)=="table" then rep = sjson.encode(rep) end
			print_log("publish ".. topic.. "=>" ..rep)
			if App.mqtt.connected then
				if App.mqtt.client:publish(topic,rep,
									action.qos or 0,
									action.retain or 0,
									action.callback) then
					print_log("MQTT send : ok")
					print_log("MQTT not send : mqtt error")
                    App.mqtt.connected = false
                    App.mqtt_connect()
				collectgarbage()
			end

-- 	Creation du timer pour lecture et envoie des App.mqtt_out_topics
if App.mesure_period then
	tmr.create():alarm(App.mesure_period, tmr.ALARM_AUTO, function ()
			_dofile("read_and_send")
			if App.logger then
				check_logfile_size()
			end
		end)
end

-- 	Creation du timer pour lecture et envoie des App.mqtt_test_topics
if App.test_period then
		end)

-- Création des triggers GPIO
_dofile("init_trig")
-- Connection WIFI
    if TELNET then
        _dofile("telnet")
    end
    _dofile("init_mqtt")
end

_dofile("wifi")

