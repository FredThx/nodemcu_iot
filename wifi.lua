-- GESTION WIFI
-- Réalise la connection WIFI
-- quand établie, execute on_wifi_connected()

function wait_for_wifi_conn()
	local wifi_alarm = tmr.create()
	wifi_alarm:alarm (10000, tmr.ALARM_AUTO, function()
      if wifi.sta.getip() == nil then
         wifi.setmode(wifi.STATION)
         local _SSID
         local _PASSWORD
         _SSID = App.net.ssid[WIFI_INDEX]
         print_log ("Waiting for Wifi connection on " .. _SSID)
         if (type(App.net.password)=='table') then
            _PASSWORD = App.net.password[WIFI_INDEX]
         else
            _PASSWORD = App.net.password
         end
         wifi.sta.config({ssid = _SSID, pwd=_PASSWORD})
         if (WIFI_INDEX < table.getn(App.net.ssid)) then
            WIFI_INDEX = WIFI_INDEX + 1
         else
            WIFI_INDEX = 1
         end
      else
         wifi_alarm:stop()
         print_log ("The module MAC address is: " .. wifi.sta.getmac ( ))
         local _ssid = wifi.sta.getconfig()
         print_log ("Access point : " .. _ssid)
         print_log ("Config done, IP is " .. wifi.sta.getip ( ))
         if on_wifi_connected ~= nil then
            on_wifi_connected()
         end
      end
   end)
end

if (type(App.net.ssid)=='string') then App.net.ssid = {App.net.ssid} end

--wifi.sta.setmac("5c:cf:7f:EF:7A:C0")

WIFI_INDEX = 1
wait_for_wifi_conn()
tmr.create():alarm(App.net.wifi_time_retry*60000,1,function()
    if wifi.sta.getip() == nil then
        wait_for_wifi_conn()
    end
end)
