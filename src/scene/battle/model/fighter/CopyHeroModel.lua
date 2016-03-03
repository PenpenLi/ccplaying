--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/11
-- Time: 下午4:32
-- To change this template use File | Settings | File Templates.
--

local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
-------------------------------------------------------------------------------

local CopyHeroModel = class("CopyHeroModel", BattleHeroModel)

function CopyHeroModel:ctor(heroModel, team)
    local args = heroModel.__create_args__

    CopyHeroModel.super.ctor(self, args.heroCreateData, team, args.formAdd)
    self._replicationTimeLeft = BattleConfig.COPY_MODEL_TIME
end

function CopyHeroModel:getViewInfo()
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

function CopyHeroModel:getName()
    local name = CopyHeroModel.super.getName(self)

    return name .. "的复制品"
end

function CopyHeroModel:expired()
    CopyHeroModel.super.die(self, false)

    CCLog("CopyHeroModel:expired()", debug.traceback())
    self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = self:getFighterID(),  fadeoutTime = 0.5})
end

function CopyHeroModel:onBattleRoundEnd()
    if self:isAlive() then
        self:expired()
    end

    CopyHeroModel.super.onBattleRoundEnd(self)
end

function CopyHeroModel:update(battleModel)
    CopyHeroModel.super.update(self, battleModel)

    self._replicationTimeLeft = self._replicationTimeLeft - BattleConfig.TIME_UNIT
    if self._replicationTimeLeft <= 0 then
        self:expired()
    end

    --CCLog("CopyHeroModel.timeLeft", self._replicationTimeLeft)
end

return CopyHeroModel