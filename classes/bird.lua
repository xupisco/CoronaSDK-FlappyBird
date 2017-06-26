-- Bird Class

local _M = {}

function _M.new(params)
    local options = {
        width = 17,
        height = 12,
        numFrames = 3
    }

    local bird_animations = {
        {
            name = "idle",
            start = 1,
            count = 1,
            time = 0,
            loopCount = 1
        },
        {
            name = "flap",
            start = 1,
            count = 3,
            time = 200,
            loopCount = 1,
            loopDirection = "bounce"
        },
        {
            name = "menu",
            start = 1,
            count = 3,
            time = 200,
            loopCount = 0,
            loopDirection = "bounce"
        }
    }

    local birds = {
        'orange',
        'red',
        'blue'
    }
    local bird_color = params.color or birds[math.random(#birds)]
    --local bird = display.newImageRect("sprites/bird_".. bird_color .."_0.png", 17, 12)
    local bird_sheet = graphics.newImageSheet("sprites/bird_".. bird_color .."_ss.png", options)
    local bird = display.newSprite(bird_sheet, bird_animations)
    bird.x = params.x
    bird.y = params.y

    local flapSound = audio.loadSound('sounds/sfx_wing.mp3')
    
    if not params.static then
        physics.addBody(bird, "dynamic", { density = 10, bounce = 0, radius = 5, friction = 1 })
        bird.isFixedRotation = true
    end

    function bird:tap()
        audio.play(flapSound)
        bird:setSequence('flap')
        bird:play()
        bird:setLinearVelocity(0, -175)
    end

    function bird:getColor()
        return bird_color
    end

    return bird
end

return _M