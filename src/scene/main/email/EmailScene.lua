local BaseScene = require("tool.helper.BaseScene")

local EmailScene = class("EmailScene",BaseScene)
local EmailLayer = require("scene.main.email.EmailLayer")

function EmailScene:ctor( emaillist )
    EmailScene.super.ctor(self)
    local layer = EmailLayer.new(emaillist)
    self:addChild(layer)	
end

return EmailScene