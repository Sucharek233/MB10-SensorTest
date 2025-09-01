local scr, root

local sensor
local sensorName, sensorPath

local mainLabel
local infoLabel

local sensorCallback

local function init()
    root:set {
        flex = {
            flex_direction = "column",
        }
    }

    _, mainLabel = CreateCenteredLabel(root, sensorName)

    _, infoLabel = CreateInfoLabel(root)
    infoLabel:set {
        text = "Waiting for data...",
        text_font = lvgl.Font(DefFont, DefFontSize)
    }

    local btn = CreateBtn(root, "< Back")
    btn:onClicked(function()
        sensor:stop()

        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

local function updateVariables(name, path)
    sensorName = name
    sensorPath = path

    mainLabel:set {
        text = sensorName
    }

    infoLabel:set {
        text = "Waiting for data..."
    }

    sensor:close()

    sensor = GetSensor(sensorPath, Period, sensorCallback)
end

function sensorCallback(data)
    local str = ""
    str = str .. "timestamp:\n" .. data.timestamp .. "\n\nvalues:\n";
    for _, value in ipairs(data.values) do
        str = str .. value .. "\n";
    end

    infoLabel:set {
        text = str
    }
end

function OpenRaw(name, path)
    if not scr then
        scr, root = CreateRootLocked()

        sensorName = name
        sensorPath = path

        sensor = GetSensor(sensorPath, Period, sensorCallback)

        init()
    else
        scr:clear_flag(lvgl.FLAG.HIDDEN)
    end

    if sensorName ~= name then
        updateVariables(name, path)
    end

    sensor:start()
end