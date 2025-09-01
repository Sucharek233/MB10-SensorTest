local lvgl = require("lvgl")

-- load our submodules
require "extraFunctions"
require "sensorFunctions.sensorInfo"

local scr, root

local sensorListContainer
local predefinedSensorListContainer

local function initSensorList()
    sensorListContainer = CreateFlexboxContainer(root)

    local sensors = GetSensorList()
    for _, sensor in ipairs(sensors) do
        local sensorBtn = CreateBtn(sensorListContainer, sensor)
        sensorBtn:set {
            w = ContentWidth,
            h = 50,
            bg_color = "#222",
            text_color = "#eee",
            text_font = lvgl.Font(DefFont, 18)
        }
        sensorBtn:clear_flag(lvgl.FLAG.SCROLLABLE)

        sensorBtn:onClicked(function()
            OpenRaw(sensor, sensor)
        end)
    end
    
    sensorListContainer:add_flag(lvgl.FLAG.HIDDEN)
end

local function initPredefinedSensorList()
    predefinedSensorListContainer = CreateFlexboxContainer(root)

    for _, sensor in ipairs(PredefinedSensorList) do
        local sensorBtn, sensorBtnLabel = CreateBtn(predefinedSensorListContainer, sensor.name)
        sensorBtn:set {
            w = ContentWidth,
            h = 50,
            bg_color = "#222",
            text_color = "#eee"
        }
        sensorBtnLabel:set {
            text_font = lvgl.Font(DefFont, 16)
        }
        sensorBtn:clear_flag(lvgl.FLAG.SCROLLABLE)

        sensorBtn:onClicked(function()
            sensor.open(sensor.name, sensor.path, sensor.props, sensor.propsFormat)
        end)
    end

    predefinedSensorListContainer:add_flag(lvgl.FLAG.HIDDEN)
end

local function init()
    scr, root = CreateRootLocked()
    root:set {
        flex = {
            flex_direction = "column",
        }
    }

    local _, title = CreateCenteredLabel(root, "Sensor List")
    title:clear_flag(lvgl.FLAG.SCROLLABLE)

    initPredefinedSensorList()
    initSensorList()

    local backBtn = CreateBtn(root, "< Back")
    backBtn:set {
        bg_color = "#191919",
    }
    backBtn:onClicked(function ()
        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

function LoadSensorList(type)
    if not scr then
        init()
    end

    -- I mean it's not good but uhh it works ;)
    if type == "predefined" then
        predefinedSensorListContainer:clear_flag(lvgl.FLAG.HIDDEN)
        sensorListContainer:add_flag(lvgl.FLAG.HIDDEN)
    else
        sensorListContainer:clear_flag(lvgl.FLAG.HIDDEN)
        predefinedSensorListContainer:add_flag(lvgl.FLAG.HIDDEN)
    end

    scr:clear_flag(lvgl.FLAG.HIDDEN)
end