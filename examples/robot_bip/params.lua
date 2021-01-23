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
    Spied_d=Servo(7, 500, 100)
    Spied_g=Servo(5, 500, 60)
    Shanche_d=Servo(8, 500, 90)
    Shanche_g=Servo(6, 500, 110)

    Spied_d:set_angle(0)
    Spied_g:set_angle(0)
    Shanche_d:set_angle(0)
    Shanche_g:set_angle(0)
        
    amplitude = 25
    a_marche=tmr.create()


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
      client_name = "NODE-ROBOTBIP",
      base_topic = "T-HOME/ROBOT_BIP/"
  }
    -- Actions sur messages MQTT entrants
    App.mqtt_in_topics = {}
    App.mqtt_in_topics[App.mqtt.base_topic.."PG/angle"]=function(data)
                    Spied_g:set_angle(tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."PD/angle"]=function(data)
                    Spied_d:set_angle(tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."HG/angle"]=function(data)
                    Shanche_g:set_angle(tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."HD/angle"]=function(data)
                    Shanche_d:set_angle(tonumber(data))
                end
                                
    App.mqtt_in_topics[App.mqtt.base_topic.."MARCHE"]={
                ["ON"] = function ()
                    local ordres = {
                    {[Spied_d] = 1, [Spied_g] = 1},
                    {[Shanche_g] = 0.8, [Shanche_d] = 0.8},
                    {[Spied_g] = 0, [Spied_d] = 0},
                    {[Spied_g] = -1, [Spied_d] = -1},
                    {[Shanche_d] = -0.8, [Shanche_g] = -0.8},
                    {[Spied_g] = 0, [Spied_d] = 0},
                    {[Shanche_d] = 0, [Shanche_g]=0}
                    }
                    local i = 0
                    a_marche:alarm(510,tmr.ALARM_AUTO, function()
                        print(i)
                        if i < #ordres then
                            for servo, angle in pairs(ordres[i+1]) do
                                servo:set_angle(angle * amplitude)
                            end
                            i = i + 1
                        else
                            i=0
                        end
                    end)
                end,
                ["OFF"] = function()
                        a_marche:stop()
                    end
                }
end
return App
