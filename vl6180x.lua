-- VL6160X Time-of-Flight Distance Sensor Carrier
--
-- usage:
--  distance_sensor = require 'vl6180x'
--  distance_sensor.init(sda_pin, scl_pin [,i2c_addr])
--  distance = distance_sensor.distance(addr)
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    gpio,tmr
--    bit, i2c
-------------------------------------------------

local M = {}

do
    local addr_default = 0x29 -- i2c
    local addr
    --local timeout = 500
    local id = 0 -- i2c bus 
    
    -- Read a register addressed with  a 2 bytes address (reg)
    --      n_bytes : number of lenght in bytes of the register readed (default : 1 = 8bits)
    local function read_reg(reg, n_bytes)
        n_bytes = n_bytes or 1
        i2c.start(id)
        local val = 0
        if i2c.address(id, addr, i2c.TRANSMITTER) then
            i2c.write(id, bit.band(bit.arshift(reg,8), 0xff)) --write High byte reg
            i2c.write(id, bit.band(reg, 0xff)) -- write Low byte reg
            i2c.stop(id)
            i2c.start(id)
            i2c.address(id, addr, i2c.RECEIVER)
            local str_val = i2c.read(id, n_bytes) -- read n_bytes bytes
            -- Transforme string to a number
            while n_bytes > 0 do
                val = bit.bor(val,bit.lshift(string.byte(str_val, n_bytes),(n_bytes-1)*8))
                n_bytes = n_bytes - 1
            end --
        else --
            print('Connection Error device not found on ic2 bus.')
        end --
        i2c.stop(id) --
        return val --
    end
    -- Write cmd in a register addressed with  a 2 bytes address (reg)
    --    n_bytes : number of lenght in bytes of datas to write (default : 1 = 8bits)
    local function write_reg(reg, cmd, n_bytes)
        n_bytes = n_bytes or 1
        i2c.start(id)
        if i2c.address(id, addr, i2c.TRANSMITTER) then
            i2c.write(id, bit.band(bit.arshift(reg,8), 0xff))
            i2c.write(id, bit.band(reg, 0xff))
            while n_bytes > 0 do --
                i2c.write(id, bit.band(bit.arshift(cmd, (n_bytes-1) * 8)))
                n_bytes = n_bytes - 1 --
            end
        else
            print("Connection Error device not found on ic2 bus.") 
        end
        i2c.stop(id)
    end
    
    
    local function init(sda, scl, _addr)
        addr = _addr or addr_default
        -- Init I2C
        i2c.setup(id,sda, scl, i2c.SLOW)
        -- Init VL6160X
        if read_reg(0x016)== 1 then
            write_reg(0x207, 0x01) -- SYSTEM__FRESH_OUT_OF_RESET
            write_reg(0x208, 0x01)
            write_reg(0x096, 0x00)
            write_reg(0x097, 0xfd)-- RANGE_SCALER = 253
            write_reg(0x0E3, 0x00)
            write_reg(0x0E4, 0x04)
            write_reg(0x0E5, 0x02)
            write_reg(0x0E6, 0x01)
            write_reg(0x0E7, 0x03)
            write_reg(0x0F5, 0x02)
            write_reg(0x0D9, 0x05)
            write_reg(0x0DB, 0xCE)
            write_reg(0x0DC, 0x03)
            write_reg(0x0DD, 0xF8)
            write_reg(0x09F, 0x00)
            write_reg(0x0A3, 0x3C)
            write_reg(0x0B7, 0x00)
            write_reg(0x0BB, 0x3C)
            write_reg(0x0B2, 0x09)
            write_reg(0x0CA, 0x09)
            write_reg(0x198, 0x01)
            write_reg(0x1B0, 0x17)
            write_reg(0x1AD, 0x00)
            write_reg(0x0FF, 0x05)
            write_reg(0x100, 0x05)
            write_reg(0x199, 0x05)
            write_reg(0x1A6, 0x1B)
            write_reg(0x1AC, 0x3E)
            write_reg(0x1A7, 0x1F)
            write_reg(0x030, 0x00)
            
            write_reg(0x016, 0)
        end
        
        write_reg(0x014, 0x24) --SYSTEM__INTERRUPT_CONFIG_GPIO
        write_reg(0x011, 0x10) -- SYSTEM__MODE_GPIO1
        write_reg(0x10A, 0x30) -- READOUT__AVERAGING_SAMPLE_PERIOD : 48
        write_reg(0x03F, 0x46) -- SYSALS__ANALOGUE_GAIN : 1.0 
        write_reg(0x031, 0xff) -- SYSRANGE__VHV_REPEAT_RATE
        write_reg(0x040, 0x63,2) -- SYSALS__INTEGRATION_PERIOD : 100ms
        write_reg(0x02E, 0x01) -- SYSRANGE__VHV_RECALIBRATE
        write_reg(0x01B, 0x09) --SYSRANGE__INTERMEASUREMENT_PERIOD
        write_reg(0x03E, 0x0A) --SYSALS__INTERMEASUREMENT_PERIOD
        
        write_reg(0x01C, 0x32) -- SYSRANGE__MAX_CONVERGENCE_TIME        
        write_reg(0x02D, 0x11) -- SYSRANGE__RANGE_CHECK_ENABLES
        write_reg(0x022, 0x78,2) -- SYSRANGE__EARLY_CONVERGENCE_ESTIMATE
        write_reg(0x10A, 0x30) -- READOUT__AVERAGING_SAMPLE_PERIOD
        write_reg(0x03F, 0x40) -- SYSALS__ANALOGUE_GAIN
        write_reg(0x120, 0x01) -- FIRMWARE__RESULT_SCALER
    end

    -- Read the distance. Result in mm
    local function read_distance()
        write_reg(0x18,0x01) -- SYSRANGE__START
        while not bit.isset(read_reg(0x04f),2) do -- RESULT__INTERRUPT_STATUS_GPIO
        end
        range = read_reg(0x62) -- RESULT__RANGE_VAL
        write_reg(0x15,0x07) -- SYSTEM__INTERRUPT_CLEAR
        return range
    end
    
    M.distance = read_distance
    M.init = init
end
return M
