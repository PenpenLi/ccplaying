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
local FollowMagicCircleListModel = require("scene.battle.model.skill.FollowMagicCircleListModel")
-------------------------------------------------------------------------------
local BattleTrapModel = class("BattleTrapModel", FighterModel)

function BattleTrapModel:ctor(trapID, pos, battleModel)
    BattleTrapModel.super.ctor(self, "trap")

    self.battleModel = battleModel
    self.trapID = trapID
    self.pos = pos -- 左下为中心点，大小为Range
    self.trapData = assert(BaseConfig.GetTrap(trapID), string.format("trap:%d", trapID))
    self.view = nil

    local skillData = BaseConfig.GetHeroSkill(self.trapData.Skill, 1)
    self.skillData = skillData
    self.intervalLeft = skillData.CD

    self._fullHP = self.trapData.HP
    self._currentHP = self._fullHP
    self.triggeredFighterID = nil

    self:setEventDispatcher(battleModel.eventDispatcher)
end

function BattleTrapModel:getTrapID()
    return self.trapID
end

--- begin FighterModel 虚函数 -------
function BattleTrapModel:isAttackableType()
    return true
end

function BattleTrapModel:isHittableType()
    return true
end

function BattleTrapModel:isMovableType()
    return false
end

function BattleTrapModel:isMissable()
    return false
end

function BattleTrapModel:canMatched()
    return false
end

function BattleTrapModel:getCell()
    return self.pos
end

function BattleTrapModel:inCellsArea(area)
    local x = self.pos.x
    local y = self.pos.y

    for _, cell in ipairs(area) do
        if self:isCellInTrap(cell) then
            return true
        end
    end

    return false
end

function BattleTrapModel:cellInBitMap(scopeBitmap)
    local startX = self.pos.x
    local endX = self.pos.x + self.trapData.Range
    local startY = self.pos.y
    local endY = self.pos.y + self.trapData.Range

    for y = startY, endY do
        for x = startX, endX do
            if scopeBitmap:get(x, y) then
                return true
            end
        end
    end

    return false
end

function BattleTrapModel:cellPosInRect(rect)
    local startX = self.pos.x
    local endX = self.pos.x + self.trapData.Range
    local startY = self.pos.y
    local endY = self.pos.y + self.trapData.Range

    for y = startY, endY do
        for x = startX, endX do
            local pos = BattleConfig.getCellPos(x, y)

            if cc.rectContainsPoint(rect, pos) then
                return true
            end
        end
    end

    return false
end

function BattleTrapModel:cellPosInBitmap(bitmap)
    local startX = self.pos.x
    local endX = self.pos.x + self.trapData.Range
    local startY = self.pos.y
    local endY = self.pos.y + self.trapData.Range

    for y = startY, endY do
        for x = startX, endX do
            local pos = BattleConfig.getCellPos(x, y)

            if bitmap:get(pos.x, pos.y) then
                return true
            end
        end
    end

    return false
end

function BattleTrapModel:getFormulaParams()
    local params = {
        ATK = self.trapData.Attack,
        DEF = 0,
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
        WX = self.trapData.WX,
    }

    return params
end
--- end FighterModel 虚函数 -------

function BattleTrapModel:getHP()
    return self._currentHP
end

function BattleTrapModel:getFullHP()
    return self._fullHP
end

function BattleTrapModel:isAlive()
    return self._currentHP > 0
end

function BattleTrapModel:decHP(hp)
    local hp = math.floor(hp)
    self._currentHP = self._currentHP - hp
    if self._currentHP <= 0 then
        self:dispatchRemovedEvent()
    end
end

function BattleTrapModel:hitBy(damage, attacker)
    self:decHP(damage)
end

function BattleTrapModel:setView(view)
    self.view = view
end

function BattleTrapModel:getView()
    return self.view
end

function BattleTrapModel:update()
    if not self.triggeredFighterID then
        return
    end

    self.intervalLeft = self.intervalLeft - BattleConfig.TIME_UNIT
    if self.intervalLeft <= 0 then
        self:updateInterval()
    end
end

function BattleTrapModel:updateInterval()
    if self.triggeredFighterID then
        local fighter = FighterModel.getFighter(self.triggeredFighterID)
        if fighter and fighter:isAlive() then
            local attackData = AttackDataModel.new(self, self._battleModel, self.trapData.Skill, 1, {self.triggeredFighterID})
            self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
        else
            self.triggeredFighterID = nil
        end
    end
end

function BattleTrapModel:isCellInTrap(cell)
    local startX = self.pos.x
    local endX = self.pos.x + self.trapData.Range
    local startY = self.pos.y
    local endY = self.pos.y + self.trapData.Range

    if cell.x >= startX and cell.x < endX and cell.y >= startY and cell.y < endY then
        return true
    end
    return false
end

function BattleTrapModel:onHeroCellChangedEvent(name, data)
    CCLog(vardump({name = name, data = data}, "BattleTrapModel:onHeroCellChangedEvent(name, data)"))

    local fighterID = data.fighterID
    local fighter = FighterModel.getFighter(fighterID)
    if fighter:getTeamSide() ~= "left" then
        return
    end

    local newPos = data.new
    local oldPos = data.old

    if not self:isCellInTrap(oldPos) and self:isCellInTrap(newPos) then
        self:trigger(data.fighterID)
        self.triggeredFighterID = fighterID
    end
end

function BattleTrapModel:trigger(fighterID)
    local attackData = AttackDataModel.new(self, self._battleModel, self.trapData.Skill, 1, {fighterID})
    self:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())

    self:dispatchEvent(AppEvent.UI.Battle.TrapSkill, {fighterID = self:getFighterID(), targetID = fighterID})
end

function BattleTrapModel:dispatchRemovedEvent()
    self:dispatchEvent(AppEvent.UI.Battle.TrapRemoved, {fighterID = self:getFighterID()})
end

function BattleTrapModel:dispatchAddedEvent()
    self:dispatchEvent(AppEvent.UI.Battle.TrapAdded, {fighterID = self:getFighterID(), trapID = self.trapID , pos = self.pos, range = self.trapData.Range})
end

return BattleTrapModel