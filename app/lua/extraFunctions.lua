function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function LerpColor(c1, c2, t)
    local r1, g1, b1 = tonumber(c1:sub(2,3),16), tonumber(c1:sub(4,5),16), tonumber(c1:sub(6,7),16)
    local r2, g2, b2 = tonumber(c2:sub(2,3),16), tonumber(c2:sub(4,5),16), tonumber(c2:sub(6,7),16)
    local r = math.floor(r1 + (r2 - r1) * t)
    local g = math.floor(g1 + (g2 - g1) * t)
    local b = math.floor(b1 + (b2 - b1) * t)
    return string.format("#%02X%02X%02X", r, g, b)
end

function MapValue(val, inMin, inMax, outMin, outMax)
    return (val - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function Clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

function Round(val, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(val * mult + 0.5) / mult
end

function RoundTrailZeroes(val, decimals)
    decimals = decimals or 0
    local rounded = Round(val, decimals)
    return string.format("%." .. decimals .. "f", rounded)
end