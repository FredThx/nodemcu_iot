ws2812.init()
--ws2812.write(string.char(10,30,100,20,0,0))




buffer10=ws2812.newBuffer(10,3)
buffer6 = ws2812.newBuffer(6,3)
buffer6:fill(0,0, 0)
buffer10:fill(0,0, 0)
ws2812.write(buffer10..buffer6..buffer10..buffer6..buffer10..buffer6..buffer10..buffer6..buffer10)

--alarm = tmr.create()
--alarm:alarm(10,tmr.ALARM_AUTO ,function()
        ws2812.write(buffer)
--        buffer:shift(1)--,ws2812.SHIFT_CIRCULAR)
--    end)

--alarm2 = tmr.create()

couleurs = {{0,0,0},{255,255,255},{255,0,0},{0,255,0},{0,0,255}}
--couleurs = {{0,0,0},{25,25,25},{25,0,0},{0,25,0},{0,0,25}}


phase = 0
gpio.mode(5,gpio.INT)
gpio.trig(5,"up",function()
        --local r=math.random(255)
        --local v = math.random(255)
        --local b = math.random(255)
        phase = (phase + 1)%5
        buffer10:fill(unpack(couleurs[1+phase]))
        ws2812.write(buffer10..buffer6..buffer10..buffer6..buffer10..buffer6..buffer10..buffer6..buffer10)
        --buffer:set(2,r,v,b)
        --buffer:set(1,r/3,v/3,b/3)
    end)

-- init the ws2812 module

