local function HSVtoRGB(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    r, g, b = (r + m) * 255, (g + m) * 255, (b + m) * 255
    return math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5)
end

local scr, root
local backBtnAnim

local function init()
    scr, root = CreateRootLocked()
    root:set {
        flex = {
            flex_direction = "column"
        }
    }

    CreateCenteredLabel(root, "About")

    local aboutText =
[[Sensor Test
Version 1.1

Test your sensors with interactive little games
You can view raw readings from all sensors too.

Made by Sucharek233 :)
This app is open source! Check it out on GitHub: https://github.com/Sucharek233/MB10-SensorTest

WARNING!
Some sensors can freeze and restart your band.
In case of a complete freeze, connect your charger quickly 10 times in a row.]]
    local _, label = CreateInfoLabel(root)
    label:set {
        text = aboutText,
        text_font = lvgl.Font(DefFont, 16),
        w = lvgl.PCT(100)
    }

    local backBtn = CreateBtn(root, "< Back")
    backBtnAnim = backBtn:Anim({
        start_value = 0,
        end_value = 360,
        duration = 4000,
        repeat_count = lvgl.ANIM_REPEAT_INFINITE,
        exec_cb = function(obj, v)
            local r, g, b = HSVtoRGB(v, 1, 0.5)
            obj:set {
                bg_color = string.format("#%02X%02X%02X", r, g, b)
            }
        end,
        path = "linear"
    })
    backBtn:onClicked(function ()
        scr:add_flag(lvgl.FLAG.HIDDEN)
        backBtnAnim:stop()
    end)
end

function ShowAbout()
    if not scr then
        init()
    end

    scr:clear_flag(lvgl.FLAG.HIDDEN)

    backBtnAnim:start()
end