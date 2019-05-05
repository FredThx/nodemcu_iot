-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - sonde humidité terre
--                    - sonde humidité air
--                    - sonde pluie
--                    - sonde luminosité
--                    - sonde température
--                    - relay pour piloter pompe
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, dth, mqtt, ow
-------------------------------------------------
local App = {}

do
  App.msg_debug = true
  App.watchdog = {timeout = 30*60}

  -- Module MCP3008 pour entree analogiques
  mcp = _dofile("mcp3008")
  mcp.init(7,6,8,5)
  mcp.init = nil -- 952 bytes released
  -- Capteur DTH11-22
  DHT_pin = 4
  -- Capteur température DSx20
  DS1820_PIN = 3
  thermometres=_dofile("ds1820_reader")
  thermometres.init(DS1820_PIN)
  sensors = {
      [string.char(40,255,213,74,1,21,4,230)] = "piscine"
  }
  -- Relay pompe
  POMPE_PIN = 2
  -- Capteur Niveau d'eau
  NIVEAU_PIN = 1
  f_niveau = function(level)
                      if level == gpio.LOW then
                          return "BAS"
                      else
                          return "HAUT"
                      end
                  end
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
      client_name = "NODE-EXTERIEUR",
      base_topic = "T-HOME/EXTERIEUR/"
  }

  -- Messages MQTT sortants
  App.mesure_period = 10*60 * 1000
  App.mqtt_out_topics = {}
  App.mqtt_out_topics[App.mqtt.base_topic.."humidite_terre"]={
                  message = function()
                          return (1023 - mcp.read(0))/1023
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}
  App.mqtt_out_topics[App.mqtt.base_topic.."luminosite"]={
                  message = function()
                          return mcp.read(1)
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}
  App.mqtt_out_topics[App.mqtt.base_topic.."pluie"]={
                  message = function()
                          return (1023-mcp.read(2))/1023
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}
  App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                  message = function()
  						local status,temp,humi = dht.read(DHT_pin)
                          return temp
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}
  App.mqtt_out_topics[App.mqtt.base_topic.."humidite"]={
                  message = function()
                          local status,temp,humi = dht.read(DHT_pin)
                          return humi
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}
  App.mqtt_out_topics["T-HOME/PISCINE/temperature"]={
                  result_on_callback = function(callback)
                          thermometres.read(sensors["piscine"],callback)
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}
  App.mqtt_out_topics["T-HOME/PISCINE/niveau"]={
                  message = function()
                          return f_niveau(gpio.read(NIVEAU_PIN))
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}

  -- Messages MQTT sortants sur test
  App.test_period = 1000
  App.mqtt_test_topics = {}

  -- Messages sur trigger GPIO
  App.mqtt_trig_topics = {}
  App.mqtt_trig_topics["T-HOME/PISCINE/niveau"]={
              pin = NIVEAU_PIN,
              pullup = false,
              type = "both",
              message = f_niveau--,
              --qos = 0, retain = 0, callback = nil
  }
  -- Actions sur messages MQTT entrants
  App.mqtt_in_topics = {}
  App.mqtt_in_topics["T-HOME/PISCINE/pompe"]={
              ["ON"]=function()
                          print("POMPE ON")
                          gpio.write(POMPE_PIN, gpio.HIGH)
                      end,
              ["OFF"]=function()
                          print("POMPE OFF")
                          gpio.write(POMPE_PIN, gpio.LOW)
                      end}

end

return App
