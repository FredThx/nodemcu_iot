--
-- Inspired by IntelliJ IDEA.
-- Modifié by FredThx
-- Date: 23/06/2018
-- Interfaces ULN2003 for driving a 28BYJ-48 stpper motor OR ANOTHER
--
-- Usage :
--   moteur = require("stepper")
--   moteur.init(1,2,3,4) pins definition
--   moteur.rotate(moteur.REVERSE | moteur.FORWARD, nb_steps | nil, ms per step, callback)
--   moteur.stop()

local stepper = {}
do
    -- HALF-STEP phases : 
    local PHASE_GPIO_DATA = {
        { gpio.LOW,  gpio.LOW,  gpio.LOW,   gpio.HIGH },
        { gpio.LOW,  gpio.LOW,  gpio.HIGH,  gpio.HIGH },
        { gpio.LOW,  gpio.LOW,  gpio.HIGH,  gpio.LOW },
        { gpio.LOW,  gpio.HIGH, gpio.HIGH,  gpio.LOW },
        { gpio.LOW,  gpio.HIGH, gpio.LOW,   gpio.LOW },
        { gpio.HIGH, gpio.HIGH, gpio.LOW,   gpio.LOW },
        { gpio.HIGH, gpio.LOW,  gpio.LOW,   gpio.LOW },
        { gpio.HIGH, gpio.LOW,  gpio.LOW,   gpio.HIGH}
    }

    local PHASE_LOWER_BOUND = 1;
    local PHASE_UPPER_BOUND = table.getn(PHASE_GPIO_DATA);

    local FORWARD = 1;
    local REVERSE = -1;

    ---------------------------------------------------------------------------------------
    -- motor configuration data
    ---------------------------------------------------------------------------------------
    local motor_params = {}

    -- Default values :
    motor_params.pins = {5,6,7,8}
        -- NODEMCU ------- ULN2003
        -- D5 ( GPIO14 ) <-> IN1
        -- D6 ( GPIO12 ) <-> IN2
        -- D7 ( GPIO13 ) <-> IN3
        -- D8 ( GPIO15 ) <-> IN4
    motor_params.step_interval = 5 -- milliseconds decides the speed. smaller the interval, higher the speed.
    motor_params.desired_steps = nil
    motor_params.direction = FORWARD
    motor_params.timer_to_use = nil
    motor_params.callback = nil

    ---------------------------------------------------------------------------------------
    -- rotation state data
    ---------------------------------------------------------------------------------------

    local step_counter  = 0     --total number of steps done since the call started
    local phase         = 1     --which stepper phase are we in ?


    ---------------------------------------------------------------------------------------
    -- Private ( Auxillary and Utility ) methods
    ---------------------------------------------------------------------------------------

    local updatePhaseForNextStep = function ()
        --increment phase in given direction
        phase = phase + motor_params.direction
        if phase > PHASE_UPPER_BOUND then
            phase = PHASE_LOWER_BOUND
        elseif phase < PHASE_LOWER_BOUND then
            phase = PHASE_UPPER_BOUND
        end
    end


    local single_step = function ()
        -- Move the motor 1 step in given direction
        updatePhaseForNextStep();
        for index,mcu_pin in ipairs(motor_params.pins) do
            gpio.write(mcu_pin, PHASE_GPIO_DATA[phase][index])
        end
        -- Check the end
        if motor_params.desired_steps then
            step_counter = step_counter + 1
        end
        if motor_params.desired_steps and step_counter > motor_params.desired_steps then
            stepper.stop()
            if motor_params.callback then
                node.task.post(2, motor_params.callback) -- node.task.HIGH_PRIORITY = 2
            end
        end
    end

    ---------------------------------------------------------------------
    -- moule public methods
    ---------------------------------------------------------------------

    -- Init the stepper
    -- params :
        -- pins
    local init = function ( pins )
        -- Init the timer
        motor_params.timer_to_use = tmr.create()
        -- 
        if not pins then
            print('Init params missing !!! initializing with defaults')
        else
            motor_params.pins = pins
        end
        for i,pin in ipairs(motor_params.pins) do
            gpio.mode(pin, gpio.OUTPUT)
            gpio.write(pin, gpio.LOW)
        end
        step_counter  = 0
        phase         = 1
    end

    -- rotates motor in a given direction. takes a callback to call once the rotation is done
    -- params
        -- direction = stepper.FORWARD or stepper.REVERSE
        -- desired_steps = number between 0 to ... - if nil : never stop
        -- interval = time delay in milliseconds between steps, smaller self number is, faster the motor rotates . 5 is default
        -- callback = callback function called when desired_steps are done
    local rotate = function ( direction, desired_steps, interval, callback)
        if interval then
            motor_params.step_interval = interval
        end
        motor_params.desired_steps = desired_steps
        motor_params.direction = direction
        motor_params.callback = callback
        step_counter  = 0
        motor_params.timer_to_use:alarm(motor_params.step_interval, tmr.ALARM_AUTO, single_step)
    end

    -- Stop the stepper
    local stop = function()
        motor_params.timer_to_use:stop()
        for pin in pairs(motor_params.pins) do
            gpio.write(pin, gpio.LOW)
    end
    end

    stepper = {
        FORWARD = FORWARD,
        REVERSE = REVERSE,
        init = init,
        rotate = rotate,
        stop = stop,
    }
end
return stepper
