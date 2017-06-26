-- Corona SDK composer basic template file

local widget = require('widget')
local composer = require('composer')
local scene = composer.newScene()

local Bird = require('classes.bird').new
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local bird, bg_color
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create(event)
    local group = self.view

    local bgs = {
        'day', 
        'night'
    }
    bg_color = bgs[math.random(#bgs)]

    local background = display.newImageRect("sprites/background_" .. bg_color .. ".png", 144, 256)
    background.anchorX, background.anchorY = 0, 0
    background.x, background.y = 0, 0

    local brand = display.newImageRect("sprites/label_flappy_bird.png", 89, 24)
    brand.x, brand.y = display.contentCenterX, display.contentCenterY - 80
    
    bird = Bird({ x = display.contentCenterX, y = 100, static = true })
    bird:setSequence('menu')
    bird:play()

    local me = display.newText("@xupisco", display.contentWidth, display.contentHeight - 13, 24, 10, native.systemFont, 4)
    me.anchorX = 1
    me:setFillColor(0, 0, 0, 0.8)
    me.alpha = 0

    local btn_play = widget.newButton({
        width = 52,
        height = 29,
        defaultFile = "sprites/button_play_normal.png",
        overFile = "sprites/button_play_pressed.png",
        onEvent = gotoGame
    })
    btn_play.x = display.contentCenterX
    btn_play.y = display.contentCenterY + 20

    local ground = display.newImageRect("sprites/ground.png", 168, 56)
    ground.anchorX, ground.anchorY = 0, 0
    ground.x, ground.y = 0, display.contentHeight - ground.height

    group:insert(background)
    group:insert(brand)
    group:insert(bird)
    group:insert(btn_play)
    group:insert(ground)
    group:insert(me)
end

function gotoGame(event)
    if(event.phase == "ended") then
        composer.gotoScene('scenes.get_ready', {
            params = {
                bird_color = bird:getColor(),
                bg_color = bg_color
            },
            effect = "fade",
            time = 500 })
    end
end

-- Touch listener
local function onTouchEvent(event)
    if event.phase == "began" then
        gotoGame()
    end
end
 
 
-- show()
function scene:show(event)
    local group = self.view
    local phase = event.phase
 
    if (phase == 'will') then
    elseif (phase == 'did') then
    end
end
 
 
-- hide()
function scene:hide(event)
    local group = self.view
    local phase = event.phase
 
    if (phase == 'will') then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif (phase == 'did') then
        -- Code here runs immediately after the scene goes entirely off screen
     end
end
 
 
-- destroy()
function scene:destroy( event )
    local group = self.view
    -- Code here runs prior to the removal of scene's view
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------
 
return scene
