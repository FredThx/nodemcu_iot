-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec

-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, i2c, u8g(avec font ssd1306_128x64_i2c), cjson | sjson
-------------------------------------------------

LOGGER = false
TELNET = false

-- display en i2c
pin_sda = 5 
pin_scl = 6 
disp_sla = 0x3c

BT_PLUS = 3
BT_MOINS = 2

rotary.setup(0, 7, 8, 4)
rotary.on(0, rotary.CLICK + rotary.TURN, function(type, pos, when)
        if mqtt_client then
            data = {type= type, position = pos, time= when}
            mqtt_client:publish(mqtt_base_topic.."ROTARY",sjson.encode(data),0,0)
        end
     end)
------------------------------
-- Modules a charger
------------------------------
modules={ 
    "i2c_lcd"
    }

------------------
-- Params WIFI 
------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-FAB1"
wifi_time_retry = 10 -- minutes

--------------------
-- Params MQTT
--------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "FAB/1/"

-- Messages MQTT sortants
mesure_period = 10*60 * 1000
mqtt_out_topics = {}

-- Messages sur trigger GPIO
mqtt_trig_topics = {}
mqtt_trig_topics[mqtt_base_topic.."FAB_PLUS"]={
            pin = BT_PLUS,
            type = "down",
            pullup = true,
            message = 1
            }
mqtt_trig_topics[mqtt_base_topic.."FAB_MOINS"]={
            pin = BT_MOINS,
            type = "down",
            pullup = true,
            message = -1
            }  
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
-- Messages MQTT sortants sur test
test_period = 1000
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}
mqtt_in_topics[mqtt_base_topic.."DISPLAY"]=function(data)
                disp_add_data(data)
            end
          