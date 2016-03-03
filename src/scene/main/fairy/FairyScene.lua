--
-- Author: keyring
-- Date: 2014-09-18 16:03:39
--
local BaseScene = require("tool.helper.BaseScene")

local FairyScene = class("FairyScene",BaseScene)
local FairyLayer = require("scene.main.fairy.FairyLayer")

function FairyScene:ctor(data)
    FairyScene.super.ctor(self)
    local layer = FairyLayer.new(data)
    self:addChild(layer)    
end

return FairyScene