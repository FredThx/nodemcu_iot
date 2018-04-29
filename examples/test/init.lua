

d = require "vl6180x"

d.init(5,6,0x29)

tmr.create():alarm(500,tmr.ALARM_AUTO , function()
    print(d.distance())
end)

