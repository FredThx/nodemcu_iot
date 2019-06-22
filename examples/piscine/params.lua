-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx
-------------------------------------------------
--  Ce fichier : paramètres pour nodemcu
--               avec
--                    - sonde température ds18b20
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    file, gpio, net, node,tmr, uart, wifi
--    bit, mqtt, ds1820
-------------------------------------------------
local App = {}

do
  App.msg_debug = true
  App.watchdog = {timeout = 30*60}

  -- Module MCP3008 pour entree analogiques
  -- Capteur température DSx20
  DS1820_PIN = 3
  thermometres=_dofile("ds1820_reader")
  thermometres.init(DS1820_PIN)
  --sensors = {
  --    [string.char(28,70,04,94,1B,13,01,1A 40,255,213,74,1,21,4,230)] = "piscine"
  --}
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
      client_name = "NODE-PISCINE",
      base_topic = "T-HOME/PISCINE/"
  }

  -- Messages MQTT sortants
  App.mesure_period = 10*60 * 1000
  App.mqtt_out_topics = {}

  App.mqtt_out_topics[App.mqtt.base_topic.."temperature"]={
                  result_on_callback = function(callback)
                          thermometres.read(nil,callback)
                      end,
                  --qos = 0, retain = 0, callback = nil,
                  manual = true}

  -- Messages MQTT sortants sur test
  App.test_period = 1000
  App.mqtt_test_topics = {}

  -- Messages sur trigger GPIO
  App.mqtt_trig_topics = {}

  -- Actions sur messages MQTT entrants
  App.mqtt_in_topics = {}

end

return App
