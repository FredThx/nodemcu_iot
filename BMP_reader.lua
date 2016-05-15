function readBMP_temperature()
    bmp085.init(BMP_SDA_PIN, BMP_SCL_PIN)
    local t = bmp085.temperature()
    print(string.format("Temperature: %s degrees C", t / 10))
    return t/10
end

function readBMP_pressure()
    bmp085.init(BMP_SDA_PIN, BMP_SCL_PIN)
    local p = bmp085.pressure()
    print(string.format("Pressure: %s mbar", p / 100))
    return p/100
end
