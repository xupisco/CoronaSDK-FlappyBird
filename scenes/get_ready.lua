-- Corona SDK composer basic template file

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

    -- BG
    local bgs = {
        'day', 
        'night'
    }

    bg_color = bgs[math.random(#bgs)]
    bird_color = "orange"

    if(event.params) then
        bg_color = event.params.bg_color
        bird_color = event.params.bird_color
    end
    
    pipes_color = bg_color

    local background = display.newImageRect("sprites/background_" .. bg_color .. ".png", 144, 256)
    background.anchorX, background.anchorY = 0, 0
    background.x, background.y = 0, 0

    local ready = display.newImageRect("sprites/label_get_ready.png", 92, 25)
    ready.x, ready.y = display.contentCenterX, display.contentCenterY - 80
    
    local instructions = display.newImageRect('sprites/instructions.png', 57, 49)
    instructions.x, instructions.y = display.contentCenterX, display.contentCenterY - 20
    
    bird = Bird({ color = bird_color, x = 40, y = 100, static = true })

    local ground = display.newImageRect("sprites/ground.png", 168, 56)
    ground.anchorX, ground.anchorY = 0, 0
    ground.x, ground.y = 0, display.contentHeight - ground.height

    group:insert(background)
    group:insert(ready)
    group:insert(instructions)
    group:insert(bird)
    group:insert(ground)
end

function gotoGame()
    composer.gotoScene('scenes.game', { params = { bird_color = bird:getColor(), bg_color = bg_color }})
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
        Runtime:addEventListener('touch', onTouchEvent)
    end
end
 
 
-- hide()
function scene:hide(event)
    local group = self.view
    local phase = event.phase
 
    if (phase == 'will') then
        Runtime:removeEventListener('touch', onTouchEvent)
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
