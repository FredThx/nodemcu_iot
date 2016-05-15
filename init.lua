gpio.mode(0,gpio.INPUT)
if (gpio.read(0)==gpio.HIGH) then
    tmr.alarm(0,1000,tmr.ALARM_SINGLE, function ()
            dofile("util.lc")
            _dofile("main")
        end)
end
