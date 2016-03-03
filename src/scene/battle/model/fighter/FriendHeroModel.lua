local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
-------------------------------------------------------------------------------

local FriendHeroModel = class("FriendHeroModel", BattleHeroModel)

function FriendHeroModel:ctor(...)
    FriendHeroModel.super.ctor(self, ...)
    self._timeLeft = BattleConfig.FRIEND_GUARD_TIME
end

function FriendHeroModel:expired()
    FriendHeroModel.super.die(self, true)

    CCLog("FriendHeroModel:expired()", debug.traceback())
    self:dispatchEvent(AppEvent.UI.Battle.FighterExpired, {fighterID = self:getFighterID(),  fadeoutTime = 0.5})
end

function FriendHeroModel:update(battleModel)
    FriendHeroModel.super.update(self, battleModel)

    self._timeLeft = self._timeLeft - BattleConfig.TIME_UNIT
    if self._timeLeft <= 0 then
        self:expired()
    end

    --CCLog("FriendHeroModel.timeLeft", self._timeLeft)
end

return FriendHeroModel