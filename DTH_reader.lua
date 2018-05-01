-- DTH module
--
-- Conservé uniquement pour compatibilité avec anciens projets
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    dth
-------------------------------------------------
--
-- En plus erreur de frappe : device = DHT et non DTH!!!

--local dht= require 'dht'
function readDht()    
    --local status,temp,humi,temp_decimial,humi_decimial = dht.read(DTH_pin)
    local status,temp,humi = dht.read(DTH_pin)
    if( status == dht.OK ) then
        print("DHT Temperature : "..temp.." - ".."Humidite : "..humi)
        return temp,humi
    elseif( status == dht.ERROR_CHECKSUM ) then
        print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
        print( "DHT Time out." );
    end
end
