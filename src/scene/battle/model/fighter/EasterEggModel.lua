--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/18
-- Time: 上午9:36
-- 会复活怪物的彩蛋
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterModel = require("scene.battle.model.fighter.FighterModel")
-------------------------------------------------------------------------------

local EasterEggModel = class("EasterEggModel", FighterModel)

function EasterEggModel:ctor(heroModel, rageHitTimesLeft)
    EasterEggModel.super.ctor(self, "egg")

    self._originHeroModel = heroModel
    self._eggTimeLeft = BattleConfig.EGG_MODEL_TIME
    self._cell = heroModel:getCell()
    self._rageHitTimesLeft = rageHitTimesLeft
    self._totalRageHitTimesLeft = rageHitTimesLeft
    self._name = heroModel:getName() .. "的蛋"
end

function EasterEggModel:getRageHitTimesLeft()
    return self._rageHitTimesLeft
end

function EasterEggModel:getTotalRageHitTimesLeft()
    return self._totalRageHitTimesLeft
end

function EasterEggModel:hitByRageSkill()
    self._rageHitTimesLeft = self._rageHitTimesLeft - 1
end

function EasterEggModel:getOriginHeroModel()
    return self._originHeroModel
end

function EasterEggModel:isAttackableType()
    return false
end

function EasterEggModel:isHittableType()
    return true
end

function EasterEggModel:isMovableType()
    return false
end

function EasterEggModel:isMissable()
    return false
end

function EasterEggModel:getFormulaParams()
    local params = {
        ATK = 0,
        DEF = 0,
        MP = 0,
        HP = 1,
        FH = 1,
        heroLV = 1,
        damageAddition = 0,
        damageReduction = 0,
        skillAddition = 0,
        skillReduction = 0,
        treatmentAddition = 0,
        treatedAddition = 0,
        treatmentReduction = 0,
        treatedReduction = 0,
        specDamageAddition = 0,
        specDamageReduction = 0,
        comboHit = 0,
        WX = 0,
    }

    return params
end

function EasterEggModel:onBuffAdded(buff)

end

function EasterEggModel:onBuffRemoved(buff)

end

function EasterEggModel:onBuffReplaced(oldBuff, newBuff)

end

function EasterEggModel:incHP(value)

end

function EasterEggModel:decHP(value)

end

function EasterEggModel:getName()
    return self._name
end

function EasterEggModel:isAlive()
    CCLog(vardump({hitLeft = self._rageHitTimesLeft, timeLeft = self._eggTimeLeft}, "EasterEggModel:isAlive()"))
    return self._eggTimeLeft > 0 and self._rageHitTimesLeft > 0
end

function EasterEggModel:setCell(cell)
    self._cell = cell
end

function EasterEggModel:getCell()
    return self._cell
end

function EasterEggModel:getFightType()
    return "far"
end

function EasterEggModel:isHittableType()
    return true
end

function EasterEggModel:die()
    EasterEggModel.super.die(self)
end

function EasterEggModel:expired() 
    self._originHeroModel:dispatchEvent(AppEvent.UI.Battle.EggExpired, {fighterID = self:getFighterID() })
end

function EasterEggModel:onBattleRoundEnd()
    EasterEggModel.super.onBattleRoundEnd(self)
end

function EasterEggModel:getAttackRatio()
    return self._attackRatio
end

function EasterEggModel:update(battleModel)
    self._eggTimeLeft = self._eggTimeLeft - BattleConfig.TIME_UNIT
    if self._eggTimeLeft <= 0 then
        self:expired()
    end

    CCLog("EasterEggModel.timeLeft", self._eggTimeLeft)
end

return EasterEggModel


