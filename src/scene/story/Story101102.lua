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


	local bajie_skins = {
		["Arm"] = 1006,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local bajie = self:CreatePerson(SCREEN_WIDTH*0.5+150, 200, 1027, bajie_skins)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1069,
	}
	local longnv = self:CreatePerson(SCREEN_WIDTH*0.5-180, 200, 1040, longnv_skins)

	local koubi = self:CreateEmoji("dummy/koubi.png")
	local heixian = self:CreateEmoji("dummy/heixian.png")
	local jingkong = self:CreateEmoji("dummy/jingkong.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


	local icon_bajie = self:CreateIcon(1027, bajie_skins)

	local icon_longnv = self:CreateIcon(1040, longnv_skins)


    self.message = {
		{icon = icon_longnv, dir = 1, speak = "龙女", msg = "难道这个就是女神的大杀器？"},
		{icon = icon_bajie, dir = 2, speak = "猪八戒", msg = "真是吓死本宝宝了…"},
		{icon = icon_longnv, dir = 1, speak = "龙女", msg = "瞧你这点出息！"},
    }


    self:AddInitEndEvent(function ()
    	bajie:setVisible(true)
    	longnv:setVisible(true)

    	bajie:setAnimation(0, "idle", true)
    	longnv:setAnimation(0, "idle", true)

    	self:WaitToDialog(0.2)
    	self:Emoji(longnv, koubi)
    	AudioEngine.stopAllEffects()
		
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
        	AudioEngine.stopAllEffects()
			self:WaitToDialog(0.2)

			self:Emoji(bajie, jingkong)
			bajie:setRotationSkewY(180)

	
		elseif hua == self.message[2].msg then
			AudioEngine.stopAllEffects()	
			self:Emoji(longnv, heixian)
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			AudioEngine.stopAllEffects()		

			self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
