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
            "on_wifi_connected",
            "433_switch",
            "i2c_display",
            "util",
            "logger",
            "i2c_lcd",
            "i2c_geste",
            "paj7620",
            "mcp3008",
            "maxsonar",
            "servo",
            "mpu6050",
            "stepper",
            "mcp3201",
            "rotary",
            "mcp9804",
            "mcp9803",
            }
    files = file.list()
    for k, prog in pairs(progs) do
        if files[prog..".lua"] then
            nb = (nb or 0) + 1
            print(prog.."...")
            file.remove(prog..".lc")
            node.compile(prog..".lua")
            file.remove(prog..".lua")
            print("... done.")
        end
    end
    files = nil
end
return nb