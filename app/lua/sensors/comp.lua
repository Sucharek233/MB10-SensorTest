local scr, root

local sensor
local sensorName, sensorPath, sensorProps, sensorPropsFormat

local compassContainer
local needle
local headingLabel

local currentAngle = 0
local function shortestPathAngle(from, to)
    local diff = (to - from + 1800) % 3600 - 1800
    return from + diff
end

local function animateNeedle(targetAngle)
    targetAngle = shortestPathAngle(currentAngle, targetAngle)

    local anim = needle:Anim({
        start_value = currentAngle,
        end_value = targetAngle,
        duration = 100,
        exec_cb = function(obj, v)
            obj:set {
                transform_angle = v
            }

            -- local labelValue = Round(math.abs(v / 10), 3) % 360
            -- headingLabel:set {
            --     text = "Heading: " .. GenerateStringValues({-1, labelValue}, sensorProps, sensorPropsFormat)
            -- }

        end,
        path = "ease_in_out" -- smoother easing
    })

    anim:start()

    -- Save last angle
    currentAngle = targetAngle
end

-- update needle rotation based on heading
local function updateCompass(degrees)
    -- rotate needle
    local targetAngle = degrees * 10
    animateNeedle(targetAngle)

    -- update text
    headingLabel:set {
        text = "Heading: " .. GenerateStringValues({-1, degrees}, sensorProps, sensorPropsFormat)
    }
end

-- sensor callback
local function sensorCallback(data)
    local heading = data.values[2]  -- SET TO 2 LATER!!!!
    updateCompass(heading)
end

local function init()
    root:set {
        flex = {
            flex_direction = "column",
            align_items = "center"
        }
    }

    CreateCenteredLabel(root, sensorName)

    compassContainer = CreateExpandingContainer(root)
    compassContainer:set {
        flex = {
            flex_direction = "row",
            flex_wrap = "wrap",
            justify_content = "center",
            align_items = "center",
            align_content = "center",
        }
    }

    -- compass base circle
    local circleSize = ContentWidth / 1.5
    local compassCircle = compassContainer:Object(nil, {
        w = circleSize,       -- diameter of the circle
        h = circleSize,
        bg_color = "#222222",
        radius = lvgl.RADIUS_CIRCLE,   -- half of width/height to make it fully circular
        border_width = 4,
        border_color = "#FFFFFF",
        clip_corner = true, -- ensure needle stays within bounds
        flex = {
            flex_direction = "row",
            flex_wrap = "wrap",
            justify_content = "center",
            align_items = "center",
            align_content = "center",
        }
    })

    -- needle object (arrow pointing up initially)
    local needleHeight = (circleSize / 2) - (circleSize / 10) -- leave a bit of space at the end
    needle = compassCircle:Object(nil, {
        w = 10,
        h = needleHeight,
        bg_color = "#FF0000",
        radius = 2,

        -- bottom-center pivot
        transform_pivot_x = 5,             -- half width
        transform_pivot_y = needleHeight,  -- bottom edge

        -- move pivot to the circle center
        translate_y = -(needleHeight / 2),
    })

    headingLabel = CreateLabel(root, "Heading: 0°")
    headingLabel:set {
        h = 50,
        pad_all = 16
    }

    local backBtn = CreateBtn(root, "< Back")
    backBtn:onClicked(function()
        sensor:stop()
        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

function OpenCompass(name, path, props, propsFormat)
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