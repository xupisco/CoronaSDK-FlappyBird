-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- No antialias
display.setDefault('magTextureFilter', 'nearest')
display.setDefault('minTextureFilter', 'nearest')

local composer = require('composer')

composer.recycleOnSceneChange = true
composer.effectList.fade.from.transition = easing.outQuad
composer.effectList.fade.to.transition = easing.outQuad

composer.gotoScene('scenes.menu')