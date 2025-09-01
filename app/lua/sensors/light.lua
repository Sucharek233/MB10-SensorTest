local scr, root

local sensor
local sensorName, sensorPath, sensorProps, sensorPropsFormat

local gameContainer
local rawInfoLabel

local lux = 0
local maxLux = 5000

-- update background color based on light intensity
local function updateColor()
    local r, g, b

    if lux <= 300 then
        -- black → gray
        local t = Clamp(lux / 300, 0, 1)
        local v = math.floor(t * 128)
        r, g, b = v, v, v

    elseif lux <= 3000 then
        -- gray → yellow
        local t = Clamp((lux - 300) / (3000 - 300), 0, 1)
        r = math.floor(MapValue(t, 0, 1, 128, 255))
        g = math.floor(MapValue(t, 0, 1, 128, 255))
        b = math.floor(MapValue(t, 0, 1, 128, 0))

    else
        -- yellow → white (cap at 20k)
        local t = Clamp((lux - 3000) / (20000 - 3000), 0, 1)
        r = 255
        g = 255
        b = math.floor(MapValue(t, 0, 1, 0, 255))
    end


    local hex = string.format("#%02X%02X%02X", math.floor(r+0.5), math.floor(g+0.5), math.floor(b+0.5))
    gameContainer:set {
        bg_color = hex
    }
    rawInfoLabel:set {
        text = GenerateStringValues({lux}, sensorProps, sensorPropsFormat)
    }
end

-- sensor callback
local function sensorCallback(data)
    local val = data.values[1]  -- assuming sensor returns [lux]
    lux = val
    updateColor()
end

local function init()
    root:set {
        flex = {
            flex_direction = "column"
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

    rawInfoLabel = CreateLabel(gameContainer, sensorName)
    rawInfoLabel:set {
        text = "0 lux",
        bg_opa = lvgl.OPA(50),
        radius = 16,
        pad_all = 16
    }

    local backBtn = CreateBtn(root, "< Back")
    backBtn:onClicked(function()
        sensor:stop()
        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

function OpenLight(name, path, props, propsFormat)
    if not scr then
        scr, root = CreateRootLocked()

        sensorName = name
        sensorPath = path
        sensorProps = props
        sensorPropsFormat = propsFormat

        sensor = GetSensor(sensorPath, Period, sensorCallback)

        init()
    else
        scr:clear_flag(lvgl.FLAG.HIDDEN)
    end

    sensor:start()
end
