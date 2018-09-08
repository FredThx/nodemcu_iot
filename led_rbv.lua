-- LED RBV module
--
-- Wiring: 
--       cathode to GRND
--       anodes to pins (1~12) with resistors (~1kO)
--
--        | | | |
--          | |
--            |
--       V B  0 R
--
-- usage :
--  led = require "led_rbv"
--  led.init(1,3,2)
--  led.setcolor(0,255,255)
--  led.off()
--  led.on()
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    pwm
-------------------------------------------------
-- by FredThx
-------------------------------------------------

local M = {}

do

    local pins={}

    M.init = function(r,b,v)
        pins.R=r
        pins.B=b
        pins.V=v
        local k,pin
        for k, pin in pairs(pins) do
            pwm.setup(pin,60,255)
            pwm.start(pin)
        end
    end

    M.setcolor = function (r,b,v)
        pwm.setduty(pins.R,r*4)
        pwm.setduty(pins.B,b*4)
        pwm.setduty(pins.V,v*4)
    end

    M.off = function()
        for k, pin in pairs(pins) do
            pwm.stop(pin)
        end
    end

    M.on = function()
        for k, pin in pairs(pins) do
            pwm.start(pin)
        end
    end

end

return M