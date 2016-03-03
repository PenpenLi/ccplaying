local BaseScene = require("tool.helper.BaseScene")
local EquipRecycleScene = class("EquipRecycleScene", BaseScene)

function EquipRecycleScene:ctor()
    EquipRecycleScene.super.ctor(self)
	local RecycleLayer = require("scene.main.equipRecycle.EquipRecycleLayer").new()
    self:addChild(RecycleLayer)
end

return EquipRecycleScene