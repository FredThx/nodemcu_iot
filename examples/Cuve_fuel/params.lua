-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : paramètres pour Cuve Fuel
--               avec
--                  - capteur de distance branché sur MCP3008
--                  - Led
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, (spi)
-------------------------------------------------
local App = {}

do

    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes 
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")
    
    -- MPC3008
    MPC_PIN = 0
    mpc = require('mcp3008')
    mpc.init() -- default pins
    mpc.init = nil -- to free memory
    
    -- LED
    GREEN_LED_PIN = 2
    RED_LED_PIN = 1
    gpio.mode(GREEN_LED_PIN, gpio.OUTPUT)
    gpio.write(GREEN_LED_PIN, gpio.LOW)
    gpio.mode(RED_LED_PIN, gpio.OUTPUT)
    gpio.write(RED_LED_PIN, gpio.LOW)

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
      client_name = "NODE-CUVE-FUEL",
      base_topic = "T-HOME/CUVE-FUEL/"
  }
  
    
    -- Messages MQTT sortants
    App.mesure_period = 10*60 * 1000
    App.mqtt_out_topics = {}
    App.mqtt_out_topics[App.mqtt.base_topic.."distance"]={
                    message = function()
                            return mpc.read(MPC_PIN) * 5000 * 5 / 4.88 /1024
                        end,
                    qos = 0, retain = 0, callback = nil}
    -- Messages sur trigger GPIO
    App.mqtt_trig_topics = {}
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."green_led"]={
                ["ON"]=function()
                            gpio.write(GREEN_LED_PIN,gpio.HIGH)
                        end,
                ["OFF"]=function()
                            gpio.write(GREEN_LED_PIN,gpio.LOW)
                        end
                        }
    led_alarm = tmr.create()
    App.mqtt_in_topics[App.mqtt.base_topic.."red_led"]={
                ["ON"]=function()
                            led_alarm:stop()
                            gpio.write(RED_LED_PIN, gpio.HIGH)
                        end,
                ["OFF"]=function()
                            led_alarm:stop()
                            gpio.write(RED_LED_PIN, gpio.LOW)
                        end,
                ["BLINK"]=function()
                            gpio.write(LED_PIN,gpio.HIGH)
                            led_alarm:alarm(500,tmr.ALARM_SINGLE, function()
                                    gpio.write(RED_LED_PIN,gpio.LOW)
                                end)
                        end,
                ["BLINK_ALWAYS"]=function()
                            led_alarm:alarm(500,tmr.ALARM_AUTO, function()
                                    if led_state then
                                        gpio.write(RED_LED_PIN,gpio.LOW)
                                        led_state = false
                                    else
                                        gpio.write(RED_LED_PIN,gpio.HIGH)
                                        led_state = true
                                    end
                                end)
                            end}

end
return App
