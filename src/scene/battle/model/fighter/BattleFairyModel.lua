--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-29
-- Time: 下午3:36
-- To change this template use File | Settings | File Templates.
--
local FighterModel = require("scene.battle.model.fighter.FighterModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
-------------------------------------------------------------------------------
local FAIRY_COOL_TIME_DEF = BattleConfig.FAIRY_COOL_TIME

local BattleFairyModel = class("BattleFairyModel", FighterModel)

function BattleFairyModel:ctor(fairyData, team)
    BattleFairyModel.super.ctor(self, "fairy")

    self.team = team
    self.COOL_TIME = math.max(FAIRY_COOL_TIME_DEF - 0.1 * fairyData.Level, 1)
    self.fairyData = fairyData
    self.fairyConfig = BaseConfig.GetFairy(fairyData.ID)
    self.coolTimeLeft = self.COOL_TIME
    self.lastReleaseIndex = nil
    self.inCooling = true

    self.coolPercent = 0

    self.view = nil
    self.skillIsTreat = {}

    local skillData1 = BaseConfig.GetHeroSkill(self.fairyConfig.Skill1, self.fairyData.SkillLevel[1] or 1)
    local skillData2 = BaseConfig.GetHeroSkill(self.fairyConfig.Skill2, self.fairyData.SkillLevel[2] or 1)

    CCLog(vardump({skillData1, skillData2}, "fairy skils"))

    self.treatSkillIndex = nil
    if (skillData1 and skillData1.affect == enums.SkillAffectType.Treatment) then
        self.treatSkillIndex = 1
        self.otherSkillIndex = 2
    end

    if (skillData2 and skillData2.affect == enums.SkillAffectType.Treatment) then
        self.treatSkillIndex = 2
        self.otherSkillIndex = 1
    end
end

function BattleFairyModel:getFairyID()
    return self.fairyData.ID
end

--- begin FighterModel 虚函数 -------
function BattleFairyModel:isAttackableType()
    return true
end

function BattleFairyModel:isHittableType()
    return false
end

function BattleFairyModel:isMovableType()
    return false
end

function BattleFairyModel:isMissable()
    return false
end

function BattleFairyModel:canMatched()
    return false
end

function BattleFairyModel:getFormulaParams()
    local params = {
        ATK = 0,
        DEF = 0,
        MP = 0,
        HP = 0,
        FH = 0,
        heroLV = 0,
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
--- end FighterModel 虚函数 -------

function BattleFairyModel:isInCooling()
    return self.inCooling
end

function BattleFairyModel:update(battleModel)
    local oldCoolTimeLeft = self.coolTimeLeft
    self.coolTimeLeft = self.coolTimeLeft - BattleConfig.TIME_UNIT

    local leftTime = self.coolTimeLeft
    local CD = self.COOL_TIME
    local cdPercent = 100 - math.floor(leftTime / CD * 100)
    if self.coolPercent ~= cdPercent then
        self.coolPercent = cdPercent

        local teamSide = self.team:getSide()
        battleModel:dispatchEvent(AppEvent.UI.Battle.FairyCoolPercentChange, {fighterID = self:getFighterID(), teamSide = teamSide, percent = cdPercent})
    end

    if self.coolTimeLeft <= 0 and oldCoolTimeLeft > 0 then
        local teamSide = self.team:getSide()
        self.inCooling = false
        battleModel:dispatchEvent(AppEvent.UI.Battle.FairyCool, {fighterID = self:getFighterID(), teamSide = teamSide})
    end
end

function BattleFairyModel:getTeamSide()
    return self.team:getSide()
end

function BattleFairyModel:setView(view)
    self.view = view
end

function BattleFairyModel:getView()
    return self.view
end

function BattleFairyModel:getAttackSpeedVar()
    return 1
end

function BattleFairyModel:getSkills()
    local skills = {self.fairyConfig.Skill1, self.fairyConfig.Skill2 }
    return skills
end

function BattleFairyModel:getSkill(index)
    local skills = {self.fairyConfig.Skill1, self.fairyConfig.Skill2 }
    local skillID = skills[index] or 0
    return skillID
end

function BattleFairyModel:releaseSkill(index)
    local skillID = self:getSkill(index)
    local skillLV = self.fairyData.SkillLevel[index] or 1
    if skillID  and skillID ~= 0 then
        CCLog(vardump({skills = self:getSkills(), index = index}, "BattleFairyModel:releaseSkill()"))
        local attackData = AttackDataModel.new(self, self._battleModel, skillID, skillLV)
        self.team:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
    end

    self.coolTimeLeft = self.COOL_TIME
    self.inCooling = true
end

function BattleFairyModel:autoReleaseSkill()
    local skillIndex = 1

    if self.treatSkillIndex then
        if not self.team:hasHeroHPUnderHalf() then
            skillIndex = self.otherSkillIndex
        else
            skillIndex = self.treatSkillIndex
        end
    else
        if self.lastReleaseIndex == 1 then
            self.lastReleaseIndex = 2
            skillIndex = 2
        else
            self.lastReleaseIndex = 1
        end
    end

    self:releaseSkill(skillIndex)
end

function BattleFairyModel:getName()
    return self.fairyConfig.Name
end

function BattleFairyModel:getAttackSpeed()
    return 3000
end

function BattleFairyModel:getHeadIconPath()
    return string.format("image/ui/fairy/%s_head.png", self.fairyConfig.Res)
end

return BattleFairyModel