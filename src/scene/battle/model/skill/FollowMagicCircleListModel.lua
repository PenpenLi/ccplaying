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

local FollowMagicCircleListModel = class("FollowMagicCircleListModel")

function FollowMagicCircleListModel:ctor(fighter)
    self.fighter = fighter
    self.magicCircleList = {}
end

function FollowMagicCircleListModel:add(magicCircle)
    table.insert(self.magicCircleList, magicCircle)
    self:onMagicCircleAdded(magicCircle)
end

function FollowMagicCircleListModel:remove(magicCircle)
    local index = self:index(magicCircle)

    if index then
        local magicCircle = self.magicCircleList[index]
        table.remove(self.magicCircleList, index)

        self:onMagicCircleRemoved(magicCircle)
        CCLog("FollowMagicCircleListModel:remove(magicCircle)")
        CCLogCaller(5)
    end
end

function FollowMagicCircleListModel:clear()
    local magicCircleList = self.magicCircleList

    self.magicCircleList = {}
    for _, magicCircle in ipairs(magicCircleList) do
        self:onMagicCircleRemoved(magicCircle)
        CCLog("FollowMagicCircleListModel:clear()")
    end
end

function FollowMagicCircleListModel:index(magicCircle)
    local skillID = magicCircle.attackData.skillData.id
    return self:indexBySkillID(skillID)
end

function FollowMagicCircleListModel:indexBySkillID(skillID)
    for idx, magicCircle in ipairs(self.magicCircleList) do
        local mcskillID = magicCircle.attackData.skillData.id
        if mcskillID == skillID then
            return idx
        end
    end

    return nil
end

function FollowMagicCircleListModel:onMagicCircleAdded(magicCircle)
    self.fighter:dispatchEvent(AppEvent.UI.Battle.FollowMagicCircleAdded, {fighterID = self.fighter:getFighterID(), skillID = magicCircle:getSkillID()})
end

function FollowMagicCircleListModel:onMagicCircleRemoved(magicCircle)
    self.fighter:dispatchEvent(AppEvent.UI.Battle.FollowMagicCircleRemoved,{fighterID = self.fighter:getFighterID(), skillID = magicCircle:getSkillID()})
end

function FollowMagicCircleListModel:update(battleModel)
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

return FollowMagicCircleListModel
