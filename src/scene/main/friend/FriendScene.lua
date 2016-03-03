local BaseScene = require("tool.helper.BaseScene")
local FriendScene = class("FriendScene", BaseScene)

function FriendScene:ctor()
	FriendScene.super.ctor(self)
	local friendsLayer = require("scene.main.friend.FriendLayer").new()
    self:addChild(friendsLayer)
end

return FriendScene