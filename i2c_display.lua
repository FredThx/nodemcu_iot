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


i2c.setup(0, pin_sda, pin_scl, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(disp_sla)

disp:setFont(u8g.font_6x10)
disp:setFontRefHeightExtendedText()
disp:setDefaultForegroundColor()
disp:setFontPosTop()

-- rafaichissement du display
function update_display()
    i2c.setup(0, disp_sda, disp_scl, i2c.SLOW) -- pour pas que ça déconne??
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
        disp:drawStr(text.column*6 , text.row*10+2, text.text)
    end
end

tmr.alarm(5,500, tmr.ALARM_AUTO, update_display)

--Exemples de texts :
--disp_texts["humidite"]={column=1, row=2, text="hum : 70%"}
--disp_texts["heure"]={column=1, row=3, text="12:45", id="heure"}

function disp_add_data(data)
    local t_data=cjson.decode(data)
    disp_texts[t_data["id"] ]=t_data
end            
