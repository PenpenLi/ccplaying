--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/2
-- Time: 下午4:41
-- To change this template use File | Settings | File Templates.
--

local BaseScene = require("tool.helper.BaseScene")

local VersionCheckLayer = require("scene.update.VersionCheckLayer")
local VersionCheckScene = class("VersionCheckScene", BaseScene)

function VersionCheckScene:ctor(verCheckResult)
    VersionCheckScene.super.ctor(self)
    local layer = VersionCheckLayer.new(verCheckResult)
    self:addChild(layer)
end

return VersionCheckScene