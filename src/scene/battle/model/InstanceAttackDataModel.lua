--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-31
-- Time: 下午12:19
-- 副本技能
--
local ElemType = require("config.ElemType")
local BHT = require("tool.lib.BehaviourTree")
local BattleHelper = require("scene.battle.helper.BattleHelper")
-------------------------------------------------------------------------------

local InstanceAttackDataModel = class("InstanceAttackDataModel")

function InstanceAttackDataModel:ctor(battleModel, pos, skillID, attrs)
    self.battleModel = battleModel
    self.attrs = attrs or {}
    self.pos = pos
    self.skillID = skillID
    self.skillData = assert(BaseConfig.GetHeroSkill(skillID, 1), "InstanceAttackDataModel getSkillData")
end

function InstanceAttackDataModel:getCell()
    return self.pos
end

function InstanceAttackDataModel:getTargetFighterList()
    -- TODO:
    return {}
end

function InstanceAttackDataModel:generateFormulaParams(enemyModel)
    local attackerParams = self:getInstanceFormulaParams()
    local defenderParams = enemyModel:getFormulaParams()
    local comboHit = 0
    local restraint = ElemType.damageRestraint
    local fromCell = self.heroModel:getCell()
    local toCell = enemyModel:getCell()
    local dist = math.sqrt((fromCell.x - toCell.x) ^ 2 + (fromCell.y - toCell.y) ^ 2)

    local params = {
        A = attackerParams,
        D = defenderParams,
        skillLV = 1,
        restraint = restraint,
        dist = dist,
        MAX = math.max,
        MIN = math.min,
    }

    return params
end

function InstanceAttackDataModel:getFormulaParams()
    --    属性	字段
    --    攻击	ATK
    --    防御	DEF
    --    法力	MP
    --    生命（当前值）	HP
    --    生命（最大值）	FH
    --    技能等级	skillLV
    --    人物等级	heroLV
    --    五行克制函数	restraint(A,D)
    --    普通攻击加成	damageAddition
    --    普通攻击减免	damageReduction
    --    技能攻击加成	skillAddition
    --    技能攻击减免	skillReduction
    --    治疗效果加成	treatmentAddition
    --    被治疗效果加成	treatedAddition
    --    治疗效果减免	treatmentReduction
    --    被治疗效果减免 	treatedReduction
    --    额外五行伤害加成	specDamageAddition
    --    额外五行伤害减免	specDamageReduction
    --    连击伤害加成	comboHit
    --    距离	dist


    local ATK = self.attrs.Atk or 1
    local DEF = self.attrs.Def or 1
    local MP = 1
    local HP = 1
    local FH = 1
    local heroLV = 1
    local WX = self.attrs.WX

    local damageAddition           = 0
    local damageReduction          = 0
    local skillAddition         = 0
    local skillReduction        = 0
    local treatmentAddition     = 0
    local treatedAddition       = 0
    local treatmentReduction    = 0
    local treatedReduction      = 0
    local specDamageAddition    = 0
    local specDamageReduction   = 0
    local comboHit              = 0

    local params = {
        ATK = ATK,
        DEF = DEF,
        MP = MP,
        HP = HP,
        FH = FH,
        heroLV = heroLV,
        damageAddition = damageAddition,
        damageReduction = damageReduction,
        skillAddition = skillAddition,
        skillReduction = skillReduction,
        treatmentAddition = treatmentAddition,
        treatedAddition = treatedAddition,
        treatmentReduction = treatmentReduction,
        treatedReduction = treatedReduction,
        specDamageAddition = specDamageAddition,
        specDamageReduction = specDamageReduction,
        comboHit = comboHit,
        WX = WX,
    }

    return params
end

return InstanceAttackDataModel
