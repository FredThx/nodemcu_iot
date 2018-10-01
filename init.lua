print("Initialisation...")

tmr.create():alarm(1000,tmr.ALARM_SINGLE, function ()
        dofile("util.lc")
        _dofile("main")
    end)
