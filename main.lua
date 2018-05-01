-- projet Standart NodeMCU & MQTT
-- 
-- Base sur ESP8266
--


-- Lecture des parametres propres du projets

App = require("params")

if App.msg_debug == nil then App.msg_debug = true end

print_log("******************************")
print_log("**   " .. App.mqtt.client_name .. "              **")
print_log("******************************")
print_log("")


if LOGGER then 
    _dofile("logger")
    node.output(logger,1)
    print_log("----- NODE RESTART -----")
end

if App.watchdog then
    tmr.softwd(App.watchdog.timeout or 3600)
end

_dofile("add_reverse_topics")
for key, reader in pairs(modules or {}) do
    print_log("Load " .. reader)
    _dofile(reader)
end

function on_wifi_connected()
    if TELNET then
        _dofile("telnet")
    end
    _dofile("init_mqtt")
end

_dofile("wifi")
