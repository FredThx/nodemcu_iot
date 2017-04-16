-- Initialisation MQTT

mqtt_client = mqtt.Client(mqtt_client_name, 120, mqtt_user, mqtt_pass)
--mqtt_connected = false
-- on connect / close
--mqtt_client:on("connect", function(con) print ("MQTT connected") end)
-- on close connection, keep alive connection
mqtt_client:on("offline", function(con) 
    print ("MQTT offline")
    --todo : stop the triggers
    tmr.stop(4)
    mqtt_connected = false
    mqtt_connect()
    end)

-- on receive message
mqtt_client:on("message", function(conn, topic, data)
    if data == nil then data = "" end
    print("Reception MQTT =>" .. topic .. ":" .. data)
    if mqtt_in_topics[topic]~= nil then
        if type(mqtt_in_topics[topic])=='function' then
            mqtt_in_topics[topic](data)
        end
        if type(mqtt_in_topics[topic])=='table' then
            if mqtt_in_topics[topic][data]~= nil then
                mqtt_in_topics[topic][data]()
            end
        end
    end
end)

function mqtt_connect()
    tmr.alarm(3, 1000, 1, function()
            if mqtt_connected then
                print("MQTT Connected.")
                tmr.stop(3)
            else
                print("MQTT Connection...")
                mqtt_client:connect(mqtt_host, mqtt_port, 0, function(conn)
                        mqtt_connected = true
                        for topic in pairs(mqtt_in_topics) do
                            mqtt_client:subscribe(topic,1)
                            print(topic .." : subscribed")
                        end
                        _dofile("init_trig")
                        if mesure_period then
                            tmr.alarm(4, mesure_period, tmr.ALARM_AUTO, function () 
                                    _dofile("read_and_send")
                                    if LOGGER then
                                        check_logfile_size()
                                    end
                                end)
                        end
                        if test_period then
                            tmr.alarm(5,test_period, tmr.ALARM_AUTO, function()
                                    _dofile("test_and_send")
                                end)
                        end
                    end)
            end
        end)
end

mqtt_connect()
print('Init_mqtt : ok')
                
