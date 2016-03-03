--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/18
-- Time: 下午3:15
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/26
-- Time: 下午4:13
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-31
-- Time: 上午10:30
-- 陷井
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterModel = require("scene.battle.model.fighter.FighterModel")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
-------------------------------------------------------------------------------
local HatredTargetModel = class("HatredTargetModel", FighterModel)

function HatredTargetModel:ctor(HP, DEF, cell, skillData, team)
    HatredTargetModel.super.ctor(self, "hatredTarget")

    self._cell = cell
    self._skillData = skillData

    self._team = team
    self._teamSide = assert(team:getSide(), "teamSide")        -- 队伍方向(left, right)

    self._fullHP = HP
    self._currentHP = self._fullHP
    self._def = DEF
    self._direction = "right"
end

function HatredTargetModel:getRes()
    return "TODO:"
end

function HatredTargetModel:getTeam()
    return self._team
end

function HatredTargetModel:getTeamSide()
    return self._team:getSide()
end

function HatredTargetModel:getEnemyTeam()
    return self.battleModel:getEnemyTeam(self._teamSide)
end

function HatredTargetModel:getHeroID()
    return 0
end

function HatredTargetModel:showHPBar()
    return true
end

function HatredTargetModel:setDirection(direction)
    self._direction = direction
end

function HatredTargetModel:getDirection()
    return self._direction
end

--- begin FighterModel 虚函数 -------
function HatredTargetModel:isAttackableType()
    return false
end

function HatredTargetModel:isHittableType()
    return true
end

function HatredTargetModel:isMovableType()
    return false
end

function HatredTargetModel:isMissable()
    return false
end

function HatredTargetModel:canMatched()
    return true
end

function HatredTargetModel:getCell()
    return self._cell
end

function HatredTargetModel:getNextCell()
    return nil
end

function HatredTargetModel:inCellsArea(area)
    local x = self._cell.x
    local y = self._cell.y

    for _, cell in ipairs(area) do
        if cell.x == x and cell.y == y then
            return true
        end
    end

    return false
end

function HatredTargetModel:cellInBitMap(scopeBitmap)
    return scopeBitmap:get(self._cell.x, self._cell.y)
end

function HatredTargetModel:cellPosInRect(rect)
    local cellPos = self:getCellPos()
    return cc.rectContainsPoint(rect, cellPos)
end

function HatredTargetModel:cellPosInBitmap(bitmap)
    local cellPos = self:getCellPos()
    return bitmap:get(cellPos.x, cellPos.y)
end

function HatredTargetModel:getFormulaParams()
    local params = {
        ATK = 0,
        DEF = self._def,
        MP = 0,
        HP = self._currentHP,
        FH = self._fullHP,
        heroLV = 1,
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

function HatredTargetModel:getFightType()
    return "near"
end

function HatredTargetModel:getRes()
    return "" -- TODO:
end

function HatredTargetModel:getHP()
    return self._currentHP
end

function HatredTargetModel:getFullHP()
    return self._fullHP
end

function HatredTargetModel:getHPPercent()
    local hp = self:getHP()
    local fullHP = self:getFullHP()
    return hp * 100 / fullHP
end

function HatredTargetModel:isAlive()
    return self._currentHP > 0
end

function HatredTargetModel:decHP(hp)
    local hp = math.floor(hp)
    self._currentHP = self._currentHP - hp

    self:dispatchEvent(AppEvent.UI.Battle.HPChange, {hint = true, fighterID = self:getFighterID(), percent = self:getHPPercent(), value = -hp, curHP = self._currentHP})
    if self._currentHP <= 0 then
        self:die()

        -- 死亡触发技能
        local dieTriggerSkillData = BaseConfig.GetHeroSkill(5010, self._skillData.level)
        if dieTriggerSkillData then
            self:triggeredSkill(dieTriggerSkillData)
        end
    end
end

function HatredTargetModel:hitBy(damage, attacker)
    if damage > self._currentHP then
        self._killer = attacker
    end

    self:decHP(damage)
end

function HatredTargetModel:update()

end

function HatredTargetModel:die()
    self._currentHP = 0

    self:dispatchEvent(AppEvent.UI.Battle.FighterDie, {fighterID = self:getFighterID() })
end

function HatredTargetModel:triggeredSkill(skillData)
    local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, nil)
    self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
end

function HatredTargetModel:getEnemies(params)
    params = params or {}

    local teamSide = self._teamSide
    local enemyTeam = self:getEnemyTeam()
    local enemies = enemyTeam:getAliveHeroModels(params.summon)

    return enemies
end

function HatredTargetModel:getTeammates(params)
    params = params or {}

    local teamSide = self._teamSide
    local selfTeam = self:getTeam()

    local teammates = selfTeam:getAliveHeroModels(params.summon)

    return teammates
end

function HatredTargetModel:onBattleRoundStart()

end

function HatredTargetModel:onBattleRoundEnd()
    if self:isAlive() then
        self:die()
    end
end

function HatredTargetModel:incHitting()

end

function HatredTargetModel:clearMoving()

end

return HatredTargetModel