local BaseScene = require("tool.helper.BaseScene")
local PackageScene = class("PackageScene", BaseScene)

function PackageScene:ctor()
	PackageScene.super.ctor(self)
	local packageLayer = require("scene.main.package.PackageLayer").new()
    self:addChild(packageLayer)
end

return PackageScene