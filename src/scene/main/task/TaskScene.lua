local BaseScene = require("tool.helper.BaseScene")
local TaskScene = class("TaskScene",BaseScene)
local TaskLayer = require("scene.main.task.TaskLayer")

function TaskScene:ctor(taskInfoTabs, achievementInfoTabs)
    TaskScene.super.ctor(self)
    local layer = TaskLayer.new(taskInfoTabs, achievementInfoTabs)
    self:addChild(layer)    
end

return TaskScene