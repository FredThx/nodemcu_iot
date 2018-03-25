sr = dofile("HC_SR04.lua")
sr.init(1,2,1000, function(value) print(value) end)
sr.start()
