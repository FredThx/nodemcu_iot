-- Lecture des capteurs & envoie données via mqtt
for topic, action in pairs(mqtt_out_topics) do
    if not action.manual then
        local no_err, rep
        if type(action.message)=="function" then
            no_err, rep = pcall(action.message)
        else
            no_err = true
            rep = action.message
        end
        print_log(topic, ":" , rep)
        if no_err and rep then
            if mqtt_client:publish(topic,rep,
                                action.qos or 0,
                                action.retain or 0,
                                action.callback) then
                print_log("MQTT send : ok")
            else
                print_log("MQTT not send : mqtt error")
            end
            --tmr.delay(1000000) Pourquoi ca a ete mis??? Il ne faut pas !!!
            collectgarbage()
        else
            print_log("MQTT not send : action error")
        end
    end
end

-- TODO : supprimer le delay et mettre une alarme à la place


