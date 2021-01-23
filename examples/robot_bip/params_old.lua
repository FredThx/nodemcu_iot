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
    Spied_d=Servo(7,500)
    Spied_g=Servo(5,500)
    Shanche_d=Servo(8,500)
    Shanche_g=Servo(6,500)
    
    a0_hanche_g = 110
    a0_hanche_d = 90
    a0_pied_g = 60
    a0_pied_d = 100
    
    Spied_d:set_angle(a0_pied_d, function()
            Spied_g:set_angle(a0_pied_g, function()
                    Shanche_d:set_angle(a0_hanche_d, function()
                            Shanche_g:set_angle(a0_hanche_g)
                        end)
                end)
        end)
    
    amp_pied = 20
    amp_hamche = 30
    DROIT = 1
    GAUCHE = -1
    function pas(pied, direction)
      -- pied : 1 (droit) ou -1 (gauche)
      -- direction : 1 (avance) ou -1  (recule)
      direction = direction or 1
      Spied_d:set_angle(a0_hanche_d-amp_pied * pied)
      Spied_g:set_angle(a0_hanche_g-amp_pied * pied, function()
          Shanche_g:set_angle(a0_hanche_g-amp_hamche*direction)
          Shanche_d:set_angle(a0_hanche_d-amp_hamche*direction, function()
              Spied_d:set_angle(a0_pied_d)
              Spied_g:set_angle(a0_pied_g, function()
                  Shanche_d:set_angle(a0_hanche_d)
                  Shanche_g:set_angle(a0_hanche_g)
                end)
            end)
        end)
    
    end

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
    App.mqtt_in_topics[App.mqtt.base_topic.."PAS"]=function(data)
                    pas(data)
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."PG/angle"]=function(data)
                    Spied_g:set_angle(a0_pied_g + tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."PD/angle"]=function(data)
                    Spied_d:set_angle(a0_pied_g + tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."HG/angle"]=function(data)
                    Shanche_g:set_angle(a0_hanche_g + tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."HD/angle"]=function(data)
                    Shanche_d:set_angle(a0_hanche_d + tonumber(data))
                end
    App.mqtt_in_topics[App.mqtt.base_topic.."MARCHE"]={
                ["ON"] = function ()
                    local ordres = {
                    Spied_d, a0_pied_d + 20,
                    Spied_g, a0_pied_g + 00,
                    Shanche_g, a0_hanche_g+30,
                    --Shanche_d, a0_hanche_d+30,
                    Spied_g, a0_pied_g-0,
                    Spied_d, a0_pied_d-0,
                    Spied_g, a0_pied_g-20,
                    Spied_d, a0_pied_d-20,
                    Shanche_d, a0_hanche_d-30,
                    Shanche_g, a0_hanche_g-30,
                    Spied_g, a0_pied_g,
                    Spied_d, a0_pied_d,
                    Shanche_d, a0_hanche_d,
                    Shanche_g, a0_hanche_g,
                    }
                    local i = 0
                    a_marche:alarm(510,tmr.ALARM_AUTO, function()
                        print(i)
                        if i < #ordres/2 then
                            ordres[2*i+1]:set_angle(ordres[2*i+2])
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
