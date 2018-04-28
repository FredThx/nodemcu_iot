alarm = tmr.create()
alarm:alarm(1000,tmr.ALARM_AUTO, function()
            local datas = {}
            datas['mac'] = wifi.sta.getmac()
            datas['time'] = tmr.now()
            datas['state'] = "Ok"
            datas = sjson.encode(datas)
            print(datas)
        end)