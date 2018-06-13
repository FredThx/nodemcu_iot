local M
do

    local A

    function init(a)
        A = a
    end

    function read()
        print(A)
    end

    function rien()
     local val
        i2c.start(id)
        i2c.address(id, addr, i2c.TRANSMITTER)
        i2c.write(id, reg)
        i2c.stop(id)
        i2c.start(id)
        i2c.address(id, addr, i2c.RECEIVER)
        val = i2c.read(id, 2)
        i2c.stop(id)
        return val
    end

    M = {
        init = init,
        read = read
        }

end
return M