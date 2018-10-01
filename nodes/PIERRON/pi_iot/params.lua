-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour interface PIERRON/Mesura
--               avec
--                  - MCP3201 avec Vref = 3.3V
--					- LED :
--							- ON si en fonction
--							- CLIGNOTTE si Batterie faible
--					- BOUTON RESET
--							- Appuie court : node.reset()
--							- Appuie long : suppression parametrage (wifi, ...)
--					- BOUTON ON-OFF (= présence 3.7 batterie)
--							- détecte si le bouton ON-OFF est fermé
--								=> allume LED 
--								=> stoppe l' envoie de mesures
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, spi, sjson, enduser,adc
-------------------------------------------------

LOGGER = false
TELNET = false
WATCHDOG = false
--WATCHDOG_TIMEOUT = 30*60 -- 30 minutes
MSG_DEBUG = false -- if true : send messages (ex : "MQTT send : ok")



-- Modèle
modele = {
    MODELE="PI_NODE",
    VERSION="1",
    ID = wifi.sta.getmac()
    }

-- GPIOs
reset_pin = 3
-- HSPI CLK    5   GPIO14
cs_pin = 8 -- HSPI /CS    8   GPIO15
-- HSPI MISO   6   GPIO12
led_pin = 2
bt_on_off_pin = 1

gpio.mode(reset_pin, gpio.INT)
gpio.mode(led_pin, gpio.OUTPUT)
gpio.mode(bt_on_off_pin, gpio.INT)


-- Convertisseur Analogique vers Numérique
mcp3201 = dofile("mcp3201.lc")
mcp3201.init(1, cs_pin)

-- Enable adcvdd33
if adc.readvdd33() == 65535 then
    adc.force_init_mode(adc.INIT_VDD33)
    node.restart()
end
VCC_MIN = 2.7

-- alarm clignotement LED

alarm_led = tmr.create()

------------------------------
-- Modules a charger
------------------------------
modules={}

------------------
-- Params WIFI 
------------------
--SSID = {"PIANODE"}
--PASSWORD = "pYthagore"
HOST = "PI_NODE_" .. string.sub(string.gsub(wifi.sta.getmac(),':',''),7)
--wifi_time_retry = 10 -- minutes

--function on_wifi_connected()
    --print('on_wifi_connected!')
--end

--------------------
-- Params MQTT
--------------------
mqtt_host = "10.3.141.1"
mqtt_port = 1883
mqtt_user = nil
mqtt_pass = nil
mqtt_client_name = HOST
mqtt_base_topic = "PIERRON/" .. HOST .. "/"

-- Messages MQTT sortants
mesure_period =  1000
mqtt_out_topics = {}
mqtt_out_topics[mqtt_base_topic.."tension"]={
                message = function() 
                        --local value = mcp3201.read() * 3.3
                        local value = voltage()
                        local t = {}
                        t.MODELE = modele
                        t.DATAS = {}
                        t.DATAS["tension"]=value
                        t.INFOS = {}
                        t.INFOS.HEAP = node.heap()
                        t.INFOS.VDD33 = adc.readvdd33()
						if t.INFOS.VDD33 < VCC_MIN then
							alarm_led:alarm(500, tmr.ALARM_AUTO, function()
									if gpio.read(led_pin) == gpio.HIGH then
										gpio.write(led_pin, gpio.LOW)
									else
										gpio.write(led_pin, gpio.HIGH)
									end
								end)
						else
							if alarm_led:state() then
								alarm_led:stop()
							end
						end
                        return t -- return 0 at 0V and 2 at 2V
                    end,
                usb = true,
                qos = 0, retain = 0, callback = nil}

-- Messages sur trigger GPIO
mqtt_trig_topics = {}
-- Actions sur messages MQTT entrants
mqtt_in_topics = {}
					
-- Messages MQTT sortants sur test
test_period = false
mqtt_test_topics = {}

--Gestion du display : mqtt(json)=>affichage
disp_texts = {}

-- Gestion du BOUTON MARCHE/ARRET

function set_status(is_on)
		if is_on then
				mqtt_out_topics[mqtt_base_topic.."tension"].manual = false -- pas necesaire si arrêt complet du module
				gpio.write(led_pin,gpio.HIGH)
				-- A TESTER : arrêt du wifi
				--wifi.resume()
		else
				mqtt_out_topics[mqtt_base_topic.."tension"].manual = true -- pas necesaire si arrêt complet du module
				gpio.write(led_pin,gpio.LOW)
				-- A TESTER : arrêt complet du module
				--local cfg = {}
				--cfg.wake_pin = bt_on_off_pin
				--cfg.int_type = node.INT_DOWN
				--node.sleep(cfg)	
				-- A TESTER : arrêt du wifi
				--wifi.suspend({duration=0})
		end
end

set_status(gpio.read(bt_on_off_pin)==gpio.LOW)

gpio.trig(bt_on_off_pin, "both", function(level)
			if alarm_led:state() then
				alarm_led:stop()
			end
			set_status(level==gpio.LOW)
	end)


-- Gestion du BOUTON RESET
gpio.trig(reset_pin,"down", function()
            -- TODO : refaire en inversant l'interruption
			tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
					if gpio.read(reset_pin)==gpio.LOW then
						print("EFFACEMENT DES DONNEES!") -- TODO
					else
						node.restart()
					end
				end)
	end)

-- Moyenne des tensions
mesures = {}
nb_mesures = 20
somme_mesures = 0
tmr.create():alarm(100, tmr.ALARM_AUTO, function()
         local 
         value = mcp3201.read() * 3.35 --Vref = 3.3 + perte filtre RC
         table.insert(mesures, value)
         somme_mesures = somme_mesures + value 
         if table.getn(mesures) >nb_mesures then
            somme_mesures = somme_mesures- mesures[1]
            table.remove(mesures,1)
         end
    end)

function voltage()
    return somme_mesures / table.getn(mesures)
end
