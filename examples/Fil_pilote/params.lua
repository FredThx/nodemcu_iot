
-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour pilotage radiateurs via fil pilote
--               avec
--              - 2 relais pour pilotage
--
-------------------------------------------------
--  Wiring
--           |---[Relay_1]--|>|--
--           |                  |
--  --230Vac--                  ------ fil pilote
--           |                  |
--           |---[Relay_2]--|<|--
--
--   ("|>|" est une diode 1N4007
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt
-------------------------------------------------
local App = {}

do
    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    -- Relais
    pin_rel_1 = 5
    pin_rel_2 = 6


    gpio.mode(pin_rel_1, gpio.OUTPUT)
    gpio.mode(pin_rel_2, gpio.OUTPUT)
    gpio.write(pin_rel_1, gpio.LOW)
    gpio.write(pin_rel_2, gpio.LOW)
    fil_pilote_etat = "CONFORT"

    ------------------
    -- Params WIFI
    ------------------
    App.net = {
            ssid = {"WIFI_THOME1",'WIFI_THOME2'},
            password = "plus33324333562",
            wifi_time_retry = 10, -- minutes
            }

    --------------------
    -- Params MQTT
    --------------------
    App.mqtt = {
        host = "192.168.10.155",
        port = 1883,
        client_name = "NODE-SDB-RADIATEUR",
        base_topic = "T-HOME/SDB/RADIATEUR/"
    }

    -- Messages MQTT sortants
    --App.mesure_period = 60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."ETAT"]={
                message = function()
                        return fil_pilote_etat
                    end}

    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    alarm_fil_pilote = tmr.create()
    App.mqtt_in_topics[App.mqtt.base_topic.."PILOTE"] = {
            ["CONFORT"]=function()
                        print_log("SET CONFORT")
                        alarm_fil_pilote:stop()
                        gpio.write(pin_rel_1, gpio.LOW)
                        gpio.write(pin_rel_2, gpio.LOW)
                        fil_pilote_etat = "CONFORT"
                    end,
            ["REDUIT"]=function()
                        print_log("SET REDUIT")
                        alarm_fil_pilote:stop()
                        gpio.write(pin_rel_1, gpio.HIGH)
                        gpio.write(pin_rel_2, gpio.HIGH)
                        fil_pilote_etat = "REDUIT"
                    end,
            ["HORS-GEL"]=function()
                        print_log("SET HORS-GEL")
                        alarm_fil_pilote:stop()
                        gpio.write(pin_rel_1, gpio.LOW)
                        gpio.write(pin_rel_2, gpio.HIGH)
                        fil_pilote_etat = "HORS-GEL"
                    end,
            ["ARRET"]=function()
                        print_log("SET ARRET")
                        alarm_fil_pilote:stop()
                        gpio.write(pin_rel_1, gpio.HIGH)
                        gpio.write(pin_rel_2, gpio.LOW)
                        fil_pilote_etat = "ARRET"
                        end,
            ["CONFORT-1"]=function()
                        print_log("SET CONFORT-1")
                        App.mqtt_in_topics[App.mqtt.base_topic.."PILOTE"]["CONFORT"]()
                        alarm_fil_pilote:alarm(5*60*1000,tmr.ALARM_AUTO,function()
                                print_log("Signal Confort ...")
                                gpio.write(pin_rel_1, gpio.HIGH)
                                gpio.write(pin_rel_2, gpio.HIGH)
                                tmr.create():alarm(3000,tmr.ALARM_SINGLE, function()
                                        print_log("... -2°")
                                        gpio.write(pin_rel_1, gpio.LOW)
                                        gpio.write(pin_rel_2, gpio.LOW)
                                    end)
                            end)
                        fil_pilote_etat = "CONFORT-1"
                        end,
            ["CONFORT-2"]=function()
                        print_log("SET CONFORT-2")
                        App.mqtt_in_topics[App.mqtt.base_topic.."PILOTE"]["CONFORT"]()
                        alarm_fil_pilote:alarm(5*60*1000,tmr.ALARM_AUTO,function()
                                print_log("Signal Confort ...")
                                gpio.write(pin_rel_1, gpio.HIGH)
                                gpio.write(pin_rel_2, gpio.HIGH)
                                tmr.create():alarm(3000,tmr.ALARM_SINGLE, function()
                                        print_log("... -2°")
                                        gpio.write(pin_rel_1, gpio.LOW)
                                        gpio.write(pin_rel_2, gpio.LOW)
                                    end)
                            end)
                        fil_pilote_etat = "CONFORT-2"
                        end}

end
return App
