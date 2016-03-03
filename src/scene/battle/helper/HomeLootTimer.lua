local Timer = require("scene.battle.helper.Timer")

local HomeLootTimer = class("HomeLootTimer", Timer)
-------------------------------------------------------------------------------

function HomeLootTimer:ctor(eventDispatcher, name)
    HomeLootTimer.super.ctor(self, 0, eventDispatcher, name)

    local homeTimeLeftHandler 
    homeTimeLeftHandler = application:addEventListener(AppEvent.UI.Home.CountDown, function(event)
        local result = event.data
        local time = result.Time
        self.timeLeft = time

        self:update()
    end)

    self.homeTimeLeftHandler = homeTimeLeftHandler
end

function HomeLootTimer:update()
    if not self.started then
        self.eventDispatcher:dispatchEvent(AppEvent.UI.Battle.TimerStart)
        self.started = true
    end

    if self.timeLeft <= 0 then
        self.eventDispatcher:dispatchEvent(AppEvent.UI.Battle.TimerEnd)
        self.finished = true

        if self.timerEndHandler then
            self.timerEndHandler()
        end
    end
end

function HomeLootTimer:cleanup()
    application:removeEventListener(self.homeTimeLeftHandler)
end

return HomeLootTimer
