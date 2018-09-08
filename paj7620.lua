-------------------------------------------------
--  Projet : des IOT a base de nodemcu (ESP8266)
--           qui communiquent en MQTT
-------------------------------------------------
--  Auteur : FredThx  
-------------------------------------------------
--  Ce fichier : 
--              Utilisation d'un module grove gesture (PAJ7620)
--
--              Initialisation du PAJ7620
--              mise en place du deamon de lecture
--
-------------------------------------------------
--  Utilisation :
--              G = require("paj7620")
--              G.init()
--              G.init = nil  -- to free memory
--              G.scan(function(c) print(c.." catch") end)
--
-------------------------------------------------
-- Modules nécessaires dans le firmware :
--    i2c, bit
-------------------------------------------------
local M
do
    local ADR = 0x73  -- default PAJ6220 i2c addr
    local PAJ7620_ADDR_BASE = 0x00
    local PAJ7620_REGITER_BANK_SEL = PAJ7620_ADDR_BASE + 0xEF
    local PAJ7620_BANK0 = bit.lshift(0,0)
    local GES_RIGHT_FLAG = bit.lshift(1,0)
    local GES_LEFT_FLAG = bit.lshift(1,1)
    local GES_UP_FLAG = bit.lshift(1,2)
    local GES_DOWN_FLAG = bit.lshift(1,3)
    local GES_FORWARD_FLAG = bit.lshift(1,4)
    local GES_BACKWARD_FLAG = bit.lshift(1,5)
    local GES_CLOCKWISE_FLAG = bit.lshift(1,6)
    local GES_COUNT_CLOCKWISE_FLAG = bit.lshift(1,7)
    local GES_WAVE_FLAG = bit.lshift(1,8)
    
    local GES_REACTION_TIME = 500
    local GES_ENTRY_TIME = 800
    local GES_QUIT_TIME = 1500

    local GES_REG_FILE = "paj7620.reg"
	
	local ALARM_TIME = 100
	local alarm = tmr.create()
	
    -- Write data
    --      addr : reg adress
    --      cmd : function data
    local paj7620WriteReg = function(addr, cmd)
        i2c.start(0)
        i2c.address(0, ADR, i2c.TRANSMITTER)
        i2c.write(0, addr)
        i2c.write(0,cmd)
        i2c.stop(0)
    end
    
    -- Read reg data
    --      addr : reg address
    -- return : readed data (1 byte)
    local paj7620ReadReg = function(addr)
        i2c.start(0)
        i2c.address(0, ADR, i2c.TRANSMITTER)
        i2c.write(0, addr)
        i2c.stop(0)        
        i2c.start(0)
        i2c.address(0, ADR, i2c.RECEIVER)
        local data = i2c.read(0,1)
        i2c.stop(0)
        return string.byte(data)
    end

    -- Init sensor
    local paj7620Init = function(adr, alarm_time)
	    ADR = adr or ADR
		ALARM_TIME = alarm_time or ALARM_TIME
        print("Init PAJ7620 at 0x"..string.format("%x", ADR))
        --i2c.start(0)
        print("Init gestual sensor...")
        paj7620WriteReg(PAJ7620_REGITER_BANK_SEL, PAJ7620_BANK0);
        paj7620WriteReg(PAJ7620_REGITER_BANK_SEL, PAJ7620_BANK0);
        local data0 = paj7620ReadReg(0,1)
        local data1 = paj7620ReadReg(1,1)
        print("Addr0 = 0x"..string.format("%x", data0))
        print("Addr1 = 0x"..string.format("%x", data1))
        if ((data0~= 0x20) or (data1)~=0x76) then
            print("Error!!!")
            return false
        elseif data0 == 0x20 then
            print("wake-up finish.")
        end
        file.open(GES_REG_FILE, 'r')
        local txt = file.readline()
        local err
        while txt do
           txt = "reg = " .. txt 
           if  pcall(loadstring((txt))) then
                paj7620WriteReg(reg[1], reg[2])
           end
           txt = file.readline()
        end
        file.close()
        paj7620WriteReg(PAJ7620_REGITER_BANK_SEL, PAJ7620_BANK0);
        print("Paj7620 initialize register finished.")
        return true
    end
    -- scan the gestual sensor
    --  paramètres : 
    --      - alarme_id : 0-6 alarme id
    --      - alarme_time : time between sensors read
    --      - callback : callback function with geste as parameter
    local scan = function(callback)
        alarm:alarm(ALARM_TIME, tmr.ALARM_AUTO, function ()
            local data = paj7620ReadReg(0x43) + paj7620ReadReg(0x44)*256
            if data ~= 0 then
                alarm:stop()
                if data >= GES_FORWARD_FLAG then
                    callback(data)
                else
                    tmr.delay(GES_ENTRY_TIME)
                    data2=paj7620ReadReg(0x43)
                    if data2 == 0 then
                        callback(data)
                    else
                        callback(data2)
                    end
                end
                tmr.delay(GES_QUIT_TIME)
                alarm:start()
            end
        end)
    end
    
--    local init = function(adr)
--        ADR = adr or 0x73
--        print("Init PAJ7620 at 0x"..string.format("%x", ADR))
--        paj7620Init()
        --return {
        --    write = paj7620WriteReg,
        --    read = paj7620ReadReg,
        --    scan = scan
        --}
--    end
    M={
		init = paj7620Init,
		--write = paj7620WriteReg,
		--read = paj7620ReadReg,
		scan = scan
	}
end
return M