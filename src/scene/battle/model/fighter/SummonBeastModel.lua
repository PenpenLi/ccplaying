--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/1/29
-- Time: 下午4:21
-- 召唤兽
--

local MonsterModel = require("scene.battle.model.fighter.MonsterModel")
-------------------------------------------------------------------------------

local SummonBeastModel = class("SummonBeastModel", MonsterModel)

function SummonBeastModel:ctor(monsterData, team, ownerFighter)
    SummonBeastModel.super.ctor(self, monsterData, team)
    self.ownerFighter = ownerFighter

    self.ownerFighter:addSummonBeast(self)
end

function SummonBeastModel:getViewInfo()
    return {
        fighterID = self:getFighterID(),
        name = self:getName(),
        moveMode = self:getHeroMoveMode(),
        isReplication = false,
        teamSide = self:getTeamSide(),
        direction = self:getDirection(),
        heroID = self:getHeroID(),
        heroRes = self:getHeroRes(),
        isMonster = true,
    }
end

function SummonBeastModel:die()
    if self.ownerFighter then
        self.ownerFighter:removeSummonBeast(self)
    end

    SummonBeastModel.super.die(self)
    self.ownerFighter = nil
end

function SummonBeastModel:expired()
    SummonBeastModel.super.die(self, false)

    if self.ownerFighter then
        self.ownerFighter:removeSummonBeast(self)
    end

    SummonBeastModel.super.die(self, false)
    self.ownerFighter = nil

    self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = self:getFighterID(), fadeoutTime = 0.5 })
end

function SummonBeastModel:onBattleRoundEnd()
    if self:isAlive() then
        self:die()
    end

    SummonBeastModel.super.onBattleRoundEnd(self)
end

return SummonBeastModel