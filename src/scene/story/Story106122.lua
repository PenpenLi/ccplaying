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
    local leizhenzi = self:CreatePerson(350, 200, 1048, lei_skins)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local diao_skins = {
		["Arm"] = 1016,
		["Hat"] = 1092,
		["Coat"] = 1067,
	}
	local dapengdiao = self:CreatePerson(SCREEN_WIDTH-350, 200, 1048, diao_skins)
	dapengdiao:setRotationSkewY(180)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_dapengdiao = self:CreateIcon(1048, diao_skins)


    self.message = {
		{icon = icon_dapengdiao,dir = 2, speak = "金翅大鹏雕", msg = "各位老板，有话好说，求别打脸！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "王母娘娘网购的那条超（qi）短（bi）裙你们送到哪里去了呀！"},
		{icon = icon_dapengdiao,dir = 2, speak = "金翅大鹏雕", msg = "你是说天狗ID“第一大美女”是王母娘娘？"},
		{icon = icon_leizhenzi, dir = 1, speak = "雷震子", msg = "少特么废话，你到底是赔还是不赔？"},
		{icon = icon_dapengdiao,dir = 2, speak = "金翅大鹏雕", msg = "赔，我赔，这次保证30秒内送达。"},

    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)
		dapengdiao:setVisible(true)


			self:WaitToDialog(0.5)


    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.0)


		elseif hua == self.message[2].msg then
			self:Emoji(dapengdiao, jingdai)
			self:WaitToDialog(0.5)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.5)
			leizhenzi:setAnimation(1, "atk1", false)
			leizhenzi:setAnimation(0, "idle", true)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.5)

		elseif hua == self.message[5].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
