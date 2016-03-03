--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-31
-- Time: 上午10:31
-- To change this template use File | Settings | File Templates.
-- 陷进列表管理
local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleTrapModel = require("scene.battle.model.fighter.BattleTrapModel")
-------------------------------------------------------------------------------

local BattleTrapListModel = class("BattleTrapListModel")

function BattleTrapListModel:ctor(battleModel)
    self.battleModel = battleModel
    self.trapList = {}
end

function BattleTrapListModel:getTrapModel(trapID)
    for _, trapModel in ipairs(self.trapList) do
        if trapModel:getTrapID() == trapID then
            return trapModel
        end
    end
    return nil
end

function BattleTrapListModel:getAllTrapList()
    return self.trapList
end

function BattleTrapListModel:loadTrapList(trapList)
    CCLog(vardump(trapList, "BattleTrapListModel:loadTrapList()"))
    for _, trapData in ipairs(trapList) do
        local trapID = trapData.ID
        local pos = BattleConfig.configPosToCell(trapData.Pos)
        local trapModel = BattleTrapModel.new(trapID, pos, self.battleModel)
        table.insert(self.trapList, trapModel)

        trapModel:dispatchAddedEvent()
    end
end

function BattleTrapListModel:releaseTrapList()
    for _, trapModel in ipairs(self.trapList) do
        trapModel:dispatchRemovedEvent()
    end
    self.trapList = {}
end

function BattleTrapListModel:update()
    for _, trapModel in ipairs(self.trapList) do
        if trapModel:isAlive() then
            trapModel:update()
        end
    end
end

function BattleTrapListModel:onEvent(name, data)
    if name == AppEvent.UI.Battle.HeroCellChanged then
        for _, trapModel in ipairs(self.trapList) do
            trapModel:onHeroCellChangedEvent(name, data)
        end
    end
end

function BattleTrapListModel:find(trapID, pos)
    CCLog(vardump({trapID = trapID, pos = pos}, "BattleTrapListModel:find(trapID, pos)"))
    for idx, trapModel in ipairs(self.trapList) do

        local trapID = trapModel:getTrapID()
        CCLog(vardump({trapID = trapID, pos = trapModel.pos}, "BattleTrapListModel[" .. idx .. "]"))
        if trapModel:getTrapID() == trapID and trapModel.pos.x == pos.x and trapModel.pos.y == pos.y then
            return trapModel
        end
    end
    return nil
end

return BattleTrapListModel