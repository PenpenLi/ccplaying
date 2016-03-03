--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/5
-- Time: 下午5:07
-- To change this template use File | Settings | File Templates.
--

local CommandClient = class("CommandClient")

function CommandClient:ctor(eventDispatcher)
    self.eventDispatcher = eventDispatcher
end

function CommandClient:sendCommand(name, data)

end

function CommandClient:onCommandReceived(name, data)

end

function CommandClient:update()

end

return CommandClient