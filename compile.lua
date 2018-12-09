local nb
do
    progs={ "init_mqtt",
            "init_trig",
            "main",
            "params",
            "read_and_send",
            "telnet",
            "add_reverse_topics",
            "BMP_reader",
            "ds18b20",
            "ds1820_reader",
            "DTH_reader",
            "test_and_send",
            "wifi",
            "433_switch",
            "i2c_display",
            "util",
            "logger",
            "i2c_lcd",
            "lcd1602",
            "i2c_geste",
            "paj7620",
            "mcp3008",
            "maxsonar",
            "servo",
            "mpu6050",
            "stepper",
            "mcp3201",
            "rotary",
            "vl6180x",
            "led_rbv",
            "flowmeter",
            "motor_l298b"
            }
    files = file.list()
    for k, prog in pairs(progs) do
        if files[prog..".lua"] then
            print(prog.."...")
            file.remove(prog..".lc")
            node.compile(prog..".lua")
            file.remove(prog..".lua")
            print("... done.")
            nb = (nb or 0) +1
        end
    end
    files = nil
end
return nb
