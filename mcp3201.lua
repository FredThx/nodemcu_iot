-- MCP3201 module
--
-- Wiring for spi_no = 1 : 
--         IO index    ESP8266 pin
-- HSPI CLK    5   GPIO14
-- HSPI /CS    8   GPIO15
-- HSPI MISO   6   GPIO12
--
-- usage :
--  mcp3201 = dofile('mcp3201.lua')
--  mcp.init(spi_no, cs_pin) or mcp.init() spi_no = 1, cs_pin = 8
--  mcp.init = nil -- to free memory
--  val = mcp.read() n -- return a float between 0 and 1
--                        0 : 0V
--                        1 : Vref
-- Notes :
-- Durée de la mesure : 2500 µs
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    gpio,tmr
--    bit, spi
-------------------------------------------------
--local hexToBin_lut={ ["0"]="0000", ["1"]="0001", ["2"]="0010", ["3"]="0011", ["4"]="0100", ["5"]="0101", ["6"]="0110", ["7"]="0111", ["8"]="1000", ["9"]="1001", ["a"]="1010", ["b"]="1011", ["c"]="1100", ["d"]="1101", ["e"]="1110", ["f"]="1111", }

--local function toBinary(num) 
--  return string.format("%x",num):gsub(".",function(v) return hexToBin_lut[v] end):match("^[0]*(%d*)$")
--end

local M
do
    --defaults
    local SPI_NO = 1
    local CS_PIN = 8

    local init_MCP3201 = function(spi_no, cs_pin)
        SPI_NO = spi_no or SPI_NO
        CS_PIN = cs_pin or CS_PIN
        -- Spi Init
        spi.setup(SPI_NO,spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW,8,8)
        gpio.mode(CS_PIN, gpio.OUTPUT)
        print_log("MCP3102 initialised on spi no " .. SPI_NO)
    end
    
    -- Function to read MCP3201
    local read_MCP3201 = function ()
        gpio.write(CS_PIN,gpio.LOW)
        local value = spi.recv(SPI_NO,2) -- lecture de deux octets
        gpio.write(CS_PIN,gpio.HIGH)
        ---print(toBinary(string.byte(value,1)),toBinary(string.byte(value,2)))
        value = 256 * string.byte(value,1) + string.byte(value,2)
        --Supression des 3 premier bits
        value = bit.clear(value,15,14,13)
        --Supression (decalage) du dernier bit
        value = bit.arshift(value, 1)
        value = value / 4096
        return value
    end
    M =  {
            read = read_MCP3201,
            init = init_MCP3201
        }
end
return M
