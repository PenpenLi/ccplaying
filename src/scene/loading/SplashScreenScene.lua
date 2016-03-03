local BaseScene = require("tool.helper.BaseScene")
local SplashScreenLayer = require("scene.loading.SplashScreenLayer")
local SplashScreenScene = class("SplashScreenScene", BaseScene)

function SplashScreenScene:ctor()
    SplashScreenScene.super.ctor(self)
    
    local layer = SplashScreenLayer.new()
    self:addChild(layer)
end

return SplashScreenScene