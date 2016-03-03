--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-28
-- Time: 上午11:04
-- 持续施法
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local AttackSubDataModel = require("scene.battle.model.attack.AttackSubDataModel")
-------------------------------------------------------------------------------
local ContinuousSkillModel = class("local ContinuousSkillModel")

function ContinuousSkillModel:ctor(attackData, battleModel)
    self.battleModel = battleModel
    self.attackData = attackData
    self.timeLeft = attackData.skillData.durationTime
    self.intervalLeft = 0
    self.completed = false
end

function ContinuousSkillModel:update(battleModel)
    if self.completed then
        return
    end
    
    self.timeLeft = self.timeLeft - BattleConfig.TIME_UNIT
    self.intervalLeft = self.intervalLeft - BattleConfig.TIME_UNIT

    if self.intervalLeft <= 0 then
        self.intervalLeft = self.attackData.skillData.interval
        self:doUpdateInterval(battleModel)
    end

    if self.timeLeft <= 0 then
        self.completed = true
    end
end

function ContinuousSkillModel:breakOff()
    self.completed = true
end

function ContinuousSkillModel:doUpdateInterval(battleModel)
    CCLog("处理持续伤害技能 间隔 攻击")
    --[[ SkillAffectType 技能效果类型
        None = 0,
        Damage = 1,          1-伤害
        Treatment = 2,       2-治疗
        Resurrection = 3,    3--复活（公式为复活后的血量）
        Summoner = 4,        4--召唤
        CopyKiller = 5       5--复制凶手
--]]
    local handlers = {
        --[enums.SkillAffectType.None        ] = nil,
        [enums.SkillAffectType.Damage      ] = self.handleIntervalDamage,
        [enums.SkillAffectType.Treatment   ] = self.handleIntervalTreatment,
        --[enums.SkillAffectType.Resurrection] = nil,
        --[enums.SkillAffectType.Summoner    ] = nil,
        --[enums.SkillAffectType.Replication ] = nil,
    }

    local attackData = self.attackData
    local handler = handlers[attackData.skillData.affect]

    if handler then
        handler(self, attackData, battleModel)
    else
        CCLog("没有处理技能技能效果类型: " .. attackData.skillData.affect)
    end
end

function ContinuousSkillModel:handleIntervalDamage(attackData, battleModel)
    if attackData.skillData.id == 1331 then
        -- 宝塔镇妖，敌人死后中止
        local targetHeroList = attackData:getTargetFighterList()

        local deadCount = 0
        for _, targetHeroModel in ipairs(targetHeroList) do
            local subAttackModel = AttackSubDataModel.new(attackData, targetHeroModel)
            self.battleModel:handleInstantSkillSubAttack(subAttackModel)
            if not targetHeroModel:isAlive() then
                deadCount = deadCount + 1
            end
        end

        if deadCount == #targetHeroList then
            CCLog("持续施法目标死绝，中止")
            self.completed = true
        end
    else
        local targetHeroList = attackData:calcHeroTargetFighterList()
        for _, targetHeroModel in ipairs(targetHeroList) do
            local subAttackModel = AttackSubDataModel.new(attackData, targetHeroModel)
            self.battleModel:handleInstantSkillSubAttack(subAttackModel)
        end
    end
end

function ContinuousSkillModel:handleIntervalTreatment(attackData, battleModel)
    CCLog("持续技能治疗")
    local targetHeroList = attackData:getTargetFighterList()

    for _, targetHeroModel in ipairs(targetHeroList) do
        local hp = battleModel:calcSkillAffectValue(attackData, targetHeroModel)
        targetHeroModel:treat(attackData, hp)
    end
end

function ContinuousSkillModel:isFinish()
    return self.completed
end

return ContinuousSkillModel

