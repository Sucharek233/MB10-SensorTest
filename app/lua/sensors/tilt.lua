local scr, root

local sensor
local sensorName, sensorPath, sensorProps, sensorPropsFormat

local infoLabel

local gameContainer

local bgPulseAnimation

-- sensor callback
local function sensorCallback(_)
    bgPulseAnimation:start()
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
        },
        bg_color = "#000"
    }

    local animDuration = 600
    bgPulseAnimation = gameContainer:Anim({
        start_value = 0,
        end_value = 100,
        duration = animDuration,
        playback_time = animDuration,
        repeat_count = 1,
        exec_cb = function(obj, v)
            local t = v / 100
            local color = LerpColor("#000000", "#00AF00", t)
            obj:set {
                bg_color = color
            }

            infoLabel:set {
                text = "Tilt detected!"
            }
        end,
        done_cb = function(_)
            -- after pulse finishes, reset label
            infoLabel:set {
                text = "Waiting..."
            }
        end,
        path = "ease_in_out" -- smoother easing
    })

    infoLabel = CreateLabel(gameContainer, "")
    infoLabel:set {
        text = "Waiting...",
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

function OpenTilt(name, path, _, _)
    if not scr then
        scr, root = CreateRootLocked()

        sensorName = name
        sensorPath = path
        -- sensorProps = props
        
        sensor = GetSensor(sensorPath, Period, sensorCallback)
        
        init()
    else
        scr:clear_flag(lvgl.FLAG.HIDDEN)
    end

    sensor:start()
end