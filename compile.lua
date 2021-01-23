local nb
do
    local progs={ "init_mqtt",
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
            "motor_l298b",
            "tft_24_ts",
            "DF6_V",
            }
    local files = file.list()
    file.open("COMPILE", "a")
    for k, prog in pairs(progs) do
        if files[prog..".lua"] then
            print(prog.."...")
            --file.remove(prog..".lc")
            if pcall(node.compile,prog..".lua") then
                file.writeline('{"'..prog..'":"OK"}')
                print("... done.")
                nb = (nb or 0) + 1
                file.remove(prog..".lua")
            else
                file.remove(prog..".lua")
                file.remove(prog..".lc.chk")
                print("Error")
                file.writeline('{"'..prog..'":"ERROR"}')
            end
        end
    end
    file.flush()
    file.close()
end
return nb
