-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : 
--				Initialisation de l ecran (en i2c)
--				mise en place du deamon de rafraichissement (alarm)
--
-------------------------------------------------
--  Utilisation :
--              pin_sda = 5 
--              pin_scl = 6 
--              disp_sla = 0x3c
--              _dofile("i2c_display")
--              disp_add_data(texte)
--          avec texte un json du type
--          texte = '{ "id": "id_du_texte",
--                     "column": [0-20],    (si omis : 0)
--                     "row": [0-5],        (si omis : 0)
--                     "text": "abcdef",      (si omis : "")
--                     "angle": [0,90,180,270] }'     (si omis 0°)
--
--          disp_add_data('{"id":"id_du_texte"}') efface le texte
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    i2c, u8g(avec font ssd1306_128x64_i2c), cjson
-------------------------------------------------

i2c.setup(0, pin_sda, pin_scl, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(disp_sla)

disp:setFont(u8g.font_6x10)
disp:setFontRefHeightExtendedText()
disp:setDefaultForegroundColor()
disp:setFontPosTop()

-- rafaichissement du display
function update_display()
    i2c.setup(0, pin_sda, pin_scl, i2c.SLOW) -- pour pas que ça déconne??
    disp:firstPage()
    repeat
        draw_background()
        draw_texts()
    until disp:nextPage() == false
    x_pos = x_pos + 3
    if x_pos > 125 then x_pos = 6 end
end

-- Dessin du background (en dur ici)
x_pos = 6
function draw_background()
    local coins = {7,11,13,14}
    disp:drawDisc(x_pos, 5, 4, coins[(x_pos/3)%4+1])
end

-- Dessin des text qui viendront par mqtt
function draw_texts()
    for k, text in pairs(disp_texts) do
        local column = (text.column or 0)*6
        local row = (text.row or 0)*10+2
        local text = text.text or ""
        if text.angle==90 then
            disp:drawStr90(column, row, text)
        elseif text.angle==180 then
            disp:drawStr180(column, row, text)
        elseif text.angle==270 then
            disp:drawStr270(column, row, text)
        else
            disp:drawStr(column, row, text)
        end
    end
end

tmr.alarm(0,500, tmr.ALARM_AUTO, update_display)

function disp_add_data(data)
    local t_data=cjson.decode(data)
    disp_texts[t_data["id"] ]=t_data
end            
