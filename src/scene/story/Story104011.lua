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
    local shawujing = self:CreatePerson(SCREEN_WIDTH*0.5+180, 200, 1028, wujing_skins)

    local wanjia = self:CreatePerson(SCREEN_WIDTH*0.5-170, 200, GameCache.Avatar.Figure)

	local deyi = self:CreateEmoji("dummy/deyi.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local han = self:CreateEmoji("dummy/han.png")

	local touxiao = self:CreateEmoji("dummy/touxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_shawujing = self:CreateIcon(1028, wujing_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_shawujing, dir = 2, speak = "沙悟净", msg = "看呐，天是这么蓝呀，要是雾霾能一直那么少就好了！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你要少抽两口烟这空气质量能再高些！"},
		{icon = icon_shawujing, dir = 2, speak = "沙悟净", msg = "抽完这口我就戒烟，我保证！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "嗨，其实主要还是那些昧良心又没节操乱排污的工厂。"},
		{icon = icon_shawujing, dir = 2, speak = "沙悟净", msg = "那咱去治治这些工厂怎样？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "说走咱就走啊~"},
    }


    self:AddInitEndEvent(function (  )
		shawujing:setVisible(true)
		wanjia:setVisible(true)

		shawujing:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		shawujing:setRotationSkewY(180)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, koubi)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shawujing, han)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shawujing, deyi)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, touxiao)

			shawujing:setRotationSkewY(0)
			shawujing:setAnimation(0, "move", true)
			wanjia:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))
			local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH+200,200))

			shawujing:runAction(go)
			wanjia:runAction(go1)


		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
