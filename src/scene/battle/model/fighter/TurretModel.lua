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
local TurretModel = class("TurretModel", FighterModel)

function TurretModel:ctor(turretID, pos, team, battleModel)
    TurretModel.super.ctor(self, "turret")

    self.battleModel = battleModel
    self.turretID = turretID
    self.pos = pos -- 左下为中心点，大小为Range

    self._team = team
    self._teamSide = assert(team:getSide(), "teamSide")        -- 队伍方向(left, right)

    self.turretData = assert(BaseConfig.GetTurret(turretID), string.format("turret:%d", turretID))
    self.view = nil

    local skillData = BaseConfig.GetHeroSkill(self.turretData.Skill, 1)
    self.skillData = skillData
    self.coolTimeLeft = 0

    self._fullHP = self.turretData.Hp
    self._currentHP = self._fullHP
    self:setEventDispatcher(battleModel.eventDispatcher)

    self._matchedEnemy = nil
end

function TurretModel:getTeam()
    return self._team
end

function TurretModel:getEnemyTeam()
    return self.battleModel:getEnemyTeam(self._teamSide)
end

function TurretModel:getTurretID()
    return self.turretID
end

function TurretModel:getHeroID()
    return self:getTurretID()
end

function TurretModel:isFort()
    return self.turretData.Type == enums.Turret.Fort
end

function TurretModel:showHPBar()
    return self.turretData.Type == enums.TurretType.Norm or self.turretData.Type == enums.TurretType.Buff
end

function TurretModel:getDirection()
    return "left"
end

--- begin FighterModel 虚函数 -------
function TurretModel:isAttackableType()
    return self.turretData.Type == enums.TurretType.Norm
end

function TurretModel:isHittableType()
    return true
end

function TurretModel:isMovableType()
    return false
end

function TurretModel:isMissable()
    return false
end

function TurretModel:canMatched()
    return true
end

function TurretModel:getCell()
    return self.pos
end

function TurretModel:getNextCell()
    return self:getCell()
end

function TurretModel:inCellsArea(area)
    local x = self.pos.x
    local y = self.pos.y

    for _, cell in ipairs(area) do
        if cell.x == x and cell.y == y then
            return true
        end
    end

    return false
end

function TurretModel:cellInBitMap(scopeBitmap)
    return scopeBitmap:get(self.pos.x, self.pos.y)
end

function TurretModel:cellPosInRect(rect)
    local cellPos = self:getCellPos()
    return cc.rectContainsPoint(rect, cellPos)
end

function TurretModel:cellPosInBitmap(bitmap)
    local cellPos = self:getCellPos()
    return bitmap:get(cellPos.x, cellPos.y)
end

function TurretModel:getFormulaParams()
    local params = {
        ATK = self.turretData.Atk,
        DEF = self.turretData.Def,
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

function TurretModel:getFightType()
    local attackSkillID = self.turretData.Skill
    if attackSkillID == 1001 then
        return "near"
    else
        return "far"
    end
end

function TurretModel:getRes()
    return self.turretData.Res
end

function TurretModel:getHP()
    return self._currentHP
end

function TurretModel:getFullHP()
    return self._fullHP
end

function TurretModel:getHPPercent()
    local hp = self:getHP()
    local fullHP = self:getFullHP()
    return hp * 100 / fullHP
end

function TurretModel:isAlive()
    return self._currentHP > 0
end

function TurretModel:decHP(hp)
    local hp = math.floor(hp)
    self._currentHP = self._currentHP - hp

    self:dispatchEvent(AppEvent.UI.Battle.HPChange, {hint = true, fighterID = self:getFighterID(), percent = self:getHPPercent(), value = -hp, curHP = self._currentHP})
--    if self.view then
--        self.view:hpChange(-hp, false, false)
--    end

    if self._currentHP <= 0 then
        self:die()
    end
end

function TurretModel:hitBy(damage, attacker)
    if damage > self._currentHP then
        self._killer = attacker
    end

    self:decHP(damage)
end

function TurretModel:update()
    if self:isAttackableType() then
        self.coolTimeLeft = self.coolTimeLeft - BattleConfig.TIME_UNIT
        if self.coolTimeLeft <= 0 then
           self:releaseSkill()
        end
    end
end

function TurretModel:filterEnemyList(enemyModels, minX, maxX)
    assert(#enemyModels > 0)

    local mcell = self:getCell()

    local enemyInXRange = {}
    for idx, enemy in ipairs(enemyModels) do
        local ecell = enemy:getCell()
        local disX = math.abs(ecell.x - mcell.x)
        if disX >= minX and disX < maxX then
            table.insert(enemyInXRange, enemy)
        end
    end

    if #enemyInXRange == 1 then
        return enemyInXRange
    end

    local minDisX = 10000
    for idx, enemy in ipairs(enemyInXRange) do
        local ecell = enemy:getCell()
        local disX = math.abs(ecell.x - mcell.x)
        if disX < minDisX then
            minDisX = disX
        end
    end

    local minDisY = 10000
    for idx, enemy in ipairs(enemyInXRange) do
        local ecell = enemy:getCell()
        local disX = math.abs(ecell.x - mcell.x)
        if minDisX == disX then
            local disY = math.abs(ecell.y - mcell.y)
            if disY < minDisY then
                minDisY = disY
            end
        end
    end

    local enemyList = {}
    for idx, enemy in ipairs(enemyInXRange) do
        local ecell = enemy:getCell()
        local disX = math.abs(ecell.x - mcell.x)
        local disY = math.abs(ecell.y - mcell.y)

        if disX == minDisX and disX >= minX and disX < maxX and disY == minDisY then
            table.insert(enemyList, enemy)
        end
    end
    return enemyList
end


function TurretModel:releaseSkill()
    if self.turretData.Skill == 0 then
        return
    end

    local enemyTeam = self.battleModel.leftTeam
    local enemyModels = enemyTeam:getCanMatchedHeroModels(true)

    if #enemyModels > 0 then
        enemyModels = self:filterEnemyList(enemyModels, 4, 20)
    end

    if #enemyModels > 0 then
        local enemy = enemyModels[1]
        self._matchedEnemy = enemy
        local attackData = AttackDataModel.new(self, self.battleModel, self.turretData.Skill, 1, {enemy:getFighterID()})
        self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())

        self.coolTimeLeft = (self.turretData.CD / 1000.0)
    else
        self.coolTimeLeft = (self.turretData.CD / 1000.0) / 10
    end
end

function TurretModel:die()
    self:dispatchEvent(AppEvent.UI.Battle.FighterDie, {fighterID = self:getFighterID() })

    if self.turretData.Type == enums.TurretType.Buff then
        local attackData = AttackDataModel.new(self, self.battleModel, self.turretData.Skill, 1)
        self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
    end
end

function TurretModel:getEnemies(params)
    params = params or {}

    local teamSide = self._teamSide
    local enemyTeam = self:getEnemyTeam()
    local enemies = enemyTeam:getAliveHeroModels(params.summon)

    if params.trap then
        if params.isRageSkill and teamSide == "left" then
            local trapList = self._battleModel.gameTrap:getAllTrapList()
            for _, trap in ipairs(trapList) do
                table.insert(enemies, trap)
            end
        end
    end

    return enemies
end

function TurretModel:getTeammates(params)
    params = params or {}

    local teamSide = self._teamSide
    local selfTeam = self:getTeam()

    local teammates = selfTeam:getAliveHeroModels(params.summon)

    if params.isRageSkill and teamSide == "right" then
        if params.trap then
            local trapList = self._battleModel.gameTrap:getAllTrapList()
            for _, trap in ipairs(trapList) do
                table.insert(teammates, trap)
            end
        end
    end

    return teammates
end

function TurretModel:onBattleRoundStart()

end

function TurretModel:onBattleRoundEnd()

end

function TurretModel:setMatchedEnemy(enemy)
    -- 不需要
end

function TurretModel:isMatchedEnemy(enemy)
    return false
end

function TurretModel:getMatchedEnemy()
    return self._matchedEnemy
end

function TurretModel:incHitting()

end

function TurretModel:clearMoving()
    
end

return TurretModel