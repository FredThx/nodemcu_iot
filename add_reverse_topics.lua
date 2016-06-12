--Ajout les topics MQTT de demande de mesure
-- exemple /T-HOME/TEST/temperature est le topic dans lequel est envoyé toutes les x minutes
--         /T-HOME/TEST/temperature_ est le topic de demande de la température (valeur = "SENDIT")


for topic in pairs(mqtt_out_topics) do
    mqtt_in_topics[topic.."_"]={["SENDIT"]=function()
            local no_err, rep = pcall(mqtt_out_topics[topic]["message"])
            print(topic, ":" , rep)
            if no_err and rep then
                mqtt_client:publish(
                        topic,
                        rep,
                        mqtt_out_topics[topic]["qos"],
                        mqtt_out_topics[topic]["retain"],
                        mqtt_out_topics[topic]["callback"] --
                        )
            else
                print("MQTT not send.")
            end
        end}
end

-- deamons systems : pour executer du code via MQTT
if mqtt_base_topic then
    mqtt_in_topics[mqtt_base_topic.."_LUA"]= function(data)
                   node.input(data)
                end
end
