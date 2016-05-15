-- POUR piloter prises Radio Frequence 433Mhz
--
--  Matériel : un emetteur 433 Mhz sur PIN_433
--             un bouton poussoir sur PIN_BT
--             prise pilotables :
--                      groupePrises
--                      priseA
-- (voir parames.lua)

-- Constantes
pulseLenght = 300
nb_repeat = 10
on = "10"
off = "01"

-- Initialisation
gpio.mode(PIN_433, gpio.OUTPUT)
gpio.write(PIN_433, gpio.LOW)

-- transmission donnees en 433 Mhz
-- bits = string ex "000101000010"
function transmit433(bits)
    local msg = {}
    --Les données
    for bit in bits:gmatch"." do
        if bit == "1" then
            table.insert(msg,pulseLenght)
            table.insert(msg,pulseLenght*3)
            table.insert(msg,pulseLenght)
            table.insert(msg,pulseLenght*3)
        elseif bit == "0" then
            table.insert(msg,pulseLenght)
            table.insert(msg,pulseLenght*3)
            table.insert(msg,pulseLenght*3)
            table.insert(msg,pulseLenght)        
        end
    end
    --la trame de fin
    table.insert(msg,pulseLenght)
    table.insert(msg,pulseLenght*31)
    -- Envoie du signal
    gpio.serout(PIN_433, gpio.HIGH, msg, nb_repeat)
end

--function set433Switch(group_id, switch_id, on_off)
--    if on_off then
--        transmit433(group_id..switch_id..on)
--    else
--        transmit433(group_id..switch_id..off)
--    end
--end
