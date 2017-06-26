display.newImageRect("sprites/ground.png", 168, 56)
ground.x, ground.y = halfW, display.contentHeight - 28
physics.addBody(ground, "static")