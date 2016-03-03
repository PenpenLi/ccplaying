local BaseScene = require("tool.helper.BaseScene")
local AllHeroScene = class("AllHeroScene", BaseScene)

function AllHeroScene:ctor()
	AllHeroScene.super.ctor(self)
	local allHeroLayer = require("scene.main.hero.AllHeroLayer").new()
	allHeroLayer:setName("layer")
    self:addChild(allHeroLayer)
end

return AllHeroScene