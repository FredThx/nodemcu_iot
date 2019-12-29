print("Initialisation...")
tmr.create():alarm(2000,tmr.ALARM_SINGLE, function ()
        if dofile("compile.lua") then node.restart() end
        dofile("util.lc")
        _dofile("main")
    end)
