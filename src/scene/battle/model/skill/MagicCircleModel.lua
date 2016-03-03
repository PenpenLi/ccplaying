--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-27
-- Time: 下午6:10
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-23
-- Time: 下午6:15
-- 魔法阵
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local AttackSubDataModel = require("scene.battle.model.attack.AttackSubDataModel")
local IDGenerator = require("scene.battle.IDGenerator")
-------------------------------------------------------------------------------

local MagicCircleModel = class("MagicCircleModel")

function MagicCircleModel:ctor(attackData)
    self.serialID = IDGenerator.genID()
    self.battleModel = attackData.battleModel

    self.attackData = attackData
    self.timeLeft = attackData.skillData.durationTime
    self.intervalLeft = attackData.skillData.interval
end

function MagicCircleModel:getSerialID()
    return self.serialID
end

function MagicCircleModel:getSkillID()
    return self.attackData.skillData.id
end

function MagicCircleModel:getAttacker()
    return self.attackData.attacker
end

function MagicCircleModel:update(battleModel)
    CCLog("MagicCircleModel:update()", self.timeLeft)
    if self.timeLeft <= 0 then
        return
    end

    self.timeLeft = self.timeLeft - BattleConfig.TIME_UNIT
    self.intervalLeft = self.intervalLeft - BattleConfig.TIME_UNIT

    if self.intervalLeft <= 0 then
        self.intervalLeft = self.attackData.skillData.interval
        self:doUpdateInterval(battleModel)
    end
end

function MagicCircleModel:encode()
    assert(false, "not implement")
end

function MagicCircleModel.decode(jsonStr, battleModel)
    assert(false, "not implement")
end

function MagicCircleModel:doUpdateInterval(battleModel)
    local targetHeroList = self:getTargetFighterList()

    --[[ SkillAffectType 技能效果类型
            None = 0,
            Damage = 1,          1-伤害
            Treatment = 2,       2-治疗
            Resurrection = 3,    3--复活（公式为复活后的血量）
            Summoner = 4,        4--召唤
            CopyKiller = 5       5--复制凶手
    --]]
    local handlers = {
        [enums.SkillAffectType.None        ] = self.handleMagicCircleBuff,
        [enums.SkillAffectType.Damage      ] = self.handleMagicCircleDamage,
        [enums.SkillAffectType.Treatment   ] = self.handleMagicCircleTreatment,
        [enums.SkillAffectType.Resurrection] = nil,
        [enums.SkillAffectType.Summoner    ] = nil,
        [enums.SkillAffectType.CopyKiller  ] = nil,
        [enums.SkillAffectType.Prison      ] = nil,
    }

    local attackData = self.attackData
    local handler = handlers[attackData.skillData.affect]

    battleModel:dispatchEvent(AppEvent.UI.Battle.AttackInterval, {skillID = attackData.skillData.id})
    if handler then
         handler(self, attackData, battleModel)
    else
        CCLog("没有处理技能技能效果类型: " .. attackData.skillData.affect)
    end
end

function MagicCircleModel:handleMagicCircleBuff(attackData, battleModel)
    CCLog("魔法阵 BUFF")
    local targetHeroList = self:getTargetFighterList()

    CCLog("魔法阵 目标数量", #targetHeroList)
    for _, targetHeroModel in ipairs(targetHeroList) do
        local skillData = attackData.skillData
        local probability = skillData.buffProbability

        local randNum = self.battleModel:random(1, 10000)
        CCLog(string.format("random:%d, probability:%d", randNum, probability))
        if randNum <= probability then
            local attacker = attackData.attacker
            for _, buffID in ipairs(skillData.buff) do
                targetHeroModel:addBuff(buffID, attacker, skillData.id, skillData.level)
            end
        end
    end
end

function MagicCircleModel:handleMagicCircleDamage(attackData, battleModel)
    CCLog("魔法阵 伤害")
    local targetHeroList = self:getTargetFighterList()

    CCLog("魔法阵 目标数量", #targetHeroList)
    for _, targetHeroModel in ipairs(targetHeroList) do
        --self:doHit(targetHeroModel, attackData, battleModel)
        local subAttackModel = AttackSubDataModel.new(attackData, targetHeroModel)
        battleModel:doHit(subAttackModel)
    end
end

function MagicCircleModel:handleMagicCircleTreatment(attackData, battleModel)
    CCLog("魔法阵 治疗")
    local targetHeroList = self:getTargetFighterList()
    CCLog("魔法阵 目标数量", #targetHeroList)

    for _, targetHeroModel in ipairs(targetHeroList) do
        local hp = battleModel:calcSkillAffectValue(attackData, targetHeroModel)
        targetHeroModel:treat(attackData, hp)
    end
end

function MagicCircleModel:getTargetFighterList()
    assert(false, "virtual function")
end

function MagicCircleModel:isFinish()
    return self.timeLeft <= 0
end

return MagicCircleModel
