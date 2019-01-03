--Function executee tous les test_period 
--
--Usage (dans param.lua)
-- App.test_period = 1000 (1 seconde)
-- App.mqtt_test_topics = {}
-- App.mqtt_test_topics[App.mqtt.base_topic.."MQ-5"] = {
--          test = function()
--                      return false or true
--                  end,
--          value = "C'est vrai",
--          mqtt_repeat = false,
--         qos = 0, retain = 0, callback = nil}
--

for topic, tests in pairs(App.mqtt_test_topics) do
    local value
	for i, test in ipairs(tests) do
        if test["test"]() then
            -- TODO : tester le reapat
			if type(test["value"])=='function' then
				value = test["value"]()
			else
				value = test["value"]
			end
            App.mqtt_publish(value,topic,tests)
        end
    end
end
