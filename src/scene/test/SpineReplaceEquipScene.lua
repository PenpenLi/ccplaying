local BaseScene = require("tool.helper.BaseScene")

local ReplaceEquipLayer = require("scene.test.SpineReplaceEquipLayer")
local ReplaceEquipScene = class("SpineReplaceEquipScene", BaseScene)

function ReplaceEquipScene:ctor()
    ReplaceEquipScene.super.ctor(self)

    local layer = ReplaceEquipLayer.new()
    self:addChild(layer)
end

return ReplaceEquipScene