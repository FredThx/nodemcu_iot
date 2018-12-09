--gpio.mode(0,gpio.INPUT,gpio.PULLUP)
--if (gpio.read(0)==gpio.HIGH) then
    print("Initialisation...")
    tmr.create():alarm(2000,tmr.ALARM_SINGLE, function ()
            if dofile("compile.lua") then node.restart() end
            dofile("util.lc")
            _dofile("main")
        end)
--end
