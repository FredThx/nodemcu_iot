-- MPU_6050 module
-- Accelerometre + gyroscope + thermometre
-- usage :
--  mpu6050 = dofile('mpu_6050.lua') or .lc if compiled
--  mpu6050.init(pin_sda, pin_scl [int_detection, int_duration])
--      int_detection : 0 to 255 (0 : always, 1 is good)
--  mpu6050.init = nil -- to free memory
--  mpu6050.read() return a table with all values
--


local M

do
    bus = 0
    -- MPU Register addr    
    MPU_PWR_MGMT1 = 0x6b
    MPU_WHO_I_AM = 0x75
    MPU_ACCEL_XOUT_H = 0x3b
    MPU_INT_ENABLE = 0x38
    MPU_INT_STATUS = 0x3a
    MPU_MOT_THR = 0x1f
    MPU_MOT_DUR = 0x20
    
    --Initialisation
    function init(pin_sda, pin_scl, int_detection, int_duration)
      i2c.setup(bus, pin_sda, pin_scl, i2c.SLOW)  
      scan()  
      print("Start device...")
      write_reg_MPU(MPU_PWR_MGMT1,0)
      scan()
      if int_detection ~= nil then
        write_reg_MPU(MPU_MOT_THR,int_detection)
        write_reg_MPU(MPU_MOT_DUR,int_duration or 1)
        write_reg_MPU(MPU_INT_ENABLE,64)
      end
    end
    
    function write_reg_MPU(reg,val)
        i2c.start(bus)
        i2c.address(bus, dev_addr, i2c.TRANSMITTER)
        i2c.write(bus, reg)
        i2c.write(bus, val)
        i2c.stop(bus)
    end
    
    function read_reg_MPU(reg , byte_nb)
        local c
        local byte_nb = byte_nb or 1
        i2c.start(bus) 
        i2c.address(bus, dev_addr, i2c.TRANSMITTER)
        i2c.write(bus, reg)
        i2c.stop(bus)
        i2c.start(bus)
        i2c.address(bus, dev_addr, i2c.RECEIVER)
        c=i2c.read(bus, byte_nb)
        i2c.stop(bus)
        local result = {}
        for i = 1,byte_nb do
            table.insert(result,string.byte(c,i))
        end
        return unpack(result)
    end
    
    function read_data()
        local datas
        local result
        datas = pack(read_reg_MPU(MPU_ACCEL_XOUT_H,14))
        result = {}
        for i = 0,6 do
            table.insert(result,datas[1+2*i]*256+datas[2+2*i])
        end
        datas = result
        result = {}
        result['gyro_X'] = calc_value(datas[5])
        result['gyro_Y'] = calc_value(datas[6])
        result['gyro_Z'] = calc_value(datas[7])
        result['acc_X'] = calc_value(datas[1])
        result['acc_Y'] = calc_value(datas[2])
        result['acc_Z'] = calc_value(datas[3])
        result['temp'] = calc_value(datas[4])/340+36.53
        return result
    end
    
    function calc_value(val)
        if val >= 0x8000 then
            return -((65535 - val)+1)
        else
            return val
        end
    end
    
    function scan()
        for dev_addr_ = 1,127 do
            dev_addr = dev_addr_
            if read_reg_MPU(MPU_WHO_I_AM)==dev_addr_ then
                print("MCU found at 0x"..string.format("%02X",dev_addr))
                if bit.isset(read_reg_MPU(MPU_PWR_MGMT1),6) then
                    print("Mode : sleep")
                else
                    print("Mode : running")
                end
                break
            end
        end
        if dev_addr_ == 127 then
            dev_addr = nil
            print("No MCU found")
        end
    end
                
    function pack(...)
        return arg
    end

    M = {
        init = init,
        read = read_data        
    }
    
end
return M