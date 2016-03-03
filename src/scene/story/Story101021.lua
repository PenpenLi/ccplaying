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
	local wujing = self:CreatePerson(SCREEN_WIDTH*0.5-250, 300, 1028, wujing_skins)

	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1071,
	}
    local tangseng = self:CreatePerson(SCREEN_WIDTH*0.5-350, 200, 1026, tangseng_skins)

	local bajie_skins = {
		["Arm"] = 1006,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local bajie = self:CreatePerson(SCREEN_WIDTH*0.5-150, 200, 1027, bajie_skins)

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
	local wukong = self:CreatePerson(SCREEN_WIDTH*0.5-250, 100, 1018, wukong_skins)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1069,
	}
	local longnv = self:CreatePerson(SCREEN_WIDTH*0.5+200, 200, 1040, longnv_skins)
	longnv:setRotationSkewY(180)

	
	local daku = self:CreateEmoji("dummy/daku.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local yun = self:CreateEmoji("dummy/yun.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wukong = self:CreateIcon(1018, wukong_skins)

	local icon_bajie = self:CreateIcon(1027, bajie_skins)

	local icon_wujing = self:CreateIcon(1028, wujing_skins)

	local icon_longnv = self:CreateIcon(1040, longnv_skins)


    self.message = {
		{icon = icon_bajie, dir = 1, speak = "猪八戒", msg = "老板娘，失恋了能打折么？"},
		{icon = icon_longnv, dir = 2, speak = "老板娘", msg = "能呀！看姐把你的猪蹄子给打折咯！"},
    }


    self:AddInitEndEvent(function (  )

		tangseng:setVisible(true)
		wukong:setVisible(true)
		bajie:setVisible(true)
		wujing:setVisible(true)
		longnv:setVisible(true)

		tangseng:setAnimation(0, "idle", true)
		wukong:setAnimation(0, "idle", true)
		bajie:setAnimation(0, "idle", true)
		wujing:setAnimation(0, "idle", true)
		longnv:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

		AudioEngine.stopAllEffects()
		Common.playMusic("audio/music/BGM_Bar.mp3", true)

		self:Emoji(bajie, daku)

		Common.playSound("audio/hero/z_04.mp3")

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
        	AudioEngine.stopAllEffects()
			self:WaitToDialog(0.2)

			Common.playSound("audio/hero/long_02.mp3")

			longnv:setAnimation(1, "atk2", false)
			longnv:setAnimation(0, "idle", true)
			self:Emoji(longnv, fennu)

			local delay = cc.DelayTime:create(1)

			local event = cc.CallFunc:create(function (  )
				tangseng:setAnimation(1, "hit", false)
				tangseng:setAnimation(0, "idle", true)

				wukong:setAnimation(1, "hit", false)
				wukong:setAnimation(0, "idle", true)

				wujing:setAnimation(1, "hit", false)
				wujing:setAnimation(0, "idle", true)

				bajie:setAnimation(1, "hit", false)
				bajie:setAnimation(0, "idle", true)

				self:Emoji(tangseng, yun)
				self:Emoji(wukong, jingdai)
				self:Emoji(wujing, qiaoda)
				self:Emoji(bajie, jingkong)
			end)

			self:runAction(cc.Sequence:create(delay, event))


		elseif hua == self.message[2].msg then

            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
