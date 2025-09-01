local lvgl = require("lvgl")

require "sensorFunctions.sensorObject"

require "sensors.accel"
require "sensors.gyro"
require "sensors.mag"
require "sensors.light"
require "sensors.comp"
require "sensors.tilt"

require "sensors.raw"

local sensorPath = "/dev/uorb"

PredefinedSensorList = {
    {
        key = "accel",
        name = "Accelerometer",
        path = "sensor_accel0",
        props = {"x", "y", "z"},
        propsFormat = {
            propFirst = true,
            separateProp = nil
        },
        open = OpenAccel
    },
    {
        key = "gyro",
        name = "Gyroscope",
        path = "sensor_gyro0",
        props = {"x", "y", "z"},
        propsFormat = {
            propFirst = true,
            separateProp = nil
        },
        open = OpenGyro
    },
    {
        key = "mag",
        name = "Magnetometer",
        path = "sensor_mag_uncal0", -- CHANGE BACK TO sensor_mag_uncal0!!!!!!!!!!!
        props = {"x", "y", "z"},
        propsFormat = {
            propFirst = true,
            separateProp = nil
        },
        open = OpenMag
    },
    {
        key = "light",
        name = "Light Sensor",
        path = "sensor_light0",
        props = {"lux"},
        propsFormat = {
            propFirst = false,
            separateProp = true
        },
        open = OpenLight
    },
    {
        key = "comp",
        name = "Compass",
        path = "algo_compass0",
        props = {"_", "°"},
        propsFormat = {
            propFirst = false,
            separateProp = false
        },
        open = OpenCompass
    },
    {
        key = "tilt",
        name = "Wrist Tilt",
        path = "algo_wrist_tilt0",
        props = {"_"},
        propsFormat = {
            propFirst = nil,
            separateProp = nil
        },
        open = OpenTilt
    }
}

function GenerateStringValues(values, props, propsFormat)
    local lines = {}
    local sep = propsFormat.separateProp and " " or ""

    for i, prop in ipairs(props) do
        if prop == "_" then
            goto continue
        end

        local value = values[i] or nil


        value = RoundTrailZeroes(value, 3)

        if propsFormat.propFirst then
            lines[#lines + 1] = string.format("%s: %s", prop, value)
        else
            lines[#lines + 1] = string.format("%s%s%s", value, sep, prop)
        end

        ::continue::
    end

    return table.concat(lines, "\n")
end

function GetSensorList()
    local sensors = {}
    local dir, msg, code = lvgl.fs.open_dir(sensorPath)
    if not dir then
        print("open dir failed: ", msg, code)
        return
    end

    while true do
        local d = dir:read()
        if not d then break end
        table.insert(sensors, d)
    end
    dir:close()
    
    return sensors
end