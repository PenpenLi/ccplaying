local BaseScene = require("tool.helper.BaseScene")
local PVPLoadingLayer = require("scene.loading.PVPLoadingLayer")
local PVPLoadingScene = class("PVPLoadingScene", BaseScene)

function PVPLoadingScene:ctor(ownForm, enemyForm, callFunc)
    PVPLoadingScene.super.ctor(self)
    
    local layer = PVPLoadingLayer.new(ownForm, enemyForm, callFunc)
    self:addChild(layer)
end

return PVPLoadingScene