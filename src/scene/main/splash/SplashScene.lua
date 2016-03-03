local BaseScene = require("tool.helper.BaseScene")

local SplashScene = class("SplashScene",BaseScene)
local SplashLayer = require("scene.main.splash.SplashLayer")

function SplashScene:ctor()
    SplashScene.super.ctor(self)
    local layer = SplashLayer.new()
    self:addChild(layer)    
end

return SplashScene