i2c.setup(0, pin_sda, pin_scl, i2c.SLOW)
lcd = dofile("lcd1602.lua")()

disp_clear = lcd.clear

function disp_add_data(data)
    local t_data=cjson.decode(data)
    if t_data.clear then lcd.clear() end
    if t_data.led~=nil then lcd.light(t_data.led) end
    if t_data.text~=nil then
        if not t_data.column then t_data.column = 0 end
        if not t_data.row then t_data.row = 0 end
        lcd.put(lcd.locate( t_data.row, t_data.column), ""..t_data.text)
    end
end
