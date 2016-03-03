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

	local kelian = self:CreateEmoji("dummy/kelian.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_shawujing = self:CreateIcon(1028, wujing_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	--local icon_menwei = self:CreateIcon(1037)


    self.message = {
		{icon = icon_shawujing, dir = 2, speak = "沙悟净", msg = "这工厂还真远呀，不如咱先在这儿歇一晚再走吧，毕竟我算是个中老年人了…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "那酒店费你给！"},
    }


    self:AddInitEndEvent(function (  )
		shawujing:setVisible(true)
		wanjia:setVisible(true)

		shawujing:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		shawujing:setRotationSkewY(180)

        self:WaitToDialog(0.2)
		self:Emoji(shawujing, kelian)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

		if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, koubi)


		elseif hua == self.message[2].msg then
			self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
