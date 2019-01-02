-- MODULE NODEMCU (ESP8266)    + capteur DS1820
-- Language : LUA - Firmware : nodemcu - Auteur : FredThx

--GESTION CAPTEURS DS1820

-- Lecture d'un capteur via function callback
-- Si addr : renvoie la temperature du capteur spécifie
-- Si pas addr : renvoie toutes des temperatures lues (au pif) => util quand un seul capteur de branche
--
-- U

-- DS18b20 module (One Wire)
--
-- Wiring :
--       5V -------------Vcc
--                |
--            [4.7kOhms]
--                |
--               --------- pin (to define with init)
--
--       0V   ------------ GRND
--
-- usage :
--  temps = dofile('ds1820_reader.lua') or .lc if compiled
--  temps.init(pin)
--  temps.read(roms, function(result) print("temp :",result) end)
--     ou roms : 
--              - nil : execute la function à chaque device
--              - "XX:XX:XX:XX:XX:XX:XX:XX" : execute la function si capteur detecte
--              - {"XX:XX:...XX,"YY:YY:...YY" ...} : execute la function si capteurs detectes
-- Notes :
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    
--    ds18b20
-------------------------------------------------

--TODO : regler le probleme de demandes simultanees
--	soit
--			- buffer
--			- timeout
-- soit
--			- lecture de tous les capteurs si mesure il y a plus de xx (5s par ex)
--			- renvoie des valeurs

local M
do

    function read_DS18B20(ask_rom, callback)
            if ask_rom == nil then
                ask_rom={}
            elseif type(ask_rom)~="table" then
                ask_rom = {ask_rom}
            end
            ds18b20.read(function(ind,rom,res,temp,tdec,par)
                    print(string.format(
                        "%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X",
                        string.match(rom,"(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)"))
                        .." => "..temp)
					if temp < 85 and callback then
						callback(temp)
					end
                end,ask_rom)
    end
    
    M =  {
            read = read_DS18B20,
            init = ds18b20.setup,
            --pipe = {}
        }    
end
return M
