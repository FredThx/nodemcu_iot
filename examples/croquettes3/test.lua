uart.setup(0,115200,8 ,uart.PARITY_NONE, uart.STOPBITS_1, 1)

tmr.alarm(0,400,tmr.ALARM_AUTO, function()
        t = math.floor(10*math.max(0,poids.offset + hx711.read(0)/poids.pente))/10
        uart.write(0,t..'\n')
    end)
