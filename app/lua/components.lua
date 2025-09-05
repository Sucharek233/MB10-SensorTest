local lvgl = require("lvgl")

local padding = 20
local globalWidth = lvgl.HOR_RES()
-- local globalWidth = 212
local globalHeight = lvgl.VER_RES()

ContentWidth = globalWidth - (padding * 2)
ContentHeight = globalHeight - (padding * 2)

DefFont = "MiSans-Regular"
DefFontSize = 14

-- Containers
function CreateRoot()
    local main = lvgl.Object(nil, {
        w = globalWidth,
        h = globalHeight,
        x = 0,
        y = 0,
        bg_color = 0,
        bg_opa = lvgl.OPA(100),
        border_width = 0,
        pad_all = padding
    })
    main:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    local root = lvgl.Object(main, {
        outline_width = 0,
        border_width = 0,
        pad_all = 0,
        bg_color = 0,
        align = lvgl.ALIGN.TOP_LEFT,
        x = 0,
        y = 0,
        w = lvgl.PCT(100),
        h = lvgl.PCT(100),
        flex = {
            flex_direction = "row",
            flex_wrap = "wrap",
            justify_content = "center",
            align_items = "center",
            align_content = "center",
        }
    })
    root:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    return main, root
end

function CreateRootLocked()
    local lockedMain, lockedRoot = CreateRoot()

    lockedMain:clear_flag(0xFFFF)
    -- lockedRoot:clear_flag(0xFFFF)
    lockedMain:clear_flag(lvgl.FLAG.SCROLLABLE)
    -- lockedRoot:clear_flag(lvgl.FLAG.SCROLLABLE)
    
    lockedMain:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    return lockedMain, lockedRoot
end

-- Buttons
function CreateBtn(parent, name)
    local root = parent:Object(nil, {
        w = ContentWidth,
        h = 65,
        bg_color = "#222",
        bg_opa = lvgl.OPA(100),
        border_width = 0,
        radius = 16,
        pad_all = 16,
        shadow_width = 8,
        shadow_color = "#111",
    })
    root:clear_flag(lvgl.FLAG.SCROLLABLE)
    root:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    local label = root:Label {
        text = name,
        text_color = "#eee",
        text_font = lvgl.Font(DefFont, DefFontSize),
        align = lvgl.ALIGN.CENTER,
    }
    label:clear_flag(lvgl.FLAG.SCROLLABLE)

    return root, label
end

-- Labels
function CreateLabel(parent, name)
    local label = parent:Label(nil, {
        w = lvgl.SIZE_CONTENT,
        h = lvgl.SIZE_CONTENT,
        bg_opa = lvgl.OPA(0),
        border_width = 0,
        text_font = lvgl.Font(DefFont, DefFontSize),
        text = name
    })
    label:clear_flag(lvgl.FLAG.SCROLLABLE)
    label:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    return label
end

function CreateCenteredLabel(parent, name)
    local root = parent:Object(nil, {
        w = ContentWidth,
        h = 20,
        bg_color = 0,
        bg_opa = lvgl.OPA(100),
        border_width = 0
    })
    root:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    local label = root:Label {
        text = name,
        text_color = "#eee",
        align = lvgl.ALIGN.CENTER,
        text_font = lvgl.Font(DefFont, 18)
    }

    return root, label
end

function CreateInfoLabel(parent)
    local root, infoLabel = CreateCenteredLabel(parent, "")

    root:set {
        flex_grow = 1,
        width = ContentWidth,
        bg_color = "#191919"
    }

    infoLabel:set {
        align = lvgl.ALIGN.TOP_LEFT
    }

    return root, infoLabel
end

-- More Containers
function CreateExpandingContainer(parent)
    local container = parent:Object(nil, {
        w = ContentWidth,
        bg_color = "#000",
        bg_opa = lvgl.OPA(100),
        border_width = 0,
        flex_grow = 1
    })
    container:clear_flag(lvgl.FLAG.SCROLLABLE)
    container:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    return container
end

function CreateFlexboxContainer(parent)
    local flexbox = lvgl.Object(parent, {
        outline_width = 0,
        border_width = 0,
        pad_all = 0,
        bg_color = 0,
        -- align = lvgl.ALIGN.TOP_LEFT,
        -- x = 0,
        -- y = 0,
        w = ContentWidth,
        flex = {
            flex_direction = "column",
            flex_wrap = "nowrap",
            justify_content = "flex-start",
            align_items = "center",
            align_content = "flex-start",
        },
        flex_grow = 1
    })
    flexbox:add_flag(lvgl.FLAG.EVENT_BUBBLE)

    return flexbox
end

-- Popup
local shownPopups = {}
-- everything will be recreated every single time a popup is shown
-- I'm doing this to make sure the popup is always on the top of everything else
function ShowPopup(title, message, id, callback)
    -- if id is passed, the popup gets shown only once
    -- if id isn't passed, the popup can be shown an infinite amount of times
    if id and shownPopups[id] then
        callback()
        return
    end

    local scr, root = CreateRootLocked()
    root:set {
        flex = {
            flex_direction = "column"
        }
    }

    CreateCenteredLabel(root, title)

    local _, popupMessage = CreateInfoLabel(root)
    popupMessage:set {
        text = message,
        w = lvgl.PCT(100)
    }

    local closeBtn = CreateBtn(root, "Close")
    closeBtn:onClicked(function()
        scr:delete()
        callback()
    end)

    if id then
        shownPopups[id] = true
    end
end