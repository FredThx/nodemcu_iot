-- MCP3008 module
--
-- usage :
--  mcp = dofile('mcp3008.lua")
--  mcp.init(6,7,5,8) or mcp.init() to use default
--  chanel = 1 -- (0-7)
--  val = mcp.read(chanel)
--
local M
do
    --default SPI pins
    local MISO = 6           --> GPIO12
    local MOSI =  7         --> GPIO13
    local CLK = 5            --> GPIO14
    local CS = 8              --> GPIO15

    local init_MCP3008 = function(miso, mosi, clk, cs)
        MISO = miso or MISO
        MOSI = mosi or MOSI
        CLK = clk or CLK
        CS = cs or CS
        -- Pin Initialization
        gpio.mode(CS, gpio.OUTPUT)
        gpio.mode(CLK, gpio.OUTPUT)
        gpio.mode(MOSI, gpio.OUTPUT)
        gpio.mode(MISO, gpio.INPUT)
        print("MCP3008 initialised with SPI configuration :")
        print("    MISO : ".. MISO)
        print("    MOSI : ".. MOSI)
        print("    CLK : ".. CLK)
        print("    CS : ".. CS)
    end
    
    -- Function to read MCP3008
    local read_MCP3008 = function (adc_ch)
       if adc_ch >=0 and adc_ch < 8 then
          -- MCP3008 has eight channels 0-7
    
          gpio.write(CS,gpio.HIGH)
           tmr.delay(5)  
            
           gpio.write(CLK, gpio.LOW)  
              gpio.write(CS, gpio.LOW)      -->Activate the chip 
           tmr.delay(1)                  -->1us Delay
          
           commandout = adc_ch
           commandout=bit.bor(commandout, 0x18) 
            commandout=bit.lshift(commandout, 3)
            for i=1,5 do
              if bit.band(commandout,0x80) >0 then
                   gpio.write(MOSI, gpio.HIGH)    
              else   
                   gpio.write(MOSI, gpio.LOW) 
               end   
                commandout=bit.lshift(commandout,1)
                
                gpio.write(CLK, gpio.HIGH)
                tmr.delay(1)
                gpio.write(CLK, gpio.LOW)
                tmr.delay(1)       
          end
          adcout = 0
          for i=1,12 do
                gpio.write(CLK, gpio.HIGH)
                tmr.delay(1)  
                gpio.write(CLK, gpio.LOW)
                tmr.delay(1)  
                 adcout = bit.lshift(adcout,1);
                 if gpio.read(MISO)>0 then
                     adcout = bit.bor(adcout, 0x1)
                end
            end 
            gpio.write(CS, gpio.HIGH)
            adcout = bit.rshift(adcout,1)     
            return adcout
         else 
            return -1
         end
    end
    M =  {
            read = read_MCP3008,
            init = init_MCP3008
        }
end
return M