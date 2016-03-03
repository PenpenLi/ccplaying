local BattleConfig = require("scene.battle.helper.BattleConfig")

local Timer = class("Timer")
-------------------------------------------------------------------------------

function Timer:ctor(duration, eventDispatcher, name)
	self.timeLeft = duration
	self.eventDispatcher = eventDispatcher
	self.name = name
	
	self.started = false
	self.finished = false

	self.timerEndHandler = nil
end

function Timer:update()
	if not self.started then
		self.eventDispatcher:dispatchEvent(AppEvent.UI.Battle.TimerStart)
		self.started = true
	end

	self.timeLeft = self.timeLeft - BattleConfig.TIME_UNIT

	if self.timeLeft <= 0 then
		self.eventDispatcher:dispatchEvent(AppEvent.UI.Battle.TimerEnd)
		self.finished = true

		if self.timerEndHandler then
			self.timerEndHandler()
		end
	end
end

function Timer:setEndCallback(handler)
	self.timerEndHandler = handler
end

function Timer:cleanup()
	
end

return Timer
