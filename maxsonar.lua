-- MaxSonar module
-- for pwm mode
-- usage :
--  maxsonar = dofile('maxsonar.lua') or lc if compile
--  val = maxsonar.read(pin, err, retrys)
-- err : precision in pourcent (ex : 0.01 for 1%) - optional
-- retrys : nb of bad result before send false (ex : 10) optional
-- pin : pwm output of the sensor

-- MAIS en fait ça ne fonctionne PAS!!!
-- LUA n'est pas assez rapide pour lire le capteur.
-- plus simple : lire la sortie analogie du capteur en passant par un mcp3008

local M
do 

    local function read_distance(pin,err,retrys)
        if err == nil then err = 0.05 end
        if retrys == nil then retrys = 10 end
        local distance
        local variance
        repeat
        -- Read sensor until standard deviation < err
            local now
            local distances = {}
            local i
            local duty
            if nb == nil then nb = 8 end
            for i=1,nb do
                --Acces to sensor on pwm mode
                gpio.mode(pin,gpio.INPUT )
                while (gpio.read(pin)==gpio.HIGH) do
                    tmr.delay(1) -- pour éviter plantage!!!
                end
                while (gpio.read(pin)==gpio.LOW) do
                    tmr.delay(1) -- pour éviter plantage!!!
                end
                now = tmr.now()
                while (gpio.read(pin)==gpio.HIGH) do
                    tmr.delay(1) -- pour éviter plantage!!!
                end
                -- Note 1µs = 1mm
                duty = tmr.now()-now
                table.insert(distances, duty)
            end
            -- Calculate the average of distances
            distance = 0
            for i, d in pairs(distances) do
                print(d)
                distance = distance + d
            end
            distance = distance / nb
            -- calculate the (standard deiation)^2
            variance = 0
            for i, d in pairs(distances) do
                variance = variance + (distance - d)^2
            end
            retrys = retrys -1
        until (retrys < 1 or (variance^0.5)/distance<err)
        if (variance^0.5)/distance<err then 
            return distance
        else 
            return false
        end
    end
    
    M= {read = read_distance}
    
end

return M