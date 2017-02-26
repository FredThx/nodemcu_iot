--Ajout les topics MQTT de demande de mesure
-- exemple /T-HOME/TEST/temperature est le topic dans lequel est envoyé toutes les x minutes
--         /T-HOME/TEST/temperature_ est le topic de demande de la température (valeur = "SENDIT")


for topic in pairs(mqtt_out_topics) do
    mqtt_in_topics[topic.."_"]={["SENDIT"]=function()
            print(topic,"...")
            local no_err, rep = pcall(mqtt_out_topics[topic]["message"])
            print(topic, ":" , rep)
            if no_err and rep then
                mqtt_client:publish(
                        topic,
                        rep,
                        mqtt_out_topics[topic]["qos"] or 0,
                        mqtt_out_topics[topic]["retain"] or 0,
                        mqtt_out_topics[topic]["callback"] --
                        )
            else
                print("MQTT not send.")
            end
        end}
    print("Reverse topic "..topic.."_".." created.")
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
        print("Test topic "..topic.."_".." created.")
     end
end

-- deamons systems : pour executer du code via MQTT
if mqtt_base_topic then
    mqtt_in_topics[mqtt_base_topic.."_LUA"]= function(data)
                   node.input(data)
                end
end
-- watchdog
if WATCHDOG then
    mqtt_in_topics[mqtt_base_topic.."_WATCHDOG"]={
        ["INIT"]=function()
                tmr.softwd(WATCHDOG_TIMEOUT or 3600)
            end}
    print("Mqtt watchdog created.")
end
print('reverse mqtt topics : ok')
