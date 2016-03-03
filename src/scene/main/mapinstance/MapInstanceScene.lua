--
-- Author: keyring
-- Date: 2014-09-19 11:13:24
--
local BaseScene = require("tool.helper.BaseScene")

local MapInstanceScene = class("MapInstanceScene",BaseScene)
local MapInstanceLayer = require("scene.main.mapinstance.MapInstanceLayer")

function MapInstanceScene:ctor( nodeid,diff)
    MapInstanceScene.super.ctor(self)
    local layer = MapInstanceLayer.new(nodeid,diff)
    self:addChild(layer)    
end

return MapInstanceScene