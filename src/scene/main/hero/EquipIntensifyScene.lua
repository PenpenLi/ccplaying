local BaseScene = require("tool.helper.BaseScene")
local EquipIntensifyScene = class("EquipIntensifyScene", BaseScene)

function EquipIntensifyScene:ctor(heroInfo, goodsInfo)
	EquipIntensifyScene.super.ctor(self)
	local equipIntensify = require("scene.main.hero.EquipIntensify").new(heroInfo, goodsInfo)
	equipIntensify:setName("layer")
    self:addChild(equipIntensify)
end

return EquipIntensifyScene