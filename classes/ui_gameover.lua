-- Bird Class
local widget = require('widget')
local composer = require('composer')

local _M = {}
local score_text
local go_group

local options = {
    width = 7,
    height = 10,
    numFrames = 10
}

local score_sheet = graphics.newImageSheet("sprites/number_middle_ss.png", options)

local function cleanGroup(g)
    while g.numChildren > 0 do
        local c = g[1]
        if c then c:removeSelf() end
    end
end

local function buildSpriteSheet(score, g)
    score_string = tostring(score)
    local char_width = 7
    
    cleanGroup(g)
    
    for i=1, string.len(score_string) do
        local char = score_string:sub(i, i)
        local score_char = display.newImage(score_sheet, tonumber(char) + 1)
        score_char.x = char_width * (i - 1)
        g:insert(score_char)
    end

    local left_limit = 114

    g.x = left_limit - (char_width * (string.len(score_string) - 1))
    go_group:insert(g)
    return g
end

function _M.new(params)
    local bg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg:setFillColor(0, 0, 0, 0.75)

    go_group = display.newGroup()
    score = params.score

    local medal_type = "bronze"

    if(score > 50) then
        medal_type = "gold"
    end
    if(score > 100) then
        medal_type = "platinum"
    end

    local go_label = display.newImageRect("sprites/label_game_over.png", 96, 21)
    local panel = display.newImageRect("sprites/panel_score.png", 113, 57)
    local medal = display.newImageRect("sprites/medal_" .. medal_type .. ".png", 22, 22)

    if score < 20 then
        medal.alpha = 0
    end

    go_label.x = display.contentCenterX
    go_label.y = display.contentCenterY - 80
    panel.x = display.contentCenterX
    panel.y = display.contentCenterY - 20
    medal.x, medal.y = 40, 112

    local new = display.newImageRect("sprites/label_new.png", 16, 7)
    new.x, new.y = 90, 112
    new.alpha = 0

    local hs = system.getPreference('app', 'highscore', 'number')
    if hs == nil then
        hs = score
        system.setPreferences('app', { highscore = score })
    end
    if score > hs then
        hs = score
        new.alpha = 1
        system.setPreferences('app', { highscore = score })
    end

    local latest_score = buildSpriteSheet(score, display.newGroup())
    latest_score.y = 101

    local high_score = buildSpriteSheet(hs, display.newGroup())
    high_score.y = 122

    local btn_play = widget.newButton({
        width = 52,
        height = 29,
        defaultFile = "sprites/button_play_normal.png",
        overFile = "sprites/button_play_pressed.png",
        onEvent = function(event)
            if(event.phase == 'ended') then
                composer.gotoScene('scenes.get_ready', {
                    effect = "slideLeft",
                    time = 1000 })
            end
        end
    })
    btn_play.x = display.contentCenterX
    btn_play.y = display.contentCenterY + 40

    local btn_menu = widget.newButton({
        width = 40,
        height = 14,
        defaultFile = "sprites/button_menu.png",
        overFile = "sprites/button_menu.png",
        onEvent = function(event)
            if(event.phase == 'ended') then
                composer.gotoScene('scenes.menu', {
                    effect = "fromBottom",
                    time = 1000 })
            end
        end
    })
    btn_menu.x = display.contentCenterX
    btn_menu.y = display.contentHeight - 30

    go_group:insert(bg)
    go_group:insert(go_label)
    go_group:insert(panel)
    go_group:insert(btn_play)
    go_group:insert(medal)
    go_group:insert(new)
    go_group:insert(btn_menu)
    latest_score:toFront()
    high_score:toFront()

    return go_group
end

return _M