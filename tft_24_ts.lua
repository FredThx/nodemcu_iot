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
--      Add a wire between JP4-TS_IRQ and D1 (you can change it)
--
-- usage :
--  tft_ts = require 'tft_24_ts'
--  tft_cs, tft_dc, ts_cs, ts_irq = 0, 8, 3, 1
--  tft_ts.init(tft_cs, tft_dc, ts_cs, ts_irq, ts_callback) or tft_ts.init() to use default
--      if file calibration.json is not present, do a touch screen calibration
--  tft_ts.on_touch(function(x,y) print(x,y) end)
--  tft_ts.add_button(x,y,h,w,{r,b,v},callback)
--
--  and all ucg functions :
--  tft_tc.disp:setColor(255,0,0)
--  tft_tc.disp:clearScreen()
--  tft_tc.disp:drawDisc(x,y,5, ucg.DRAW_ALL)
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
-- Boutons :    - passez les arguments comme table (avec arguments facultatifs
--              - ajout text (et font et couleur text)
--              - changer apparence quand click
--              - Intégration dans le projet nodemcu_iot
--                  - creation de bouton via mqtt msg
--                  - button => mqtt "PUSH"
--                  - mqtt => zone de text

local M = {}
do
    --default values
    local TFT_CS = 0
    local TFT_DC =  8
    local TS_CS = 3
    local TS_IRQ = 1

    function M.init(tft_cs, tft_dc, ts_cs, ts_irq, ts_callback)
        tft_cs = tft_cs or TFT_CS
        tft_dc = tft_dc or TFT_DC
        ts_cs = ts_cs or TS_CS
        ts_irq = ts_irq or TS_IRQ
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
        M.disp:clearScreen()
        --INIT TS
        xpt2046.init(ts_cs, ts_irq, M.disp:getHeight(), M.disp:getWidth()) -- height and width inverted
        gpio.mode(ts_irq,gpio.INT,gpio.PULLUP)
        local calibration = false
        if file.open("calibration.json","r") then
            local r
            r,calibration = pcall(function()
                            return sjson.decode(file.read())
                        end)
        end
        if  not calibration then
            -- CALIBRATION
            M.disp:clearScreen()
            tft_ts.disp:drawString(40,160,0,"Calibration...")
            local x0, y0, x1, y1 = 10, 10, 230, 310
            local get_raw_cal = function(x,y)
                M.disp:setColor(255,255,255)
                M.disp:drawVLine(x,y-10,20)
                M.disp:drawHLine(x-10,y,20)
                while not xpt2046.isTouched() do
                    tmr.delay(100)
                end
                M.disp:setColor(0,0,0)
                M.disp:drawVLine(x,y-10,20)
                M.disp:drawHLine(x-10,y,20)
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
        gpio.trig(ts_irq, "down", function()
                local x,y = xpt2046.getPosition()
                if xpt2046.isTouched() then
                    -- Callback "on_touch"
                    if M.ts_callback then
                        pcall(M.ts_callback, x,y)
                    end
                    -- Buttons
                    for i, button in ipairs(M.buttons) do
                        if x > button.x and x < (button.x + buton.w)
                                and y > button.y and y < (button.y + button.h) then
                            pcall(button.callback)
                        end
                    end
                end
            end)
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
    end

    function M.add_button(button)
      -- button={
      --        x=x,
      --        y=y,
      --        h=h,
      --        w=w,
      --        color={r,g,b},
      --        text_color{r,g,b}
      --        text = text,
      --        callback = function(x,y) ... end}
      M.set_default(button, {x=0,y=0,h=20,w=200, color = {0,0,255}, text_color = {255,255,255}})
      table.insert(M.buttons, button)
        M.disp:setColor(unpack(button.color))
        M.disp:drawRBox(button.x,button.y,button.w,button.h,5)
        M.disp:setFont(ucg.font_helvB10_hr)
        M.disp:setColor(unpack(button.text_color))
        M.disp:drawString(button.x+5,button.y+button.h-5,0,button.text)
    end

    function M.add_text(text)
      -- test = {
      --  x=x,
      --  y=y,
      --  color = {r,g,b}
      --  text = text
      -- font = font
      -- dir = direction (One of the values 0 (left to right), 1 (top down), 2 (right left) or 3 (bottom up))
      --  }
      M.set_default(text, {x=0,y=12,color = {255,255,255}, font = ucg.font_helvB12_hr, dir = 0})
      M.disp:setColor(unpack(text.color))
      M.disp:setFont(ucg.font_helvB10_hr)
      M.disp:drawString(text.x,text.y,text.dir,text.text)
   end

end
return M
