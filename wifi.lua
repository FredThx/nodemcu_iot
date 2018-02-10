-- GESTION WIFI
-- Réalise la connection WIFI
-- quand établie, execute on_wifi_connected()

function wait_for_wifi_conn()
   tmr.alarm (1, 10000, tmr.ALARM_AUTO, function()
      if wifi.sta.getip() == nil then
         wifi.setmode(wifi.STATION)
         local _SSID
         local _PASSWORD
         _SSID = SSID[WIFI_INDEX]
         print ("Waiting for Wifi connection on " .. _SSID)
         if (type(PASSWORD)=='table') then
            _PASSWORD = PASSWORD[WIFI_INDEX]
         else
            _PASSWORD = PASSWORD
         end
         --wifi.sta.config(_SSID, _PASSWORD, 1)
         -- si marche pas pour ancien, firmware : 
         -- if (not pcall(function()
         --             wifi.sta.config({ssid = _SSID, pwd=_PASSWORD})
         --             end) then
         --             wifi.sta.config(_SSID, _PASSWORD, 1)
         -- end
         wifi.sta.config({ssid = _SSID, pwd=_PASSWORD})
         if (WIFI_INDEX < table.getn(SSID)) then
            WIFI_INDEX = WIFI_INDEX + 1
         else
            WIFI_INDEX = 1
         end
      else
         tmr.stop (1)
         --print ("ESP8266 mode is: " .. wifi.getmode ( ))
         print ("The module MAC address is: " .. wifi.sta.getmac ( ))
         local _ssid = wifi.sta.getconfig()
         print ("Access point : " .. _ssid)
         print ("Config done, IP is " .. wifi.sta.getip ( ))
         --pcall(function()  -- not work with master firmware!!!
         --           wifi.sta.sethostname(HOST)
         --           print("Current hostname is: \""..wifi.sta.gethostname().."\"")
         --       end)
         if on_wifi_connected ~= nil then
            on_wifi_connected()
         end
      end
   end)
end

if (type(SSID)=='string') then SSID = {SSID} end

--wifi.sta.setmac("5c:cf:7f:EF:7A:C0")

WIFI_INDEX = 1
wait_for_wifi_conn()
tmr.alarm(2,wifi_time_retry*60000,1,function()
    if wifi.sta.getip() == nil then
        wait_for_wifi_conn()
    end
end)
