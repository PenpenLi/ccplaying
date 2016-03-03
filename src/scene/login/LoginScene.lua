local BaseScene = require("tool.helper.BaseScene")
local LoginLayer = require("scene.login.LoginLayer")
local LoginScene = class("LoginScene", BaseScene)

function LoginScene:ctor()
    LoginScene.super.ctor(self)
    
    local layer = LoginLayer.new()
    self:addChild(layer)
end

return LoginScene