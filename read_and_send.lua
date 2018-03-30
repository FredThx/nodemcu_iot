

-- Lecture des capteurs & envoie données via mqtt

for topic, action in pairs(mqtt_out_topics) do
    if not action.manual then
        local no_err, rep
        if action.message then
            if type(action.message)=="function" then
                no_err, rep = pcall(action.message)
            else
                no_err = true
                rep = action.message
            end
            print_log(topic, ":" , rep)
            if no_err and rep then
                mqtt_publish(rep, topic,action)
            else
                print_log("MQTT not send : action error")
            end
        end
        if action.result_on_callback then --callback function when datas is generate by callback function (ex ds18b20)
            no_err, rep = pcall(action.result_on_callback, function(result)
                            mqtt_publish(result, topic,action)
                        end)
        end
    end
end

-- TODO : supprimer le delay et mettre une alarme à la place


