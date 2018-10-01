--ON WIFI  CONNECTED

print_log ("WIFI connected")
print_log ("     IP is " .. wifi.sta.getip())

if TELNET then
    _dofile("telnet")
end

_dofile("init_mqtt")

 if on_wifi_connected ~= nil then
    on_wifi_connected()
 end
