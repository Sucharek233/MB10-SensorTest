require "components"
require "about"
require "sensorFunctions.sensorList"

local root

local function entry()
    _, root = CreateRoot()
    
    local _, title = CreateCenteredLabel(root, "Sensor Test")
    title:set {
        text_font = lvgl.Font(DefFont, 20)
    }
    
    local knownBtn, knownBtnLabel = CreateBtn(root, "Known Sensors")
    knownBtnLabel:set {
        text_font = lvgl.Font(DefFont, 16)
    }
    knownBtn:onClicked(function ()
        LoadSensorList("predefined")
    end)

    local allBtn, allBtnLabel = CreateBtn(root, "All Sensors")
    allBtnLabel:set {
        text_font = lvgl.Font(DefFont, 16)
    }
    allBtn:onClicked(function ()
        local popupText =
[[Some sensors may cause your band to freeze or restart.
If your band becomes unresponsive, quickly connect and disconnect the charger 10 times in a row (10 times in 5 seconds).]]
        ShowPopup("Warning!", popupText, "allSensorsWarning", function()
            LoadSensorList("all")
        end)
    end)

    local aboutBtn, aboutBtnLabel = CreateBtn(root, "About")
    aboutBtnLabel:set {
        text_font = lvgl.Font(DefFont, 16)
    }
    aboutBtn:onClicked(function ()
        ShowAbout()
    end)
end

-- execute watchface function
entry()
