-- MCP9804 module
--
-- usage:
--  mcp9804 = dofile('mcp9804.lua')
--  mcp9804.init(sda_pin, scl_pin)
--  temperature = mcp9804.read(addr)
--

local M
do
    
    --I2C init
    local id = 0
    local init_i2c = function(sda, scl)
        i2c.setup(id,sda, scl, i2c.SLOW)
    end
    
    -- Function to read temperature
    local read_temp = function(addr)
    
        local temp = read_reg(addr, 0x05)
        temp = 256 * string.byte(temp,1) + string.byte(temp,2)
        temp = bit.clear(temp,13,14,15)  
        temp = temp * 0.0625
        return temp
    end

    function read_reg(addr, reg)
        local val
        i2c.start(id)
        i2c.address(id, addr, i2c.TRANSMITTER)
        i2c.write(id, reg)
        i2c.stop(id)
        i2c.start(id)
        i2c.address(id, addr, i2c.RECEIVER)
        val = i2c.read(id, 2)
        i2c.stop(id)
        return val
    end
    
    M =  {
            read = read_temp,
            init = init_i2c
        }
end
return M
