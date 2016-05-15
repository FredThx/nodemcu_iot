-- projet Standart NodeMCU & MQTT
-- 
-- Base sur ESP8266


--dofile("util.lc")
_dofile("params")

print("******************************")
print("**   " .. HOST.. "              **")
print("******************************")
print()

if LOGGER then 
    _dofile("logger")
    node.output(logger,1)
    print("----- NODE RESTART -----")
end

_dofile("add_reverse_topics")
for key, reader in pairs(modules) do
    print("Load " .. reader)
    _dofile(reader)
end

function on_wifi_connected()
    _dofile("telnet")
    _dofile("init_mqtt")
    _dofile("init_trig")
    -- Solution hybernation (economie energie):
    -- mqtt_client:on("offline", function(con) 
    --    print ("Hybernation...") 
    --    node.dsleep(mesure_period*1000)
    --    end)
    -- Solution alarme (reste eveille et connecte. Telnet possible):
    tmr.alarm(4, mesure_period, 1, function () 
            _dofile("read_and_send")
            if LOGGER then
                check_logfile_size()
            end
        end)
    tmr.alarm(5,test_period, 1, function()
            _dofile("test_and_send")
        end)
end

_dofile("wifi")
