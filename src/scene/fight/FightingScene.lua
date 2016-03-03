local BaseScene = require("app.scenes.common.BaseScene")
local FightingLayer = require("app.scenes.fight.FightingLayer")
local FightingScene = class("FightingScene", BaseScene)

function FightingScene:ctor()
    FightingScene.super.ctor(self)
    local layer = FightingLayer.new()
    self:addChild(layer)
end

return FightingScene