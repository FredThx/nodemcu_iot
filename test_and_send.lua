for topic, tests in pairs(mqtt_test_topics) do
    local value
	for i, test in ipairs(tests) do
        if test["test"]() then
            -- TODO : tester le reapat
			if type(test["value"])=='function' then
				value = test["value"]()
			else
				value = test["value"]
			end
            print(topic, ":" , value)
            mqtt_client:publish(topic,value,
                        test["qos"] or 0,
                        test["retain"] or 0,
                        test["callback"])        
        end
    end
end
