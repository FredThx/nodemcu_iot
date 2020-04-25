-- LPS35HW (ST water resistant pressure sensor)
--      in i2c mode
-- 
-- usage:
--  sensor = require('LPS35HW')
--  sensor.init(sda_pin, scl_pin, [addr = 0x5D], [i2c_id=0])
--  pression_hPa = sensor.read_pressure()
--  temperature_C = sensor.read_temperature()
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    gpio
--    i2c
-------------------------------------------------

local M
do
    -- Default values
    local ID = 0
    local SDA
    local SCL
    local ADDR = 0x5D
    -- Constantes
    -- local PRESS_OUT_H = 0x2A
    -- local PRESS_OUT_L = 0x29
    local PRESS_OUT_XL = 0x28
    local TEMP_OUT_L = 0x2B
    --local TEMP_OUT_H = 0x2C
    local FIFO_CTRL = 0x14
    local CTRL_REG1 = 0x10
    local CTRL_REG2 = 0x11


    -- Init
    local init = function(sda_pin, scl_pin, addr, id)
      -- Init i2c
      ID = id or ID
      SDA = sda_pin
      SCL = scl_pin
      ADDR = addr or ADDR
      i2c.setup(ID, SDA, SCL, i2c.SLOW)
      write_reg(FIFO_CTRL, 0x00)
      write_reg(CTRL_REG1, 0x10)

    end

    -- user defined function: read 1 byte of data from device
    function read_reg(reg_addr, n)
        n = n or 1
        i2c.start(ID)
        i2c.address(ID, ADDR, i2c.TRANSMITTER)
        i2c.write(ID, reg_addr)
        i2c.stop(ID)
        i2c.start(ID)
        i2c.address(ID, ADDR, i2c.RECEIVER)
        c = i2c.read(ID, n)
        i2c.stop(ID)
        return c
    end

    function write_reg(reg_addr, data)
        i2c.start(ID)
        i2c.address(ID, ADDR, i2c.TRANSMITTER)
        i2c.write(ID, reg_addr)
        c = i2c.write(ID, data)
        i2c.stop(ID)
        return c
    end

    function read_pressure()
        write_reg(CTRL_REG2, 0x11)
        local press_xl, press_l, press_h  = string.byte(read_reg(PRESS_OUT_XL,3),1,3)
        local pressure_lbs = press_h * 256 * 256 + press_l * 256 + press_xl
        return pressure_lbs / 4096
    end

    function read_temperature()
        write_reg(CTRL_REG2, 0x11)
        local temp_l, temp_h =  string.byte(read_reg(TEMP_OUT_L,2),1,2)
        return (temp_h * 256 + temp_l) / 100
    end

    M =  {
            read_pressure = read_pressure,
            read_temperature = read_temperature,
            init = init,
        }
end
return M
