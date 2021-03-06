-- servomotor module
--
-- usage :
--  Servo = require('servo')
--  servo_1 = Servo(5, 1000) -- pin = 5, auto stop after 1000 milliseconds (factultatif)
--  servo_1:start()
--  servo_1:set_angle(angle) angle entre 0 et 156
-- servo_1:set_angle(angle, callback) -- callback is called after the timeout (auto-stop)
--  servo_1:stop()
-- memory usage : 3248 octets (if compiled)
--                + 304 octets per instance

local Servo = {}
Servo.__index = Servo

setmetatable(Servo, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Servo.new(pin, timer_stop, offset)
  print("Create new Servo with pin = " .. pin)
  local self = setmetatable({}, Servo)
  self.pin = pin
  self.offset = offset or 0
  pwm.setup(pin,50,25)
  if timer_stop then
    self.timer_stop = timer_stop
    self.alarm = tmr.create()
  end
  return self
end

function Servo:start()
    pwm.start(self.pin)
end

function Servo:stop()
    pwm.stop(self.pin)
end

function Servo:set_angle(angle, callback)
    local angle0 = self.offset+angle
    if angle0 >= 0 and angle0 <= 200 then
        pwm.setduty(self.pin, 25+(angle0)*5/9)
    end
    if self.alarm then
      self.alarm:alarm(self.timer_stop, tmr.ALARM_SINGLE, function()
          self:stop()
          if callback then callback() end
        end)
    end
end

return Servo
