-----------------------------------------------------------------------
--
-- Projet : Serveur Web 100% local
-----------------------------------------------------------------------
-- Module representant un serveur web    
-----------------------------------------------------------------------
-- Usage :                               
--          server = dofile("server.lua")
--          server.http_pages['/'] = function (method, path, _GET)
--                      return server.read_file("index.html")
--                  end
--      avec dans index.html
--              - du code html
--              - balise <?lua unefonctionlua() ?>
--                  où unefonctionLua() retourne un string qui va bien
----------------------------------------------------------------------
-- Auteur : FredThx
----------------------------------------------------------------------

local M = {}
local defaut = {
    ssid = "ESP8266",
    pwd = "12345678",
    ip = "192.168.68.1",
    mask = "255.255.255.0",
    dhcp_start = "192.168.68.10"
}

do
	M.http_pages = {}
	M.params = {}
	M.buffer = {}
    M.read_file = function(filename)
			return assert(loadfile("read_file.lc"))(filename)
		end

    -- Lecture des paramètres
    local f_params = file.open("params.json","r")
    if f_params then
		if pcall(function() 
					M.params = sjson.decode(f_params:read(2*1024)) 
				end) then -- limite a 2*1024 bytes
			print("lecture parametres du serveur :", sjson.encode(M.params))
		else
			print("Error reading params.json") 
		end
        f_params:close()
    end
    if not M.params["wifi_mode"] then M.params["wifi_mode"]="ap" end
    if not M.params["wifi_ssid"] then M.params["wifi_ssid"]=defaut.ssid end
    if not M.params["wifi_pwd"] then M.params["wifi_pwd"]=defaut.pwd end
	if not M.params["server_ip"] then M.params["server_ip"]=defaut.ip end
    if not M.params["ip_mask"] then M.params["ip_mask"]=defaut.mask end
	if not M.params["dhcp_start"] then M.params["dhcp_start"]= defaut.dhcp_start end
	station_cfg={}
    station_cfg.ssid = M.params["wifi_ssid"]
    station_cfg.pwd = M.params["wifi_pwd"]
    -- WIFI configuration
    if M.params["wifi_mode"]=='sta' then
        wifi.setmode(wifi.STATION)
        wifi.sta.config(station_cfg)
    else
        wifi.setmode(wifi.SOFTAP)
        --wifi.cfg.auth=wifi.OPEN
        if not pcall(function() wifi.ap.config(station_cfg) end) then
            wifi.ap.config({ssid=defaut.ssid, pwd=defaut.pwd})
        end
        wifi.ap.setip({ip=M.params["server_ip"], netmask=M.params["ip_mask"], gateway=M.params["server_ip"]})
        wifi.ap.dhcp.config({start = M.params["dhcp_start"]})
        wifi.ap.dhcp.start()
    end
    
    -- Attend la connexion wifi...
    tmr.alarm(1,1000,tmr.ALARM_AUTO, function()
        if (wifi.sta.getip() or wifi.ap.getip()) then
            tmr.stop(1)
            print("WIFI connected")
            if wifi.sta.getip() then
                print(wifi.sta.getip())
            else
                print(wifi.ap.getip())
            end
            srv=net.createServer(net.TCP, 30)
            -- Ecoute du port 80 .. et reponse.
            if srv then
				srv:listen(80, function(conn)
					conn:on("receive", function(sck, request)
							assert(loadfile("http_request.lc"))(sck, request)
						end)
					end)
				print("http server is active.")
			end
		end
    end)
end
return M