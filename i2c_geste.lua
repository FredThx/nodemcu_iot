-- Il faut mieux intégrer ce code directement au params.lua

i2c.setup(0, pin_sda, pin_scl, i2c.SLOW)
G = _dofile("paj7620")()

G.scan(6,100,function(c)
        print(GEST_TOPIC, c)
        if App.mqtt.client then
            App.mqtt.client:publish(GEST_TOPIC,c,0,0)
        end
    end)
