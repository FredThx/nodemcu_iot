sr = dofile("HC_SR04.lua")
sr.init(1,2,1000, function(value) 
            local t={}
            t.distance=value
            print(sjson.encode(t)) 
        end)
sr.start()
