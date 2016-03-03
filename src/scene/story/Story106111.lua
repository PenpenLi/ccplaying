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


	local lei_skins = {
		["Arm"] = 1010,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local leizhenzi = self:CreatePerson(500, 200, 1048, lei_skins)

    local wanjia = self:CreatePerson(350, 200, GameCache.Avatar.Figure)

	--local qianliyan = self:CreatePerson(SCREEN_WIDTH-350, 200, 1053)
	--qianliyan:setRotationSkewY(180)

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local han = self:CreateEmoji("dummy/han.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_leizhenzi,dir = 2, speak = "雷震子", msg = "难道这里就是传说中的狮驼洞！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你说“洞”这个字的时候能不能不要想太多了？"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)

		leizhenzi:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		leizhenzi:setRotationSkewY(180)

        self:Emoji(leizhenzi, yiwen)
		self:WaitToDialog(0.5)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.5)
			self:Emoji(wanjia, han)

		elseif hua == self.message[2].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
