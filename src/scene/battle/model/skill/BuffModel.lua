--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-5
-- Time: 下午2:43
-- To change this template use File | Settings | File Templates.
--
--int	int	int	int	int	int	int
--id	isGain	affect	value	duration	overlap	interval
--ID	是否增益	作用	值	持续时间	是否多次触发	触发间隔							buff作用枚举

local BHT = require("tool.lib.BehaviourTree")
local BattleHelper = require("scene.battle.helper.BattleHelper")
local BattleModel = require("scene.battle.model.BattleModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local ElemType = require("config.ElemType")
-------------------------------------------------------------------------------

local BuffDescMap = {
    "持续伤害（值为公式ID）	",
    "持续回血（值为公式ID）	",
    "眩晕	",
    "魅惑	",
    "增加命中	",
    "增加闪避	",
    "增加暴击	",
    "增加韧性	",
    "增加攻击	",
    "增加防御	",
    "增加攻击万分比	",
    "增加防御万分比	",
    "反弹伤害万分比	",
    "击杀敌人回血（按目标的血量上限的万分比）	",
    "增加治疗效果	",
    "增加被治疗效果	",
    "己方每次阵亡一个单位，增加一定攻击万分比	",
    "增加普通攻击伤害（万分比）	",
    "减免普通攻击伤害（万分比）	",
    "增加技能攻击伤害（万分比）	",
    "减免技能攻击伤害（万分比）	",
    "额外五行伤害加成	",
    "额外五行伤害减免	",
    "迟缓（降低50%的攻击速度和移动速度）	",
    "致盲（降低50%命中率）	",
    "增加攻击速度万分比	",
    "隐身（只有五行对其克制的角色才能攻击他）	",
    "金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）	",
    "木属性护盾 能吸收金属性以外的所有伤害	",
    "水属性护盾 能吸收土属性以外的所有伤害	",
    "火属性护盾 能吸收水属性以外的所有伤害	",
    "土属性护盾 能吸收木属性以外的所有伤害	",
    "缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）	",
    "伤害减免（降低20%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）	",
    "沉默（无法释放技能）	",
    "中毒(持续掉血,值为公式;降低30%移动速度,攻击速度)	",
    "增加闪避值万分比	",
    "定身（无法移动，可以攻击使用技能）	",
    "法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）	",
    "昏睡（无法移动，无法攻击，受到攻击自动解除）",
    "反弹技能伤害",
    "禁锢",
    "冰冻",
    "禁止回血",
}

local BuffModel = class("BuffModel")

-- heroModel BUFF拥有者 attackerModel: 施法者
function BuffModel:ctor(fighter, buffID, skillID, skillLevel, attacker)
--    assert(iskindof(heroModel, "BattleHeroModel"), "own hero is not BattleHeroModel")
--    assert(iskindof(attackerModel, "BattleHeroModel"), "attacker is not BattleHeroModel")
--    assert(type(buffID) == "number", "buffID is not number")

    self.fighter = fighter
    self.attacker = attacker

    self.buffID = buffID
    self.skillID = skillID
    self.skillLevel = skillLevel
    self.buffData = BaseConfig.GetBuff(buffID)
    --self.bhtRoot = self:createBHT()

    self.timeLeft = self.buffData.duration
    self.lastTimeLeft = self.timeLeft

    self.interval = 0

    -- 法术盾 之类 值会用掉的
    self.affectValueLeft = self.buffData.value
    self.magicShieldValue = self:calcMagicShieldValue()
    self.formulaValue = nil

    local intervalHandlerMap = {
        [enums.BuffAffectType.DamageOverTime] = self.damageOverTime,
        [enums.BuffAffectType.ContinuesIncHP] = self.continuesIncHP,
        [enums.BuffAffectType.Entangled]      = self.damageOverTime,
        [enums.BuffAffectType.Poisoning]      = self.damageOverTime,
    }
    self.intervalHandler = intervalHandlerMap[self.buffData.affect]
end

function BuffModel:encode()
    local attackerID = self.attacker and self.attacker:getFighterID() or nil
    return json.encode({fighterID = self.fighter:getFighterID(), buffID = self.buffID, skillID = self.skillID, skillLevel = self.skillLevel, attackerID = attackerID})
end

function BuffModel.decode(jsonStr, battleModel)
    local FighterModel = require("scene.battle.model.fighter.FighterModel")

    local jsData = json.decode(jsonStr)
    local fighter =  FighterModel.getFighter(jsData.fighterID)
    local buffID = jsData.buffID
    local skillID = jsData.skillID
    local skillLevel = jsData.skillLevel
    local attackerID = jsData.attackerID
    local attacker = nil
    if attackerID then
        attacker = FighterModel.getFighter(attackerID)
    end

    --CCLog(vardump({jsData = jsData, heroModel = heroModel, attackerModel = attackerModel, buffID = buffID}, "BuffModel:decode"))
    return BuffModel.new(fighter, buffID, skillID, skillLevel, attacker)
end

function BuffModel:getSkillID()
    return self.skillID
end

function BuffModel:getBuffID()
    return self.buffID
end

function BuffModel:getBuffData()
    return self.buffData
end

local affectFormulaTypes = {
    [enums.BuffAffectType.MetalShield] = true,
    [enums.BuffAffectType.WoodShield ] = true,
    [enums.BuffAffectType.WaterShield] = true,
    [enums.BuffAffectType.FireShield ] = true,
    [enums.BuffAffectType.EarthShield] = true,
}

function BuffModel:useMagicShieldValue(maxValue)
    local value = 0
    if maxValue >= self.magicShieldValue then
        value = self.magicShieldValue
        self.magicShieldValue = 0
        self.timeLeft = 0
    else
        value = maxValue
        self.magicShieldValue = self.magicShieldValue - maxValue
    end

    CCLogf("%s:useMagicShieldValue(max = %d, val = %d, left = %d)", self.fighter:getName(), maxValue, value, self.magicShieldValue)
    return value
end

function BuffModel:calcMagicShieldValue()
    local affectType = self.buffData.affect
    if affectFormulaTypes[affectType] == nil then
        return 0
    end

    local formulaID = self.buffData.value

    if formulaID > 0 then
        local formulaFunction = assert(BaseConfig.FormulaFunc(formulaID), string.format("formula:%d", formulaID))

        local heroModel = self.fighter
        local attackerParams = heroModel:getFormulaParams()
        local defenderParams = {}
        local comboHit = 0
        local restraint = ElemType.damageRestraint
        local dist = 0

        local params = {
            A = attackerParams,
            D = defenderParams,
            skillLV = self.skillLevel,
            restraint = restraint,
            dist = dist,
            MAX = math.max,
            MIN = math.min,
        }

        local formulaValue = formulaFunction(params)
        return math.floor(formulaValue)
    end
    return 0
end

function BuffModel:getBuffDesc()
    return BuffDescMap[self.buffData.affect] or ""
end

-- 是否为负面状态
BuffModel.UsefulMap = {
    [enums.BuffAffectType.DamageOverTime            ] = false, --	持续伤害（值为公式ID）
    [enums.BuffAffectType.ContinuesIncHP            ] = true,  --	持续回血（值为公式ID）
    [enums.BuffAffectType.Vertigo                   ] = false, --	眩晕
    [enums.BuffAffectType.Charm                     ] = false, --	魅惑
    [enums.BuffAffectType.AddHit                    ] = true,  --	增加命中
    [enums.BuffAffectType.AddMiss                   ] = true,  --	增加闪避
    [enums.BuffAffectType.AddCri                    ] = true,  --	增加暴击
    [enums.BuffAffectType.AddTen                    ] = true,  --	增加韧性
    [enums.BuffAffectType.AddATK                    ] = true,  --	增加攻击
    [enums.BuffAffectType.AddDEF                    ] = true,  --	增加防御
    [enums.BuffAffectType.AddATKRatio               ] = true,  --	增加攻击万分比
    [enums.BuffAffectType.AddDEFRatio               ] = true,  --	增加防御万分比
    [enums.BuffAffectType.AntiInjuryRatio           ] = true,  --	反弹伤害万分比
    [enums.BuffAffectType.KillBackHPRatio           ] = true,  --	击杀敌人回血（按目标的血量上限的万分比）
    [enums.BuffAffectType.AddTreatment              ] = true,  --	增加治疗效果
    [enums.BuffAffectType.AddTreated                ] = true,  --	增加被治疗效果
    [enums.BuffAffectType.AddRatioATKByTeammateDie  ] = true,  --	己方每次阵亡一个单位，增加一定攻击万分比
    [enums.BuffAffectType.AddNormATKRatio           ] = true,  --	增加普通攻击伤害（万分比）
    [enums.BuffAffectType.DecNormATKRatio           ] = true,  --	减免普通攻击伤害（万分比）
    [enums.BuffAffectType.AddSkillATKRatio          ] = true,  --	增加技能攻击伤害（万分比）
    [enums.BuffAffectType.DecSkillATKRatio          ] = true,  --	减免技能攻击伤害（万分比）
    [enums.BuffAffectType.AddExtraElemDamage        ] = true,  --	额外五行伤害加成
    [enums.BuffAffectType.DecExtraElemDamage        ] = true,  --	额外五行伤害减免
    [enums.BuffAffectType.Slow                      ] = false, --	迟缓（降低Name = 50, --%的攻击速度和移动速度）
    [enums.BuffAffectType.Blinding                  ] = false, --	致盲（降低Name = 50, --%命中率）
    [enums.BuffAffectType.AddAttckSpeedRatio        ] = true,  --	增加攻击速度万分比
    [enums.BuffAffectType.Hide                      ] = true,  --	隐身（只有五行对其克制的角色才能攻击他）
    [enums.BuffAffectType.MetalShield               ] = true,  --	金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）
    [enums.BuffAffectType.WoodShield                ] = true,  --	木属性护盾 能吸收金属性以外的所有伤害
    [enums.BuffAffectType.WaterShield               ] = true,  --	水属性护盾 能吸收土属性以外的所有伤害
    [enums.BuffAffectType.FireShield                ] = true,  --	火属性护盾 能吸收水属性以外的所有伤害
    [enums.BuffAffectType.EarthShield               ] = true,  --	土属性护盾 能吸收木属性以外的所有伤害
    [enums.BuffAffectType.Entangled                 ] = false, --	缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
    [enums.BuffAffectType.DamageReduction           ] = true, --	伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）
    [enums.BuffAffectType.Silence                   ] = false, --	沉默（无法释放技能）
    [enums.BuffAffectType.Poisoning                 ] = false, --	中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)
    [enums.BuffAffectType.AddMissRatio              ] = true, --	增加闪避值万分比
    [enums.BuffAffectType.FixedBody                 ] = false, --	定身（无法移动，可以攻击使用技能）
    [enums.BuffAffectType.SpellShield               ] = true, --	法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）
    [enums.BuffAffectType.Sleep                     ] = false, --    昏睡（无法移动，无法攻击，受到攻击自动解除）
    [enums.BuffAffectType.SkillAntiInjuryRatio      ] = true, --    反弹技能伤害
}
function BuffModel:isDebuff()
    return BuffModel.UsefulMap[self.buffData.affect] == false
end

function BattleModel:getTimeLeft()
    return self.timeLeft
end

function BattleModel:getAffectValueLeft()
    return self.affectValueLeft
end

function BattleModel:decAffectValueLeft()
   self.affectValueLeft =  self.affectValueLeft - 1
end

-- 设置英雄
function BuffModel:setFighterModel(fighter)
    self.fighter = fighter
end

-- 每个时间单位更新，处理持续性BUFF
function BuffModel:update()
    self.lastTimeLeft = self.timeLeft
    self.timeLeft = self.timeLeft - BattleConfig.TIME_UNIT
    self.interval = self.interval - BattleConfig.TIME_UNIT

    if self.interval <= 0 then
        self.interval = self.buffData.interval

        if self.intervalHandler then
            self.intervalHandler(self)
        end
    end

--    self.bhtRoot:update(self)
end

--function BuffModel:createBHT()
--    local Action = BHT.Action.new
--    local Condition = BHT.Condition.new
--    local Selector = BHT.Selector.new
--    local Sequence = BHT.Sequence.new
--
--    local Conditions = BattleHelper.Conditions
--
--    local root = Selector{
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isDamageOverTime, "持续伤害（值为公式ID）"),
--            Action(handler(self, self.onDamageOverTime), "持续伤害（值为公式ID）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isContinuesIncHP, "持续回血（值为公式ID）"),
--            Action(handler(self, self.onContinuesIncHP), "持续回血（值为公式ID）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isVertigo, "眩晕"),
--            Action(handler(self, self.onVertigo), "眩晕"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isCharm, "魅惑"),
--            Action(handler(self, self.onCharm), "魅惑"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddHit, "增加命中"),
--            Action(handler(self, self.onAddHit), "增加命中"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddMiss, "增加闪避"),
--            Action(handler(self, self.onAddMiss), "增加闪避"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddCri, "增加暴击"),
--            Action(handler(self, self.onAddCri), "增加暴击"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddTen, "增加韧性"),
--            Action(handler(self, self.onAddTen), "增加韧性"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddATK, "增加攻击"),
--            Action(handler(self, self.onAddATK), "增加攻击"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddDEF, "增加防御"),
--            Action(handler(self, self.onAddDEF), "增加防御"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddATKRatio, "增加攻击万分比"),
--            Action(handler(self, self.onAddATKRatio), "增加攻击万分比"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddDEFRatio, "增加防御万分比"),
--            Action(handler(self, self.onAddDEFRatio), "增加防御万分比"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAntiInjuryRatio, "反弹伤害万分比"),
--            Action(handler(self, self.onAntiInjuryRatio), "反弹伤害万分比"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isKillBackHPRatio, "击杀敌人回血（按目标的血量上限的万分比）"),
--            Action(handler(self, self.onKillBackHPRatio), "击杀敌人回血（按目标的血量上限的万分比）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddTreatment, "增加治疗效果"),
--            Action(handler(self, self.onAddTreatment), "增加治疗效果"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddTreated, "增加被治疗效果"),
--            Action(handler(self, self.onAddTreated), "增加被治疗效果"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddRatioATKByTeammateDie, "己方每次阵亡一个单位，增加一定攻击万分比"),
--            Action(handler(self, self.onAddRatioATKByTeammateDie), "己方每次阵亡一个单位，增加一定攻击万分比"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddNormATKRatio, "增加普通攻击伤害（万分比）"),
--            Action(handler(self, self.onAddNormATKRatio), "增加普通攻击伤害（万分比）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isDecNormATKRatio, "减免普通攻击伤害（万分比）"),
--            Action(handler(self, self.onDecNormATKRatio), "减免普通攻击伤害（万分比）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddSkillATKRatio, "增加技能攻击伤害（万分比）"),
--            Action(handler(self, self.onAddSkillATKRatio), "增加技能攻击伤害（万分比）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isDecSkillATKRatio, "减免技能攻击伤害（万分比）"),
--            Action(handler(self, self.onDecSkillATKRatio), "减免技能攻击伤害（万分比）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddExtraElemDamage, "额外五行伤害加成"),
--            Action(handler(self, self.onAddExtraElemDamage), "额外五行伤害加成"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isDecExtraElemDamage, "额外五行伤害减免"),
--            Action(handler(self, self.onDecExtraElemDamage), "额外五行伤害减免"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isSlow, "迟缓（降低Name = 50, --%的攻击速度和移动速度）"),
--            Action(handler(self, self.onSlow), "迟缓（降低Name = 50, --%的攻击速度和移动速度）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isBlinding, "致盲（降低Name = 50, --%命中率）"),
--            Action(handler(self, self.onBlinding), "致盲（降低Name = 50, --%命中率）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddAttckSpeedRatio, "增加攻击速度万分比"),
--            Action(handler(self, self.onAddAttckSpeedRatio), "增加攻击速度万分比"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isHide, "隐身（只有五行对其克制的角色才能攻击他）"),
--            Action(handler(self, self.onHide), "隐身（只有五行对其克制的角色才能攻击他）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isMetalShield, "金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）"),
--            Action(handler(self, self.onMetalShield), "金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isWoodShield, "木属性护盾 能吸收金属性以外的所有伤害"),
--            Action(handler(self, self.onWoodShield), "木属性护盾 能吸收金属性以外的所有伤害"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isWaterShield, "水属性护盾 能吸收土属性以外的所有伤害"),
--            Action(handler(self, self.onWaterShield), "水属性护盾 能吸收土属性以外的所有伤害"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isFireShield, "火属性护盾 能吸收水属性以外的所有伤害"),
--            Action(handler(self, self.onFireShield), "火属性护盾 能吸收水属性以外的所有伤害"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isEarthShield, "土属性护盾 能吸收木属性以外的所有伤害"),
--            Action(handler(self, self.onEarthShield), "土属性护盾 能吸收木属性以外的所有伤害"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isEntangled, "缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）"),
--            Action(handler(self, self.onEntangled), "缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isDamageReduction, "伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）"),
--            Action(handler(self, self.onDamageReduction), "伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isSilence, "沉默（无法释放技能）"),
--            Action(handler(self, self.onSilence), "沉默（无法释放技能）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isPoisoning, "中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)"),
--            Action(handler(self, self.onPoisoning), "中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isAddMissRatio, "增加闪避值万分比"),
--            Action(handler(self, self.onAddMissRatio), "增加闪避值万分比"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isFixedBody, "定身（无法移动，可以攻击使用技能）"),
--            Action(handler(self, self.onFixedBody), "定身（无法移动，可以攻击使用技能）"),
--        },
--        Sequence{
--            Condition(Conditions.Buff.AffectType.isSpellShield, "法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）"),
--            Action(handler(self, self.onSpellShield), "法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）"),
--        },
--    }
--    return root
--end

function BuffModel:isFinish()
    return self.timeLeft <= 0
end

--持续伤害（值为公式ID）
function BuffModel:damageOverTime()
    local formulaValue = self.formulaValue
    if formulaValue == nil then
        formulaValue = self:calcFormulaValue()
    end

    if self.fighter.isEgg and self.fighter:isEgg() then
        -- 空
    else
        self.fighter:hitBy(formulaValue, self.attacker, true)
        CCLog("BUFF持续伤害", formulaValue)
    end
end

--持续回血（值为公式ID）
function BuffModel:continuesIncHP()
    local formulaValue = self.formulaValue
    if formulaValue == nil then
        formulaValue = self:calcFormulaValue()
    end

    if self.fighter:isAlive() then
        self.fighter:incHP(formulaValue, true, true)
        CCLog("BUFF持续回血", formulaValue)
    end
end

function BuffModel:isBreakOffAttack(attackData)
    if self.buffData.type == enums.BuffAffectType.Vertigo then
        return true
    elseif self.buffData.type == enums.BuffAffectType.Silence then
        if attackData.skillData.type ~= enums.SkillType.NormAttack then
            return true
        end
    elseif self.buffData.type == enums.BuffAffectType.Sleep then
        return true
    elseif self.buffData.type == enums.BuffAffectType.Frozen then
        return true
    elseif self.buffData.type == enums.BuffAffectType.Shackle then
        return true
    end

    return false
end

function BuffModel:onHit()
    if self.buffData.affect == enums.BuffAffectType.Sleep then
        CCLog("晕睡被打醒")
        self.timeLeft = 0
    end
end


----眩晕
--function BuffModel:onVertigo()
--    -- TODO:
--    return true
--end
--
----魅惑
--function BuffModel:onCharm()
--    return true
--end
--
----增加命中
--function BuffModel:onAddHit()
--    return true
--end
--
----增加闪避
--function BuffModel:onAddMiss()
--    return true
--end
--
----增加暴击
--function BuffModel:onAddCri()
--    return true
--end
--
----增加韧性
--function BuffModel:onAddTen()
--    return true
--end
--
----增加攻击
--function BuffModel:onAddATK()
--    return true
--end
--
----增加防御
--function BuffModel:onAddDEF()
--    return true
--end
--
----增加攻击万分比
--function BuffModel:onAddATKRatio()
--    return true
--end
--
----增加防御万分比
--function BuffModel:onAddDEFRatio()
--    return true
--end
--
----反弹伤害万分比
--function BuffModel:onAntiInjuryRatio()
--    return true
--end
--
----击杀敌人回血（按目标的血量上限的万分比）
--function BuffModel:onKillBackHPRatio()
--    return true
--end
--
----增加治疗效果
--function BuffModel:onAddTreatment()
--    return true
--end
--
----增加被治疗效果
--function BuffModel:onAddTreated()
--    return true
--end
--
----己方每次阵亡一个单位，增加一定攻击万分比
--function BuffModel:onAddRatioATKByTeammateDie()
--    return true
--end
--
----增加普通攻击伤害（万分比）
--function BuffModel:onAddNormATKRatio()
--    return true
--end
--
----减免普通攻击伤害（万分比）
--function BuffModel:onDecNormATKRatio()
--    return true
--end
--
----增加技能攻击伤害（万分比）
--function BuffModel:onAddSkillATKRatio()
--    return true
--end
--
----减免技能攻击伤害（万分比）
--function BuffModel:onDecSkillATKRatio()
--    return true
--end
--
----额外五行伤害加成
--function BuffModel:onAddExtraElemDamage()
--    return true
--end
--
----额外五行伤害减免
--function BuffModel:onDecExtraElemDamage()
--    return true
--end
--
----迟缓（降低Name = 50, --%的攻击速度和移动速度）
--function BuffModel:onSlow()
--    return true
--end
--
----致盲（降低Name = 50, --%命中率）
--function BuffModel:onBlinding()
--    return true
--end
--
----增加攻击速度万分比
--function BuffModel:onAddAttckSpeedRatio()
--    return true
--end
--
----隐身（只有五行对其克制的角色才能攻击他）
--function BuffModel:onHide()
--    return true
--end
--
----金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）
--function BuffModel:onMetalShield()
--    return true
--end
--
----木属性护盾 能吸收金属性以外的所有伤害
--function BuffModel:onWoodShield()
--    return true
--end
--
----水属性护盾 能吸收土属性以外的所有伤害
--function BuffModel:onWaterShield()
--    return true
--end
--
----火属性护盾 能吸收水属性以外的所有伤害
--function BuffModel:onFireShield()
--    return true
--end
--
----土属性护盾 能吸收木属性以外的所有伤害
--function BuffModel:onEarthShield()
--    return true
--end
--
----缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
--function BuffModel:onEntangled()
--    if self.interval <= 0 then
--        -- TODO:
--        self.interval = self.buffData.interval
--
--        self:intervalDamage()
--    end
--
--    return true
--end
--
----伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）
--function BuffModel:onDamageReduction()
--    return true
--end
--
----沉默（无法释放技能）
--function BuffModel:onSilence()
--    return true
--end
--
----中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)
--function BuffModel:onPoisoning()
--    if self.interval <= 0 then
--        -- TODO:
--        self.interval = self.buffData.interval
--
--        self:intervalDamage()
--    end
--
--    return true
--end

function BuffModel:calcFormulaValue()
    local attackerParams = self.attacker:getFormulaParams()
    local defenderParams = self.fighter:getFormulaParams()
    local comboHit = 0
    local restraint = ElemType.damageRestraint
    local dist = 0

    local params = {
        A = attackerParams,
        D = defenderParams,
        skillLV = self.skillLevel,
        restraint = restraint,
        comboHit = 0,
        dist = dist,
        MAX = math.max,
        MIN = math.min,
    }

    local formulaExpr = BaseConfig.FormulaContent(self.buffData.value)
    local formulaFunction = assert(BaseConfig.FormulaFunc(self.buffData.value), string.format("formula[%d]:%s", self.buffData.value, formulaExpr))
    local affectValue = formulaFunction(params)
    affectValue = math.floor(affectValue)

    return affectValue
end

----增加闪避值万分比
--function BuffModel:onAddMissRatio()
--    return true
--end
--
----定身（无法移动，可以攻击使用技能）
--function BuffModel:onFixedBody()
--    return true
--end
--
----法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）
--function BuffModel:onSpellShield()
--    return true
--end

return BuffModel