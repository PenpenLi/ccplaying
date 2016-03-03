local BaseScene = require("tool.helper.BaseScene")

local SprotoLayer = require("scene.test.SprotoLayer")
local SprotoScene = class("SprotoScene", BaseScene)

function SprotoScene:ctor()
    SprotoScene.super.ctor(self)

    local layer = SprotoLayer.new()
    self:addChild(layer)
end

return SprotoScene