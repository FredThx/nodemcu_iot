-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : 
--              Utilisation d'un ecran LCD type 1602 en i2c
--
--              Initialisation de l ecran (en i2c)
--              mise en place du deamon de rafraichissement (alarm)
--
-------------------------------------------------
--  Utilisation :
--              pin_sda = 5 
--              pin_scl = 6 
--              disp_sla = 0x3c
--              _dofile("i2c_lcd")
--              disp_add_data(texte)
--          avec texte un json du type
--          texte = '{ 
--                     "column": [0-20],    (si omis : 0)
--                     "row": [0-5],        (si omis : 0)
--                     "text": "abcdef",      (si omis : "")
--                      "clear":false|true      (si omis : false)
--                      "led":false|true        
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    i2c, sjson
-------------------------------------------------
--
-- TODO : faire un seul module pour les écrans (lcd et oled)
-- 

local M = {}
do
	local lcd = _dofile("lcd1602")()
    
	function M.disp_add_data(data)
		local t_data=sjson.decode(data)
		if t_data.clear then lcd:clear() end
		if t_data.led~=nil then lcd:light(t_data.led) end
		if t_data.text~=nil then
			if not t_data.column then t_data.column = 0 end
			if not t_data.row then t_data.row = 0 end
			lcd:put(lcd:locate( t_data.row, t_data.column), ""..t_data.text)
		end
	end
end
return M
