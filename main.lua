-- projet Standart NodeMCU & MQTT
-- 
-- Base sur ESP8266
----------------------------------------------------
-- Utilisation des alarmes :
--  0   :   i2c display
--  1   :   wait_for_wifi_conn
--  2   :   test wifi
--  3   :   mqtt_connect()
--  4   :   _dofile("read_and_send")
--  5   :   _dofile("test_and_send")
--  6   :   libre pour le projet (ex : blink leb)
---------------------------------------------------

_dofile("params")
if MSG_DEBUG == nil then MSG_DEBUG = true end

print_log("******************************")
print_log("**   " .. HOST.. "              **")
print_log("******************************")
print_log("")


if LOGGER then 
    _dofile("logger")
    node.output(logger,1)
    print_log("----- NODE RESTART -----")
end

if WATCHDOG then
    tmr.softwd(WATCHDOG_TIMEOUT or 3600)
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
