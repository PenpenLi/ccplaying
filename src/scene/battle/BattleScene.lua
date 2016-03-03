local BaseScene = require("tool.helper.BaseScene")
local BattleLayer = require("scene.battle.BattleLayer")
local BattleScene = class("BattleScene", BaseScene)


function BattleScene:ctor(params, attackerFormInfo, progressFunc)
    BattleScene.super.ctor(self)

    local layer = BattleLayer.new(params, attackerFormInfo, progressFunc)

    self:addChild(layer)
end

function BaseScene:setLoadingCallback(callback)
    self.layer:setLoadingCallback(callback)
end

return BattleScene