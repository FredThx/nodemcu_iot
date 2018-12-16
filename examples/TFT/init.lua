tft_ts = require 'tft_24_ts'

tft_ts.init()

--tft_ts.on_touch(function(x,y)
--        print(x,y)
--        tft_ts.disp:drawDisc(x,y,5, ucg.DRAW_ALL)
--        end
--    )

--tft_ts.disp:drawDisc(50,50,5, ucg.DRAW_ALL)

--tft_ts.disp:clearScreen()

print(node.heap())
tft_ts.add_button({x=50,y=200,h=20,w=50,text="Ok", callback=function() print("hello2") end})

tft_ts.add_label({y=50,font = ucg.font_7x13B_tr, text="ucg.font_7x13B_tr",back_color = {100,25,10}})
tft_ts.add_label({y=100,font = ucg.font_helvB10_hr, text="ucg.font_helvB10_hr",back_color = {100,25,10}})
tft_ts.add_label({y=150,font = ucg.font_helvB12_hr,back_color = {100,25,10}, variable = 'time', format = "%4d", size = 50})
tft_ts.add_label({y=200,font = ucg.font_helvB18_hr, text="ucg.font_helvB18_hr",back_color = {100,25,10}})
tft_ts.add_label({y=250,font = ucg.font_ncenB24_tr, text="ucg.font_ncenB24_tr",back_color = {100,25,10}})


tmr.create():alarm(1000, tmr.ALARM_AUTO, function() tft_ts.set_label('time',tmr.time()) end)

print(node.heap())