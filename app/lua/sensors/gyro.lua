local scr, root

local sensor
local sensorName, sensorPath, sensorProps, sensorPropsFormat

local power = 0
local powerLabel
local maxPowerLabel
local maxPower = 0
local powerDecayTimer

local gameContainer

local rawValuesLabel

local function tobyte(x)
    -- clamp to 0..255 and round
    if x ~= x then x = 0 end            -- guard NaN
    if x < 0 then x = 0 elseif x > 255 then x = 255 end
    return math.floor(x + 0.5)          -- round to int
end

-- update background color based on power
local function updateColor()
    local powerScaled = MapValue(power, 0, 100, 0, 255)
    local r = tobyte(powerScaled)
    local g = tobyte(0)
    local b = tobyte(255 - powerScaled)

    local hex = string.format("#%02X%02X%02X", r, g, b)

    gameContainer:set {
        bg_color = hex
    }
end

-- sensor callback
local function sensorCallback(data)
    local x = data.values[1]
    local y = data.values[2]
    local z = data.values[3]

    local mag = (x*x + y*y + z*z)

    if mag > power then -- threshold for "punch"
        power = mag
    end
    
    local strValues = GenerateStringValues(data.values, sensorProps, sensorPropsFormat)
    rawValuesLabel:set {
        text = strValues
    }
end

-- decay timer
local function decayTimerCb()
    power = Clamp(power - power * 0.02 - 0.2, 0, 999999)
    if power >= maxPower then
        maxPower = power
        maxPowerLabel:set {
            text = "Max: " .. math.floor(power)
        }
    end

    powerLabel:set {
        text = "Power: " .. math.floor(power)
    }
    updateColor()
end

local function init()
    root:set {
        flex = {
            flex_direction = "column",
        }
    }

    CreateCenteredLabel(root, sensorName)

    gameContainer = CreateExpandingContainer(root)
    gameContainer:set {
        flex = {
            flex_direction = "row",
            flex_wrap = "wrap",
            justify_content = "center",
            align_items = "center",
            align_content = "center",
        }
    }

    rawValuesLabel = CreateLabel(gameContainer, "")
    rawValuesLabel:set {
        x = 0,
        y = 0,
        bg_opa = lvgl.OPA(50),
        radius = 16,
        pad_all = 16
    }

    powerLabel = CreateLabel(gameContainer, "")
    powerLabel:set {
        text = "Power: 0",
        bg_opa = lvgl.OPA(50),
        radius = 16,
        pad_all = 16
    }

    maxPowerLabel = CreateLabel(gameContainer, "")
    maxPowerLabel:set {
        text = "Max: 0",
        bg_opa = lvgl.OPA(50),
        radius = 16,
        pad_all = 16
    }

    -- start decay timer
    powerDecayTimer = lvgl.Timer({
        period = Period,
        repeat_count = -1,
        paused = true,
        cb = decayTimerCb
    })

    local backBtn = CreateBtn(root, "< Back")
    backBtn:onClicked(function()
        sensor:stop()
        powerDecayTimer:pause()
        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

function OpenGyro(name, path, props, propsFormat)
    if not scr then
        scr, root = CreateRootLocked()

        sensorName = name
        sensorPath = path
        sensorProps = props
        sensorPropsFormat = propsFormat
        
        sensor = GetSensor(sensorPath, Period, sensorCallback)
        
        init()
    else
        power = 0
        maxPower = 0
        decayTimerCb() -- trigger update with reset values

        scr:clear_flag(lvgl.FLAG.HIDDEN)
    end

    sensor:start()
    powerDecayTimer:resume()
end