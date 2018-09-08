-----------------------------------------
-- Init of the mqtt trigger
--
-- a mqtt trigger is defined by
--  App.mqtt_trig_topics["MyTopic"]={
--              pin = the_input_pin,
--              pullup = false true,
--              type = "down", -- or "_down" (as down, but realy work), "both", "low", "high"
--              qos = 0, retain = 0, callback = nil,
--              message = "Hello" (if omitted level is send ; message can be a function)
--              divisor = false (or omitted) or the number of events for the message to be transmitted }
------------------------------------------
if App.mqtt_trig_topics then
    for topic, trig in pairs(App.mqtt_trig_topics) do
        print_log("Init trigger : ", trig.pin, trig.type)
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
                        print_log("    Function et diviseur et _down")
                        gpio.trig(trig.pin, "both" ,function(level)
                            if not trig.actif then
                                trig.counter = trig.counter+1
                                if trig.counter>trig.divisor then
                                    local msg
                                    no_err, msg = pcall(trig.message,level,when,eventcount)
                                    if no_erre and msg then
                                        --print(topic.." : "..msg)
									    App.mqtt_publish(msg, topic, trig)
                                        trig.counter = 0
                                    end
                                end
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- **** Function et diviseur
                        print_log("    Function et diviseur")
                        gpio.trig(trig.pin, trig.type ,function(level,when,eventcount)
                            trig.counter = trig.counter+1
                            if trig.counter>trig.divisor then
                                local msg
                                no_err, msg = pcall(trig.message,level,when,eventcount)
                                if no_err and msg then
                                    --print(topic.." : "..msg)
								    App.mqtt_publish(msg, topic, trig)
                                    trig.counter = 0
                                end
                            end
                        end)
                    end
                else
                    if trig.type=="_down" then
                        -- ****function sans diviseur et _down
                        print_log("     function sans diviseur et _down")
                        gpio.trig(trig.pin, "both" ,function(level,when,eventcount)
                            if not trig.actif then
                                local msg
                                no_err, msg = pcall(trig.message,level,when,eventcount)
                                if no_err and msg then
                                    --print(topic.." : "..msg)
                                    App.mqtt_publish(msg, topic, trig)
                                    trig.actif = true
                                end
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- ****function sans diviseur
                        print_log("     function sans diviseur")
                        gpio.trig(trig.pin, trig.type ,function(level,when,eventcount)
                            local msg
                            no_err, msg = pcall(trig.message, level,when,eventcount)
                            if no_err and msg then
                                --print(topic.." : "..msg)
                                App.mqtt_publish(msg, topic, trig)
                            end
                        end)
                    end
                end
            else
                if trig.divisor then
                    if trig.type=="_down" then
                        -- ****Valeur et diviseur et _down
                        print_log("     Valeur et diviseur et _down")
                        gpio.trig(trig.pin, "both" ,function(level,when,eventcount)
                            if not trig.actif then
                                trig.counter = trig.counter+1
                                if trig.counter>trig.divisor then
                                    --print(topic.." : "..trig.message)
                                    App.mqtt_publish(trig.message, topic, trig)
                                    trig.counter = 0
                                end
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- ****Valeur et diviseur
                        print_log("     Valeur et diviseur")
                        gpio.trig(trig.pin, trig.type ,function(level,when,eventcount)
                            trig.counter = trig.counter+1
                            if trig.counter>trig.divisor then
                                --print(topic.." : "..trig.message)
								App.mqtt_publish(trig.message, topic, trig)
                                trig.counter = 0
                            end
                        end)
                    end
                else
                    if trig.type=="_down" then
                        -- ****Valeur sans diviseur et _down
                        print_log("     Valeur sans diviseur et _down")
                        gpio.trig(trig.pin, "both" ,function(level,when,eventcount)
                            if trig.actif then
                                --print(topic.." : "..trig.message)
								App.mqtt_publish(trig.message, topic, trig)
                                trig.actif = true
                            else
                                trig.actif = false
                            end
                        end)
                    else
                        -- ****Valeur sans diviseur
                        print_log("     Valeur sans diviseur")
                        gpio.trig(trig.pin, trig.type ,function(level,when,eventcount)
                            --print(topic.." : "..trig.message)
							App.mqtt_publish(trig.message, topic, trig)
                        end)
                    end
                end
            end
        else
            if trig.divisor then
                if trig.type == "_down" then
                    -- **** Level et diviseur et _down
                    print_log("     Level et diviseur et _down")
                    gpio.trig(trig.pin, "both" ,function(level,when,eventcount)
                        if trig.actif then
                            trig.counter = trig.counter+1
                            if trig.counter>trig.divisor then
                                --print(topic.." : "..level)
								App.mqtt_publish(level, topic, trig)
                                trig.counter = 0
                            end
                            trig.actif = true
                        else
                            trig.actif = false
                        end
                    end)
                else
                    -- **** Level et diviseur
                    print_log("     Level et diviseur")
                    gpio.trig(trig.pin, trig.type ,function(level,when,eventcount)
                        trig.counter = trig.counter+1
                        if trig.counter>trig.divisor then
                            --print(topic.." : "..level)
                            App.mqtt_publish(level, topic, trig)
                            trig.counter = 0
                        end
                    end)
                end
            else
                if trig.type == "_down" then
                    -- **** Level sans diviseur et _down
                    print_log("     Level sans diviseur et _down")
                    gpio.trig(trig.pin, "both" ,function(level,when,eventcount)
                        if trig.actif then
                            --print(topic.." : "..level)
                            App.mqtt_publish(level, topic, trig)
                            trig.actif = false
                        else
                            trig.actif = true
                        end
                    end)
                else
                    -- **** Level sans diviseur
                    print_log("     Level sans diviseur")
                    gpio.trig(trig.pin, trig.type ,function(level,when,eventcount)
                        --print(topic.." : "..level)
                        App.mqtt_publish(level, topic, trig)
                    end)
                end
            end
        end
    end
    -- free memory
    App.mqtt_trig_topics = nil
    print_log('Init_trig : ok')
end

