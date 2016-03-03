--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-5
-- Time: 下午2:44
-- 攻击模型, 表示一次攻击的数据
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local ElemType = require("config.ElemType")
local BHT = require("tool.lib.BehaviourTree")
local BattleHelper = require("scene.battle.helper.BattleHelper")
local BattleUtils = require("scene.battle.helper.Utils")
-------------------------------------------------------------------------------
local AttackDataModel = class("AttackDataModel")

local function fighter_names(fighterList)
    local names = {}
    for _, fighter in ipairs(fighterList) do
        table.insert(names, fighter:getName())
    end
    return table.concat(names, ", ")
end

function AttackDataModel:ctor(attacker, battleModel, skillID, skillLevel, originTargetFighterIDList)
    self.attacker = attacker
    self.battleModel = battleModel
    self.skillID = skillID
    self.skillLevel = skillLevel
    self.skillData = assert(BaseConfig.GetHeroSkill(skillID, skillLevel), string.format("skill data not found:{id:%d, lv:%d}", skillID, skillLevel))
    self.destCell = nil
    self.destPos = nil

    self.timeTick = 0

    self.targetFighterList = nil
    self.extraAffect = false
    self.subAttackList = nil
    self.originTargetFighterIDList = originTargetFighterIDList
    self.isComboHit = false
    self.isNormAttackCritical = nil

    self._skillAreaBitmap = nil

    assert(self:checkAttackerType(), string.format("skillID:%d AttackerType and skill type don't match %s:%d", skillID, self:getAttackerType(), self.skillData.type))
end

function AttackDataModel:randomElems(array, n)
    --CCLog(vardump({#array, n}, "AttackDataModel:randomElems"))
    local len = #array
    if len == 0 then
        return {}
    else
        local result = {}
        while n > 0 and len > 0 do
            local r = self.battleModel:random(1, len)
            table.insert(result, array[r])
            table.remove(array, r)

            len = #array
            n = n - 1
        end
        return result
    end
end

function AttackDataModel:preComputedCrit()
    local skillData = self.skillData
    local attacker = self.attacker
    local originTargetFighterIDList = self.originTargetFighterIDList

    local isCriticalHit = false
    if skillData.type == enums.SkillType.NormAttack then
        if #originTargetFighterIDList == 1 then
            local FighterModel = require("scene.battle.model.fighter.FighterModel")


            local fighterID = originTargetFighterIDList[1]
            local targetFighter = FighterModel.getFighter(fighterID)

            local A = 30
            local crit = attacker:getCRIT()
            local ten = targetFighter:getTEN()

            local critical = math.max((crit - ten) / (crit + A) * 0.5, 0) + 0.04 -- TODO:测试用
            local randNum = self.battleModel:random()
            --CCLog(vardump({randNum = randNum, critical = critical}, "AttackDataModel:preComputedCrit"))
            if randNum <= critical then
                isCriticalHit = true
            end
        else
            CCLog("AttackDataModel:preComputedCrit error:has target num = ", #originTargetFighterIDList)
        end
    end

    self.isNormAttackCritical = isCriticalHit
end

function AttackDataModel:setOriginTargetFighter(fighter)
    self.originTargetFighterIDList = {fighter:getFighterID()}
end

function AttackDataModel:getOriginTargetFighter(fighter)
   if self.originTargetFighterIDList and #self.originTargetFighterIDList == 1 then
       local FighterModel = require("scene.battle.model.fighter.FighterModel")
       return FighterModel.getFighter(self.originTargetFighterIDList[1])
   end
end

function AttackDataModel:getAttackerType()
    return self.attacker:getFighterType()
end

function AttackDataModel:getAttacker()
    return self.attacker
end

function AttackDataModel:getSubAttackList()
    return self.subAttackList or {}
end

function AttackDataModel:setSubAttackList(subAttackList)
    self.subAttackList = subAttackList
end

function AttackDataModel:setIsComboHit(isComboHit)
    self.isComboHit = isComboHit
end

function AttackDataModel:setIsNormAttackCritical(isCritical)
    self.isNormAttackCritical = isCritical
end

function AttackDataModel:attackerIsHero()
    local attackerType = self:getAttackerType()
    return attackerType == "hero" or attackerType == "monster"
end

function AttackDataModel:attackerIsInstance()
    return self:getAttackerType() == "instance"
end

function AttackDataModel:attackerIsTrap()
    return self:getAttackerType() == "trap"
end

function AttackDataModel:attackerIsFairy()
    return self:getAttackerType() == "fairy"
end

function AttackDataModel:attackerIsObstacle()
    return self:getAttackerType() == "obstacle"
end

function AttackDataModel:attackerIsTurret()
    return self:getAttackerType() == "turret"
end

function AttackDataModel:attackerIsHatredTarget()
    return self:getAttackerType() == "hatredTarget"
end

function AttackDataModel:checkAttackerType()
    -- 所有类型都可以用普攻
    if self.skillData.id == 1001 or self.skillData.id == 1002  or self.skillData.id == 1003 then
        return true
    end

    if self:getAttackerType() == "hero" then
        return self.skillData.type == enums.SkillType.NormAttack or
                self.skillData.type == enums.SkillType.NormSkill or
                self.skillData.type == enums.SkillType.RageSkill or
                self.skillData.type == enums.SkillType.InnateSkill
    elseif self:getAttackerType() == "instance" then
        return self.skillData.type == enums.SkillType.InstanceSkill
    elseif self:getAttackerType() == "trap" then
        return self.skillData.type == enums.SkillType.TrapSkill
    elseif self:getAttackerType() == "fairy" then
        return self.skillData.type == enums.SkillType.FairySkill
    elseif self:getAttackerType() == "obstacle" then
        return self.skillData.type == enums.SkillType.ObstacleSkill
    elseif self:getAttackerType() == "turret" then
        return true
    elseif self:getAttackerType() == "hatredTarget" then
        return true       
    end
end

function AttackDataModel:isRageSkill()
    return self.skillData.type == enums.SkillType.RageSkill
end

function AttackDataModel:targetIsTeammate()
    return BattleUtils.skillTargetIsTeammate(self.skillData.target)
end

function AttackDataModel:encode()
    return json.encode({
        fighterID = self.attacker:getFighterID(),
        skillID = self.skillID,
        skillLevel = self.skillLevel,
        destCell = self.destCell,
        originTargetFighterIDList = self.originTargetFighterIDList,
        isComboHit = self.isComboHit,
        isNormAttackCritical = self.isNormAttackCritical,
    })
end

function AttackDataModel.decode(jsonStr, battleModel)
    local jsData = assert(json.decode(jsonStr), jsonStr)
    local FighterModel = require("scene.battle.model.fighter.FighterModel")
    
    local attacker = assert(FighterModel.getFighter(jsData.fighterID), "attacker:" .. tostring(jsData.fighterID))
    local attackData = AttackDataModel.new(attacker, battleModel, jsData.skillID, jsData.skillLevel, jsData.originTargetFighterIDList)
    attackData:setDestCell(jsData.destCell)
    attackData:setIsComboHit(jsData.isComboHit)
    attackData:setIsNormAttackCritical(jsData.isNormAttackCritical)

    return attackData
end

function AttackDataModel:update()
    self.timeTick = self.timeTick + 1
end

function AttackDataModel:setDestCell(cell)
    CCLog(vardump({cell = cell}, "AttackDataModel:setDestCell()"))
    self.destCell = cell
    self.destPos = nil
end

function AttackDataModel:setDestPos(pos)
    CCLog(vardump({pos = pos}, "AttackDataModel:setDestPos()"))
    self.destPos = pos

    local cell =  BattleConfig.getCellOfPos(pos.x, pos.y)
    self:setDestCell(cell)
end


function AttackDataModel:getDestCell()
    CCLog(vardump({cell = self.destCell}, "AttackDataModel:getDestCell()"))
    if self.destCell == nil then
        if self:attackerIsHero() then
            local heroModel = self:getHeroModel()

            if self.skillData.target == enums.SkillAffectTarget.AroundEnemies then
                self.destCell = heroModel:getCell()
            elseif self.skillData.affect == enums.SkillAffectType.HatredTarget then
                local cell = self:absRegionRectCenterCell()
                self.destCell = cell
            elseif self:targetIsTeammate() then
                self.destCell = heroModel:getCell()
                --self.destCell = self:calcHeroOptimalDestCell()
            else
                --self.destCell = self:calcHeroOptimalDestCell()
                local enemyModel = heroModel:getMatchedEnemy()
                if enemyModel then
                    self.destCell = enemyModel:getCell()
                else
                    local targetList = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
                    if #targetList > 0 then
                        self.destCell = targetList[1]:getCell()
                    else
                        CCLog("no enemy, use self cell")
                        self.destCell = heroModel:getCell()
                    end
                end
            end
        elseif self:attackerIsInstance() then
            CCLog("TODO: 副本技术")
            self.destCell = {x = 10, y = 3}
        elseif self:attackerIsTrap() then
            CCLog("TODO: 陷阱技术")
            -- TODO:
        else
            assert(false, "unknown attacker type:" .. self:getAttackerType())
        end
    end
    CCLog(vardump({cell = self.destCell}, "AttackDataModel:getDestCell()"))
    return self.destCell
end

function AttackDataModel:getDestPos()
    local destPos = self.destPos

    if destPos == nil then
        local destCell = self:getDestCell()
        local cellPos = BattleConfig.getCellPos(destCell.x, destCell.y)
        destPos = cellPos
    end

    return destPos
end

local function sign(num)
    if num > 0 then
        return 1
    elseif num < 0 then
        return -1
    else
        return 0
    end
end

local function get_target_list_rect_center(attacker, targetList, width, height)
    local matchedEnemy = attacker:getMatchedEnemy()
    if matchedEnemy == nil then
        local cellPos = attacker:getCellPos()
        matchedEnemy = targetList[1]
        
        for _, target in ipairs(targetList) do
            if target ~= matchedEnemy then
                local mcellPos = matchedEnemy:getCellPos()
                local tcellPos = target:getCellPos()
                if math.abs(tcellPos.x - cellPos.x) < math.abs(mcellPos.x - cellPos.x) then
                    matchedEnemy = target
                end
            end
        end        
    end

    local neightborPosList = {}
    local pos = matchedEnemy:getCellPos()
    local lastDisSignX = 0
    local lastDisSignY = 0
    for _, innerTarget in ipairs(targetList) do

        if innerTarget ~= matchedEnemy then
            local innerPos = innerTarget:getCellPos()
            local disX = innerPos.x - pos.x
            local disY = innerPos.y - pos.y

            if lastDisSignX == 0 then
                lastDisSignX = sign(disX)
            else
                local disSignX = sign(disX)
                if disSignX ~= 0 and lastDisSignX ~= disSignX then
                    break
                end
            end

            if lastDisSignY == 0 then
                lastDisSignY = sign(disY)
            else
                local disSignY = sign(disY)
                if disSignY ~= 0 and lastDisSignY ~= disSignY then
                    break
                end
            end

            if disX > -width and disX < width and disY > -height and disY < height then
                table.insert(neightborPosList, innerPos)
            end
        end
    end

    local cell = matchedEnemy:getCell()
    local count = #neightborPosList 

    if count == 0 then
        return cell
    else
        local distance = {x = 0, y = 0}
        for _, targetPos in ipairs(neightborPosList) do
            distance = cc.pAdd(distance, cc.pSub(targetPos, pos))
        end
        
        distance.x = distance.x / count / 2
        distance.y = distance.y / count / 2

        distance.x = math.max(math.min(distance.x, width - 4), -width + 4)
        distance.y = math.max(math.min(distance.y, height - 4), -height + 4)

        CCLog(vardump({name = matchedEnemy:getName(), distance = distance, pos = pos, width = width, height = height, neightborPosList = neightborPosList}, "Raw:"))
        local result = {x = cell.x + (distance.x / BattleConfig.CELL_WIDTH), y = cell.y + (distance.y / BattleConfig.CELL_HEIGHT)}
        CCLog(vardump({result, cell}, "Result:"))
        return result
    end
end

local function get_target_list_circle_center(attacker, targetList, width, height)
    local matchedEnemy = attacker:getMatchedEnemy()
    if matchedEnemy == nil then
        local cellPos = attacker:getCellPos()
        matchedEnemy = targetList[1]        

        for _, target in ipairs(targetList) do
            if target ~= matchedEnemy then
                local mcellPos = matchedEnemy:getCellPos()
                local tcellPos = target:getCellPos()
                if math.abs(tcellPos.x - cellPos.x) < math.abs(mcellPos.x - cellPos.x) then
                    matchedEnemy = target
                end
            end
        end        
    end

    local widthSQ = (width - 4) ^ 2
    local heightSQ = (height - 4) ^ 2

    local neightborPosList = {}
    local pos = matchedEnemy:getCellPos()
    local lastDisSignX = 0
    local lastDisSignY = 0
    for _, innerTarget in ipairs(targetList) do

        if innerTarget ~= matchedEnemy then
            local innerPos = innerTarget:getCellPos()
            local disX = innerPos.x - pos.x
            local disY = innerPos.y - pos.y
            local disXSQ = disX * disX
            local disYSQ = disY * disY

            if lastDisSignX == 0 then
                lastDisSignX = sign(disX)
            else
                local disSignX = sign(disX)
                if disSignX ~= 0 and lastDisSignX ~= disSignX then
                    break
                end
            end

            if lastDisSignY == 0 then
                lastDisSignY = sign(disY)
            else
                local disSignY = sign(disY)
                if disSignY ~= 0 and lastDisSignY ~= disSignY then
                    break
                end
            end

            if disXSQ < widthSQ and disYSQ < heightSQ and disXSQ + disYSQ <  widthSQ + heightSQ then
                table.insert(neightborPosList, innerPos)
            end
        end
    end

    local cell = matchedEnemy:getCell()
    local count = #neightborPosList 

    if count == 0 then
        return cell
    else
        local distance = {x = 0, y = 0}
        for _, targetPos in ipairs(neightborPosList) do
            distance = cc.pAdd(distance, cc.pSub(targetPos, pos))
        end
        
        distance.x = distance.x / count / 2
        distance.y = distance.y / count / 2

        distance.x = math.max(math.min(distance.x, width - 2), -width + 2)
        distance.y = math.max(math.min(distance.y, height - 2), -height + 2)

        CCLog(vardump({name = matchedEnemy:getName(), distance = distance, pos = pos, width = width, height = height, neightborPosList = neightborPosList}, "Raw:"))
        local result = {x = cell.x + (distance.x / BattleConfig.CELL_WIDTH), y = cell.y + (distance.y / BattleConfig.CELL_HEIGHT)}
        CCLog(vardump({result, cell}, "Result:"))
        return result
    end
end

function AttackDataModel:calcHeroOptimalDestCell()
    local skillData = self:getSkillData()
    local areaInfo = BattleUtils.getSkillArea(skillData.id)

    if self:targetIsTeammate() then
        local targetList = self.attacker:getTeammates({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        targetList = self:fightersInInRegion(targetList)        

        if skillData.shape == enums.SkillAreaShape.Circle or skillData.shape == enums.SkillAreaShape.Rect then
            if self.attacker:getTeamSide() == "left" then
                table.sort(targetList, function(heroA, heroB) return heroA:getCell().x > heroB:getCell().x end)
            else
                table.sort(targetList, function(heroA, heroB) return heroA:getCell().x < heroB:getCell().x end)
            end

            local cell = targetList[1]:getCell()
            local sumY = cell.y
            local count = 1
            for idx = 2, #targetList do
                local target = targetList[idx]
                local tcell = target:getCell()
                if tcell.x == cell.x then
                    count = count + 1
                    sumY = sumY + tcell.y
                end
            end

            local x = cell.x
            local y = sumY / count

            return {x = x, y = y}
        else
            if #targetList > 1 and skillData.affect == enums.SkillAffectType.Treatment then
                table.sort(targetList, function(heroA, heroB) return heroA:getHPPercent() < heroB:getHPPercent() end)
                return targetList[1]:getCell()
            else
                return self.attacker:getCell()
            end
        end
    else
        local targetList = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        targetList = self:fightersInInRegion(targetList)

        local targetCount = #targetList
        if targetCount == 1 then
            return targetList[1]:getCell()
        elseif targetCount > 0 then
            if areaInfo then
                if skillData.shape == enums.SkillAreaShape.Circle then
                    return get_target_list_circle_center(self.attacker, targetList, areaInfo.width, areaInfo.height)
                elseif skillData.shape == enums.SkillAreaShape.Rect then
                    return get_target_list_rect_center(self.attacker, targetList, areaInfo.width, areaInfo.height)
                else
                    local enemy = self.attacker:getMatchedEnemy()
                    if enemy then 
                        return enemy:getCell()
                    else
                        return targetList[1]:getCell()
                    end
                end
            else
                local enemy = self.attacker:getMatchedEnemy()
                if enemy then 
                    return enemy:getCell()
                else
                    return self.attacker:getCell()
                end
            end
        else
            return self.attacker:getCell()
        end
    end
end

function AttackDataModel:getTargetFighterList()
    if self.originTargetFighterIDList then
        local FighterModel = require("scene.battle.model.fighter.FighterModel")

        local fighterList = {}
        for idx, fighterID in ipairs(self.originTargetFighterIDList) do
            table.insert(fighterList, FighterModel.getFighter(fighterID))
        end
        return fighterList
    end

    if self.targetFighterList == nil then
        if self:attackerIsHero() then
            self.targetFighterList = self:calcHeroTargetFighterList()
        elseif self:attackerIsInstance() then
            self.targetFighterList = self:calcInstanceTargetFighterList()
        elseif self:attackerIsTrap() then
            self.targetFighterList = self:calcTrapTargetFighterList()
        elseif self:attackerIsFairy() then
            self.targetFighterList = self:calcFairyTargetFighterList()
        elseif self:attackerIsObstacle() then
            self.targetFighterList = self:calcInstanceTargetFighterList()
        elseif self:attackerIsTurret() then
            self.targetFighterList = self:calcTurretTargetFighterList()
        elseif self:attackerIsHatredTarget() then
            self.targetFighterList = self:calcHatredTargetFighterList()
        else
            assert(false, "attackerType is unkown:" .. self:getAttackerType())
        end
    end

    return self.targetFighterList
end

function AttackDataModel:getTeamSide()
    if self:attackerIsHero() then
        return self:getHeroModel():getTeamSide()
    elseif self:attackerIsInstance() or self:attackerIsTrap() then
        return "right"
    elseif self:attackerIsFairy() then
        local fairyModel = self.attacker
        local teamSide = fairyModel:getTeamSide()
        return teamSide
    else
        assert(false, "还没有处理")
    end
end

function AttackDataModel:calcInstanceTargetFighterList()
    local enemyTeam = self.battleModel.leftTeam
    local selfTeam = self.battleModel.rightTeam

    local AffectTargetFunctionMap = {
        [enums.SkillAffectTarget.AllEnemies] = function()
            return enemyTeam:getAliveHeroModels(true, true)
        end,
        [enums.SkillAffectTarget.AllTeammates] = function()
            return selfTeam:getAliveHeroModels(true, true)
        end,
        [enums.SkillAffectTarget.Self] = function()
            return {}
        end,
        [enums.SkillAffectTarget.MatchedEnemy] = function()
            return {}
        end,
        [enums.SkillAffectTarget.RandomEnemy] = function()
            local enemies = enemyTeam:getAliveHeroModels(true, true)
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.ScopeEnemies] = function()
            return {}
        end,
        [enums.SkillAffectTarget.ScopeTeammates] = function()
            return {}
        end,
        [enums.SkillAffectTarget.RandomTeamate] = function()
            local enemies = selfTeam:getAliveHeroModels(true, true)
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.MostWeakEnemy] = function()
            local enemies = enemyTeam:getAliveHeroModels(true, true)
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                if p1 == p2 then
                    local hp1 = hero1:getHP()
                    local hp2 = hero2:getHP()
                    return hp1 < hp2
                else
                    return p1 < p2
                end

            end)
            return {enemies[1]}
        end,
        [enums.SkillAffectTarget.MinPercentHPTeammate] = function()
            local teammates = selfTeam:getAliveHeroModels(true, true)
            table.sort(teammates, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)
            return {teammates[1]}
        end,
        [enums.SkillAffectTarget.AroundEnemies] = function()
            return {}
        end,
        [enums.SkillAffectTarget.SelectAreaEnemies] = function()
            return {}
        end,
        [enums.SkillAffectTarget.DeadTeammate] = function()
            return selfTeam:getDeadHeroModels()
        end,

        [enums.SkillAffectTarget.NRandomTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = selfTeam:getAliveHeroModels(true, true)

            return self:randomElems(teammates, num)
        end,

        [enums.SkillAffectTarget.NRandomEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = enemyTeam:getAliveHeroModels(true, true)

            return self:randomElems(enemies, num)
        end,

        [enums.SkillAffectTarget.NWeakestTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = selfTeam:getAliveHeroModels(true, true)
            table.sort(teammates, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(teammates) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.NWeakestEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = enemyTeam:getAliveHeroModels(true, true)
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(enemies) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,
    }

    local func = AffectTargetFunctionMap[self.skillData.target]
    if func then
        return func()
    else
        return {}
    end
end

function AttackDataModel:calcFairyTargetFighterList()
    local fairyModel = self.attacker
    local teamSide = fairyModel:getTeamSide()

    local enemyTeam = nil
    local selfTeam = nil

    if teamSide == "left" then
        selfTeam  = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        enemyTeam = self.battleModel.leftTeam
        selfTeam  = self.battleModel.rightTeam
    end

    local AffectTargetFunctionMap = {
        [enums.SkillAffectTarget.AllEnemies] = function()
            return enemyTeam:getAliveHeroModels(true, true)
        end,
        [enums.SkillAffectTarget.AllTeammates] = function()
            return selfTeam:getAliveHeroModels()
        end,
        [enums.SkillAffectTarget.Self] = function()
            return {}
        end,
        [enums.SkillAffectTarget.MatchedEnemy] = function()
            return {}
        end,
        [enums.SkillAffectTarget.RandomEnemy] = function()
            local enemies = enemyTeam:getAliveHeroModels(true, true)
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.ScopeEnemies] = function()
            return {}
        end,
        [enums.SkillAffectTarget.ScopeTeammates] = function()
            return {}
        end,
        [enums.SkillAffectTarget.RandomTeamate] = function()
            local enemies = selfTeam:getAliveHeroModels(true, true)
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.MostWeakEnemy] = function()
            local enemies = enemyTeam:getAliveHeroModels(true, true)
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                if p1 == p2 then
                    local hp1 = hero1:getHP()
                    local hp2 = hero2:getHP()
                    return hp1 < hp2
                else
                    return p1 < p2
                end

            end)
            return {enemies[1]}
        end,
        [enums.SkillAffectTarget.MinPercentHPTeammate] = function()
            local teammates = selfTeam:getAliveHeroModels(true, true)
            table.sort(teammates, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)
            return {teammates[1]}
        end,
        [enums.SkillAffectTarget.AroundEnemies] = function()
            return {}
        end,
        [enums.SkillAffectTarget.SelectAreaEnemies] = function()
            return {}
        end,
        [enums.SkillAffectTarget.DeadTeammate] = function()
            return selfTeam:getDeadHeroModels()
        end,

        [enums.SkillAffectTarget.NRandomTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = selfTeam:getAliveHeroModels(true, true)

            return self:randomElems(teammates, num)
        end,

        [enums.SkillAffectTarget.NRandomEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = enemyTeam:getAliveHeroModels(true, true)

            return self:randomElems(enemies, num)
        end,

        [enums.SkillAffectTarget.NWeakestTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = selfTeam:getAliveHeroModels(true, true)
            table.sort(teammates, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(teammates) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.NWeakestEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = enemyTeam:getAliveHeroModels(true, true)
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(enemies) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,
    }

    local func = AffectTargetFunctionMap[self.skillData.target]
    if func then
        return func()
    else
        return {}
    end
end

function AttackDataModel:calcTrapTargetFighterList()
    local trapModel = self.attacker
    local teamSide = "right" -- 陷阱只可能是防守方

    local targetList = {}

    local enemyTeam = self.battleModel.leftTeam
    local selfTeam  = self.battleModel.rightTeam

    local enemies = enemyTeam:getAliveHeroModels(true, true)
    for _, enemy in ipairs(enemies) do
        local cell = enemy:getCell()
        if trapModel:isCellInTrap(cell) then
           table.insert(targetList, enemy)
        end
    end

    return targetList
end

function AttackDataModel:calcHeroTargetFighterList()
    local Action = BHT.Action.new
    local Condition = BHT.Condition.new
    local Selector = BHT.Selector.new
    local Sequence = BHT.Sequence.new

    local Conditions = BattleHelper.Conditions

    local heroModel = self:getHeroModel()

    local function heroDistance(hero1, hero2)
        local fromCell = hero1:getCell()
        local toCell = hero2:getCell()
        --return math.sqrt((fromCell.x - toCell.x) ^ 2 + (fromCell.y - toCell.y) ^ 2)
        return math.abs(fromCell.x - toCell.x)
        --CCLog(vardump({dis = dis, cell1 = fromCell, cell2 = toCell, hero1 = hero1:getName(), hero2 = hero2:getName()}))
        --return dis
    end


    local teamSide = heroModel:getTeamSide()
    local enemyTeam = nil
    local selfTeam = nil
    if teamSide == "left" then
        selfTeam = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        selfTeam = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    local AffectTargetFunctionMap = {
        [enums.SkillAffectTarget.AllEnemies] = function()
            return self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        end,
        [enums.SkillAffectTarget.AllTeammates] = function()
            return self.attacker:getTeammates({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        end,
        [enums.SkillAffectTarget.Self] = function()
            return {heroModel}
        end,
        [enums.SkillAffectTarget.MatchedEnemy] = function()
            return {heroModel:getMatchedEnemy()}
        end,
        [enums.SkillAffectTarget.RandomEnemy] = function()
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.ScopeEnemies] = function()
            local destCell = self:getDestCell()
            local skillData = self:getSkillData()

            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #enemies
            if len > 0 then
                -- TODO:延迟
                local areaEnemies = self:fightersInInRegionArea(enemies)
                return areaEnemies
            end
            return {}
        end,
        [enums.SkillAffectTarget.ScopeTeammates] = function()
            local skillData = self:getSkillData()
            local teammates = self.attacker:getTeammates({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #teammates
            if len > 0 then
                local areaTeammates = self:fightersInInRegionArea(teammates)
                return areaTeammates
            end
            return {}
        end,
        [enums.SkillAffectTarget.RandomTeamate] = function()
            local enemies = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.MostWeakEnemy] = function()
            local enemies = self.attacker:getEnemies({summon = true, trap = false, isRageSkill = self:isRageSkill()})
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                if p1 == p2 then
                    local hp1 = hero1:getHP()
                    local hp2 = hero2:getHP()
                    return hp1 < hp2
                else
                   return p1 < p2
                end

            end)
            return {enemies[1]}
        end,
        [enums.SkillAffectTarget.MinPercentHPTeammate] = function()
            local enemies = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)
            return {enemies[1]}
        end,
        [enums.SkillAffectTarget.AroundEnemies] = function()
            local skillData = self:getSkillData()

            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #enemies
            if len > 0 then
                -- TODO:延迟
                local areaEnemies = self:fightersInInRegionArea(enemies)
                return areaEnemies
            end
            return {}
        end,
        [enums.SkillAffectTarget.SelectAreaEnemies] = function()
            local destCell = self:getDestCell()
            local skillData = self:getSkillData()

            local teammates = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #teammates
            if len > 0 then
                -- TODO:延迟
                local areaTeammates = self:fightersInInRegionArea(teammates)
                return areaTeammates
            end
            return {}
        end,
        [enums.SkillAffectTarget.DeadTeammate] = function()
            return selfTeam:getDeadHeroModels()
        end,

        [enums.SkillAffectTarget.NRandomTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})

            return self:randomElems(teammates, num)
        end,

        [enums.SkillAffectTarget.NRandomEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            return self:randomElems(enemies, num)
        end,

        [enums.SkillAffectTarget.NWeakestTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})
            table.sort(teammates, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(teammates) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.NWeakestEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(enemies) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.Attacker] = function()
            local result = {}
            if not heroModel:isAlive() then
                local attacker = heroModel._killer
                CCLog(heroModel:getName(), "的凶手为:", attacker and attacker:getName() or "null")
                if attacker then
                    table.insert(result, attacker)
                end
            else
                if #self.originTargetFighterIDList > 0 then
                    local FighterModel = require("scene.battle.model.fighter.FighterModel")

                    local fighterID = self.originTargetFighterIDList[1]
                    local targetFighter = FighterModel.getFighter(fighterID)
                    table.insert(result, targetFighter)
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.FarEnemy] = function()
            local result = {}
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
            if #enemies > 0 then
                table.sort(enemies, function(hero1, hero2)
                    local d1 = heroDistance(heroModel, hero1)
                    local d2 = heroDistance(heroModel, hero2)
                    return d1 > d2
                end)

                table.insert(result, enemies[1])
            end
            return result
        end,
    }

    local func = AffectTargetFunctionMap[self.skillData.target]
    if func then
        return func()
    else
        return {}
    end
end

function AttackDataModel:calcTurretTargetFighterList()
    local Action = BHT.Action.new
    local Condition = BHT.Condition.new
    local Selector = BHT.Selector.new
    local Sequence = BHT.Sequence.new

    local Conditions = BattleHelper.Conditions

    local attacker = self.attacker

    local function heroDistance(hero1, hero2)
        local fromCell = hero1:getCell()
        local toCell = hero2:getCell()
        --return math.sqrt((fromCell.x - toCell.x) ^ 2 + (fromCell.y - toCell.y) ^ 2)
        return math.abs(fromCell.x - toCell.x)
        --CCLog(vardump({dis = dis, cell1 = fromCell, cell2 = toCell, hero1 = hero1:getName(), hero2 = hero2:getName()}))
        --return dis
    end

    local teamSide = attacker:getTeamSide()
    local enemyTeam = nil
    local selfTeam = nil
    if teamSide == "left" then
        selfTeam = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        selfTeam = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    local AffectTargetFunctionMap = {
        [enums.SkillAffectTarget.AllEnemies] = function()
            return self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        end,
        [enums.SkillAffectTarget.AllTeammates] = function()
            return self.attacker:getTeammates({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        end,
        [enums.SkillAffectTarget.Self] = function()
            return {attacker}
        end,
        [enums.SkillAffectTarget.MatchedEnemy] = function()
            return {attacker:getMatchedEnemy()}
        end,
        [enums.SkillAffectTarget.RandomEnemy] = function()
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.ScopeEnemies] = function()
            local destCell = self:getDestCell()
            local skillData = self:getSkillData()

            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #enemies
            if len > 0 then
                -- TODO:延迟
                local areaEnemies = self:fightersInInRegionArea(enemies)
                return areaEnemies
            end
            return {}
        end,
        [enums.SkillAffectTarget.ScopeTeammates] = function()
            local skillData = self:getSkillData()

            local teammates = self.attacker:getTeammates({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #teammates
            if len > 0 then
                -- TODO:延迟
                local areaTeammates = self:fightersInInRegionArea(teammates)
                return areaTeammates
            end
            return {}
        end,
        [enums.SkillAffectTarget.RandomTeamate] = function()
            local enemies = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})
            local len = #enemies
            if len > 0 then
                local randomEnemy = enemies[self.battleModel:random(1, len)]
                return {randomEnemy}
            end
            return {}
        end,
        [enums.SkillAffectTarget.MostWeakEnemy] = function()
            local enemies = self.attacker:getEnemies({summon = true, trap = false, isRageSkill = self:isRageSkill()})
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                if p1 == p2 then
                    local hp1 = hero1:getHP()
                    local hp2 = hero2:getHP()
                    return hp1 < hp2
                else
                    return p1 < p2
                end

            end)
            return {enemies[1]}
        end,
        [enums.SkillAffectTarget.MinPercentHPTeammate] = function()
            local enemies = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)
            return {enemies[1]}
        end,
        [enums.SkillAffectTarget.AroundEnemies] = function()
            local destCell = attacker:getCell()
            local skillData = self:getSkillData()

            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            local len = #enemies
            if len > 0 then
                -- TODO:延迟
                local areaEnemies = self:fightersInInRegionArea(enemies)
                return areaEnemies
            end
            return {}
        end,
        [enums.SkillAffectTarget.SelectAreaEnemies] = function()
            local destCell = self:getDestCell()
            local skillData = self:getSkillData()

            local teammates = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

             local len = #teammates
            if len > 0 then
                -- TODO:延迟
                local areaTeammates = self:fightersInInRegionArea(teammates)
                return areaTeammates
            end
            return {}
        end,
        [enums.SkillAffectTarget.DeadTeammate] = function()
            return selfTeam:getDeadHeroModels()
        end,

        [enums.SkillAffectTarget.NRandomTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})

            return self:randomElems(teammates, num)
        end,

        [enums.SkillAffectTarget.NRandomEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})

            return self:randomElems(enemies, num)
        end,

        [enums.SkillAffectTarget.NWeakestTeamates] = function()
            local num = self.skillData.targetNum
            local teammates = self.attacker:getTeammates({summon = false, trap = false, isRageSkill = self:isRageSkill()})
            table.sort(teammates, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(teammates) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.NWeakestEnemies] = function()
            local num = self.skillData.targetNum
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
            table.sort(enemies, function(hero1, hero2)
                local p1 = hero1:getHPPercent()
                local p2 = hero2:getHPPercent()
                return p1 < p2
            end)

            local result = {}
            for idx, hero in ipairs(enemies) do
                table.insert(result, hero)

                if idx >= num then
                    break
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.Attacker] = function()
            local result = {}
            if not attacker:isAlive() then
                local attacker = attacker._killer
                CCLog(attacker:getName(), "的凶手为:", attacker and attacker:getName() or "null")
                if attacker then
                    table.insert(result, attacker)
                end
            else
                if #self.originTargetFighterIDList > 0 then
                    local FighterModel = require("scene.battle.model.fighter.FighterModel")

                    local fighterID = self.originTargetFighterIDList[1]
                    local targetFighter = FighterModel.getFighter(fighterID)
                    table.insert(result, targetFighter)
                end
            end
            return result
        end,

        [enums.SkillAffectTarget.FarEnemy] = function()
            local result = {}
            local enemies = self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
            if #enemies > 0 then
                table.sort(enemies, function(hero1, hero2)
                    local d1 = heroDistance(attacker, hero1)
                    local d2 = heroDistance(attacker, hero2)
                    return d1 > d2
                end)

                table.insert(result, enemies[1])
            end
            return result
        end,
    }

    local func = AffectTargetFunctionMap[self.skillData.target]
    if func then
        return func()
    else
        return {}
    end
end

function AttackDataModel:calcHatredTargetFighterList()
    local attacker = self.attacker

    local teamSide = attacker:getTeamSide()
    local enemyTeam = nil
    local selfTeam = nil
    if teamSide == "left" then
        selfTeam = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        selfTeam = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    local AffectTargetFunctionMap = {
        [enums.SkillAffectTarget.AllEnemies] = function()
            return self.attacker:getEnemies({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        end,
        [enums.SkillAffectTarget.AllTeammates] = function()
            return self.attacker:getTeammates({summon = true, trap = true, isRageSkill = self:isRageSkill()})
        end,
    }

    local func = AffectTargetFunctionMap[self.skillData.target]
    if func then
        return func()
    else
        return {}
    end
end

function AttackDataModel:getRegionCenterCell()
    local heroModel = self:getHeroModel()

    if self.skillData.affect == enums.SkillAffectType.HatredTarget then
        local cell = self:absRegionRectCenterCell()
        return cell
    else
        return self:calcHeroOptimalDestCell()
    end
    -- elseif self:targetIsTeammate() then
    --     return heroModel:getCell()
    -- else
    --     local enemyModel = heroModel:getMatchedEnemy()
    --     if enemyModel then
    --         return enemyModel:getCell()
    --     else
    --         local targetList = self:getTargetFighterList()
    --         if #targetList > 0 then
    --             return targetList[1]:getCell()
    --         else
    --             return heroModel:getCell()
    --         end
    --     end
    -- end
end

--function AttackDataModel:calcAbsScope(region, direction, heroCell)
--    local attackScope = {}
--    if direction == "right" then
--        for y, xrange in pairs(region) do
--            local absY = y + heroCell.y
--
--            if absY >= 1 and absY <= BattleConfig.Y_CELL_COUNT then
--                attackScope[y + heroCell.y] = {start = heroCell.x + xrange.start, len = xrange.len }
--            end
--        end
--    else
--        for y, xrange in pairs(region) do
--            local absY = y + heroCell.y
--            if absY >= 1 and absY <= BattleConfig.Y_CELL_COUNT then
--                attackScope[y + heroCell.y] = {start = heroCell.x - xrange.start - xrange.len + 1, len = xrange.len }
--            end
--        end
--    end
--    CCLog(vardump(attackScope, "region"))
--
--    return attackScope
--end

function AttackDataModel:absRegionRect()
    local heroModel = self:getHeroModel()
    local skillData = self.skillData

    local rect = heroModel:getAbsSkillRegionRect(skillData.type)

    if rect == nil then
        local region = BattleUtils.getSkillRegion(skillData.id)
        local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
        local cell = heroModel:getCell()
        local direction = heroModel:getDirection()
        rect = BattleHeroModel.compute_abs_region_rect(cell, direction, region)
    end

    if self.skillData.target == enums.SkillAffectTarget.AroundEnemies then
        if heroModel:getDirection() == "right" then
            rect = cc.rect(rect.x - rect.width / 2, rect.y, rect.width, rect.height)
        else
            rect = cc.rect(rect.x + rect.width / 2, rect.y, rect.width, rect.height)
        end
    elseif self.skillData.target == enums.SkillAffectTarget.ScopeEnemies then
        local enemy = heroModel:getMatchedEnemy()

        if enemy then
            local centerPos = enemy:getCellPos()
            rect = cc.rect(centerPos.x - rect.width / 2, centerPos.y - rect.height / 2, rect.width, rect.height)
        end
    end

    return rect
end

function AttackDataModel:absRegionRectCenterCell()
    local heroModel = self:getHeroModel()
    local skillData = self.skillData

    local rect = heroModel:getAbsSkillRegionRect(skillData.type)
    local midX = cc.rectGetMidX(rect)
    local midY = cc.rectGetMidY(rect)

    return BattleConfig.getCellOfPos(midX, midY)
end

function AttackDataModel:skillArea()
    if self._skillAreaBitmap == nil then
        local areaInfo = assert(BattleUtils.getSkillArea(self.skillID), self.skillID)

        local bitmap = bitarray2d.new(areaInfo.width, areaInfo.height)
        bitmap:frombytes(areaInfo.bitmap)
        self._skillAreaBitmap = bitmap
    end

    return self._skillAreaBitmap
end

function AttackDataModel:absArea()
    local heroModel = self:getHeroModel()
    local areaInfo = BattleUtils.getSkillArea(self.skillID)

    local destPos = self:getDestPos()

    local bitmap = self:skillArea():clone()

    if heroModel:getDirection() == "left" then
        bitmap:flipX()
    end

    local max_width = math.max(BattleConfig.BATTLE_WIDTH, areaInfo.width)
    local max_height = math.max(BattleConfig.BATTLE_HEIGHT, areaInfo.height)
    
    bitmap:resize(max_width, max_height)
    bitmap:move(destPos.x - areaInfo.width / 2, destPos.y - areaInfo.height / 2)
    bitmap:resize(BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)

    return bitmap
end

--function AttackDataModel:absAreaInRegion()
--    local areaInfo = BattleUtils.getSkillArea(self.skillID)
--    local destCell = self:getDestCell()
--    local cellPos = BattleConfig.getCellPos(destCell.x, destCell.y)
--
--    local bitmap = self:skillArea()
--    bitmap:resize(BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)
--    bitmap:move(cellPos.x - areaInfo.width / 2, cellPos.y - areaInfo.height / 2)
--
--    local regionRect = self:absRegionRect()
--    print("attacker:", self.attacker:getName())
--    print("region:", vardump(regionRect))
--    print("area:", bitmap:tohex())
--    bitmap:clearOutOfRect(regionRect.x, regionRect.x, regionRect.width, regionRect.height)
--    print("areaInRegion:", bitmap:tohex())
--    return bitmap
--end

function AttackDataModel:fightersInInRegion(fighters)
    local regionRect = self:absRegionRect()

    local targetFighterList = {}
    for _, fighter in ipairs(fighters) do
        if fighter:cellPosInRect(regionRect) then
            table.insert(targetFighterList, fighter)
        end
    end
    return targetFighterList
end

function AttackDataModel:fightersInInRegionArea(fighters)
    local regionRect = self:absRegionRect()
    local areaBitmap = self:absArea()

    CCLog(vardump(regionRect, "regionRect"))
    local targetFighterList = {}
    for _, fighter in ipairs(fighters) do
        if fighter:cellPosInRect(regionRect) and fighter:cellPosInBitmap(areaBitmap) then
            table.insert(targetFighterList, fighter)
        end
    end
    return targetFighterList
end

-- function AttackDataModel:fightersInInRegionAreaLog(fighters)
--     local regionRect = self:absRegionRect()
--     local areaBitmap = self:absArea()

--     CCLog(vardump({#fighters, regionRect, self.attacker:getCellPos(), areaBitmap:tohex()}, "fightersInInRegionAreaLog"))
--     local targetFighterList = {}
--     for _, fighter in ipairs(fighters) do
--         local inRect = fighter:cellPosInRect(regionRect) 
--         local inBitmap = fighter:cellPosInBitmap(areaBitmap) 

--         CCLog(vardump({inRect = inRect, inBitmap = inBitmap, pos = fighter:getCellPos(), fighter = fighter:getName()}))
--         if inRect and inBitmap then
--             table.insert(targetFighterList, fighter)
--         end
--     end
--     return targetFighterList
-- end

-- ID
function AttackDataModel:getSkillID()
    return self.skillID
end

function AttackDataModel:getSkillLevel()
    return self.skillLevel
end

function AttackDataModel:getName()
    return self.skillData.name
end

function AttackDataModel:getSkillData()
    return self.skillData
end

function AttackDataModel:getHeroModel()
    if self:getAttackerType() == "hero" then
        return self.attacker
    else
        CCLog(string.format("error: %s's attacker is not hero", self:getAttackerType()))
        CCLogCaller(4)
        return nil
    end
end

function AttackDataModel:generateFormulaParams(enemyModel)
    local defenderParams = nil
    local toCell = enemyModel and enemyModel:getCell() or self.attacker:getCell()
    if enemyModel then
        defenderParams = enemyModel:getFormulaParams()
    else
        enemyModel = {}
    end

    if self:attackerIsHero() then
        local heroModel = self:getHeroModel()
        local attackerParams = heroModel:getFormulaParams()
        local comboHit = 0
        local restraint = ElemType.damageRestraint
        local fromCell = heroModel:getCell()
        local dist = math.sqrt((fromCell.x - toCell.x) ^ 2 + (fromCell.y - toCell.y) ^ 2)

        local params = {
            A = attackerParams,
            D = defenderParams,
            skillLV = self.skillLevel,
            restraint = restraint,
            dist = dist,
            MAX = math.max,
            MIN = math.min,
        }

        return params
    elseif self:attackerIsInstance() then
        local attackerParams = self.battleModel:getFormulaParams()
        local comboHit = 0
        local restraint = ElemType.damageRestraint
        local fromCell = toCell
        local dist = math.sqrt((fromCell.x - toCell.x) ^ 2 + (fromCell.y - toCell.y) ^ 2)

        local params = {
            A = attackerParams,
            D = defenderParams,
            skillLV = self.skillLevel,
            restraint = restraint,
            dist = dist,
            MAX = math.max,
            MIN = math.min,
        }

        return params
    elseif self:attackerIsTrap() then
        CCLog("TODO:")
    elseif self:attackerIsFairy() then
        local comboHit = 0
        local attackerParams = self.attacker:getFormulaParams()
        local restraint = ElemType.damageRestraint

        local params = {
            A = attackerParams,
            D = defenderParams,
            skillLV = self.skillLevel,
            restraint = restraint,
            dist = 1,
            MAX = math.max,
            MIN = math.min,
        }

        return params
    elseif self:attackerIsObstacle() then
        local attackerParams = self.attacker:getFormulaParams()
        local comboHit = 0
        local restraint = ElemType.damageRestraint
        local dist = 1

        local params = {
            A = attackerParams,
            D = defenderParams,
            skillLV = self.skillLevel,
            restraint = restraint,
            dist = dist,
            MAX = math.max,
            MIN = math.min,
        }

        return params
    elseif self:attackerIsTurret() then
        local attackerParams = self.attacker:getFormulaParams()
        local comboHit = 0
        local restraint = ElemType.damageRestraint
        local dist = 1

        local params = {
            A = attackerParams,
            D = defenderParams,
            skillLV = self.skillLevel,
            restraint = restraint,
            dist = dist,
            MAX = math.max,
            MIN = math.min,
        }

        return params
    else
        CCLog("TODO:")
    end
end

-- 计算公式的值
function AttackDataModel:calcSkillAffectValue(target)
    local params = self:generateFormulaParams(target)

    local skillData = self:getSkillData()
    local formulaExpr = BaseConfig.FormulaContent(skillData.formula)
    local formulaFunction = assert(BaseConfig.FormulaFunc(skillData.formula), string.format("formula[%d]:%s", skillData.formula, formulaExpr))
    local affectValue = formulaFunction(params)

    CCLog(vardump({a = self.attacker:getName(), d = target and target:getName() or "nil", ID = skillData.formula, expr = formulaExpr, params = params, result = affectValue}, "formula"))
    return affectValue
end

function AttackDataModel:getSkillAniTime()
    if self:attackerIsHero() then
        if BattleConfig.RAGE_SKILL_PAUSE and self.skillData.type == enums.SkillType.RageSkill then
            -- 怒气技能黑屏，不需要时间
            return 0
        else
            local skillType = self.skillData.type

            if skillType == enums.SkillType.NormAttack and isNormAttackCritical then
                skillType = enums.SkillType.NormAttack_Crit
            end

            local heroModel = self:getHeroModel()            
            return heroModel:getSkillAniTime(skillType)
        end
    else
        return 0
    end
end

function AttackDataModel:getSkillAniDuration()
    if self:attackerIsHero() then
        if BattleConfig.RAGE_SKILL_PAUSE and self.skillData.type == enums.SkillType.RageSkill then
            -- 怒气技能黑屏，不需要时间
            return 0
        else
            local skillType = self.skillData.type

            local heroModel = self:getHeroModel()
            return heroModel:getSkillAniDuration(skillType)
        end
    else
        return 0
    end
end



---- 技能类型
--function AttackDataModel:getSkillType()
--    return self.skillData.type
--end
--
---- 释放方式
--function AttackDataModel:getReleaseMode()
--
--end
--
---- 释放范围
--function AttackDataModel:getReleaseRegion()
--
--end
--
---- 作用范围
--function AttackDataModel:getAffectArea()
--
--end
--
---- 持续类型 （持久，瞬发）
--function AttackDataModel:getDurationMode()
--
--end
--
---- 持续时间
--function AttackDataModel:getDurationTime()
--
--end
--
---- 作用类型
--function AttackDataModel:getAffectType()
--
--end
--
---- 消耗血量
--function AttackDataModel:getConsumeHP()
--
--end
--
---- 消耗怒气
--function AttackDataModel:getConsumeRage()
--
--end
--
---- 获取伤害公式
--function AttackDataModel:getFormula()
--
--end


-- 附加作用类型
function AttackDataModel:getExtraAffectType()
    return self.skillData.extraAffect
end

-- 附加作用概率
function AttackDataModel:getExtraAffectProbability()
    return self.skillData.extraAffectProbability
end

-- 附加作用值
function AttackDataModel:getExtraAffectValue()
    return self.skillData.extraAffectValue
end

AttackDataModel.SkillExtraAffectDescMap = {
    [enums.SkillExtraAffect.Knockback]              = "击退（几格）",
    [enums.SkillExtraAffect.Seckilling]             = "秒杀（血量低于某个百分比",
    [enums.SkillExtraAffect.AddDamage_1]            = "额外伤害1（触发特殊效果时，伤害值=普通效果的公式+额外伤害公式",
    [enums.SkillExtraAffect.DecEnemyRage]           = "减少对方怒气",
    [enums.SkillExtraAffect.IncSelfRage]            = "增加己方怒气",
    [enums.SkillExtraAffect.IncSelfHP]              = "回复自身生命（按造成伤害的万分比回血",
    [enums.SkillExtraAffect.ComboHit]               = "连续攻击（值为次数)",
    [enums.SkillExtraAffect.Bomber]                 = "若目标死亡，周围4格内所有敌方单位受到相同伤害",
    [enums.SkillExtraAffect.ClearDebuff]            = "清除目标身上不利状态",
    [enums.SkillExtraAffect.AddDamage_2]            = "额外伤害2（触发特殊效果时，伤害值=额外伤害公式）",
    [enums.SkillExtraAffect.Replication]            = "分身（1-10级分身数位1,11-20级分身数位2,21级以上分身数位3  分身持续",
    [enums.SkillExtraAffect.ExtraDamageForMale]     = "对男性目标有额外加成（万分比）",
    [enums.SkillExtraAffect.ExtraDamageForFemale]   = "对女性目标有额外加成（万分比）",
    [enums.SkillExtraAffect.TransferDebuff]         = "清除己方单位的不利状态（100%成功），并有一定概率把不理状态转移到对方身上（随机）",
    [enums.SkillExtraAffect.IncMaleBuffSuccessRate] = "提高对男性角色使用buff的成功率",
}

function AttackDataModel:getSkillExtraAffectDesc()
    return AttackDataModel.SkillExtraAffectDescMap[self.skillData.extraAffect] or ""
end

return AttackDataModel
