for topic, tests in pairs(mqtt_test_topics) do
    for i, test in ipairs(tests) do
        if test["test"]() then
            -- TODO : tester le reapat
            mqtt_client:publish(topic,test["value"],
                        test["qos"] or 0,
                        test["retain"] or 0,
                        test["callback"])        
        end
    end
end
