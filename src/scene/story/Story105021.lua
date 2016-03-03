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


	local niu_skins = {
		["Arm"] = 1008,
		["Hat"] = 1079,
		["Coat"] = 1054,
	}
    local niumowang = self:CreatePerson(-200, 200, 1016, niu_skins)
	--niumowang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)


	local daku = self:CreateEmoji("dummy/daku.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_niumowang = self:CreateIcon(1016, niu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "牛老大，咱们要干嘛？"},
		{icon = icon_niumowang, dir = 2, speak = "牛魔王", msg = "去把网络光纤线给弄断！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "弄断光纤干嘛？"},
		{icon = icon_niumowang, dir = 2, speak = "牛魔王", msg = "家里出了个败家娘们儿，成天只知道上网买买买呀…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "甭说了，我懂，都是苦命的男人呀…"},


    }


    self:AddInitEndEvent(function (  )
		niumowang:setVisible(true)
		wanjia:setVisible(true)

		niumowang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-350,200))
		local go1 = cc.MoveTo:create(3, cc.p(350,200))

		local event = cc.CallFunc:create(function()
			niumowang:setAnimation(0, "idle", true)
			niumowang:setRotationSkewY(180)
			wanjia:setAnimation(0, "idle", true)

			self:WaitToDialog(0.2)
		end)

		niumowang:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
            niumowang:setAnimation(1, "atk3", false)
            niumowang:setAnimation(0, "idle", true)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			--self:Emoji(niumowang, deyi)

			--tangseng:setAnimation(1, "move", true)

			--local go1 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-500,200))

			--local event1 = cc.CallFunc:create(function()
			--	tangseng:setAnimation(0, "idle", true)
			--	self:WaitToDialog(0.5)
			--end)

			--tangseng:runAction(cc.Sequence:create({go1,event1}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			--niumowang:setRotationSkewY(0)

			--niumowang:setAnimation(0, "move", true)
			--wanjia:setAnimation(0, "move", true)

			--local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-200,200))
			--local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-200,200))

			--local event = cc.CallFunc:create(function()
				--self:StoryEnd()
			--end)

			--tangseng:runAction(go)
			--wanjia:runAction(cc.Sequence:create({go1,event}))

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, daku)
            --shawujing:setAnimation(1, "atk3", false)
            --shawujing:setAnimation(0, "idle", true)

		elseif hua == self.message[5].msg then

            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
