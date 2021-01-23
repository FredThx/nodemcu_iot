-- DF6-V (OMRON Flow Sensor)
--      
-- Wiring :
--      DF6-V     ESP32
--      Vin         3.3V
--      0V          0V
--      OUT         A0
--
-- usage:
--  sensor = require('DF6_V')
--  flow = sensor.read()
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    adc
-------------------------------------------------

local M
do

    local TAB_FLOW = {
            {v=0.5,flow =0},
            {v=0.7, flow = 0.75},
            {v=1.11, flow = 1.5},
            {v=1.58, flow = 2.25},
            {v=2, flow =3}}
    
    
    function read()
        tension = adc.read(0) * 3.3 / 1023
        for k, range in ipairs(TAB_FLOW) do
            if tension < range.v then
                if k == 1 then
                    return TAB_FLOW[k].flow
                else
                    range0 = TAB_FLOW[k-1]
                    return range0.flow + (tension - range0.v) * (range.flow - range0.flow) / (range.v - range0.v)
                end
            end
        end
        return TAB_FLOW[#TAB_FLOW].flow
    end
    
    M = {
        read = read
    }

end
return M