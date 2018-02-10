gpio.mode(3,gpio.INPUT)
if (gpio.read(3)==gpio.HIGH) then
    print("Initialisation...")
    tmr.alarm(0,2000,tmr.ALARM_SINGLE, function ()
            dofile("util.lc")
            _dofile("main")
        end)
end
