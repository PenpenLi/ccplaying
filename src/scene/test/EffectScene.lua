local BaseScene = require("tool.helper.BaseScene")

local EffectLayer = require("scene.test.EffectLayer")
local EffectScene = class("EffectScene", BaseScene)

function EffectScene:ctor()
    EffectScene.super.ctor(self)

    local layer = EffectLayer.new()
    self:addChild(layer)
end

return EffectScene