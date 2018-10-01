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



function mqtt_publish(rep,topic,action)
            if not action then action = {} end
            if type(rep)=="table" then
                rep = sjson.encode(rep)
            end
            print_log("publish ".. topic.. "=>" ..rep)
            if mqtt_connected and node.heap() > 2000 then -- prevent not enough memory error when mqtt queue messages
                if mqtt_client:publish(topic,rep,
                                    action.qos or 0,
                                    action.retain or 0,
                                    action.callback) then
                    print_log("MQTT send : ok")
                else
                    print_log("MQTT not send : mqtt error")
                    --TODO : reconnect
                end
                collectgarbage()       
            end
            if action.usb then
                print(rep)
            end
    end


if wifi.sta.getip() then
    _dofile("on_wifi_connected")
end
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        tmr.create():alarm(2000,tmr.ALARM_SINGLE,function()
                _dofile("on_wifi_connected")
            end)
 end)


                        
tmr.create():alarm(30000, tmr.ALARM_SINGLE, function()
        if wifi.sta.getip() == nil then
            print_log("Wifi not connected. Start enduser web AP.")
            read_and_send_timer:interval(mesure_period*4)
            enduser_setup.start()
            tmr.create():alarm(5*60000, tmr.ALARM_SINGLE, function()
                    enduser_setup.stop()
                    read_and_send_timer:interval(mesure_period)
                end)
        end
    end)



if mesure_period then
    read_and_send_timer = tmr.create()
    read_and_send_timer:alarm(mesure_period, tmr.ALARM_AUTO, function () 
            _dofile("read_and_send")
            if LOGGER then
                check_logfile_size()
            end
        end)
end
