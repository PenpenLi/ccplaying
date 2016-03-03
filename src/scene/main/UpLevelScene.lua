--
-- Author: keyring
-- Date: 2014-11-22 11:01:30
--
local BaseScene = require("tool.helper.BaseScene")

local UpLevelScene = class("UpLevelScene",BaseScene)
local UpLevelLayer = require("scene.main.UpLevelLayer")

function UpLevelScene:ctor( result)
    UpLevelScene.super.ctor(self)
    local layer = UpLevelLayer.new(result)
    self:addChild(layer)    
end

return UpLevelScene