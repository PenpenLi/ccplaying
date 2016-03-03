local ElemType = require("config.ElemType")
local BattleHelper = require("scene.battle.helper.BattleHelper")
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local BattleTeamModel = class("BattleTeamModel")

local MAX_RAGE_VAL = 100
local ELEM_BUF_TICK = math.floor(60 / BattleConfig.TIME_UNIT)
-- 创一个队伍
-- @param side = "left", "right"
function BattleTeamModel:ctor(side, eventDispatcher, battleModel)
    assert(side == "left" or side == "right")
    self.battleModel = battleModel

    self._side = side   -- 战队方向(左，右)
    self._heroModelList = {} -- 英雄列表
    self._summoning = {}
    self._rage = 0     -- 怒气
    self._elemBuff = {elemType = nil, times = 1, leftTick = 0, comboTimes = 1} -- 五行BUFF
    self._resurrectionData = nil -- 复活技能
    self._eventDispatcher = eventDispatcher

    -- 英雄阵容原始单元格
    self._heroRawCellMap = {}

    self._heroRageReleaseQueue = {}

    self._herosHPRemain = nil

    -- 阵容加成
    self._formAddition = nil

    -- 阵容入场加成
    self._formExtraHPAdditionRatio = nil

    self._fairyModel = nil

    self._longRunning = false -- 正在进行耗时操作

    self._turretProtectMap = nil  -- { hero -> turret }

    self._regionRageData = nil -- 正在选择怒气技能的范围的英雄

    self._rageIncTimeLeft = BattleConfig.RAGE_INC_INTERVAL
end

function BattleTeamModel:getSide()
    return self._side
end

function BattleTeamModel:setFormAddition(formAddition)
    self._formAddition = formAddition
end

function BattleTeamModel:setExtraHPAddition(percent)
    self._formExtraHPAdditionRatio = percent
end

function BattleTeamModel:setFairyModel(fairyModel)
    self._fairyModel = fairyModel
end

function BattleTeamModel:getFairyModel()
    return self._fairyModel
end

-- 初始化英雄怒气技能释放信息表
function BattleTeamModel:initHeroRageReleaseQueue()
    local queue = {}
    for _, heroModel in ipairs(self._heroModelList) do
        queue[heroModel] = {count = 0}
    end

    self._heroRageReleaseQueue = queue
end

-- 释放怒气技能次数最少的英雄列表
function BattleTeamModel:minRageReleaseCount()
    local minimum = nil
    for heroModel, releaseInfo in pairs(self._heroRageReleaseQueue) do
        if minimum == nil or (heroModel:isAlive() and releaseInfo.count < minimum) then
           minimum = releaseInfo.count
        end
    end

    if minimum == nil then
        minimum = 0
    end

    return minimum
end

function BattleTeamModel:heroRageReleaseCount(heroModel)
    --local releaseInfo = assert(self._heroRageReleaseQueue[heroModel], heroModel:getName() .. " not in hero release queue")
    local releaseInfo = self._heroRageReleaseQueue[heroModel]

    if releaseInfo then
        return releaseInfo.count
    else
        return 0
    end
end

function BattleTeamModel:isClimbTower()
    return self._herosHPRemain ~= nil
end

function BattleTeamModel:setTowerHerosHPRemain(heroHPRemain)
    self._herosHPRemain = heroHPRemain
end

function BattleTeamModel:getTowerHeroRemainHP(heroID)
    local climbHero = self._herosHPRemain or {}
    for _, heroHP in ipairs(climbHero) do
        if heroHP.ID == heroID then
            return heroHP.RemainHP
        end
    end
    -- TODO:
    CCLog("Team:", self._side, "Tower HeroID:", heroID, " remainHP not found", vardump( climbHero))
    return nil
end

function BattleTeamModel:maxConsumeRage()
    local needRage = 0
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() then
            local need = hero:rageConsumeRage()
            if type(need) == "number" and need > needRage then
                needRage = need
            end
        end
    end
    return needRage
end

function BattleTeamModel:canAutoReleaseRageSkill(heroModel)
    CCLog("BattleTeamModel:canAutoReleaseRageSkill")
    local enable, reason = heroModel:canReleaseRageSkill()
    if not enable  then
        CCLogf("heroModel(%s):disableRageSkill(%s)", heroModel:getName(), reason)
        return false
    end

    if iskindof(heroModel, "SummonBeastModel") then
        return true
    end

    local minReleaseCount = self:minRageReleaseCount()
    local heroReleaseCount = self:heroRageReleaseCount(heroModel)

    if heroModel:isTreatRageSkill() then
        if self:hasHeroHPUnderHalf() then
            self:setHeroReleaseCount(heroModel, minReleaseCount) -- 提升优化级
            return true
        else
            self:incHeroReleaseCount(heroModel) -- 降低优化级
            return false
        end
    end

    if minReleaseCount >= heroReleaseCount  then
        return true
    end

    local maxConsumeRage = self:maxConsumeRage()
    local needRage = heroModel:rageConsumeRage()
    if needRage * 0.5 >= maxConsumeRage then
        return true
    end

    -- 怒气超过需要过2倍
    if needRage * 0.5 >= self._rage then
        return true
    end
    
    CCLog(vardump({minReleaseCount = minReleaseCount, heroReleaseCount = heroReleaseCount}))
    return false
end

--[[
    form = {
    {pos = {x = 1, y = 1}, heroData = heroData},

    }
--]]
function BattleTeamModel:lineup(form, battleModel, dispatch)
    CCLog(vardump({form = form, add = self._formAddition }, "BattleTeamModel:lineup"))
    if form == nil or #form == 0 then
        --self._battleModel:teamHasNoHero(self._side)
        return
    end
    
    local teamSide = self._side
    local direction = teamSide == "left" and "right" or "left"

    local heroList = {}
    for index, unit in ipairs(form) do
        local cell = unit.cell
        local dataType = unit.type
        local data =unit.data
        local heroID = nil
        local heroModel = nil

        local HeroModel = nil

        if dataType == "friend" then
            dataType = "hero"
            HeroModel = require("scene.battle.model.fighter.FriendHeroModel")
        else
            HeroModel = require("scene.battle.model.fighter.BattleHeroModel")
        end

        if data then
            heroID = unit.data.ID
            heroModel = HeroModel.new({type = dataType, data = data, index = index}, self, self._formAddition)

            if self._formExtraHPAdditionRatio then
                heroModel:setExtraHPAddition(heroModel:getRawFullHP() * self._formExtraHPAdditionRatio)
            end
        end

        heroModel:setDirection(direction)

        if self:isClimbTower() then
            local remainHP = self:getTowerHeroRemainHP(heroModel:getHeroID())
            if remainHP ~= nil then
                heroModel:setRawPartialHP(remainHP)
            end
        end

        if teamSide == "right" and not heroModel:isMonster() then
            cell = BattleConfig.getFlipCell(cell)
        end
        heroModel:clearMoving()
        heroModel:setCell(cell)
        heroModel:setEventDispatcher(self._eventDispatcher)

        self._heroRawCellMap[heroModel] = cell

        table.insert(heroList, heroModel)
        
        self:setHeroModels(heroList)

        CCLog(vardump({AppEvent.UI.Battle.HeroLineup, {teamSide = teamSide, fighterID = heroModel:getFighterID(), modelAttr = heroModel:getViewInfo()}}))
        self:dispatchEvent(AppEvent.UI.Battle.HeroLineup, {teamSide = teamSide, fighterID = heroModel:getFighterID(), modelAttr = heroModel:getViewInfo()})
    end

    if dispatch then
        self:dispatchEvent(AppEvent.UI.Battle.TeamLineup, {teamSide = teamSide})
    end
end

function BattleTeamModel:getSummonCell(cell, direction)
    local battleModel = self.battleModel
    local x = cell.x
    local y = cell.y

    local destX = x
    local destY = y

    if direction == "left" then
        destX = x - 2
    else
        destX = x + 2
    end

    if battleModel:isGridUsed(destX, destY) then
        for x = -2, 2 do
            for y = -2, 2 do
                local newX = destX + x
                local newY = destY + y
                if not battleModel:isGridUsed(newX, newY) then
                    return {x = newX, y = newY}
                end
            end
        end
    end

    return {x = destX, y = destY}
end

-- 召唤怪物
function BattleTeamModel:summon(attackData)
    local SummonBeastModel = require("scene.battle.model.fighter.SummonBeastModel")
    local onwerFighter = attackData:getAttacker()
    local skillData = attackData.skillData

    local count = skillData.targetNum
    if count == 0 then
        count = 1
    end

    for i = 1, count do
        local monsterID = skillData.formula
        local monsterData = assert(BaseConfig.GetMonster(monsterID), string.format("MonsterID:%d", monsterID))
        local cell = onwerFighter:getCell()
        local direction = onwerFighter:getDirection()
        local destCell = self:getSummonCell(cell, direction)

        local heroID = monsterData.ID
        local heroModel = SummonBeastModel.new(monsterData, self, onwerFighter)
        heroModel:setDirection(direction)

        if self:isClimbTower() then
            local remainHP = self:getTowerHeroRemainHP(heroModel:getHeroID())
            if remainHP ~= nil then
                heroModel:setHP(remainHP)
            end
        end

        heroModel:setCell(destCell)
        heroModel:setEventDispatcher(self._eventDispatcher)

        self._heroRawCellMap[heroModel] = destCell
        self:addSummonBeast(heroModel)

        local teamSide = self._side
        self:dispatchEvent(AppEvent.UI.Battle.Summoning, {teamSide = teamSide, fighterID = heroModel:getFighterID(), modelAttr = heroModel:getViewInfo()})
    end
end

function BattleTeamModel:transfiguration(srcMonster, dstMonsterID)
    local MonsterModel = require("scene.battle.model.fighter.MonsterModel")    

    local monsterData = assert(BaseConfig.GetMonster(dstMonsterID), string.format("MonsterID:%d", dstMonsterID))
    local cell = srcMonster:getCell()
    local direction = srcMonster:getDirection()

    local heroModel = MonsterModel.new(monsterData, srcMonster:getTeam())
    heroModel:setDirection(direction)
    heroModel:setCell(cell)
    heroModel:setEventDispatcher(self._eventDispatcher)

    self:addSummonBeast(heroModel)

    local teamSide = self._side
    self:dispatchEvent(AppEvent.UI.Battle.Summoning, {teamSide = teamSide, fighterID = heroModel:getFighterID(), modelAttr = heroModel:getViewInfo()})
    self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = srcMonster:getFighterID(), teamSide = srcMonster:getTeamSide(), fadeoutTime = 0})
    srcMonster:setHP(0)

    heroModel:triggeredSkill(BaseConfig.GetHeroSkill(5009, 1))
end

function BattleTeamModel:getReplicationCell(cell, direction)
    local x= cell.x
    if direction == "right" then
        x = x + 4
    else
        x = x - 4
    end

    if cell.y == 1 then
        return {x = x, y = 2}, {x = x, y = 3}
    elseif cell.y == 5 then
        return {x = x, y = 4}, {x = x, y = 3}
    else
        return {x = x, y = cell.y - 1}, {x = x, y = cell.y + 1}
    end
end

-- 分身
function BattleTeamModel:replicate(attackData)
    local ReplicationModel = require("scene.battle.model.fighter.ReplicationModel")
    local onwerFighter = attackData:getAttacker()
    local skillData = attackData.skillData
    local attackRatio = skillData.extraAffectValue

    local cell = onwerFighter:getCell()
    local direction = onwerFighter:getDirection()
    local cell1, cell2 = self:getReplicationCell(cell, direction)

    local cloned1 = ReplicationModel.new(onwerFighter, attackRatio)
    cloned1:setDirection(direction)
    cloned1:setCell(cell1)
    cloned1:setEventDispatcher(self._eventDispatcher)
    self._heroRawCellMap[cloned1] = cell1
    self:addSummonBeast(cloned1)

    local cloned2 = ReplicationModel.new(onwerFighter, attackRatio)
    cloned2:setDirection(direction)
    cloned2:setCell(cell2)
    cloned2:setEventDispatcher(self._eventDispatcher)
    self._heroRawCellMap[cloned2] = cell2
    self:addSummonBeast(cloned2)

    local teamSide = self._side
    self:dispatchEvent(AppEvent.UI.Battle.Replication, {
        teamSide = teamSide,
        fighterList = {
            {
                fighterID = cloned1:getFighterID(),
                modelAttr = cloned1:getViewInfo(),

            },
            {
                fighterID = cloned2:getFighterID(),
                modelAttr = cloned2:getViewInfo(),
            }
        }
    })
end

function BattleTeamModel:copyKiller(attackData)
    local CopyHeroModel = require("scene.battle.model.fighter.CopyHeroModel")
    local attacker = attackData.attacker
    local killer = attacker._killer

    if killer then
        local cell = attacker:getCell()
        local direction = attacker:getDirection()

        local copyKiller = CopyHeroModel.new(killer, self)
        copyKiller:setDirection(direction)
        copyKiller:setCell(cell)
        copyKiller:setEventDispatcher(self._eventDispatcher)
        self._heroRawCellMap[copyKiller] = cell
        self:addSummonBeast(copyKiller)

        local teamSide = self._side
        self:dispatchEvent(AppEvent.UI.Battle.Summoning, {teamSide = teamSide, fighterID = copyKiller:getFighterID(), modelAttr = copyKiller:getViewInfo()})
    end
end

function BattleTeamModel:summonHatredTarget(attackData)
    local HatredTargetModel = require("scene.battle.model.fighter.HatredTargetModel")
    local onwerFighter = attackData:getAttacker()
    local skillData = attackData.skillData

    local HP = attackData:calcSkillAffectValue(nil)
    local cell = attackData:getDestCell()
    local direction = onwerFighter:getDirection()
    local destCell = self:getSummonCell(cell, direction)

    local fighter = HatredTargetModel.new(HP, onwerFighter:getDEF(), cell, skillData, self)
    fighter:setDirection(direction)
    fighter:setEventDispatcher(self._eventDispatcher)

    self:addSummonBeast(fighter)

    local teamSide = self._side

    self:dispatchEvent(AppEvent.UI.Battle.SummonTarget, {
        teamSide = teamSide,
        fighterID = fighter:getFighterID(),
        res = fighter:getRes(),
        cell = cell,
        direction = direction,
    })
end

function BattleTeamModel:loadTurret(turretData)
    CCLog(vardump(turretData, "BattleTeamModel:loadTurret"))

    local TurretModel = require("scene.battle.model.fighter.TurretModel")
    local form = {}

    for _, turret in ipairs(turretData) do
        local turretID = turret.ID
        local turretPos = BattleConfig.configPosToCell(turret.Pos)

        local turretModel = TurretModel.new(turretID, turretPos, self, self.battleModel)
        if turret.Power then            
            turretModel:setStrength(1 + turret.Power / 10)
        end

        self._heroRawCellMap[turretModel] = turretPos
        self:addSummonBeast(turretModel)
        local teamSide = self._side
        self:dispatchEvent(AppEvent.UI.Battle.TurretAdded, {
            teamSide = teamSide,
            fighterID = turretModel:getFighterID(),
            res = turretModel:getRes(),
            showHPBar = turretModel:showHPBar(),
            cell = turretModel:getCell(),
        })

        for _, hero in ipairs(self._heroModelList) do
            local cell = hero:getCell()
            if cell.x == turretPos.x and cell.y == turretPos.y then
                if self._turretProtectMap == nil then
                    self._turretProtectMap = {[hero] = turretModel }
                else
                    self._turretProtectMap[hero] = turretModel
                end
                hero:protectByturret()
            end
        end
    end
end

function BattleTeamModel:isProtectedByTurret(heroModel)
    if self._turretProtectMap then
        local turretModel = self._turretProtectMap[heroModel]
        if turretModel then
            if turretModel:isAlive() then
                return true
            else
                self._turretProtectMap[heroModel] = nil
                return false
            end
        else
            return false
        end
    end

    return false
end

--function BattleTeamModel:turnIntoEgg(attackData)
--    local EasterEggModel = require("scene.battle.model.fighter.EasterEggModel")
--
--    local attacker = attackData.attacker
--    local eggModel = EasterEggModel.new(attacker, attackData.skillData.extraAffectValue)
--    eggModel:setEventDispatcher(self._eventDispatcher)
--    local teamSide = self._side
--
--    self:addSummonBeast(eggModel)
--    self:dispatchEvent(AppEvent.UI.Battle.TurnIntoEgg, {teamSide = teamSide, fighterID = attacker:getFighterID(), eggID = eggModel:getFighterID()})
--end

function BattleTeamModel:dispatchLineupEvent(battleModel)
    local teamSide = self._side
    self:dispatchEvent(AppEvent.UI.Battle.TeamLineup, {teamSide = teamSide})
end

function BattleTeamModel:getHeroRawCell(heroModel)
    local cell = self._heroRawCellMap[heroModel]
    return cell
end

-- 重新整理队形
function BattleTeamModel:relineup(battleModel)
    local teamSide = self._side
    local direction = teamSide == "left" and "right" or "left"

    local heroModels = self:getAliveHeroModels()
    for idx, heroModel in ipairs(heroModels) do
        local heroId = heroModel:getHeroID()

        local cell = self._heroRawCellMap[heroModel]
        if teamSide == "right" and not heroModel:isMonster() then
            cell = BattleConfig.getFlipCell(cell)
        end

        heroModel:setDirection(direction)
        heroModel:setTeamSide(teamSide)
        heroModel:clearMoving()
        heroModel:setCell(cell)
        heroModel:setMatchedEnemy(nil)
--        if heroModel:isAlive() then
--            heroModel:incHP(heroModel:getFullHP() * 0.2)
--        end

        self:dispatchEvent(AppEvent.UI.Battle.HeroRelineup, {teamSide = teamSide, fighterID = heroModel:getFighterID(), cell = cell})
    end

    local teamSide = self._side
    self:dispatchEvent(AppEvent.UI.Battle.TeamRelineup, {teamSide = teamSide})
end

function BattleTeamModel:hasResurrection()
    return self._resurrectionData ~= nil
end

function BattleTeamModel:getResurrectionData()
    return self._resurrectionData
end

function BattleTeamModel:setResurrectionData(attackData)
    self._resurrectionData = {
        attackData = attackData,
--        heroModels = heroModels
    }
end

function BattleTeamModel:heroCanResurrect(heroModel)
    if self._resurrectionData == nil then
        return false
    end

    if not heroModel:isAlive() and not heroModel:isStucked() then
        return true
    end

--    local heroList = self._resurrectionData.heroModels or {}
--    for _, hero in ipairs(heroList) do
--        if hero == heroModel then
--            return true
--        end
--    end
    return false
end

function BattleTeamModel:resurrectHero(heroModel, battleModel)
    local attackData = self._resurrectionData.attackData
    attackData:setOriginTargetFighter(heroModel)
    local attacker = attackData:getAttacker()
    if attacker:isAlive() then
        attacker:doAttack(attackData)
    end
    
    self:resetResurrectionData()
end

function BattleTeamModel:resetResurrectionData()
    self._resurrectionData = nil
end

function BattleTeamModel:dispatchEvent(eventName, data)
    if self._eventDispatcher then
        local event = cc.EventCustom:new(eventName)
        event.data = data
        --CCLog(vardump({eventName, data}, "dispatchEvent error"))

        self._eventDispatcher:dispatchEvent(event)
    end
end

function BattleTeamModel:hasElemBuff()
    return self._elemBuff.elemType ~= nil
end

function BattleTeamModel:getBuffElemType()
    return self._elemBuff.elemType
end

function BattleTeamModel:getElemBuff()
    return self._elemBuff
end

function BattleTeamModel:getComboHitTimes(elemType)
    if not self:hasElemBuff() then
        return 0
    end

    if self._elemBuff.elemType == elemType then
        return self._elemBuff.times
    end

    if ElemType.generate(self._elemBuff.elemType, elemType) then
        return self._elemBuff.times + 1
    end

    return 0
end

function BattleTeamModel:getBuffComboHitTimes()
    if not self:hasElemBuff() then
        return 0
    end

    return self._elemBuff.comboTimes
end

function BattleTeamModel:update(battleModel)
    local heroUpdateCount = 0

    self._rageIncTimeLeft = self._rageIncTimeLeft - BattleConfig.TIME_UNIT
    if self._rageIncTimeLeft <= 0 then
        self:incRage(1)
        self._rageIncTimeLeft = BattleConfig.RAGE_INC_INTERVAL
    end

    self._longRunning = false
    for idx, heroModel in ipairs(self._heroModelList) do
        if heroModel:isAlive() then
            heroModel:update(battleModel)
            heroUpdateCount = heroUpdateCount + 1
        end
    end

    for idx, heroModel in ipairs(self._summoning) do
        if heroModel:isAlive() then
            heroModel:update(battleModel)
            heroUpdateCount = heroUpdateCount + 1
        end
    end

    if self._fairyModel then
        self._fairyModel:update(battleModel)
    end

    if self:hasElemBuff() then
        if self._elemBuff.leftTick > 0 then
            self._elemBuff.leftTick = self._elemBuff.leftTick - 1
        else
            self:resetRageComboHit()
        end
    end

    if heroUpdateCount == 0 then
        self.battleModel:checkTeamHasNoHero(self._side)
    end
end

function BattleTeamModel:resetRageComboHit()
    -- 重置
    self:dispatchEvent(AppEvent.UI.Battle.RageComboHit, {teamSide = self._side, elemType = nil})
    self._elemBuff = {elemType = nil, times = 1, leftTick = 0, comboTimes = 1 }
end

function BattleTeamModel:getHeroCount()
    return #self._heroModelList
end

function BattleTeamModel:getRage()
    return self._rage
end

function BattleTeamModel:onAttack(attackData)
    if attackData.isComboHit then
        return
    end

    local Conditions = BattleHelper.Conditions
    if Conditions.Skill.Type.isRageSkill(attackData) then
        local elemType = attackData:getHeroModel():getElemType()

        CCLog(vardump({elemType = elemType, self._elemBuff}))
        CCLog("连击BUFF属性:", ElemType.typeName(elemType), "当前属性：", ElemType.typeName(self._elemBuff.elemType))
        if self:hasElemBuff() then
            if ElemType.generate(self._elemBuff.elemType, elemType) then
                CCLog("增加连击BUFF 五行相生:", ElemType.typeName(self._elemBuff.elemType), ElemType.typeName(elemType))

                self._elemBuff.elemType = elemType
                if self._elemBuff.times <= 5 then
                    self._elemBuff.times = self._elemBuff.times + 1
                end

                if self._elemBuff.comboTimes <= 5 then
                    self._elemBuff.comboTimes = self._elemBuff.comboTimes + 1
                end
                self._elemBuff.leftTick = ELEM_BUF_TICK

                self:dispatchEvent(AppEvent.UI.Battle.RageComboHit, {teamSide = self._side, elemType = elemType, times = self._elemBuff.times})
            elseif self._elemBuff.elemType == elemType and self._elemBuff.times >= 1 then
                -- 属性相同，保持
                CCLog("保持连击BUFF 五行相生:", ElemType.typeName(self._elemBuff.elemType), ElemType.typeName(elemType))

                -- self._elemBuff.elemType = elemType
                -- self._elemBuff.times = self._elemBuff.times
                -- self._elemBuff.comboTimes = self._elemBuff.comboTimes
                self._elemBuff.leftTick = ELEM_BUF_TICK

                self:dispatchEvent(AppEvent.UI.Battle.RageComboHit, {teamSide = self._side, elemType = elemType, times = self._elemBuff.times})
            else
                self._elemBuff.elemType = elemType
                self._elemBuff.times = 1
                self._elemBuff.comboTimes = 1
                self._elemBuff.leftTick = ELEM_BUF_TICK

                self:dispatchEvent(AppEvent.UI.Battle.RageComboHit, {teamSide = self._side, elemType = elemType, times = self._elemBuff.times})
            end
        else
            self._elemBuff.elemType = elemType
            self._elemBuff.times = 1
            self._elemBuff.comboTimes = 1
            self._elemBuff.leftTick = ELEM_BUF_TICK

            self:dispatchEvent(AppEvent.UI.Battle.RageComboHit, {teamSide = self._side, elemType = elemType, times = self._elemBuff.times})
        end
    end
end

function BattleTeamModel:incRage(rage)
    CCLog(string.format("BattleTeamModel:incRage(%d)", rage))
    assert(rage > 0)
    local oldRage = self._rage

    self._rage = self._rage + rage
    -- TODO:
    if self._rage > MAX_RAGE_VAL then
        self._rage = MAX_RAGE_VAL
    end

    if oldRage ~= self._rage then
        self:rageChanged(oldRage, self._rage)
    end
end

function BattleTeamModel:decRage(rage)
    CCLog(string.format("BattleTeamModel:decRage(%d, has)", rage, self._rage))
    local oldRage = self._rage

    self._rage = self._rage - rage
    if self._rage < 0 then
        self._rage = 0
    end

    if oldRage ~= self._rage then
        self:rageChanged(oldRage, self._rage)
    end
end

function BattleTeamModel:setRage(rage)
    assert(type(rage) == "number")
    local oldRage = self._rage

    self._rage = rage
end

function BattleTeamModel:rageChanged(old, new)
    self:dispatchEvent(AppEvent.UI.Battle.RageChanged, {teamSide = self._side , old = old, new = new})
end

function BattleTeamModel:reset()
    self._heroModelList = {}
    self._summoning = {}
    self._rage = 0
end

function BattleTeamModel:setHeroModels(heroModels)
    self._heroModelList = {}
    
    for idx, heroModel in ipairs(heroModels) do
        table.insert(self._heroModelList, heroModel)
    end

    self:sort()
    self:initHeroRageReleaseQueue()
end

function BattleTeamModel:getAllHeroModels(raw)
    if raw then
        return self._heroModelList
    end

    local heroList = {}
    for idx, hero in ipairs(self._heroModelList) do
       table.insert(heroList, hero)
    end
    return heroList
end

function BattleTeamModel:addSummonBeast(fighter)
    table.insert(self._summoning, fighter)
end

function BattleTeamModel:getFullHP()
    local fullHP = 0

    for idx, hero in ipairs(self._heroModelList) do
        fullHP = fullHP + hero:getFullHP()
    end

    return fullHP
end

function BattleTeamModel:getCurHP()
    local curHP = 0

    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() then
            curHP = curHP + hero:getHP()
        end
    end

    return curHP
end

function BattleTeamModel:getAllHeroHPLeft()
    local herosHPArray = {}

    for idx, hero in ipairs(self._heroModelList) do
        local HPPer = math.floor(hero:getHP() / hero:getFullHP() * 10000.0)
        table.insert(herosHPArray, {ID = hero:getHeroID(), RemainHP = hero:getHP(), HPPer = HPPer})
    end

    return herosHPArray
end

function BattleTeamModel:getAllHeroDamageStat()
    local damageMap = {}

    for idx, hero in ipairs(self._heroModelList) do
        local heroID = hero:getHeroID()
        local damage = hero:getDamageStat()
        --damageMap[heroID] = damage
        table.insert(damageMap, {heroID = heroID, damage = damage})
    end

    return damageMap
end

--function BattleTeamModel:getAliveHeroViews(includeSummoning)
--    local viewList = {}
--    for idx, hero in ipairs(self._heroModelList) do
--        if hero:isAlive() then
--            local view = hero:getView()
--            if not tolua.isnull(view) then
--                table.insert(viewList, view)
--            end
--        end
--    end
--
--    if includeSummoning then
--        for idx, hero in ipairs(self._summoning) do
--            if hero:isAlive() then
--                local view = hero:getView()
--                if not tolua.isnull(view) then
--                    table.insert(viewList, view)
--                end
--            end
--        end
--    end
--
--    return viewList
--end

function BattleTeamModel:getAliveHeroModels(includeSummoning, excludeTurret)
    local heroList = {}
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() then
            if excludeTurret then
                if not self:isProtectedByTurret(hero) then
                    table.insert(heroList, hero)
                end
            else
                table.insert(heroList, hero)
            end
        else
            CCLog("not alive hero", hero:getName())
        end
    end

    if includeSummoning then
        for idx, hero in ipairs(self._summoning) do
            if hero:isAlive() then
                table.insert(heroList, hero)
            end
        end
    end

    return heroList
end

function BattleTeamModel:hasHeroHPUnderHalf()
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() then
            if hero:getHPPercent() < 50.0 then
                return true
            end
        end
    end

    return false
end

function BattleTeamModel:getCanMatchedHeroModels(includeSummoning)
    local heroList = {}
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() and hero:canMatched() and not self:isProtectedByTurret(hero) then
            table.insert(heroList, hero)
        end
    end

    if includeSummoning then
        for idx, hero in ipairs(self._summoning) do
            if hero:isAlive() and hero:canMatched() then
                table.insert(heroList, hero)
            end
        end
    end

    return heroList
end

function BattleTeamModel:getAliveHeroCount(includeSummoning)
    local count = 0
    for _, hero in ipairs(self._heroModelList) do
        if hero:isAlive() then
            count = count + 1
        end
    end
    if includeSummoning then
        for idx, hero in ipairs(self._summoning) do
            if hero:isAlive() then
                count = count + 1
            end
        end
    end

    CCLog("BattleTeamModel:getAliveHeroCount", self._side, count)
    return count
end

function BattleTeamModel:getDeadHeroModels()
    local heroList = {}
    for idx, hero in ipairs(self._heroModelList) do
        if not hero:isAlive() then
            table.insert(heroList, hero)
        end
    end
    return heroList
end

function BattleTeamModel:getDeadHeroCount()
    local count = 0
    for _, hero in ipairs(self._heroModelList) do
        if not hero:isAlive() then
            count = count + 1
        end
    end
    return count
end

function BattleTeamModel:getCanReliveCount()
    local count = 0
    for _, hero in ipairs(self._heroModelList) do
        if not hero:isAlive() and not hero:isStucked() then
            count = count + 1
        end
    end
    return count
end

function BattleTeamModel:hasFreeHero()
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() and not hero:hasMatchedEnemy() then
            return true
        end
    end
    return false
end

function BattleTeamModel:getFreeHeroModels()
    local heroList = self:getAliveHeroModels()

    local freeHeroList = {}
    for idx, hero in ipairs(heroList) do
        if not hero:hasMatchedEnemy() then
            table.insert(freeHeroList, hero)
        end
    end
    return freeHeroList
end

function BattleTeamModel:sort()
    if self._side == "left" then
        self:sortLeft(self._heroModelList)
    elseif self._side == "right" then
        self:sortRight(self._heroModelList)
    end

    local cells = {}
    for idx, hero in ipairs(self._heroModelList) do
        table.insert(cells, hero:getCell())
    end
    CCLog(vardump(cells, "after sort"))
end

-- 左军排序 (右边，下边优先)
function BattleTeamModel:sortLeft(heroModels)
    local compareHeroPos = function(heroA, heroB)
        local cellA = heroA:getCell()
        local cellB = heroB:getCell()
        
        if cellA.x == cellB.x then
            return cellA.y < cellB.y
        elseif cellA.x > cellB.x then
            return true
        else
            return false
        end
    end
    table.sort(heroModels, compareHeroPos)    
end

-- 右军排序 (左边，下边优先)
function BattleTeamModel:sortRight(heroModels)
    local compareHeroPos = function(heroA, heroB)
        local cellA = heroA:getCell()
        local cellB = heroB:getCell()

        if cellA.x == cellB.x then
            return cellA.y < cellB.y
        elseif cellA.x < cellB.x then
            return true
        else
            return false
        end
    end
    table.sort(heroModels, compareHeroPos)    
end

function BattleTeamModel:removeHero(heroModel)
    for idx, hero in ipairs(self._heroModelList) do
        if hero == heroModel then
            CCLog("BattleTeamModel:removeHero(", hero:getName(), ")")
            table.remove(self._heroModelList, idx)
            return true
        end
    end
    return false
end

function BattleTeamModel:removeMatchedEnemy(heroModel)
    local ret = false
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isMatchedEnemy(heroModel) then
            hero:setMatchedEnemy(nil)
            ret = true
        end
    end

    for idx, hero in ipairs(self._summoning) do
        if hero:isMatchedEnemy(heroModel) then
            hero:setMatchedEnemy(nil)
            ret = true
        end
    end

    return ret
end

function BattleTeamModel:clearBuff()
    for _, hero in ipairs(self._heroModelList) do
        hero:clearBuff()
    end

    for _, hero in ipairs(self._summoning) do
        hero:clearBuff()
    end
end

function BattleTeamModel:preload()
    for _, hero in ipairs(self._heroModelList) do
        hero:preload()
    end
end

function BattleTeamModel:onBattleRoundStart()
    for _, hero in ipairs(self._heroModelList) do
        hero:onBattleRoundStart()
    end

    CCLog("BattleTeamModel:onBattleRoundStart()", self._formExtraHPAdditionRatio)
    local hpAddRatio = self._formExtraHPAdditionRatio
    if hpAddRatio then
        for _, hero in ipairs(self._heroModelList) do
            hero:treat(nil, hero:getRawFullHP() * hpAddRatio)
        end
    end

    -- for _, hero in ipairs(self._summoning) do
    --     hero:onBattleRoundStart()
    -- end
end

function BattleTeamModel:onBattleRoundEnd()
    for _, hero in ipairs(self._heroModelList) do
        hero:onBattleRoundEnd()
    end

    for _, hero in ipairs(self._summoning) do
        hero:onBattleRoundEnd()
    end
end

function BattleTeamModel:onRageSkill(heroModel, skillData)
    self:incHeroReleaseCount(heroModel)
    --self:decRage(skillData.consumeRage)
end

function BattleTeamModel:incHeroReleaseCount(heroModel)
    local releaseInfo = self._heroRageReleaseQueue[heroModel]
    if releaseInfo then
        releaseInfo.count = releaseInfo.count + 1
    end
end

function BattleTeamModel:decHeroReleaseCount(heroModel)
    local releaseInfo = self._heroRageReleaseQueue[heroModel]
    releaseInfo.count = releaseInfo.count - 1
    if releaseInfo.count < 0 then
        releaseInfo.count = 0
    end
end

function BattleTeamModel:setHeroReleaseCount(heroModel, count)
    local releaseInfo = self._heroRageReleaseQueue[heroModel]
    releaseInfo.count = count
end

function BattleTeamModel:onEnemyMoved(enemyModel)
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() and hero:getMatchedEnemy() == enemyModel then
            hero:setMatchedEnemy(nil)
        end
    end

    for idx, hero in ipairs(self._summoning) do
        if hero:isAlive() and hero:getMatchedEnemy() == enemyModel then
            hero:setMatchedEnemy(nil)
        end
    end
end

function BattleTeamModel:onEnemyChanged()
    for idx, hero in ipairs(self._heroModelList) do
        if hero:isAlive() then
            hero:setMatchedEnemy(nil)
        end
    end

    for idx, hero in ipairs(self._summoning) do
        if hero:isAlive() then
            hero:setMatchedEnemy(nil)
        end
    end
end

function BattleTeamModel:heroDie(heroModel)
    if self._turretProtectMap then
        for hero, turretModel in pairs(self._turretProtectMap) do
            if turretModel == heroModel then
               hero:loseProtectionOfTurret()
            end
        end
    end
end

function BattleTeamModel:onHeroKill(heroModel, targetFighter)
    local teamSide = heroModel:getTeamSide()
    local targetTeamSide = targetFighter:getTeamSide()
    if teamSide ~= targetTeamSide then
        heroModel:onKillEnemy(targetFighter)
    elseif teamSide == targetFighter then
        heroModel:onKillTeammate(targetFighter)
    end
end

function BattleTeamModel:setRegionRageData(regionRageData)
    self._regionRageData = regionRageData
end

function BattleTeamModel:getRegionRageData()
    return self._regionRageData
end

return BattleTeamModel
