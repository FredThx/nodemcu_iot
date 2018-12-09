-- Moteur CC sur L298B : double pont en H
--
-- Wiring :
--
--
-- usage :
--          moteur = require("motor_l298b")
--          moteur.init(pin_ena, pinA, pinB[, freq][, duty])
--          moteur.run()
--          moteur.stop()
--          moteur.run{reverse = true}
--          moteur.run{reverse = false, freq = 100, duty = 0.5}
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    gpio,tmr
--    pwm
-------------------------------------------------

local M = {}

do
    
    
    function M.init(pin_ena, pinA, pinB, freq, duty)
        M.ena = pin_ena
        gpio.mode(M.ena,gpio.OUTPUT)
        M.pinA = pinA
        gpio.mode(M.pinA,gpio.OUTPUT)
        M.pinB = pinB
        gpio.mode(M.pinB,gpio.OUTPUT)
        M.freq = freq
        M.duty = duty
        pwm.setup(M.ena,M.freq or 500, (M.duty or 0.5 )* 1023)
        M.stop()
    end
    
    function M.stop()
        pwm.stop(M.ena)
        gpio.write(M.ena, gpio.LOW)
        print("motor stopped")
    end
    
    function M.run(args)
        if args == nil then args = {} end
        if args.reverse then
            gpio.write(M.pinA, gpio.LOW)
            gpio.write(M.pinB, gpio.HIGH)
            print("Set reverse")
        else
            gpio.write(M.pinA, gpio.HIGH)
            gpio.write(M.pinB, gpio.LOW)
            print("Set normal")
        end
        if (args.duty and args.duty<1) or (M.duty or M.duty) then
            pwm.setup(M.ena,args.freq or M.freq or 500, (args.duty or M.duty) * 1023)
            gpio.write(M.ena, gpio.LOW)
            pwm.start(M.ena)
            print("motor : pwm : freq=" .. M.ena,args.freq or M.freq or 500 .. " duty =" .. (args.duty or M.duty) * 1023)
        else
            pwm.stop(M.ena)
            gpio.write(M.ena, gpio.HIGH)
            print('motor : run 100%')
        end
    
    end

end

return M
