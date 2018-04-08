-- Rotary encoder module
--  based on the official rotary module (https://nodemcu.readthedocs.io/en/master/en/modules/rotary/)
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
        rotary.setup(unpack({channel, pina, pinb, pinpress, longpress_time_ms, dblclick_time_ms})) 
        channels[channel].pos = rotary.getpos(channel)
    end
    
    local on_rotary = function(channel,eventtype, callback)
		if eventtype == rotary.TURN then
            --M.channels[channel].callback = callback
			rotary.on(channel, rotary.TURN, function(type, pos, when)
                    local ch = M.channels[channel]
					if math.abs(ch.pos - pos) >= ch.ipd then
						ch.count = ch.count + (pos - ch.pos) / ch.ipd
                        ch.pos = pos
						callback(rotary.TURN, ch.count, when)
					end
				end)
		else 
			rotary.on(channel, eventtype, callback)
		end
	end
	
    M =  {
            on = on_rotary,
            init = init_rotary,
            channels = channels
        }
end
return M
