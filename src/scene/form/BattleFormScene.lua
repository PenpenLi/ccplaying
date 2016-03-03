--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-18
-- Time: 下午3:19
-- To change this template use File | Settings | File Templates.
--

local BaseScene = require("tool.helper.BaseScene")
local BattleFormLayer = import(".BattleFormLayer")
local BattleFormScene = class("BattleFormScene", BaseScene)

function BattleFormScene:ctor(formType, params)
    CCLog(vardump({params = params}, "BattleFormScene:ctor()"))
    BattleFormScene.super.ctor(self)
    local layer = BattleFormLayer.new(formType, params)
    self:addChild(layer)

    require("scene.battle.model.fighter.FighterModel").traceAllFighters()
end

return BattleFormScene