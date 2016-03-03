--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-30
-- Time: 下午5:50
-- 游戏关卡AI
--

local FighterModel = require("scene.battle.model.fighter.FighterModel")
-------------------------------------------------------------------------------
local BattleGameAIModel = class("BattleGameAIModel")

function BattleGameAIModel:ctor(aiID, gameAIList, battleModel)
    self.gameAIList = gameAIList
    self.battleModel = battleModel
    self.aiID = aiID
    self.aiData = BaseConfig.GetAI(aiID)
    self.instanceSkillModel = nil

    self.handlers = {}
    local triggerType = self.aiData.Trigger

    CCLog(vardump(self.aiData, "AI Data"))
    if triggerType == enums.AITriggerCondition.EnterBattle then
        -- 进入战斗后触发
        CCLog("AI触发类型: 进入战斗后触发")
        self.handlers[AppEvent.UI.Battle.Enter] = handler(self, self.onEnterBattle)
    elseif triggerType == enums.AITriggerCondition.MonsterHPUnderHalf then
        -- 指定怪物血量降低到一定比例触发
        CCLog("AI触发类型: 指定怪物血量降低到一定比例触发")
        self.handlers[AppEvent.UI.Battle.HPChange] = handler(self, self.onHPChange)
    elseif triggerType == enums.AITriggerCondition.MonsterDie then
        -- 指定怪物死亡触发
        CCLog("AI触发类型: 指定怪物死亡触发")
        self.handlers[AppEvent.UI.Battle.FighterDie] = handler(self, self.onHeroDie)
    elseif triggerType == enums.AITriggerCondition.Obstacle then
        -- 障碍破碎前
        CCLog("AI触发类型: 障碍破碎前")
        self.handlers[AppEvent.UI.Battle.Obstacle] = handler(self, self.onObstacle)
    elseif triggerType == enums.AITriggerCondition.TurnIntoEgg then        
         -- 变蛋
        CCLog("AI触发类型: 英雄变蛋")
        self.handlers[AppEvent.UI.Battle.TurnIntoEgg] = handler(self, self.onTurnIntoEgg)
    elseif triggerType == enums.AITriggerCondition.WithObstacle then
        self.handlers[AppEvent.UI.Battle.ObstacleAdded] = handler(self, self.onObstacleAdded)
        self.handlers[AppEvent.UI.Battle.ObstacleRemoved] = handler(self, self.onObstacleRemoved)
    else
        CCLog("未知AI触发类型:", triggerType)
    end
end

function BattleGameAIModel:getID()
    return self.aiID
end

function BattleGameAIModel:meetPreAICondition()
    local preAI = self.aiData.PreAI

    if preAI == nil or preAI == 0 then
        return true
    else
        if self.gameAIList then
            return self.gameAIList:hasTriggeredAIID(preAI)
        else
            assert(false, "AI has no owner")
        end
    end
    return false
end

function BattleGameAIModel:trigger(eventName, eventData)
    CCLog(vardump({eventName, eventData}, "BattleGameAIModel:trigger"))

    local aiData = self.aiData
    local time = aiData.LagTime

    if time == 0 then
        self:doTrigger(eventName, eventData)
    else
        self.battleModel:addAction(time, function()
            if self.battleModel:getState() == "fight" then
                self:doTrigger(eventData, eventData)
            end
        end)
    end
end

function BattleGameAIModel:doTrigger(eventName, eventData)
    local aiData = self.aiData

    CCLog(vardump({aiData, eventName, eventData}, "BattleGameAIModel:doTrigger"))

    if aiData.AIType == enums.BattleAIType.Dialogue then
        CCLog("AI类型: 怪物说话")
        self.battleModel:dispatchEvent(AppEvent.UI.Battle.Dialogue, {teamSide = "right", monsterID = self.aiData.Monster, dialogueID = self.aiData.Content})
    elseif aiData.AIType == enums.BattleAIType.MonsterSkill then
        CCLog("AI类型: 怪物使用技能")
        self.battleModel:dispatchEvent(AppEvent.UI.Battle.MonsterSkill, {skillID = self.aiData.Content, fighterID = eventData.fighterID})
    elseif aiData.AIType == enums.BattleAIType.SummonMonster then
        CCLog("AI类型: 出现新的怪物（敌方）")
    elseif aiData.AIType == enums.BattleAIType.SummonNPC then
        CCLog("AI类型: 出现新的NPC（友方）")
    elseif aiData.AIType == enums.BattleAIType.InstanceSkill then
        CCLog("AI类型: 关卡技能")
        if eventName == AppEvent.UI.Battle.ObstacleRemoved then
            local skillID = aiData.Content
            self.battleModel:dispatchEvent(AppEvent.UI.Battle.RemoveFixedMagicCircle, {fighterID = self.battleModel:getInstanceFighter():getFighterID(), skillID = skillID})
        else
            local skillID = aiData.Content
            local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")

            local attackData = AttackDataModel.new(self.battleModel:getInstanceFighter(), self.battleModel, skillID, 1)
            self.battleModel:dispatchEvent(AppEvent.UI.Battle.AttackComplete, attackData:encode())
        end
    elseif aiData.AIType == enums.BattleAIType.MonsterAI then
        CCLog("AI类型: 怪物相关AI 如双生怪")
    elseif aiData.AIType == enums.BattleAIType.RandomDialogue then
        CCLog("AI类型: 障碍破碎前")
        self.battleModel:dispatchEvent(AppEvent.UI.Battle.RandomDialogue, {teamSide = "right", monsterID = self.aiData.Monster, dialogueID = self.aiData.Content})
    elseif aiData.AIType == enums.BattleAIType.Resurrection then
        CCLog("AI类型: 另一个怪物复活自己")
        self.battleModel:dispatchEvent(AppEvent.UI.Battle.ResurrectionMonster, {dstMonsterID = self.aiData.Content, srcMonsterID = self.aiData.Monster})
    elseif aiData.AIType == enums.BattleAIType.Transfiguration then
        CCLog("AI类型：变身")
        self.battleModel:dispatchEvent(AppEvent.UI.Battle.Transfiguration, {dstMonsterID = self.aiData.Content, srcMonsterID = self.aiData.Monster})
    else
        CCLog("未知AI类型：", aiData.AIType)
    end

    self.gameAIList:onTriggeredAI(self)
end

function BattleGameAIModel:onTriggeredAI(aiModel)
    CCLogf("BattleGameAIModel(%d):onTriggeredAI(%d)", self.aiData.ID, aiModel.aiData.ID)
    local triggerType = self.aiData.Trigger

    if triggerType == enums.AITriggerCondition.None then
        local preAI = self.aiData.PreAI
        if preAI == aiModel:getID() then
            self:trigger(nil, nil)
        end
    end
end

function BattleGameAIModel:onEnterBattle(name, data)
    CCLog("BattleGameAIModel:onEnterBattle()")
    if self:meetPreAICondition() then
        self:trigger(name, data)
    end
end

function BattleGameAIModel:onHPChange(name, data)
    CCLog("BattleGameAIModel:onHPChange")
    if self:meetPreAICondition() then
        local monterID = self.aiData.TriggerMonster
        local fighterID = data.fighterID
        local heroModel = FighterModel.getFighter(fighterID)

        if heroModel:getHeroID() == monterID then
            local fullHP = heroModel:getFullHP()
            local halfHP = math.floor(fullHP / 2)
            local curHP = heroModel:getHP()
            local prevHP = heroModel:getPreviousHP()
            if curHP <= halfHP and prevHP > halfHP and heroModel:getHP() == heroModel:getLowestHP() then
                self:trigger(name, data)
            end
        end
    else
        CCLog("BattleGameAIModel:onHPChange PreAICondition fail")
    end
end

function BattleGameAIModel:onHeroDie(name, data)
    if self:meetPreAICondition() then
        local monterID = self.aiData.TriggerMonster
        local fighterID = data.fighterID
        local heroModel = FighterModel.getFighter(fighterID)
        if heroModel:getHeroID() == monterID then
            self:trigger(name, data)
        end
    end
end

function BattleGameAIModel:onTurnIntoEgg(name, data)
    if self:meetPreAICondition() then
        self:trigger(name, data)
    end
end

function BattleGameAIModel:onObstacle(name, data)
    if self:meetPreAICondition() then
        self:trigger(name, data)
    end
end

function BattleGameAIModel:onObstacleAdded(name, data)
    if self:meetPreAICondition() then
        self:trigger(name, data)
    end
end

function BattleGameAIModel:onObstacleRemoved(name, data)
    if self:meetPreAICondition() then
        self:trigger(name, data)
    end
end

function BattleGameAIModel:onEvent(name, data)
    local handler = self.handlers[name]
    if handler then
        CCLog(vardump({name = name, data = data}, "handlerEvent"))
        handler(name, data)
    end
end

function BattleGameAIModel:onBattleRoundStart()
    CCLog("BattleGameAIModel:onRoundStart()")
    self:onEnterBattle()
end

function BattleGameAIModel:onBattleRoundEnd()

end

return BattleGameAIModel
