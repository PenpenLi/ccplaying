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
	local wujing = self:CreatePerson(280, 300, 1028, wujing_skins)

	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1071,
	}
    local tangseng = self:CreatePerson(150, 300, 1026, tangseng_skins)

	local bajie_skins = {
		["Arm"] = 1006,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local bajie = self:CreatePerson(450, 200, 1027, bajie_skins)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1069,
	}
	local longnv = self:CreatePerson(350, 100, 1040, longnv_skins)

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
	local wukong = self:CreatePerson(200, 100, 1018, wukong_skins)


	local heixian = self:CreateEmoji("dummy/heixian.png")
	local jingdai = self:CreateEmoji("dummy/jingdai.png")
	local jingkong = self:CreateEmoji("dummy/jingkong.png")
	local yun = self:CreateEmoji("dummy/yun.png")
	local biti = self:CreateEmoji("dummy/biti.png")
	local zhuakuang = self:CreateEmoji("dummy/zhuakuang.png")
	local yiwen = self:CreateEmoji("dummy/yiwen.png")	


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


	local icon_wukong = self:CreateIcon(1018, wukong_skins)

	local icon_tangseng = self:CreateIcon(1026, tangseng_skins)


    self.message = {
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "空空，咱们这是被撸到哪儿来啦？"},
		{icon = icon_wukong, dir = 2, speak = "孙悟空", msg = "俺咋知道，分头找出路吧！"},
    }


    self:AddInitEndEvent(function (  )

		local scene = cc.Director:getInstance():getRunningScene()
		scene:runAction(cc.Shake:create(1, 10))

		local delay = cc.DelayTime:create(0.5)

		-- 播放特效，然后消失
		local event_texiao = cc.CallFunc:create(function()
			self:CreateEffect(tangseng:getPositionX(), tangseng:getPositionY(), 8)
			self:CreateEffect(wukong:getPositionX(), wukong:getPositionY(), 8)
			self:CreateEffect(bajie:getPositionX(), bajie:getPositionY(), 8)
			self:CreateEffect(wujing:getPositionX(), wujing:getPositionY(), 8)
		end)

		local delay1 = cc.DelayTime:create(0.3)

		local event_chuxian = cc.CallFunc:create(function()
			tangseng:setVisible(true)
			wukong:setVisible(true)
			bajie:setVisible(true)
			wujing:setVisible(true)
			longnv:setVisible(true)

			AudioEngine.stopAllEffects()
			--Common.playSound("audio/hero/t_02.mp3")
			--self:WaitToDialog(0.2)

			self:Emoji(wukong, heixian)
			self:Emoji(bajie, jingkong)
			self:Emoji(tangseng, jingdai)
			self:Emoji(wujing, biti)
			self:Emoji(longnv, yun)
		end)

		local delay2 = cc.DelayTime:create(1.5)

		local event = cc.CallFunc:create(function ()
			self:Emoji(tangseng, yiwen)
			self:WaitToDialog(0.2)
		end)

		self:runAction(cc.Sequence:create(delay, event_texiao, delay1, event_chuxian, delay2, event))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
        	AudioEngine.stopAllEffects()
			self:WaitToDialog(0.2)

			self:Emoji(wukong, zhuakuang)
			wukong:setRotationSkewY(180)
			wujing:setRotationSkewY(180)
			bajie:setRotationSkewY(180)
			longnv:setRotationSkewY(180)

	
		elseif hua == self.message[2].msg then
			AudioEngine.stopAllEffects()	

			self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
