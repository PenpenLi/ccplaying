--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/6
-- Time: 下午3:15
-- To change this template use File | Settings | File Templates.
--

local socket = require("socket")

local CommandServer = class("CommandServer")

function CommandServer:ctor(eventDispatcher)
    self.eventDispatcher = eventDispatcher
end

function CommandServer:sendCommand(name, data)

end

function CommandServer:onCommandReceived(name, data)

end

function CommandServer:update()

end

return CommandServer