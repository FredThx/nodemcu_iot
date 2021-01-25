-- Initialisation du client MQTT
--
-- Client : App.mqtt.client
--
-- Functions :
--			- on("offline") : reconnecte serveur
--			- on("message") : A la reception des mmessages : execution des App.mqtt_in_topics
-------------------------------------------------------------------------------------------------

-- Creation du client mqtt avec 120s de keepalive
App.mqtt.client = mqtt.Client(App.mqtt.client_name, 120, App.mqtt.user, App.mqtt.pass)
App.mqtt.client:lwt(App.mqtt.base_topic .. "_SYS", "LWT")

-- Deamon quand perte serveur mqtt
App.mqtt.client:on("offline", function(con)
    print_log ("MQTT offline")
    App.mqtt.connected = false
    if App.mqtt.disconnected_callback then
        print_log('mqtt_disconnected_callback call...')
        pcall(App.mqtt.disconnected_callback)
    end
    App.mqtt_connect()
    end)

-- on receive message
App.mqtt.client:on("message", function(conn, topic, data)
    if data == nil then data = "" end
    print_log("Reception MQTT =>" .. topic .. ":" .. data)
    if App.mqtt_in_topics[topic]~= nil then
        if type(App.mqtt_in_topics[topic])=='function' then
            rep = App.mqtt_in_topics[topic](data)
			if rep then App.mqtt_publish(rep,topic.."_") end
        elseif type(App.mqtt_in_topics[topic])=='table' then
            if App.mqtt_in_topics[topic][data]~= nil then
                if type(App.mqtt_in_topics[topic][data])=='function' then
					rep = App.mqtt_in_topics[topic][data]()
				else
					rep = App.mqtt_in_topics[topic][data]
				end
            end
			if rep then App.mqtt_publish(rep,topic.."_",App.mqtt_in_topics[topic]) end
        end
    end
end)

-- when mqtt connect : call App.mqtt.connected_callback
App.mqtt.client:on("connect", function(client)
			end)


-- Connecte (ou reconnecte) le client mqtt
function App.mqtt_connect()
	local mqtt_connect_alarm = tmr.create()
    local on_connection = false
    mqtt_connect_alarm:alarm(1000, 1, function()
            if App.mqtt.connected then
                print_log("MQTT Connected.")
                mqtt_connect_alarm:stop()
            else
                print_log("MQTT Connection...")
                if not on_connection then
                    on_connection = true
                    App.mqtt.client:connect(App.mqtt.host, App.mqtt.port, false,
                        function(conn)
    						App.mqtt.connected = true
    						for topic in pairs(App.mqtt_in_topics) do
    							App.mqtt.client:subscribe(topic,1)
    							print_log(topic .." : subscribed")
    						end
    						if App.mqtt.connected_callback then
    							print_log('mqtt_connected_callback call...')
    							pcall (App.mqtt.connected_callback)
    						end
                            App.mqtt_publish("INIT",App.mqtt.base_topic.."HELLO")
                            if file.open("COMPILE","r") then
                                print("Analyse COMPILE")
                                local txt
                                repeat
                                    txt = file.readline()
                                    print(txt)
                                    if txt~=nil then
                                        App.mqtt_publish(txt,App.mqtt.base_topic.."COMPILE")
                                    end
                                until txt == nil
                                file.close()
                                file.remove('COMPILE')
                            end
                            on_connection = false
    					end,
    					function(conn, reason)
                            print("Error en mqtt connection : ".. reason)
                            on_connection = false
    					end)
                end
            end
        end)
end

-- 1st connexion
App.mqtt_connect()
