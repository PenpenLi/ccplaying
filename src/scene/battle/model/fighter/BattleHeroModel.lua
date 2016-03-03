--战斗中的英雄
local FighterModel = require("scene.battle.model.fighter.FighterModel")
local ElemType = require("config.ElemType")
local BuffModel = require("scene.battle.model.skill.BuffModel")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
local BuffManager = require("scene.battle.model.skill.BuffManager")
local HeroSkillManager = require("scene.battle.model.skill.HeroSkillManager")
local AttackingModel = require("scene.battle.model.attack.AttackingModel")
local BattleUtils = require("scene.battle.helper.Utils")
local FollowMagicCircleListModel = require("scene.battle.model.skill.FollowMagicCircleListModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local EasterEggModel = require("scene.battle.model.fighter.EasterEggModel")
-- 取数字的单元数量，大于0返回1， 小于0返回-1
local function sign(num)
    if num < 0 then
        return -1
    elseif num > 0 then
        return 1
    else
        return 0
    end
end

local HERO_MOVE_TRY_LIST = {
-- 所有前进的方向   前    上前       下前       上      下       后上       后下   后
    u_right = {{1,  0}, {1,  1}, {1,  -1}, {0, 1}, {0, -1},  {-1, 1}, {-1, -1}}, {-1, 0},
-- 所有前进的方向   前    下前       上前       下      上       后下       后上   后
    d_right = {{1,  0}, {1, -1}, {1,  -1}, {0, -1}, {0, 1},  {-1, -1}, {-1, 1}}, {-1, 0},

-- 所有前进的方向   前    上前       下前          上      下    后上       后下    后
    u_left = {{-1,  0}, {-1,  1}, {-1,  -1}, {0,  1}, {0, -1}, {1, 1}, {1, -1}}, {1, 0},
-- 所有前进的方向   前    下前       上前       下      上       后下       后上   后
    d_left = {{-1,  0}, {-1, -1}, {-1,   1}, {0, -1}, {0,  1}, {1, -1}, {1, 1}}, {1, 0},
}

-------------------------------------------------------------------------------

local BattleHeroModel = class("BattleHeroModel", FighterModel)


-- 所有状态
BattleHeroModel.STATES = {
    ready  = "待击",
    walk   = "走",
    win    = "胜利",
    dead   = "死亡",
}

function BattleHeroModel:ctor(heroCreateData, team, formAdd)
    BattleHeroModel.super.ctor(self, "hero")

    self.__create_args__ = {heroCreateData = heroCreateData, team = team, formAdd = formAdd}
    self._formIndex = heroCreateData.index or 1

    --CCLog(vardump({heroData = heroCreateData, team, formAdd}, "BattleHeroModel:ctor"))
    self._heroId = assert(heroCreateData.data.ID, "heroID")
    self._view = nil
    self._battleModel = team.battleModel

    self._direction = "right"   -- 方向 (人脸朝向, left, right)
    self._lastState = "none"
    self._state = "none"        -- 状态
    self._team = team
    self._teamSide = assert(team:getSide(), "teamSide")        -- 队伍方向(left, right)
    self._cell = nil            -- 单元格位置
    self._nextCell = nil        -- 准备移动到的单元格
--    self._movingToPosArray = nil
--    self._movingToPosIndex = 1

    self._movingToCell = nil  -- 正在移动到的Cell
    self._movingFromPos = nil -- 当前移动的开始位置
    self._movingToPos  = nil  -- 正在移动到的位置
    --self._movingCellLine = nil  -- 正在移动到的Cell的中线位置(过线Cell为目标cell)
    self._currentPos  = nil  -- 上次移动到的位置

    self._lastMoveY = 0 -- 上次移动的竖向方向
    self._pushedToCell = nil

    self._eventDispatcher = nil -- 事件分发事
    self._bhtRoot = self:createBehaviourTree()  -- 行为树
    self._matchedEnemy = nil     -- 锁定的敌人
    --self._matchedObstacle = nil  -- 锁定的障碍物

    --self._relativeAttackScope = nil
    self._attackScope = nil
    self._rageSkillID = nil
    self._rageSkillQueue = {}
    self._moveForMomentData = nil -- 

    -- 被动触发的技能队列
    --self._triggeredSkillQueue = {}

    if heroCreateData.type == "hero" then
        self._isMonster = false
        self._heroData = heroCreateData.data
        self._heroBaseData = BaseConfig.GetHero(self._heroId, 1)
    elseif heroCreateData.type == "monster" then
        self._heroData = BattleUtils.monsterToHeroData(heroCreateData.data)
        self._heroBaseData = BattleUtils.monsterToHeroBaseData(heroCreateData.data)
        self._isMonster = true
        CCLog(vardump({heroData = self._heroData, heroBaseData = self._heroBaseData, monster = heroCreateData.data}, "Monster To Hero"))
    else
        assert(false, "unknown heroData type" .. tostring(heroCreateData.type))
    end
    self._attrAdd = self:calcAddition(self._heroData, self._heroBaseData, formAdd or {})

    assert(self._heroData.HP > 0, "hero's hp " .. self._heroData.HP)
    self._currentHP = self._heroData.HP + self._attrAdd.HP
    self._previousHP = self._currentHP
    self._lowestHP = self._currentHP   -- 历史最低血量
    self._stuck = nil -- 卡死在悬崖上了

    local skills = {}

    local skillLevelAdded = self._heroData.RPLevelAdd or 0
    skills.normAttack  = assert(BaseConfig.GetHeroSkill(self._heroBaseData.atkSkill, 1))
    if self._heroBaseData.norSkill then
        skills.normSkill = BaseConfig.GetHeroSkill(self._heroBaseData.norSkill, self._heroData.NorSkillLevel + skillLevelAdded)
    end
    
    if self._heroBaseData.rpSkill then
        skills.rageSkill   = BaseConfig.GetHeroSkill(self._heroBaseData.rpSkill , self._heroData.RPSkillLevel + skillLevelAdded)
--        if skills.rageSkill then
--            self._rageScopeRange = self:calcRegionRageSkillScopeRange(skills.rageSkill)
--        end
    end
    
    if self._heroBaseData.tfSkill then
        skills.innateSkill = BaseConfig.GetHeroSkill(self._heroBaseData.tfSkill, self._heroData.TFSkillLevel + skillLevelAdded)
    end

    -- buff 血量总量提升
    self._HPCellingUP = 0
    
    self._skillMgr = HeroSkillManager.new(self, self._battleModel, skills)

    -- 相对坐标的攻击范围
    self._rawSkillRegion = {
        [enums.SkillType.NormAttack ] = self:getSkillRegion(skills.normAttack),
        [enums.SkillType.NormSkill  ] = self:getSkillRegion(skills.normSkill),
        [enums.SkillType.RageSkill  ] = self:getSkillRegion(skills.rageSkill),
        [enums.SkillType.InnateSkill] = self:getSkillRegion(skills.innateSkill),
    }

    CCLog(vardump(self._rawSkillRegion, "RawSkillRegion"))

    -- 绝对坐标的攻击范围(坐标变化后实时更新)
    self._absSkillRegionRect = {
        [enums.SkillType.NormAttack ] = nil,
        [enums.SkillType.NormSkill  ] = nil,
        [enums.SkillType.RageSkill  ] = nil,
        [enums.SkillType.InnateSkill] = nil,
    }

    self._buffMgr = BuffManager.new(self)
    self._magicCircleList = nil      -- 魔法阵
    self._continuousSkillModel = nil                           -- 持续施法
    self._continuousHitCount = 0
    self._continuousSkillEndCallback = nil
    self._inRageScopeSelecting = false

    self._comboHitModel = nil

    self._attackingModel = AttackingModel.new(self)

    --[[
     idle   = 空闲,
     walk   = 走,
     move   = 走+移动,
     ready  = 待击,
     attack = 攻击,
     hit    = 被击,
     win    = 胜利,
     dead   = 死亡，
    --]]

    self._state = "idle"
    self._status = {
    }

    self._skillAniTimeMap = nil

    self._moveThread = coroutine.create(handler(self, self.moveUpdate))

    self._aiThreadList = nil -- AI相关的协程
    self._killer = nil       -- 杀死自己的凶手
    self._egg = nil

    self._cellChanged = false
    -- 缓存的行走速度
    self._cachedMoveSpeed = {
        cached = false,
        x   = nil,
        y   = nil,
    }
    self.cache = {}
end

function BattleHeroModel:getSkillRegion(skillData)
    if skillData == nil then
        return nil
    end

    local region = BattleUtils.getSkillRegion(skillData.id)

    return region
end

-- local function compute_abs_region_rect(cell, direction, region)
--     if region == nil then
--         return nil
--     end

--     -- 全屏还计算什么呢
--     if region.full then
--         return cc.rect(0, 0, BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)
--     end

--     local rect = nil
--     local cellPos = BattleConfig.getCellPos(cell.x, cell.y)

--     local cx = cellPos.x
--     local cy = cellPos.y - region.height / 2
--     local width = region.width
--     local height = region.height

--     if direction == "right" then
--         if region.sym then
--             cx = cx - width
--             width = width * 2
--         else
--             cx = cx - width / 2
--         end

--         rect = cc.rect(cx, cy, width, height)
--     elseif direction == "left" then       
--         if region.sym then
--             cx = cx - width
--             width = width * 2
--         else
--             cx = cx - width / 2
--         end

--         rect = cc.rect(cx, cy, width, height)
--     else
--         assert(false, "direction:" .. tostring(direction))
--     end

--     return rect
-- end

function BattleHeroModel.compute_abs_region_rect(cell, direction, region)
    if region == nil then
        return nil
    end

    -- 全屏还计算什么呢
    if region.full then
        return cc.rect(0, 0, BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)
    end

    local rect = nil
    local cellPos = BattleConfig.getCellPos(cell.x, cell.y)

    local cx = cellPos.x
    local cy = cellPos.y - region.height / 2
    local width = region.width
    local height = region.height

    if direction == "right" then
        if region.sym then
            cx = cx - width
            width = width * 2
        end

        rect = cc.rect(cx, cy, width, height)
    elseif direction == "left" then
        cx = cx - width
        if region.sym then
            width = width * 2
        end

        rect = cc.rect(cx, cy, width, height)
    else
        assert(false, "direction:" .. tostring(direction))
    end

    return rect
end

function BattleHeroModel:rebuildAbsSkillRegionRect()
    local cell = self._cell
    local direction = self._direction

    if cell == nil or direction == nil then
        return
    end

    self._absSkillRegionRect = {
        [enums.SkillType.NormAttack ] = BattleHeroModel.compute_abs_region_rect(cell, direction, self._rawSkillRegion[enums.SkillType.NormAttack]),
        [enums.SkillType.NormSkill  ] = BattleHeroModel.compute_abs_region_rect(cell, direction, self._rawSkillRegion[enums.SkillType.NormSkill]),
        [enums.SkillType.RageSkill  ] = BattleHeroModel.compute_abs_region_rect(cell, direction, self._rawSkillRegion[enums.SkillType.RageSkill]),
        [enums.SkillType.InnateSkill] = BattleHeroModel.compute_abs_region_rect(cell, direction, self._rawSkillRegion[enums.SkillType.InnateSkill]),
    }

    local bulk = self:getBulk()

    if bulk >= 2 then
        local extra_width = (bulk - 1) * BattleConfig.CELL_WIDTH
        local rect = self._absSkillRegionRect[enums.SkillType.NormAttack]
        if direction == "right" then
            rect.width = rect.width + extra_width
        else
            rect.width = rect.width + extra_width
            rect.x = rect.x - extra_width
        end
    end
end

function BattleHeroModel:getAbsSkillRegionRect(skillType)
    return self._absSkillRegionRect[skillType]
end

function BattleHeroModel:getRawSkillRegion(skillType)
    return self._rawSkillRegion[skillType]
end

function BattleHeroModel:getSkinInfo()
    if not self._isMonster then
        local equipInfo = self._heroData.Equip 

        if equipInfo then
            local SkinType = {["ARM"] = 1, ["HAT"] = 2, ["COAT"] = 4}

            local skinInfo = { 
                ["Arm"]  = equipInfo[SkinType.ARM].SkinID, 
                ["Hat"]  = equipInfo[SkinType.HAT].SkinID, 
                ["Coat"] = equipInfo[SkinType.COAT].SkinID,
            }

            return skinInfo
        else
            return { 
                ["Arm"]  = 0, 
                ["Hat"]  = 0, 
                ["Coat"] = 0,
            }
        end
    else
        local equipInfo = self._heroData.equip or {}

        local skinInfo = { 
            ["Arm"]  = equipInfo[1], 
            ["Hat"]  = equipInfo[2], 
            ["Coat"] = equipInfo[3],
        }

        return skinInfo
    end    
end

function BattleHeroModel:getViewInfo()
    return {
        fighterID = self:getFighterID(),
        name = self:getName(),
        moveMode = self:getHeroMoveMode(),
        isReplication = false,
        teamSide = self:getTeamSide(),
        direction = self:getDirection(),
        heroID = self:getHeroID(),
        heroRes = self:getHeroRes(),
        isMonster = self:isMonster(),
        isBoss = self:isBoss(),
        scale = self:getHeroScale(),
        skinInfo = self:getSkinInfo(),
        fullHP = self:getFullHP(),
        starLevel = self._heroBaseData.starLevel,
    }
end

--- begin FighterModel 虚函数 -------
function BattleHeroModel:isAttackableType()
    return true
end

function BattleHeroModel:isHittableType()
    return true
end

function BattleHeroModel:isMovableType()
    return true
end

function BattleHeroModel:isMissable()
    return true
end

function BattleHeroModel:isHittable()
    return self._buffMgr:heroCanHit()
end

function BattleHeroModel:canMatched()
    if self._egg then
        return false
    end

    local buffMgr = self._buffMgr
    if buffMgr:hasAffect(enums.BuffAffectType.Shackle) then
        return false
    end

    return true
end

function BattleHeroModel:getFormulaParams()
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

    local heroSkillReduction = self._heroData.SkillReduction or 0
    local heroTreatedAddition = self._heroData.TreatedAddition or 0

    local team = self._team

    local damageAddition           = self._buffMgr:getDamageAddition()     / 10000
    local damageReduction          = self._buffMgr:getDamageReduction()    / 10000
    local skillAddition         = self._buffMgr:getSkillAddition()   / 10000
    local skillReduction        = (self._buffMgr:getSkillReduction() + heroSkillReduction) / 10000
    local treatmentAddition     = self._buffMgr:getTreatmentAddition() / 10000
    local treatedAddition       = (self._buffMgr:getTreatedAddition() + heroTreatedAddition) / 10000
    local treatmentReduction    = self._buffMgr:getTreatmentReduction() / 10000
    local treatedReduction      = self._buffMgr:getTreatedReduction() / 10000
    local specDamageAddition    = self._buffMgr:getSpecDamageAddition() / 10000
    local specDamageReduction   = self._buffMgr:getSpecDamageReduction() / 10000    
    local elemType              = self:getElemType()
    local comboHit              = math.max(team:getComboHitTimes(elemType) - 1, 0)

    local params = {
        ATK = self:getATK(),
        DEF = self:getDEF(),
        MP = self:getMP(),
        HP = self:getHP(),
        FH = self:getFullHP(),
        heroLV = self:getLevel(),
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
        WX = elemType,
    }

    return params
end

--function BattleHeroModel:calcRegionRageSkillScopeRange(rageSkillData)
--    local scopeRange = nil
--    if rageSkillData.mode == enums.SkillMode.Region then
--        BattleConfig.cellsToRanges(rageSkillData.scope)
--        if #rageSkillData.scope == 0 then
----            scopeRange = {
----                [1] = {start = 1, len = 20},
----                [2] = {start = 1, len = 20},
----                [3] = {start = 1, len = 20},
----                [4] = {start = 1, len = 20},
----                [5] = {start = 1, len = 20 }
----            }
--            scopeRange = nil -- 全屏技能不处理
--        else
--            scopeRange = BattleConfig.cellsToRanges(rageSkillData.scope)
--        end
--    end
--    return scopeRange
--end

function BattleHeroModel:rageSkillTargetInScope(rageSkillData)
    CCLog(self:getName(), "BattleHeroModel:rageSkillTargetInScope")
    if rageSkillData == nil then
        return true
    end


--    local SkillAffectTarget = {
--        AllEnemies = 1,
--        AllTeammates = 2,
--        Self = 3,
--        MatchedEnemy = 4,
--        RandomEnemy = 5,
--        ScopeEnemies = 6,
--        ScopeTeammates = 7,
--        RandomTeamate = 8,
--        MostWeakEnemy = 9,
--        MinPercentHPTeammate = 10,
--        AroundEnemies = 11,
--        SelectAreaEnemies = 12,
--        DeadTeammate = 13,
--        NRandomTeamates = 14,
--        NRandomEnemies = 15,
--        NWeakestTeamates = 16,
--        NWeakestEnemies = 17,
--        Attacker = 18,
--        FarEnemy = 19,
--    }
    local targetType = rageSkillData.target
    local SkillAffectTarget = enums.SkillAffectTarget
    if targetType ~= SkillAffectTarget.ScopeEnemies and
            targetType ~= SkillAffectTarget.ScopeTeammates and
            targetType ~= SkillAffectTarget.AroundEnemies and
            targetType ~= SkillAffectTarget.SelectAreaEnemies
    then
        return true
    end

    local rageRegionRect = self:getAbsSkillRegionRect(enums.SkillType.RageSkill)

    CCLog(vardump(rageRegionRect, "rage region rect"))

    if rageRegionRect == nil then
        CCLog("没有怒气技能？")
        return false
    end

    if rageRegionRect and rageRegionRect.x == 0 and rageRegionRect.y == 0
            and rageRegionRect.width == BattleConfig.BATTLE_WIDTH
            and rageRegionRect.height == BattleConfig.BATTLE_HEIGHT
    then
        CCLog("全屏怒气技能")
        return true
    end

--    if rageScopeBitMap == nil then
--        return true
--    end

--    if self._rageScopeRange == nil then
--        return true
--    end

    if rageSkillData.mode ~= enums.SkillMode.Region then
        return true
    end

    if rageSkillData.target ~= enums.SkillAffectTarget.SelectAreaEnemies then
        return true
    end

    local targetFighterList = nil
    if BattleUtils.skillTargetIsTeammate(rageSkillData.target) then
        targetFighterList = self:getTeammates({summon = true, trap = true, isRageSkill = true})
    else
        targetFighterList = self:getEnemies({summon = true, trap = true, isRageSkill = true})
    end

--    if #targetFighterList > 0 then
--        local attackScope = {}
--        local region = self._rageScopeRange
--        local direction = self._direction
--        local heroCell = self._cell
--
--        if direction == "right" then
--            for y, xrange in pairs(region) do
--                local absY = y + heroCell.y
--
--                if absY >= 1 and absY <= BattleConfig.Y_CELL_COUNT then
--                    attackScope[y + heroCell.y] = {start = heroCell.x + xrange.start, len = xrange.len }
--                end
--            end
--        else
--            for y, xrange in pairs(region) do
--                local absY = y + heroCell.y
--                if absY >= 1 and absY <= BattleConfig.Y_CELL_COUNT then
--                    attackScope[y + heroCell.y] = {start = heroCell.x - xrange.start - xrange.len + 1, len = xrange.len }
--                end
--            end
--        end
--
--        CCLog(vardump(attackScope, "attack scope"))
--        for _, fighter in ipairs(targetFighterList) do
--            if fighter:cellInRange(attackScope) then
--                return true
--            end
--        end
--    end

    if #targetFighterList > 0 then
        --CCLog("rage scope:", rageScopeBitMap:tostring())
        for _, fighter in ipairs(targetFighterList) do
            CCLog(vardump({hero = self:getName(), target = fighter:getName(), rect = rageRegionRect, targetPos = fighter:getCellPos()}, "hero rage target"))
            if fighter:cellPosInRect(rageRegionRect) then
                return true
            end
        end
    end

    return false
end

local function create_action_thread(timeUnits, action)
    return coroutine.create(function()
        for i = 1, timeUnits do
            coroutine.yield()
        end
        action()
    end)
end

function BattleHeroModel:addAction(time, action)
    local timeUnits = math.ceil(time / BattleConfig.TIME_UNIT)
    CCLog(vardump({time = time, timeUnits = timeUnits}, "BattleModel:addAction"))
    if self._aiThreadList == nil then
        self._aiThreadList = {}
    end

    table.insert(self._aiThreadList, create_action_thread(timeUnits, action))
end

function BattleHeroModel:updateAIThreadList()
    local threadList = self._aiThreadList
    if threadList then
        local count = #threadList
        for i = count, 1, -1 do
            local thread = threadList[i]
            coroutine.resume(thread)

            if coroutine.status(thread) == "dead" then
                table.remove(threadList, i)
            end
        end
    end
end

-- 破盾五行 => 法术盾类型
local __elemSheilds = {
    [enums.ElemType.Metal] = enums.BuffAffectType.WoodShield ,
    [enums.ElemType.Wood ] = enums.BuffAffectType.EarthShield,
    [enums.ElemType.Water] = enums.BuffAffectType.FireShield ,
    [enums.ElemType.Fire ] = enums.BuffAffectType.MetalShield ,
    [enums.ElemType.Earth] = enums.BuffAffectType.WaterShield,
}
--function BattleHeroModel:getMagicShieldValue(attackElemType)
--    -- 如果有法术盾并且有可用次数，伤害为0，并用掉一次
--    local buffMgr = self._buffMgr
--    local heroElemType = self:getElemType()
--
--    for restraintElemType, shieldType in pairs(__elemSheilds) do
--        if restraintElemType ~= attackElemType then
--            local formulaID = buffMgr:getAffectValue(shieldType, false)
--            if formulaID > 0 then
--                return formulaID
--            end
--        end
--    end
--
--    return 0
--end

-- returns shieldID, decDamage
function BattleHeroModel:useMagicShieldValue(attackElemType, damage)
    -- 如果有法术盾并且有可用次数，伤害为0，并用掉一次
    local buffMgr = self._buffMgr
    local heroElemType = self:getElemType()

    local total = 0
    for restraintElemType, shieldType in pairs(__elemSheilds) do
        if restraintElemType ~= attackElemType then
            local value = buffMgr:useMagicShieldValue(shieldType, damage)
            total = total + value
        end
    end

    return total
end

function BattleHeroModel:useSpellShield()
    local buffMgr = self._buffMgr

    local shieldType = enums.BuffAffectType.SpellShield
    if buffMgr:hasAffect(shieldType) then
        local spellLeftTimes = buffMgr:getAffectValueLeft(shieldType)
        if spellLeftTimes > 0 then
            buffMgr:decAffectValueLeft(shieldType)
            return true, spellLeftTimes
        end
    end

    return false, 0
end

function BattleHeroModel:isHideTo(heroModel)
    local buffMgr = self._buffMgr

    if buffMgr:hasAffect(enums.BuffAffectType.Hide) then
        if heroModel:restraint(self) then
            return false
        else
            CCLog(heroModel:getName(), "对", self:getName(), "是隐身的")
            return true
        end
    end
    return false
end

function BattleHeroModel:getAntiInjuryRatio()
    local ratio = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AntiInjuryRatio)
    return ratio
end

function BattleHeroModel:getSkillAntiInjuryRatio()
    local ratio = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.SkillAntiInjuryRatio)
    return ratio
end
--- end FighterModel 虚函数 -------

-- 处理忏悔加成
function BattleHeroModel:calcAddition(heroData, heroBaseData, formAdd)
    local addition = {ATK = 0, DEF = 0, HP = 0, MP = 0, HIT = 0, MISS = 0, CRIT = 0, TEN = 0}
    if formAdd and (formAdd.Wx == 0 or formAdd.Wx == heroBaseData.wx) then
        local AtkPer  = formAdd.Atk  or 0
        local DefPer  = formAdd.Def  or 0
        local HitPer  = formAdd.Hit  or 0
        local MissPer = formAdd.Miss or 0
        local CritPer = formAdd.Crit or 0
        local TenPer  = formAdd.Ten  or 0
        local HPPer   = formAdd.HP   or 0

        addition.HP  = math.floor(heroData.HP  * HPPer )
        addition.ATK = math.floor(heroData.Atk * AtkPer)
        addition.DEF = math.floor(heroData.Def * DefPer)

        addition.HIT  = math.floor(heroBaseData.hit  * HitPer )
        addition.MISS = math.floor(heroBaseData.miss * MissPer)
        addition.CRIT = math.floor(heroBaseData.crit * CritPer)
        addition.TEN  = math.floor(heroBaseData.ten  * TenPer )
    end
    CCLog(vardump({raw = formAdd, add = addition, formWx = formAdd.Wx, wx = heroBaseData.wx}, "Form Addition"))

    return addition
end

function BattleHeroModel:setExtraHPAddition(HP)
    self._attrAdd.HP = self._attrAdd.HP + HP
end

function BattleHeroModel:setView(view)
    self._view = view
end

function BattleHeroModel:getView()
    return self._view
end

function BattleHeroModel:getHeroID()
    return self._heroId
end

function BattleHeroModel:getHeroScale()
    local scale = self._heroBaseData.scale
    if scale then
        return scale / 10000
    else
        return 1
    end
end

function BattleHeroModel:getHeroMoveMode()
    local moveMode = self._heroBaseData.move
    if moveMode then
        return moveMode
    else
        return enums.HeroMoveMode.Walk
    end
end

function BattleHeroModel:isMonster()
    return self._isMonster
end

function BattleHeroModel:isBoss()
    return self._heroData.IsBoss == 1
end

function BattleHeroModel:getBulk()
    return self._heroBaseData.Bulk or 1
end

function BattleHeroModel:getName()
    return self._heroBaseData.name
end

function BattleHeroModel:getHeroBaseData()
    return self._heroBaseData
end

function BattleHeroModel:getBorderIcon()
    local borderPath = "image/icon/border/props_border.png"
    if self._heroData.StarLevel then
        borderPath = string.format("image/icon/border/border_star_%d.png", self._heroData.StarLevel)
    end

    return borderPath
end

function BattleHeroModel:getBorderIconName()
    local borderPath = "props_border.png"
    if self._heroData.StarLevel then
        borderPath = string.format("border_star_%d.png", self._heroData.StarLevel)
    end

    return borderPath
end

function BattleHeroModel:rageConsumeRage()
    local rageSkill = self._skillMgr:getRageSkill() or {}
    return rageSkill.consumeRage
end

function BattleHeroModel:rageConsumeHP()
    local rageSkill = self._skillMgr:getRageSkill() or {}
    local hpRatio = rageSkill.consumeHP or 0
    local needHP = hpRatio / 10000.0 * self:getFullHP()
    return needHP
end

function BattleHeroModel:canReleaseRageSkill()
    if self._battleModel:getState() ~= "fight" then
        return false, "in not fight state"
    end

    if self:isInRageScopeSelecting() then
        return false, "in rage scope selecting"
    end

    local needRage = self:rageConsumeRage()
    if type(needRage) ~= "number" then
        return false, "no rage skill"
    end

    local enabled = true
    local reason = nil
    local team = self._team

    if enabled and not (self:isAlive()) then
        enabled = false
        reason = "hero is dead"
    end

    local buffMgr = self._buffMgr
    if buffMgr:hasAffect(enums.BuffAffectType.Shackle) then
        enabled = false
        reason = "shackle"
    end

    if self._moveForMomentData then
        enabled = false
        reason = "press monstr"
    end

    if buffMgr:hasAffect(enums.BuffAffectType.Frozen) then
        enabled = false
        reason = "Frozen"
    end    

    if enabled and self:matchedEnemyIsObstacle() then
        enabled = false
        reason = "has obstacle"
    end

    if self:inSilence() then
        enabled = false
        reason = "has silence debuff"
    end

    if self:inCharm() then
        enabled = false
        reason = "in charm"
    end

    if self:isVertigo() then
        enabled = false
        reason = "in vertigo"
    end

    if self:isSleep() then 
        enabled = false
        reason = "in sleep"
    end

    if enabled and self:rageSkillInCooling() then
        enabled = false
        reason = string.format("rage skill cooling :%0.2f", self._skillMgr.rageSkillModel.coolLeftTime)
    end

    if enabled and team:getRage() < self:rageConsumeRage() then
        enabled = false
        reason = "rage not enough"
    end

    if enabled and self:hasRoadBlockObstacle() then
        enabled = false
        reason = "has read block obstacle"
    end

        --    if enabled and not self:hasMatchedEnemy() then
--        enabled = false
--        reason = "has no enemy"
--    end

    if enabled then
        -- 巨灵神自爆特殊处理，不需要判断
        if self:getHeroID() ~= 1049 then
            local needHP = self:rageConsumeHP()
            local hasHP = self:getHP()
            if needHP > 0 and hasHP <= needHP then
                CCLog(self:getName(), "怒气技能 耗血 血量不足", "needHP:", needHP, "hasHP:", hasHP)
                enabled = false
                reason = "hp not enough"
            end
        end
    end

    if enabled then
        local rageSkill = self:getRageSkill()
        if rageSkill.affect == enums.SkillAffectType.Resurrection then
            if team:getCanReliveCount() <= 0 then
                CCLog(self:getName(), "复活怒气技能没有死人可以复活")
                enabled = false
                reason = "resurrection skill has no dead teammate"
            end
        end

        -- 如果是选择范围的怒气技能
        if enabled then
            if not self:rageSkillTargetInScope(rageSkill) then
                CCLog(self:getName(), "怒气技能范围内没有目标")
                enabled = false
                reason = "region has no target"
            end
        end
    end

    -- TODO:复活
    if not self:isAlive() then
        if self:canResurrect() then
            enabled = true
            reason = nil
        end
    end

    return enabled, reason
end

function BattleHeroModel:pushedToCell(cell)
    local battleModel = self._battleModel
    local mcell = self:getCell()

    local moveX = sign(cell.x - mcell.x)
    local moveY =  sign(cell.y - mcell.y)
    local x = mcell.x + moveX
    local y = mcell.y + moveY

    if not battleModel:isGridUsed(x, y, self) and not battleModel:isGridToBeUse(x, y) then
        self:setState("walk")
        self:setNextStepCell(moveX, moveY)

        self._pushedToCell = cell
    end
end

function BattleHeroModel:tryPushFrontTeammate()
    local teammates = self:getTeammates()

    local frontTeammate = nil
    local mcell = self:getCell()
    local direction = self:getDirection()
    for _, heroModel in ipairs(teammates) do
        local tcell = heroModel:getCell()
        if tcell.y == mcell.y then
            if direction == "right" and mcell.x + 1 == tcell.x then
                frontTeammate = heroModel
            elseif direction == "left" and mcell.x - 1 == tcell.x then
                frontTeammate = heroModel
            end
        end
        if frontTeammate then
            break
        end
    end

    if frontTeammate then
        frontTeammate:pushedToCell(direction == "right" and {x = mcell.x + 2, y = mcell.y} or {x = mcell.x - 2, y = mcell.y})
    end
end

function BattleHeroModel:onStateChange(oldState, newState)
    if newState == "ready" and oldState == "walk" then
       --self:tryPushFrontTeammate()
    end

    self:dispatchEvent(AppEvent.UI.Battle.HeroStateChange, {fighterID = self:getFighterID(), old = oldState, new = newState})
end

function BattleHeroModel:setMoveForMoment(attackData)
    local destCell = attackData:getDestCell()
    self._moveForMomentData = {attackData = attackData, cell = self:getCell()}
    self:clearMoving()
    self:setCellAndUpdatePos(destCell)
    self:dispatchEvent(AppEvent.UI.Battle.TeleportToCell, {status = "begin", fighterID = self:getFighterID(), cell = destCell})

    self:clearCanMoveCache()
end

function BattleHeroModel:clearMoveForMoment()
    self:clearMoving()
    self:setCellAndUpdatePos(self._moveForMomentData.cell)
    self:dispatchEvent(AppEvent.UI.Battle.TeleportToCell, {status = "end", fighterID = self:getFighterID(), cell = self._moveForMomentData.cell})
    self._moveForMomentData = nil

    self:clearCanMoveCache()
end

function BattleHeroModel:moveToPosForMoment(attackData)    
    self:setMoveForMoment(attackData)
end

function BattleHeroModel:improveHPCeiling(ratio)
    local oldHP = self:getHP()
    local curHPPer = self:getHPPercent() / 100.0

    local rawFullHP = self:getRawFullHP()

    local hpCellingUP = math.floor(rawFullHP * (ratio / 10000))
    self._HPCellingUP = self._HPCellingUP + hpCellingUP

    local fullHP = self:getFullHP()
    local hp = math.floor((curHPPer * fullHP) - oldHP)

    self:incHP(hp, true, false)
    CCLog(vardump({ratio = ratio, percent = curHPPer, incHP = hp, rawFullHP = rawFullHP}, self:getName() .. "提升血量上限"))
end

function BattleHeroModel:restoreHPCeiling(ratio)
    local oldHP = self:getHP()
    local curHPPer = self:getHPPercent() / 100.0

    local rawFullHP = self:getRawFullHP()

    local hpCellingUP = math.floor(rawFullHP * (ratio / 10000))
    self._HPCellingUP = self._HPCellingUP - hpCellingUP

    local fullHP = self:getFullHP()
    local hp = math.floor(oldHP - (curHPPer * fullHP))

    self:decHP(hp, true, false)
    CCLog(vardump({ratio = ratio, percent = curHPPer, decHP = hp, rawFullHP = rawFullHP}, self:getName() .. "还原血量上限"))
end

function BattleHeroModel:onBuffAdded(buff)    
    -- 技能打断
    if self._attackingModel:inAttacking() then
        if buff:isBreakOffAttack(self._attackingModel.attackDataModel) then
            self._attackingModel:breakOff()
            self._continuousSkillModel:breakOff()
            self._comboHitModel = nil
            self:clearCanMoveCache()

            CCLog(vardump({skill = self._attackingModel.attackDataModel.skillData.name}, "break attack"))
        end
    end

    local buffData = buff:getBuffData()
    if buffData.affect == enums.BuffAffectType.Charm then
        self:setMatchedEnemy(nil)
    end

    if buffData.affect == enums.BuffAffectType.Shackle then
        local enemyTeam = self:getEnemyTeam()
        enemyTeam:removeMatchedEnemy(self)
    end

    if buffData.affect == enums.BuffAffectType.HPCellingUP then
        self:improveHPCeiling(buffData.value)
    end

    self._cachedMoveSpeed.cached = false -- 还可以更精细一些

    self:dispatchEvent(AppEvent.UI.Battle.BuffAdded, {fighterID = self:getFighterID(), buff = buff:encode()})

    self:clearCanMoveCache()
end

function BattleHeroModel:onBuffRemoved(buff)
    if self._moveForMomentData then
        local moveAttackData = self._moveForMomentData.attackData
        if moveAttackData.skillData.extraAffectValue == buff.buffID then
            self:clearMoveForMoment()
        end
    end

    self:dispatchEvent(AppEvent.UI.Battle.BuffRemoved, {fighterID = self:getFighterID(), buff = buff:encode()})
    
    local buffData = buff:getBuffData()
    if buffData.affect == enums.BuffAffectType.Charm then
        self:setMatchedEnemy(nil)
    end

    if buffData.affect == enums.BuffAffectType.HPCellingUP then
        self:restoreHPCeiling(buffData.value)
    end

    self._cachedMoveSpeed.cached = false -- 还可以更精细一些

    self:clearCanMoveCache()
end

function BattleHeroModel:onBuffReplaced(oldBuff, newBuff)
    self:dispatchEvent(AppEvent.UI.Battle.BuffReplaced, {fighterID = self:getFighterID(), oldBuff = oldBuff:encode(), newBuff = newBuff:encode()})
end

function BattleHeroModel:onContinuousSkillBegin(continuousSkillModel)
    CCLog(self:getName(), "开始持续施法")
--    self:dispatchEvent(AppEvent.UI.Battle.ContinuousSkillBegin, {fighterID = self:getFighterID(),
--        skillID = continuousSkillModel.attackData.skillData.id,
--        skillLV = continuousSkillModel.attackData.skillData.level
--    })

    self:dispatchEvent(AppEvent.UI.Battle.ContinuousSkillBegin, continuousSkillModel.attackData:encode())
end

function BattleHeroModel:onContinuousSkillEnd(continuousSkillModel)
    CCLog(self:getName(), "结束持续施法")
--    self:dispatchEvent(AppEvent.UI.Battle.ContinuousSkillEnd, {fighterID = self:getFighterID(),
--        skillID = continuousSkillModel.attackData.skillData.id,
--        skillLV = continuousSkillModel.attackData.skillData.level
--    })

    self:dispatchEvent(AppEvent.UI.Battle.ContinuousSkillEnd, continuousSkillModel.attackData:encode())

    if self._continuousSkillEndCallback then
        self._continuousSkillEndCallback()
        self._continuousSkillEndCallback = nil
    end
end

function BattleHeroModel:setState(state)
    assert(BattleHeroModel.STATES[state], "state not allowed")
    local old = self._state
    CCLog("BattleHeroModel:setState()", state, "from", old)
    --CCLogCaller(3)
    if old ~= state then
        self._lastState = self._state
        self._state = state

        self:onStateChange(old, state)
    end
end

function BattleHeroModel:getState()
    return self._state
end

function BattleHeroModel:getLastState()
    return self._lastState
end

function BattleHeroModel:isState(state)
    return self._state == state
end

function BattleHeroModel:isMoving()
    return self._state == "walk" and self._movingToPos
end

function BattleHeroModel:isWalking()
    return self._state == "walk"
end

function BattleHeroModel:isIdle()
    return self._state == "idle"
end

function BattleHeroModel:isReady()
    return self._state == "ready"
end

function BattleHeroModel:getDirection()
    return self._direction
end

function BattleHeroModel:inAttacking()
    if self._attackingModel:inAttacking() then
        return true
    elseif self._continuousSkillModel ~= nil then
        return true
    else
        return false
    end
end

-- 处理魅惑状态
function BattleHeroModel:inCharm()
    return self._buffMgr:hasAffect(enums.BuffAffectType.Charm)
end

function BattleHeroModel:inHitting()
    return self:isInHitting() or self:inContinuousHitting()
end

function BattleHeroModel:inContinuousHitting()
    return self._continuousHitCount > 0
end

function BattleHeroModel:incContinuousHitCount()
    self._continuousHitCount = self._continuousHitCount + 1
end

function BattleHeroModel:decContinuousHitCount()
    self._continuousHitCount = self._continuousHitCount - 1
end

function BattleHeroModel:setContinuousSkillEndCallback(callback)
    self._continuousSkillEndCallback = callback
end

function BattleHeroModel:setInRageScopeSelecting(val)
    self._inRageScopeSelecting = val
end

function BattleHeroModel:isInRageScopeSelecting()
    return self._inRageScopeSelecting
end

function BattleHeroModel:protectByturret()
    self:dispatchEvent(AppEvent.UI.Battle.ProtectByturret, {fighterID = self:getFighterID()})

    self:clearCanMoveCache()
end

function BattleHeroModel:loseProtectionOfTurret()
    self:dispatchEvent(AppEvent.UI.Battle.LoseProtectionOfTurret, {fighterID = self:getFighterID()})

    self:clearCanMoveCache()
end

function BattleHeroModel:incHitting()
    FighterModel.incHitting(self)

    if self._hittingCount == 1 then
        self:clearCanMoveCache()
    end
end

function BattleHeroModel:decHitting()
    FighterModel.decHitting(self)

    if self._hittingCount == 0 then
        self:clearCanMoveCache()
    end
end

function BattleHeroModel:canMove()
    if self.cache.canMove == nil then
        self.cache.canMove = self:_canMove()
    end
    return self.cache.canMove
    --return self:_canMove()
end

function BattleHeroModel:clearCanMoveCache()
    self.cache.canMove = nil
end

function BattleHeroModel:_canMove()
    local buffMgr = self._buffMgr
    --	缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
    if buffMgr:hasAffect(enums.BuffAffectType.Entangled) then
        --CCLog("缠绕状态，无法移动")
        return false
    end

    --	定身（无法移动，可以攻击使用技能）
    if buffMgr:hasAffect(enums.BuffAffectType.FixedBody) then
        --CCLog("定身状态，无法移动")
        return false
    end

    -- 禁锢
    if buffMgr:hasAffect(enums.BuffAffectType.Shackle) then
        --CCLog("禁锢状态，无法移动")
        return false
    end

    if self._moveForMomentData then
        --CCLog("镇压状态，无法移动")
        return false
    end

    -- 冰冻
    if buffMgr:hasAffect(enums.BuffAffectType.Frozen) then
        --CCLog("冰冻状态，无法移动")
        return false
    end  

    if self:inAttacking() or self:isInHitting() then
        --CCLog("攻击受击状态，无法移动")
        return false
    end

    if self._team:isProtectedByTurret(self) then
        --CCLog("站在炮台上，无法移动")
        return false
    end

    return true
end

function BattleHeroModel:unableMove()
    return not self:canMove()
end


function BattleHeroModel:canAttack()
    if self:inAttacking() or self:isInHitting()  or self:isMoving() then
        return false
    end

    local buffMgr = self._buffMgr
    if buffMgr:hasAffect(enums.BuffAffectType.Shackle) then
        return false
    end

    if self._moveForMomentData then
        return false 
    end

    if buffMgr:hasAffect(enums.BuffAffectType.Frozen) then
        return false
    end

    return true
end

function BattleHeroModel:unableAttack()
    return not self:canAttack()
end

function BattleHeroModel:isVertigo()
    return self._buffMgr:hasAffect(enums.BuffAffectType.Vertigo)
end

function BattleHeroModel:isSleep()
    return self._buffMgr:hasAffect(enums.BuffAffectType.Sleep)
end

function BattleHeroModel:setDirection(direction)
    assert(direction == "left" or direction == "right")
    local oldDirection = self._direction
    if oldDirection ~= direction then
        self:rebuildAbsSkillRegionRect()
        self:dispatchEvent(AppEvent.UI.Battle.HeroDirectionChange, {fighterID = self:getFighterID(), direction = direction})
    end

    self._direction = direction
end

function BattleHeroModel:getTeamSide()
    return self._teamSide
end

function BattleHeroModel:getTeam()
    return self._team
end

function BattleHeroModel:getEnemyTeam()
    return self._battleModel:getEnemyTeam(self._teamSide)
end

function BattleHeroModel:getEnemies(params)
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

function BattleHeroModel:getTeammates(params)
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

function BattleHeroModel:setTeamSide(side)
    assert(side == "left" or side == "right")
    self._teamSide = side
end

function BattleHeroModel:setCell(cell)
--    if self._cell == nil then
--      CCLog(vardump(cell, "BattleHeroModel:setCell()"), debug.traceback())
--    end

    if not cell then
        local traceback = debug.traceback()
        CCLog("BattleHeroModel:setCell(nil)\n", traceback)
        assert(false, string.format("%s\n:%s", "BattleHeroModel:setCell(nil)\n", traceback))
    end

    if self._currentPos == nil and self._cell ~= nil then
        local mcell = self._cell
        self._currentPos = BattleConfig.getHeroCellPos(mcell.x, mcell.y)
    end

    cell = cell or {}
    local oldCell = self._cell or {}
    self._cell = {x = cell.x, y = cell.y }

    if oldCell.x ~= cell.x or oldCell.y ~= cell.y then
        self:rebuildAbsSkillRegionRect()

        self:dispatchEvent(AppEvent.UI.Battle.HeroCellChanged, {fighterID = self:getFighterID(), old = oldCell, new = cell})
        local enemyTeam = self:getEnemyTeam()
        enemyTeam:onEnemyMoved(self)

        self._cellChanged = true

        local attackRegion = self:getAbsSkillRegionRect(enums.SkillType.NormAttack)
        --CCLog(vardump({region = attackRegion, pos = self:getCellPos(), name = self:getName()},  "attack region"))
    end
    
    self._nextCell = nil
    self._attackScope = nil
end

function BattleHeroModel:setCellAndUpdatePos(cell)
    self:setCell(cell)
    self._currentPos = BattleConfig.getHeroCellPos(cell.x, cell.y)
end

function BattleHeroModel:getCell()
    local cell = self._cell or {}
    return {x = cell.x, y = cell.y}
end

function BattleHeroModel:getLeftFreeCell()
    local battleModel = self._battleModel

    local cell = self._nextCell or self._cell
    local x, y
    for dx = 1, 5 do
        for dy = 0, dx - 1 do
            x = cell.x - dx

            y = cell.y + dy
            if x >= 0 and x < BattleConfig.X_CELL_COUNT and y >= 0 and y < BattleConfig.Y_CELL_COUNT then
                if not battleModel:isGridUsed(x, y) then
                    return {x = x, y = y}
                end
            end

            y = cell.y - dy
            if x >= 0 and x < BattleConfig.X_CELL_COUNT and y >= 0 and y < BattleConfig.Y_CELL_COUNT then
                if not battleModel:isGridUsed(x, y) then
                    return {x = x, y = y}
                end
            end
        end
    end

    return nil
end

function BattleHeroModel:getRightFreeCell()
    local battleModel = self._battleModel

    local cell = self._nextCell or self._cell
    local x, y
    for dx = 1, 5 do
        for dy = 0, dx - 1 do
            x = cell.x + dx

            y = cell.y - dy
            if x >= 0 and x < BattleConfig.X_CELL_COUNT and y >= 0 and y < BattleConfig.Y_CELL_COUNT then
                if not battleModel:isGridUsed(x, y) then
                    return {x = x, y = y}
                end
            end

            y = cell.y + dy
            if x >= 0 and x < BattleConfig.X_CELL_COUNT and y >= 0 and y < BattleConfig.Y_CELL_COUNT then
                if not battleModel:isGridUsed(x, y) then
                    return {x = x, y = y}
                end
            end
        end
    end

    return nil
end

function BattleHeroModel:isCellChanged()
    return self._cellChanged
end

function BattleHeroModel:resetCellChanged()
    self._cellChanged = false
end

function BattleHeroModel:inCellsArea(area)
    local x = self._cell.x
    local y = self._cell.y

    for _, cell in ipairs(area) do
        if cell.x == x and cell.y == y then
            return true
        end
    end

    -- TODO: 占多格的怪物

    return false
end

function BattleHeroModel:cellInBitMap(scopeBitmap)
    local bulk = self:getBulk()
    local cell = self._cell

    if bulk == 2 then
        return scopeBitmap:get(cell.x, cell.y) or 
            scopeBitmap:get(cell.x + 1, cell.y) or 
            scopeBitmap:get(cell.x - 1, cell.y)
    elseif bulk == 3 then
        return  scopeBitmap:get(cell.x, cell.y) or 
                scopeBitmap:get(cell.x, cell.y - 1) or 
                scopeBitmap:get(cell.x, cell.y + 1) or
                scopeBitmap:get(cell.x + 1, cell.y) or
                scopeBitmap:get(cell.x + 1, cell.y - 1) or
                scopeBitmap:get(cell.x + 1, cell.y + 1) or
                scopeBitmap:get(cell.x - 1, cell.y) or
                scopeBitmap:get(cell.x - 1, cell.y - 1) or
                scopeBitmap:get(cell.x - 1, cell.y + 1)
    elseif bulk == 4 then
        return  scopeBitmap:get(cell.x, cell.y) or 
                scopeBitmap:get(cell.x, cell.y - 1) or 
                scopeBitmap:get(cell.x, cell.y + 1) or
                scopeBitmap:get(cell.x, cell.y - 2) or 
                scopeBitmap:get(cell.x, cell.y + 2) or
                scopeBitmap:get(cell.x + 1, cell.y) or
                scopeBitmap:get(cell.x + 1, cell.y - 1) or
                scopeBitmap:get(cell.x + 1, cell.y + 1) or
                scopeBitmap:get(cell.x - 1, cell.y) or
                scopeBitmap:get(cell.x - 1, cell.y - 1) or
                scopeBitmap:get(cell.x - 1, cell.y + 1)
    else
        -- default: 1
        return scopeBitmap:get(cell.x, cell.y)
    end
end

function BattleHeroModel:cellPosInRect(rect)
    local bulk = self:getBulk()
    local cell = self._cell

    if bulk == 2 then       
        return cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y)) or
            cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y)) or
            cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y))
    elseif bulk == 3 then        
        return  cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y - 1)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y + 1)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y - 1)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y + 1)) or 
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y - 1)) or 
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y + 1))
    elseif bulk == 4 then        
        return  cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y - 1)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y + 1)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y - 2)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y + 2)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y - 1)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x + 1, cell.y + 1)) or 
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y)) or
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y - 1)) or 
                cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x - 1, cell.y + 1))
    else
        -- default: 1
        return cc.rectContainsPoint(rect, BattleConfig.getCellPos(cell.x, cell.y))
    end

    return false
end

function BattleHeroModel:cellPosInBitmap(bitmap)
    local function posInBitmap(pos)
        return bitmap:get(pos.x, pos.y)
    end

    local bulk = self:getBulk()
    local cell = self._cell

    if bulk == 2 then
        return posInBitmap(BattleConfig.getCellPos(cell.x, cell.y)) or
            posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y)) or
            posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y))
    elseif bulk == 3 then
        return  posInBitmap(BattleConfig.getCellPos(cell.x, cell.y)) or
                posInBitmap(BattleConfig.getCellPos(cell.x, cell.y - 1)) or
                posInBitmap(BattleConfig.getCellPos(cell.x, cell.y + 1)) or
                posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y)) or
                posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y - 1)) or
                posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y + 1)) or 
                posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y)) or
                posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y - 1)) or 
                posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y + 1))
    elseif bulk == 4 then
        return  posInBitmap(BattleConfig.getCellPos(cell.x, cell.y)) or
                posInBitmap(BattleConfig.getCellPos(cell.x, cell.y - 1)) or
                posInBitmap(BattleConfig.getCellPos(cell.x, cell.y + 1)) or
                posInBitmap(BattleConfig.getCellPos(cell.x, cell.y - 2)) or
                posInBitmap(BattleConfig.getCellPos(cell.x, cell.y + 2)) or
                posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y)) or
                posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y - 1)) or
                posInBitmap(BattleConfig.getCellPos(cell.x + 1, cell.y + 1)) or 
                posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y)) or
                posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y - 1)) or 
                posInBitmap(BattleConfig.getCellPos(cell.x - 1, cell.y + 1))
    else
        -- default: 1
        return posInBitmap(BattleConfig.getCellPos(cell.x, cell.y))
    end

    return false
end

-- function BattleTrapModel:cellInBitMap(scopeBitmap)
--     local startX = self.pos.x
--     local endX = self.pos.x + self.trapData.Range
--     local startY = self.pos.y
--     local endY = self.pos.y + self.trapData.Range

--     for y = startY, endY do
--         for x = startX, endX do
--             if scopeBitmap:get(x, y) then
--                 return true
--             end
--         end
--     end

--     return false
-- end

-- function BattleTrapModel:cellPosInRect(rect)
--     local startX = self.pos.x
--     local endX = self.pos.x + self.trapData.Range
--     local startY = self.pos.y
--     local endY = self.pos.y + self.trapData.Range

--     for y = startY, endY do
--         for x = startX, endX do
--             local pos = BattleConfig.getCellPos(x, y)

--             if cc.rectContainsPoint(rect, pos) then
--                 return true
--             end
--         end
--     end

--     return false
-- end

-- function BattleTrapModel:cellPosInBitmap(bitmap)
--     local startX = self.pos.x
--     local endX = self.pos.x + self.trapData.Range
--     local startY = self.pos.y
--     local endY = self.pos.y + self.trapData.Range

--     for y = startY, endY do
--         for x = startX, endX do
--             local pos = BattleConfig.getCellPos(x, y)

--             if bitmap:get(pos.x, pos.y) then
--                 return true
--             end
--         end
--     end

--     return false
-- end

function BattleHeroModel:setNextCell(cell)
    self._nextCell = {x = cell.x, y = cell.y}
end

function BattleHeroModel:getNextCell()
    return self._nextCell
end

function BattleHeroModel:getElemType()
    return self._heroBaseData.wx
end

function BattleHeroModel:getGender()
    return self._heroBaseData.gender
end

function BattleHeroModel:getElemTypeIcon()
    local wx = self._heroBaseData.wx
    local iconPath = string.format("image/icon/wx/wx_%d.png", wx)
    return iconPath
end

function BattleHeroModel:getElemTypeName()
    return ElemType.typeName(self._heroBaseData.wx)
end

function BattleHeroModel:getElemTypeColor()
    local colors = {
        cc.c3b(255, 255, 255),
        cc.c3b(0x66, 0xCD, 0),
        cc.c3b(50, 50, 50),
        cc.c3b(255, 0, 0),
        cc.c3b(0xFF, 0xB9, 0x0F),
    }
    return colors[self._heroBaseData.wx]
end

function BattleHeroModel:getFightType()
    local attackSkillID = self._heroBaseData.atkSkill
    if attackSkillID == 1001 then
        return "near"
    else
        return "far"
    end
end

-- 五行克制
function BattleHeroModel:restraint(heroModel)
    local myElem = self:getElemType()
    local otherElem = heroModel:getElemType()
    
    return ElemType.restraint(myElem, otherElem)
end

-- 血量
function BattleHeroModel:getHP()
    if self._egg then
        return self._egg:getRageHitTimesLeft()
    end

    return math.floor(self._currentHP)
end

function BattleHeroModel:getLowestHP()
    return self._lowestHP
end

function BattleHeroModel:setHP(hp)
    assert(hp ~= nil and hp >= 0, string.format("Hero[%d:%s] setHP error", self:getHeroID(), self:getName(), tostring(hp)))
    local fullHP = self:getFullHP()
    if hp > fullHP then
        hp = fullHP
    end

    if hp < 0 then
        hp = 0
    elseif hp > self:getFullHP() then
        hp = self:getFullHP()
    end

    self._previousHP = self._currentHP
    self._currentHP = hp

    if self._lowestHP > self._currentHP then
        self._lowestHP = self._currentHP
    end
end

function BattleHeroModel:setRawPartialHP(hp)
    assert(hp ~= nil and hp >= 0, string.format("Hero[%d:%s] setRawPartialHP error", self:getHeroID(), self:getName(), tostring(hp)))

    self:setHP(hp + self._attrAdd.HP)
end

function BattleHeroModel:incHP(hp, triggerEvent, hint)
    assert(hp >= 0)

    -- 禁止回血
    if self._buffMgr:hasAffect(enums.BuffAffectType.DisableHPUP) then
        return
    end 

    hp = math.floor(hp)
    if triggerEvent == nil then
        triggerEvent = true
    end
    hint = tobool(hint)

    local fullHP = self:getFullHP()
    
    self._previousHP = self._currentHP
    self._currentHP = self._currentHP + hp
    if self._currentHP > fullHP then
       self._currentHP = fullHP
    end

    if triggerEvent then
        self:dispatchEvent(AppEvent.UI.Battle.HPChange, {fighterID = self:getFighterID(), percent = self:getHPPercent(), value = hp, curHP = self._currentHP, hint = hint})
    end
end

function BattleHeroModel:decHP(hp, triggerEvent, hint)
    if triggerEvent == nil then
        triggerEvent = true
    end
    hint = tobool(hint)

    hp = math.floor(hp)
    --hp = hp <= 0 and 100 or hp -- TODO:测试
    assert(hp >= 0, string.format("hp %d is not valid", hp))
    self._previousHP = self._currentHP
    self._currentHP = math.floor(self._currentHP - hp)
    if self._currentHP < 0 then
       self._currentHP = 0
    end

    if self._lowestHP > self._currentHP then
        self._lowestHP = self._currentHP
    end

    CCLogf("BattleHeroModel:decHP(%d), left %d", hp, self._currentHP)
    if triggerEvent then
        self:dispatchEvent(AppEvent.UI.Battle.HPChange, {hint = hint, fighterID = self:getFighterID(), percent = self:getHPPercent(), value = -hp, curHP = self._currentHP})
    end

    local fullHP = self:getFullHP()
    if self._currentHP <= fullHP / 2  then
        self._skillMgr:onHeroHPUnderHalf()
    end

    if self._currentHP <= 0 then
        self:die()
    end
end

function BattleHeroModel:hitBy(damage, attacker, hintHPChange)
    if self._currentHP <= damage then
        self._killer = attacker
    end
    if self._egg then
        assert(damage == 1, "蛋痛只能为‘1’")
        self._egg:hitByRageSkill()
        if self._egg:getRageHitTimesLeft() <= 0 then
            self:die()
            self._egg = nil
        end
    else
        self:decHP(damage, true, hintHPChange)
    end
end

function BattleHeroModel:stuck()
    self._previousHP = self._currentHP
    self._currentHP = 0
    self._stuck = true

    self:dispatchEvent(AppEvent.UI.Battle.HeroStuck, {fighterID = self:getFighterID() })
end

function BattleHeroModel:isStucked()
    if self._stuck then
        return true
    end
    return false
end

function BattleHeroModel:die(dispachevent)
    if dispachevent == nil then
        dispachevent = true
    end

    CCLog("BattleHeroModel:die()", self:getName(), self:getTeamSide())
    self._previousHP = self._currentHP
    self._currentHP = 0
    self._continuousHitCount = 0

    self._buffMgr:clear()

    if self._magicCircleList then
        self._magicCircleList:clear()
    end

    self._attackingModel:breakOff()
    self:resetContinuousSkillModel()
    self:clearCanMoveCache()

    for i = #self._summoning, 1, -1 do
        local summonBeast = self._summoning[i]
        summonBeast:die()
    end
    self._aiThreadList = nil

    local eggSkillData = self._skillMgr:getTurnIntoEggSkillData()
    if eggSkillData then
        if self._egg == nil then
            self:turnIntoEgg(eggSkillData)
            return
        else
            self._egg = nil
        end
    end

    self._skillMgr:onHeroDie()

    if dispachevent then
        self:dispatchEvent(AppEvent.UI.Battle.FighterDie, {fighterID = self:getFighterID() })
    end
end

function BattleHeroModel:killedBy(killer)
    CCLog(self:getName(), "被", killer:getName(), "残忍的杀害了")
    self._killer = killer
end

function BattleHeroModel:isEgg()
    return self._egg ~= nil
end

function BattleHeroModel:getFullHP()
    if self._egg then
        return self._egg:getTotalRageHitTimesLeft()
    end

    return self._heroData.HP + self._attrAdd.HP + self._HPCellingUP
end

function BattleHeroModel:getRawFullHP()
    return self._heroData.HP + self._attrAdd.HP
end

function BattleHeroModel:getPreviousHP()
    return self._previousHP
end

function BattleHeroModel:getHPPercent()
    local hp = self:getHP()
    local fullHP = self:getFullHP()
    return hp * 100 / fullHP
end

function BattleHeroModel:getBuffManager()
    return self._buffMgr
end

function BattleHeroModel:getBuffAddition(attrName)
    return 0
end

function BattleHeroModel:getMood()
    local mood = self._heroData.Mood or self._heroData.M or enums.HeroMood.Normal

    return mood
end

--local HeroMood = {
--    Depressed = 1,    -- 沮丧
--    Normal = 2,       -- 普通
--    Excited = 3,      -- 兴奋
--    ExtremelyExcited = 4, -- 亢奋
--}
local __Mood_Add_Map = {
    [enums.HeroMood.Depressed]        = -0.04,
    [enums.HeroMood.Normal]           = 0,
    [enums.HeroMood.Excited]          = 0.04,
    [enums.HeroMood.ExtremelyExcited] = 0.08,
}
function BattleHeroModel:getMoodAddPercent()
    return __Mood_Add_Map[self:getMood()] or 0
end

function BattleHeroModel:isExtremelyExcited()
    return self:getMood() == enums.HeroMood.ExtremelyExcited
end

function BattleHeroModel:getMoodExtraDamageRatio(heroID)
    if not self:isExtremelyExcited() then
        return 0
    end

    local mood = self._heroBaseData.mood
    if mood then
        if mood[1] == heroID then
            return mood[2]
        end
    end

    return 0
end

-- 获取属性：命中
function BattleHeroModel:getHIT()
    local baseHit = self._heroBaseData.hit
    local hitBuffAdd = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddHit)

    return baseHit + hitBuffAdd + self._attrAdd.HIT
end

-- 获取属性：闪避
function BattleHeroModel:getMISS()
    local baseMiss = self._heroBaseData.miss
    local missBuffAdd = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddMiss)

    return baseMiss + missBuffAdd + self._attrAdd.MISS
end

-- 获取属性：暴击
function BattleHeroModel:getCRIT()
    local baseCri = self._heroBaseData.crit
    local criBuffAdd = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddCri)

    return baseCri + criBuffAdd + self._attrAdd.CRIT
end

-- 获取属性：韧性
function BattleHeroModel:getTEN()
    local baseTen = self._heroBaseData.ten
    local tenBuffAdd = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddTen)

    return baseTen + tenBuffAdd + self._attrAdd.TEN
end

-- 获取忏悔:攻击
function BattleHeroModel:getATK()
    --CCLog(vardump({heroData = self._heroData}, "BattleHeroModel:getATK()"))
    local baseAtk = self._heroData.Atk
    local atkBuffAdd = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddATK)
    local atkBuffAddRatio = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddATKRatio)
    
    if self._buffMgr:hasAffect(enums.BuffAffectType.DamageReduction) then
        atkBuffAddRatio = atkBuffAddRatio - 2000
    end

    local deadAddRatio = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddRatioATKByTeammateDie)
    local deadTeammateCount = self._team:getDeadHeroCount()
    local ratoAdd = math.floor(baseAtk * ((atkBuffAddRatio + deadAddRatio * deadTeammateCount) / 10000.0))

    return baseAtk + atkBuffAdd + ratoAdd + self._attrAdd.ATK
end

-- 获取忏悔:防御
function BattleHeroModel:getDEF()
    local baseDef = self._heroData.Def
    local defBuffAdd = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddDEF)
    local defBuffAddRato = self._buffMgr:getCachedAffectValue(enums.BuffAffectType.AddDEFRatio)
    local ratoAdd = math.floor(baseDef * (defBuffAddRato / 10000.0))

    return baseDef + defBuffAdd + ratoAdd + self._attrAdd.DEF
end

function BattleHeroModel:getMP()
    local baseMP = self._heroData.MP
    local mpBuffAdd = 0
    -- TODO:基础属性加BUFF
    return baseMP + mpBuffAdd + self._attrAdd.MP
end

function BattleHeroModel:getLevel()
    return self._heroData.Level
end

function BattleHeroModel:onHit(enemyModel, skillID)
    local skillData = BaseConfig.GetHeroSkill(skillID, 1)
    if skillData.type == enums.SkillType.RageSkill then
        self._skillMgr:onHitByRage(enemyModel)
    end

    if (skillData.Cickflt and skillData.Cickflt > 0) or (skillData.isBreak and skillData.isBreak > 0) then
        self._attackingModel:breakOff()
        if self._continuousSkillModel then 
            self._continuousSkillModel:breakOff()
        end
        self._comboHitModel = nil
        self:clearCanMoveCache()
    end

    self._buffMgr:onHit()
end

-- 敌人死亡事件
function BattleHeroModel:onEnemyDie(heroModel)
    -- TODO:

    self._skillMgr:onEnemyDie(heroModel)
end

-- 队友死亡事件
function BattleHeroModel:onTeammateDie(targetFighter)

end

-- 杀死敌人事件
function BattleHeroModel:onKillEnemy(targetFighter)
    local backHPRatio = self._buffMgr:getAffectValue(enums.BuffAffectType.KillBackHPRatio)
    if backHPRatio ~= 0 then
        local fullHP = targetFighter:getFullHP()

        local hp = fullHP * backHPRatio / 10000
        CCLog(vardump({hp = hp, fullHP = fullHP, backHPRatio = backHPRatio}, "击杀回血"))
        hp = math.max(hp, 1)
        self:incHP(hp, true, true)
    end
end

-- 杀死队友事件
function BattleHeroModel:onKillTeammate(targetFighter)
    -- TODO:
end

function BattleHeroModel:preload()
    self:lookForAliveEnemy()
    self:setNextStepToMatchedEnemy()
end

-- 战斗回合开始
local starLevel_backHPMap = {
    [0] = 0.05,
    [1] = 0.06,
    [2] = 0.06,
    [3] = 0.07,
    [4] = 0.07,
    [5] = 0.08,
    [6] = 0.08,
    [7] = 0.08,
    [8] = 0.09,
    [9] = 0.09,
    [10] = 0.09,
    [11] = 0.09,
    [12] = 0.10,
}
function BattleHeroModel:onBattleRoundStart()
    -- TODO:
    local mcell = self._cell
    self._currentPos  = BattleConfig.getHeroCellPos(mcell.x, mcell.y)

    self._lowsetHP = self._currentHP

    self._skillMgr:onEnterBattle()
    self:setInRageScopeSelecting(false)
end

-- 战斗回合结束
function BattleHeroModel:onBattleRoundEnd()
    -- TODO:
    self:clearMoving()
    self._buffMgr:clear()
    if self._magicCircleList then
        self._magicCircleList:clear()
        self._magicCircleList = nil
    end
    self._attackingModel:breakOff(true)
    self:resetContinuousSkillModel()
    self._comboHitModel = nil
    self._aiThreadList = nil
    self:clearCanMoveCache()

    if self._moveForMomentData then       
        self:clearMoveForMoment() 
    end

    if self:isAlive() and self._battleModel.roundIndex < self._battleModel:getRoundCount() then
        local starLevel = self._heroData.StarLevel or 0
        local backPercent = starLevel_backHPMap[starLevel] or 0.05
        local hp = math.floor(self:getFullHP() * backPercent)
        CCLog(self:getName(), "通关回血:", hp)
        self:treat(nil, hp)
    end
end

-- 获取普通攻击技能
function BattleHeroModel:getNormAttack()
    return self._skillMgr:getNormAttack()
end

-- 获取普通技能
function BattleHeroModel:getNormSkill()
    return self._skillMgr:getNormSkill()
end

-- 获取怒气技能
function BattleHeroModel:getRageSkill()
    return self._skillMgr:getRageSkill()
end

function BattleHeroModel:isTreatRageSkill()
    local rageSkill = self._skillMgr:getRageSkill()
    if rageSkill then
        return rageSkill.affect == enums.SkillAffectType.Treatment
    end

    return false
end


-- 获取天赋技能
function BattleHeroModel:getInnateSkill()
    return self._skillMgr:getInnateSkill()
end

-- 获取普通攻击技能
function BattleHeroModel:_getSkillAniTime(skillType)
    local skillAniNameMap = {
        [enums.SkillType.NormAttack] = "atk1",
        [enums.SkillType.NormAttack_Crit] = "atk2",
        [enums.SkillType.NormSkill] = "atk3",
        [enums.SkillType.RageSkill] = "atk_ko",
        [enums.SkillType.InnateSkill] = "atk3",
    }

    local heroView = self:getView()
    if heroView then
        --return heroView.heroAni:getAnimationDuration(skillAniNameMap[skillType])
        local aniTime = heroView.heroAni:getAnimationEventTime(skillAniNameMap[skillType])
        if aniTime == 0 then
            aniTime = heroView.heroAni:getAnimationDuration(skillAniNameMap[skillType]) / 2
        end

        if skillType == enums.SkillType.NormAttack and self._heroBaseData.attackAnimation then
            aniTime = self._heroBaseData.attackAnimation / 1000.0
        end

        if skillType == enums.SkillType.NormAttack_Crit and self._heroBaseData.critAnimation then
            aniTime = self._heroBaseData.critAnimation / 1000.0
        end

        return aniTime
    end

    return 0.5
end

function BattleHeroModel:_getSkillAniDuration(skillType)
    local skillAniNameMap = {
        [enums.SkillType.NormAttack] = "atk1",
        [enums.SkillType.NormAttack_Crit] = "atk2",
        [enums.SkillType.NormSkill] = "atk3",
        [enums.SkillType.RageSkill] = "atk_ko",
        [enums.SkillType.InnateSkill] = "atk3",
    }

    local heroView = self:getView()
    if heroView then
        local duration = heroView.heroAni:getAnimationDuration(skillAniNameMap[skillType])
        return duration
    end

    return 1
end

function BattleHeroModel:getSkillAniTime(skillType)
    if self._skillAniTimeMap == nil then
        self._skillAniTimeMap = {
            [enums.SkillType.NormAttack] = self:_getSkillAniTime(enums.SkillType.NormAttack),
            [enums.SkillType.NormSkill] = self:_getSkillAniTime(enums.SkillType.NormSkill),
            [enums.SkillType.RageSkill] = self:_getSkillAniTime(enums.SkillType.RageSkill),
            [enums.SkillType.InnateSkill] = 0,
        }
    end

    return self._skillAniTimeMap[skillType] or 0.5
end

function BattleHeroModel:getSkillAniDuration(skillType)
    if self._skillAniDurationMap == nil then
        self._skillAniDurationMap = {
            [enums.SkillType.NormAttack] = self:_getSkillAniDuration(enums.SkillType.NormAttack),
            [enums.SkillType.NormSkill] = self:_getSkillAniDuration(enums.SkillType.NormSkill),
            [enums.SkillType.RageSkill] = self:_getSkillAniDuration(enums.SkillType.RageSkill),
            [enums.SkillType.InnateSkill] = 0,
        }
    end
    --CCLog(vardump(self._skillAniDurationMap, "ani duration"))

    return self._skillAniDurationMap[skillType] or 1.0
end

function BattleHeroModel:isAlive()
    if self._egg then
        return self._egg:isAlive()
    end

    return self._currentHP > 0
end

-- 设置配对的敌人
function BattleHeroModel:setMatchedEnemy(enemy)
    self._matchedEnemy = enemy

    self:clearPath()

    self:dispatchEvent(AppEvent.UI.Battle.Match, {fighterID = self:getFighterID(), enemyFighterID = enemy and enemy:getFighterID() or nil})
end

function BattleHeroModel:getMatchedEnemy()
    if self._matchedEnemy and not self._matchedEnemy:isAlive() then
        self._matchedEnemy = nil
    end

    return self._matchedEnemy
end

--function BattleHeroModel:getMatchedObstacle()
--    if self._matchedObstacle ~= nil and self._matchedObstacle:isDead() then
--        self._matchedObstacle = nil
--    end
--
--    return self._matchedObstacle
--end

function BattleHeroModel:hasMatchedObstacle()
    return self:getMatchedObstacle() ~= nil
end

function BattleHeroModel:clearMatchedEnemy()
    self._matchedEnemy = nil
end

function BattleHeroModel:matchedEnemyIsObstacle()
    if self._matchedEnemy then
        return self._matchedEnemy:getFighterType() == "obstacle"
    end
    return false
end

function BattleHeroModel:isMatchedEnemy(enemy)
    assert(enemy ~= nil)
    return self._matchedEnemy == enemy
end

function BattleHeroModel:hasMatchedEnemy()
    if self._matchedEnemy ~= nil then
        if self._matchedEnemy:isAlive() then
            return true
        else
            self._matchedEnemy = nil
            return false
        end
    else
        return false
    end
end

function BattleHeroModel:hasNoMatchedEnemy()
    return not self:hasMatchedEnemy()
end

--function BattleHeroModel:initRelativeAttackScope()
--    if self._relativeAttackScope == nil then
--        local normAttackSkillID = self._heroBaseData.atkSkill
--
--        local normAttackSkill = BaseConfig.GetHeroSkill(normAttackSkillID, 1)
--
--        local scope = BattleConfig.cellsToRanges(normAttackSkill.scope)
--        self._relativeAttackScope = scope
--    end
--end

--function BattleHeroModel:getAttackScope()
--    if self._attackScope then
--        return self._attackScope
--    else
--        self:initRelativeAttackScope()
--        local scope = self._relativeAttackScope
--
--        if #scope == 0 then
--            return {
--                [1] = {start = 1, len = 20},
--                [2] = {start = 1, len = 20},
--                [3] = {start = 1, len = 20},
--                [4] = {start = 1, len = 20},
--                [5] = {start = 1, len = 20},
--            }
--        else
--            local attackScope = {}
--            local heroCell = self._cell
--            if self._direction == "right" then
--                for y, xrange in pairs(scope) do
--                    attackScope[y + heroCell.y] = {start = heroCell.x + xrange.start, len = xrange.len}
--                end
--            else
--                for y, xrange in pairs(scope) do
--                    attackScope[y + heroCell.y] = {start = heroCell.x - xrange.start - xrange.len + 1, len = xrange.len}
--                end
--            end
--            self._attackScope = attackScope
--
--            return attackScope
--        end
--    end
--end



function BattleHeroModel:triggeredSkill(skillData, targetList)
--    if skillData.extraAffect == enums.SkillExtraAffect.TurnIntoEgg then
--        self:turnIntoEgg(skillData)
--    else
        local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, targetList)
        self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
--    end
end

function BattleHeroModel:delayTriggeredSkill(skillData, targetList)
--    if skillData.extraAffect == enums.SkillExtraAffect.TurnIntoEgg then
--        self:turnIntoEgg(skillData)
--    else
    self._battleModel:addAction(BattleConfig.TIME_UNIT * self._formIndex, function()
        local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, targetList)
        self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
    end)
--    end
end

function BattleHeroModel:hasTriggeredSkill()
    return false -- #self._triggeredSkillQueue > 0
end

function BattleHeroModel:addTriggeredBuff(buff)
    -- TODO:
end

function BattleHeroModel:genAttackSkill()
    -- 生成本次攻击的技能
    return self._skillMgr:genAttackSkill()
end

function BattleHeroModel:inSilence()
    return self._buffMgr:hasAffect(enums.BuffAffectType.Silence)
end

-- 攻击敌人
function BattleHeroModel:attack()
    --CCLog(vardump({name = "attack", from = self:getCell(), to = enemy:getCell()}))
    -- TODO: 魅惑状态攻击队友 无队友不攻击
    if self:inCharm() or self:matchedEnemyIsObstacle() then
        CCLog("处理魅惑状态")

        -- 正常攻击
--        local elemType = self:getElemType()
        local skillData = self:getNormAttack()
        local targetList = {self._matchedEnemy:getFighterID() }
        local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, targetList)

        self:doAttack(attackData)
    else
        -- 正常攻击
--        local elemType = self:getElemType()
        local skillData

--        if #self._triggeredSkillQueue > 0 then
--            skillData = table.remove(self._triggeredSkillQueue, 1)
--        else

        if self:inSilence() then -- 沉默时不能使用技能
            skillData = self:getNormAttack()
        else
            skillData = self:genAttackSkill()
        end

        local targetList = nil
        if skillData.type == enums.SkillType.NormAttack then
            targetList = {self._matchedEnemy:getFighterID() }
        end

        local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, targetList)

        self:doAttack(attackData)
    end

    return true
end

function BattleHeroModel:doSubComboHitAttack(originAttackData)
    local targetList = nil

    local skillData = originAttackData.skillData
    local isNormAttack = skillData.type == enums.SkillType.NormAttack
    if isNormAttack then
        targetList = {self._matchedEnemy:getFighterID() }
    else
        targetFighterList = originAttackData:getTargetFighterList()
        targetList = {}

        for _, fighter in ipairs(targetFighterList) do
            table.insert(targetList, fighter:getFighterID())
        end
    end

    local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, targetList)
    attackData:setIsComboHit(true)
    if isNormAttack then
        attackData:setDestCell(originAttackData:getDestCell())
    end

    self:doAttack(attackData)
end

function BattleHeroModel:doAttack(attackData)
    -- TODO:
    if not self:isAlive() then
        CCLog("已经死了，不能攻击")
        return false
    end

    if true or self:canAttack() then
        if attackData.skillData.type == enums.SkillType.NormAttack then
            -- 预告计算暴击
            attackData:preComputedCrit()
        end

        self._attackingModel:attackBegin(attackData)
        self:onAttackBegin(attackData)
        self:clearCanMoveCache()

        --self:setMatchedEnemy(nil)
        return true
    end
    return false
end

function BattleHeroModel:onAttackComplete(attackData)
    self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())

    self:clearCanMoveCache()
end

function BattleHeroModel:onAttackEnd()
    --self:setState("ready")
end

function BattleHeroModel:onAttackBegin(attackData)
    self._skillMgr:onSkillRelease(attackData.skillData)

    if attackData.skillData.type == enums.SkillType.RageSkill and (not attackData.isComboHit) then
        self._team:decRage(attackData.skillData.consumeRage)
    end

    self:dispatchEvent(AppEvent.UI.Battle.AttackBegin, attackData:encode())
end

function BattleHeroModel:onAttackBreakOff(attackData, quiet)
    self:dispatchEvent(AppEvent.UI.Battle.AttackBreakOff, {attackData = attackData:encode(), quiet = quiet})
    self:setState("ready")

    self:clearCanMoveCache()
end

-- 被击 移到Controller中去了
--function BattleHeroModel:hit(attackData, damage)
----    if not self:hasMatchedEnemy() then
----        self.setMatchedEnemy(attackData:getHeroModel())
----        if not attackData:getHeroModel():hasMatchedEnemy() then
----            attackData:getHeroModel():setMatchedEnemy(self)
----        end
----    end
--
--    local enemy = attackData:getHeroModel()
--    --命中率计算： 命中率=攻方命中值/（攻方命中值+守方闪避值）+攻方基础命中率+攻方阵法命中率-守方阵法闪避率
--    local shooting = enemy:getHIT() / (enemy:getHIT() + self:getMISS()) + 0.28 + 0.0 - 0.0
--    CCLog(vardump({miss = self:getMISS(), hit = enemy:getHIT(), shooting = shooting}, "hit miss"))
--    local randNum = self._battleModel:random()
--    if randNum >= shooting then
--        damage = 0
--        self:dispatchEvent(AppEvent.UI.Battle.MISS, {attackData = attackData, heroModel = self})
--    else
--        -- 如果有法术盾并且有可用次数，伤害为0，并用掉一次
--        if self._buffMgr:hasAffect(enums.BuffAffectType.SpellShield) then
--            local spellLeftTimes = self._buffMgr:getAffectValueLeft(enums.BuffAffectType.SpellShield)
--            if spellLeftTimes > 0 then
--                damage = 0
--                self._buffMgr:decAffectValueLeft(enums.BuffAffectType.SpellShield)
--
--                self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.SpellShield, heroModel = self})
--            end
--        end
--
--        CCLog("BattleHeroModel:hit(" .. damage .. ")")
--        self:dispatchEvent(AppEvent.UI.Battle.Hit, {damage = damage, attackData = attackData, heroModel = self})
--        self:decHP(damage)
--        if not self:isAlive() then
--            self:dispatchEvent(AppEvent.UI.Battle.FighterDie, {heroModel = self})
--        else
--            self:setHitting(true)
--            self._battleModel:addAction(1, function() self:setHitting(false) end)
--        end
--    end
--end

function BattleHeroModel:treat(attackData, hp)
    self:incHP(hp, true, true)
    self:dispatchEvent(AppEvent.UI.Battle.Treated, {fighterID = self:getFighterID(), hp = hp})
end

function BattleHeroModel:canResurrect()
    local team = self._team
    return team:heroCanResurrect(self)
end

function BattleHeroModel:resurrect(attackData, hp)
    self._egg = nil

    assert((self:isEgg()) or (not self:isAlive()), "复活活人" .. self:getName())
    self:setHP(hp)
    self:dispatchEvent(AppEvent.UI.Battle.Resurrection, {fighterID = self:getFighterID(), modelAttr = self:getViewInfo(), teamSide = self:getTeamSide(), hpPercent = self:getHPPercent()})
end

-- 从列表选取对手
local heroMatchCompare = function(heroModelA, heroModelB)
    if heroModelA:getHP() < heroModelB:getHP() then
        return true
    elseif  heroModelA:getHP() == heroModelB:getHP() then
        if heroModelA:getFightType() == "near" then
            return true
        elseif heroModelB:getFightType() == "near" then
            return false
        else
            return true
        end
    end
end

function BattleHeroModel:matchPriority(heroModelList)
    assert(#heroModelList > 0)
    
    for idx, hero in ipairs(heroModelList) do  
        if self:restraint(hero) then
            return hero
        end 
    end
    
    table.sort(heroModelList, heroMatchCompare)
    return heroModelList[1]
end

-- 速度以万为单位
function BattleHeroModel:getAttackSpeed()
    local atkSpeed = self._heroBaseData.atkSpeed

    -- TODO:local atkSpeed = self._heroData.atkSpeed
    return atkSpeed
end

function BattleHeroModel:getBloodSucking()
    return self._heroData.Vampire or 0
end

function BattleHeroModel:getAttackSpeedVar()
    return self._buffMgr:getAttackSpeedVar()
end

function BattleHeroModel:getMoveSpeed()
    if not self._cachedMoveSpeed.cached then
        local baseSpeed = self:getFightType() == "near" and 12000 or 10000

        local speedAdd = self._buffMgr:getMoveSpeedAddition()
        local speedVar = (baseSpeed + speedAdd) / 10000
        local speedX = BattleConfig.HERO_X_SPEED * speedVar
        local speedY = BattleConfig.HERO_Y_SPEED * speedVar

        local offsetX = (BattleConfig.TIME_UNIT * speedX)
        local offsetY = (BattleConfig.TIME_UNIT * speedY)

        self._cachedMoveSpeed.x = offsetX
        self._cachedMoveSpeed.y = offsetY
        self._cachedMoveSpeed.cached = true
    end

    return self._cachedMoveSpeed.x, self._cachedMoveSpeed.y
end

function BattleHeroModel:getMoveVel(targetPos, fromPos)
    if not self._cachedMoveSpeed.cached then
        local baseSpeed = self:getFightType() == "near" and 12000 or 10000

        local speedAdd = self._buffMgr:getMoveSpeedAddition()
        local speedVar = (baseSpeed + speedAdd) / 10000
        local speed = BattleConfig.HERO_X_SPEED * speedVar

        local vel = cc.pMul(pNormalize(cc.pSub(targetPos, fromPos)), speed)
        local unitDistanceSQ = cc.pLengthSQ(cc.pMul(vel, BattleConfig.TIME_UNIT))
        self._cachedMoveSpeed.vel = vel
        self._cachedMoveSpeed.uDisSQ = unitDistanceSQ

        self._cachedMoveSpeed.cached = true
    end

    return self._cachedMoveSpeed.vel, self._cachedMoveSpeed.uDisSQ
end

function BattleHeroModel:inCooling()
    --  特殊处理:银币BOSS 怪物小猪没有攻击
    if self._heroId == 20000001 then
        return true 
    end

    return self._skillMgr:attackInCooling()
end

function BattleHeroModel:rageSkillInCooling()
    return self._skillMgr:rageSkillInCooling()
end

function BattleHeroModel:rageSkillCoolLeftTime()
    return self._skillMgr:rageSkillCoolLeftTime()
end

function BattleHeroModel:rageSkillCoolTime()
    return self._skillMgr:rageSkillCoolTime()
end

-- 敌人是否在攻击范围内
function BattleHeroModel:enemyInAttackScope(enemy)
--    self:initRelativeAttackScope()
--
--    -- 空数组表示所有
--    if #self._relativeAttackScope == 0 then
--        return true
--    end
    
    local ecell = enemy:getCell()
    --local mcell = self._cell

    local attackRegionRect = self:getAbsSkillRegionRect(enums.SkillType.NormAttack)

    if enemy:getFighterType() == "obstacle" then
        for y = 0, BattleConfig.Y_CELL_COUNT - 1 do
            local epos = BattleConfig.getCellPos(ecell.x, y)
            if cc.rectContainsPoint(attackRegionRect, epos) then
                return true
            end
        end
    else
        local epos = BattleConfig.getCellPos(ecell.x, ecell.y)
        --CCLog("enemyInAttackScope", vardump({pos = epos, rect = attackRegionRect}), self:getName(), enemy:getName())
        if cc.rectContainsPoint(attackRegionRect, epos) then
            --CCLog("norm attack contains enemy pos")
            return true
        end

        if enemy:cellPosInRect(attackRegionRect) then
            --CCLog("norm attack contains enemy cells pos")
            return true
        end
    end

    return false
        
--    local offY = ecell.y - mcell.y
--    if enemy:getFighterType() == "obstacle" then
--        offY = 0
--    end
--
--    local xrange = self._relativeAttackScope[offY]
--    if xrange then
--        -- 在右边
--        do
--            local start =  mcell.x + xrange.start
--            local stop = mcell.x + xrange.start + xrange.len - 1
--            if ecell.x >= start and ecell.x <= stop then
--                return true
--            end
--        end
--
--        -- 在左边
--        do
--            local start = mcell.x - xrange.start - xrange.len + 1
--            local stop = mcell.x - xrange.start
--            if ecell.x >= start and ecell.x <= stop then
--                return true
--            end
--        end
--    end
--    return false
end

function BattleHeroModel:matchedEnemyInAttackScope()
    if self._matchedEnemy then
        return self:enemyInAttackScope(self._matchedEnemy)
    else
        return false
    end
end

function BattleHeroModel:matchedEnemyWillInAttackScope()
    CCLog("BattleHeroModel:matchedEnemyWillInAttackScope()")
    if not self._matchedEnemy then
        CCLog("has no matched enemy")
        return false
    end

    local enemy = self._matchedEnemy
    local ecell = enemy:getNextCell()
    if not ecell then
        CCLog("has no next cell")
        return false
    end

    CCLog(vardump({cell = self:getCell(), enemyCell = ecell}))

    local attackRegionRect = self:getAbsSkillRegionRect(enums.SkillType.NormAttack)

    if enemy:getFighterType() == "obstacle" then
        for y = 0, BattleConfig.Y_CELL_COUNT - 1 do
            local epos = BattleConfig.getCellPos(ecell.x, y)
            if cc.rectContainsPoint(attackRegionRect, epos) then
                return true
            end
        end
    else
        local epos = BattleConfig.getCellPos(ecell.x, ecell.y)
        if cc.rectContainsPoint(attackRegionRect, epos) then
            return true
        end
    end

    return false

--
--    self:initRelativeAttackScope()
--
--    -- 空数组表示所有
--    if #self._relativeAttackScope == 0 then
--        return true
--    end

--    local mcell = self._cell
--    local offY = ecell.y - mcell.y
--    local xrange = self._relativeAttackScope[offY]
--    if xrange then
--        do
--            local start =  mcell.x + xrange.start
--            local stop = mcell.x + xrange.start + xrange.len - 1
--            if ecell.x >= start and ecell.x <= stop then
--                return true
--            end
--        end
--
--        do
--            local start = mcell.x - xrange.start - xrange.len + 1
--            local stop = mcell.x - xrange.start
--            if ecell.x >= start and ecell.x <= stop then
--                return true
--            end
--        end
--    end
--    return false
end

function BattleHeroModel:tryMoveToMatchedEnemyRow()
    return self:tryMoveToEnemyRow(self._matchedEnemy)
end

--function BattleHeroModel: nextCellGrow(srcCell, destCell, fightType)
--    if fightType == "near" then
--        local diffX = destCell.x - srcCell.x
--        local diffY = destCell.y - srcCell.y
--        local distanceX = math.abs(diffX)
--        local distanceY = math.abs(diffY)
--        local distance = math.max(distanceX, distanceY)
--
--        local x_ratio =  diffX / distance
--        local y_ratio =  diffY / distance
--
--        local growX = math.floor(x_ratio + 0.5)
--        local growY = math.floor(y_ratio + 0.5)
--
--        return growX, growY
--    else
--        local diffX = destCell.x - srcCell.x
--        local diffY = destCell.y - srcCell.y
--
--        local signX = sign(diffX)
--        local signY = sign(diffY)
--
--        return signX, signY
--    end
--end

local function next_cell_grow(srcCell, destCell)
    local diffX = destCell.x - srcCell.x
    local diffY = destCell.y - srcCell.y
    local distanceX = math.abs(diffX)
    local distanceY = math.abs(diffY)
    local distance = math.max(distanceX, distanceY)

    local x_ratio =  diffX / distance
    local y_ratio =  diffY / distance

    local growX = math.floor(x_ratio + 0.5)
    local growY = math.floor(y_ratio + 0.5)

    return growX, growY
end

--function BattleHeroModel:findPath(enemy)
    -- local pathfinder = require("pathfinder")
    -- local walkableBitmap = self._battleModel:getWalkableBitmap(self)
   
    -- local mcell = self._cell
    -- local ecell = enemy:getNextCell() or enemy:getCell()

    -- local config = {
    --     width = BattleConfig.X_CELL_COUNT,
    --     height = BattleConfig.Y_CELL_COUNT,
    --     start = self:getCell(),
    --     goal = ecell,
    -- }

    -- CCLog("pathfinder.search")
    -- local st = os.clock()
    -- --local path = {}
    -- local found, path = pathfinder.search(config, walkableBitmap)
    -- local et = os.clock()
    -- CCLog(vardump({usetime = et - st, found = found, path = path, config = config, ecell = ecell, bitmap = walkableBitmap, enemy = enemy:getName()}, self:getName() .. "search result"))

    -- self.path = {}

    -- for i = 1, #path do
    --     if i > 3 then
    --         break
    --     end

    --     local x = path[i][1]
    --     local y = path[i][2]
    --     table.insert(self.path, {x = x,  y = y})
    -- end
--end

function BattleHeroModel:findPath(enemy)
    self.path = nil

    local mcell = self:getCell()
    local ecell = enemy:getCell()
    --local goal = enemy:getNextCell() or enemy:getCell()
    local goal

    if mcell.x < ecell.x then
        goal = enemy:getLeftFreeCell()
    else
        goal = enemy:getRightFreeCell()
    end
    if goal == nil then
        goal = enemy:getNextCell() or enemy:getCell()
    end

    -- local finder = self._pathFinder 
    -- if finder == nil then      
    --     local Grid = require ("tool.lib.jumper.grid")  
    --     local Pathfinder = require ("tool.lib.jumper.pathfinder")

    --     local walkableBitmap = self._battleModel:getWalkableBitmap(self)
    --     local walkable = "0"
    --     local map = walkableBitmap:tobitstring()
    --     local grid = Grid(map)
    --     finder = Pathfinder(grid, 'ASTAR', walkable)

    --     local h = function(nodeA, nodeB)
    --         return (0.3 * (math.abs(nodeA:getX() - nodeB:getX()))
    --               + 1.0 * (math.abs(nodeA:getY() - nodeB:getY())))
    --     end
    --     finder:setHeuristic(h)

    --     self._pathFinder = finder
    -- else        
    --     local Grid = require ("tool.lib.jumper.grid")
    --     local walkableBitmap = self._battleModel:getWalkableBitmap(self)
    --     local walkable = "0"
    --     local map = walkableBitmap:tobitstring()
    --     local grid = Grid(map)
    --     finder:setGrid(grid)
    -- end

    -- --CCLog(vardump({self:getName(), "findPath", mcell, goal, map}))
    -- local p = finder:getPath(mcell.x + 1, mcell.y + 1, goal.x + 1, goal.y + 1)

    -- if p then
    --     self.path = {}
    --     for node, count in p:nodes() do
    --         local x = node:getX() - 1
    --         local y = node:getY() - 1
    --         table.insert(self.path, {x = x, y = y})
    --     end
    -- end

    -- CCLog(vardump({self:getName(), "findPath", self.path, map}))


    local walkableBitmap = self._battleModel:getWalkableBitmap(self)

    -- local pathfinder = require("tool.lib.pathfinder")

    -- local abs = math.abs

    -- local sign = function(num) 
    --     if num > 0 then 
    --         return 1
    --     elseif num < 0 then
    --         return -1
    --     else
    --         return 0
    --     end
    -- end

    -- local function heuristic(cx, cy, gx, gy)
    --     local dy, dx = abs(gy - cy), abs(gx - cx)
    --     return dx * 6 + dy * 10 
    -- end

    -- local function cost(fx, fy, tx, ty, goalX, goalY)
    --     local gSignY = sign(goalX - fx)
    --     local nSignY = sign(tx - fx)
        
    --     -- 尽量不要回走
    --     local addition = 0
    --     if gSignY ~= nSignY then
    --         addition = 1
    --     end

    --     if abs(fx - tx) == 1 and abs(fy - ty) == 1 then
    --         return 14 + addition 
    --     else
    --         return 10 + addition
    --     end
    -- end

    -- function isGoal(cx, cy, gx, gy)
    --     return abs(gx - cx) <= 1 and abs(gy - cy) <= 1
    -- end

    -- local p = pathfinder.findPath(walkableBitmap, mcell.x, mcell.y, goal.x, goal.y, pathfinder.heuristic, pathfinder.cost, pathfinder.neighbours, isGoal)
    -- --CCLog(vardump({p, walkableBitmap, mcell, goal, enemy:getName()}, self:getName() .. ":findPath"))
    -- self.path = p

    --local st = os.clock()

    local pathFinder = self._battleModel:getPathFinder()
    local found, path = pathFinder:search(walkableBitmap, mcell, goal)
    self.path = path

    --local et = os.clock()
    --local usetime  = et - st
    --CCLog(vardump({path = path, found = found, map = walkableBitmap, mcell = mcell, goal = goal, enemy = enemy:getName(), time = usetime}), self:getName() .. ":findPath")
end

function BattleHeroModel:clearPath()
    self.path = nil

    return true
end

function BattleHeroModel:computeStepToEnemy(enemy)
    local battleModel = self._battleModel

    local mcell = self._cell
    if self.path and #self.path > 0 then
        local nextCell = self.path[1]
        if not battleModel:isWalkable(nextCell.x, nextCell.y, self) then
            self.path = nil
        end
    end

   if self.path == nil or #self.path == 0 then
       self:findPath(enemy)
   end

   if #self.path > 0 then
       local nextCell = table.remove(self.path, 1)       

       if nextCell then
           local moveX = nextCell.x - mcell.x
           local moveY = nextCell.y - mcell.y

           return moveX, moveY
       end
   end

   CCLog("寻路失败，这是为什么呢")

    local mcell = self._cell
    local ecell = enemy._nextCell or enemy:getCell()

    local mcell = self._cell
    local ecell = enemy:getCell()

    local goal
    if mcell.x < ecell.x then
        goal = enemy:getLeftFreeCell()
    elseif mcell.x >= ecell.x then
        goal = enemy:getRightFreeCell()
    end
    if goal == nil then
        goal = enemy._nextCell or enemy:getCell()
    end

    ecell = goal

    local diffX = ecell.x - mcell.x
    local diffY = ecell.y - mcell.y

    --local growX, growY = self:nextCellGrow(mcell, ecell, self:getFightType())
    local growX, growY = next_cell_grow(mcell, ecell)

--    local attackScope = self:getAttackScope()
--    local xrange = attackScope[mcell.y]
--    CCLog(vardump({xrange = xrange, offX = offX}, "MoveToEnemy"))
--    if growX ~= 0 and xrange and math.abs(offX) >= xrange.len then
--        growY = 0
--    end

    local x = mcell.x + growX
    local y = mcell.y + growY
    local halfHeight = BattleConfig.Y_CELL_COUNT / 2

    local moveX = 0
    local moveY = 0
    if battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y) then
        local mx = mcell.x
        local my = mcell.y

        local lastMoveY = self._lastMoveY
        local tryMoveY = lastMoveY

        if lastMoveY ~= 0 then
            local nextStepY = lastMoveY + my
            if nextStepY < 0 or nextStepY >= BattleConfig.Y_CELL_COUNT then
                tryMoveY = -lastMoveY
            end
        else
            tryMoveY = sign(diffY)
            if tryMoveY == 0 then
                if my == 0 then
                    tryMoveY = 1
                elseif my == BattleConfig.Y_CELL_COUNT - 1 then
                    tryMoveY = -1
                elseif my >= BattleConfig.Y_CELL_COUNT / 2 then
                    tryMoveY = 1
                else
                    tryMoveY = -1
                end
            end
        end

        local unitDiffX = sign(diffX)
        local unitDiffY = sign(diffY)
        for normTryMoveX = 1, -1, -1 do
            local x = mx + normTryMoveX * unitDiffX
            local y = my

            if x ~= mx and y >= 0 and y < BattleConfig.Y_CELL_COUNT and x >= 0 and  x < BattleConfig.X_CELL_COUNT then
                if not (battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y)) then
                    moveX = x - mx
                    moveY = y - my
                    break
                end
            end

            if tryMoveY ~= 0 then
                y = my + tryMoveY
                if (x ~= mx or y ~= my) and y >= 0 and y < BattleConfig.Y_CELL_COUNT and x >= 0 and  x < BattleConfig.X_CELL_COUNT then
                    if not (battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y)) then
                        moveX = x - mx
                        moveY = y - my
                        break
                    end
                end
            else
                y = my - 1
                if (x ~= mx or y ~= my) and y >= 0 and y < BattleConfig.Y_CELL_COUNT and x >= 0 and  x < BattleConfig.X_CELL_COUNT then
                    if not (battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y)) then
                        moveX = x - mx
                        moveY = y - my
                        break
                    end
                end

                y = my + 1
                if (x ~= mx or y ~= my) and y >= 0 and y < BattleConfig.Y_CELL_COUNT and x >= 0 and  x < BattleConfig.X_CELL_COUNT then
                    if not (battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y)) then
                        moveX = x - mx
                        moveY = y - my
                        break
                    end
                end
             end
        end


--        local moveGrows = nil
--        if growX > 0 then
--            if mcell.y > halfHeight then
--                moveGrows = HERO_MOVE_TRY_LIST.u_right
--            else
--                moveGrows = HERO_MOVE_TRY_LIST.d_right
--            end
--        else
--            if mcell.y > halfHeight then
--                moveGrows = HERO_MOVE_TRY_LIST.u_left
--            else
--                moveGrows = HERO_MOVE_TRY_LIST.d_left
--            end
--        end
--
--        for idx, grow in ipairs(moveGrows) do
--            local x = mcell.x + grow[1]
--            local y = mcell.y + grow[2]
--
--            if y >= 0 and y < BattleConfig.Y_CELL_COUNT then
--                if x >= 0 and  x < BattleConfig.X_CELL_COUNT then
--                    if not (battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y)) then
--                        moveX = grow[1]
--                        moveY = grow[2]
--                        break
--                    end
--                end
--            end
--        end
    else
        moveX = growX
        moveY = growY
    end

    self._lastMoveY = moveY

    CCLog("computeStep", vardump({self:getName(), moveX, moveY, mcell, ecell}))
    return moveX, moveY
end


function BattleHeroModel:moveToEnemy(enemy)
    local moveX, moveY = self:computeStepToEnemy(enemy)

    if moveX > 0 then
        self:setDirection("right")
    elseif moveX < 0 then
        self:setDirection("left")
    end

    self:setState("walk")
    self:setNextStepCell(moveX, moveY)
    --self:moveAction()

    return true
end

function BattleHeroModel:moveToMatchedEnemy()
    if self:isMoving() then
        CCLog("move on in moving action")
        return false
    end

    if self._matchedEnemy then
        return self:moveToEnemy(self._matchedEnemy)
    else
        return false
    end
end

function BattleHeroModel:checkPushedByTeammate()

    return true
end

function BattleHeroModel:setNextStepToMatchedEnemy()
    if self._matchedEnemy then
        local moveX, moveY = self:computeStepToEnemy(self._matchedEnemy)
        self:setNextStepCell(moveX, moveY)
    else
        return false
    end
end

function BattleHeroModel:getHeroImage()
	local res = self._heroBaseData.res

	local path = string.format("image/icon/head/%s.png", res)
    if not cc.FileUtils:getInstance():isFileExist(path) then
        CCLog(string.format("file '%s' not exists, use default", path))
        path = "image/icon/head/xj_1000.png"
    end
    return path
end

function BattleHeroModel:getHeroImageName()
    local res = self._heroBaseData.res

    local path = string.format("%s.png", res)

    return path
end

function BattleHeroModel:getHeroAni() 
    local fileUtils = cc.FileUtils:getInstance()
    local path

    path = fileUtils:fullPathForFilename(string.format("Hero/Ani/%s/skeleton.skel", self._heroBaseData.res))
    if fileUtils:isFileExist(path) then
        return path
    end

    path = fileUtils:fullPathForFilename(string.format("Hero/Ani/%s/skeleton.json", self._heroBaseData.res))
    if fileUtils:isFileExist(path) then
        return path
    end

    CCLog(string.format("file '%s' not exists, use default", path))
    path = "Hero/Ani/xj_1000/skeleton.json"

    return path
end

function BattleHeroModel:getHeroAtlas()
    local fileUtils = cc.FileUtils:getInstance()
    local path

    path = fileUtils:fullPathForFilename(string.format("Hero/Ani/%s/skeleton.atlas", self._heroBaseData.res))
    if fileUtils:isFileExist(path) then
        return path
    end

    CCLog(string.format("file '%s' not exists, use default", path))
    path = "Hero/Ani/xj_1000/skeleton.atlas"
    return path
end

function BattleHeroModel:getHeroRes(  )
    return self._heroBaseData.res
end

function BattleHeroModel:setEventDispatcher(dispatcher)
    self._eventDispatcher = dispatcher
end

function BattleHeroModel:dispatchEvent(eventName, data)
    if self._eventDispatcher then
        local event = cc.EventCustom:new(eventName)
        event.data = data
        --CCLog("BattleHeroModel(" .. self:getName() .. "):dispatchEvent(" .. eventName ..")")
        self._eventDispatcher:dispatchEvent(event)
    end
end

function BattleHeroModel:doWait()
    self:dispatchEvent(AppEvent.UI.Battle.Wait, {fighterID = self:getFighterID()})
    return true
end

function BattleHeroModel:rageSkillInQueue()
    return #self._rageSkillQueue > 0
end

function BattleHeroModel:doRageSkill()
    CCLog("dispatchEvent(rageSkill)")
    local rageSkillID = table.remove(self._rageSkillQueue, 1)
    local elemType = self:getElemType()

    local rageSkill = self:getRageSkill()
    -- TODO:使用命名枚举

    local attackData = AttackDataModel.new(self, self._battleModel, rageSkill.id, rageSkill.level)
    if rageSkill.mode == enums.SkillMode.Region then
        self:setInRageScopeSelecting(true)
        self:dispatchEvent(AppEvent.UI.Battle.RegionRageSkill, attackData:encode())
    elseif rageSkill.mode == enums.SkillMode.HeroChoice then 
        self:dispatchEvent(AppEvent.UI.Battle.HeroChoiceRageSkill, attackData:encode())
    else
        self:doAttack(attackData)
    end

    return true
end

function BattleHeroModel:doSkill(skillData)
    local elemType = self:getElemType()

    local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level)
    if skillData.mode == enums.SkillMode.Region then
        self:setInRageScopeSelecting(true)
        self:dispatchEvent(AppEvent.UI.Battle.RegionRageSkill, attackData:encode())
    elseif skillData.mode == enums.SkillMode.HeroChoice then
        self:dispatchEvent(AppEvent.UI.Battle.HeroChoiceRageSkill, attackData:encode())
    else
        self:doAttack(attackData)
    end

    return true
end

function BattleHeroModel:setNextStepCell(offsetX, offsetY)
    if not self:canMove() then
        CCLog("BattleHeroModel:setNextStepCell(), but can't move", debug.traceback())
        return
    end

    local battleModel = self._battleModel
    local direction = self._direction

    local mcell = self._cell
    local nextCell = {x = mcell.x + offsetX, y = mcell.y + offsetY }
    self._nextCell = nextCell

    
    self._movingToPos = BattleConfig.getHeroCellPos(nextCell.x, nextCell.y)
    --CCLog(vardump({mcell, nextCell, self._movingToPos}, "BattleHeroModel:setNextStepCell()"), self:getName(), debug.traceback())

    if self._currentPos == nil then
        self._currentPos  = BattleConfig.getHeroCellPos(mcell.x, mcell.y)
    end

    self._movingFromPos = {x = self._currentPos.x, y = self._currentPos.y}

    self._movingToCell = {x = nextCell.x, y = nextCell.y }
    --self._movingCellLine = cc.pMidpoint(self._currentPos, self._movingToPos)

    if offsetX ~= 0 then
        self:setDirection(offsetX > 0 and "right" or "left")
        --CCLog(self:getName(), offsetX, offsetY, "setDirection by MoveBY")
    end
end

--function BattleHeroModel:moveBy(offsetX, offsetY)
--    self:setNextStepCell(offsetX, offsetY)
--    self:setState("walk")
--end

function BattleHeroModel:clearMoving()
    self._movingToCell = nil -- 正在移动到的Cell
    self._movingToPos = nil -- 正在移动到的位置
    self._currentPos  = nil  -- 上次移动到的位置
    --self._movingCellLine = nil
end

function BattleHeroModel:hasMovingToCell()
    return self._movingToCell ~= nil
end

function BattleHeroModel:hasNoMovingToCell()
    return self._movingToCell == nil
end

--[[
curPos = {
        x = 697.5,
        y = 202.5,
    },
    disX = 0,
    disY = 0,
    nextPos = {
        x = 697.5,
        y = 202.5,
    },
    speedX = 0,
    speedY = 0,
    toPos = {
        x = 697.5,
        y = 202.5,
    },

--]]

-- local abs = math.abs
-- local min = math.min
-- function BattleHeroModel:moveStep()
--     if self._movingToPos then
--         local dstPosX, dstPosY = self._movingToPos.x, self._movingToPos.y
--         local posX, posY = self._currentPos.x, self._currentPos.y

--         local disX = dstPosX - posX
--         local disY = dstPosY - posY

--         local signX = sign(disX)
--         local signY = sign(disY)

--         local absDisX = abs(disX)
--         local absDisY = abs(disY)

--         local absOffsetX, absOffsetY = self:getMoveSpeed()

--         local offsetX = signX * min(absOffsetX, absDisX)
--         local offsetY = signY * min(absOffsetY, absDisY)

--         local nextX = posX + offsetX
--         local nextY = posY + offsetY

--         local nextPos = cc.p(nextX, nextY)
--         CCLog(vardump({disX = disX, disY = disY, speedX = offsetX, speedY = offsetY, curPos = self._currentPos, toPos = self._movingToPos, nextPos = nextPos}, self:getName() .. " moveStep"))
        
--         self:dispatchEvent(AppEvent.UI.Battle.SetHeroPos, {fighterID = self:getFighterID(), pos = nextPos})
--         self._currentPos = nextPos

--         if ((disX > 0 and nextX > dstPosX) or (disX < 0 and nextX < dstPosX) or (disX == 0 and nextX == dstPosX)) and
--            ((disY > 0 and nextY > dstPosY) or (disY < 0 and nextY < dstPosY) or (disY == 0 and nextY == dstPosY))
--         then
--             CCLog(vardump(self._movingToCell, "reachCell"))
--             self:setCell(self._movingToCell)
--             self._movingToPos = nil
--         end
--     end
-- end

local abs = math.abs
local min = math.min
function BattleHeroModel:moveStep()
    if self._movingToPos then
        local reachX, reachY = false, false
        local fromX, fromY = self._movingFromPos.x, self._movingFromPos.y
        local toX, toY = self._movingToPos.x, self._movingToPos.y
        local curX, curY = self._currentPos.x, self._currentPos.y

        -- 当前单元格移动方向
        local dirX = sign(toX - fromX)
        local dirY = sign(toY - fromY)

        -- 到目标位置的位移
        local disX = toX - curX
        local disY = toY - curY

        -- 移动速率
        local absOffsetX, absOffsetY = self:getMoveSpeed()

        local nextX = curX + dirX * absOffsetX
        local nextY = curY + dirY * absOffsetY

        if dirX == 0 then
            reachX = true
        elseif (dirX == 1 and nextX >= toX) or (dirX == -1 and nextX <= toX) then
            reachX = true
            nextX = toX
        end

        if dirY == 0 then 
            reachY = true
        elseif (dirY == 1 and nextY >= toY) or (dirY == -1 and nextY <= toY) then
            reachY = true
            nextY = toY
        end  

        local nextPos = cc.p(nextX, nextY)

        -- CCLog(vardump({
        --         tick = self._battleModel.totalTimeTick,  
        --         cur = self._currentPos, 
        --         next = nextPos, 
        --         from = self._movingFromPos,
        --         to = self._movingToPos, 
        --         toCell = self._movingToCell,
        --         reach = {reachX, reachY},
        --         speed = {absOffsetX, absOffsetY},
        --     }, 
        --     self:getName() .. ":moveStep")
        -- )

        self:dispatchEvent(AppEvent.UI.Battle.SetHeroPos, {fighterID = self:getFighterID(), pos = nextPos})
        self._currentPos = nextPos

        if reachX and reachY then
            self:setCell(self._movingToCell)
            self._movingToPos = nil
        end 
    end
end

-- local abs = math.abs
-- local min = math.min
-- function pNormalize(pt)
--     local length = cc.pGetLength(pt)
--     if 0 == length then
--         return { x = 0.0,y = 0.0 }
--     end

--     return { x = pt.x / length, y = pt.y / length }
-- end

-- function BattleHeroModel:moveStep()
--     if self._movingToPos then
--         local fromPos = self._movingFromPos
--         local targetPos = self._movingToPos
--         local curPos = self._currentPos

--         -- 当前单元格移动方向
--         local vel, unitDistanceSQ = self:getMoveVel(targetPos, curPos)
        
--         -- 到目标位置的位移
--         local nextPos = cc.pAdd(curPos, cc.pMul(vel, BattleConfig.TIME_UNIT))

--         local distanceSQ = cc.pDistanceSQ(nextPos, targetPos)
--         local reach = false
--         if distanceSQ < unitDistanceSQ then
--             reach = true
--         end

--         -- CCLog(vardump({name = self:getName(), fromPos = fromPos, targetPos = targetPos, curPos = curPos, vel = vel, 
--         --     tick = self._battleModel.totalTimeTick,
--         --     nextPos = nextPos, distanceSQ = distanceSQ, unitDistanceSQ = unitDistanceSQ, reach = reach}, "moveStep"))

--         self:dispatchEvent(AppEvent.UI.Battle.SetHeroPos, {fighterID = self:getFighterID(), pos = nextPos})
--         self._currentPos = nextPos

--         if reach then
--             self:setCell(self._movingToCell)
--             self._movingToPos = nil
--             self._cachedMoveSpeed.cached = false
--         end 
--     end
-- end

function BattleHeroModel:moveUpdate()
    while true do
        xpcall(handler(self, self.moveStep), __G__TRACKBACK__)
        coroutine.yield()
    end
end

function BattleHeroModel:moveAction()
    if not self:canMove() then
        return false
    end

    self:moveStep()
    return true

    -- local status, error = coroutine.resume(self._moveThread)
    -- if status then
    --     return true
    -- else
    --     assert(false, error)
    -- end
end

function BattleHeroModel:hasFreeEnemy()
    local enemyTeam = self:getEnemyTeam()
    return enemyTeam:hasFreeHero()
end

function BattleHeroModel:enemyCount()
    return self._battleModel:getEnemyCount(self:getTeamSide())
end

function BattleHeroModel:matchEnemy(enemyModels)
    CCLog("BattleHeroModel:matchEnemy count = " .. #enemyModels)
    local enemyCount = #enemyModels
    assert(enemyCount > 0, "match enemy count == 0")

    -- 只有一个就不用搜索了
    if enemyCount == 1 then
        return enemyModels[1]
    end

    -- 距离最近
    local nearEnemyList = self:filterNearestEnemyList(enemyModels)
    if #nearEnemyList == 1 then
        return nearEnemyList[1]
    end

    -- 血量最少
    local weakestEnemyList = self:filterWeakestEnemyList(nearEnemyList)
    if #weakestEnemyList == 1 then
        return weakestEnemyList[1]
    end

    -- 五行克制
    local restraintEnemyList = self:filterRestraintEnemyList(weakestEnemyList)
    if #restraintEnemyList == 1 then
        return restraintEnemyList[1]
    end

    -- 近战优先
    local directAttackEnemyList = self:filterDirectAttackEnemyList(restraintEnemyList)
    if #directAttackEnemyList == 1 then
        return directAttackEnemyList[1]
    end

    -- 随机选择
    local count = #directAttackEnemyList
    return directAttackEnemyList[self._battleModel:random(1, count)]
end

-- 过滤最近的敌人
--function BattleHeroModel:filterNearestEnemyList(enemyModels)
--    assert(#enemyModels > 0)
--
--    -- 只有一个就不用搜索了
--    if #enemyModels == 1 then
--        return enemyModels
--    end
--
--    local mcell = self._cell
--
--    local disEnemyModels = {}
--    for idx, enemy in ipairs(enemyModels) do
--        local ecell = enemy:getCell()
--        local disX = math.abs(ecell.x - mcell.x)
--        local disY = math.abs(ecell.y - mcell.y)
--        table.insert(disEnemyModels, {disX = disX, disY = disY, enemy = enemy, used = true})
--    end
--
--    local minDisX = nil
--    for idx, disEnemy in ipairs(disEnemyModels) do
--        local enemyDisX = disEnemy.disX
--        if minDisX == nil or enemyDisX < minDisX then
--            minDisX = enemyDisX
--        end
--    end
--
--    for idx, disEnemy in ipairs(disEnemyModels) do
--        local enemyDisX = disEnemy.disX
--        if minDisX == nil or enemyDisX < minDisX then
--            minDisX = enemyDisX
--        end
--    end
--
--    for idx, disEnemy in ipairs(disEnemyModels) do
--        if minDisX ~= disEnemy.disX then
--            disEnemy.used = false
--        end
--    end
--
--    local minDisY  = nil
--    for idx, disEnemy in ipairs(disEnemyModels) do
--        if disEnemy.used then
--            local enemyDisY = disEnemy.disY
--            if minDisY == nil or enemyDisY < minDisY then
--                minDisY = enemyDisY
--            end
--        end
--    end
--
--    local nearEnemyList = {}
--    for idx, disEnemy in ipairs(disEnemyModels) do
--        if disEnemy.used and disEnemy.disY == minDisY then
--            table.insert(nearEnemyList, disEnemy.enemy)
--        end
--    end
--
--    return nearEnemyList
--end

function BattleHeroModel:filterNearestEnemyList(enemyModels)
    local X_WEIGHT = 4
    local Y_WEIGHT = 1
    assert(#enemyModels > 0)

    -- 只有一个就不用搜索了
    if #enemyModels == 1 then
        return enemyModels
    end

    local mcell = self._cell

    local disEnemyArray = {}

    local minDis = nil
    for idx, enemy in ipairs(enemyModels) do
        local ecell = enemy:getCell()
        local disX = math.abs(ecell.x - mcell.x)
        local disY = math.abs(ecell.y - mcell.y) - (ecell.y - mcell.y) * 0.1

        -- 三格之内有 吸引仇恨的靶子 直接返回
        if disX <= 3 and disY <= 3 and enemy:getFighterType() == "hatredTarget" then
            return {enemy}
        end

        local dis = disX * X_WEIGHT + disY * Y_WEIGHT
        table.insert(disEnemyArray, {dis = dis, enemy = enemy})
        CCLog(vardump({self:getName(), enemy:getName(), dis = dis, x =  disX, y = disY}, "Enemy dis"))

        if minDis == nil or dis < minDis then
            minDis = dis
        end
    end

    table.sort(disEnemyArray, function(d1, d2)
        return d1.dis < d2.dis
    end)

    local nearEnemyList = {}
    for idx, disEnemy in ipairs(disEnemyArray) do
        local dis = disEnemy.dis
        local enemy = disEnemy.enemy
        if dis == minDis then
           table.insert(nearEnemyList, enemy)
        end
    end

    return nearEnemyList
--    local minDisX = 10000
--    for idx, enemy in ipairs(enemyModels) do
--        local ecell = enemy:getCell()
--        local disX = math.abs(ecell.x - mcell.x)
--        if disX < minDisX then
--            minDisX = disX
--        end
--    end
--
--    local minDisY = 10000
--    for idx, enemy in ipairs(enemyModels) do
--        local ecell = enemy:getCell()
--        local disX = math.abs(ecell.x - mcell.x)
--        if minDisX == disX then
--            local disY = math.abs(ecell.y - mcell.y)
--            if disY < minDisY then
--                minDisY = disY
--            end
--        end
--    end
--
--    local nearEnemyList = {}
--    for idx, enemy in ipairs(enemyModels) do
--        local ecell = enemy:getCell()
--        local disX = math.abs(ecell.x - mcell.x)
--        local disY = math.abs(ecell.y - mcell.y)
--
--        if disX == minDisX and disY == minDisY then
--            table.insert(nearEnemyList, enemy)
--        end
--    end
--    return nearEnemyList
end


-- 过滤最少血量的敌人
function BattleHeroModel:filterWeakestEnemyList(enemyModels)
    assert(#enemyModels > 0)

    -- 只有一个就不用搜索了
    if #enemyModels == 1 then
        return enemyModels
    end

    -- 先搜索Y轴最近的敌人
    local minHP = nil
    local enemyList = nil
    for idx, enemy in ipairs(enemyModels) do
        local HP = enemy:getHP()
        if minHP == nil or HP < minHP then
            minHP = HP
            enemyList = {enemy }
        elseif minHP == HP then
            table.insert(enemyList, enemy)
        end
    end

    return enemyList
end

-- 过滤五行相克的职业(如果有，没有克制的就返回原敌人列表)
function BattleHeroModel:filterRestraintEnemyList(enemyModels)
    assert(#enemyModels > 0)

    -- 只有一个就不用搜索了
    if #enemyModels == 1 then
        return enemyModels
    end

    local restraintEnemyList = {}
    for idx, enemy in ipairs(enemyModels) do
        if self:restraint(enemy) then
            table.insert(restraintEnemyList, enemy)
        end
    end
    if #restraintEnemyList > 0 then
        return restraintEnemyList
    else
        return enemyModels
    end
end

-- 过滤近战职业(如果有，无则返回原列表)
function BattleHeroModel:filterDirectAttackEnemyList(enemyModels)
    assert(#enemyModels > 0)

    -- 只有一个就不用搜索了
    if #enemyModels == 1 then
        return enemyModels
    end

    local directAttackEnemyList = {}
    for idx, enemy in ipairs(enemyModels) do
        if enemy:getFightType() == "near"  then
            table.insert(directAttackEnemyList, enemy)
        end
    end
    if #directAttackEnemyList > 0 then
        return directAttackEnemyList
    else
        return enemyModels
    end
end

function BattleHeroModel:lookForMatchedEnemy()
    local enemyTeam = self:getEnemyTeam()
    local enemyModels = enemyTeam:getAliveHeroModels(true)

    if #enemyModels > 0 then
        return self:matchEnemy(enemyModels)
    else
        return nil
    end
end

function BattleHeroModel:lookForAliveEnemy()
    local enemyModels
    if self:inCharm() then
        local team = self:getTeam()
        enemyModels = team:getCanMatchedHeroModels(true)
        for i, hero in ipairs(enemyModels) do
            if hero == self then
                table.remove(enemyModels, i)
                break
            end
        end
    else
        local enemyTeam = self:getEnemyTeam()
        enemyModels = enemyTeam:getCanMatchedHeroModels(true)
    end

    if #enemyModels > 0 then
        return self:matchEnemy(enemyModels)
    else
        CCLog("BattleHeroModel:lookForAliveEnemy has no alive enemy")
        return nil
    end
end

function BattleHeroModel:lookForEnemy()
    if self:hasMatchedEnemy() then
        CCLog("maybe BUG")
        return false
    end

    if self:isAttacker() and self:hasRoadBlockObstacle() then
        CCLog("matchRoadBlockObstacle")
        return self:matchRoadBlockObstacle()
    else
        CCLog("lookForAliveEnemy")
        local enemy = self:lookForAliveEnemy()

        if enemy then
            self:setMatchedEnemy(enemy)
            return true
        end
    end

    return false
end

function BattleHeroModel:isReady()
    return self._state == "ready"
end

-- 脸朝向敌人
function BattleHeroModel:directToMatchedEnemy()
    if self._matchedEnemy then
        local mcell = self._cell
        local ecell = self._matchedEnemy:getCell()

        if mcell.x and ecell.x then
            if mcell.x < ecell.x then
                self:setDirection("right")
            elseif mcell.x > ecell.x then
                self:setDirection("left")
            elseif mcell.x == ecell.x then
                local enemyDirection = self._matchedEnemy:getDirection()
                if enemyDirection == "left" then
                    self:setDirection("right")
                elseif enemyDirection == "right" then
                    self:setDirection("left")
                end
            end
        end
    end

    return true
end

function BattleHeroModel:setReady()
    self:setState("ready")

    self:directToMatchedEnemy()
    return true
end

-- 进攻方
function BattleHeroModel:isAttacker()
    return self._teamSide == "left"
end

-- 防守方
function BattleHeroModel:isDefender()
    return self._teamSide == "right"
end

function BattleHeroModel:hasRoadBlockObstacle()
    local battleModel = self._battleModel

    return battleModel.gameObstacle:hasRoadBlockObstacle()
end

function BattleHeroModel:hasNoRoadBlockObstacle()
    return not self:hasRoadBlockObstacle()
end

--function BattleHeroModel:matchRoadBlockObstacle()
--    local obstacleList = self._battleModel.gameObstacle:getRoadBlockObstacleList()
--
--    local minX = nil
--    local nearObstacle = nil
--    for _, obstacle in ipairs(obstacleList) do
--        if minX == nil or obstacle.pos.x < minX then
--            minX = obstacle.pos.x
--            nearObstacle = obstacle
--        end
--    end
--
--    self._matchedObstacle = nearObstacle
--
--    return true
--end

function BattleHeroModel:matchRoadBlockObstacle()
    local obstacleList = self._battleModel.gameObstacle:getRoadBlockObstacleList()

    local minX = nil
    local nearObstacle = nil
    for _, obstacle in ipairs(obstacleList) do
        if minX == nil or obstacle.pos.x < minX then
            minX = obstacle.pos.x
            nearObstacle = obstacle
        end
    end

    self:setMatchedEnemy(nearObstacle)

    return true
end

--function BattleHeroModel:roadBlockObstacleInAttackScope()
--    local nearObstacle = self._matchedObstacle
--    if nearObstacle then
--        self:initRelativeAttackScope()
--
--        -- 空数组表示所有
--        if #self._relativeAttackScope == 0 then
--            return true
--        end
--
--        local mcell = self._cell
--
--        local posX = nearObstacle.pos.x
--        local xrange = self._relativeAttackScope[0]
--        if xrange then
--            -- 在右边
--            local start =  mcell.x + xrange.start
--            local stop = mcell.x + xrange.start + xrange.len - 1
--            if posX >= start and posX <= stop then
--                return true
--            end
--        end
--    end
--    return false
--end

--function BattleHeroModel:attackRoadBlockObstacle()
--    local skillData = self:getNormAttack()
--    local attackData = AttackDataModel.new(self, self._battleModel, skillData.id, skillData.level, {self._matchedObstacle:getFighterID()})
--
--    self:doAttack(attackData)
--
--    return true
--end

--function BattleHeroModel:computeStepToObstacle(obstacle)
--    local destX = obstacle.pos.x
--    local mcell = self._cell
--
--    local battleModel = self._battleModel
--
--    local growX = 1
--    local growY = 0
--
--    local x = nil
--    if mcell.x < destX then
--        x = mcell.x + 1
--    else
--        x = mcell.x - 1
--    end
--
--    local y = mcell.y + 0
--    if battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y) then
--        local moveGrows = nil
--        if growX > 0 then
--            moveGrows = HERO_MOVE_TRY_LIST.right
--        else
--            moveGrows = HERO_MOVE_TRY_LIST.left
--        end
--
--        for idx, grow in ipairs(moveGrows) do
--            local x = mcell.x + grow[1]
--            local y = mcell.y + grow[2]
--
--            if y >= 1 and y <= BattleConfig.Y_CELL_COUNT then
--                if (growX > 0 and x <= BattleConfig.X_CELL_COUNT) or (growX < 0 and x >= 1) then
--                    if not (battleModel:isGridUsed(x, y, self) or battleModel:isGridToBeUse(x, y)) then
--                        growX = grow[1]
--                        growY = grow[2]
--                        break
--                    end
--                end
--            end
--        end
--    end
--end

--function BattleHeroModel:moveToRoadBlockObstacle()
--    if self:isMoving() then
--        CCLog("move on in moving action")
--        CCLog(debug.traceback())
--        return false
--    end
--
--    local moveX, moveY = self:computeStepToObstacle(self._matchedObstacle)
--
--    self:setState("walk")
--    self:moveBy(moveX, moveY)
--
--    return true
--end

function BattleHeroModel:matchedEnemyIsNotHide()
    return self._matchedEnemy:isHideTo(self)
end

function BattleHeroModel:createBehaviourTree()
    local BHT = require("tool.lib.BehaviourTree")

    local Action = BHT.Action.new
    local Condition = BHT.Condition.new
    local Selector = BHT.Selector.new
    local Sequence = BHT.Sequence.new

   -- local Action = BHT.ActionLog.new
   -- local Condition = BHT.ConditionLog.new
   -- local Selector = BHT.SelectorLog.new
   -- local Sequence = BHT.SequenceLog.new

    local TRUE = Action(function() return true end)
    local FALSE = Action(function() return false end)

    local bhtRoot = Selector{
        --[[
            眩晕, 攻击中，受击中 。。。，不作为
        --]]
        Condition(handler(self, self.isEgg), "egg"),
        Condition(handler(self, self.isVertigo), "vertigo"),
        Condition(handler(self, self.isSleep), "sleep"),
        Condition(handler(self, self.inAttacking), "in attacking"),
        Condition(handler(self, self.inHitting), "in hitting"),
        --Condition(handler(self, self.isMoving), "is moving"),

        Sequence{
            Condition(handler(self, self.inComboHitting), "in combo hit"),
            Action(handler(self, self.doComboHit), "do combo hit"),
        },
        -- 防御方，有可被攻击障碍，不做操作
        Sequence{
            Condition(handler(self, self.isDefender), "is defender"),
            Condition(handler(self, self.hasRoadBlockObstacle), "has road block obstacle"),
            TRUE,
        },

        -- 还没有锁定的敌人
        Sequence{
            Condition(handler(self, self.hasNoMatchedEnemy), "has no matched enemy"),
            Action(handler(self, self.lookForEnemy), "match enemy"),
            Action(handler(self, self.directToMatchedEnemy), "direct to enemy"),
            FALSE,
        },

        Sequence{
            Condition(handler(self, self.hasNoRoadBlockObstacle), "no road block obstacle"),
            Condition(handler(self, self.rageSkillInQueue), "rage skill in queue"),
            Action(handler(self, self.doRageSkill), "perform rage skill")
        },

        Sequence{
            Condition(handler(self, self.isMoving), "in moving"),
            Action(handler(self, self.moveAction), "move step"),
--            Selector{
--                Condition(handler(self, self.matchedEnemyInAttackScope), "enemy in scope"),
--                Condition(handler(self, self.matchedEnemyWillInAttackScope), "enemy will in scope"),
--                Condition(handler(self, self.isCellChanged), "has next cell"),
--                Sequence{
--                    Action(handler(self, self.setNextStepToMatchedEnemy), "compute next step"),
--                    Action(handler(self, self.resetCellChanged), "reset cell changed"),
--                },
--                TRUE,
--            },
        },

        Selector{
            -- 如果已经有锁定的敌人
            Sequence{
                Condition(handler(self, self.hasMatchedEnemy), "has matched enemy"),
                Action(handler(self, self.directToMatchedEnemy), "direct to enemy"),
                Selector{
                    -- 如果锁定的敌人在攻击范围内
                    Sequence{
                        Condition(handler(self, self.matchedEnemyInAttackScope), "enemy in scope"),
                        Action(handler(self, self.clearPath), "clear path cache"),
                        Selector{
                            --Action(handler(self, self.tryMoveToMatchedEnemyRow), "try move to same row"),
                            Condition(handler(self, self.isReady), "is ready"),
                            Action(handler(self, self.setReady), "set ready"),
                            Action(handler(self, self.directToMatchedEnemy), "direct to enemy"),
                        },
                        -- 如果队列中有怒气技能待释放就释放技能
                        Selector{
--                            Sequence{
--                                Condition(handler(self, self.rageSkillInQueue), "rage skill in queue"),
--                                Action(handler(self, self.doRageSkill), "perform rage skill")
--                            },
                            -- 如果攻击冷却中，就啥都不做
                            Selector{
                                Condition(handler(self, self.inCooling), "cool down"),
                                Condition(handler(self, self.unableAttack), "处于不能攻击状态"),
                                Condition(handler(self, self.matchedEnemyIsNotHide), "敌人没有隐身"),
                                Action(handler(self, self.attack), "attack"),
                            },
                        },
                    },

                    -- 敌人正在走入攻击范围
                    Sequence{
                        Condition(handler(self, self.matchedEnemyWillInAttackScope), "enemy will in scope"),
                        Action(handler(self, self.clearPath), "clear path cache"),
--                        Selector{
--                            Action(handler(self, self.tryMoveToMatchedEnemyRow), "try move to same row"),
--                            TRUE,
--                        },
                        Action(handler(self, self.setReady), "set ready"),
                        Action(handler(self, self.directToMatchedEnemy), "direct to enemy"),
                    },

                    -- 如果锁定的敌人不在攻击范围内，走近敌人
                    Condition(handler(self, self.unableMove), "can move"),
                    Action(handler(self, self.moveToMatchedEnemy), "move to enemy"),
                    Action(handler(self, self.directToMatchedEnemy),  "direct to enemy"),
                },
            },
        },
    }
    
    return bhtRoot
end

function BattleHeroModel:update()
    local battleModel = self._battleModel
    if self._egg then
        self._egg:update(battleModel)
        return
    end

    self._attackingModel:update()
    self._buffMgr:update()

    if self._magicCircleList then
        self._magicCircleList:update(battleModel)
    end

    if self._continuousSkillModel ~= nil then
        self._continuousSkillModel:update(battleModel)
        if self._continuousSkillModel:isFinish() then
            self:resetContinuousSkillModel()
        end
    end

    self._skillMgr:update()
    self._bhtRoot:update(battleModel)
    self:updateAIThreadList()

    self:hpRecover()
end

local TICK_PER_SECOND = math.floor(1.0 / BattleConfig.TIME_UNIT)
function BattleHeroModel:hpRecover()
    local tick = self._battleModel.timeTick 

    local HP = self._heroData.hpRecover or 0
    if HP > 0 and tick % TICK_PER_SECOND == 0 then
        self:incHP(HP, true, false)
        CCLog("hpRecover", HP)
    end
end

function BattleHeroModel:addBuff(buffID, attackerModel, skillID, skillLevel)
    if not self:isAlive() then
        return
    end

    CCLog(self:getName(), "addBuff", buffID, skillLevel)
    local buffModel = BuffModel.new(self, buffID, skillID, skillLevel, attackerModel)
    self._buffMgr:addBuff(buffModel)
end

function BattleHeroModel:addRawBuff(buffModel)
    self._buffMgr:addRawBuff(buffModel)
end

function BattleHeroModel:removeRawBuff(buffModel)
    self._buffMgr:removeRawBuff(buffModel)
end

function BattleHeroModel:clearBuff()
    CCLog("BattleHeroModel:clearBuff()")
    self._buffMgr:clear()
end

function BattleHeroModel:clearDebuff()
    return self._buffMgr:clearDebuff()
end

function BattleHeroModel:addMagicCircle(magicCircle)
    if self._magicCircleList == nil then
        self._magicCircleList = FollowMagicCircleListModel.new(self)
    end

    self._magicCircleList:add(magicCircle)
end

function BattleHeroModel:clearMagicCircle()
    CCLog("BattleHeroModel:clearMagicCircle()")
    self._magicCircleList:clear()
    self._magicCircleList = nil
end

function BattleHeroModel:setContinuousSkillModel(continuousSkillModel)
    self._continuousSkillModel = continuousSkillModel

    if continuousSkillModel ~= nil then
        self:onContinuousSkillBegin(continuousSkillModel)
    end

    self:clearCanMoveCache()
end

function BattleHeroModel:resetContinuousSkillModel()
    if self._continuousSkillModel ~= nil then
        self:onContinuousSkillEnd(self._continuousSkillModel)
        self._continuousSkillModel = nil
    end

    self:clearCanMoveCache()
end

function BattleHeroModel:inContinuousSkill()
    if self._continuousSkillModel ~= nil and (not self._continuousSkillModel:isFinish()) then
        return true
    end
    return false
end

function BattleHeroModel:setComboHitModel(comboHitModel)
    CCLog(vardump({times = comboHitModel.leftCount}, "BattleHeroModel:setComboHitModel()"))
    self._comboHitModel = comboHitModel
end

function BattleHeroModel:inComboHitting()
    return self._comboHitModel ~= nil
end

function BattleHeroModel:doComboHit()
    if self._comboHitModel ~= nil then
        if self._comboHitModel:release() then
            return true
        else
            self._comboHitModel = nil
            return false
        end
    end
    return false
end

function BattleHeroModel:getRageSkillID()
    if self._rageSkillID == nil then
        local skillID = self._heroBaseData.rpSkill

        self._rageSkillID = skillID
    end
    return self._rageSkillID
end

function BattleHeroModel:performRageSkill()
    if self:canReleaseRageSkill() then
        table.insert(self._rageSkillQueue, self:getRageSkillID())
        self:doRageSkill()
    end
end

function BattleHeroModel:turnIntoEgg(skillData)
    self._attackingModel:breakOff(true)
    self:resetContinuousSkillModel()
    self._comboHitModel = nil
    self:clearCanMoveCache()

    CCLog(vardump(skillData, "BattleHeroModel:turnIntoEgg"))
    local rageHitTimes = skillData.extraAffectValue
    assert(rageHitTimes > 0, "rage hit times: " .. tostring(rageHitTimes))
    local egg = EasterEggModel.new(self, rageHitTimes)
    self._egg = egg
    self:dispatchEvent(AppEvent.UI.Battle.TurnIntoEgg, {fighterID = self:getFighterID(), modelAttr = self:getViewInfo(), teamSide = self:getTeamSide()})
end

return BattleHeroModel
