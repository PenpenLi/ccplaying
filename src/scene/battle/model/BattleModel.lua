local BattleTeamModel = require("scene.battle.model.BattleTeamModel")
local BattleRecordData = require("scene.battle.player.BattleRecordData")
--local FormationManager = require("data.FormationManager")
--local HeroDataManager = require("data.HeroDataManager")
local FixedMagicCircleModel = require("scene.battle.model.skill.FixedMagicCircleModel")
local FixedMagicCircleListModel = require("scene.battle.model.skill.FixedMagicCircleListModel")
local FollowMagicCircleModel = require("scene.battle.model.skill.FollowMagicCircleModel")
local ContinuousSkillModel = require("scene.battle.model.attack.ContinuousSkillModel")
local BattleGameAIListModel = require("scene.battle.model.BattleGameAIListModel")
local BattleTrapListModel = require("scene.battle.model.fighter.BattleTrapListModel")
local BattleObstacleListModel = require("scene.battle.model.fighter.BattleObstacleListModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local ElemType = require("config.ElemType")
local BattleFairyModel = require("scene.battle.model.fighter.BattleFairyModel")
local AttackSubDataModel = require("scene.battle.model.attack.AttackSubDataModel")
local InstanceModel = require("scene.battle.model.fighter.InstanceModel")
local FighterModel = require("scene.battle.model.fighter.FighterModel")
local ComboHitModel = require("scene.battle.model.skill.ComboHitModel")
local random = require("random")
-------------------------------------------------------------------------------

local BattleModel = class("BattleModel")

function BattleModel:ctor(eventDispatcher, params, attackerFormInfo, controller)
    FighterModel.resetFighterIDPool()

--    local guideJson = [===[
--[
--   {"map": "S00E02_map",
--   "nodeSequence": [
--   {
--    "Monster":
--    [
--      {
--       "ID":10000006,
--       "Pos":{"x":17,"y":5}
--       },
--      {
--       "ID":10000005,
--       "Pos":{"x":15,"y":3}
--       },
--      {
--       "ID":10000007,
--       "Pos":{"x":17,"y":1}
--       }
--    ],
--    "Npc":
--    [
--      {
--       "ID":10000003,
--       "Pos":{"x":6,"y":5}
--       },
--      {
--       "ID":10000001,
--       "Pos":{"x":2,"y":3}
--       },
--      {
--       "ID":10000002,
--       "Pos":{"x":4,"y":3}
--       },
--      {
--       "ID":10000004,
--       "Pos":{"x":6,"y":1}
--       }
--    ],
--    "BeginStory": 100011,
--    "EndStory": 100012
--  },
--
--  {
--    "Monster":
--    [
--      {
--       "ID":10000005,
--       "Pos":{"x":15,"y":3}
--       },
--      {
--       "ID":10000010,
--       "Pos":{"x":17,"y":3}
--       },
--      {
--       "ID":10000011,
--       "Pos":{"x":19,"y":3}
--       }
--    ],
--    "Npc":
--    [
--      {
--       "ID":10000009,
--       "Pos":{"x":2,"y":5}
--       },
--      {
--       "ID":10000003,
--       "Pos":{"x":6,"y":5}
--       },
--      {
--       "ID":10000002,
--       "Pos":{"x":4,"y":3}
--       },
--      {
--       "ID":10000008,
--       "Pos":{"x":2,"y":1}
--       },
--      {
--       "ID":10000004,
--       "Pos":{"x":6,"y":1}
--       }
--    ],
--    "BeginStory": 100013,
--    "EndStory": 0
--  }
--]
--}
--]
--]===]
--
--    local guideParams = json.decode(guideJson)[1]
--    params =  {battleType = "GUIDE", map = guideParams.MapID, nodeSequence = guideParams.nodeSequence}
--    -- end test

    attackerFormInfo = attackerFormInfo or {}

    params = params or {}
    self._random = random.new()
    self.controller = controller
    self.params = params
    self.attackerForm = attackerFormInfo.form
    self.instanceFighter = InstanceModel.new(self)

    local BattleFormData = require("scene.form.BattleFormData")
    self.attackerFormAdd = BattleFormData.getFormAddition(attackerFormInfo.form)
    self.defenderFormAdd = nil
    
    self.eventDispatcher = eventDispatcher
    local WHITE = cc.c4f(1.0, 1.0, 1.0, 0.3)
    local GREEN = cc.c4f(0.0, 1.0, 0.0, 0.3)

    self.leftTeam = BattleTeamModel.new("left", eventDispatcher, self)
    self.rightTeam = BattleTeamModel.new("right", eventDispatcher, self)

    --self.gridBitmap = bitarray2d.new(BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT)
    
    --self.nextStepGrid = {}
    self.timeLeft = BattleConfig.ROUND_TIME

    -- 银币BOSS特殊处理
    if params.battleType == "PVE" and params.nodeID == 2 then
        self.timeLeft = 30 / BattleConfig.TIME_UNIT  -- 一回合的时间(tick)
    end

    self.totalTimeTick = 0
    self.rageSkillCooling = 0
    self.state = "none" -- [none, init, starting, entrance, fight, ending, end, idle, win, fail, timeout]

    --self.actionQueue = {}
    self.threadList = {}

    self.lastSerNum = nil

    self.battleRecordData = BattleRecordData.new()
    self.isPlayback = false

    self.roundIndex = 0 -- 副本战斗回合数

    self.gameAI       = BattleGameAIListModel.new(self)
    self.gameTrap     = BattleTrapListModel.new(self)
    self.gameObstacle = BattleObstacleListModel.new(self)
    self.magicCircleList = FixedMagicCircleListModel.new(self)     -- 魔法阵
    -- self.paused = false
    -- self.aniPaused = false

    self.pausedCount = 0

    self.finished = false
    self.autoBattle = false
    self.friendTimer = nil
    self.frameDeadList = {} -- 当前

    self.skillExtraHandlers = self:getSkillExtraAffectHandlers()

    CCLog(vardump({params = params, attackerForm = attackerFormInfo.form, formAdd = self.attackerFormAdd}, "Params"))   

    if params.battleType == "PVE" then
        local nodeSeq = params.nodeSequence

        self.ATKForm = self:getAttackerForm()
        self.DEFFormList = {}

        for idx, round in ipairs(nodeSeq) do
            local monsters = round.Monster

            local battleUnit = {}
            table.insert(self.DEFFormList, battleUnit)
            for _, monsterUnit in ipairs(monsters) do
                local cell = BattleConfig.configPosToCell(assert(monsterUnit.Pos, "monster pos"))
                local monsterID = monsterUnit.ID
                local monsterData = assert(BaseConfig.GetMonster(monsterID), string.format("MonsterID:%d", monsterID))

                table.insert(battleUnit, {cell = cell, type = "monster", data = monsterData})
            end
        end
    elseif params.battleType == "PVP" then
        self.leftTeam:setRage(20)
        self.rightTeam:setRage(20)

        self.ATKForm = self:getAttackerForm()
        self.DEFFormList = {}

        if params.fairyData then
            self.rightTeam:setFairyModel(BattleFairyModel.new(params.fairyData, self.rightTeam))
        end

        local form = params.form.Hero or {}
        self.defenderFormAdd = BattleFormData.getFormAddition(form)

        local heroList = params.heroList

        local function HeroList_find(heroList, ID)
            for _, heroData in ipairs(heroList) do
               if heroData.ID == ID then
                   return heroData
               end
            end
            CCLog("hero:", ID, " not found")
            return nil
        end

        local battleUnit = {}
        table.insert(self.DEFFormList, battleUnit)

        for idx, unit in ipairs(form) do
            local cell = BattleConfig.getSlotCell(unit.X, unit.Y)
            local heroID = unit.ID
            local heroData = HeroList_find(heroList, heroID)

            table.insert(battleUnit, {cell = cell, type = "hero", data = heroData})
        end

        if self.params.isFriendGuard then
            CCLog("有仙友护卫")
            self.friendUnits = {}

            local form = params.friendForm.Hero
            local heroList = params.friendHeroList

            local function HeroList_find(heroList, ID)
                for _, heroData in ipairs(heroList) do
                   if heroData.ID == ID then
                       return heroData
                   end
                end
                CCLog("hero:", ID, " not found")
                return nil
            end

            local battleUnit = {}
            table.insert(self.friendUnits, battleUnit)

            for idx, unit in ipairs(form) do
                local cell = BattleConfig.getSlotCell(unit.X, unit.Y)
                local heroID = unit.ID
                local heroData = HeroList_find(heroList, heroID)

                table.insert(battleUnit, {cell = cell, type = "friend", data = heroData})
            end
        end
    elseif params.battleType == "Tower" then
        CCLog(vardump({heroRP = params.heroRP, enemyRP = params.enemyRP}, "Tower Rage"))
        self.leftTeam:setRage(params.heroRP)
        self.rightTeam:setRage(params.enemyRP)

        if params.fairyData then
            self.rightTeam:setFairyModel(BattleFairyModel.new(params.fairyData, self.rightTeam))
        end

        self.leftTeam:setTowerHerosHPRemain(params.climbHero)
        self.rightTeam:setTowerHerosHPRemain(params.climbEnemy)

        self.ATKForm = self:getAttackerForm()
        self.DEFFormList = {}

        local form = params.form.Hero
        self.defenderFormAdd = BattleFormData.getFormAddition(form)        

        local heroList = params.heroList

        local function HeroList_find(heroList, ID)
            for _, heroData in ipairs(heroList) do
                if heroData.ID == ID then
                    return heroData
                end
            end
            CCLog("hero:", ID, " not found")
            return nil
        end

        local battleUnit = {}
        table.insert(self.DEFFormList, battleUnit)

        for idx, unit in ipairs(form) do
            local cell = BattleConfig.getSlotCell(unit.X, unit.Y)
            local heroID = unit.ID
            local heroData = HeroList_find(heroList, heroID)

            table.insert(battleUnit, {cell = cell, type = "hero", data = heroData})
        end
    elseif params.battleType == "GUIDE" then
        -- self._random:seed(0)

        self.guideStepInfo = {
            step  = 1,
            open  = {false, false, false},
            close = {false, false, false},
        }

        local nodeSeq = params.nodeSequence

        self.ATKForm = self:getAttackerForm()
        self.DEFFormList = {}

        for idx, round in ipairs(nodeSeq) do
            local monsters = round.Monster

            local battleUnit = {}
            table.insert(self.DEFFormList, battleUnit)
            for _, monsterUnit in ipairs(monsters) do
                local cell = BattleConfig.configPosToCell(assert(monsterUnit.Pos, "monster pos"))
                local monsterID = monsterUnit.ID
                local monsterData = assert(BaseConfig.GetMonster(monsterID), string.format("MonsterID:%d", monsterID))

                table.insert(battleUnit, {cell = cell, type = "monster", data = monsterData})
            end
        end
        -- self.battleUnits = {}
        -- self.attackUnits = {}

        -- local nodeSeq = params.nodeSequence

        -- for idx, round in ipairs(nodeSeq) do
        --     local monsters = round.Npc

        --     local battleUnit = {}
        --     table.insert(self.attackUnits, battleUnit)
        --     for _, monsterUnit in ipairs(monsters) do
        --         local cell = BattleConfig.configPosToCell(assert(monsterUnit.Pos, "monster pos"))
        --         local monsterID = monsterUnit.ID
        --         local monsterData = assert(BaseConfig.GetMonster(monsterID), string.format("MonsterID:%d", monsterID))

        --         table.insert(battleUnit, {cell = cell, type = "monster", data = monsterData})
        --     end
        -- end

        -- for idx, round in ipairs(nodeSeq) do
        --     local monsters = round.Monster

        --     local battleUnit = {}
        --     table.insert(self.battleUnits, battleUnit)
        --     for _, monsterUnit in ipairs(monsters) do
        --         local cell = BattleConfig.configPosToCell(assert(monsterUnit.Pos, "monster pos"))
        --         local monsterID = monsterUnit.ID
        --         local monsterData = assert(BaseConfig.GetMonster(monsterID), string.format("MonsterID:%d", monsterID))

        --         table.insert(battleUnit, {cell = cell, type = "monster", data = monsterData})
        --     end
        -- end
    end

    if DEBUG > 0 then
        pcall(function()
            local formList = {}
            for _, battleUnit in ipairs(self.DEFFormList) do
                local form = {}
                table.insert(formList, form)
                for _, unit in ipairs(battleUnit) do
                    local name = unit.data.Name
                    if name == nil then
                        local heroID = unit.data.ID
                        local hero = BaseConfig.GetHero(heroID)
                        name = hero and hero.name  or "<NULL>"
                    end 
                    table.insert(form,  name)
                end
            end
            CCLog(vardump(formList, "敌方阵容"))
        end)
    end

    if attackerFormInfo.fairyData and attackerFormInfo.fairyData ~= 0 then
        self.leftTeam:setFairyModel(BattleFairyModel.new(attackerFormInfo.fairyData, self.leftTeam))
    end

            -- 设置阵容加成
    self.leftTeam:setFormAddition(self.attackerFormAdd)
    self.rightTeam:setFormAddition(self.defenderFormAdd)

    -- 竞技场防守方加血 %20
    if params.battleFormType == GameCache.FORM_TYPE_ARENA then
        self.leftTeam:setExtraHPAddition(0.50)
        self.rightTeam:setExtraHPAddition(0.60)
        CCLog("竞技场血量 调整")
    end

    if params.battleFormType == GameCache.FORM_TYPE_HOME then
        local HomeLootTimer = require("scene.battle.helper.HomeLootTimer")
        self.timer = HomeLootTimer.new(self, "掠夺倒计时:")
        self.timer:setEndCallback(function() self:battleTimeout() end)
    end
end

function BattleModel:cleanup()
    if self.timer then
        self.timer:cleanup()
    end
end

function BattleModel:random(...)
    return self._random:value(...)
end

function BattleModel:getInstanceFighter()
    return self.instanceFighter
end

function BattleModel:getFairyModel(teamSide)
    local fairyModel = nil
    if teamSide == "left" then
        fairyModel = self.leftTeam:getFairyModel()
    elseif teamSide == "right" then
        fairyModel = self.rightTeam:getFairyModel()
    end
    return fairyModel
end

function BattleModel:getTrapModel(trapID)
    self.gameTrap:getTrapModel(trapID)
end

function BattleModel:isAutoBattle()
    return self.autoBattle
end

function BattleModel:setAutoBattle(val)
    self.autoBattle = val
end

function BattleModel:addMagicCircle(magicCircle)
    self.magicCircleList:add(magicCircle)
end

function BattleModel:removeMagicCircle(attacker, skillID)
    self.magicCircleList:removeByAttackerAndSkillID(attacker, skillID)
end

function BattleModel:clearMagicCircle()
    CCLog("BattleModel:clearMagicCircle()")
    self.magicCircleList:clear()
end

function BattleModel:getAttackerForm()
    local form = {}
    for x = 1, 3 do
        for y = 3, 1, -1 do
            --local heroID = formationManager:getHeroID(x, y)
            local heroID = self:getAttackerHeroID(x, y)
            if heroID then
                local cell = BattleConfig.getSlotCell(x, y)
                local heroData = assert(GameCache.GetHero(heroID))
                table.insert(form, {cell = cell, type = "hero", data = heroData})
            end
        end
    end

    if self.params.nodeInfo and self.params.nodeInfo.IsFirst then
        for x = 1, 3 do
            for y = 3, 1, -1 do
                if #form < 5 and self:getAttackerHeroID(x, y) == nil then
                    local npcID = self:getAttackerNPCID(x, y)
                    if npcID then
                        local cell = BattleConfig.getSlotCell(x, y)
                        local monsterData = assert(BaseConfig.GetMonster(npcID))
                        table.insert(form, {cell = cell, type = "monster", data = monsterData})
                    end
                end
            end
        end
    end

    return form
end

function BattleModel:genSerNum()
    if self.lastSerNum == nil then
        self.lastSerNum = 1
    else
        self.lastSerNum = self.lastSerNum + 1
    end
    return self.lastSerNum
end

function BattleModel:getRoundCount()
    return #self.DEFFormList
end

function BattleModel:getRoundForm(index)
    return self.DEFFormList[index]
end

function BattleModel:getAttackForm(index)
    return self.attackUnits[index]
end

function BattleModel:dispatchEvent(eventName, data)
    if self.eventDispatcher then
        local event = cc.EventCustom:new(eventName)
        event.data = data
        CCLog("dispatchEvent(" .. eventName ..")")
        self.eventDispatcher:dispatchEvent(event)
    end
end

local function create_action_thread(timeUnits, action)
    return coroutine.create(function()
        for i = 1, timeUnits do
            coroutine.yield()
        end
        action()
    end)
end

function BattleModel:addAction(time, action)
    local timeUnits = math.ceil(time / BattleConfig.TIME_UNIT)
    CCLog(vardump({time = time, timeUnits = timeUnits}, "BattleModel:addAction"))
    table.insert(self.threadList, create_action_thread(timeUnits, action))
end

--function BattleModel:addAction(time, action)
--    local timeUnits = math.ceil(time / BattleConfig.TIME_UNIT)
--    CCLog(vardump({time = time, timeUnits = timeUnits}, "BattleModel:addAction"))
--    table.insert(self.actionQueue, {timeUnits = timeUnits, action = action})
--end

--function BattleModel:updateActionQueue()
--    local expired = {}
--
--    for idx, elem in ipairs(self.actionQueue) do
--        elem.timeUnits = elem.timeUnits - 1
--
--        if elem.timeUnits <= 0 then
--            elem.action()
--            table.insert(expired, idx)
--        end
--    end
--
--    for i = #expired, 1, -1 do
--        local idx = expired[i]
--        table.remove(self.actionQueue, idx)
--    end
--end

-- 时间片
function BattleModel:getTimeUnit()
    return BattleConfig.TIME_UNIT
end

function BattleModel:getTimeLeftStr()
    local sec = self.timeLeft * BattleConfig.TIME_UNIT
    return Common.timeFormat(sec)
end

function BattleModel:getTimerName()
    if self.timer then
        return self.timer.name or ""
    end
    return ""
end

function BattleModel:getTimerLeftStr()
    local sec = 0
    if self.timer then
        sec = self.timer.timeLeft
    end
    return Common.timeFormat(sec)
end

function BattleModel:getState()
    return self.state
end

function BattleModel:onStateChange(oldState, newState)
    if not self.finished then
        local time = BattleConfig.ENTRANCE_TIME
--        if newState == "entrance" then
--            self:addAction(time, function()
--                if self.params.battleType == "PVE" then
--                    self:loadTrap(self.roundIndex)
--                end
--
--                self:showEnemy()
--                self:setState("fight")
--            end)
--        end

        if newState == "fight" then
            if self.params.battleType == "PVE" then
                self:loadTrap(self.roundIndex)                
            end
            self:loadTurret(self.roundIndex)
            self:showEnemy()

            if self.params.battleType == "Tower" then
                self.leftTeam:rageChanged(self.leftTeam:getRage(), self.leftTeam:getRage())
                self.rightTeam:rageChanged(self.rightTeam:getRage(), self.rightTeam:getRage())
            end
        end

        self:dispatchEvent(AppEvent.UI.Battle.BattleStateChange, {old = oldState, new = newState, useTime = time})

        if newState == "fight" then
            if self.params.battleType == "Tower" then
                self.leftTeam:rageChanged(self.leftTeam:getRage(), self.leftTeam:getRage())
                self.rightTeam:rageChanged(self.rightTeam:getRage(), self.rightTeam:getRage())
            end
        end
    end
end

function BattleModel:setState(state)
    local oldState = self.state

    if oldState ~= state then
        self.state = state
        self:onStateChange(oldState, state)
    end
end

function BattleModel:start()
    --self.battleRecordData:init(self:getAttackerForm(), self.battleUnits)

    self.roundIndex = self.roundIndex + 1

    self:lineupEnemy(self.roundIndex)
    self:lineupHero(self.roundIndex)

    self:setState("starting")
end

function BattleModel:started()
    self:setState("entrance")

    self.leftTeam:preload()
    self.rightTeam:preload()

    if self.params.battleType == "PVE" or self.params.battleType == "GUIDE" then
        self:loadGameAI(self.roundIndex)
        self:loadObstacle(self.roundIndex)
    end
end

function BattleModel:getAttackerHeroID(x, y)
    local form = self.attackerForm
    local heroID = nil
    for _, unit in ipairs(form) do
        if unit.X == x and unit.Y == y then
            heroID = unit.ID
            break
        end
    end

    return heroID
end

function BattleModel:getAttackerNPCID(x, y)
    local form = self.attackerForm
    local heroID = nil
    for _, unit in ipairs(form) do
        if unit.X == x and unit.Y == y then
            heroID = unit.NPC
            break
        end
    end

    return heroID
end

function BattleModel:lineupHero(roundIndex)
    -- if self.params.battleType ~= "GUIDE" then
        if roundIndex == 1 then
            --local formationManager = FormationManager:sharedInstance()
            local form = self.ATKForm

            self.leftTeam:lineup(form, self, true)
        else
            self.leftTeam:relineup()
        end
    -- else
    --     local battleCount = self:getRoundCount()

    --     local heroCount = 0

    --     if roundIndex <= battleCount then
    --         local form = self:getAttackForm(roundIndex)
    --         self.leftTeam:lineup(form, self, true)
    --     end
    --     return 0
    -- end
end

function BattleModel:lineupEnemy(roundIndex)
    local battleCount = self:getRoundCount()

    local heroCount = 0

    if roundIndex <= battleCount then
        local form = self:getRoundForm(roundIndex)
        CCLog(vardump({form = form, roundIndex = roundIndex}, "lineupEnemy"))
        self.rightTeam:lineup(form, self, false)
    end
    return 0
end

function BattleModel:roundHasBoss(roundIndex)
    local battleCount = self:getRoundCount()

    local heroCount = 0

    if roundIndex <= battleCount then
        local form = self:getRoundForm(roundIndex)
        
        for idx, slot in pairs(form) do
            if slot.data.IsBoss == 1 then
                return true
            end
        end
    end
    return false
end

function BattleModel:lineupFriend()
    -- IsFriendGuard  bool             // 是否有仙友护卫
    -- FriendForm     model.RFormation // 护卫仙友阵容
    -- FriendHeroList []model.RHeroEx  // 阵容星将详细属性

    local Timer = require("scene.battle.helper.Timer")
    if self.timer then
        self.timer:cleanup()
        self.timer = nil
    end
    self.timer = Timer.new(BattleConfig.FRIEND_GUARD_TIME, self, "仙友护卫时间:")

    if self.params.friendFairyData then
        self.rightTeam:setFairyModel(BattleFairyModel.new(self.params.friendFairyData, self.rightTeam))
    end

    CCLog(vardump({isFriendGuard = self.params.isFriendGuard, units = self.friendUnits}, "lineupFriend"))
    if self.params.isFriendGuard then
        local form = self.friendUnits[1]
        self.rightTeam:setRage(0)
        self.rightTeam:lineup(form, self, false)
        self:dispatchEvent(AppEvent.UI.Battle.FriendGuard, nil)
        return 0
    end
end

function BattleModel:showEnemy()
    self.rightTeam:dispatchLineupEvent(self)
end

function BattleModel:incTimeTick()
    self.timeTick = self.timeTick + 1
end

function BattleModel:getTimeTick()
    return self.timeTick
end

function BattleModel:updateThreadList()
    local count = #self.threadList
    for i = count, 1, -1 do
        local thread = self.threadList[i]
        coroutine.resume(thread)

        if coroutine.status(thread) == "dead" then
            table.remove(self.threadList, i)
        end
    end
end

-- function BattleModel:isPaused()
--     return self.paused or self.aniPaused
-- end

function BattleModel:isPaused()    
    return self.pausedCount > 0
end

function BattleModel:incPausedCount()
    self.pausedCount = self.pausedCount + 1
    CCLog("BattleModel:incPausedCount:", self.pausedCount)
end

function BattleModel:decPausedCount()
    if self.pausedCount <= 0 then
        CCLog("BattleModel:decPausedCount error, count = ", self.pausedCount, debug.traceback())
    else
        self.pausedCount = self.pausedCount - 1
        CCLog("BattleModel:decPausedCount:", self.pausedCount)
    end
end

function BattleModel:update()
    self:updateThreadList()

    if not (self:isPaused() or self.finished) then
        if self.state == "fight" then
            local timer = self.timer
            if timer then
                timer:update()
                if timer.finished then
                    self.timer = nil
                end
            end

            self.magicCircleList:update(self)
            self.gameObstacle:update(self)
            self.gameTrap:update(self)

            self.leftTeam:update(self)
            self.rightTeam:update(self)

            self:checkBattleEnd()

            self.timeLeft = self.timeLeft - 1
            self.totalTimeTick = self.totalTimeTick + 1

            if self.timeLeft <= 0 then
                self:battleTimeout()
            end
        end
    end
end

function BattleModel:battleTimeout()
    self:dispatchEvent(AppEvent.UI.Battle.Timeout, nil)
    self:setState("timeout")
end

function BattleModel:checkBattleEnd()
    if #self.frameDeadList > 0 then
        local heroTeamOrder = nil 
        if self.params.battleType == "PVE" then
            heroTeamOrder = function(teamSide) 
                if teamSide == "left" then 
                    return 1
                elseif teamSide == "right" then 
                    return 2
                else 
                    assert(false, "teamside:" .. tostring(teamSide))
                end
            end
        else
            heroTeamOrder = function(teamSide) 
                if teamSide == "right" then 
                    return 1
                elseif teamSide == "left" then 
                    return 2
                else 
                    assert(false, "teamside:" .. tostring(teamSide))
                end
            end
        end

        table.sort(self.frameDeadList, function(heroA, heroB) return heroTeamOrder(heroA:getTeamSide()) < heroTeamOrder(heroB:getTeamSide()) end)

        for _, hero in ipairs(self.frameDeadList) do
            self:checkTeamHasNoHero(hero)
        end

        self.frameDeadList = {}
    end
end

function BattleModel:onEvent(name, data)
    --self.battleRecordData:onEvent(name, data)
    self.gameAI:onEvent(name, data)
    self.gameTrap:onEvent(name, data)

--    self.leftTeam:onEvent(name, data)
--    self.rightTeam:onEvent(name, data)
end

function BattleModel:getRecordJson()
    return self.battleRecordData:getRecordJson()
end

-- 设置左队成员
function BattleModel:setLeftTeam(heroModels)
    self.leftTeam:setHeroModels(heroModels)
end

-- 设置右队成员
function BattleModel:setRightTeam(heroModels)
    self.rightTeam:setHeroModels(heroModels)
end

function BattleModel:getTeamMembers(side)
    assert(side == "left" or side == "right")
    if side == "left" then
        return self.leftTeam:getHeroModels()
    elseif side == "right" then
        return self.rightTeam:getHeroModels()
    end
end

function BattleModel:getEnemyMembers(side)
    assert(side == "left" or side == "right")
    if side == "right" then
        return self.leftTeam:getHeroModels()
    elseif side == "left" then
        return self.rightTeam:getHeroModels()
    end
end

function BattleModel:getEnemyTeam(side)
    assert(side == "left" or side == "right")
    if side == "left" then
        return self.rightTeam
    elseif side == "right" then
        return self.leftTeam
    end
end

function BattleModel:getEnemyCount(side)
    assert(side == "left" or side == "right")
    if side == "left" then
        return self.rightTeam:getHeroCount()
    elseif side == "right" then
        return self.leftTeam:getHeroCount()
    end
end

function BattleModel:getTeam(side)
    assert(side == "left" or side == "right")
    if side == "left" then
        return self.leftTeam
    elseif side == "right" then
        return self.rightTeam
    end
end

-- 敌人是否已经队友锁定
function BattleModel:isMatchedByTeammate(heroModel, enemyModel)
    local teamSide = heroModel:getTeamSide()
    local teammateList = self:getTeamMembers(teamSide)
    
    for _, teammate in ipairs(teammateList) do
        if teammate ~= heroModel then
            if temmate:isMatchedEnemy(enemyModel) then
                return true
            end
        end
    end    
    return false
end

function BattleModel:heroDie(heroModel)
    local teamSide = heroModel:getTeamSide()

    local team = nil
    local enemyTeam = nil
    if teamSide == "left" then
        team = self.leftTeam
        enemyTeam = self.rightTeam
    else
        team = self.rightTeam
        enemyTeam = self.leftTeam
    end
    team:heroDie(heroModel)

    --team:removeHero(heroModel)
    --self:teamHasNoHero(teamSide)

    enemyTeam:removeMatchedEnemy(heroModel)

    table.insert(self.frameDeadList, heroModel)

    if self.params.battleType == "PVP" and heroModel:getFighterType() == "hero" then        
        self.leftTeam:incRage(10)
        self.rightTeam:incRage(10)
    end
end

function BattleModel:checkTeamHasNoHero(teamSide)
    local team = nil
    local enemyTeam = nil

    if teamSide == "left" then
        team = self.leftTeam
        enemyTeam = self.rightTeam
    else
        team = self.rightTeam
        enemyTeam = self.leftTeam
    end

    if self.state == "fight" and team:getAliveHeroCount(true) == 0 then
        if teamSide == "left" then
            self:setState("fail")
        else
            if self.params.isFriendGuard then                
                self:lineupFriend()

                self.params.isFriendGuard = false
            else
                self:setState("win")
            end
        end
    end
end

-- 技能没有效果：只处理BUFF
function BattleModel:handleInstantSkillBuff(subAttackData)
    local attackData = subAttackData.attackData
    local targetFighter = subAttackData.targetFighter

    if not targetFighter:isAlive() then
        return
    end
    
    CCLog(vardump({attackData.skillData.name, attackData.skillData.buff}, "BattleModel:handleInstantSkillBuff"))

    local BattleHelper = require("scene.battle.helper.BattleHelper")
    local Conditions = BattleHelper.Conditions

    if Conditions.Skill.Buff.hasBuff(attackData) then
        CCLog(vardump(attackData.skillData.buff, "BattleController:doAddBuff"))
        local skillData = attackData.skillData
        local probability = skillData.buffProbability + subAttackData.extraBuffProbability

        local randNum = self._random:value(1, 10000)
        CCLog(string.format("random:%d, probability:%d, extra:", randNum, probability, subAttackData.extraBuffProbability))
        if randNum <= probability then
            local attacker = attackData:getAttacker()
            for _, buffID in ipairs(skillData.buff) do
                targetFighter:addBuff(buffID, attacker, skillData.id, skillData.level)
            end
        end
    end
end

-- 处理立即生效的伤害技能
function BattleModel:handleInstantDamageSkill(subAttackData)
    CCLog("BattleModel:handleInstantDamageSkill")

    self:doHit(subAttackData)
end

-- 处理立即生效的治疗技能
function BattleModel:handleInstantTreatmentSkill(subAttackData)
    CCLog("BattleModel:handleInstantTreatmentSkill")
    local attackData = subAttackData.attackData
    local targetFighter = subAttackData.targetFighter

    if not targetFighter:isAlive() then
        return
    end
    
    local hp = self:calcSkillAffectValue(attackData, targetFighter)

    if subAttackData.extraDamageRatio > 0 then
        local extraDamage = hp * (subAttackData.extraDamageRatio / 10000.0)
        hp = hp + extraDamage
    end

    if subAttackData.extraDamageValue > 0 then
        hp = hp + subAttackData.extraDamageValue
    end

    targetFighter:treat(attackData, hp)
end

-- 处理立即生效的复活技能
function BattleModel:handleInstantResurrectionSkill(attackData)
    CCLog("TODO:处理立即生效的复活技能")
    local heroModel = attackData:getHeroModel()
    if heroModel:isAlive() then
        local targetList = attackData:getTargetFighterList()
        if #targetList == 1 then
            local target = targetList[1]
            local hp = self:calcSkillAffectValue(attackData, target)
            target:resurrect(attackData, hp)
            
            local enemyTeam = heroModel:getEnemyTeam()
            enemyTeam:onEnemyChanged()
        else
            CCLog("复活目标数不为1")
        end
    else
        CCLog("施法者已死")
    end
end

-- 处理立即生效的召唤技能
function BattleModel:handleInstantSummonerSkill(attackData)
    CCLog("TODO: 处理立即生效的召唤技能", vardump(attackData.skillData))

    local attacker = attackData:getAttacker()
    local team = attacker:getTeam()
    team:summon(attackData)
end

-- 处理立即生效的复制凶手技能
function BattleModel:handleInstantCopyKillerSkill(attackData)
    local attacker = attackData.attacker
    local killer = attacker._killer
    CCLog("处理立即生效的复制凶手技能", vardump({attacker:getName(), killer:getName()}))
    local team = attacker:getTeam()
    team:copyKiller(attackData)
end

function BattleModel:handleInstantMoveForMomentSkill(attackData)
    local attacker = attackData.attacker
    attacker:moveToPosForMoment(attackData)
end

    -- 1.瞬间生效
function BattleModel:handleInstantSkillSubAttack(subAttackData)
    CCLog("BattleModel:handleInstantSkillSubAttack")

    local attackData = subAttackData.attackData
--[[ SkillAffectType 技能效果类型
        None = 0,
        Damage = 1,          1-伤害
        Treatment = 2,       2-治疗
        Resurrection = 3,    3--复活（公式为复活后的血量）
        Summoner = 4,        4--召唤
        Replication = 5      5--分身
--]]
    local handlers = {
        --[enums.SkillAffectType.None        ] = nil,
        [enums.SkillAffectType.Damage      ] = self.handleInstantDamageSkill,
        [enums.SkillAffectType.Treatment   ] = self.handleInstantTreatmentSkill,
    }

    local handler = handlers[attackData.skillData.affect]

    if handler then
        handler(self, subAttackData)
        
    else
        CCLog("没有处理技能技能效果类型: " .. attackData.skillData.affect)
    end
    self:handleInstantSkillBuff(subAttackData)
end

-- 处理立即 召唤仇恨目标的技能
function BattleModel:handleInstantHatredTargetSkill(attackData)
    local attacker = attackData.attacker
    local killer = attacker._killer
    CCLog("召唤仇恨目标的技能", vardump({attacker:getName()}))
    local team = attacker:getTeam()
    team:summonHatredTarget(attackData)
end

--function BattleModel:handleSkillByDurationMode(attackData, targetHeroModel)
--    CCLog("BattleModel:handleSkillByDurationMode")
--
--    --[[   SkillDurationMode      技能持续时间类型
--           Instant = 1,             1.瞬间生效
--           FixedMagicCircle = 2,    2.放在地上的阵法技能（持续作用于一定范围）
--           FollowMagicCircle = 3,   3.以自身为中心的可移动阵法技能
--           Continuous = 4           4.持续施法（自身不动，可被打断）
--    --]]
--
--    local handlers = {
--        [enums.SkillDurationMode.Instant] = self.handleInstantSkill,
--        [enums.SkillDurationMode.FixedMagicCircle] = self.handleFixedMagicCircleSkill,
--        [enums.SkillDurationMode.FollowMagicCircle] = self.handleFollowMagicCircleSkill,
--        [enums.SkillDurationMode.Continuous] = self.handleContinuousSkill,
--    }
--    local handler = handlers[attackData.skillData.durationType]
--
--    if handler then
--       handler(self, attackData, targetHeroModel)
--    else
--        CCLog("没有处理技能持续时间类型: " .. attackData.skillData.durationType)
--    end
--end

--[[ 技能附加效果：反击，秒杀，弹射，减敌方怒气，加自己的怒气，加自己的血量
1--击退（几格）
2--秒杀（血量低于某个百分比）
3--额外伤害1（触发特殊效果时，伤害值=普通效果的公式+额外伤害公式）
4-减少对方怒气
5--增加己方怒气
6-回复自身生命（按造成伤害的万分比回血）
7-连续攻击（值为次数）
8-若目标死亡，周围4格内所有敌方单位受到相同伤害
9-清除目标身上不利状态
10--额外伤害2（触发特殊效果时，伤害值=额外伤害公式）
11--分身（1-10级分身数位1,11-20级分身数位2,21级以上分身数位3  分身持续4s）
12--对男性目标有额外加成（万分比）
13--对女性目标有额外加成（万分比）
14--清除己方单位的不利状态（100%成功），并有一定概率把不理状态转移到对方身上（随机）
15--提高对男性角色使用buff的成功率
16--提高情绪一个等级
--]]

function BattleModel:getSkillExtraAffectHandlers()
    local handlers = {
        [enums.SkillExtraAffect.Knockback]               = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = function(subAttackData)
                local attackData, targetFighter = subAttackData.attackData, subAttackData.targetFighter

                CCLog("extra affect: knockedback")
                local extraAffectValue = attackData.skillData.extraAffectValue

                local attacker = attackData:getAttacker()
                local direction = attacker:getDirection()
                self:dispatchEvent(AppEvent.UI.Battle.Knockedback, {fighterID = targetFighter:getFighterID(), value = extraAffectValue, direction = direction})
            end,
        },
        [enums.SkillExtraAffect.Seckilling]              = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = function(subAttackData)
                CCLog("extra affect: seckilling")
                local attackData, targetFighter = subAttackData.attackData, subAttackData.targetFighter
                local extraAffectValue = attackData.skillData.extraAffectValue
                local hpPercent = targetFighter:getHPPercent()
                if hpPercent <= extraAffectValue / 10000 then
                    targetFighter:decHP(targetFighter:getHP())
                end
            end,
        },
        [enums.SkillExtraAffect.AddDamage_1]             = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = function(subAttackData)
                CCLog("extra affect: add_damage_1")
                local targetFighter    = subAttackData.targetFighter

                local attackData       = subAttackData.attackData
                local probability      = attackData.skillData.extraAffectProbability
                local extraAffectValue = attackData.skillData.extraAffectValue

                local randNum = self._random:value(1, 10000)
                if randNum <= probability then
                    subAttackData:incExtraDamageValue(extraAffectValue)
                end
            end,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.DecEnemyRage]            = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local attacker = attackData:getAttacker()
                local probability      = attackData.skillData.extraAffectProbability
                local extraAffectValue = attackData.skillData.extraAffectValue

                local randNum = self._random:value(1, 10000)
                if randNum <= probability then
                    local team = attacker:getEnemyTeam()
                    if team then
                        team:decRage(extraAffectValue)
                    end
                end
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.IncSelfRage]             = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local attacker = attackData:getAttacker()
                local probability      = attackData.skillData.extraAffectProbability
                local extraAffectValue = attackData.skillData.extraAffectValue

                local randNum = self._random:value(1, 10000)
                if randNum <= probability then
                    local team = attacker:getTeam()
                    if team then
                        team:incRage(extraAffectValue)
                    end
                end
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.IncSelfHP]               = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = function(subAttackData)
                local attackData = subAttackData.attackData
                local attacker = attackData:getAttacker()

                local damage = subAttackData:getValue()
                attacker:incHP(damage * attackData.skillData.extraAffectValue / 10000, true, true)
            end,
        },
        [enums.SkillExtraAffect.ComboHit]                = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                if not attackData.isComboHit then
                    local attacker = attackData:getAttacker()
                    --attackData:setIsComboHit(true)
                    local comboHitModel = ComboHitModel.new(attacker, attackData)
                    attacker:setComboHitModel(comboHitModel)
                end
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.Bomber]                  = {
            ["before"]     = nil,
            ["after"]      = function()

            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.ClearDebuff]             = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local attacker = attackData:getAttacker()
                attacker:clearDebuff()
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.AddDamage_2]             = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = function()

            end,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.Replication]             = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local attacker = attackData:getAttacker()

                local team = attacker:getTeam()
                team:replicate(attackData, 2)
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.ExtraDamageForMale]      = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = function(subAttackData)
                local targetFighter    = subAttackData.targetFighter

                if targetFighter:getGender() == enums.Gender.Male then
                    local attackData       = subAttackData.attackData
                    local probability      = attackData.skillData.extraAffectProbability
                    local extraAffectValue = attackData.skillData.extraAffectValue

                    local randNum = self._random:value(1, 10000)
                    if randNum <= probability then
                        subAttackData:incExtraDamageRatio(extraAffectValue)
                    end
                end
            end,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.ExtraDamageForFemale]    = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = function(subAttackData)
                local targetFighter    = subAttackData.targetFighter

                if targetFighter:getGender() == enums.Gender.Female then
                    local attackData       = subAttackData.attackData
                    local probability      = attackData.skillData.extraAffectProbability
                    local extraAffectValue = attackData.skillData.extraAffectValue

                    local randNum = self._random:value(1, 10000)
                    if randNum <= probability then
                        subAttackData:incExtraDamageRatio(extraAffectValue)
                    end
                end
            end,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.TransferDebuff]          = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = function(subAttackData)
                CCLog("转移Debuff")
                local attackData = subAttackData.attackData
                local targetFighter = subAttackData.targetFighter
                local debuffList = targetFighter:clearDebuff()
                CCLog("debuff count:", #debuffList)
                if debuffList and #debuffList > 0 then
                    local enemies = targetFighter:getEnemies()
                    CCLog("enemy count:", #enemies)
                    
                    if #enemies > 0 then
                        for _, debuff in ipairs(debuffList) do
                            local probability = attackData:getExtraAffectProbability()
                            local randNum = self._random:value(1, 10000)
                            if randNum <= probability then
                                local enemy = enemies[self._random:value(1, #enemies)]

                                enemy:addBuff(debuff.buffID, debuff.attacker, debuff.skillID, debuff.skillLevel)
                            end
                        end
                    end
                end
            end,
        },
        [enums.SkillExtraAffect.IncMaleBuffSuccessRate]  = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = function(subAttackData)
               local targetFighter    = subAttackData.targetFighter

                if targetFighter:getGender() == enums.Gender.Male then
                    local attackData       = subAttackData.attackData
                    local probability      = attackData.skillData.extraAffectProbability
                    local extraAffectValue = attackData.skillData.extraAffectValue

                    local randNum = self._random:value(1, 10000)
                    if randNum <= probability then
                        subAttackData:incExtraBuffProbability(extraAffectValue)
                    end
                end
            end,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.IncMoodLevel]            = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = function()

            end,
        },
        [enums.SkillExtraAffect.ProbabilityFormula]            = {
            ["before"]     = function(attackData)
                local probability      = attackData.skillData.extraAffectProbability
                local extraAffectValue = attackData.skillData.extraAffectValue

                local randNum = self._random:value(1, 10000)
                if randNum <= probability then
                    CCLog("公式替换")                    
                    attackData.skillData = clone(attackData.skillData)
                    attackData.skillData.formula = extraAffectValue
                end
            end,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.TurnIntoEgg]            = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                -- 在 HeroModel中特殊处理
--                local attacker = attackData.attacker
--                attacker:turnIntoEgg(attackData)
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.Suction]               = {
            ["before"]     = nil,
            ["after"]      =  function(attackData)
                local cell = attackData:getDestCell()
                local fighterList = attackData:getTargetFighterList()
                local usedCellList = {}
                local function hasCell(cellList, x, y)
                    for _, cell in ipairs(cellList) do
                        if cell.x == x and cell.y == y then
                            return true
                        end
                    end
                    return false
                end

                for _, targetFighter in ipairs(fighterList) do
                    local destCell = {x = cell.x, y = cell.y }
                    local srcCell = targetFighter:getCell()

                    local diffX = cell.x - srcCell.x
                    local diffY = cell.y - srcCell.y
                    local distanceX = math.abs(cell.x - srcCell.x)
                    local distanceY = math.abs(cell.y - srcCell.y)
                    local distance = math.max(distanceX, distanceY)

                    local x_ratio =  diffX / distance
                    local y_ratio =  diffY / distance
                    --print(vardump({srcCell = srcCell, destCell = destCell, diffY = diffY, diffX = diffX, distanceX = distanceX, distanceY = distanceY, distance = distance, x_ratio = x_ratio, y_ratio = y_ratio}))
                    for i = 0, distance - 1 do
                        local x = cell.x - math.floor(x_ratio * i + 0.5)
                        local y = cell.y - math.floor(y_ratio * i + 0.5)
                        if (not self:isGridUsed(x, y, targetFighter)) and (not hasCell(usedCellList, x, y)) then
                            destCell.x = x
                            destCell.y = y
                            break
                        end
                    end
                    table.insert(usedCellList, destCell)
                    self:dispatchEvent(AppEvent.UI.Battle.Suction, {fighterID = targetFighter:getFighterID(), cell = destCell})
                end
            end,
            ["sub_before"] = nil,
            ["sub_after"] =  nil,
        },
        [enums.SkillExtraAffect.Replication_1] = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local attacker = attackData:getAttacker()

                local team = attacker:getTeam()
                team:replicate(attackData, 1)
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
        [enums.SkillExtraAffect.BuffForFemale] = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = nil,
            ["sub_after"]  = function(subAttackData)
                local attackData = subAttackData.attackData
                local skillData = attackData.skillData
                local attacker = attackData.attacker
                local targetFighter = subAttackData.targetFighter
                local probability      = attackData.skillData.extraAffectProbability
                local extraAffectValue = attackData.skillData.extraAffectValue

                if targetFighter:getGender() == enums.Gender.Female then
                    local randNum = self._random:value(1, 10000)
                    if randNum <= probability then
                        targetFighter:addBuff(extraAffectValue, attacker, skillData.id, skillData.level)
                    end
                end
            end,
        },
        [enums.SkillExtraAffect.ExtraDamageForSummon]    = {
            ["before"]     = nil,
            ["after"]      = nil,
            ["sub_before"] = function(subAttackData)
                local targetFighter    = subAttackData.targetFighter

                if targetFighter:getGender() == enums.Gender.Female then
                    local attackData       = subAttackData.attackData
                    local probability      = attackData.skillData.extraAffectProbability
                    local extraAffectValue = attackData.skillData.extraAffectValue

                    if  iskindof(targetFighter, "ReplicationModel") or 
                        iskindof(targetFighter, "SummonBeastModel") or 
                        iskindof(targetFighter, "HatredTargetModel") or 
                        iskindof(targetFighter, "CopyHeroModel") 
                    then
                        local randNum = self._random:value(1, 10000)
                        if randNum <= probability then
                            subAttackData:incExtraDamageRatio(extraAffectValue)
                        end
                    end
                end
            end,
            ["sub_after"]  = nil,
        },      
        [enums.SkillExtraAffect.BuffForSelf] = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local skillData = attackData.skillData
                local attacker = attackData.attacker
                local probability      = attackData.skillData.extraAffectProbability
                local extraAffectValue = attackData.skillData.extraAffectValue

                local randNum = self._random:value(1, 10000)
                if randNum <= probability then
                    attacker:addBuff(extraAffectValue, attacker, skillData.id, skillData.level)
                end
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },  

        [enums.SkillExtraAffect.KillSelf] = {
            ["before"]     = nil,
            ["after"]      = function(attackData)
                local attacker = attackData:getAttacker()
                CCLog(attacker:getName(), "自爆")
                attacker:decHP(attacker:getHP())
            end,
            ["sub_before"] = nil,
            ["sub_after"]  = nil,
        },
    }

    return handlers
end

function BattleModel:handleSkillExtraAffect(attackData, targetFighter)
    -- TODO:额外效果
    local extraAffect = attackData:getExtraAffectType()
    if extraAffect and extraAffect ~= 0 then
        local probability = attackData:getExtraAffectProbability()
        local randNum = self._random:value(1, 10000)
        if randNum <= probability then
            CCLog(string.format("额外效果[%d]:%s", extraAffect, attackData:getSkillExtraAffectDesc()))
--            local SkillExtraAffect = {
--                Knockback              = 1,
--                Seckilling             = 2,
--                AddDamage_1            = 3,
--                DecEnemyRage           = 4,
--                IncSelfRage            = 5,
--                IncSelfHP              = 6,
--                ComboHit               = 7,
--                Bomber                 = 8,
--                ClearDebuff            = 9,
--                AddDamage_2            = 10,
--                Replication            = 11,
--                ExtraDamageForMale     = 12,
--                ExtraDamageForFemale   = 13,
--                TransferDebuff         = 14,
--                IncMaleBuffSuccessRate = 15,
--                IncMoodLevel           = 16,
--            }

        end
    end
end

function BattleModel:onBeforeSkill(attackData)
    local extraAffect = attackData:getExtraAffectType()
    local handlers = self.skillExtraHandlers[extraAffect]
    if handlers then
        local handler = handlers["before"]
        if handler then
            local probability = attackData:getExtraAffectProbability()
            local randNum = self._random:value(1, 10000)
            if randNum <= probability then
                CCLog(string.format("额外效果[%d]:%s", extraAffect, attackData:getSkillExtraAffectDesc()))
                handler(attackData)
            end
        end
    end
end

function BattleModel:onAfterSkill(attackData)
    local extraAffect = attackData:getExtraAffectType()
    local handlers = self.skillExtraHandlers[extraAffect]
    if handlers then
        local handler = handlers["after"]
        if handler then
            local probability = attackData:getExtraAffectProbability()
            local randNum = self._random:value(1, 10000)
            if randNum <= probability then
                CCLog(string.format("额外效果[%d]:%s", extraAffect, attackData:getSkillExtraAffectDesc()))
                handler(attackData)
            end
        else
            CCLog("no after skill handler")
        end
    end

    if attackData.skillData.type == enums.SkillType.RageSkill then
        local attacker = attackData:getAttacker()
        if attacker:getFighterType() == "hero" then
            local hp = attacker:getHP()

            if hp > 0 then
                local needHP = attacker:rageConsumeHP()
                attacker:decHP(math.min(needHP, hp - 1))
            end
        end
    end
end

function BattleModel:onBeforeSkillSubAttack(subAttackData)
    local attackData = subAttackData.attackData
    local extraAffect = attackData:getExtraAffectType()
    local handlers = self.skillExtraHandlers[extraAffect]
    if handlers then
        local handler = handlers["sub_before"]
        if handler then
            local probability = attackData:getExtraAffectProbability()
            local randNum = self._random:value(1, 10000)
            if randNum <= probability then
                CCLog(string.format("额外效果[%d]:%s", extraAffect, attackData:getSkillExtraAffectDesc()))
                handler(subAttackData)
            end
        end
    end
end

function BattleModel:onAfterSkillSubAttack(subAttackData)
    local attackData = subAttackData.attackData
    local extraAffect = attackData:getExtraAffectType()
    local handlers = self.skillExtraHandlers[extraAffect]
    if handlers then
        local handler = handlers["sub_after"]
        if handler then
            local probability = attackData:getExtraAffectProbability()
            local randNum = self._random:value(1, 10000)

            -- 姜子牙大招特殊处理
            if extraAffect == enums.SkillExtraAffect.TransferDebuff then
                randNum = 0
            end
            CCLog(string.format("额外效果[%d]:%s 随机数:%.2f, 概率:%.2f", extraAffect, attackData:getSkillExtraAffectDesc(), randNum, probability))
            if randNum <= probability then                
                handler(subAttackData)
            end
        end
    end

    -- 普攻吸血
    if attackData.skillData.type == enums.SkillType.NormAttack then
        local attackData = subAttackData.attackData
        local attacker = attackData:getAttacker()

        if attacker:isAlive() then
            local damage = subAttackData:getValue()
            local hp = math.floor(damage * attacker:getBloodSucking())

            if hp > 0 then
                attacker:incHP(hp , true, true)
            end
        end
    end
end

function BattleModel:handleSkill(attackData)
    local attackerType = attackData:getAttackerType()
    local attacker = attackData:getAttacker()
    local skillData = attackData.skillData
    local targetHeroList = attackData:getTargetFighterList()
    CCLog(string.format("处理技能: {hero:%s, skill:%s, targetNum:%d, target:%d}", attacker and attacker:getName() or attackerType, skillData.name, skillData.targetNum, #targetHeroList))
    
    if attackData.skillData.durationType == enums.SkillDurationMode.Instant then
        if attackData.skillData.affect == enums.SkillAffectType.Resurrection then
            self:handleInstantResurrectionSkill(attackData) -- 复活
        elseif attackData.skillData.affect == enums.SkillAffectType.Summoner then
            self:handleInstantSummonerSkill(attackData)     -- 招唤
        elseif attackData.skillData.affect == enums.SkillAffectType.HatredTarget then
            self:handleInstantHatredTargetSkill(attackData)     -- 招唤仇恨目标
        elseif attackData.skillData.affect == enums.SkillAffectType.CopyKiller then
            self:handleInstantCopyKillerSkill(attackData)  -- 复制凶手
        else
            if attackData.skillData.affect == enums.SkillAffectType.TeleportForMoment then
                self:handleInstantMoveForMomentSkill(attackData)
            end

            local subAttackList = {}
            for _, hero in ipairs(targetHeroList) do
                local subAttackModel = AttackSubDataModel.new(attackData, hero)
                table.insert(subAttackList, subAttackModel)
                self:onBeforeSkillSubAttack(subAttackModel)
                self:handleInstantSkillSubAttack(subAttackModel) -- 按钮持续类型处理技能
                self:onAfterSkillSubAttack(subAttackModel)
                --self:handleSkillExtraAffect(attackData, hero)    -- 处理技能附加效果
            end
            attackData:setSubAttackList(subAttackList)
        end
    elseif attackData.skillData.durationType == enums.SkillDurationMode.FixedMagicCircle then
        local newID = self.magicCircleList:genID()
        local magicCircle = FixedMagicCircleModel.new(newID, attackData, self)
        self.magicCircleList:add(magicCircle)
    elseif attackData.skillData.durationType == enums.SkillDurationMode.FollowMagicCircle then
        local magicCircle = FollowMagicCircleModel.new(attackData)
        local attacker = attackData.attacker
        attacker:addMagicCircle(magicCircle)
    elseif attackData.skillData.durationType == enums.SkillDurationMode.Continuous then
        local continuousSkill = ContinuousSkillModel.new(attackData, self)
        attacker:setContinuousSkillModel(continuousSkill)
    end
end

function BattleModel:onAttack(attackData)
    local st = os.clock()
    CCLog("BattleModel:onAttack()", attackData.skillData.id)
    self:onBeforeSkill(attackData)
    self:handleSkill(attackData)
    self:onAfterSkill(attackData)

    if attackData:attackerIsHero() then
        local hero = attackData:getAttacker()
        local side = hero:getTeamSide()
        if side == "left" then
            self.leftTeam:onAttack(attackData)
            --self.leftTeam:incRage(1)
        else
            self.rightTeam:onAttack(attackData)
            --self.rightTeam:incRage(1)
        end
    end
    print("attack use time:", os.clock() - st)
end

function BattleModel:handleAI(aiID)
    local aiData = BaseConfig.GetAI(aiID)
    local AIType = aiData.AIType

    local handlers = {
        [enums.BattleAIType.Dialogue     ] = handler(self, self.handleDialogueAI),       -- 说话
        [enums.BattleAIType.MonsterSkill ] = handler(self, self.handleMonsterSkillAI),   -- 怪物使用技能
        [enums.BattleAIType.SummonMonster] = handler(self, self.handleSummonMonsterAI),  -- 出现新的怪物（敌方）
        [enums.BattleAIType.SummonNPC    ] = handler(self, self.handleSummonNPCAI),      -- 出现新的NPC（友方）
        [enums.BattleAIType.InstanceSkill] = handler(self, self.handleInstanceSkillAI),  -- 关卡技能
        [enums.BattleAIType.MonsterAI    ] = handler(self, self.handleMonsterAI),        -- 怪物相关AI 如双生怪
    }

    local handler = handlers[AIType]
    if handler then
        handler(aiData)
    end
end

-- 说话
function BattleModel:handleDialogueAI(aiData)

end

-- 怪物使用技能
function BattleModel:handleMonsterSkillAI(aiData)

end

-- 出现新的怪物（敌方）
function BattleModel:handleSummonMonsterAI(aiData)

end

-- 出现新的NPC（友方）
function BattleModel:handleSummonNPCAI(aiData)

end

-- 关卡技能
function BattleModel:handleInstanceSkillAI(aiData)

end

-- 怪物相关AI 如双生怪
function BattleModel:handleMonsterAI(aiData)

end

--[[ 技能附加效果：反击，秒杀，弹射，减敌方怒气，加自己的怒气，加自己的血量
1--击退（几格）
2--秒杀（血量低于某个百分比）
3--额外伤害1（触发特殊效果时，伤害值=普通效果的公式+额外伤害公式）
4-减少对方怒气
5--增加己方怒气
6-回复自身生命（按造成伤害的万分比回血）
7-连续攻击（值为次数）
8-若目标死亡，周围4格内所有敌方单位受到相同伤害
9-清除目标身上不利状态
10--额外伤害2（触发特殊效果时，伤害值=额外伤害公式）
11--分身（1-10级分身数位1,11-20级分身数位2,21级以上分身数位3  分身持续4s）
12--对男性目标有额外加成（万分比）
13--对女性目标有额外加成（万分比）
14--清除己方单位的不利状态（100%成功），并有一定概率把不理状态转移到对方身上（随机）
15--提高对男性角色使用buff的成功率
--]]
--local SkillExtraAffect = {
--    Knockback = 1,
--    Seckilling = 2,
--    AddDamage_1 = 3,
--    DecEnemyRage = 4,
--    IncSelfRage = 5,
--    IncSelfHP = 6,
--    ComboHit = 7,
--    Bomber = 8,
--    ClearDebuff = 9,
--    AddDamage_2 = 10,
--    Replication = 11,
--    ExtraDamageForMale = 12,
--    ExtraDamageForFemale = 13,
--    TransferDebuff = 14,
--    IncMaleBuffSuccessRate = 15,
--}

BattleModel.SkillExtraAffectDealMap = {
    [enums.SkillExtraAffect.Knockback] = function(attackData)

    end,
}
function BattleModel:dealSkillExtraAffect(attackData)
    local extraAffect = attackData:getExtraAffectType()


end

function BattleModel:onHit(hero, damage)
    -- local side = hero:getTeamSide()
    -- if side == "left" then
    --     -- TODO:
    --     self.leftTeam:incRage(1)
    -- else
    --     self.rightTeam:incRage(1)
    -- end
end

function BattleModel:getPathFinder()
    local pathFinder = self._pathFinder

    if pathFinder == nil then
        local PathFinder = require("pathfinder")
        pathFinder = PathFinder.new(BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT)
        self._pathFinder = pathFinder
    end

    return pathFinder
end


function BattleModel:getWalkableBitmap(heroModel)
    if self._walkableBitmap == nil then
        self._walkableBitmap = bitarray2d.new(BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT)
    end

    local bitmap = self._walkableBitmap
    bitmap:zero()

    local heroModels = self.leftTeam:getAliveHeroModels(true)
    for _, hero in ipairs(heroModels) do
        if hero ~= heroModel and hero:isAlive() then
            local cell = hero:getNextCell() or hero:getCell()

            bitmap:set(cell.x, cell.y, true)
            -- 近战的后面也不能站人
            if hero:getFightType() == "near" then
                bitmap:set(cell.x - 1, cell.y, true)
                bitmap:set(cell.x + 1, cell.y, true)
                -- local direction = hero:getDirection()
                -- if direction == "right" then
                --     bitmap:set(cell.x - 1, cell.y, true)
                -- else
                --     bitmap:set(cell.x + 1, cell.y, true)
                -- end
            end

            local bulk = hero:getBulk()
            if bulk == 2 then
                bitmap:set(cell.x - 1, cell.y, true)
                bitmap:set(cell.x + 1, cell.y, true)
            elseif bulk == 3 then
                bitmap:set(cell.x, cell.y, true)
                bitmap:set(cell.x, cell.y - 1, true)
                bitmap:set(cell.x, cell.y + 1, true)
                bitmap:set(cell.x - 1, cell.y, true)
                bitmap:set(cell.x - 1, cell.y - 1, true)
                bitmap:set(cell.x - 1, cell.y + 1, true)
                bitmap:set(cell.x + 1, cell.y, true)
                bitmap:set(cell.x + 1, cell.y - 1, true)
                bitmap:set(cell.x + 1, cell.y + 1, true)
            end
        end
    end

    heroModels = self.rightTeam:getAliveHeroModels(true)
    for _, hero in ipairs(heroModels) do
        if hero ~= heroModel and hero:isAlive() then
            local cell = hero:getNextCell() or hero:getCell()

            bitmap:set(cell.x, cell.y, true)
            -- 近战的后面也不能站人
            if hero:getFightType() == "near" then
                bitmap:set(cell.x - 1, cell.y, true)
                bitmap:set(cell.x + 1, cell.y, true)
                -- local direction = hero:getDirection()
                -- if direction == "right" then
                --     bitmap:set(cell.x - 1, cell.y, true)
                -- else
                --     bitmap:set(cell.x + 1, cell.y, true)
                -- end
            end

            local bulk = hero:getBulk()
            if bulk == 2 then
                bitmap:set(cell.x - 1, cell.y, true)
                bitmap:set(cell.x + 1, cell.y, true)
            elseif bulk == 3 then
                bitmap:set(cell.x, cell.y, true)
                bitmap:set(cell.x, cell.y - 1, true)
                bitmap:set(cell.x, cell.y + 1, true)
                bitmap:set(cell.x - 1, cell.y, true)
                bitmap:set(cell.x - 1, cell.y - 1, true)
                bitmap:set(cell.x - 1, cell.y + 1, true)
                bitmap:set(cell.x + 1, cell.y, true)
                bitmap:set(cell.x + 1, cell.y - 1, true)
                bitmap:set(cell.x + 1, cell.y + 1, true)
            end
        end
    end

    for _, obstacle in ipairs(self.gameObstacle.obstacleList) do
        if obstacle:getObstacleType() == enums.ObstacleType.RoadBlock then
            local cell = obstacle.pos
            for y = 0, BattleConfig.Y_CELL_COUNT - 1 do
               bitmap:set(cell.x, y, true)
            end
        else
            local cell = obstacle.pos
            if (heroModel:getHeroMoveMode() == enums.HeroMoveMode.Walk) then
                for y = 0, BattleConfig.Y_CELL_COUNT - 1 do
                    bitmap:set(cell.x - 1, y, true)
                    bitmap:set(cell.x + 0, y, true)
                    bitmap:set(cell.x + 1, y, true)
                end
            end
        end
    end

    local prisonArea = self.magicCircleList:getPrisonArea(heroModel)
    if prisonArea then
        for y = 0, BattleConfig.Y_CELL_COUNT - 1 do
            for x = 0, BattleConfig.X_CELL_COUNT - 1 do
                if prisonArea:get(x, y) then
                    bitmap:set(x, y, true)
                end
            end
        end
    end

    return bitmap
end

function BattleModel:isWalkable(x, y, heroModel)
    local heroModels = self.leftTeam:getAliveHeroModels(true)
    for _, hero in ipairs(heroModels) do
        if hero ~= heroModel and hero:isAlive() then
            local cell = hero:getNextCell()
            if cell == nil then
                cell = hero:getCell()
            end

            if cell.y == y then
                if cell.x == x  then
                    return false
                end

                -- 近战的后面也不能站人
                if hero:getFightType() == "near" then
                    if cell.x - 1 == x or cell.x + 1 == x then
                        return false 
                    end
                    -- local direction = hero:getDirection()
                    -- if direction == "right" then
                    --     if cell.x - 1 == x then
                    --         return false
                    --     end
                    -- else
                    --     if cell.x + 1 == x then
                    --         return false
                    --     end
                    -- end
                end
            end
            if heroModel then
                local bulk = hero:getBulk()
                if bulk == 2 then
                    if cell.y == y and math.abs(cell.y - y) <= 1 then
                        return false
                    end
                elseif bulk == 3 then
                    if math.abs(cell.x - x) <= 1 and math.abs(cell.y - y) <= 1 then
                        return false
                    end
                end
            end
        end
    end

    heroModels = self.rightTeam:getAliveHeroModels(true)
    for _, hero in ipairs(heroModels) do
        if hero ~= heroModel and hero:isAlive() then
            local cell = hero:getNextCell()
            if cell == nil then
                cell = hero:getCell()
            end
            if cell.y == y then
                if cell.x == x  then
                    return false
                end

                -- 近战的后面也不能站人
                if hero:getFightType() == "near" then
                    local direction = hero:getDirection()
                    if cell.x - 1 == x or cell.x + 1 == x then
                        return false 
                    end
                    -- if direction == "right" then
                    --     if cell.x - 1 == x then
                    --         return false
                    --     end
                    -- else
                    --     if cell.x + 1 == x then
                    --         return false
                    --     end
                    -- end
                end
            end
            if heroModel then
                local bulk = hero:getBulk()
                if bulk == 2 then
                    if cell.y == y and math.abs(cell.y - y) <= 1 then
                        return false
                    end
                elseif bulk == 3 then
                    if math.abs(cell.x - x) <= 1 and math.abs(cell.y - y) <= 1 then
                        return false
                    end
                end
            end
        end
    end

    for _, obstacle in ipairs(self.gameObstacle.obstacleList) do
        if obstacle:getObstacleType() == enums.ObstacleType.RoadBlock then
            local cell = obstacle.pos
            if cell.x == x or cell.x + 1 == x or cell.x - 1 == x then
                return false
            end
        else
            local cell = obstacle.pos
            if (heroModel:getHeroMoveMode() == enums.HeroMoveMode.Walk) and (cell.x == x or cell.x + 1 == x or cell.x - 1 == x) then
                return false
            end
        end
    end

    local prisonArea = self.magicCircleList:getPrisonArea(heroModel)
    if prisonArea then
        local xrange = prisonArea[y]
        if xrange then
            if x < xrange.start then
                return false
            elseif x >= xrange.start + xrange.len then
                return false
            end
        else
            return false
        end
    end

    return true
end

-- 格子是否被占用
function BattleModel:isGridUsed(x, y, heroModel)
    local heroModels = self.leftTeam:getAliveHeroModels(true)
    for _, hero in ipairs(heroModels) do
        if hero ~= heroModel and hero:isAlive() then
            local cell = hero:getNextCell()
            if cell == nil then
                cell = hero:getCell()
            end

            if cell.y == y then
                if cell.x == x  then
                    return true
                end

                -- 近战的后面也不能站人
                if hero:getFightType() == "near" then
                    if cell.x + 1 == x or cell.x - 1 == x then
                        return true
                    end
                    -- local direction = hero:getDirection()
                    -- if direction == "right" then
                    --     if cell.x - 1 == x then
                    --         return true
                    --     end
                    -- else
                    --     if cell.x + 1 == x then
                    --         return true
                    --     end
                    -- end
                end
            end
        end
    end

    heroModels = self.rightTeam:getAliveHeroModels(true)
    for _, hero in ipairs(heroModels) do
        if hero ~= heroModel and hero:isAlive() then
            local cell = hero:getCell()
            if cell.y == y then
                if cell.x == x  then
                    return true
                end

                -- 近战的后面也不能站人
                if hero:getFightType() == "near" then
                    if cell.x + 1 == x or cell.x - 1 == x then
                        return true
                    end

                    -- local direction = hero:getDirection()
                    -- if direction == "right" then
                    --     if cell.x - 1 == x then
                    --         return true
                    --     end
                    -- else
                    --     if cell.x + 1 == x then
                    --         return true
                    --     end
                    -- end
                end
            end
        end
    end

    --CCLog("obstacle count", #self.gameObstacle.obstacleList)
    for _, obstacle in ipairs(self.gameObstacle.obstacleList) do
        if obstacle:getObstacleType() == enums.ObstacleType.RoadBlock then
            local cell = obstacle.pos
            --CCLog(vardump({cell}, "obstacle pos"))
            if cell.x == x or cell.x + 1 == x or cell.x - 1 == x then
                return true
            end
        else
            local cell = obstacle.pos
            if (heroModel == nil or heroModel:getHeroMoveMode() == enums.HeroMoveMode.Walk) and (cell.x == x or cell.x + 1 == x or cell.x - 1 == x) then
                return true
            end
        end
    end

    if heroModel then
    local prisonArea = self.magicCircleList:getPrisonArea(heroModel)
        if prisonArea then
            local xrange = prisonArea[y]
            if xrange then
               if x < xrange.start then
                   return true
               elseif x >= xrange.start + xrange.len then
                   return true
               end
            else
                return true
            end
        end
    end

    return false
end

function BattleModel:isGridToBeUse(x, y)
    local heroModels = self.leftTeam:getAliveHeroModels()
    for _, hero in ipairs(heroModels) do
        if hero:isAlive() then
            local nextCell = hero:getNextCell()
            if nextCell then
                if nextCell.x == x and nextCell.y == y then
                    return true
                end
            end
        end
    end

    heroModels = self.rightTeam:getAliveHeroModels()
    for _, hero in ipairs(heroModels) do
        if hero:isAlive() then
            local nextCell = hero:getNextCell()
            if nextCell then
                if nextCell.x == x and nextCell.y == y then
                    return true
                end
            end
        end
    end
end

function BattleModel:onBattleRoundStart()
    CCLog("Round start")
    self.leftTeam:onBattleRoundStart()
    self.rightTeam:onBattleRoundStart()

    self.gameAI:onBattleRoundStart()
end

function BattleModel:onBattleRoundEnd()
    CCLog("Round end")
    self.timeLeft = BattleConfig.ROUND_TIME
    
    self:setState("none")

    -- if self.params.battleType == "GUIDE" then
    --     local heroModels = self.leftTeam:getAliveHeroModels(true, false)
    --     for _, hero in ipairs(heroModels) do
    --         self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = hero:getFighterID(), fadeoutTime = 0 })
    --     end

    --     local heroModels = self.rightTeam:getAliveHeroModels(true, false)
    --     for _, hero in ipairs(heroModels) do
    --         self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = hero:getFighterID(), fadeoutTime = 0  })
    --     end

    --     self.leftTeam:setRage(0)
    --     self.rightTeam:setRage(0)
    -- end

    self.leftTeam:onBattleRoundEnd()
    self.rightTeam:onBattleRoundEnd()

    if self.params.battleType == "PVE" or self.params.battleType == "GUIDE" then
        self:releaseGameAI()
        self:releaseTrap()
        self:releaseObstacle()        
    end

    self.magicCircleList:clear()
end

function BattleModel:getCurRoundBeginStory()
    if self.params.battleType == "PVE" or self.params.battleType == "GUIDE" then
        local subNode = self.params.nodeSequence[self.roundIndex] or {}
        return subNode.BeginStory
    else
        return nil
    end
end

function BattleModel:getCurRoundXXXStory()
    if self.params.battleType == "PVE" or self.params.battleType == "GUIDE" then
        local subNode = self.params.nodeSequence[self.roundIndex] or {}
        return subNode.XXXStory -- TODO:
    else
        return nil
    end
end

function BattleModel:getCurRoundEndStory()
    if self.params.battleType == "PVE"  or self.params.battleType == "GUIDE"then
        local subNode = self.params.nodeSequence[self.roundIndex] or {}
        return subNode.EndStory
    else
        return nil
    end
end

function BattleModel:loadGameAI(roundIndex)
    local subNode = self.params.nodeSequence[roundIndex] or {}
    local aiIDList = subNode.Ai or {}
    self.gameAI:load(aiIDList)
end

function BattleModel:releaseGameAI()
    self.gameAI:releaseAI()
end

function BattleModel:onObstacleAIEvent()
    self.gameAI:onEvent(AppEvent.UI.Battle.Obstacle, nil)
end

function BattleModel:loadTrap(roundIndex)
    local subNode = self.params.nodeSequence[roundIndex] or {}
    local trapData = subNode.Trap or {}
    self.gameTrap:loadTrapList(trapData)
end

function BattleModel:releaseTrap()
    self.gameTrap:releaseTrapList()
end

function BattleModel:loadObstacle(roundIndex)
    local subNode = self.params.nodeSequence[roundIndex] or {}

    local obstacleData = subNode.Obstacle or {}
    self.gameObstacle:loadObstacleList(obstacleData)
end

function BattleModel:loadTurret(roundIndex)
    if self.params.nodeSequence then
        local subNode = self.params.nodeSequence[roundIndex] or {}

        local turretData = subNode.Turret or {}
        if #turretData > 0 then
            self.rightTeam:loadTurret(turretData)
        end
    end
end

function BattleModel:releaseObstacle()
    local precipice = false
    for _, obstacle in ipairs(self.gameObstacle.obstacleList) do
        if obstacle:getObstacleType() == enums.ObstacleType.Precipice then
            precipice = true
            break
        end
    end

    if precipice then
        CCLog("有悬崖，杀死不能飞的英雄")
        local leftTeam = self.leftTeam
        local aliveHeroList = leftTeam:getAliveHeroModels()
        for _, hero in ipairs(aliveHeroList) do
           if hero:getHeroMoveMode() == enums.HeroMoveMode.Walk then
              hero:stuck()
           end
        end
    else
        CCLog("没有悬崖")
    end

    self.gameObstacle:releaseObstacleList()
end

-- 技能相关 --
--function BattleModel:doInstantDamage(attackData)
--    local heroList = attackData:getTargetFighterList()
--    for _, hero in ipairs(heroList) do
--        self:doHit(hero, attackData)
--    end
--end
--
--function BattleModel:doInstantTreatment(attackData)
--    local heroList = attackData:getTargetFighterList()
--    for _, hero in ipairs(heroList) do
--        local hp = self:calcSkillAffectValue(attackData, hero)
--        hero:treat(attackData, hp)
--    end
--end

function BattleModel:calcSkillAffectValue(attackData, target, params)
    -- TODO:
    if params == nil then
        params = attackData:generateFormulaParams(target)
    end

    local skillData = attackData:getSkillData()
    local formulaExpr = BaseConfig.FormulaContent(skillData.formula)
    local formulaFunction = assert(BaseConfig.FormulaFunc(skillData.formula), string.format("formula[%d]:%s", skillData.formula, formulaExpr))

    CCLog(vardump({a = attackData.attacker:getName(), d = target:getName(), ID = skillData.formula, expr = formulaExpr, params = params}, "formula"))

    local affectValue = formulaFunction(params)

    CCLog(vardump({result = affectValue}))
    
    return affectValue
end

--function BattleModel:doResurrection(attackData)
--    local heroList = attackData:getTargetFighterList()
--    if #heroList then
--        local heroModel = attackData:getHeroModel()
--        local team = self.battleModel:getTeam(heroModel:getTeamSide())
--        team:setResurrectionData(attackData, heroList)
--    end
--end

function BattleModel:doAddBuff(attackData)
    CCLog(vardump(attackData.skillData.buff, "BattleController:doAddBuff()"))
    local skillData = attackData.skillData
    local probability = skillData.buffProbability

    local randNum = self._random:value(1, 10000)
    CCLog(string.format("random:%d, probability:%d", randNum, probability))
    if randNum <= probability then
        local affectHeroList = attackData:getTargetFighterList()

        if #affectHeroList == 0 then
            CCLog("生效目标为空")
        else
            local attacker = attackData:getHeroModel()
            for _, hero in ipairs(affectHeroList) do
                for _, buffID in ipairs(skillData.buff) do
                    hero:addBuff(buffID, attacker, skillData.id, skillData.level)
                end
            end
        end
    end

    return true
end

function BattleModel:doHitEgg(subAttackData)
    local attackData = subAttackData.attackData
    if attackData.skillData.type == enums.SkillType.RageSkill then
        local attacker = attackData:getAttacker()
        local targetFighter = subAttackData.targetFighter

        CCLog("BattleModel:doHitEgg()", attacker:getName(), targetFighter:getName())
        local damage = 1
        subAttackData:setValue(damage)
        targetFighter:hitBy(damage, attacker)
        attacker:addDamageStat(damage)

        self:dispatchEvent(AppEvent.UI.Battle.Hit, {
            damage = damage,
            restraint = false,
            critical = false,
            skillID = attackData.skillData.id,
            fighterID = targetFighter:getFighterID(),
            attackerID = attacker:getFighterID(),
        })

        if not targetFighter:isAlive() then
            self:dispatchEvent(AppEvent.UI.Battle.Kill, {fighterID = attacker:getFighterID(), killedFighterID = targetFighter:getFighterID()})
        end
    end
end

function BattleModel:doHit(subAttackData)
    CCLog("BattleModel:doHit()")
    local attackData = subAttackData.attackData
    local attacker = attackData:getAttacker()
    local targetFighter = subAttackData.targetFighter

    if targetFighter:getFighterType() == "hero" and targetFighter:isEgg() then
       return self:doHitEgg(subAttackData)
    end

    while true do
        if not targetFighter:isHittableType() then
            CCLog(targetFighter:getName(), "是不被攻击类型")
            subAttackData:setValue(0)
            subAttackData:setStoped(true)
            subAttackData:setValidation(false)
            break
        end

        if not targetFighter:isHittable() then
            CCLog(targetFighter:getName(), "处于不可攻击状态")
            subAttackData:setValue(0)
            subAttackData:setStoped(true)
            subAttackData:setValidation(false)
            break
        end

        if not targetFighter:isAlive() then
            CCLog(targetFighter:getName(), "已经死亡")
            subAttackData:setValue(0)
            subAttackData:setStoped(true)
            subAttackData:setValidation(false)
            break
        end

--        if targetFighter:getFighterType() == "hero" and targetFighter:isHideTo(attacker) then
--            CCLog(targetFighter:getName(), "攻击隐身对象，有问题")
--            subAttackData:setValue(0)
--            subAttackData:setStoped(true)
--            subAttackData:setValidation(false)
--            break
--        end

        if attacker:getFighterType() == "obstacle" and targetFighter:getFighterType() == "hero" and targetFighter:restraint(attacker) then
            CCLog("障碍属性免疫")
            self:dispatchEvent(AppEvent.UI.Battle.Immune, {fighterID = targetFighter:getFighterID()})
            subAttackData:setValue(0)
            subAttackData:setStoped(true)
            subAttackData:setValidation(false)
            break
        end

        if targetFighter:isMissable() then
            local shooting = attacker:getHIT() / (attacker:getHIT() + targetFighter:getMISS()) + 0.28 + 0.0 - 0.0
            --CCLog(vardump({miss = attacker:getMISS(), hit = attacker:getHIT(), shooting = shooting}, "hit miss"))

            local randNum = self._random:value()
            if attackData:isRageSkill() then
                randNum = randNum / 2
            end

            if randNum >= shooting then
                CCLog("闪避")
                self:dispatchEvent(AppEvent.UI.Battle.MISS, {attackData = attackData:encode(), fighterID = targetFighter:getFighterID()})
                subAttackData:setValue(0)
                subAttackData:setStoped(true)
                subAttackData:setValidation(false)
                break
            end
        end

        local useShield, leftTimes = targetFighter:useSpellShield()
        if useShield then
            CCLog(targetFighter:getName(), "魔法盾", leftTimes)
            self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.SpellShield, fighterID = targetFighter:getFighterID()})
            subAttackData:setValue(0)
            subAttackData:setStoped(true)
            subAttackData:setValidation(false)
            break
        end

        -- 克制判断
        local restraint = attacker:restraint(targetFighter)

        -- 暴击判断
        local criticalHit = false
        --[[
           暴击率=（暴击值-韧性值）/（暴击值+常数A）*0.5+基础暴击率
           其中常数A暂定30，基础暴击率4%。暴击值为攻击方属性，韧性值为防御方属性。
           若暴击值-韧性值<0，则暴击率=基础暴击率

           暴击	韧性	基础暴击率	暴击中率
           初始数值	30	26	4%	7%
           极限值(平衡性)	300	280	4%	7%
           --]]
        if attackData.skillData.type == enums.SkillType.NormAttack then
            criticalHit = attackData.isNormAttackCritical
        else
            local A = 30
            local crit = attacker:getCRIT()
            local ten = targetFighter:getTEN()

            local critical = math.max((crit - ten) / (crit + A) * 0.5, 0) + 0.04 -- TODO:测试用
            local randNum = self._random:value()
            if randNum <= critical then
                criticalHit = true
            end
        end

        -- 反伤万分比
        local antiInjuryRatio = targetFighter:getAntiInjuryRatio()
        if attackData.skillData.type ~= enums.SkillType.NormAttack then
            local skillAntiInjuryRatio = targetFighter:getSkillAntiInjuryRatio()
            antiInjuryRatio = (antiInjuryRatio or 0) + (skillAntiInjuryRatio or 0)
        end

        -- 最终伤害结算
        do
            local  params = subAttackData:getFormulaParams()
            local damage = self:calcSkillAffectValue(attackData, targetFighter, params)

            -- 分身基础伤害加倍
            if  iskindof(targetFighter, "ReplicationModel") then
                damage = damage * 2
            end

            if subAttackData.extraDamageRatio > 0 then
                local extraDamage = damage * (subAttackData.extraDamageRatio / 10000.0)
                CCLog("extra damage:", extraDamage)
                damage = damage + extraDamage
            end

            if subAttackData.extraDamageValue > 0 then
                CCLog("extra damage:", subAttackData.extraDamageValue)
                damage = damage + subAttackData.extraDamageValue
            end

            -- 爆击加成
            if criticalHit then
                damage = damage * 2
            end

--            -- 情绪加成
--            if attacker:getFighterType() == "hero" and targetFighter:getFighterType() == "hero" then
--                local extraDamageRatio = attacker:getMoodExtraDamageRatio(targetFighter:getHeroID())
--                if extraDamageRatio ~= 0 then
--                    damage = (10000.0 + extraDamageRatio) / 10000.0 * damage
--                end
--            end

            -- 魔法盾减伤
            if targetFighter:getFighterType() == "hero" then
                local decDamage = targetFighter:useMagicShieldValue(attacker:getElemType(), damage)
                if decDamage and decDamage > 0 then
                    damage = math.max(damage - decDamage, 0)
                    if damage == 0 then
                        self:dispatchEvent(AppEvent.UI.Battle.Immune, {fighterID = targetFighter:getFighterID()})
                        subAttackData:setValue(0)
                        subAttackData:setStoped(true)
                        subAttackData:setValidation(false)
                        break
                    end
                end
            end

            -- 分身减伤
            if iskindof(attacker, "ReplicationModel") then
                damage = damage * attacker:getAttackRatio() / 10000.0
            end
            damage = math.floor(damage)

            self:dispatchEvent(AppEvent.UI.Battle.Hit, {
                damage = damage,
                restraint = restraint,
                critical = criticalHit,
                skillID = attackData.skillData.id,
                fighterID = targetFighter:getFighterID(),
                attackerID = attacker:getFighterID(),
            })

            subAttackData:setValue(damage)
            targetFighter:hitBy(damage, attacker)
            attacker:addDamageStat(damage)

            if antiInjuryRatio and antiInjuryRatio > 0 then
                if targetFighter:getFighterType() == "obstacle" and attacker:getFighterType() == "hero" and attacker:restraint(targetFighter) then
                    CCLog("反伤 障碍属性免疫")
                    self:dispatchEvent(AppEvent.UI.Battle.Immune, {fighterID = attacker:getFighterID()})
                else
                    local antiInjuryDamange = math.max(math.floor(damage * antiInjuryRatio / 10000), 1)
                    attacker:decHP(antiInjuryDamange, true, true)
                    targetFighter:addDamageStat(antiInjuryDamange)
                end
            end

            if not targetFighter:isAlive() then
                self:dispatchEvent(AppEvent.UI.Battle.Kill, {fighterID = attacker:getFighterID(), killedFighterID = targetFighter:getFighterID()})
            else
                targetFighter:incHitting(true)
                self:addAction(0.2, function() targetFighter:decHitting() end)
            end

            -- 正常退出
            break
        end
    end
end

--function BattleModel:__old__doHit(subAttackData)
--    local attackData = subAttackData.attackData
--    local hitHeroModel = subAttackData.targetFighter
--    local damage = self:calcSkillAffectValue(attackData, hitHeroModel)
--
--    if attackData:attackerIsHero() then
--        local attackHeroModel = attackData:getHeroModel()
--
--        --命中率计算： 命中率=攻方命中值/（攻方命中值+守方闪避值）+攻方基础命中率+攻方阵法命中率-守方阵法闪避率
--        local shooting = attackHeroModel:getHIT() / (attackHeroModel:getHIT() + hitHeroModel:getMISS()) + 0.28 + 0.0 - 0.0
--        CCLog(vardump({miss = hitHeroModel:getMISS(), hit = attackHeroModel:getHIT(), shooting = shooting}, "hit miss"))
--
--        local randNum = self._random:value()
--        if randNum >= shooting then
--            damage = 0
--            self:dispatchEvent(AppEvent.UI.Battle.MISS, {attackData = attackData:encode(), fighterID = hitHeroModel:getFighterID()})
--            subAttackData:setValue(damage)
--            subAttackData:setStoped(true)
--            subAttackData:setValidation(false)
--        else
--            --[[
--            暴击率=（暴击值-韧性值）/（暴击值+常数A）*0.5+基础暴击率
--            其中常数A暂定30，基础暴击率4%。暴击值为攻击方属性，韧性值为防御方属性。
--            若暴击值-韧性值<0，则暴击率=基础暴击率
--
--            暴击	韧性	基础暴击率	暴击中率
--            初始数值	30	26	4%	7%
--            极限值(平衡性)	300	280	4%	7%
--            --]]
--            do
--                local A = 30
--                local crit = attackHeroModel:getCRI()
--                local ten = hitHeroModel:getTEN()
--
--                local critical = (crit - ten) / (crit + A) * 0.5 + 0.4
--                local randNum = self._random:value()
--                if randNum >= shooting then
--                    damage = damage * 2
--                    self:dispatchEvent(AppEvent.UI.Battle.CRIT, {attackData = attackData:encode(), fighterID = hitHeroModel:getFighterID()})
--                end
--            end
--
--            -- 如果有法术盾并且有可用次数，伤害为0，并用掉一次
--            local hitterBuffList = hitHeroModel:getBuffManager()
--            if hitterBuffList:hasAffect(enums.BuffAffectType.SpellShield) then
--                local spellLeftTimes = hitterBuffList:getAffectValueLeft(enums.BuffAffectType.SpellShield)
--                if spellLeftTimes > 0 then
--                    damage = 0
--                    hitterBuffList:decAffectValueLeft(enums.BuffAffectType.SpellShield)
--
--                    self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.SpellShield, fighterID = hitHeroModel:getFighterID()})
--                end
--            elseif hitterBuffList:hasAffect(enums.BuffAffectType.MetalShield) and hitHeroModel:getElemType() ~= enums.ElemType.Fire then
--                local spellLeftTimes = hitterBuffList:getAffectValueLeft(enums.BuffAffectType.MetalShield)
--                if spellLeftTimes > 0 then
--                    damage = 0
--                    hitterBuffList:decAffectValueLeft(enums.BuffAffectType.MetalShield)
--
--                    self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.MetalShield, fighterID = hitHeroModel:getFighterID()})
--                end
--            elseif hitterBuffList:hasAffect(enums.BuffAffectType.WoodShield) and hitHeroModel:getElemType() ~= enums.ElemType.Metal then
--                local spellLeftTimes = hitterBuffList:getAffectValueLeft(enums.BuffAffectType.WoodShield)
--                if spellLeftTimes > 0 then
--                    damage = 0
--                    hitterBuffList:decAffectValueLeft(enums.BuffAffectType.WoodShield)
--
--                    self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.WoodShield, fighterID = hitHeroModel:getFighterID()})
--                end
--            elseif hitterBuffList:hasAffect(enums.BuffAffectType.WaterShield) and hitHeroModel:getElemType() ~= enums.ElemType.Earth  then
--                local spellLeftTimes = hitterBuffList:getAffectValueLeft(enums.BuffAffectType.WaterShield)
--                if spellLeftTimes > 0 then
--                    damage = 0
--                    hitterBuffList:decAffectValueLeft(enums.BuffAffectType.WaterShield)
--
--                    self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.WaterShield, fighterID = hitHeroModel:getFighterID()})
--                end
--            elseif hitterBuffList:hasAffect(enums.BuffAffectType.FireShield) and hitHeroModel:getElemType() ~= enums.ElemType.Water then
--                local spellLeftTimes = hitterBuffList:getAffectValueLeft(enums.BuffAffectType.FireShield)
--                if spellLeftTimes > 0 then
--                    damage = 0
--                    hitterBuffList:decAffectValueLeft(enums.BuffAffectType.FireShield)
--
--                    self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.FireShield, fighterID = hitHeroModel:getFighterID()})
--                end
--            elseif hitterBuffList:hasAffect(enums.BuffAffectType.EarthShield) and hitHeroModel:getElemType() ~= enums.ElemType.Wood then
--                local spellLeftTimes = hitterBuffList:getAffectValueLeft(enums.BuffAffectType.EarthShield)
--                if spellLeftTimes > 0 then
--                    damage = 0
--                    hitterBuffList:decAffectValueLeft(enums.BuffAffectType.EarthShield)
--
--                    self:dispatchEvent(AppEvent.UI.Battle.HitBuffAffect, {affect = enums.BuffAffectType.EarthShield, fighterID = hitHeroModel:getFighterID()})
--                end
--            end
--
--            -- 反弹伤害
--            if hitterBuffList:hasAffect(enums.BuffAffectType.AntiInjuryRatio) then
--                local ratio = hitterBuffList:getCachedAffectValue(enums.BuffAffectType.AntiInjuryRatio)
--                CCLog(vardump({ratio = ratio, damage = damage, buffList = hitterBuffList:toString()}, "反弹伤害"))
--                local antiInjuryDamange = damage * ratio / 10000
--                attackHeroModel:decHP(antiInjuryDamange)
--            end
--
--            CCLog("BattleHeroModel:hit(" .. damage .. ")")
--            local restraint = attackHeroModel:restraint(hitHeroModel)
--            self:dispatchEvent(AppEvent.UI.Battle.Hit, {damage = damage, restraint = restraint, skillID = attackData.skillData.id, fighterID = hitHeroModel:getFighterID()})
--            hitHeroModel:decHP(damage, false)
--            subAttackData:setValue(damage)
--            if not hitHeroModel:isAlive() then
--                self:dispatchEvent(AppEvent.UI.Battle.Kill, {fighterID = attackHeroModel:getFighterID(), killedFighterID = hitHeroModel:getFighterID()})
--                -- TODO:击杀回血
--            else
--                hitHeroModel:incHitting()
--                self:addAction(0.1, function() hitHeroModel:decHitting(false) end)
--            end
--        end
--    else
--        CCLog("TODO: 攻击者类型:", attackData:getAttackerType())
--        CCLog("Instance:hit(" .. damage .. ")")
--        self:dispatchEvent(AppEvent.UI.Battle.Hit, {damage = damage, restraint = false, skillID = attackData.skillData.id, fighterID = hitHeroModel:getFighterID()})
--        hitHeroModel:decHP(damage)
--        subAttackData:setValue(damage)
--        if not hitHeroModel:isAlive() then
--            -- TODO:击杀回血
--        else
--            hitHeroModel:incHitting()
--            self:addAction(0.2, function() hitHeroModel:decHitting() end)
--        end
--
--    end
--end

-- 关卡技能公式参数
function BattleModel:getFormulaParams()
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


    local ATK = 0
    local DEF = 0
    local MP = 0
    local HP = 0
    local FH = 0
    local heroLV = 0
    local WX = 1

    local damageAddition           = 0
    local damageReduction          = 0
    local skillAddition         = 0
    local skillReduction        = 0
    local treatmentAddition     = 0
    local treatedAddition       = 0
    local treatmentReduction    = 0
    local treatedReduction      = 0
    local specDamageAddition    = 0
    local specDamageReduction   = 0
    local comboHit              = 0

    local params = {
        ATK = ATK,
        DEF = DEF,
        MP = MP,
        HP = HP,
        FH = FH,
        heroLV = heroLV,
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
        WX = WX,
    }

    return params
end

return BattleModel
