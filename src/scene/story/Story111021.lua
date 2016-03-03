--
-- Author: Kamirotto
-- Date: 2015-04-24 15:48:47
--
local BaseStory = require("scene.story.BaseStory")
local Story = class("story", BaseStory)

function Story:ctor( callback )

	--[[
		1、初始化场景
		2、初始化父类
		3、初始化 头像 和对话 message
		4、添加剧情事件
	--]]


    -- 1\


	-- SCREEN_WIDTH    SCREEN_HEIGHT

	-- GameCache.Avatar.Figure

	-- GameCache.Avatar.Name


	local er_skins = {
		["Arm"] = 1004,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local erye = self:CreatePerson(-180, 200, 1015, er_skins)

    local wanjia = self:CreatePerson(-180, 200, GameCache.Avatar.Figure)
	--wanjia:setRotationSkewY(180)

	local han = self:CreateEmoji("dummy/han.png")

	local deyi = self:CreateEmoji("dummy/deyi.png")

	local yiwen = self:CreateEmoji("dummy/yiwen.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "二爷…"},
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "叫我官人！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "官…二爷，CCAV都说了民工工资不能拖欠，究竟是谁还这么胆大呀？"},
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "江南皮革厂的老总黄鹤！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "我怎么记得这件事有些年头了呀…"},
    }


    self:AddInitEndEvent(function (  )
		erye:setVisible(true)
		wanjia:setVisible(true)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(2.5, cc.p(650,200))
		local go1 = cc.MoveTo:create(2, cc.p(400,200))

		local event = cc.CallFunc:create(function()
			wanjia:setAnimation(0, "idle", true)
		end)

		local event1 = cc.CallFunc:create(function()
			erye:setAnimation(0, "idle", true)
			erye:setRotationSkewY(180)
		end)

		erye:runAction(cc.Sequence:create({go,event1}))
		wanjia:runAction(cc.Sequence:create({go1,event}))

		self:WaitToDialog(2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(erye, deyi)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, han)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, yiwen)


		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
