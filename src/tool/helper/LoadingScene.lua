--
-- Author: keyring
-- Date: 2014-11-29 14:27:38
--

local BaseScene = require("tool.helper.BaseScene")
local LoadingLayer = import(".LoadingLayer")
-------------------------------------------------------------------------------

local LoadingScene = class("LoadingScene", BaseScene)

function LoadingScene:ctor(Scene, ...)
    LoadingScene.super.ctor(self)
    local layer = LoadingLayer.new(Scene, ...)
    self:addChild(layer)
end

return LoadingScene