

-- Lecture des capteurs & envoie données via mqtt
for topic, action in pairs(mqtt_out_topics) do
    if not action.manual then
        local no_err, rep = pcall(action.message)
        print(topic, ":" , rep)
        if no_err and rep then
            if mqtt_client:publish(topic,rep,
                                action.qos or 0,
                                action.retain or 0,
                                action.callback) then
                print("MQTT send : ok")
            else
                print("MQTT not send : mqtt error")
            end
            tmr.delay(1000000)
            collectgarbage()
        else
            print("MQTT not send : action error")
        end
    end
end

-- TODO : supprimer le delay et mettre une alarme à la place


