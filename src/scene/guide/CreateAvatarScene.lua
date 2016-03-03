--
-- Author: keyring
-- Date: 2015-04-07 11:00:27
--
local BaseScene = require("tool.helper.BaseScene")

local CreateAvatarScene = class("CreateAvatarScene",BaseScene)
local CreateAvatarLayer = require("scene.guide.CreateAvatarLayer")

function CreateAvatarScene:ctor( callback)
    CreateAvatarScene.super.ctor(self)
    local layer = CreateAvatarLayer.new(callback)
    self:addChild(layer)    
end

return CreateAvatarScene