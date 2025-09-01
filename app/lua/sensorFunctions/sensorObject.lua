local io = require("io")
local topic = require("topic")

local sensorPath = "/dev/uorb"

Period = 50 -- 20x per second

-- For anyone reading this code
-- yes, AI wrote this function
-- it doesn't work with everything of course
-- but sensors like accel, gyro, magnetometer, light all work perfectly
-- keep in mind the results are buffered on real hardware, so you'll get multiple readings in one
local function read_uorb_generic(f)
    local data = f:read("*a")

    if not data or #data < 12 then
        return nil
    end

    -- unpack timestamp (two uint32 little endian)
    local ts_lo, ts_hi = string.unpack("<I4I4", data, 1)
    local timestamp = ts_hi << 32 | ts_lo

    local values = {}
    local i = 9  -- start after timestamp (8 bytes)
    while i <= #data - 3 do
        local val
        val, i = string.unpack("<f", data, i)

        -- check for NaN marker (0x7FC00000)
        if val ~= val then  -- NaN check in Lua
            break
        end

        table.insert(values, val)
    end

    return {timestamp = timestamp, values = values}
end


function GetSensor(sensorName, period, callback)
    local path = sensorPath .. "/" .. sensorName

    local sensor = {}
    sensor._path = path
    sensor._period = period
    sensor._callback = callback
    sensor._file = io.open(path, "rb")
    sensor._started = false

    sensor._timer = lvgl.Timer({
        paused = true,
        period = period,
        repeat_count = -1,
        cb = function()
            if not sensor._started then return end
            -- seek back to start before reading fresh data
            local reading = read_uorb_generic(sensor._file)
            if reading and sensor._callback then
                sensor._callback(reading)
            end
        end
    })

    function sensor:start()
        if self._started then return end
        self._started = true
        self._timer:resume()
    end

    function sensor:stop()
        if not self._started then return end
        self._started = false
        self._timer:pause()
    end

    function sensor:close()
        self:stop()
        if self._file then
            self._file:close()
            self._file = nil
        end
    end

    return sensor
end

-- this function that freezes the band in most cases
-- the only reason why this is here, is because I can get data from the accelerometer at a faster rate
-- but still, it's nice having both options available
function GetSensorTopic(name, frequency, callback)
    local sensor = {}
    sensor._name = name
    sensor._frequency = frequency
    sensor._callback = callback
    sensor._sub = nil

    function sensor:start()
        if self._sub then return end
        self._sub = topic.subscribe(name, callback)
        self._sub:frequency(self._frequency)
    end

    function sensor:stop()
        if self._sub then
            self._sub:unsubscribe()
            self._sub = nil
        end
    end

    return sensor
end