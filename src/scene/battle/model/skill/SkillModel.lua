--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-12-29
-- Time: 下午5:53
-- To change this template use File | Settings | File Templates.
--

local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local SkillModel = class("SkillModel")

function SkillModel:ctor(fighterModel, skillData)
    self.fighterModel = fighterModel
    self.skillData = skillData

    -- 释放次数
    self.releaseCount = 0

    -- 当前时间
    local formIndex = fighterModel._formIndex or 1
    self.coolLeftTime = formIndex * BattleConfig.TIME_UNIT
    -- 触发机率
    self.releaseProbability = self.skillData.triggerProbability

    self.CD = self.skillData.CD

    if skillData.type == enums.SkillType.RageSkill and fighterModel:isBoss() then
        self.CD = self.CD * 1.5

        -- Boss初始CD
        self.coolLeftTime = self.CD / 2
    end

    if skillData.type == enums.SkillType.NormAttack or
--            skillData.type == enums.SkillType.InstanceSkill or
--            skillData.type == enums.SkillType.TrapSkill  or
--            skillData.type == enums.SkillType.FairySkill or
            skillData.type == enums.SkillType.ObstacleSkill
    then
        self.CD = fighterModel:getAtkSpeed() / 1000
    end
end

function SkillModel:reset()
    -- 释放次数
    self.releaseCount = 0

    -- 当前时间
    self.coolLeftTime = self.CD
    -- 重置触发机率
    self.releaseProbability = self.skillData.triggerProbability
end

-- 技能冷却中
function SkillModel:inCooling()
    return self.coolLeftTime > 0
end

function SkillModel:resetCooling()
    self.coolLeftTime = self.CD
end

function SkillModel:clearCooling()
    self.coolLeftTime = 0
end

function SkillModel:getProbability()
    return self.releaseProbability
end

function SkillModel:incProbability()
    self.releaseProbability = self.releaseProbability + self.skillData.triggerProbability
end

function SkillModel:decProbability(probability)
    assert(probability >= 0)
    self.releaseProbability = self.releaseProbability - probability
end

function SkillModel:onRelease()
    self.coolLeftTime = self.CD
    self.releaseCount = self.releaseCount + 1
    self.releaseProbability = 0
end

function SkillModel:update()
    local speedVar = self.fighterModel:getAttackSpeedVar()

    self.coolLeftTime = self.coolLeftTime - BattleConfig.TIME_UNIT * speedVar
    if self.coolLeftTime < 0 then
        self.coolLeftTime = 0
    end
end

return SkillModel