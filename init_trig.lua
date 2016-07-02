-----------------------------------------
-- Init of the mqtt trigger
--
-- a mqtt trigger is defined by
--  mqtt_trig_topics["MyTopic"]={
--              pin = the_input_pin,
--              pullup = false true,
--              type = "down", -- or "down", "both", "low", "high"
--              qos = 0, retain = 0, callback = nil,
--              message = "Hello" (if omitted level is send ; message can be a function)
--              divisor = false (or omitted) or the number of events for the message to be transmitted }
------------------------------------------
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
                        if trig.divisor then trig.counter = trig.counter+1 end
                        if (not trig.divisor) or (trig.counter>trig.divisor) then
                            local msg
                            if trig.message then 
                                if type(trig.message)=="function" then 
                                    no_err, msg = pcall(trig.message)
                                else
                                    msg = trig.message
                                end
                            else
                                msg = level
                            end
                            print(topic.." : "..msg)
                            mqtt_client:publish(topic, msg, trig.qos, trig.retain, trig.callback)
                            if trig.divisor then trig.counter = 0 end
                        end
                        trig.actif = true
                    else
                        trig.actif = false
                    end
                end)
    else
        gpio.trig(trig.pin, trig.type ,function(level)
                    if trig.divisor then trig.counter = trig.counter+1 end
                    if (not trig.divisor) or (trig.counter>trig.divisor) then
                        local msg
                        if trig.message then 
                            if type(trig.message)=="function" then 
                                no_err, msg = pcall(trig.message)
                            else
                                msg = trig.message
                            end
                        else
                            msg = level
                        end
                        print(topic.." : "..msg)
                        mqtt_client:publish(topic, msg, trig.qos, trig.retain, trig.callback)
                        if trig.divisor then trig.counter = 0 end
                    end
                end)
    end
    if trig.divisor then trig.counter = 0 end
end
