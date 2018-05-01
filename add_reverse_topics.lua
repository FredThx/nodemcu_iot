--Ajout les topics MQTT de demande de mesure
-- exemple /T-HOME/TEST/temperature est le topic dans lequel est envoyé toutes les x minutes
--         /T-HOME/TEST/temperature_ est le topic de demande de la température (valeur = "SENDIT")

for topic in pairs(App.mqtt_out_topics) do
    if App.mqtt_out_topics[topic]["message"] then
        App.mqtt_in_topics[topic.."_"]={["SENDIT"]=function()
				--TODO : fonctionnariser ça avec read_and_send (gain qques ko)
				local no_err, rep
				if type(App.mqtt_out_topics[topic]["message"])=="function" then
					no_err, rep = pcall(App.mqtt_out_topics[topic]["message"])
				else
					no_err = true
					rep = App.mqtt_out_topics[topic]["message"]
				end
                if no_err and rep then
                    App.mqtt_publish(rep, topic,App.mqtt_out_topics[topic])
                else
                    print_log("MQTT not send.")
                end
            end}
        print_log("Reverse topic "..topic.."_".." created.")
    end
    if App.mqtt_out_topics[topic]["result_on_callback"] then
        App.mqtt_in_topics[topic.."_"]={["SENDIT"]=function()
                pcall(App.mqtt_out_topics[topic]["result_on_callback"], function(rep)
                            App.mqtt_publish(rep, topic ,App.mqtt_out_topics[topic])
                        end)
                 end}
		print_log("Reverse topic "..topic.."_".." created.")
	 end
     
    -- Add deamons on_change
    if App.mqtt_out_topics[topic]["on_change"] then
        App.mqtt_out_topics[topic]["on_change_value"]=nil
        App.mqtt_test_topics[topic]={{
                test = function()
                            local no_err, value = pcall(App.mqtt_out_topics[topic].message)
                            if no_err and value ~= App.mqtt_out_topics[topic].on_change_value then
                                App.mqtt_out_topics[topic].on_change_value = value
                                return true
                            else
                                return false
                            end
                        end,
                    value = function()
                                local no_err, value = pcall(App.mqtt_out_topics[topic].message)
                                if no_err then
                                    return value
                                end
                        end,
                    mqtt_repeat = false,
                    qos = 0, retain = 0, callback = nil}}
        print_log("Test topic "..topic.."_".." created.")
     end
end

-- deamons systems : 
if App.mqtt.base_topic then
	-- pour executer du code via MQTT
    App.mqtt_in_topics[App.mqtt.base_topic.."_LUA"]= function(data)
                   node.input(data)
                end
	-- pour tester si vivant
	App.mqtt_in_topics[App.mqtt.base_topic.."_HELLO"]= function(data)
				App.mqtt_publish(App.mqtt.client_name, App.mqtt.base_topic.."HELLO")
			end
end

print_log('reverse mqtt topics : ok')

-- Modification App.mqtt_test_topic si pas table de table
for topic, tests in pairs(App.mqtt_test_topics) do
	if type(tests[1]) ~= 'table' then
		App.mqtt_test_topics[topic] = {tests}
	end
end
