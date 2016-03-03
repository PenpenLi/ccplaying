--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-31
-- Time: 上午10:21
-- To change this template use File | Settings | File Templates.
--

local BattleObstacleModel = require("scene.battle.model.fighter.BattleObstacleModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local AI_COOL_TIME = 5
-------------------------------------------------------------------------------

local BattleObstacleListModel = class("BattleObstacleListModel")

function BattleObstacleListModel:ctor(battleModel)
    self.battleModel = battleModel
    self.obstacleList = {}

    self.coolLeft = 1
end

function BattleObstacleListModel:loadObstacleList(obstacleDataList)
    CCLog(vardump(obstacleDataList, "BattleObstacleListModel:loadObstacleList"))
    for _, obstacleData in ipairs(obstacleDataList) do
        local obstacleID = obstacleData.ID
        local pos = BattleConfig.configPosToCell(obstacleData.Pos)

        local obstacleModel = BattleObstacleModel.new(obstacleID, pos, self)
        table.insert(self.obstacleList, obstacleModel)
        obstacleModel:dispatchAddedEvent()
    end
end

function BattleObstacleListModel:remove(obstacleModel)
    obstacleModel:dispatchRemovedEvent()
    table.removeItem(self.obstacleList, obstacleModel)
end

function BattleObstacleListModel:releaseObstacleList()
    for _, obstacleModel in ipairs(self.obstacleList) do
        obstacleModel:dispatchRemovedEvent()
    end
    self.obstacleList = {}
end

function BattleObstacleListModel:getObstacleViews()
    local viewList = {}
    for _, obstacle in ipairs(self.obstacleList) do
        local view = obstacle:getView()
        table.insert(viewList, view)
    end
    return viewList
end

function BattleObstacleListModel:hasRoadBlockObstacle()
    if #self.obstacleList == 0 then
        return false
    end

    for _, obstacle in ipairs(self.obstacleList) do
        if obstacle:getObstacleType() == enums.ObstacleType.RoadBlock then
            return true
        end
    end
    return false
end

function BattleObstacleListModel:getRoadBlockObstacleList()
    local hittableObstacleList = {}
    for _, obstacle in ipairs(self.obstacleList) do
        if obstacle:getObstacleType() == enums.ObstacleType.RoadBlock then
            table.insert(hittableObstacleList, obstacle)
        end
    end
    return hittableObstacleList
end

function BattleObstacleListModel:hasObstacle()
    return #self.obstacleList > 0
end

function BattleObstacleListModel:update(battleModel)
    if #self.obstacleList > 0 then
        for _, obstacle in ipairs(self.obstacleList) do
            obstacle:update()
        end

        if self.coolLeft <= 0 then
            self.coolLeft = AI_COOL_TIME
            battleModel:onObstacleAIEvent()
        else
            self.coolLeft = self.coolLeft - BattleConfig.TIME_UNIT
        end
    end
end

function BattleObstacleListModel:find(obstacleID, pos)
    for _, obstacle in ipairs(self.obstacleList) do
        if obstacle.obstacleID == obstacleID and obstacle.pos.x == pos.x and obstacle.pos.y == pos.y then
            return obstacle
        end
    end
    return nil
end

return BattleObstacleListModel