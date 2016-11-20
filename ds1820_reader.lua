-- MODULE NODEMCU (ESP8266)    + capteur DS1820
-- Language : LUA - Firmware : nodemcu - Auteur : FredThx

--GESTION CAPTEURS DS1820

-- Lecture d'un capteur
-- Si addr : renvoie la temperature du capteur spécifie
-- Si pas addr : renvoie une des temperatures lues (au pif) => util quand un seul capteur de branche
-- Si erreur, renvoie nil
function readDSSensor(addr)
    local temp = 85 -- valeur retournee par le capteur quand ca merde
    local i = 0      
    if (addr==nil) then
        for k,v in pairs(readDSSensors()) do
            temp = v -- On prend un des capteurs détectés au pif
        end
    else
        while (i<10 and (temp==85 or temp ==0)) do
            temp = ds18b20.read(addr)
            if (temp == 85 or temp == 0) then 
                print("DS18b20 error : bad value (" .. temp .. ")")
                tmr.delay(100000) -- 0.1 secondes
            end
            i = i + 1
        end
    end
    if (temp == 85 or temp == 0) then temp = nil end
    return temp
end


-- Lecture des capteurs de temperature 
-- Si pas de arguments, renvoi la table de tous les capteurs trouves
-- si un nom specifie (renseigne dans la table sensors), renvoie la temperature
function readDSSensors(sensor_name)
    --Chargement du module en mémoire
    ds18b20 = nil
    package.loaded["ds18b20"]=nil
    require("ds18b20")
    ds18b20.setup(DS1820_PIN)
	local reponse = {}
    local sensor_name_found,i
	for key, addr in pairs(ds18b20.addrs()) do
		sensor_name_found = sensors[addr] -- 
		if (sensor_name_found == nil) then 
			sensor_name_found = ""
			for i = 1, 7 do
				sensor_name_found = sensor_name_found .. addr:byte(i,i) .. "-"
			end
			sensor_name_found = sensor_name_found .. addr:byte(8,8)
		end
		reponse[sensor_name_found] = readDSSensor(addr)
		print(sensor_name_found, reponse[sensor_name_found])
	end
    -- déchargement du module de la mémoire
    ds18b20 = nil
    package.loaded["ds18b20"]=nil
	if (sensor_name==nil) then
		return reponse
	else
		return reponse[sensor_name]--
	end
end


