-- Score Class

local _M = {}
local score_text

local options = {
    width = 12,
    height = 18,
    numFrames = 10
}

local score_sheet = graphics.newImageSheet("sprites/number_large_ss.png", options)

local function cleanGroup()
    while score_text.numChildren > 0 do
        local c = score_text[1]
        if c then c:removeSelf() end
    end
end

local function buildSpriteSheet(score)
    score_string = tostring(score)
    local char_width = 12
    
    cleanGroup()
    
    for i=1, string.len(score_string) do
        local char = score_string:sub(i, i)
        local score_char = display.newImage(score_sheet, tonumber(char) + 1)
        score_char.x = char_width * (i - 1)
        score_text:insert(score_char)
    end

    score_text.x = display.contentCenterX - ((string.len(score_string) - 1) * char_width) / 2
    score_text.y = 40
end

function _M.new(params)
    local current_score = 0
    local score_char = display.newImage(score_sheet, 1)

    score_text = display.newGroup()
    score_text:insert(score_char)
    score_text.x = display.contentCenterX
    score_text.y = 40

    function score_text:add(amount)
        current_score = current_score + amount
        buildSpriteSheet(current_score)
    end

    function score_text:getScore()
        return current_score
    end

    return score_text
end

return _M