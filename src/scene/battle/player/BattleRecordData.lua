--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-7
-- Time: 上午11:51
-- 战斗记录数据
--

-------------------------------------------------------------------------------
local BattleRecordData = class("BattleRecordData")

BattleRecordData.EventNameIDMap = {
    [AppEvent.UI.Battle.Enter] = 1,
    [AppEvent.UI.Battle.Wait] = 2,
    [AppEvent.UI.Battle.Match] = 3,
    [AppEvent.UI.Battle.MoveBy] = 4,
    [AppEvent.UI.Battle.Ready] = 5,
    [AppEvent.UI.Battle.AttackBegin] = 6,
    [AppEvent.UI.Battle.AttackBreakOff] = 7,
    [AppEvent.UI.Battle.AttackComplete] = 8,
    [AppEvent.UI.Battle.Hit] = 9,
    --RageSkill = "怒气技能攻击",
    [AppEvent.UI.Battle.RegionRageSkill] = 10,
    [AppEvent.UI.Battle.HPChange] = 11,
    [AppEvent.UI.Battle.FighterDie] = 12,
    [AppEvent.UI.Battle.AttackScopeChange] = 13,
    [AppEvent.UI.Battle.HeroStateChange] = 14,
    [AppEvent.UI.Battle.BattleStateChange] = 15,
    [AppEvent.UI.Battle.HeroDirectionChange] = 16,
    [AppEvent.UI.Battle.Walk] = 17,
    [AppEvent.UI.Battle.HeroEnterCell] = 18,
    [AppEvent.UI.Battle.HeroToCell] = 19,
    [AppEvent.UI.Battle.BuffAdded ] = 20,
    [AppEvent.UI.Battle.BuffRemoved] = 21,
    [AppEvent.UI.Battle.BuffReplaced] = 22,
    [AppEvent.UI.Battle.RageChanged] = 23,
    [AppEvent.UI.Battle.RageComboHit] = 24,
    [AppEvent.UI.Battle.HitBuffAffect] = 25,
    [AppEvent.UI.Battle.MISS] = 26,
    [AppEvent.UI.Battle.HeroLineup] = 27,
    [AppEvent.UI.Battle.TeamLineup] = 28,
    [AppEvent.UI.Battle.TeamRelineup] = 29,
    [AppEvent.UI.Battle.HeroRelineup] = 30,
}

BattleRecordData.EventIDNameMap = {}
for name, id in pairs(BattleRecordData.EventNameIDMap) do
    BattleRecordData.EventIDNameMap[id] = name
end

function BattleRecordData:ctor()
    self.timeTickCount = 0
    self.timeTick = 0

    self.timeTickMap = {}

    self.attackerForm = nil
    self.battleUnits = nil
end

function BattleRecordData:setAttackerForm(form)
    self.attackerForm = form
end

function BattleRecordData:setBattleUnits(forms)
    self.battleUnits = forms
end

function BattleRecordData:init(attackerForm, battleUnits)
    self.attackerForm = attackerForm
    self.battleUnits = battleUnits
end

function BattleRecordData:addRecord()
    table.insert(self.timeTickMap, 0)
end

function BattleRecordData:onEvent(name, data)
    local lastRecord

    if #self.timeTickMap == 0 then
        self:addRecord()
    end
    lastRecord = self.timeTickMap[#self.timeTickMap]

    if type(lastRecord) ~= "table" then
        self.timeTickMap[#self.timeTickMap] = {}
        lastRecord = self.timeTickMap[#self.timeTickMap]
    end

    --local k = BattleRecordData.EventNameIDMap[name]
    local k = name
    table.insert(lastRecord, {k = k, v = data})
end

function BattleRecordData:update(dispatcher)
    self.timeTick = self.timeTick + 1
    
    CCLog("BattleRecordData:update(" .. self.timeTick .. ")")
    local eventArray = self.timeTickMap[self.timeTick]

    if dispatcher and type(eventArray) == "table" then
        for _, eventData in ipairs(eventArray) do
            --local name = BattleRecordData.EventIDNameMap[eventData.k]
            local name = eventData.k
            local event = cc.EventCustom:new(name)
            event.data = eventData.v
            CCLog(vardump(eventData, "Event"))
            dispatcher:dispatchEvent(event)
        end
    end
end

function BattleRecordData:getRecordJson()
    CCLog(vardump(self, "BattleRecordData"))
    return json.encode({timeTickMap = self.timeTickMap, attackerForm = self.attackerForm, battleUnits = self.battleUnits})
end

function BattleRecordData:load(path)
    local rawData = cc.FileUtils:getInstance():getStringFromFile(path)
    local jsData = json.decode(rawData)

    self.timeTickMap = jsData.timeTickMap
    self.attackerForm = jsData.attackerForm
    self.battleUnits = jsData.battleUnits
end

return BattleRecordData
