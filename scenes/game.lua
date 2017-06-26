-----------------------------------------------------------------------------------------
--
-- scenes/game.lua
--
-----------------------------------------------------------------------------------------

local composer = require('composer')
local widget = require('widget')
local physics = require('physics')

local scene = composer.newScene()

physics.start()
physics.setGravity(0, 20)
--physics.setDrawMode('hybrid')


-- Classes
local Bird = require('classes.bird').new
local Score = require('classes.score').new
local GameOver = require('classes.ui_gameover').new

-- Variables
local halfW = display.contentWidth / 2
local halfH = display.contentHeight / 2
local defaultPlayerYOffset = 30
local walkingSpeed = 2500
local pipeYRandomness = 50
local pipeMinDistance = 50
local pipeSpawnDelay = 1500
local playing = true
local pipes_color

local ground
local groundloop
local spawnTimer

local scoreSound
local dieSound
local hitSound
local swooshSound

-- Objects
local bird, score

-- Groups
local decoration_group = display.newGroup() 
local pipes_group = display.newGroup()
local grounds_group = display.newGroup()
local ui_group = display.newGroup()
local player_group = display.newGroup()
local group

if not playing then
    physics.pause()
end


local function handlePause(event)
    if(event.phase == "ended") then
        if playing then
            --pause_bg = display.newRect(halfW, halfH, display.contentWidth, display.contentHeight)
            --pause_text = display.newText("Tap again to continue...", halfW + 10, display.contentHeight - 55, 80, 20, native.systemFont, 6)
            --pause_text:setFillColor(0, 0, 0, 0.9)
            --pause_bg:setFillColor(1, 1, 1, 0.5)
            --pause_text:toFront()
            --ui_group:insert(pause_bg)
            --ui_group:insert(pause_text)
            playing = false
            physics.pause()
            transition.pause()
            timer.pause(spawnTimer)
        else
            playing = true
            physics.start()
            transition.resume()
            timer.resume(spawnTimer)
            --pause_bg:removeSelf()
            --pause_text:removeSelf()
        end
    end
end

-- create()
function scene:create(event)
    group = self.view

    -- BG
    local bgs = {
        'day', 
        'night'
    }

    local bg_color = bgs[math.random(#bgs)]
    local bird_color = "orange"

    if(event.params) then
        bg_color = event.params.bg_color
        bird_color = event.params.bird_color
    end
    local background = display.newImageRect("sprites/background_" .. bg_color .. ".png", 144, 256)
    pipes_color = bg_color

    background.anchorX, background.anchorY = 0, 0
    background.x, background.y = 0, 0
    decoration_group:insert(background)

    scoreSound = audio.loadSound('sounds/sfx_point.mp3')
    dieSound = audio.loadSound('sounds/sfx_die.mp3')
    hitSound = audio.loadSound('sounds/sfx_hit.mp3')
    swooshSound = audio.loadSound('sounds/sfx_swooshing.mp3')

    -- Pause
    btn_pause = widget.newButton({
        width = 13,
        height = 14,
        defaultFile = "sprites/button_pause.png",
        overFile = "sprites/button_pause.png",
        onEvent = handlePause
    })
    btn_pause.x, btn_pause.y = 12, 20
    ui_group:insert(btn_pause)

    -- Bird
    bird = Bird({color = bird_color, x = 40, y = 100})
    player_group:insert(bird)

    score = Score({x = halfW + 5, y = 15})
    ui_group:insert(score)

    -- Ground
    ground = display.newImageRect("sprites/ground.png", 168, 56)
    groundloop = display.newImageRect("sprites/ground.png", 168, 56)
    ground.anchorX, ground.anchorY = 0, 0
    groundloop.anchorX, groundloop.anchorY = 0, 0
    ground.x, ground.y = 0, display.contentHeight - ground.height
    groundloop.x, groundloop.y = ground.width, display.contentHeight - ground.height 

    ground.name, groundloop.name = "ground"

    physics.addBody(ground, "static", { bounce = 0, friction = 1 })
    physics.addBody(groundloop, "static", { bounce = 0, friction = 1 })

    grounds_group:insert(ground)
    grounds_group:insert(groundloop)

    group:insert(decoration_group)
    group:insert(grounds_group)
    group:insert(player_group)
    group:insert(ui_group)
end

local function groundLoop()
    if not playing then
        return
    end
    if ground.x <= -ground.width then
        ground.x = 0
        groundloop.x = ground.width
    end
    transition.to(ground, {
        time = walkingSpeed,
        x = -ground.width,
        onComplete = groundLoop
    })
    transition.to(groundloop, {
        time = walkingSpeed,
        x = 0
    })
end

local function createPipe()
    if not playing then
        return
    end

    local pc = "green"
    if(pipes_color == "night") then pc = "red" end

    local pipe_top = display.newImageRect("sprites/pipe_" .. pc .. "_top.png", 26, 160)
    local pipe_bottom = display.newImageRect("sprites/pipe_" .. pc .. "_bottom.png", 26, 160)
    local pipe_trigger = display.newRect(0, 0, 5, pipeMinDistance)
    local rand = math.random(-pipeYRandomness, pipeYRandomness)

    pipe_top.anchorY = 1
    pipe_bottom.anchorY = 0
    pipe_trigger.anchorY = 1

    physics.addBody(pipe_top, "static", { bounce = 0, friction = 0 })
    physics.addBody(pipe_bottom, "static", { bounce = 0, friction = 0 })
    physics.addBody(pipe_trigger, "static", { bounce = 0, friction = 0 })

    pipe_top.x = display.contentWidth + pipe_top.width / 2
    pipe_bottom.x = display.contentWidth + pipe_top.width / 2
    pipe_top.y = (pipe_top.height / 2) + rand
    pipe_bottom.y = pipe_top.y + pipeMinDistance
    pipe_trigger.x = display.contentWidth + pipe_top.width / 2
    pipe_trigger.y = pipe_top.y + pipeMinDistance

    pipe_trigger:setFillColor(0, 0, 0, 0)
    pipe_trigger.name = "score_collider"
    pipe_trigger.isSensor = true

    pipes_group:insert(pipe_top)
    pipes_group:insert(pipe_bottom)
    pipes_group:insert(pipe_trigger)
    group:insert(pipes_group)

    grounds_group:toFront()
    player_group:toFront()
    ui_group:toFront()

    transition.to(pipe_top, {
        time = walkingSpeed + 160,
        x = -(pipe_top.width / 2),
        onComplete = function()
            if not playing then return end
            pipe_top:removeSelf()
        end
    })

    transition.to(pipe_bottom, {
        time = walkingSpeed + 160,
        x = -(pipe_bottom.width / 2),
        onComplete = function()
            if not playing then return end
            pipe_bottom:removeSelf()
        end
    })

    transition.to(pipe_trigger, {
        time = walkingSpeed + 175,
        x = -(pipe_top.width / 2)
    })

end

local function die()
    bird.bodyType = "static"
    playing = false
    transition.cancel()
    player_group:toFront()

    score:removeSelf()
    btn_pause:removeSelf()
    go = GameOver({ score = score:getScore() })
    ui_group:insert(go)
    ui_group:toFront()

    timer.performWithDelay(1, function() bird.rotation = 90 end)
end

-- Bird Collision Handler
local function onPipeCollision(self, event)
    if event.other.name == 'score_collider' then
        event.other:removeSelf()
        audio.play(swooshSound)
        audio.play(scoreSound)
        score:add(1)
        return
    end
    if playing then
        if event.other.name ~= 'ground' then
            audio.play(hitSound)
        else
            audio.play(dieSound)
        end
        die()
    end
end

-- Touch listener
local function onTouchEvent(event)
    if not playing then 
        return
    end
    if event.phase == "began" then
        bird:tap()
    end
end             

-- Bird Rotation
local function birdRotationListener(event)
    if not playing then
        return
    end
    local vx, vy = bird:getLinearVelocity()
    local maxRotation = 80
    local rotationSpeed = 0.025
    if vy <= 0 then
        bird.rotation = bird.rotation + (rotationSpeed * 10) * (-15 - bird.rotation)
    else
        bird.rotation = bird.rotation + rotationSpeed * (maxRotation - bird.rotation)
    end
end

-- show()
function scene:show(event)
    local group = self.view
    local phase = event.phase

    if (phase == 'will') then
        grounds_group:toFront()
        bird:toFront()        

        bird.collision = onPipeCollision
        bird:addEventListener('collision')

        Runtime:addEventListener("touch", onTouchEvent)
        Runtime:addEventListener("enterFrame", birdRotationListener)
    elseif(phase == 'did') then
        groundLoop()
        bird:tap()
        spawnTimer = timer.performWithDelay(pipeSpawnDelay, createPipe, 0)
    end
end

-- hide()
function scene:hide(event)
    local group = self.view
    local phase = event.phase
 
    if (phase == 'will') then
    elseif (phase == 'did') then
        score:removeSelf()
    end
end

-- destroy()
function scene:destroy( event )
    local group = self.view
    
    Runtime:removeEventListener("touch", onTouchEvent)
    Runtime:removeEventListener("enterFrame", birdRotationListener)
    timer.cancel(spawnTimer)
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
