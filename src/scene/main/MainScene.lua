local BaseScene = require("tool.helper.BaseScene")

local MainLayer = require("scene.main.MainLayer")
local MainScene = class("MainScene", BaseScene)

function MainScene:ctor(isShowActivity)
    MainScene.super.ctor(self)
    local layer = MainLayer.new(isShowActivity)
    self:addChild(layer)
end

return MainScene