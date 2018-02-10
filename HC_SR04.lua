-----------------------------------------------------------
-- Project : nodemcu_iot
-----------------------------------------------------------
-- Autor : FredThx
-----------------------------------------------------------
-- HC-SR04 module
-- Ultrasonic distance mesurer
-----------------------------------------------------------
-- usage :
-- sr04= dofile('HC_SR04.lua') or .lc if compiled or _dofile(....)
-- sr.init(pin_trig, pin_echo,  [delay_mesure], [callback])
--          delay_mesure in ms : time between two mesures
--          callback : function called at each valid mesure
-- sr.init = nil -- to free memory
-- sr.start()
-- sr.read() return the distance or nil
-- sr.stop()
------------------------------------------------------------
-- Example :
-- sr = dofile("HC_SR04.lua")
-- sr.init(1,2,1000, function(value) print("Mesure :",value) end)
-- sr.start()
-- distabnce = sr.read()
------------------------------------------------------------


local M = {}

do
    function init(pin_trig, pin_echo, delay_mesure, callback)
        M.pin_trig = pin_trig
        M.pin_echo = pin_echo
        M.delay_mesure = delay_mesure or 1000 -- each second
        M.callback = callback
        gpio.mode(pin_trig,gpio.OUTPUT)
        gpio.write(pin_trig,gpio.LOW)
        gpio.mode(pin_echo,gpio.INPUT)
    end

    -- start mesuring
    function start()
        M.mesure=nil
        gpio.trig(M.pin_echo, "both", function(level, now)
            --print("pin_echo :",level)
            if level == 1 then
                M.start_echo = now
            else
                --print (now, M.start_echo)
                if M.start_echo and now > M.start_echo then
                    M.mesure = (now - M.start_echo)*340/2000000
                    if M.mesure > 10 then -- max distance : 10 meters
                        --M.mesure = nil
                    else
                        if M.callback then
                            M.callback(M.mesure)
                        end
                    end
                end
            end
        end)
        M.timer=tmr.create()
        M.timer:alarm(M.delay_mesure, tmr.ALARM_AUTO, function()
                gpio.write(M.pin_trig,gpio.HIGH)
                tmr.delay(15) -- 15µs
                gpio.write(1, gpio.LOW)
            end)
    end

    -- stop mesuring
    function stop()
        if M.timer then
            M.timer:unregister()
        end
        gpio.trig(M.pin_trig,"none")
        M.mesure = nil
    end

    -- Return the last mesure
    function read()
        return M.mesure
    end

    M.init = init
    M.read = read
    M.start = start
    M.stop = stop
    
end
return M 
