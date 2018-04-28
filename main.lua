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

function mqtt_publish(rep,topic,action)
            if not action then action = {} end
            if type(rep)=="table" then
                rep = sjson.encode(rep)
            end
            print_log("publish ".. topic.. "=>" ..rep)
            if mqtt_connected then
                if mqtt_client:publish(topic,rep,
                                    action.qos or 0,
                                    action.retain or 0,
                                    action.callback) then
                    print_log("MQTT send : ok")
                else
                    print_log("MQTT not send : mqtt error")
                    --TODO : reconnect
                end
                --tmr.delay(1000000) Pourquoi ca a ete mis??? Il ne faut pas !!!
                collectgarbage()       
            end
            if action.usb then
                print(rep)
            end
    end

if mesure_period then
    tmr.create():alarm(mesure_period, tmr.ALARM_AUTO, function () 
            _dofile("read_and_send")
            if LOGGER then
                check_logfile_size()
            end
        end)
end
                        
_dofile("wifi")
