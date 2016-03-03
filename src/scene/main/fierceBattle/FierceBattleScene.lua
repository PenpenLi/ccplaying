local BaseScene = require("tool.helper.BaseScene")

local FierceBattleScene = class("FierceBattleScene",BaseScene)
local FierceBattleLayer = require("scene.main.FierceBattle.FierceBattleLayer")

function FierceBattleScene:ctor(info)
    FierceBattleScene.super.ctor(self)
    local layer = FierceBattleLayer.new(info)
    self:addChild(layer)    
end

return FierceBattleScene