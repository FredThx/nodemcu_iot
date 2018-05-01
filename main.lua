-- projet Standart NodeMCU & MQTT
-- 
-- Base sur ESP8266
----------------------------------------------------
-- Utilisation des alarmes :
--  auto   :   i2c display
--  auto   :   wait_for_wifi_conn
--  auto   :   test wifi
--  auto   :   mqtt_connect()
--  auto   :   _dofile("read_and_send")
--  auto   :   _dofile("test_and_send")
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
