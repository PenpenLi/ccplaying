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


	local ta_skins = {
		["Arm"] = 1037,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local tianwang = self:CreatePerson(650, 200, 1031, ta_skins)
	tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(400, 200, GameCache.Avatar.Figure)

	local deyi = self:CreateEmoji("dummy/deyi.png")

	local yiwen = self:CreateEmoji("dummy/yiwen.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "天王，这里究竟是哪里？"},
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "应该是在太2真人的神之领域里面吧。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "什么领域？"},
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "神之领域，封神之后拥有的一种空间力量，就跟企鹅空间一样，你可以随意改造和装扮。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "那天王你的领域是怎么装修的呀？"},
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "就是玲珑宝塔呀，一座五星级豪华大监狱…想不想进去看看？"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		--self:Emoji(wanjia, jingdai)
		self:WaitToDialog(0.2)
		self:Emoji(wanjia, yiwen)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, yiwen)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, deyi)
			tianwang:setAnimation(1, "atk_ko", false)
			tianwang:setAnimation(0, "idle", true)


		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
