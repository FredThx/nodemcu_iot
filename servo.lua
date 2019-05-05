-- servomotor module
--
-- usage :
--  Servo = require('servo_')
--  servo_1 = Servo(5) -- pin = 5
--  servo_1:start()
--  servo_1:set_angle(angle) angle entre 0 et 156
--  servo_1:stop()
-- memoty usage : 2408 octets

local Servo = {}
Servo.__index = Servo

setmetatable(Servo, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Servo.new(pin)
  print("Create new Servo with pin = " .. pin)
  local self = setmetatable({}, Servo)
  self.pin = pin
  pwm.setup(pin,50,25)
  return self
end

function Servo:start()
    pwm.start(self.pin)
end

function Servo:stop()
    pwm.stop(self.pin)
end

function Servo:set_angle(angle)
    if angle >= 0 and angle <= 200 then
        pwm.setduty(self.pin, 25+angle*5/9)
    end
end

return Servo
