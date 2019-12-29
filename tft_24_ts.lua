-- TFT 2.4 module
--
-- Tested on the WEMOS (LOLIN) TFT 2.4 Touch Shield V1.0.0:
--          2.4” diagonal LCD TFT display
--          320×240 pixels
--          TFT Driver IC: ILI9341
--          Touch Screen controller IC: XPT2046
--
-- Wiring :
--      plug the WEMOS D1 mini or Di mini Pro on JP2 + JP3
--              Hardware SPI CLK  = GPIO14 = D5
--              Hardware SPI MOSI = GPIO13 = D7
--              Hardware SPI MISO = GPIO12 = D6 (not used)
--              Hardware SPI /CS  = GPIO15 = D8 (not used)
--              TFT_CS = D0 (you can change it expept on WEMOS SHIELD)
--              TFT_DC = D8 (you can change it expept on WEMOS SHIELD)
--              TS_CS = D3 (you can change it)
--              TS_LED = D4 (you must set it with welding)
--      Add a wire between JP4-TS_IRQ and D1 (you can change it)
--
-- usage :
--  tft_ts = require 'tft_24_ts'
--  tft_cs, tft_dc, ts_cs, ts_irq = 0, 8, 3, 1
--  tft_ts.init(tft_cs, tft_dc, ts_cs, ts_irq, ts_callback, ts_angle) or tft_ts.init() to use default
--      ts_angle = 0 or nil | 90 | 180 | 270
--      if file calibration.json is not present, do a touch screen calibration
--  tft_ts.init = nil --freememory
--  tft.ts.free()  -- better free memory (after all objects are created)
--  tft_ts.on_touch(function(x,y) print(x,y) end)
--  tft_ts.add_button(x,y,h,w,{r,b,v},callback)
--
--  and all ucg functions :
--  tft_ts.disp:setColor(255,0,0)
--  tft_ts.disp:clearScreen()
--  tft_ts.disp:drawDisc(x,y,5, ucg.DRAW_ALL)
--     (...)
--  tft_ts.disp:setFont(...)
--  Liste des FONTS disponibles :
--      ucg.font_7x13B_tr
--      ucg.font_helvB08_hr
--      ucg.font_helvB10_hr
--      ucg.font_helvB12_hr
--      ucg.font_helvB18_hr
--      ucg.font_ncenB24_tr
--      tft_ts.disp:setFont(ucg.font_ncenR12_tr)
--      ucg.font_ncenR14_hr
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    gpio,tmr
--    spi, ucg (with ili9341_18x240x320_hw_spi), xpt2046
-------------------------------------------------

--TODO
--    - changer apparence quand click bouton (gestion push down / up)


local M = {}
do
    --default values
    local TFT_CS = 0
    local TFT_DC =  8
    local TS_CS = 3
    local TS_IRQ = 1
    local TS_LED = 4

    function M.init(tft_cs, tft_dc, ts_cs, ts_irq, ts_led, ts_callback, ts_angle)
        tft_cs = tft_cs or TFT_CS
        tft_dc = tft_dc or TFT_DC
        ts_cs = ts_cs or TS_CS
        ts_irq = ts_irq or TS_IRQ
        M.ts_led = ts_led or TS_LED
        M.ts_angle = ts_angle
        local bus = 1
        local tft_res = nil
        M.ts_callback = ts_callback
        -- Init SPI
        spi.setup(bus, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 16, spi.FULLDUPLEX)
        -- INIT DISP
        gpio.mode(tft_cs, gpio.INPUT, gpio.PULLUP)
        M.disp = ucg.ili9341_18x240x320_hw_spi(bus, tft_cs, tft_dc, tft_res)
        M.disp:begin(ucg.FONT_MODE_TRANSPARENT)
        tft_ts.disp:setFont(ucg.font_ncenR12_tr)
        if M.ts_angle == 90 then M.disp:setRotate90()
        elseif M.ts_angle == 180 then M.disp:setRotate180()
        elseif M.ts_angle == 270 then M.disp:setRotate270()
        end
        M.disp:clearScreen()
        --INIT TS
        if M.ts_angle == 90 or M.ts_angle == 270 then
            xpt2046.init(ts_cs, ts_irq, M.disp:getWidth(), M.disp:getHeight())
        else
            xpt2046.init(ts_cs, ts_irq, M.disp:getHeight(), M.disp:getWidth())
        end
        gpio.mode(ts_irq,gpio.INT,gpio.PULLUP)
        -- INIT TS_LED
        gpio.mode(M.ts_led, gpio.OUTPUT)
        gpio.write(M.ts_led, gpio.HIGH)
        -- CALIBRATION
        local calibration = false
        if file.open("calibration.json","r") then
            local r
            r,calibration = pcall(function()
                            return sjson.decode(file.read())
                        end)
        end
        if  not calibration then
            M.disp:clearScreen()
            tft_ts.disp:drawString(40,160,0,"Calibration...")
            local x0, y0, x1, y1 = 10, 10,M.disp:getWidth() - 10, M.disp:getHeight()-10
            local get_raw_cal = function(x,y)
                M.disp:setColor(255,255,255)
                M.disp:drawVLine(x,y-10,20)
                M.disp:drawHLine(x-10,y,20)
                while not xpt2046.isTouched() do
                    tmr.delay(100)
                end
                M.disp:setColor(0,0,0)
                M.disp:drawLine(x,y-10,x,y+10)
                M.disp:drawLine(x-10,y,x+10,y)
                --M.disp:drawVLine(x,y-10,20)
                --M.disp:drawHLine(x-10,y,20)
                M.disp:setColor(255,255,255)
                tmr.delay(100)
                local rx, ry = xpt2046.getRaw()
                while xpt2046.isTouched() do
                    tmr.delay(100)
                end
                return rx,ry
            end
            local rx0, ry0 = get_raw_cal(x0,y0)
            local rx1, ry1 = get_raw_cal(x1,y1)
            calibration= {
                        rx0 - math.floor(x0*(rx1-rx0)/(x1-x0)),
                        ry0 - math.floor(y0*(ry1-ry0)/(y1-y0)),
                        rx1 + math.floor(x0*(rx1-rx0)/(x1-x0)),
                        ry1 + math.floor(y0*(ry1-ry0)/(y1-y0))}
            print(sjson.encode(calibration))
            file.open("calibration.json","w")
            file.write(sjson.encode(calibration)..'\n')
            file.close()
            M.disp:clearScreen()
        end
        xpt2046.setCalibration(unpack(calibration))
        M.buttons = {}
        M.variables = {}
        -- Economiseur d'écran
        M.timer = tmr.create()
        M.init_screen_saver(300000)
        -- Touch down!
        gpio.trig(ts_irq, "down", function()
                if not M.init_screen_saver(300000) then
                  local x,y = M.getPosition()
                  if xpt2046.isTouched() then
                      -- Callback "on_touch"
                      if M.ts_callback then
                          pcall(M.ts_callback, x,y)
                      end
                      -- Buttons
                      for i, button in ipairs(M.buttons) do
                          if x > button.x and x < (button.x + button.w)
                                  and y > button.y and y < (button.y + button.h) then
                              pcall(button.callback)
                          end
                      end
                  end
               end
            end)
    end

    function M.init_screen_saver(duration)
      -- init the screen saver
      -- if needed, Wake up the screen and return true
      M.timer:alarm(duration, tmr.ALARM_SINGLE, function()
            gpio.write(M.ts_led, gpio.LOW)
        end)
      if gpio.read(M.ts_led)==gpio.LOW then -- if sreen saver ..
        gpio.write(M.ts_led, gpio.HIGH)
        return true
      end
    end

    function M.getPosition()
        local x,y = xpt2046.getPosition()
        if M.ts_angle == 90 or M.ts_angle == 270 then
            return y,x
        else
            return x,y
        end
        return
    end


    function M.on_touch(ts_callback)
        M.ts_callback = ts_callback
    end

    function M.set_default(t,t_def)
        for key, val in pairs(t_def) do
          if not t[key] then
            t[key] = val
          end
        end
        if type(t.font)== "string" then
            t.font = ucg[t.font]
        end
    end

    function M.add_button(param)
      -- param={
      --        x=x,
      --        y=y,
      --        h=h,
      --        w=w,
      --        color={r,g,b},
      --        text_color{r,g,b}
      --        text = text, font = ucg.font_..,
      --        callback = function(x,y) ... end}
      M.set_default(param, {x=0,y=0,h=20,w=200})
      M.disp:setColor(unpack(param.color or {0,0,255}))
      M.disp:drawRBox(param.x,param.y,param.w,param.h,5)
      M.disp:setFont(param.font or ucg.font_helvB10_hr)
      M.disp:setColor(unpack(param.text_color or {255,255,255}))
      local offset_x = (param.w - M.disp:getStrWidth(param.text))/2
      local offset_y = (param.h + M.disp:getFontAscent())/2
      M.disp:drawString(param.x+offset_x,param.y+offset_y,0,param.text)
      table.insert(M.buttons, param)
    end

    function M.add_label(param)
      -- param = {
      --  x=x ,y=y,
      --  color = {r,g,b},
      -- back_color = {r,g,b},
      --  text = text,
      --  variable = "maVar", size = pixels, format = "%04d"
      -- font = font,
      -- dir = direction (One of the values 0 (left to right), 1 (top down), 2 (right left) or 3 (bottom up))
      --
      --  }
      M.set_default(param, {x=0,y=12})
      if param.variable then
        local variable = param.variable
        param.variable = nil
        M.variables[variable]= param
        param.back_color = param.back_color or {0,0,0}
      end
      M.draw_label(param)
    end

    function M.draw_label(param)
        if param.format and param.text then param.text = string.format(param.format, tonumber(param.text) or 0)  end
        M.disp:setFont(param.font or ucg.font_helvB12_hr)
        if param.back_color then -- FONT_MODE_SOLID don't work with all fonts!
            M.disp:setColor(unpack(param.back_color))
            M.disp:drawBox(param.x  ,
                          param.y - 1 - M.disp:getFontAscent(),
                         param.size or M.disp:getStrWidth(param.text or " "),
                          M.disp:getFontAscent() - M.disp:getFontDescent(),5)
        end
        M.disp:setColor(unpack(param.color or {255,255,255}))
        M.disp:drawString(param.x,param.y,param.dir or 0,param.text or "")
    end

    function M.set_label(variable, text)
        if M.variables[variable] then
            M.variables[variable].text = text
            M.draw_label(M.variables[variable])
        end
    end

    function M.free()
        --Use this when all button and label are set : 1900 bytes free
        M.init = nil
        M.add_button = nil
        M.add_label = nil
        M.set_default = nil
        M.on_touch = nil
        M.free = nil
    end

end
return M
