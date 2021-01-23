Servo = require('servo')

S1=Servo(5,500)

S2=Servo(6,500)

S3=Servo(7,500)

S4=Servo(8,500)

ordres = {
    {servo=S1, angle=150},
    {servo=S1, angle=0}, 
    {servo=S1, angle=25}, 
    {servo=S2, angle=150},
    {servo=S2, angle=0}, 
    {servo=S2, angle=25}, 
    {servo=S3, angle=0},
    {servo=S3, angle=150}, 
    {servo=S3, angle=120}, 
    {servo=S4, angle=0},
    {servo=S4, angle=150}, 
    {servo=S4, angle=120}, 
    
}

--index = 1
--a=tmr.create()
--a:alarm(1500,tmr.ALARM_AUTO, function()
--    ordres[index].servo:set_angle(ordres[index].angle)
--    index = index + 1
--    if index > 12 then index = 1 end
--    end)
    