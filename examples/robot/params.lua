-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu SERVO
--               avec un servomoteur S1123
--              pour pilotage robot

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
    S1=Servo(5,500)
    S2=Servo(6,500)
    S3=Servo(7,500)
    S4=Servo(8,500)

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
      client_name = "NODE-ROBOT",
      base_topic = "T-HOME/ROBOT/"
  }
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."S1/angle"]=function(data)
                    print("angle S1 = "..data)
                    S1:set_angle(tonumber(150-data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."S2/angle"]=function(data)
                    S2:set_angle(tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."S3/angle"]=function(data)
                    S3:set_angle(tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."S4/angle"]=function(data)
                    S4:set_angle(tonumber(150-data))
                end
end
return App
