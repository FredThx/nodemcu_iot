-- Lecture des capteurs & envoie données via mqtt
for topic, action in pairs(mqtt_out_topics) do
    if not action.manual then
        local no_err, rep = pcall(action.message)
        print(topic, ":" , rep)
        if no_err and rep then
            mqtt_client:publish(topic,rep,
                                action.qos,
                                action.retain,
                                action.callback)
            tmr.delay(1000000)
        else
            print("MQTT not send.")
        end
    end
end

-- TODO : supprimer le delay et mettre une alarme à la place


