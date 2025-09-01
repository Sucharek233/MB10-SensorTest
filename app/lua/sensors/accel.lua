local scr, root

local sensor
local sensorName, sensorPath, sensorProps, sensorPropsFormat

local gameContainer

local gameUpdate

-- screen size (adjust if needed)
local screenW, screenH = 0, 0
local ball, target
local ballX, ballY = 0, 0
local speed = 1

local sizeInitialized = false

local ballPulseAnimation

local score = 0
local scoreLabel

local rawValuesLabel

local ballRadius = 10
local targetRadius = 10

local function sensorCallback(topic, status, value)
    if status ~= 0 or not value or #value == 0 then
        print("invalid sensor")
        return
    end

    local values = value[1]

    local strValues = GenerateStringValues({values.x, values.y, values.z}, sensorProps, sensorPropsFormat)
    rawValuesLabel:set {
        text = strValues,
        h = lvgl.SIZE_CONTENT
    }

    gameUpdate(values.x * -1, values.y) -- x axis inverted
end

function gameUpdate(ax, ay)
    if not sizeInitialized then -- running get_pos() after creating an object will always return 0,0,0,0, that's why I need to initialize the size later (here)
        local position = gameContainer:get_pos()
        screenW = math.abs(position.x1 - position.x2) - ballRadius * 2
        screenH = math.abs(position.y1 - position.y2) - ballRadius * 2

        target:set {
            x = screenW - 40,
            y = screenH - 40
        }
        target:clear_flag(lvgl.FLAG.HIDDEN)

        sizeInitialized = true
    end

    -- move ball
    ballX = ballX + ax * speed
    ballY = ballY + ay * speed

    -- clamp to screen
    if ballX < ballRadius then ballX = ballRadius end
    if ballY < ballRadius then ballY = ballRadius end
    if ballX > screenW - ballRadius then ballX = screenW - ballRadius end
    if ballY > screenH - ballRadius then ballY = screenH - ballRadius end

    -- update ball position
    ball:set {
        x = ballX - ballRadius,
        y = ballY - ballRadius
    }

    -- check collision with target
    local pos = target:get_pos()
    local tx = (pos.x1 + pos.x2) / 2
    local ty = (pos.y1 + pos.y2) / 2
    local dx, dy = (ballX - tx), (ballY - ty)
    if dx*dx + dy*dy < (ballRadius*ballRadius*4) then
        score = score + 1
        scoreLabel:set {
            text = "Score: " .. score
        }

        -- move target to random spot
        local spawnPadding = 20
        local newX = math.random(spawnPadding, screenW - spawnPadding)
        local newY = math.random(spawnPadding, screenH - spawnPadding)
        ballPulseAnimation:start()


        target:set {
            x = newX,
            y = newY,
            bg_color = "#FF0000" -- reset color
        }
    end
end

local function init()
    root:set {
        flex = {
            flex_direction = "column",
        }
    }

    CreateCenteredLabel(root, sensorName)

    local scoreLabelContainer
    scoreLabelContainer, scoreLabel = CreateCenteredLabel(root, "Score: 0")
    scoreLabelContainer:set {
        h = 15
    }
    scoreLabel:set {
        text_font = lvgl.Font(DefFont, DefFontSize)
    }

    gameContainer = CreateExpandingContainer(root)

    rawValuesLabel = CreateLabel(gameContainer, "")

    -- ball
    ball = gameContainer:Object(nil, {
        w = ballRadius*2,
        h = ballRadius*2,
        bg_color = "#0000FF",
        border_width = 0,
        radius = lvgl.RADIUS_CIRCLE,
        x = ballX,
        y = ballY
    })

    local animDuration = 200
    ballPulseAnimation = ball:Anim({
        start_value = 0,
        end_value = 100,
        duration = animDuration,
        playback_time = animDuration,
        repeat_count = 1,
        exec_cb = function(obj, v)
            local t = v / 100
            local color = LerpColor("#0000FF", "#00FF00", t)
            obj:set {
                bg_color = color
            }
        end
    })

    -- target
    target = gameContainer:Object(nil, {
        w = targetRadius * 2,
        h = targetRadius * 2,
        bg_color = "#FF0000",
        border_width = 0,
        radius = lvgl.RADIUS_CIRCLE,
        x = 100,
        y = 100
    })
    target:add_flag(lvgl.FLAG.HIDDEN)

    local backBtn = CreateBtn(root, "< Back")
    backBtn:onClicked(function()
        sensor:stop()
        scr:add_flag(lvgl.FLAG.HIDDEN)
    end)
end

function OpenAccel(name, path, props, propsFormat)
    if not scr then
        scr, root = CreateRootLocked()

        sensorName = name
        sensorPath = path
        sensorProps = props
        sensorPropsFormat = propsFormat

        sensor = GetSensorTopic(sensorPath, Period, sensorCallback)

        init()
    else
        scr:clear_flag(lvgl.FLAG.HIDDEN)
    end

    sensor:start()
end
