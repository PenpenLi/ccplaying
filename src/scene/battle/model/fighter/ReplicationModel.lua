--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/10
-- Time: 上午10:07
-- 分身
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
-------------------------------------------------------------------------------

local ReplicationModel = class("ReplicationModel", BattleHeroModel)

function ReplicationModel:ctor(heroModel, attackRatio)
    local args = heroModel.__create_args__

    ReplicationModel.super.ctor(self, args.heroCreateData, args.team, args.formAdd)
    self._attackRatio = attackRatio
    self.ownerFighter = heroModel
    self.ownerFighter:addSummonBeast(self)
    self._replicationTimeLeft = BattleConfig.REPLICATION_MODEL_TIME
end

function ReplicationModel:getViewInfo()
    return {
        fighterID = self:getFighterID(),
        name = self:getName(),
        moveMode = self:getHeroMoveMode(),
        isReplication = true,
        teamSide = self:getTeamSide(),
        direction = self:getDirection(),
        heroID = self:getHeroID(),
        heroRes = self:getHeroRes(),
        isMonster = true,
        -- isBoss = self:isBoss(),
        -- scale = self:getHeroScale(),
        skinInfo = self:getSkinInfo(),
        fullHP = self:getFullHP(),
        starLevel = self._heroBaseData.starLevel,
    }
end

function ReplicationModel:getName()
    local name = ReplicationModel.super.getName(self)

    return name .. "的分身"
end

function ReplicationModel:die()
    CCLog("ReplicationModel:die()")
    if self.ownerFighter then
        self.ownerFighter:removeSummonBeast(self)
    end

    ReplicationModel.super.die(self)
    self.ownerFighter = nil
end

function ReplicationModel:expired()
    if self.ownerFighter then
        self.ownerFighter:removeSummonBeast(self)
    end

    ReplicationModel.super.die(self, false)
    self.ownerFighter = nil

    CCLog("ReplicationModel:expired()", debug.traceback())
    self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = self:getFighterID(), fadeoutTime = 0.5 })
end

function ReplicationModel:onBattleRoundEnd()
    if self:isAlive() then
        self:expired()
    end

    ReplicationModel.super.onBattleRoundEnd(self)
end

function ReplicationModel:getAttackRatio()
    return self._attackRatio
end

function ReplicationModel:update(battleModel)
    ReplicationModel.super.update(self, battleModel)

    self._replicationTimeLeft = self._replicationTimeLeft - BattleConfig.TIME_UNIT
    if self._replicationTimeLeft <= 0 then
        self:expired()
    end

    CCLog("ReplicationModel.timeLeft", self._replicationTimeLeft)
end

return ReplicationModel