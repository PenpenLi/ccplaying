local BaseScene = require("app.scenes.common.BaseScene")

local SplashScreenLayer = require("app.scenes.loading.SplashScreenLayer")
local GameLoadingLayer = require("app.scenes.loading.GameLoadingLayer")
local GameLoadingScene = class("GameLoadingScene", BaseScene)

function GameLoadingScene:ctor()
    GameLoadingScene.super.ctor(self)
    
    local layer = GameLoadingLayer.new()
    self:addChild(layer)
end

return GameLoadingScene