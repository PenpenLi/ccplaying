--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-31
-- Time: 上午10:20
-- To change this template use File | Settings | File Templates.
--
local FighterModel = require("scene.battle.model.fighter.FighterModel")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
-------------------------------------------------------------------------------
local BattleObstacleModel = class("BattleObstacleModel", FighterModel)

function BattleObstacleModel:ctor(obstacleID, pos, obstacleList)
    BattleObstacleModel.super.ctor(self, "obstacle")

    self.owner = obstacleList
    self.pos = pos
    self.obstacleID = obstacleID
    local obstacleData = assert(BaseConfig.GetObstacle(obstacleID))
    self.obstacleData = obstacleData
    self.currentHP = self.obstacleData.Hp
    self.view = nil

    if obstacleData.Skill and obstacleData.Skill ~= 0 then
        local SkillModel = require("scene.battle.model.skill.SkillModel")

        self.skillModel = SkillModel.new(self, BaseConfig.GetHeroSkill(obstacleData.Skill, 1))
    end

    if obstacleData.DeadSkill and obstacleData.DeadSkill ~= 0 then
        local SkillModel = require("scene.battle.model.skill.SkillModel")

        self.deadSkillModel = SkillModel.new(self, BaseConfig.GetHeroSkill(obstacleData.DeadSkill, 1))
    end

    if obstacleData.BuffID and obstacleData.BuffID ~= 0 then
        local BuffModel   = require("scene.battle.model.skill.BuffModel")
        local BuffManager = require("scene.battle.model.skill.BuffManager")

        local buffModel = BuffModel.new(self, obstacleData.BuffID, 1, nil)
        self.buffMgr = BuffManager.new(self)
        self.buffMgr:addBuff(buffModel)
    end
end

function BattleObstacleModel:getObstacleType()
    return self.obstacleData.Type
end

function BattleObstacleModel:getAtkSpeed()
    return self.obstacleData.AtkSpeed
end

--- begin FighterModel 虚函数 -------
function BattleObstacleModel:isAttackableType()
    return true
end

function BattleObstacleModel:isHittableType()
    return self.obstacleData.Type == enums.ObstacleType.RoadBlock
end

-- 可以被攻击
function BattleObstacleModel:isHittable()
    return self.obstacleData.Type == enums.ObstacleType.RoadBlock
end

function BattleObstacleModel:isMovableType()
    return false
end

function BattleObstacleModel:isMissable()
    return false
end

function BattleObstacleModel:getFormulaParams()
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
    local WX = self.obstacleData.WX

    local params = {
        ATK = self.obstacleData.Atk,
        DEF = self.obstacleData.Def,
        MP = 0,
        HP = self:getHP(),
        FH = self:getFullHP(),
        heroLV = 0,
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

function BattleObstacleModel:useSpellShield(attackElemType)
    local buffMgr = self.buffMgr

    if buffMgr then
        local shieldType = enums.BuffAffectType.SpellShield
        if buffMgr:hasAffect(shieldType) then
            local spellLeftTimes = buffMgr:getAffectValueLeft(shieldType)
            if spellLeftTimes > 0 then
                buffMgr:decAffectValueLeft(shieldType)
                return true, spellLeftTimes
            end
        end
    end

    return false, 0
end
--- end FighterModel 虚函数 -------

function BattleObstacleModel:update(battleModel)
    if self.skillModel then
        if self.skillModel:inCooling() then
            self.skillModel:update()
        else
            self:releaseSkill()
        end
    end
end

function BattleObstacleModel:releaseSkill()
    self.skillModel:onRelease()

    local battleModel = self.owner.battleModel
    local obstacleData = self.obstacleData
    local attackData = AttackDataModel.new(self, battleModel, obstacleData.Skill, 1)

    battleModel:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
end

function BattleObstacleModel:releaseDeadSkill()
    if not self.deadSkillModel then
        return 
    end

    self.deadSkillModel:onRelease()

    local battleModel = self.owner.battleModel
    local obstacleData = self.obstacleData
    local originTargetFighterIDList = {}
    local targetList = battleModel.leftTeam:getAliveHeroModels(true, true)
    for _, target in ipairs(targetList) do
        table.insert(originTargetFighterIDList, target:getFighterID())
    end

    local attackData = AttackDataModel.new(self, battleModel, obstacleData.DeadSkill, 1, originTargetFighterIDList)

    CCLog("obstacle dead skill")
    battleModel:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
end

function BattleObstacleModel:getCell()
    return {x = self.pos.x, y = self.pos.y}
end

function BattleObstacleModel:inCellsArea(area)
    local x = self.pos.x
    for _, cell in ipairs(area) do
        if cell.x == x then
            return true
        end
    end

    return false
end

function BattleObstacleModel:getHPPercent()
    local hp = self:getHP()
    local fullHP = self:getFullHP()
    return hp * 100 / fullHP
end

function BattleObstacleModel:hit(damage)
    self.currentHP = self.currentHP - damage
    if self.currentHP <= 0 then
        self.currentHP = 0
        self.owner:remove(self)
    end

    self.owner.battleModel:dispatchEvent(AppEvent.UI.Battle.HPChange, {
        fighterID = self:getFighterID(), 
        percent = self:getHPPercent(), 
        value = damage, 
        curHP = self.currentHP,
        hint = false
    })
end

function BattleObstacleModel:getFullHP()
    return self.obstacleData.Hp
end

function BattleObstacleModel:getHP()
    return self.currentHP
end

function BattleObstacleModel:decHP(hp)
    self:hit(hp)
end

function BattleObstacleModel:isAlive()
    return self.currentHP > 0
end

function BattleObstacleModel:isDead()
    return self.currentHP == 0
end

function BattleObstacleModel:setView(view)
    self.view = view
end

function BattleObstacleModel:getView()
    return self.view
end

function BattleObstacleModel:dispatchRemovedEvent()
    self:releaseDeadSkill()

    self.owner.battleModel:dispatchEvent(AppEvent.UI.Battle.ObstacleRemoved,
    {
        fighterID = self:getFighterID(),
        res = self.obstacleData.Res,
    })
end

function BattleObstacleModel:dispatchAddedEvent()
    self.owner.battleModel:dispatchEvent(AppEvent.UI.Battle.ObstacleAdded,
        {
            fighterID = self:getFighterID(),
            ID  = self.obstacleID,
            pos = self.pos,
            res = self.obstacleData.Res,
            type = self.obstacleData.Type,
        })
end

function BattleObstacleModel:onBuffAdded(buff)

end

function BattleObstacleModel:onBuffRemoved(buff)

end

function BattleObstacleModel:onBuffReplaced(oldBuff, newBuff)

end

function BattleObstacleModel:getAntiInjuryRatio()
    local ratio = 0
    if self.buffMgr then
        ratio = self.buffMgr:getCachedAffectValue(enums.BuffAffectType.AntiInjuryRatio)
    end

    return ratio
end

function BattleObstacleModel:getElemType()
    return self.obstacleData.WX
end

return BattleObstacleModel