MAX_LOG_SIZE = 100000
LOG_FILE = "log.txt"

function logger(txt)
    if (txt ~="\n") then
        local t = tmr.time()
        file.open(LOG_FILE,"a+")
        file.write(node.heap().."/")
        file.write(math.floor(t/3600)..":"..math.floor((t%3600)/60)..":"..(t%60).."=>")
        file.writeline(txt)
        file.close()
    end
end


function check_logfile_size()
    for k, v in pairs(file.list()) do
        if (k==LOG_FILE and v > MAX_LOG_SIZE) then
            local copy_log_file = string.gsub(LOG_FILE,"%.","2.",1)
            file.remove(copy_log_file)
            file.rename(LOG_FILE, copy_log_file)
        end
    end
end

function viewLog(i)
    local _line
    local _log_file
    if (i==nil) then
        _log_file = LOG_FILE
    else
        _log_file = string.gsub(LOG_FILE,"%.",i..".",1)
    end
    node.output(nil)
    if (file.open(_log_file, "r")) then
        repeat
            _line = file.readline()
            if (_line ~= nil) then
                print(string.sub(_line,1,-2))
            end
        until (_line == nil)
        file.close()
        print("---end file ---")
    end      
    if LOGGER then
        node.output(logger,1)
    end
end
