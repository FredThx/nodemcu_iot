spi.setup(1,spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW,16,8)


--while true do
function test()
    
    local value_high = spi.recv(1,1)
    value_low = ''
    --local value_low = spi.recv(1,1)
    
    print(value_high, value_low)
    value_high = string.byte(value_high)
    value_low = string.byte(value_low)
    print(value_high, value_low)
    print(bits(value_high),bits(value_low))
    value_high = bit.band(value_high, 31)
    print(value_high, value_low)
    return value_low + 256 * value_high
    
end

function bits(num)
    local t={}
    while num>0 do
        rest=num%2
        table.insert(t,1,rest)
        num=(num-rest)/2
    end return table.concat(t)
end
