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
        -- pour utilisation floating bit
        --else
        --   table.insert(msg,pulseLenght*3)
        --    table.insert(msg,pulseLenght)
        --    table.insert(msg,pulseLenght*3)
        --    table.insert(msg,pulseLenght)     
        end
    end
    --la trame de fin : Sync. bit
    table.insert(msg,pulseLenght)
    table.insert(msg,pulseLenght*31)
    -- Envoie du signal
    gpio.serout(PIN_433, gpio.HIGH, msg, nb_repeat)
end