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
--  mcp.init(spi_no) or mcp.init() spi_no = 1 
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


local M
do
    --defaults
    local SPI_NO = 1

    local init_MCP3201 = function(spi_no)
        SPI_NO = spi_no or SPI_NO
        -- Spi Init
        spi.setup(SPI_NO,spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW,8,8)
        print_log("MCP3102 initialised on spi no " .. SPI_NO)
    end
    
    -- Function to read MCP3201
    local read_MCP3201 = function ()
        local value = spi.recv(1,2) -- lecture de deux octets
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
