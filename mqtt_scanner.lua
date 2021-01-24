local M
do

local timeout = 10

local get_lan = function(ip)
   local lan = ''
   local i = 0
   ip:gsub("([^.]+)", function(c) 
        if i< 3 then
            lan = lan .. c .. '.'
            i = i+1
       end
   end)
   return lan
end

local scan = function(port, callback)

    local srv = net.createConnection(net.TCP,query_timeout)
    local lan = get_lan(net.ifinfo().ip)
    local host
    local addr = 0
    
    srv:on("connection", function(sck, c) 
            host = select(2,sck:getpeer())
            print_log("Find host on  " .. port .. " : " .. host)
            scanner:stop()
            sck:close()
            callback(host)
        end)
    
    scanner = tmr.create()
    scanner:alarm(50, tmr.ALARM_AUTO , function() 
            pcall(function() srv:close() end)
            addr = addr + 1
            srv:connect(port,'192.168.10.'..addr)
        end)
end


M = {scan = scan}
end
return M