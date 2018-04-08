-- Rotary encoder module
--  from scratch
--
--
-- usage :
--  rot = dofile('rotary.lua') -- or "rotary.lc"
--  rot.init(channel, pina, pinb, nb_impulsion_per_detent,pinpress, longpress_time_ms, dblclick_time_ms) channel : 0,1 or 2
--  rot.init = nil -- to free memory
-- rot.on(channel, eventtype, callback)
-- with callback = function(type, pos, when)
--
-------------------------------------------------
-- Modules necessaires dans le firmware :
--    gpio,tmr
--    rotary
-------------------------------------------------


local M
do
    local channels = {}
    for channel = 0,2 do channels[channel]={} end
    
    local init_rotary = function(channel, pina, pinb,nb_impulsion_per_detent,pinpress, longpress_time_ms, dblclick_time_ms)
        channels[channel].ipd = nb_impulsion_per_detent or 1
        channels[channel].count = 0
        gpio.mode(pina, gpio.INPUT, gpio.PULLUP)
        gpio.mode(pinb, gpio.INPUT, gpio.PULLUP)
        channels[channel].pina = pina
        channels[channel].pinb = pinb
        channels[channel].last_read = {0,0,0,0}
        --rotary.setup(unpack({channel, pina, pinb, pinpress, longpress_time_ms, dblclick_time_ms})) 
    end

    local test_turn = function(channel, val)
            local ch = M.channels[channel]
            if val ~= ch.last_read[4] then
                table.insert(ch.last_read,val)
                table.remove(ch.last_read,1)
                print(ch.last_read[4])
                if ch.last_read[1]==2 and ch.last_read[2]==0 and ch.last_read[3]==1 and ch.last_read[4]==3 then
                    print("Detect : -1")
                    ch.count = ch.count - 1
                    ch.callback(-1, ch.count)
                elseif ch.last_read[1]==1 and ch.last_read[2]==0 and ch.last_read[3]==2 and ch.last_read[4]==3 then
                    print("Detect : +1")
                    ch.count = ch.count + 1
                    ch.callback(+1, ch.count)
                end
            end
        end

    
    local on_rotary = function(channel,eventtype, callback)
        if eventtype == M.TURN then
            local ch = M.channels[channel]
            ch["callback"] = callback
            gpio.trig(ch.pina,"both", function(level)
                    local pinb = gpio.read(ch.pinb)
                    test_turn(channel, level + pinb * 2)
                end)
            gpio.trig(ch.pinb,"both", function(level)
                    local pina = gpio.read(ch.pina)
                    test_turn(channel, pina + level * 2)
                end)
        else 
            print("eventype not yet implemented")
        end
    end
    
    M =  {
            on = on_rotary,
            init = init_rotary,
            channels = channels,
            TURN = 8
        }
end
return M
