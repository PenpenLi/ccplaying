--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-18
-- Time: 下午5:01
-- To change this template use File | Settings | File Templates.
--

local function check_attr_nil(aTable)
    local mt = {}
    mt.__index = function(table, name)
        local val = rawget(table, name)
        return assert(val, name)
    end
    setmetatable(aTable, mt)
end

local Conditions = {}
check_attr_nil(Conditions)
Conditions.Skill = {}
check_attr_nil(Conditions.Skill)


--[[ 技能类型
    1--普通攻击
    2--普通技能（概率触发）
    3--怒气技能
    4--天赋技能

local SkillType = {
    NormAttack = 1,
    NormSkill = 2,
    RageSkill = 3,
    InnateSkill = 4
}
--]]
Conditions.Skill.Type = {}
check_attr_nil(Conditions.Skill.Type)
function Conditions.Skill.Type.isNormAttack(attackData)
    return attackData.skillData.type == enums.SkillType.NormAttack
end

function Conditions.Skill.Type.isNormSkill(attackData)
    return attackData.skillData.type == enums.SkillType.NormSkill
end

function Conditions.Skill.Type.isRageSkill(attackData)
    return attackData.skillData.type == enums.SkillType.RageSkill
end

function Conditions.Skill.Type.isInnateSkill(attackData)
    return attackData.skillData.type == enums.SkillType.InnateSkill
end


-- 技能释放类型：自动释放，区域选择
-- local SkillReleaseMode = {Auto = 0, Region = 1 }
Conditions.Skill.ReleaseMode = {}
check_attr_nil(Conditions.Skill.ReleaseMode)
function Conditions.Skill.ReleaseMode.isAuto(attackData)
    return attackData.skillData.mode == enums.SkillMode.Auto
end

function Conditions.Skill.ReleaseMode.isRegion(attackData)
    return attackData.skillData.mode == enums.SkillMode.Region
end

--[[ 技能持续时间类型
    1.瞬间生效
    2.放在地上的阵法技能（持续作用于一定范围）
    3.以自身为中心的可移动阵法技能
    4.持续施法（自身不动，可被打断）

local SkillDurationMode = {
    Instant = 1,
    FixedMagicCircle = 2,
    FollowMagicCircle = 3,
    Continuous = 4
}
--]]
Conditions.Skill.DurationMode = {}

function Conditions.Skill.DurationMode.isInstant(attackData)
    return attackData.skillData.durationType == enums.SkillDurationMode.Instant
end

function Conditions.Skill.DurationMode.isFixedMagicCircle(attackData)
    return attackData.skillData.durationType == enums.SkillDurationMode.FixedMagicCircle
end

function Conditions.Skill.DurationMode.isFollowMagicCircle(attackData)
    return attackData.skillData.durationType == enums.SkillDurationMode.FollowMagicCircle
end

function Conditions.Skill.DurationMode.isContinuous(attackData)
    return attackData.skillData.durationType == enums.SkillDurationMode.Continuous
end

--[[ 技能效果目标
    1-敌方全部
    2-己方全部
    3-自己
    4-敌方单体（仇恨目标）
    5-敌方单体（随机）
    6-敌方多个目标（仇恨目标为中心点，作用范围内）
    7-友方多个目标（作用范围内）
    8-友方单体（随机）
    9-敌方血量最少的目标
    10-血量百分比最少的己方目标
    11-敌方多个目标（自己为中心点，作用范围内）
    12-敌方多个目标(玩家选择的作用范围内)
    13-已经死亡队友

local SkillAffectTarget = {
    AllEnemies = 1,
    AllTeammates = 2,
    Self = 3,
    MatchedEnemy = 4,
    RandomEnemy = 5,
    ScopeEnemies = 6,
    ScopeTeammates = 7,
    RandomTeamate = 8,
    MostWeakEnemy = 9,
    MinPercentHPTeammate = 10,
    AroundEnemies = 11,
    SelectAreaEnemies = 12,
    DeadTeammate = 13,
}
--]]

Conditions.Skill.AffectTarget = {}
check_attr_nil(Conditions.Skill.AffectTarget)
function Conditions.Skill.AffectTarget.isAllEnemies(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.AllEnemies
end

function Conditions.Skill.AffectTarget.isAllTeammates(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.AllTeammates
end

function Conditions.Skill.AffectTarget.isSelf(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.Self
end

function Conditions.Skill.AffectTarget.isMatchedEnemy(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.MatchedEnemy
end

function Conditions.Skill.AffectTarget.isRandomEnemy(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.RandomEnemy
end

function Conditions.Skill.AffectTarget.isScopeEnemies(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.ScopeEnemies
end

function Conditions.Skill.AffectTarget.isScopeTeammates(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.ScopeTeammates
end

function Conditions.Skill.AffectTarget.isRandomTeamate(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.RandomTeamate
end

function Conditions.Skill.AffectTarget.isMostWeakEnemy(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.MostWeakEnemy
end

function Conditions.Skill.AffectTarget.isMinPercentHPTeammate(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.MinPercentHPTeammate
end

function Conditions.Skill.AffectTarget.isAroundEnemies(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.AroundEnemies
end

function Conditions.Skill.AffectTarget.isSelectAreaEnemies(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.SelectAreaEnemies
end

function Conditions.Skill.AffectTarget.isDeadTeammate(attackData)
    return attackData.skillData.target == enums.SkillAffectTarget.DeadTeammate
end

--[[ 技能效果类型
    1-伤害
    2-治疗
    3--复活（公式为复活后的血量）
    4--召唤
    5--复制凶手

local SkillAffectType = {
    Damage = 1,
    Treatment = 2,
    Resurrection = 3,
    Summoner = 4,
    CopyKiller = 5
}
--]]
Conditions.Skill.Affect = {}
check_attr_nil(Conditions.Skill.Affect)

function Conditions.Skill.Affect.isDamage(attackData)
    return attackData.skillData.affect == enums.SkillAffectType.Damage
end

function Conditions.Skill.Affect.isTreatment(attackData)
    return attackData.skillData.affect == enums.SkillAffectType.Treatment
end

function Conditions.Skill.Affect.isResurrection(attackData)
    return attackData.skillData.affect == enums.SkillAffectType.Resurrection
end

function Conditions.Skill.Affect.isSummoner(attackData)
    return attackData.skillData.affect == enums.SkillAffectType.Summoner
end

function Conditions.Skill.Affect.isReplication(attackData)
    return attackData.skillData.affect == enums.SkillAffectType.Replication
end

function Conditions.Skill.Affect.isNone(attackData)
    return attackData.skillData.affect == enums.SkillAffectType.None
end

--[[ 技能附加效果：反击，秒杀，弹射，减敌方怒气，加自己的怒气，加自己的血量
    1--击退（几格）
    2--秒杀（血量低于某个百分比）
    3--额外伤害1（触发特殊效果时，伤害值=普通效果的公式+额外伤害公式）
    4-减少对方怒气
    5--增加己方怒气
    6-回复自身生命（按造成伤害的万分比回血）
    7-连续攻击（值为次数）
    8-若目标死亡，周围4格内所有敌方单位受到相同伤害
    9-清除目标身上不利状态
    10--额外伤害2（触发特殊效果时，伤害值=额外伤害公式）
    11--分身（1-10级分身数位1,11-20级分身数位2,21级以上分身数位3  分身持续4s）
    12--对男性目标有额外加成（万分比）
    13--对女性目标有额外加成（万分比）
    14--清除己方单位的不利状态（100%成功），并有一定概率把不理状态转移到对方身上（随机）
    15--提高对男性角色使用buff的成功率

local SkillExtraAffect = {
    Knockback = 1,
    Seckilling = 2,
    AddDamage_1 = 3,
    DecEnemyRage = 4,
    IncSelfRage = 5,
    IncSelfHP = 6,
    ComboHit = 7,
    Bomber = 8,
    ClearDebuff = 9,
    AddDamage_2 = 10,
    Replication = 11,
    ExtraDamageForMale = 12,
    ExtraDamageForFemale = 13,
    TransferDebuff = 14,
    IncMaleBuffSuccessRate = 15,
}
--]]

Conditions.Skill.ExtrtaAffect = {}
check_attr_nil(Conditions.Skill.ExtrtaAffect)

function Conditions.Skill.ExtrtaAffect.isKnockback(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.Knockback
end

function Conditions.Skill.ExtrtaAffect.isSeckilling(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.Seckilling
end

function Conditions.Skill.ExtrtaAffect.isAddDamage_1(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.AddDamage_1
end

function Conditions.Skill.ExtrtaAffect.isDecEnemyRage(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.DecEnemyRage
end

function Conditions.Skill.ExtrtaAffect.isIncSelfRage(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.IncSelfRage
end

function Conditions.Skill.ExtrtaAffect.isIncSelfHP(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.IncSelfHP
end

function Conditions.Skill.ExtrtaAffect.isComboHit(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.ComboHit
end

function Conditions.Skill.ExtrtaAffect.isBomber(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.Bomber
end

function Conditions.Skill.ExtrtaAffect.isClearDebuff(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.ClearDebuff
end

function Conditions.Skill.ExtrtaAffect.isAddDamage_2(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.AddDamage_2
end

function Conditions.Skill.ExtrtaAffect.isReplication(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.Replication
end

function Conditions.Skill.ExtrtaAffect.isExtraDamageForMale(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.ExtraDamageForMale
end

function Conditions.Skill.ExtrtaAffect.isExtraDamageForFemale(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.ExtraDamageForFemale
end

function Conditions.Skill.ExtrtaAffect.isTransferDebuff(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.TransferDebuff
end

function Conditions.Skill.ExtrtaAffect.isIncMaleBuffSuccessRate(attackData)
    return attackData.skillData.extraAffect == enums.SkillExtraAffect.IncMaleBuffSuccessRate
end

--[[ 技能触发条件
    1-进入战斗触发
    2-攻击时有概率触发
    3-自身血量低于50%时触发
    4-击杀敌人
    5-自身死亡触发

local SkillTriggerConditon = {
    EnterBattle = 1,
    AttackProp = 2,
    HPUnderHalf = 3,
    KillEnemy = 4,
    Dead = 5
}
--]]

Conditions.Skill.TriggerCondition = {}
check_attr_nil(Conditions.Skill.ExtrtaAffect)

function Conditions.Skill.TriggerCondition.isEnterBattle(attackData)
    return attackData.skillData.triggerCondition == enums.SkillTriggerConditon.EnterBattle
end

function Conditions.Skill.TriggerCondition.isAttackProp(attackData)
    return attackData.skillData.triggerCondition == enums.SkillTriggerConditon.AttackProp
end

function Conditions.Skill.TriggerCondition.isHPUnderHalf(attackData)
    return attackData.skillData.triggerCondition == enums.SkillTriggerConditon.HPUnderHalf
end

function Conditions.Skill.TriggerCondition.isKillEnemy(attackData)
    return attackData.skillData.triggerCondition == enums.SkillTriggerConditon.KillEnemy
end

function Conditions.Skill.TriggerCondition.isHeroDie(attackData)
    return attackData.skillData.triggerCondition == enums.SkillTriggerConditon.HeroDie
end

Conditions.Skill.Buff = {}
check_attr_nil(Conditions.Skill.Buff)

function Conditions.Skill.Buff.hasBuff(attackData)
    return #attackData.skillData.buff > 0
end

--[[
local BuffAffectType = {
    DamageOverTime  = 1, --	持续伤害（值为公式ID）
    ContinuesIncHP  = 2, --	持续回血（值为公式ID）
    Vertigo         = 3, --	眩晕
    Charm           = 4, --	魅惑
    AddHit          = 5, --	增加命中
    AddMiss         = 6, --	增加闪避
    AddCri          = 7, --	增加暴击
    AddTen          = 8, --	增加韧性
    AddATK          = 9, --	增加攻击
    AddDEF          = 10, --	增加防御
    AddATKRatio     = 11, --	增加攻击万分比
    AddDEFRatio     = 12, --	增加防御万分比
    AntiInjuryRatio = 13, --	反弹伤害万分比
    KillBackHPRatio = 14, --	击杀敌人回血（按目标的血量上限的万分比）
    AddTreatment    = 15, --	增加治疗效果
    AddTreated      = 16, --	增加被治疗效果
    AddRatioATKByTeammateDie   = 17, --	己方每次阵亡一个单位，增加一定攻击万分比
    AddNormATKRatio             = 18, --	增加普通攻击伤害（万分比）
    DecNormATKRatio     = 19, --	减免普通攻击伤害（万分比）
    AddSkillATKRatio    = 20, --	增加技能攻击伤害（万分比）
    DecSkillATKRatio    = 21, --	减免技能攻击伤害（万分比）
    AddExtraElemDamage  = 22, --	额外五行伤害加成
    DecExtraElemDamage  = 23, --	额外五行伤害减免
    Slow                = 24, --	迟缓（降低Name = 50, --%的攻击速度和移动速度）
    Blinding            = 25, --	致盲（降低Name = 50, --%命中率）
    AddAttckSpeedRatio = 26, --	增加攻击速度万分比
    Hide            = 27, --	隐身（只有五行对其克制的角色才能攻击他）
    MetaShield      = 28, --	金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）
    WoodShield      = 29, --	木属性护盾 能吸收金属性以外的所有伤害
    WaterShield     = 30, --	水属性护盾 能吸收土属性以外的所有伤害
    FireShield      = 31, --	火属性护盾 能吸收水属性以外的所有伤害
    EarthShield     = 32, --	土属性护盾 能吸收木属性以外的所有伤害
    Entangled       = 33, --	缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
    DamageReduction = 34, --	伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）
    Silence         = 35, --	沉默（无法释放技能）
    Poisoning       = 36, --	中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)
    AddMissRatio    = 37, --	增加闪避值万分比
    FixedBody       = 38, --	定身（无法移动，可以攻击使用技能）
    SpellShield     = 39, --	法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）
}
--]]

Conditions.Buff = {}
check_attr_nil(Conditions.Buff)

Conditions.Buff.AffectType = {}
check_attr_nil(Conditions.Buff.AffectType)

function Conditions.Buff.AffectType.isDamageOverTime(buffData)
    return buffData.affect == enums.BuffAffectType.DamageOverTime
end

function Conditions.Buff.AffectType.isContinuesIncHP(buffData)
    return buffData.affect == enums.BuffAffectType.ContinuesIncHP
end

function Conditions.Buff.AffectType.isVertigo(buffData)
    return buffData.affect == enums.BuffAffectType.Vertigo
end

function Conditions.Buff.AffectType.isCharm(buffData)
    return buffData.affect == enums.BuffAffectType.Charm
end

function Conditions.Buff.AffectType.isAddHit(buffData)
    return buffData.affect == enums.BuffAffectType.AddHit
end

function Conditions.Buff.AffectType.isAddMiss(buffData)
    return buffData.affect == enums.BuffAffectType.AddMiss
end

function Conditions.Buff.AffectType.isAddCri(buffData)
    return buffData.affect == enums.BuffAffectType.AddCri
end

function Conditions.Buff.AffectType.isAddTen(buffData)
    return buffData.affect == enums.BuffAffectType.AddTen
end

function Conditions.Buff.AffectType.isAddATK(buffData)
    return buffData.affect == enums.BuffAffectType.AddATK
end

function Conditions.Buff.AffectType.isAddDEF(buffData)
    return buffData.affect == enums.BuffAffectType.AddDEF
end

function Conditions.Buff.AffectType.isAddATKRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AddATKRatio
end

function Conditions.Buff.AffectType.isAddDEFRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AddDEFRatio
end

function Conditions.Buff.AffectType.isAntiInjuryRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AntiInjuryRatio
end

function Conditions.Buff.AffectType.isKillBackHPRatio(buffData)
    return buffData.affect == enums.BuffAffectType.KillBackHPRatio
end

function Conditions.Buff.AffectType.isAddTreatment(buffData)
    return buffData.affect == enums.BuffAffectType.AddTreatment
end

function Conditions.Buff.AffectType.isAddTreated(buffData)
    return buffData.affect == enums.BuffAffectType.AddTreated
end

function Conditions.Buff.AffectType.isAddRatioATKByTeammateDie(buffData)
    return buffData.affect == enums.BuffAffectType.AddRatioATKByTeammateDie
end

function Conditions.Buff.AffectType.isAddNormATKRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AddNormATKRatio
end

function Conditions.Buff.AffectType.isDecNormATKRatio(buffData)
    return buffData.affect == enums.BuffAffectType.DecNormATKRatio
end

function Conditions.Buff.AffectType.isAddSkillATKRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AddSkillATKRatio
end

function Conditions.Buff.AffectType.isDecSkillATKRatio(buffData)
    return buffData.affect == enums.BuffAffectType.DecSkillATKRatio
end

function Conditions.Buff.AffectType.isAddExtraElemDamage(buffData)
    return buffData.affect == enums.BuffAffectType.AddExtraElemDamage
end

function Conditions.Buff.AffectType.isDecExtraElemDamage(buffData)
    return buffData.affect == enums.BuffAffectType.DecExtraElemDamage
end

function Conditions.Buff.AffectType.isSlow(buffData)
    return buffData.affect == enums.BuffAffectType.Slow
end

function Conditions.Buff.AffectType.isBlinding(buffData)
    return buffData.affect == enums.BuffAffectType.Blinding
end

function Conditions.Buff.AffectType.isAddAttckSpeedRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AddAttckSpeedRatio
end

function Conditions.Buff.AffectType.isHide(buffData)
    return buffData.affect == enums.BuffAffectType.Hide
end

function Conditions.Buff.AffectType.isMetalShield(buffData)
    return buffData.affect == enums.BuffAffectType.MetalShield
end

function Conditions.Buff.AffectType.isWoodShield(buffData)
    return buffData.affect == enums.BuffAffectType.WoodShield
end

function Conditions.Buff.AffectType.isWaterShield(buffData)
    return buffData.affect == enums.BuffAffectType.WaterShield
end

function Conditions.Buff.AffectType.isFireShield(buffData)
    return buffData.affect == enums.BuffAffectType.FireShield
end

function Conditions.Buff.AffectType.isEarthShield(buffData)
    return buffData.affect == enums.BuffAffectType.EarthShield
end

function Conditions.Buff.AffectType.isEntangled(buffData)
    return buffData.affect == enums.BuffAffectType.Entangled
end

function Conditions.Buff.AffectType.isDamageReduction(buffData)
    return buffData.affect == enums.BuffAffectType.DamageReduction
end

function Conditions.Buff.AffectType.isSilence(buffData)
    return buffData.affect == enums.BuffAffectType.Silence
end

function Conditions.Buff.AffectType.isPoisoning(buffData)
    return buffData.affect == enums.BuffAffectType.Poisoning
end

function Conditions.Buff.AffectType.isAddMissRatio(buffData)
    return buffData.affect == enums.BuffAffectType.AddMissRatio
end

function Conditions.Buff.AffectType.isFixedBody(buffData)
    return buffData.affect == enums.BuffAffectType.FixedBody
end

function Conditions.Buff.AffectType.isSpellShield(buffData)
    return buffData.affect == enums.BuffAffectType.SpellShield
end


local BattleHelper = {}
BattleHelper.Conditions = Conditions

return BattleHelper
