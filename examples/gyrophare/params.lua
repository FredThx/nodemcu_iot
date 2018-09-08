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
-- 
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    mqtt, pwm
-------------------------------------------------

App = {}

do
    App.logger = false
    App.watchdog = {timeout = 30*60}
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    --------------------------------------
    -- PARAMETRES CAPTEURS - ACTIONEURS
    --------------------------------------
    
    pin_bt = 5
    pin_moteur = 1
    pin_led = 8
    pin_buzzer = 3
    
    gpio.mode(pin_moteur,gpio.OUTPUT)
    gpio.mode(pin_led,gpio.OUTPUT)
    gpio.mode(pin_buzzer,gpio.OUTPUT)
    --gpio.mode(pin_bt, gpio.INPUT, gpio.PULLUP )
    gpio.write(pin_moteur,gpio.LOW)
    gpio.write(pin_led,gpio.LOW)
    gpio.write(pin_buzzer,gpio.LOW)

    led_alarm = tmr.create()
    buzzer_alarm = tmr.create()
    
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
        user = "fredthx",
        pass = "GaZoBu",
        client_name = "NODE-GYROPHARE",
        base_topic = "T-HOME/GYROPHARE/"
    }    


    
    ----------------------------------------
    -- Messages sur trigger GPIO
    ----------------------------------------
    App.mqtt_trig_topics = {}
    App.mqtt_trig_topics[App.mqtt.base_topic.."BT"]={
                    pin = pin_bt,
                    pullup = true,
                    type = "down", -- or "down", "both", "low", "high"
                    message = function(level, when, eventcount)
                            if level==gpio.LOW and eventcount == 1 then
                                print("Bt pushed",level,when,eventcount)
                                return {level,when, eventcount}
                            end
                        end
                    }    
    ----------------------------------------
    -- Actions sur messages MQTT entrants
    ----------------------------------------
    App.mqtt_in_topics = {}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."MOTEUR"] = {
                ["ON"]=function()
                            print("MOTEUR ON")
                            gpio.write(pin_moteur, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            print("MOTEUR OFF")
                            gpio.write(pin_moteur, gpio.LOW)
                        end}
    
    App.mqtt_in_topics[App.mqtt.base_topic.."LED"] = {
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
                            led_alarm = tmr.create()
                            led_alarm:alarm(500,tmr.ALARM_SINGLE, function()
                                    gpio.write(pin_led,gpio.LOW)
                                end)
                        end,
                ["BLINK_ALWAYS"]=function()
                            led_alarm:alarm(500,tmr.ALARM_AUTO, function()
                                    if led_blink then
                                        gpio.write(pin_led,gpio.LOW)
                                        led_blink = false
                                    else
                                        gpio.write(pin_led,gpio.HIGH)
                                        led_blink = true
                                    end
                                end)
                         end}
    App.mqtt_in_topics[App.mqtt.base_topic.."BUZZER"]={
                ["ON"]=function()
                            print("BUZZER ON")
                            gpio.write(pin_buzzer, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            print("BUZZER OFF")
                            if buzzer_alarm then
                                buzzer_alarm:stop()
                            end
                            pwm.stop(pin_buzzer)
                            gpio.write(pin_buzzer, gpio.LOW)
                        end,
                 ["WAVE"]=function()
                               print("BUZZER WAVE")
                               buzzer_freq = 300
                               pwm.setup(pin_buzzer,buzzer_freq,200)
                               pwm.start(pin_buzzer)
                               buzzer_alarm:alarm(100,tmr.ALARM_AUTO, function()
                                    pwm.setclock(pin_buzzer,buzzer_freq)
                                    buzzer_freq = buzzer_freq + 20
                                    if buzzer_freq > 500 then buzzer_freq = 300 end
                                    end)
                            end
                        }
    ---------------------------------
    -- Connection, deconnection mqtt
    ---------------------------------
    
    App.mqtt.disconnected_callback = App.mqtt_in_topics[App.mqtt.base_topic.."LED"].BLINK_ALWAYS
    function App.mqtt.connected_callback()
        print_log("Stop blink (mqtt ok)")
        led_alarm:stop()
        gpio.write(pin_led,gpio.LOW)
        App.mqtt_publish("INIT",App.mqtt.base_topic.."HELLO")
    end
    App.mqtt.disconnected_callback()
end

return App
