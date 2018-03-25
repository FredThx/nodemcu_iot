-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu CROQUETTES 3
--               avec
--                  moteur cc 12V
--                  peson + module HX711
--                  deux vibreurs (moteur cc 3V)
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, hx711, pwm
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

-- moteur
pin_moteur = 6
-- vibeurs
pin_vibreur_1 = 7
pin_vibreur_2 = 8
gpio.mode(pin_vibreur_1,gpio.OUTPUT)
gpio.mode(pin_vibreur_2,gpio.OUTPUT)
gpio.write(pin_vibreur_1,gpio.LOW)
gpio.write(pin_vibreur_2,gpio.LOW)
-- hx711
pin_clk = 1
pin_data = 2
poids={offset=56.5,pente=2104}

moteur={pwm_ratio=0.4,temps_on = 100,pwm_freq = 500}

gpio.mode(pin_moteur,gpio.OUTPUT)
hx711.init(pin_clk, pin_data)

--------------------------------------
-- Modules a charger
--------------------------------------
modules={}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-CROQ4"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/CROQ4/"
----------------------------------------
-- Messages MQTT sortants
---------------------------------------- 
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

-- Messages MQTT sortants sur test
test_period = nil
test_init = false
mqtt_test_topics = {}

mqtt_out_topics[mqtt_base_topic .. "POIDS"]={
                message = function()
                        t = math.floor(10*math.max(0,poids.offset + hx711.read(0)/poids.pente))/10
                        return t
                    end,
                qos = 0, retain = 0, callback = nil, manual = true}
----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}

----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

mqtt_in_topics[mqtt_base_topic.."MOTEUR"] = {
            ["ON"]=function()
                        print("MOTEUR ON")
                        pwm.stop(pin_moteur)
                        gpio.write(pin_moteur, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("MOTEUR OFF")
                        tmr.stop(6)
                        pwm.stop(pin_moteur)
                        gpio.write(pin_moteur, gpio.LOW)
                    end}

mqtt_in_topics[mqtt_base_topic.."PWM_MOTEUR"]= function(data)
                   if data then
                       local duty = data * 1023
                       pwm.setup(pin_moteur,moteur.pwm_freq, duty)
                       pwm.start(pin_moteur)
                   else
                        pwm.stop(pin_moteur)
                    end
                end

mqtt_in_topics[mqtt_base_topic.."DOSEP"] = function(data)
                if (tonumber(data) and tonumber(data)>0) then
                    cible = hx711.read(0) + data*poids.pente
                    pwm.stop(pin_moteur)
                    local duty = moteur.pwm_ratio * 1023
                    pwm.setup(pin_moteur,moteur.pwm_freq, duty)
                    tmr.alarm(6,400, tmr.ALARM_AUTO, function()
                            gpio.write(pin_moteur, gpio.HIGH)
                            tmr.alarm(0,moteur.temps_on, tmr.ALARM_SINGLE, function()
                                gpio.write(pin_moteur, gpio.LOW)
                                pwm.start(pin_moteur)
                            end)
                            if hx711.read(0)>cible then -- temps : 386 ms
                                tmr.stop(0)
                                pwm.stop(pin_moteur)
                                gpio.write(pin_moteur, gpio.LOW)
                                tmr.stop(6)
                            end
                        end)
                else
                    tmr.stop(6)
                    pwm.stop(pin_moteur)
                    gpio.write(pin_moteur, gpio.LOW)
                end
            end
mqtt_in_topics[mqtt_base_topic.."VIBREUR1"] = {
            ["ON"]=function()
                        print("VIBREUR 1 ON")
                        gpio.write(pin_vibreur_1, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("VIBREUR 1 OFF")
                        gpio.write(pin_vibreur_1, gpio.LOW)
                    end}
mqtt_in_topics[mqtt_base_topic.."VIBREUR2"] = {
            ["ON"]=function()
                        print("VIBREUR 2 ON")
                        gpio.write(pin_vibreur_2, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("VIBREUR 2 OFF")
                        gpio.write(pin_vibreur_2, gpio.LOW)
                    end}       
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
            
