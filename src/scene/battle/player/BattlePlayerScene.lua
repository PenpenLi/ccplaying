--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-10
-- Time: 下午3:39
-- To change this template use File | Settings | File Templates.
--

local BaseScene = require("tool.helper.BaseScene")
local BattlePlayerLayer = require("scene.battle.player.BattlePlayerLayer")
local BattlePlayerScene = class("BattlePlayerScene", BaseScene)

function BattlePlayerScene:ctor(recordData)
    BattlePlayerScene.super.ctor(self)
    local layer = BattlePlayerLayer.new(recordData)
    self:addChild(layer)
end

return BattlePlayerScene