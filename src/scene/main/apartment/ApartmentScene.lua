--
-- Author: keyring
-- Date: 2015-10-15 12:14:53
--
local BaseScene = require("tool.helper.BaseScene")

local ApartmentScene = class("ApartmentScene",BaseScene)
local ApartmentLayer = require("scene.main.apartment.ApartmentLayer")

function ApartmentScene:ctor( initdata )
    ApartmentScene.super.ctor(self)
    local layer = ApartmentLayer.new(initdata)
    self:addChild(layer)    
end

return ApartmentScene