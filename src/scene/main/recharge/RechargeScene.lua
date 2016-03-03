local BaseScene = require("tool.helper.BaseScene")
local RechargeScene = class("RechargeScene",BaseScene)
local RechargeLayer = require("scene.main.recharge.RechargeLayer")

function RechargeScene:ctor()
    RechargeScene.super.ctor(self)
    local layer = RechargeLayer.new()
    self:addChild(layer)    
end

return RechargeScene