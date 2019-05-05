-- servomotor module
--
-- usage :
--  servo = dofile('servo.lua')
--  servo.init(1) 1=pin
--  servo.init = nil -- to free memory
--  servo.angle(angle) angle entre 0 et 156
--
local M
do
    local PIN = 1
    local init_servo = function(pin)
            PIN = pin or PIN
            pwm.setup(PIN,50,25)
            pwm.start(PIN)
        end
    local set_angle = function(angle)
            if angle >= 0 and angle <= 200 then
                pwm.setduty(PIN, 25+angle*5/9)
            end
        end
    M = {
            init = init_servo,
            angle = set_angle
        }
end
return M
