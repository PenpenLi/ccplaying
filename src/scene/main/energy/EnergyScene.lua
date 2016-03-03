local BaseScene = require("tool.helper.BaseScene")

local EnergyScene = class("EnergyScene",BaseScene)
local EnergyLayer = require("scene.main.energy.EnergyLayer")

function EnergyScene:ctor(upgradeInfo)
    EnergyScene.super.ctor(self)
    local layer = EnergyLayer.new(upgradeInfo)
    self:addChild(layer)    
end

return EnergyScene