sr = dofile("HC_SR04.lua")
sr.init(1,2,100, function(value) print(value) end)
sr.start()
