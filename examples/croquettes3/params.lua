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
--    mqtt, hx711, pwm file, gpio, hx711, mqtt, net, node, pwm, tmr, uart, wifi file, gpio, hx711, mqtt, net, node, pwm, tmr, uart, wifi file, gpio, hx711, mqtt, net, node, pwm, tmr, uart, wifi
-------------------------------------------------

local App = {}
do
    
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
    
    --------------------------------------
    -- PARAMETRES CAPTEURS - ACTIONEURS
    --------------------------------------
    
    -- moteur
    moteur = require("motor_l298b")
    moteur.init(3, 6, 5, 500) -- ena, pinA, pinB, freq
    
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
    
    config={pwm_ratio=0.4,temps_on = 100,temps_reverse = 50}
    
    hx711.init(pin_clk, pin_data)
    
    --------------------------------------
    -- Modules a charger
    --------------------------------------
    modules={}
    
    --------------------------------------
    -- Params WIFI 
    --------------------------------------
    App.net = {
            ssid = {"WIFI_THOME3",'WIFI_THOME2',"WIFI_THOME1"},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }
    
    ----------------------------------------
    -- Params MQTT
    ----------------------------------------
    App.mqtt = {
        host = "192.168.10.155",
        port = 1883,
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-CROQ4",
        base_topic = "T-HOME/CROQ4/"
    }
    ----------------------------------------
    -- Messages MQTT sortants
    ---------------------------------------- 
    App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    
    
    App.mqtt_out_topics[App.mqtt.base_topic .. "POIDS"]={
                    message = function()
                            t = math.floor(10*math.max(0,poids.offset + hx711.read(0)/poids.pente))/10
                            return t
                        end,
                    qos = 0, retain = 0, callback = nil, manual = true}
    ----------------------------------------
    -- Messages sur trigger GPIO
    ----------------------------------------
    App.mqtt_trig_topics = {}
    
    ----------------------------------------
    -- Actions sur messages MQTT entrants
    ----------------------------------------
    App.mqtt_in_topics = {}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."MOTEUR"] = {
                ["ON"]=function()
                            print("MOTEUR ON")
                            moteur.run()
                        end,
                ["OFF"]=function()
                            print("MOTEUR OFF")
                            moteur.stop()
                            dosep_alarm:stop()
                        end,
                ["REVERSE"]=function()
                            print("MOTEUR REVERSE")
                            moteur.run{reverse = true}
                        end}
                        
    
    App.mqtt_in_topics[App.mqtt.base_topic.."PWM_MOTEUR"]= function(data)
                       if data then
                           moteur.run{duty = data}
                       else
                            moteur.stop()
                        end
                    end
    
    dosep_alarm = tmr.create()
    
    App.mqtt_in_topics[App.mqtt.base_topic.."DOSEP"] = function(data)
                    if (tonumber(data) and tonumber(data)>0) then
                        cible = hx711.read(0) + data*poids.pente
                        moteur.run{reverse=true}
                        tmr.create():alarm(config.temps_reverse, tmr.ALARM_SINGLE, function()
                            moteur.run()
                        tmr.create():alarm(config.temps_on, tmr.ALARM_SINGLE, function()
                                moteur.run{duty=config.pwm_ratio}
                                dosep_alarm:alarm(400, tmr.ALARM_AUTO, function()
                                    if hx711.read(0)>cible then -- temps : 386 ms
                                        dosep_alarm:stop()
                                        moteur.stop()
                                    end
                                end)
                            end)
                         end)
                    else
                        dosep_alarm:stop()
                        moteur.stop()
                    end
                end
                
    App.mqtt_in_topics[App.mqtt.base_topic.."VIBREUR1"] = {
                ["ON"]=function()
                            print("VIBREUR 1 ON")
                            gpio.write(pin_vibreur_1, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            print("VIBREUR 1 OFF")
                            gpio.write(pin_vibreur_1, gpio.LOW)
                        end}
    App.mqtt_in_topics[App.mqtt.base_topic.."VIBREUR2"] = {
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
                
end 
return App