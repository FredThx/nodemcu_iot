--Ajout les topics MQTT de demande de mesure
-- exemple /T-HOME/TEST/temperature est le topic dans lequel est envoyé toutes les x minutes
--         /T-HOME/TEST/temperature_ est le topic de demande de la température (valeur = "SENDIT")

print_log("Add reverse topics ...")

if App.mqtt_out_topics then
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
            if not App.mqtt_test_topics then App.mqtt_test_topics = {} end
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
                        qos = App.mqtt_out_topics[topic].qos or 0, 
                        retain = App.mqtt_out_topics[topic].retain or 0,
                        callback = App.mqtt_out_topics[topic].callback}}
            print_log("Test topic "..topic.."_".." created.")
         end
    end
end
-- deamons systems : 
if App.mqtt.base_topic then
	-- pour executer du code via MQTT
    App.mqtt_in_topics[App.mqtt.base_topic.."_LUA"]= function(data)
                   node.input(data)
                end
    print_log(App.mqtt.base_topic.."_LUA created.")
	-- pour tester si vivant
	App.mqtt_in_topics[App.mqtt.base_topic.."_HELLO"]= function(data)
				App.mqtt_publish(App.mqtt.client_name, App.mqtt.base_topic.."HELLO")
			end
    print_log(App.mqtt.base_topic.."_HELLO created.")
end

-- fonction de redirection de l'interpreteur LUA
-- usage : node.output(App.redirectLUA)
function App.redirectLUA(str)
    local msg_debug = App.msg_debug
    App.msg_debug = false
    App.mqtt_publish(str, App.mqtt.base_topic.."_OUTPUT")
    App.msg_debug = msg_debug
end

print_log('reverse mqtt topics : ok')

-- Modification App.mqtt_test_topic si pas table de table
if App.mqtt_test_topics then
    for topic, tests in pairs(App.mqtt_test_topics) do
    	if type(tests[1]) ~= 'table' then
    		App.mqtt_test_topics[topic] = {tests}
    	end
    end
end
