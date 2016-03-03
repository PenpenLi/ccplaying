--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-9-25
-- Time: 上午11:21
-- 正在释放中的技能
--

local BattleModel = require("scene.battle.model.BattleModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------
local AttackingModel = class("AttackingModel")

function AttackingModel:ctor(heroModel)
    self.heroModel = heroModel

    self.attackDataModel = nil
    self.timeLeft = 0
    self.aniTimeLeft = 0
    self.speedVar = 0
end

function AttackingModel:update()
    if self.attackDataModel then
        self.timeLeft = self.timeLeft - BattleConfig.TIME_UNIT * self.speedVar

        if self.timeLeft <= 0 then
           self:onAttackComplete()
        end
    end

    if self.aniTimeLeft >= 0 then
        self.aniTimeLeft = self.aniTimeLeft - BattleConfig.TIME_UNIT
    end
end

function AttackingModel:attackBegin(attackDataModel)
    self.attackDataModel = attackDataModel
    self.timeLeft = attackDataModel:getSkillAniTime()
    self.aniTimeLeft = attackDataModel:getSkillAniDuration()
    self.speedVar = self.heroModel:getAttackSpeedVar()

    CCLog(vardump({timeLeft = self.timeLeft, aniTimeLeft = self.aniTimeLeft, speedVar = self.speedVar}))
end

function AttackingModel:inAttacking()
    if self.attackDataModel ~= nil then
        return true
    else        
        return self.aniTimeLeft > 0
    end
end

function AttackingModel:breakOff(quiet)
    if self.attackDataModel and self.timeLeft > 0 then
        self:onAttackBreakOff(quiet)
    end
end

function AttackingModel:onAttackComplete()
    local attackDataModel = self.attackDataModel

    self.heroModel:onAttackComplete(attackDataModel)
    self.attackDataModel = nil
    self.timeLeft = 0
    self.speedVar = 0
end

function AttackingModel:onAttackBreakOff(quiet)
    local attackDataModel = self.attackDataModel

    self.heroModel:onAttackBreakOff(attackDataModel, quiet)

    self.attackDataModel = nil
    self.aniTimeLeft = 0
    self.timeLeft = 0
    self.speedVar = 0
end

return AttackingModel
