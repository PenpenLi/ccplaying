--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-10
-- Time: 下午3:39
-- To change this template use File | Settings | File Templates.
--

local BattleRecordPlayer = require("scene.battle.player.BattleRecordPlayer")

local BattlePlayerLayer = class("BattlePlayerLayer", BaseLayer)

function BattlePlayerLayer:ctor(recordData)
    BattlePlayerLayer.super.ctor(self)

    local player = BattleRecordPlayer.new(recordData)
    self:addChild(player)
    self.controls.player = player
    player:play()
end

return BattlePlayerLayer