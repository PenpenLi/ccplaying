local BaseScene = require("tool.helper.BaseScene")

local MapParallaxLayer = require("scene.test.MapParallaxLayer")
local MapParallaxScene = class("MapParallaxScene", BaseScene)

function MapParallaxScene:ctor()
    MapParallaxScene.super.ctor(self)

    local layer = MapParallaxLayer.new()
    self:addChild(layer)
end

return MapParallaxScene