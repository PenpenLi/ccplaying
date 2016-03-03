local BaseScene = require("tool.helper.BaseScene")

local ColiseumScene = class("ColiseumScene",BaseScene)
-- local ColiseumLayer = require("scene.main.coliseum.ColiseumLayer")
local ColiseumLayer = require("scene.main.coliseum.ArenaLayer")

function ColiseumScene:ctor( arenainfo )
    ColiseumScene.super.ctor(self)
    local layer = ColiseumLayer.new(arenainfo)
    self:addChild(layer)    
end

function ColiseumScene:onExit( )
	self:removeFromParent()
	self= nil
end

return ColiseumScene