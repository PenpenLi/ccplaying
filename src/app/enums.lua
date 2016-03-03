--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-15
-- Time: 下午4:05
-- To change this template use File | Settings | File Templates.
--

local enums = {}

-- 五行类型 金木水火土
local ElemType = {
    Metal = 1,
    Wood  = 2,
    Water = 3,
    Fire  = 4,
    Earth = 5,
}

--[[ 技能类型
1--普通攻击
2--普通技能（概率触发）
3--怒气技能
4--天赋技能
5--场景技能
6--陷阱技能
7--仙女技能
8--障碍技能

1 + 100 普攻暴击
--]]
local SkillType = {
    NormAttack = 1,
    NormSkill = 2,
    RageSkill = 3,
    InnateSkill = 4,
    InstanceSkill = 5,
    TrapSkill = 6,
    FairySkill = 7,
    ObstacleSkill = 8,

    NormAttack_Crit = 1 + 100,
}

--[[ 技能释放类型：
0表示点击技能就触发技能（不用选择目标）
1表示点击技能后还要选择技能目标
2表示点击技能后还要手动点击目标英雄按钮
--]]
local SkillReleaseMode = {
    Auto = 0,
    Region = 1,
    HeroChoice = 2,
}

--[[ 技能持续时间类型
1.瞬间生效
2.放在地上的阵法技能（持续作用于一定范围）
3.以自身为中心的可移动阵法技能
4.持续施法（自身不动，可被打断）
--]]
local SkillDurationMode = {
    Instant = 1,
    FixedMagicCircle = 2,
    FollowMagicCircle = 3,
    Continuous = 4
}

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
14-N个随机队友
15-N个随机敌人
16-N个最虚弱的队友
17-N个最虚弱的敌人
18-攻击自己的敌人
19-最远的敌人
--]]
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
    NRandomTeamates = 14,
    NRandomEnemies = 15,
    NWeakestTeamates = 16,
    NWeakestEnemies = 17,
    Attacker = 18,
    FarEnemy = 19,
}

--[[ 技能效果类型
1-伤害
2-治疗
3--复活（公式为复活后的血量）
4--召唤
5--复制杀死自己的敌人
6--控制敌人在技能范围内
7--仇恨目标（拉仇恨，吸伤害的东西）
8-移动到目标位置一段时间(时间为公式)
--]]
local SkillAffectType = {
    None = 0,
    Damage = 1,
    Treatment = 2,
    Resurrection = 3,
    Summoner = 4,
    CopyKiller = 5,
    Prison = 6,
    HatredTarget = 7,
    TeleportForMoment = 8,
}

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
16--提高情绪一个等级
17--有机率调用另一个技能公式
18--蛋复活(只有怒气技能才能攻击)
19--把敌方单元向中间吸
20-分身 （分出1个单位  分身持续30s）
21-对女性星将释放buff
22-对召唤单位和幻象附加额外的伤害
23-给自己加BUFF
--]]
local SkillExtraAffect = {
    Knockback              = 1,
    Seckilling             = 2,
    AddDamage_1            = 3,
    DecEnemyRage           = 4,
    IncSelfRage            = 5,
    IncSelfHP              = 6,
    ComboHit               = 7,
    Bomber                 = 8,
    ClearDebuff            = 9,
    AddDamage_2            = 10,
    Replication            = 11,
    ExtraDamageForMale     = 12,
    ExtraDamageForFemale   = 13,
    TransferDebuff         = 14,
    IncMaleBuffSuccessRate = 15,
    IncMoodLevel           = 16,
    ProbabilityFormula     = 17,
    TurnIntoEgg            = 18,
    Suction                = 19,
    Replication_1          = 20,
    BuffForFemale          = 21,
    ExtraDamageForSummon   = 22,
    BuffForSelf            = 23,
    KillSelf               = 24,
}

--[[ 技能触发条件
1-进入战斗触发
2-攻击时有概率触发
3-自身血量低于50%时触发
4-击杀敌人
5-自身死亡触发
6-自身死亡和被怒气技能攻击时触发
--]]
local SkillTriggerCondition = {
    EnterBattle = 1,
    AttackProp  = 2,
    HPUnderHalf = 3,
    KillEnemy   = 4,
    HeroDie     = 5,
    HeroDieOrHitByRage = 6,
}

--[[
buff作用枚举
1   持续伤害（值为公式ID）
2   持续回血（值为公式ID）
3   眩晕
4   魅惑
5   增加命中
6   增加闪避
7   增加暴击
8   增加韧性
9   增加攻击
10  增加防御
11  增加攻击万分比
12  增加防御万分比
13  反弹伤害万分比
14  击杀敌人回血（按目标的血量上限的万分比）
15  增加治疗效果
16  增加被治疗效果
17  己方每次阵亡一个单位，增加一定攻击万分比
18  增加普通攻击伤害（万分比）
19  减免普通攻击伤害（万分比）
20  增加技能攻击伤害（万分比）
21  减免技能攻击伤害（万分比）
22  额外五行伤害加成
23  额外五行伤害减免
24  迟缓（降低50%的攻击速度和移动速度）
25  致盲（降低50%命中率）
26  增加攻击速度万分比
27  隐身（只有五行对其克制的角色才能攻击他）
28  金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）
29  木属性护盾 能吸收金属性以外的所有伤害
30  水属性护盾 能吸收土属性以外的所有伤害
31  火属性护盾 能吸收水属性以外的所有伤害
32  土属性护盾 能吸收木属性以外的所有伤害
33  缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
34  伤害减免（降低20%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）
35  沉默（无法释放技能）
36  中毒(持续掉血,值为公式;降低30%移动速度,攻击速度)
37  增加闪避值万分比
38  定身（无法移动，可以攻击使用技能）
39  法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）
40  昏睡（无法移动，无法攻击，受到攻击自动解除）
41  反弹技能伤害
--]]

local BuffAffectType = {
    DamageOverTime              = 1,  --    持续伤害（值为公式ID）
    ContinuesIncHP              = 2,  --    持续回血（值为公式ID）
    Vertigo                     = 3,  --    眩晕
    Charm                       = 4,  --    魅惑
    AddHit                      = 5,  --    增加命中
    AddMiss                     = 6,  --    增加闪避
    AddCri                      = 7,  --    增加暴击
    AddTen                      = 8,  --    增加韧性
    AddATK                      = 9,  --    增加攻击
    AddDEF                      = 10, --    增加防御
    AddATKRatio                 = 11, --    增加攻击万分比
    AddDEFRatio                 = 12, --    增加防御万分比
    AntiInjuryRatio             = 13, --    反弹伤害万分比
    KillBackHPRatio             = 14, --    击杀敌人回血（按目标的血量上限的万分比）
    AddTreatment                = 15, --    增加治疗效果
    AddTreated                  = 16, --    增加被治疗效果
    AddRatioATKByTeammateDie    = 17, --    己方每次阵亡一个单位，增加一定攻击万分比
    AddNormATKRatio             = 18, --    增加普通攻击伤害（万分比）
    DecNormATKRatio             = 19, --    减免普通攻击伤害（万分比）
    AddSkillATKRatio            = 20, --    增加技能攻击伤害（万分比）
    DecSkillATKRatio            = 21, --    减免技能攻击伤害（万分比）
    AddExtraElemDamage          = 22, --    额外五行伤害加成
    DecExtraElemDamage          = 23, --    额外五行伤害减免
    Slow                        = 24, --    迟缓（降低Name = 50, --%的攻击速度和移动速度）
    Blinding                    = 25, --    致盲（降低Name = 50, --%命中率）
    AddAttckSpeedRatio          = 26, --    增加攻击速度万分比
    Hide                        = 27, --    隐身（只有五行对其克制的角色才能攻击他）
    MetalShield                 = 28, --   金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）
    WoodShield                  = 29, --    木属性护盾 能吸收金属性以外的所有伤害
    WaterShield                 = 30, --    水属性护盾 能吸收土属性以外的所有伤害
    FireShield                  = 31, --    火属性护盾 能吸收水属性以外的所有伤害
    EarthShield                 = 32, --    土属性护盾 能吸收木属性以外的所有伤害
    Entangled                   = 33, --    缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
    DamageReduction             = 34, --    伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）
    Silence                     = 35, --    沉默（无法释放技能）
    Poisoning                   = 36, --    中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)
    AddMissRatio                = 37, --    增加闪避值万分比
    FixedBody                   = 38, --    定身（无法移动，可以攻击使用技能）
    SpellShield                 = 39, --    法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）
    Sleep                       = 40, --    昏睡（无法移动，无法攻击，受到攻击自动解除）
    SkillAntiInjuryRatio        = 41, --    反弹技能伤害
    Shackle                     = 42, --    禁锢
    Frozen                      = 43, --    冰冻
    DisableHPUP                 = 44, --    禁止回血
    HPCellingUP                 = 45, --    按比率提升总血量

}

-- 英雄动作
local HeroAction = {
    Move   = 1,
    Attack = 2,
    Skill  = 3,
}

-- 战斗
local BattleAIType = {
    Dialogue       = 1, -- 说话
    MonsterSkill   = 2, -- 怪物使用技能
    SummonMonster  = 3, -- 出现新的怪物（敌方）
    SummonNPC      = 4, -- 出现新的NPC（友方）
    InstanceSkill  = 5, -- 关卡技能
    MonsterAI      = 6, -- 怪物相关AI 如双生怪
    RandomDialogue = 7, -- 随机说话
    Resurrection   = 8, -- 指定怪物复活自己(6秒后)
    Transfiguration    = 9, -- 变身
}

-- AI触发条件
local AITriggerCondition = {
    None               = 0, -- 不需要条件(前置AI)
    EnterBattle        = 1, -- 进入战斗后触发
    MonsterHPUnderHalf = 2, -- 指定怪物血量降低于%50触发
    MonsterDie         = 3, -- 指定怪物死亡触发
    Obstacle           = 4, -- 障碍破碎前
    WithObstacle       = 5, -- 进入战斗后触发，障碍破碎后消失
    HitByRage          = 6, -- 指定怪物被怒气技能攻击时触发          
    TurrentDamage      = 7, -- 建筑毁坏触发          
    TurnIntoEgg        = 8, -- 变成蛋的时候    
}

-- 英雄和怪物的移动方式
local HeroMoveMode = {
    Walk   = 1,    -- 走
    Cloud  = 2,    -- 云
    Lotus  = 3,    -- 莲台
    Wings  = 4,    -- 翅膀
    Wheels = 5,    -- 风火轮
    Flight = 6,    -- 飞行(身体太轻了，被风吹的)
}

-- 障碍类型
local ObstacleType = {
    RoadBlock  = 1, -- 可攻击的
    Precipice  = 2,  -- 悬崖
}

-- 陷阱类型
local TrapType = {
    Interval = 1, -- 时间间隔攻击
    Enter    = 2, -- 单次触发后消失
}

local HeroMood = {
    Depressed        = 1,    -- 沮丧
    Normal           = 2,    -- 普通
    Excited          = 3,    -- 兴奋
    ExtremelyExcited = 4,    -- 亢奋
}

-- 炮台类型
local TurretType = {
    Norm = 1,  -- 普通的(就像一个不能移动的怪物)
    Fort = 2,  -- 可以站人的(上面的人不会受到伤害)
    Buff = 3,  -- BUFF建筑（打爆后给XXX加BUFF）
}

-- 技能作用区域的形状
local SkillAreaShape = {
    Circle  = 1,  -- 圆形（椭圆）
    Rect    = 2,  -- 矩形
    Fan60   = 3,  -- 扇形（60度）
    Fan90   = 4,  -- 扇形（90度）
    Cross   = 5,  -- 十字形
    Diamond = 6,  -- 菱形
}

-- 战斗系统
local BattleSystem = {
    Instance     = 1, -- 推图
    Activity     = 2, -- 活动副本
    Arena        = 3, -- 竞技场
    Transport    = 4, -- 运镖
    Loot         = 5, -- 夺宝
    Home         = 6, -- 家园
}

local BattleConsumeType = {
    Power     = 1, -- 体力
    Endurance = 2, -- 耐力
}

local Gender = {
    Male   = 1,     -- 男
    Female = 2,     -- 女
}

-- 防止写错枚举名，引用到nil
local function Enum(enumTable)
    local metaTable = {}
    local emptyTable = {}

    metaTable.__index = function(self, name)
        local val = enumTable[name]
        return assert(val, string.format("enum name %s not exists", name))
    end

    metaTable.__newindex = function(self, name, value) assert(false, "enum can't set") end

    setmetatable(emptyTable, metaTable)

    return enumTable
end

enums.ElemType = Enum(ElemType)
enums.SkillType = Enum(SkillType)
enums.SkillMode = Enum(SkillReleaseMode)
enums.SkillDurationMode = Enum(SkillDurationMode)
enums.SkillAffectTarget = Enum(SkillAffectTarget)
enums.SkillAffectType = Enum(SkillAffectType)
enums.SkillExtraAffect = Enum(SkillExtraAffect)
enums.SkillTriggerCondition = Enum(SkillTriggerCondition)
enums.BuffAffectType = Enum(BuffAffectType)
enums.HeroAction = Enum(HeroAction)
enums.BattleAIType = Enum(BattleAIType)
enums.HeroMoveMode = Enum(HeroMoveMode)
enums.AITriggerCondition = Enum(AITriggerCondition)
enums.ObstacleType = Enum(ObstacleType)
enums.TrapType = Enum(TrapType)
enums.HeroMood = Enum(HeroMood)
enums.TurretType = Enum(TurretType)
enums.SkillAreaShape = Enum(SkillAreaShape)
enums.BattleSystem = Enum(BattleSystem)
enums.BattleConsumeType = Enum(BattleConsumeType)
enums.Gender = Enum(Gender)
enums = Enum(enums)

return enums