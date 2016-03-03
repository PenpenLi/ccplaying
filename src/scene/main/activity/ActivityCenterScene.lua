local BaseScene = require("tool.helper.BaseScene")
local ActivityCenterScene = class("ActivityCenterScene",BaseScene)
local ActivityCenterLayer = require("scene.main.activity.ActivityCenterLayer")

function ActivityCenterScene:ctor(dailyCheckInfo, accCheckInfo, activityInfo, jumpPanel)
    ActivityCenterScene.super.ctor(self)
    local layer = ActivityCenterLayer.new(dailyCheckInfo, accCheckInfo, activityInfo, jumpPanel)
    layer:setName("layer")
    self:addChild(layer)    
end

return ActivityCenterScene