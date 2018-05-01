--Ajout les topics MQTT de demande de mesure
-- exemple /T-HOME/TEST/temperature est le topic dans lequel est envoyé toutes les x minutes
--         /T-HOME/TEST/temperature_ est le topic de demande de la température (valeur = "SENDIT")

for topic in pairs(mqtt_out_topics) do
    if mqtt_out_topics[topic]["message"] then
        mqtt_in_topics[topic.."_"]={["SENDIT"]=function()
				--TODO : fonctionnariser ça avec read_and_send (gain qques ko)
				local no_err, rep
				if type(mqtt_out_topics[topic]["message"])=="function" then
					no_err, rep = pcall(mqtt_out_topics[topic]["message"])
				else
					no_err = true
					rep = mqtt_out_topics[topic]["message"]
				end
                if no_err and rep then
                    mqtt_publish(rep, topic,mqtt_out_topics[topic])
                else
                    print_log("MQTT not send.")
                end
            end}
        print_log("Reverse topic "..topic.."_".." created.")
    end
    if mqtt_out_topics[topic]["result_on_callback"] then
        mqtt_in_topics[topic.."_"]={["SENDIT"]=function()
                pcall(mqtt_out_topics[topic]["result_on_callback"], function(rep)
                            mqtt_publish(rep, topic ,mqtt_out_topics[topic])
                        end)
                 end}
     end
     print_log("Reverse topic "..topic.."_".." created.")
    -- Add deamons on_change
    if mqtt_out_topics[topic]["on_change"] then
        mqtt_out_topics[topic]["on_change_value"]=nil
        mqtt_test_topics[topic]={{
                test = function()
                            local no_err, value = pcall(mqtt_out_topics[topic].message)
                            if no_err and value ~= mqtt_out_topics[topic].on_change_value then
                                mqtt_out_topics[topic].on_change_value = value
                                return true
                            else
                                return false
                            end
                        end,
                    value = function()
                                local no_err, value = pcall(mqtt_out_topics[topic].message)
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
if mqtt_base_topic then
	-- pour executer du code via MQTT
    mqtt_in_topics[mqtt_base_topic.."_LUA"]= function(data)
                   node.input(data)
                end
	-- pour tester si vivant
	mqtt_in_topics[mqtt_base_topic.."_HELLO"]= function(data)
			   mqtt_client:publish(
					mqtt_base_topic.."HELLO",
					mqtt_client_name,
					0,
					0)
			end
end

-- watchdog
if WATCHDOG then
    mqtt_in_topics[mqtt_base_topic.."_WATCHDOG"]={
        ["INIT"]=function()
                tmr.softwd(WATCHDOG_TIMEOUT or 3600)
            end}
    print_log("Mqtt watchdog created.")
end
print_log('reverse mqtt topics : ok')
