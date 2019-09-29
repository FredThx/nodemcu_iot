-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu SERVO
--               avec un servomoteur S1123
--              pour pilotage VMC

-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, pwm
-------------------------------------------------

local App = {}

do

    App.watchdog = {timeout = 30*60} -- set false or nil 30*60 = 30 minutes
    App.msg_debug = true -- if true : send messages (ex : "MQTT send : ok")

    Servo = require('servo')
    SERVO=Servo(1,1000)

    -- Relay pour piloter petite vitesse (LOW) et grande vitesse (HIGH)
    RELAY_PIN = 4
    gpio.mode(RELAY_PIN, gpio.OUTPUT)
    gpio.write(RELAY_PIN, gpio.LOW)

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
      client_name = "NODE-VMC",
      base_topic = "T-HOME/VMC/"
  }
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."WC/angle"]=function(data)
                    SERVO.angle(tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."WC"]={
                ["ON"]=function()
                            SERVO:set_angle(90)
                        end,
                ["OFF"]=function()
                            SERVO:set_angle(0)
                        end}

    App.mqtt_in_topics[App.mqtt.base_topic.."vitesse"]={
                ["HIGH"]=function()
                          print("Vitesse : HIGH.")
                            gpio.write(RELAY_PIN,gpio.HIGH)
                        end,
                ["LOW"]=function()
                            print("Vitesse : LOW.")
                            gpio.write(RELAY_PIN,gpio.LOW)
                        end}

end
return App
