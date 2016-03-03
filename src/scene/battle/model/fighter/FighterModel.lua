--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-12-29
-- Time: 上午10:58
-- 一切可战斗单元的基类
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------
local FighterModel = class("FighterModel")

local _fighterIDPool = {}

local _fighterPool = {}
local _fighterPoolMeta = {__mode = "kv" }
setmetatable(_fighterPool, _fighterPoolMeta)

function FighterModel.resetFighterIDPool()
    _fighterIDPool = {}
    FighterModel.traceAllFighters()
end

function FighterModel.traceAllFighters()
    local fighters = {}
    for k, v in pairs(_fighterPool) do
        fighters[k] = v:getName()
    end
    CCLog(vardump(fighters, "Fighter Pool"))
end

function FighterModel.genFighterID(fighterType)
    local lastID = _fighterIDPool[fighterType] or 0
    lastID = lastID + 1
    _fighterIDPool[fighterType] = lastID
    return string.format("%s_%04d", fighterType, lastID)
end

function FighterModel.getFighter(fighterID)
    local fighter = _fighterPool[fighterID]
    if fighter == nil then
        CCLog(fighterID, "not found")
        FighterModel.traceAllFighters()
    end
    return fighter
end

-- fighterType = {"hero", "fairy", "obstacle", "trap", "instance", "obstacle", "turret"}
function FighterModel:ctor(fighterType)
    assert(fighterType == "hero" or fighterType == "fairy" or
            fighterType == "trap" or fighterType == "instance" or
            fighterType == "obstacle" or fighterType == "egg" or
            fighterType == "turret" or fighterType == "hatredTarget",
        string.format("unknown fighter type: %s", tostring(fighterType)))

    self._fighterType = fighterType

    local fighterID = FighterModel.genFighterID(fighterType)
    self._fighterID = fighterID
    self._hittingCount = 0
    self._cell = nil
    self._view = nil
    self._eventDispatcher = nil

    -- 召唤兽
    self._summoning = {}

    -- 统计数据
    self.statistics = { damage = 0 }

    _fighterPool[fighterID] = self
end

function FighterModel:getName()
    return self._fighterID
end

function FighterModel:getFighterID()
    return self._fighterID
end

function FighterModel:getFighterType()
    return self._fighterType
end

function FighterModel:getViewInfo()
    assert(false, "Pure virtual function")
end

function FighterModel:isAttackableType()
    assert(false, "Pure virtual function")
end

function FighterModel:isHittableType()
    assert(false, "Pure virtual function")
end

function FighterModel:isMovableType()
    assert(false, "Pure virtual function")
end

function FighterModel:isMissable()
    assert(false, "Pure virtual function")
end

function FighterModel:getFormulaParams()
    assert(false, "Pure virtual function")
end

function FighterModel:onBuffAdded(buff)
    assert(false, "Pure virtual function")
end

function FighterModel:onBuffRemoved(buff)
    assert(false, "Pure virtual function")
end

function FighterModel:onBuffReplaced(oldBuff, newBuff)
    assert(false, "Pure virtual function")
end

function FighterModel:incHP(value)
    assert(false, "Pure virtual function")
end

function FighterModel:decHP(value)
    assert(false, "Pure virtual function")
end

-- 能够被锁定
function FighterModel:canMatched()
    assert(false, "Pure virtual function")
end

function FighterModel:isAlive()
    assert(false, "Pure virtual function")
end

function FighterModel:hitBy(damage, attacker)
    self:decHP(damage)
end

-- 五行类型:没有五行
function FighterModel:getElemType()
    return 0
end

-- 性别
function FighterModel:getGender()
    return nil
end

-- 基础命中
function FighterModel:getHIT()
    return 30
end

-- 基础闪避
function FighterModel:getMISS()
    return 20
end

-- 基础攻速
function FighterModel:getAtkSpeed()
    return 3000
end

-- 基础暴击
function FighterModel:getCRIT()
    return 30
end

-- 基础韧性
function FighterModel:getTEN()
    return 28
end

-- 克制
function FighterModel:restraint(fighter)
    return false
end

-- 没有加速
function FighterModel:getAttackSpeedVar()
    return 1
end

-- 是否可以消耗魔法盾抵挡伤害
function FighterModel:useSpellShield()
    return false, 0
end

function FighterModel:getMagicShieldValue(attackElemType)
   return 0
end

-- 反弹伤害万分比
function FighterModel:getAntiInjuryRatio()
    return 0
end

function FighterModel:getSkillAntiInjuryRatio()
    return 0
end

function FighterModel:incHitting()
    self._hittingCount =  self._hittingCount + 1
end

function FighterModel:decHitting()
    self._hittingCount =  self._hittingCount - 1
end

function FighterModel:isInHitting()
    return self._hittingCount > 0
end

function FighterModel:isHideTo(fighter)
    return false
end

function FighterModel:clearDebuff()
end

function FighterModel:getTeamSide()
    return nil
end

function FighterModel:getTeam()
    return nil
end

function FighterModel:getEnemyTeam()
    return nil
end

function FighterModel:addDamageStat(damage)
    self.statistics.damage = self.statistics.damage + damage
end

function FighterModel:getDamageStat()
    return self.statistics.damage
end

function FighterModel:addSummonBeast(fighter)
    table.insert(self._summoning, fighter)
end

function FighterModel:removeSummonBeast(fighter)
    table.removeItem(self._summoning, fighter)
end

function FighterModel:killedBy(killer)

end

function FighterModel:getTeammates(params)
end

function FighterModel:getEnemies(params)
end

function FighterModel:setView(view)
    self._view = view
end

function FighterModel:getView()
    return self._view
end

function FighterModel:getCell()
    assert(false, "Pure virtual function")
end

function FighterModel:getCellPos()
    local cell = self:getCell()
    if cell then
        return BattleConfig.getCellPos(cell.x, cell.y)
    else
        return nil
    end
end

function FighterModel:getLeftFreeCell()
    return nil
end

function FighterModel:getRightFreeCell()
    return nil
end

function FighterModel:getNextCell()
    return nil
end

function FighterModel:inCellsArea(area)
    assert(false, "Pure virtual function")
end

function FighterModel:cellInBitMap(scopeBitmap)
    assert(false, "Pure virtual function")
end

function FighterModel:cellPosInRect(scopeBitmap)
    assert(false, "Pure virtual function")
end

function FighterModel:cellPosInBitmap(scopeBitmap)
    assert(false, "Pure virtual function")
end

function FighterModel:setEventDispatcher(dispatcher)
    self._eventDispatcher = dispatcher
end

function FighterModel:dispatchEvent(eventName, data)
    if self._eventDispatcher then
        local event = cc.EventCustom:new(eventName)
        event.data = data
        CCLog("FighterModel(" .. self:getName() .. "):dispatchEvent(" .. eventName ..")")
        self._eventDispatcher:dispatchEvent(event)
    end
end

function FighterModel:addBuff(buff)
    CCLog("virtual function: addBuff")
end

function FighterModel:isHittable()
    return true
end

function FighterModel:getMatchedEnemy()
    return nil
end

function FighterModel:isMatchedEnemy(enemy)
    return false
end

function FighterModel:moveToPosForMoment(attackData)
    
end

function FighterModel:isBoss()
    return false
end

function FighterModel:getBulk()
    return 1
end

function FighterModel:getBloodSucking()
    return 0
end

function FighterModel:setRawPartialHP()
end

function FighterModel:improveHPCeiling(ratio)
end

function FighterModel:restoreHPCeiling(ratio)
end

function FighterModel:setMatchedEnemy(enemy)
end

function FighterModel:preload()
end

return FighterModel


