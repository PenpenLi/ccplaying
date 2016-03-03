local BaseScene = require("tool.helper.BaseScene")

local InstanceDailyScene = class("InstanceDailyScene",BaseScene)
local InstanceDailyLayer = require("scene.main.instanceDaily.InstanceDailyLayer")

function InstanceDailyScene:ctor(info)
    InstanceDailyScene.super.ctor(self)
    local layer = InstanceDailyLayer.new(info)
    self:addChild(layer)    
end

return InstanceDailyScene