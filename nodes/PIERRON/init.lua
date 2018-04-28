_G.cjson = sjson
dofile("util.lc")
pin_sda = 3
pin_scl = 4 
disp_sla = 0x3C
disp_texts={}
_dofile("i2c_display")
texte = '{"id": "test","column": 5,"row": 1,"text": "Pierron","angle": 0 }'
disp_add_data(texte)

