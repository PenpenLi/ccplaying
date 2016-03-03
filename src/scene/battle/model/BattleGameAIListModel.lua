--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-30
-- Time: 下午5:59
-- To change this template use File | Settings | File Templates.
--
local BattleGameAIModel = require("scene.battle.model.BattleGameAIModel")
-------------------------------------------------------------------------------
local BattleGameAIListModel = class("BattleGameAIListModel")

function BattleGameAIListModel:ctor(battleModel)
    self.battleModel = battleModel
    self.aiList = {}

    self.triggeredAIIDList = {}
end

function BattleGameAIListModel:load(aiIDList)
    CCLog(vardump(aiIDList, "BattleGameAIListModel:load()"))
    for _, aiID in ipairs(aiIDList) do
        local aiModel = BattleGameAIModel.new(aiID, self, self.battleModel)
        table.insert(self.aiList, aiModel)
    end
end

function BattleGameAIListModel:releaseAI()
    self.aiList = {}
end

function BattleGameAIListModel:addTriggeredAI(aiModel)
    table.insert(self.triggeredAIIDList, aiModel.aiID)
end

function BattleGameAIListModel:hasTriggeredAIID(aiID)
    assert(aiID, "AI ID is nil")
    for _, id in ipairs(self.triggeredAIIDList) do
        if id == aiID then
            return true
        end
    end
    return false
end

function BattleGameAIListModel:onTriggeredAI(triggeredAiModel)
    self:addTriggeredAI(triggeredAiModel)

    for _, aiModel in ipairs(self.aiList) do
        if aiModel ~= triggeredAiModel then
            aiModel:onTriggeredAI(triggeredAiModel)
        end
    end
end

function BattleGameAIListModel:onEvent(name, data)
    for _, aiModel in ipairs(self.aiList) do
        aiModel:onEvent(name, data)
    end
end

function BattleGameAIListModel:onBattleRoundStart()
    for _, aiModel in ipairs(self.aiList) do
        aiModel:onEvent(AppEvent.UI.Battle.Enter)
    end
end

function BattleGameAIListModel:onBattleRoundEnd()
    for _, aiModel in ipairs(self.aiList) do
        -- TODO:
    end
end

return BattleGameAIListModel
