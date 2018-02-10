--Function executee tous les test_period par alarm 5
--
--Usage (dasn param.lua)
-- test_period = 1000 (1 seconde)
-- mqtt_test_topics = {}
-- mqtt_test_topics[mqtt_base_topic.."MQ-5"] = {
--          test = function()
--                      return false or true
--                  end,
--          value = "C'est vrai",
--          mqtt_repeat = false,
--         qos = 0, retain = 0, callback = nil}
--

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
