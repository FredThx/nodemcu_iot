ws2812.init()
--ws2812.write(string.char(10,30,100,20,0,0))



buffer=ws2812.newBuffer(150,3)
buffer:fill(0, 0, 0)
ws2812.write(buffer)

alarm = tmr.create()
alarm:alarm(10,tmr.ALARM_AUTO ,function()
        ws2812.write(buffer)
        buffer:shift(1)--,ws2812.SHIFT_CIRCULAR)
    end)

--alarm2 = tmr.create()

gpio.mode(5,gpio.INT)
gpio.trig(5,"up",function()
        local r=math.random(255)
        local v = math.random(255)
        local b = math.random(255)
        buffer:set(2,r,v,b)
        buffer:set(1,r/3,v/3,b/3)
    end)

-- init the ws2812 module

