gpio.mode(0,gpio.INPUT,gpio.PULLUP)
if (gpio.read(0)==gpio.HIGH) then
    print("Initialisation...")
    tmr.alarm(0,2000,tmr.ALARM_SINGLE, function ()
            dofile("util.lc")
            _dofile("main")
        end)
end
