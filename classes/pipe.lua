-- Bird Class

local _M = {}

function _M.new(params)
    local bird = display.newImageRect("sprites/bird_orange_0.png", 17, 12)
    bird.x = params.x
    bird.y = params.y
    
    physics.addBody(bird, "dynamic")
    bird.isFixedRotation = true

    function bird:tap()
        bird:setLinearVelocity(0, -125)
    end

    return bird
end

return _M