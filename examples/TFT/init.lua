tft_ts = require 'tft_24_ts'

tft_ts.init()

--tft_ts.on_touch(function(x,y)
--        print(x,y)
--        tft_ts.disp:drawDisc(x,y,5, ucg.DRAW_ALL)
--        end
--    )

--tft_ts.disp:drawDisc(50,50,5, ucg.DRAW_ALL)

--tft_ts.disp:clearScreen()

tft_ts.add_button({x=50,y=200,h=20,w=50,text="Ok", callback=function() print("hello2") end})
tft_ts.add_text({text="Salut ma Poule"})
