local BaseScene = require("tool.helper.BaseScene")
local HomeScene = class("HomeScene", BaseScene)

function HomeScene:ctor(homeInfo, isOwn, enemyInfo)
    HomeScene.super.ctor(self)  
	local HomeLayer = require("scene.main.home.HomeLayer").new(homeInfo, isOwn, enemyInfo)
    self:addChild(HomeLayer)
end

return HomeScene