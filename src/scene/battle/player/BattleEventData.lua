--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-7
-- Time: 下午3:54
-- To change this template use File | Settings | File Templates.
--

local BattleEventData = {}

BattleEventData.EncoderMap = {
    [AppEvent.UI.Battle.Wait] = function(data)

    end,
    [AppEvent.UI.Battle.Match] = function(data)

    end,
    [AppEvent.UI.Battle.MoveBy] = function(data)

    end,
    [AppEvent.UI.Battle.AttackScopeChange] = function(data)

    end,
    [AppEvent.UI.Battle.AttackBegin] = function(data)

    end,
    [AppEvent.UI.Battle.AttackComplete] = function(data)

    end,
    [AppEvent.UI.Battle.AttackBreakOff] = function(data)

    end,
    [AppEvent.UI.Battle.Hit] = function(data)

    end,
    [AppEvent.UI.Battle.MISS] = function(data)

    end,
    [AppEvent.UI.Battle.RegionRageSkill] = function(data)

    end,
    [AppEvent.UI.Battle.HPChange] = function(data)

    end,
    [AppEvent.UI.Battle.FighterDie] = function(data)

    end,
    [AppEvent.UI.Battle.Ready] = function(data)

    end,
    [AppEvent.UI.Battle.Walk] = function(data)

    end,
    [AppEvent.UI.Battle.BattleStateChange] = function(data)

    end,
    [AppEvent.UI.Battle.HeroDirectionChange] = function(data)

    end,
    [AppEvent.UI.Battle.BuffAdded] = function(data)

    end,
    [AppEvent.UI.Battle.BuffRemoved] = function(data)

    end,
    [AppEvent.UI.Battle.BuffReplaced] = function(data)

    end,
    [AppEvent.UI.Battle.RageChanged] = function(data)

    end,
    [AppEvent.UI.Battle.RageComboHit] = function(data)

    end,
}

function BattleEventData:ctor(eventName, data)
    self.name = eventName
    self.data = data
end

function BattleEventData:encode()
    return {name = self.name, data = self.data}
end

function BattleEventData:decode(record)

end

return BattleEventData
