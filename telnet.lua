 --lancement du serveur telnet
s=net.createServer(net.TCP,180) 
s:listen(2323,function(c) 
    function s_output(str) 
      if(c~=nil) 
        then c:send(str..'\n') 
      end 
    end 
    node.output(s_output, 1)   
    -- re-direct output to function s_ouput.
    c:on("receive",function(c,l) 
      node.input(l)           
      --like pcall(loadstring(l)), support multiple separate lines
    end) 
    c:on("disconnection",function(c) 
      if LOGGER then
        node.output(logger,1)
      else
        node.output(nil)
      end
      TELNET = false
      --unregist redirect output function, output goes to serial or logger
    end) 
    print("Welcome to " .. HOST)
end)
