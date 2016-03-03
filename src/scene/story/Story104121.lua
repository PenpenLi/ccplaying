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


	local wujing_skins = {
		["Arm"] = 1010,
		["Hat"] = 1083,
		["Coat"] = 0,
	}
    local shawujing = self:CreatePerson(-200, 200, 1028, wujing_skins)

    local wanjia = self:CreatePerson(-550, 200, GameCache.Avatar.Figure)

	local pm25 = self:CreateMonster(SCREEN_WIDTH-280, 200, "bs_huoyanzhiwang")
	pm25:setRotationSkewY(180)

	local touxiao = self:CreateEmoji("dummy/touxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_shawujing = self:CreateIcon(1028, wujing_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_pm25 = self:CreateMonsterIcon("bs_huoyanzhiwang", 0.5)


    self.message = {
		{icon = icon_pm25, dir = 2, speak = "屁艾姆2.5", msg = "尘归尘，土归土，我就是PM2.5！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "哪里来的外国妖怪！！！"},
		{icon = icon_pm25, dir = 2, speak = "屁艾姆2.5", msg = "你猜？"},
		{icon = icon_shawujing, dir = 1, speak = "沙悟净", msg = "猜你妹！这么严重的污染，铁定是你丫搞的鬼！"},
		{icon = icon_pm25, dir = 2, speak = "屁艾姆2.5", msg = "我只是放了几个屁而已~"},
		{icon = icon_shawujing, dir = 1, speak = "沙悟净", msg = "看我今天把你的菊花给堵上咯！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "沙哥，看不出来口味挺重的呀，我看好你哟！"},


    }


    self:AddInitEndEvent(function (  )
		shawujing:setVisible(true)
		wanjia:setVisible(true)
		pm25:setVisible(true)

		shawujing:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

        local go = cc.MoveTo:create(2.2, cc.p(380,200))
		local go1 = cc.MoveTo:create(2.2, cc.p(180,200))

		local event = cc.CallFunc:create(function()
			shawujing:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)

			self:WaitToDialog(0.2)
		end)

		shawujing:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			--shawujing:setRotationSkewY(180)
			--tangseng:setRotationSkewY(180)
			--tangseng:setAnimation(1, "move", true)
			--local go1 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-500,200))
			--local event1 = cc.CallFunc:create(function()
			--	tangseng:setAnimation(0, "idle", true)
			--	self:WaitToDialog(0.5)
			--end)
			--tangseng:runAction(cc.Sequence:create({go1,event1}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			--self:Emoji(wanjia, koubi)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(pm25, touxiao)


		elseif hua == self.message[5].msg then
            shawujing:setAnimation(1, "atk3", false)
            shawujing:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)


		elseif hua == self.message[6].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[7].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
