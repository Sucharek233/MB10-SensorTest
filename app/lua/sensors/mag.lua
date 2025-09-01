local scr, root

local sensor
local sensorName, sensorPath, sensorProps, sensorPropsFormat

local magLabel
local magBarContainerHeight = ContentHeight - 180
local magBarContainer
local magBarFill
local maxMag = 35000 -- 35000

-- update the bar and label based on current magnitude
local function updateBar(x, y, z, mag)
    local barHeight = MapValue(Clamp(mag, 0, maxMag), 0, maxMag, 0, magBarContainerHeight)

    -- inner fill grows from bottom up
    magBarFill:set {
        h = barHeight,
        y = magBarContainerHeight - barHeight - 20
    }

    -- color shifts
    local r = Clamp(MapValue(mag, 0, maxMag, 0, 255), 0, 255)
    local g = 255 - r
    local b = 0
    local hex = string.format("#%02X%02X%02X", math.floor(r+0.5), math.floor(g+0.5), math.floor(b+0.5))
    magBarFill:set {
        bg_color = hex
    }

    -- update label
    magLabel:set {
        text = GenerateStringValues({x, y, z}, sensorProps, sensorPropsFormat) ..
               "\nMag: " .. math.floor(mag)
    }
end

-- sensor callback
local function sensorCallback(data)
    local x = data.values[1]
    local y = data.values[2]
    local z = data.values[3]

    local mag = math.sqrt(x*x + y*y + z*z)
    updateBar(x, y, z, mag)
end

local function init()
    root:set {
        flex = {
            flex_direction = "column"
        }
    }

    CreateCenteredLabel(root, sensorName)

    local container = CreateExpandingContainer(root)
    container:set {
        flex = {
            flex_direction = "column",
            justify_content = "center",
            align_items = "center"
        }
    }

    magLabel = CreateLabel(container, "x: 0\ny: 0\nz: 0\nMag: 0")

    magBarContainer = container:Object(nil, {
        w = lvgl.PCT(100),
        h = magBarContainerHeight,
        bg_color = "#222222",
        -- radius = 8,
        clip_corner = true
    })
    magBarContainer:clear_flag(lvgl.FLAG.SCROLLABLE)

    magBarFill = magBarContainer:Object(nil, {
        x = -30,
        w = lvgl.PCT(200),
        h = 0, -- starts empty
        bg_color = "#00FF00",
        y = magBarContainerHeight -- start at bottom
    })
    magBarContainer:clear_flag(lvgl.FLAG.SCROLLABLE)

    local backBtn = CreateBtn(root, "< Back")
    backBtn:onClicked(function()
        sensor:stop()
        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

function OpenMag(name, path, props, propsFormat)
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