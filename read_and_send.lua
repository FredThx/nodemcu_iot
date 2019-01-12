-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
-- Lecture des capteurs & envoie données via mqtt
--
-- Afin d'éviter que les lecture interfèrent entre elles
-- (capteur non réinitialisé suite lecture précédente)
-- Les lectures sont envoyés espacées de 
--          App.mesure_interval or 500 (ms)
--------------------------------------------------

local interval = App.mesure_interval or 500

--Création table pour accés par index
local index = 0
local topics = {}
for topic in pairs(App.mqtt_out_topics) do
        table.insert(topics,topic)
    end
    
local timer = tmr.create()
timer:alarm(interval,tmr.ALARM_AUTO, function()
        index = index + 1
        local topic = topics[index]
        if topic then
            local action = App.mqtt_out_topics[topic]
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
                            App.mqtt_publish(rep, topic,action)
                        else
                            print_log("MQTT not send : action error")
                        end
                    end
                    if action.result_on_callback then --callback function when datas is generate by callback function (ex ds18b20)
                        no_err, rep = pcall(action.result_on_callback, function(result)
                                        App.mqtt_publish(result, topic,action)
                                    end)
                    end
                end
        else
            timer:stop()
        end
    end)



