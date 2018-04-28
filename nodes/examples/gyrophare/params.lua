-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu GYROPHARE
--               avec
--                  - Gyropahre du commerce
--                        - moteur cc
--                        - led
--                  - buzzer
--                  - bouton
-- les 3 sorties sont branchées sur un ULN2823
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, pwm
-------------------------------------------------

LOGGER = false

--------------------------------------
-- PARAMETRES CAPTEURS - ACTIONEURS
--------------------------------------

pin_bt = 5
pin_moteur = 2
pin_led = 3
pin_buzzer = 1

gpio.mode(pin_moteur,gpio.OUTPUT)
gpio.mode(pin_led,gpio.OUTPUT)
gpio.mode(pin_buzzer,gpio.OUTPUT)
gpio.write(pin_moteur,gpio.LOW)
gpio.write(pin_led,gpio.LOW)
gpio.write(pin_buzzer,gpio.LOW)

--------------------------------------pin_buzzer
-- Modules a charger
--------------------------------------
modules={}

--------------------------------------
-- Params WIFI 
--------------------------------------
SSID = {"WIFI_THOME1","WIFI_THOME2"}
PASSWORD = "plus33324333562"
HOST = "NODE-GYROPHARE"
wifi_time_retry = 10 -- minutes

----------------------------------------
-- Params MQTT
----------------------------------------
mqtt_host = "192.168.10.155"
mqtt_port = 1883
mqtt_user = "fredthx"
mqtt_pass = "GaZoBu"
mqtt_client_name = HOST
mqtt_base_topic = "T-HOME/GYROPHARE/"
----------------------------------------
-- Messages MQTT sortants
---------------------------------------- 
mesure_period = 1*60 * 1000
mqtt_out_topics = {}

-- Messages MQTT sortants sur test
test_period = nil
test_init = false
mqtt_test_topics = {}

----------------------------------------
-- Messages sur trigger GPIO
----------------------------------------
mqtt_trig_topics = {}
--mqtt_trig_topics[mqtt_base_topic.."BT"]={
--                pin = pin_bt,
--                pullup = true,
--                type = "down", -- or "down", "both", "low", "high"
--                qos = 0, retain = 0, callback = nil,
--                message = function()
--                        print("Bt pushed")
                        --mqtt_in_topics[mqtt_base_topic.."RELAIS"]["CHANGE"]()
                        -- TODO : régler problème de déclenchement intempestif quand relais activé via WIFI
--                        return gpio.read(pin_bt)
--                    end
--                }    
----------------------------------------
-- Actions sur messages MQTT entrants
----------------------------------------
mqtt_in_topics = {}

mqtt_in_topics[mqtt_base_topic.."MOTEUR"] = {
            ["ON"]=function()
                        print("MOTEUR ON")
                        gpio.write(pin_moteur, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("MOTEUR OFF")
                        gpio.write(pin_moteur, gpio.LOW)
                    end}

mqtt_in_topics[mqtt_base_topic.."LED"] = {
            ["ON"]=function()
                        print("LED ON")
                        gpio.write(pin_led, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("LED OFF")
                        gpio.write(pin_led, gpio.LOW)
                    end,
            ["BLINK"]=function()
                        gpio.write(pin_led,gpio.HIGH)
                        tmr.alarm(6,500,tmr.ALARM_SINGLE, function()
                                gpio.write(pin_led,gpio.LOW)
                            end)
                    end,
            ["BLINK_ALWAYS"]=function()
                        tmr.alarm(6,500,tmr.ALARM_AUTO, function()
                                if led_alarm then
                                    gpio.write(pin_led,gpio.LOW)
                                    led_alarm = false
                                else
                                    gpio.write(pin_led,gpio.HIGH)
                                    led_alarm = true
                                end
                            end)
                     end}
mqtt_in_topics[mqtt_base_topic.."BUZZER"]={
            ["ON"]=function()
                        print("BUZZER ON")
                        gpio.write(pin_buzzer, gpio.HIGH)
                    end,
            ["OFF"]=function()
                        print("BUZZER OFF")
                        tmr.stop(0)
                        pwm.stop(pin_buzzer)
                        gpio.write(pin_buzzer, gpio.LOW)
                    end,
             ["WAVE"]=function()
                           print("BUZZER WAVE")
                           buzzer_freq = 300
                           pwm.setup(pin_buzzer,buzzer_freq,200)
                           pwm.start(pin_buzzer)
                           tmr.alarm(0,100,tmr.ALARM_AUTO, function()
                                pwm.setclock(pin_buzzer,buzzer_freq)
                                buzzer_freq = buzzer_freq + 20
                                if buzzer_freq > 500 then buzzer_freq = 300 end
                                end)
                        end
                    }
        
                    
----------------------------------------
--Gestion du display : mqtt(json)=>affichage
----------------------------------------
            
