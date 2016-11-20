-----------------------------------------
-- Init of the mqtt trigger
--
-- a mqtt trigger is defined by
--  mqtt_trig_topics["MyTopic"]={
--              pin = the_input_pin,
--              pullup = false true,
--              type = "down", -- or "_down" (as down, but realy work), "both", "low", "high"
--              qos = 0, retain = 0, callback = nil,
--              message = "Hello" (if omitted level is send ; message can be a function)
--              divisor = false (or omitted) or the number of events for the message to be transmitted }
------------------------------------------
if mqtt_trig_topics then
    for topic, trig in pairs(mqtt_trig_topics) do
        print("Init trigger : ", trig.pin, trig.type)
        -- Initialisations
        if trig.pullup then
            gpio.mode(trig.pin, gpio.INT, gpio.PULLUP)
        else
            gpio.mode(trig.pin, gpio.INT)
        end
        if trig.type == "_down" then trig.actif = false end
        if trig.divisor then trig.counter = 0 end
        -- Generation des triggers
        --Pour économiser de la mémoire, ... code tres tres tres lourd!!!
        if trig.message then
            if type(trig.message)=="function" then
                if trig.divisor then
                    if trig.type=="_down" then
                        -- **** Function et diviseur et _down
                        gpio.trig(trig.pin, "both" ,function(level)
                            if not trig.actif then
                                trig.counter = trig.counter+1
                                if trig.counter>trig.divisor then
                                    local msg
                                    no_err, msg = pcall(trig.message)
                                    print(topic.." : "..msg)
                                    mqtt_client:publish(topic, msg, trig.qos or 0, trig.retain or 0, trig.callback)
                                    trig.counter = 0
                                end
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- **** Function et diviseur
                        gpio.trig(trig.pin, trig.type ,function(level)
                            trig.counter = trig.counter+1
                            if trig.counter>trig.divisor then
                                local msg
                                no_err, msg = pcall(trig.message)
                                print(topic.." : "..msg)
                                mqtt_client:publish(topic, msg, trig.qos or 0, trig.retain or 0, trig.callback)
                                trig.counter = 0
                            end
                        end)
                    end
                else
                    if trig.type=="_down" then
                        -- ****function sans diviseur et _down
                        gpio.trig(trig.pin, "both" ,function(level)
                            if not trig.actif then
                                local msg
                                no_err, msg = pcall(trig.message)
                                print(topic.." : "..msg)
                                mqtt_client:publish(topic, msg, trig.qos or 0, trig.retain or 0, trig.callback)
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- ****function sans diviseur
                        gpio.trig(trig.pin, trig.type ,function(level)
                            local msg
                            no_err, msg = pcall(trig.message)
                            print(topic.." : "..msg)
                            mqtt_client:publish(topic, msg, trig.qos or 0, trig.retain or 0, trig.callback)
                        end)
                    end
                end
            else
                if trig.divisor then
                    if trig.type=="_down" then
                        -- ****Valeur et diviseur et _down
                        gpio.trig(trig.pin, "both" ,function(level)
                            if not trig.actif then
                                trig.counter = trig.counter+1
                                if trig.counter>trig.divisor then
                                    print(topic.." : "..trig.message)
                                    mqtt_client:publish(topic, trig.message, trig.qos or 0, trig.retain or 0, trig.callback)
                                    trig.counter = 0
                                end
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- ****Valeur et diviseur
                        gpio.trig(trig.pin, trig.type ,function(level)
                            trig.counter = trig.counter+1
                            if trig.counter>trig.divisor then
                                print(topic.." : "..trig.message)
                                mqtt_client:publish(topic, trig.message, trig.qos or 0, trig.retain or 0, trig.callback)
                                trig.counter = 0
                            end
                        end)
                    end
                else
                    if trig.type=="_down" then
                        -- ****Valeur sans diviseur et _down
                        gpio.trig(trig.pin, trig.type ,function(level)
                            if trig.actif then
                                print(topic.." : "..trig.message)
                                mqtt_client:publish(topic, trig.message, trig.qos or 0, trig.retain or 0, trig.callback)
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- ****Valeur sans diviseur
                        gpio.trig(trig.pin, trig.type ,function(level)
                            print(topic.." : "..trig.message)
                            mqtt_client:publish(topic, trig.message, trig.qos or 0, trig.retain or 0, trig.callback)
                        end)
                    end
                end
            end
        else
            if trig.divisor then
                if trig.type == "_down" then
                    -- **** Level et diviseur et _down
                    gpio.trig(trig.pin, trig.type ,function(level)
                        if trig.actif then
                            trig.counter = trig.counter+1
                            if trig.counter>trig.divisor then
                                print(topic.." : "..level)
                                mqtt_client:publish(topic, level, trig.qos or 0, trig.retain or 0, trig.callback)
                                trig.counter = 0
                            end
                            trig.actif = true
                        else
                            trig.actif = false
                        end
                    end)
                else
                    -- **** Level et diviseur
                    gpio.trig(trig.pin, trig.type ,function(level)
                        trig.counter = trig.counter+1
                        if trig.counter>trig.divisor then
                            print(topic.." : "..level)
                            mqtt_client:publish(topic, level, trig.qos or 0, trig.retain or 0, trig.callback)
                            trig.counter = 0
                        end
                    end)
                end
            else
                if trig.type == "_down" then
                    -- **** Level sans diviseur et _down
                    gpio.trig(trig.pin, trig.type ,function(level)
                        if trig.actif then
                            print(topic.." : "..level)
                            mqtt_client:publish(topic, level, trig.qos or 0, trig.retain or 0, trig.callback)
                            trig.actif = false
                        else
                            trig.actif = true
                        end
                    end)
                else
                    -- **** Level sans diviseur
                    gpio.trig(trig.pin, trig.type ,function(level)
                        print(topic.." : "..level)
                        mqtt_client:publish(topic, level, trig.qos or 0, trig.retain or 0, trig.callback)
                    end)
                end
            end
        end
    end
    -- free memory
    mqtt_trig_topics = nil
    print('Init_trig : ok')
end

