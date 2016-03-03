local BaseScene = require("tool.helper.BaseScene")
local GambleScene = class("GambleScene", BaseScene)

function GambleScene:ctor(gambleInfoTab)
    GambleScene.super.ctor(self)
	local gambleLayer = require("scene.main.gamble.GambleLayer").new(gambleInfoTab)
    self:addChild(gambleLayer)
end

return GambleScene