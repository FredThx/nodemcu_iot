for topic, trig in pairs(mqtt_trig_topics) do
    if trig.pullup then
        gpio.mode(trig.pin, gpio.INT, gpio.PULLUP)
    else
        gpio.mode(trig.pin, gpio.INT)
    end
    print("Init trigger : ", trig.pin, trig.type)
    if trig.type == "_down" then
        trig.actif = false
        gpio.trig(trig.pin, "both" ,function(level)
                    if not trig.actif then
                        print(topic.." : "..level)
                        mqtt_client:publish(topic, level, trig.qos, trig.retain, trig.callback)
                        trig.actif = true
                    else
                        trig.actif = false
                    end
                end)
    else
        gpio.trig(trig.pin, trig.type ,function(level)
                    print(topic.." : "..level)
                    mqtt_client:publish(topic, level, trig.qos, trig.retain, trig.callback)
                    end)
    end
end
