--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-27
-- Time: 上午10:21
-- 管理一个英雄的技能
--
local SkillModel = require("scene.battle.model.skill.SkillModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local HeroSkillManager = class("HeroSkillManager")

function HeroSkillManager:ctor(heroModel, battleModel, skillsData)
    self.heroModel = heroModel
    self.battleModel = battleModel

    self.normAttackModel = SkillModel.new(heroModel, skillsData.normAttack)

    self.normSkillModel = skillsData.normSkill and SkillModel.new(heroModel, skillsData.normSkill) or nil
    self.innateSkillModel = skillsData.innateSkill and SkillModel.new(heroModel, skillsData.innateSkill) or nil
    self.rageSkillModel = skillsData.rageSkill and SkillModel.new(heroModel, skillsData.rageSkill) or nil

    self.skillModelList = {}

    local skill = nil

    skill = self.normAttackModel
    if skill then
        table.insert(self.skillModelList, skill)
    end

    skill =  self.normSkillModel
    if skill then
        table.insert(self.skillModelList, skill)
    end

    skill =  self.innateSkillModel
    if skill then
        table.insert(self.skillModelList, skill)
    end

    skill =  self.rageSkillModel
    if skill then
        table.insert(self.skillModelList, skill)
    end

    self.coolLeftTime = 0
end

function HeroSkillManager:reset()
--    self.normAttackModel:reset()
--    self.normSkillModel:reset()
--    self.innateSkillModel:reset()
--    self.rageSkillModel:reset()

    for _, skillModel in ipairs(self.skillModelList) do
        skillModel:reset()
    end
end

function HeroSkillManager:update()
    --CCLog(string.format("冷却时间 %s: %.2f - %.2f", self.heroModel._heroId, self.coolLeftTime,  BattleModel.TIME_UNIT))
    if self.coolLeftTime > 0 then
        self.coolLeftTime = self.coolLeftTime - BattleConfig.TIME_UNIT * self.heroModel:getAttackSpeedVar()
    end
    --CCLog(string.format("冷却时间 %s: %.2f", self.heroModel._heroId, self.coolLeftTime))

--    self.normAttackModel:update()
--    self.normSkillModel:update()
--    self.innateSkillModel:update()
--    self.rageSkillModel:update()

    for _, skillModel in ipairs(self.skillModelList) do
       skillModel:update()
    end
end

--local SkillType = {
--    NormAttack = 1,
--    NormSkill = 2,
--    RageSkill = 3,
--    InnateSkill = 4
--}
function HeroSkillManager:onSkillRelease(skillData)
    -- 普攻或普攻概率触发的技能重置攻击冷却时间
--    if skillData.triggerCondition == enums.SkillTriggerCondition.AttackProp or skillData.type == enums.SkillType.NormAttack then
--        CCLog("重置冷却时间")
--        self:resetCooling()
--    end
    if skillData.type ~= enums.SkillType.RageSkill then
        self:resetCooling()
    end

    if skillData.type == enums.SkillType.NormAttack and self.normAttackModel ~= nil then
        --CCLog(self.heroModel:getName() .. "释放了普攻攻击")
        self.normAttackModel:onRelease()
    elseif skillData.type == enums.SkillType.NormSkill and self.normSkillModel ~= nil then
        --CCLog(self.heroModel:getName() .. "释放了普攻技能")
        self.normSkillModel:onRelease()
    elseif skillData.type == enums.SkillType.RageSkill and self.rageSkillModel ~= nil then
        --CCLog(self.heroModel:getName() .. "释放了怒气技能")
        self.rageSkillModel:onRelease()
    elseif skillData.type == enums.SkillType.InnateSkill and self.innateSkillModel ~= nil then
        --CCLog(self.heroModel:getName() .. "释放了天赋技能")
        self.innateSkillModel:onRelease()
    end
end

function HeroSkillManager:attackInCooling()
    return self.coolLeftTime > 0
end

function HeroSkillManager:clearCooling()
    self.coolLeftTime = 0
end

function HeroSkillManager:resetCooling()
    self.coolLeftTime = (self.heroModel:getAttackSpeed() / 1000.0) -- 单位：毫秒
    CCLog("冷却重置:", self.heroModel:getName(), self.coolLeftTime)
end

function HeroSkillManager:rageSkillInCooling()
    return self.rageSkillModel:inCooling()
end

function HeroSkillManager:rageSkillCoolLeftTime()
    return self.rageSkillModel.coolLeftTime
end

function HeroSkillManager:rageSkillCoolTime()
    return self.rageSkillModel.skillData.CD
end

-- 获取当前攻击的技能
-- 在所有攻击概率触发的技能中取概率最高的技能，没有取到的增加概率以提高下次的机会
--local SkillTriggerCondition = {
--    EnterBattle = 1,
--    AttackProp = 2,
--    HPUnderHalf = 3,
--    KillEnemy = 4,
--    HeroDie = 5
--}
function HeroSkillManager:genAttackSkill()
    local result = self.normAttackModel

    local totalProbability = 0
    local skillInfoList = {}
    for _, skillModel in ipairs({self.normSkillModel, self.innateSkillModel }) do
       if skillModel.skillData.triggerCondition == enums.SkillTriggerCondition.AttackProp and not skillModel:inCooling() then
           local probability = skillModel:getProbability()

           table.insert(skillInfoList, {skillModel = skillModel, start = totalProbability, stop = totalProbability + probability})
           totalProbability = totalProbability + probability
       end
    end

    if #skillInfoList > 0 then
        local randNum = self.battleModel:random(1, 10000)
        for _, skillInfo in ipairs(skillInfoList) do
           if randNum >= skillInfo.start and randNum < skillInfo.stop then
               result = skillInfo.skillModel
           else
               skillInfo.skillModel:incProbability()
           end
        end
    end

    self:resetCooling()

    return result.skillData
end

function HeroSkillManager:getTriggeredSkills(triggerCondition)
    local result = {}

    local skill
    
    skill = self.normSkillModel
    if skill then
        if skill.skillData.triggerCondition == triggerCondition then
            table.insert(result, skill)
        end
    end

    skill = self.innateSkillModel
    if skill then
        if skill.skillData.triggerCondition == triggerCondition then
            table.insert(result, skill)
        end
    end

    return result
end

function HeroSkillManager:getNormAttack()
    return self.normAttackModel.skillData
end

function HeroSkillManager:getNormSkill()
    local skillModel =  self.normSkillModel or {}
    return skillModel.skillData
end

function HeroSkillManager:getRageSkill()
    local skillModel = self.rageSkillModel or {}
    return skillModel.skillData
end

function HeroSkillManager:getInnateSkill()
    local skillModel =   self.innateSkillModel
    return skillModel.skillData
end

function HeroSkillManager:inProbability(skillModel)
    local skillData = skillModel.skillData
    if skillData.type == enums.SkillType.RageSkill then
        return true
    end

    local probability = skillData.triggerProbability

    if probability == 0 then
        return true
    end

    local randNum = self.battleModel:random(1, 10000)
    if randNum <= probability then
        return true
    end

    return false
end

-- begin region 事件响应
--local SkillTriggerCondition = {
--    EnterBattle = 1,
--    AttackProp = 2,
--    HPUnderHalf = 3,
--    KillEnemy = 4,
--    HeroDie = 5
--}

function HeroSkillManager:onEnterBattle()
    self:clearCooling()
    self.normAttackModel:clearCooling()

    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.EnterBattle)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            --if self:inProbability(skillModel) then
                self.heroModel:delayTriggeredSkill(skillModel.skillData)
                CCLog(self.heroModel:getName() .. "进入战场触发技能" .. skillModel.skillData.name)
            --end
        end
    end
end

function HeroSkillManager:onNormAttack()
--    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.AttackProp)
--    if #triggeredSkillModels > 0 then
--        for _, skillModel in ipairs(triggeredSkillModels) do
--            if self:inProbability(skillModel) then
--                self.heroModel:triggeredSkill(skillModel.skillData)
--            end
--        end
--    end
end

function HeroSkillManager:onHitByRage(enemyModel)
    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.HeroDieOrHitByRage)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            if self:inProbability(skillModel) then
                self.heroModel:triggeredSkill(skillModel.skillData, {enemyModel:getFighterID()})
                CCLog(self.heroModel:getName() .. "被怒气技能攻击触发" .. skillModel.skillData.name)
            end
        end
    end
end

function HeroSkillManager:onHeroDie()
    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.HeroDie)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            if self:inProbability(skillModel) then
                self.heroModel:triggeredSkill(skillModel.skillData)
                CCLog(self.heroModel:getName() .. "英雄死亡触发技能" .. skillModel.skillData.name)
            end
        end
    end

    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.HeroDieOrHitByRage)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            if self:inProbability(skillModel) then
                self.heroModel:triggeredSkill(skillModel.skillData)
                CCLog(self.heroModel:getName() .. "英雄死亡触发技能" .. skillModel.skillData.name)
            end
        end
    end
end

-- 英雄是否能死去
function HeroSkillManager:getTurnIntoEggSkillData()
    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.HeroDie)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            local skillData = skillModel.skillData

            if skillData.extraAffect == enums.SkillExtraAffect.TurnIntoEgg then
                return skillData
            end
        end
    end

    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.HeroDieOrHitByRage)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            local skillData = skillModel.skillData

            if skillData.extraAffect == enums.SkillExtraAffect.TurnIntoEgg then
                return skillData
            end
        end
    end

    return nil
end

function HeroSkillManager:onKillEnemy(enemyModel)
    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.KillEnemy)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            if self:inProbability(skillModel) then
                self.heroModel:triggeredSkill(skillModel.skillData)
                CCLog(self.heroModel:getName() .. "杀死敌人触发技能" .. skillModel.skillData.name)
            end
        end
    end
end

function HeroSkillManager:onHeroHPUnderHalf()
    local triggeredSkillModels = self:getTriggeredSkills(enums.SkillTriggerCondition.HPUnderHalf)
    if #triggeredSkillModels > 0 then
        for _, skillModel in ipairs(triggeredSkillModels) do
            if self:inProbability(skillModel) then
                self.heroModel:triggeredSkill(skillModel.skillData)
                CCLog(self.heroModel:getName() .. "英雄半血触发技能" .. skillModel.skillData.name)
            end
        end
    end
end
-- end region 事件响应

return HeroSkillManager