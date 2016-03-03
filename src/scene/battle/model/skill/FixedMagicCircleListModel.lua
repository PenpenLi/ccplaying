--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-27
-- Time: 下午6:12
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-23
-- Time: 下午6:16
-- 魔法队列阵管理
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local FixedMagicCircleListModel = class("FixedMagicCircleListModel")

function FixedMagicCircleListModel:ctor(battleModel)
    self.lastID = 0
    self.battleModel = battleModel
    self.magicCircleList = {}
end

function FixedMagicCircleListModel:genID()
    self.lastID = self.lastID + 1
    return self.lastID
end

function FixedMagicCircleListModel:add(magicCircle)
    table.insert(self.magicCircleList, magicCircle)
    self:onMagicCircleAdded(magicCircle)
end

function FixedMagicCircleListModel:remove(magicCircle)
    local index = self:index(magicCircle.ID)

    if index then
        local magicCircle = self.magicCircleList[index]
        self:onMagicCircleRemoved(magicCircle)
        table.remove(self.magicCircleList, index)
        return true
    end
    return false
end

function FixedMagicCircleListModel:removeByID(magicCircleID)
    local index = self:index(magicCircleID)

    if index then
        local magicCircle = self.magicCircleList[index]
        self:onMagicCircleRemoved(magicCircle)
        table.remove(self.magicCircleList, index)
        return true
    end
    return false
end

function FixedMagicCircleListModel:removeByAttackerAndSkillID(attacker, skillID)
    local magicCircle = self:findByAttackerAndSkillID(attacker, skillID)
    if magicCircle then
       self:remove(magicCircle)
    end
end

function FixedMagicCircleListModel:clear()
    local oldMagicCircleList = self.magicCircleList

    for _, magicCircle in ipairs(oldMagicCircleList) do
        self:onMagicCircleRemoved(magicCircle)
    end

    self.magicCircleList = {}
end

function FixedMagicCircleListModel:index(magicCircleID)
    for idx, magicCircle in ipairs(self.magicCircleList) do
        if magicCircle.ID == magicCircleID then
            return idx
        end
    end

    return nil
end

function FixedMagicCircleListModel:find(magicCircleID)
    for idx, magicCircle in ipairs(self.magicCircleList) do
        if magicCircle.ID == magicCircleID then
            return magicCircle
        end
    end

    return nil
end

function FixedMagicCircleListModel:findByAttackerAndSkillID(attacker, skillID)
    for idx, magicCircle in ipairs(self.magicCircleList) do
        if magicCircle:getAttacker() == attacker and magicCircle:getSkillID() == skillID then
            return magicCircle
        end
    end

    return nil
end

function FixedMagicCircleListModel:dump()
    local ids = {}
    for idx, magicCircle in ipairs(self.magicCircleList) do
        table.insert(ids, magicCircle.ID)
    end
    CCLog(vardump(ids, "FixedMagicCircleList.IDList"))
end

function FixedMagicCircleListModel:onMagicCircleAdded(magicCircle)
    self.battleModel:dispatchEvent(AppEvent.UI.Battle.FixedMagicCircleAdded, {
        ID = magicCircle.ID,
        cell = magicCircle:getCell(),
        skillID = magicCircle:getSkillID(),
        serialID = magicCircle:getSerialID(),
    })
end

function FixedMagicCircleListModel:onMagicCircleRemoved(magicCircle)
    self.battleModel:dispatchEvent(AppEvent.UI.Battle.FixedMagicCircleRemoved, {
        ID = magicCircle.ID,
        serialID = magicCircle:getSerialID(),
    })
end

function FixedMagicCircleListModel:update(battleModel)
--    CCLog("FixedMagicCircleListModel:update()", #self.magicCircleList)
    for _, magicCircle in ipairs(self.magicCircleList) do
        magicCircle:update(battleModel)
    end
    
    for i = #self.magicCircleList, 1, -1 do
        local magicCirle = self.magicCircleList[i]
        if magicCirle:isFinish() then
            table.remove(self.magicCircleList, i)

            self:onMagicCircleRemoved(magicCirle)
        end
    end
end

function FixedMagicCircleListModel:hasPrison()
    for _, magicCircle in ipairs(self.magicCircleList) do
        if magicCircle.isPrison then
            return true
        end
    end
    return false
end

function FixedMagicCircleListModel:getPrisonArea(fighter)
    for _, magicCircle in ipairs(self.magicCircleList) do
        if magicCircle.isPrison then
            return magicCircle:getPrisonArea(fighter)
        end
    end
    return nil
end

return FixedMagicCircleListModel
