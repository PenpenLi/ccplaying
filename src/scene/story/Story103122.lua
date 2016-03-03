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


	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1067,
	}
    local tangseng = self:CreatePerson(350, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local wangmu_skins = {
		["Arm"] = 1036,
		["Hat"] = 1084,
		["Coat"] = 1065,
	}
	local wangmuniangniang = self:CreatePerson(SCREEN_WIDTH-350, 200, 1030, wangmu_skins)
	wangmuniangniang:setRotationSkewY(180)

	local haixiu = self:CreateEmoji("dummy/haixiu.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_wangmuniangniang = self:CreateIcon(1030, wangmu_skins)


    self.message = {
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "好啦乖，不闹了好不好，快让人把天气恢复咯，让我也看看你穿短裙的样子！"},
		{icon = icon_wangmuniangniang, dir = 2, speak = "王母娘娘", msg = "死相…那你得搬上来和我一起住！"},
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "可我是一枚像风一般的男子，只会过风一样的生活…"},
		{icon = icon_wangmuniangniang, dir = 2, speak = "王母娘娘", msg = "唐唐~~人家不依了的啦！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "麻痹呀！秀恩爱前能不能先把空调给关了呀！！没看见那边有只单身狗就要快被冻屎啦！！！"}


    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wanjia:setVisible(true)
		wangmuniangniang:setVisible(true)

		tangseng:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "idle", true)
		wangmuniangniang:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-450,200))

		local event = cc.CallFunc:create(function()
			tangseng:setAnimation(0, "idle", true)
			self:WaitToDialog(0.3)
		end)

        tangseng:runAction(cc.Sequence:create({go,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.5)
			self:Emoji(wangmuniangniang, haixiu)

		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)
			tangseng:setRotationSkewY(180)
			tangseng:setAnimation(0, "move", true)
			local go1 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-500,200))
			local event1 = cc.CallFunc:create(function()
				tangseng:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)
			tangseng:runAction(cc.Sequence:create({go1,event1}))

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)
			--tangseng:setRotationSkewY(180)
			wangmuniangniang:setAnimation(0, "move", true)
			local go2 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-450,200))
			local event2 = cc.CallFunc:create(function()
				wangmuniangniang:setAnimation(0, "idle", true)
				self:WaitToDialog(0.3)
			end)
			wangmuniangniang:runAction(cc.Sequence:create({go2,event2}))

		elseif hua == self.message[4].msg then

            wanjia:setAnimation(1, "hit", false)
            wanjia:addAnimation(1, "hit", false)
            wanjia:addAnimation(1, "hit", false)

            wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.5)
			self:Emoji(wanjia, fennu)

		elseif hua == self.message[5].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
