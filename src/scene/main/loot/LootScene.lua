local BaseScene = require("tool.helper.BaseScene")
local LootScene = class("LootScene", BaseScene)

function LootScene:ctor(treasureTabs, winInfo)
    LootScene.super.ctor(self)  
	local LootLayer = require("scene.main.loot.LootLayer").new(treasureTabs, winInfo)
    self:addChild(LootLayer)
end

return LootScene