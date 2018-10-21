-- FLOWMETER module
--
-- Une turbine qui génère une impulsion à chaque tour de roue (capteur a effet hall)
-- ex : Sen-HZ43WB
-- Elle est donné pour F = A*Q+B
--      où  F : Freq (Hz)
--          Q : flow  (L/min)
-- Wiring : 
--          - a pin for datas
--          - 0V and 5V
--
-- usage :
--  flowmeter = require('flowmeter')
--  flowmeter.init(pin_no, A, B, interval, mode, callback)
--          - A & B     :    F = A*Q+B
--          - interval  :   time between 2 mesures (ms)
--          - mode      :   tmr.ALARM_SINGLE ou tmr.ALARM_AUTO
--          - callback  :   callback function param : the flow (L/min) if detected
--  flometer.volume     : total volume (liters)
--  flowmeter.stop()
--
-- Exemple :
--      f = require("flowmeter")
--      f.init(7,8.1,5,1000,tmr.ALARM_AUTO,function(debit) print(debit) end)
--
-- Notes :
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    gpio,tmr
-------------------------------------------------


local M
do
    --defaults

    local init_flowmeter = function(pin_no, A, B, interval, mode, callback)
        M.pin_no, M.A, M.B, M.interval, M.mode, M.callback = pin_no, A, B, interval, mode, callback
        M.impulsions = 0
        M.volume = 0
        gpio.mode(M.pin_no,gpio.INT)
        gpio.trig(M.pin_no,"up",function(level, when, enventcount)
                M.impulsions = M.impulsions + enventcount
            end)
        M.timer = tmr.create()
        M.timer:alarm(M.interval,mode,function()
                local debit = M.impulsions
                M.impulsions = 0
                if debit > 0 then
                    debit = (debit*1000/M.interval+M.B)/M.A
                    M.volume = M.volume + debit * M.interval/60000
                end
                if M.mode == tmr.ALARM_SINGLE or (debit > 0 and M.mode == tmr.ALARM_AUTO) then
                    pcall(M.callback, debit)
                end
            end)
    end

    local stop_flowmeter = function()
        gpio.trip(M.pin_no, "none")
        M.timer:stop()
    end

    M =  {
            stop = stop_flowmeter,
            init = init_flowmeter
        }
end
return M
