-- MCP9803 module
--
-- usage:
--  mcp9803 = dofile('mcp9803.lua')
--  mcp9803.init(sda_pin, scl_pin,resol)
--  temperature = mcp9803.read(addr)
--

local M
do

        --I2C init
    local id = 0
    local res05 = 0x00
    local res025 = 0x20
    local res0125 = 0x40
    local res00625 = 0x60

    local resolution
    local init_i2c = function(sda, scl,resol)
        i2c.setup(id,sda, scl, i2c.SLOW)        

        resolution = resol       
        i2c.start(id)
        i2c.address(id, 0x48, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)
        
        i2c.start(id)
        i2c.address(id, 0x49, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)

        i2c.start(id)
        i2c.address(id, 0x4A, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)

        i2c.start(id)
        i2c.address(id, 0x4B, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)

        i2c.start(id)
        i2c.address(id, 0x4C, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)

        i2c.start(id)
        i2c.address(id, 0x4D, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)

        i2c.start(id)
        i2c.address(id, 0x4E, i2c.TRANSMITTER)
        i2c.write(id, 0x01,resol)
        i2c.stop(id)
    end
    
    -- Function to read temperature
    local read_temp = function(addr)
    
        local temp = read_reg(addr, 0x00)
        temp = 256 * string.byte(temp,1) + string.byte(temp,2)
        if resolution == res025 then
            temp = bit.clear(temp,5,4,3,2,1,0)  
            temp = bit.arshift(temp,6)
            temp = temp * 0.25
        elseif resolution == res0125 then
            temp = bit.clear(temp,4,3,2,1,0)  
            temp = bit.arshift(temp,5)
            temp = temp * 0.125
        elseif resolution == res00625 then
            temp = bit.clear(temp,3,2,1,0)  
            temp = bit.arshift(temp,4)
            temp = temp * 0.0625
        else
            temp = bit.clear(temp,6,5,4,3,2,1,0)  
            temp = bit.arshift(temp,7)
            temp = temp * 0.5
        end
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
            init = init_i2c,
            RES05 = res05,
            RES025 = res025,
            RES0125 = res0125,
            RES00625 = res00625,
        }
end
return M
