local BaseScene = require("tool.helper.BaseScene")

local TransportScene = class("TransportScene",BaseScene)
local TransportLayer = require("scene.main.transport.TransportLayer")

function TransportScene:ctor( )
    TransportScene.super.ctor(self)
    local layer = TransportLayer.new()
    self:addChild(layer)    
end

return TransportScene