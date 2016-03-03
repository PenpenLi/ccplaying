--
-- Author: keyring
-- Date: 2014-09-17 16:49:38
--

local BaseScene = require("tool.helper.BaseScene")

local TowerScene = class("TowerScene",BaseScene)
local TowerLayer = require("scene.main.tower.TowerLayer")

function TowerScene:ctor(towerInfo)
    TowerScene.super.ctor(self)
    local layer = TowerLayer.new(towerInfo)
    self:addChild(layer)    
end

return TowerScene