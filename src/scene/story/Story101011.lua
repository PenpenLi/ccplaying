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
	local wujing = self:CreatePerson(-400, 200, 1028, wujing_skins)

	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1071,
	}
    local tangseng = self:CreatePerson(-520, 200, 1026, tangseng_skins)

	local bajie_skins = {
		["Arm"] = 2000,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local bajie = self:CreatePerson(SCREEN_WIDTH*0.5-170, 200, 1027, bajie_skins)

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
	local wukong = self:CreatePerson(-150, 200, 1018, wukong_skins)

	local cahnge_skins = {
		["Arm"] = 1000,
		["Hat"] = 1082,
		["Coat"] = 1061,
	}
	local change = self:CreatePerson(SCREEN_WIDTH*0.5+180, 200, 1033, cahnge_skins)
	change:setRotationSkewY(180)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1069,
	}
	local longnv = self:CreatePerson(-200, 200, 1040, longnv_skins)	

	
	local haixiu = self:CreateEmoji("dummy/haixiu.png")

	local guzhang1 = self:CreateEmoji("dummy/guzhang.png")

	local guzhang2 = self:CreateEmoji("dummy/guzhang.png")

	local guzhang3 = self:CreateEmoji("dummy/guzhang.png")

	local bishi = self:CreateEmoji("dummy/bishi.png")

	local kelian = self:CreateEmoji("dummy/kelian.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wukong = self:CreateIcon(1018, wukong_skins)

	local icon_bajie = self:CreateIcon(1027, bajie_skins)

	local icon_wujing = self:CreateIcon(1028, wujing_skins)

	local icon_change = self:CreateIcon(1033, cahnge_skins)

	local icon_longnv = self:CreateIcon(1040, longnv_skins)


    self.message = {
		{icon = icon_bajie, dir = 1, speak = "猪八戒", msg = "娥娥女神，做俺老猪的女朋友吧！"},
		{icon = icon_change, dir = 2, speak = "嫦娥", msg = "猪哥，我们真的不合适呐！（内心独白：我可不想跟一大坨肥肉滚床单啊…）"},
		{icon = icon_wukong, dir = 2, speak = "孙悟空", msg = "嘿嘿，呆子，恭喜你第九千九百九十九次表白失败！！！"},
		{icon = icon_change, dir = 2, speak = "嫦娥", msg = "我要回家洗澡了，掰掰！"},
		{icon = icon_bajie, dir = 1, speak = "猪八戒", msg = "亲，别走啊！！！"},
		{icon = icon_longnv, dir = 1, speak = "老板娘", msg = "嘿，那个猪脑袋你别跑，还没给钱呐！来人，保安，保安…"},
    }


    self:AddInitEndEvent(function (  )

		tangseng:setVisible(true)
		wukong:setVisible(true)
		bajie:setVisible(true)
		wujing:setVisible(true)
		change:setVisible(true)
		longnv:setVisible(true)

		tangseng:setAnimation(0, "move", true)
		wukong:setAnimation(0, "move", true)
		bajie:setAnimation(0, "idle", true)
		wujing:setAnimation(0, "move", true)
		change:setAnimation(0, "idle", true)
		longnv:setAnimation(0, "move", true)

		self:WaitToDialog(0.2)

		AudioEngine.stopAllEffects()
		Common.playSound("audio/hero/z_01.mp3")
		Common.playMusic("audio/music/BGM_Bar.mp3", true)

		self:Emoji(bajie, haixiu)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
        	AudioEngine.stopAllEffects()
			self:WaitToDialog(0.2)
			Common.playSound("audio/hero/c_01.mp3")


		elseif hua == self.message[2].msg then
			AudioEngine.stopAllEffects()

			Common.playSound("audio/hero/s_01.mp3")

			local go = cc.MoveTo:create(1.5, cc.p(180,200))
			local go1 = cc.MoveTo:create(1.5, cc.p(550,100))
			local go2 = cc.MoveTo:create(1.5, cc.p(300,300))

			local event = cc.CallFunc:create(function()
				tangseng:setAnimation(0, "idle", true)
				wukong:setAnimation(0, "idle", true)
				wujing:setAnimation(0, "idle", true)

				wukong:setRotationSkewY(180)

				self:Emoji(tangseng, guzhang1)
				self:Emoji(wukong, guzhang2)
				self:Emoji(wujing, guzhang3)

				self:WaitToDialog(0.2)
			end)

			tangseng:runAction(go)
			wukong:runAction(go1)
			wujing:runAction(cc.Sequence:create({go2,event}))


		elseif hua == self.message[3].msg then
			AudioEngine.stopAllEffects()
			self:WaitToDialog(0.2)
			self:Emoji(change, bishi)
			Common.playSound("audio/hero/c_02.mp3")


		elseif hua == self.message[4].msg then
			AudioEngine.stopAllEffects()
			change:setRotationSkewY(0)
			change:setAnimation(0, "move", true)

			local go3 = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))

			local event1 = cc.CallFunc:create(function()
				change:setVisible(false)
			end)

			local delay = cc.DelayTime:create(0.5)

			local event4 = cc.CallFunc:create(function()
				self:Emoji(bajie, jingdai)
				self:WaitToDialog(0.2)
				Common.playSound("audio/hero/z_03.mp3")
			end)

			local event2 = cc.CallFunc:create(function()
				bajie:setAnimation(0, "move", true)
			end)
			
			local delay1 = cc.DelayTime:create(0.5)

			local go4 = cc.MoveTo:create(2.6, cc.p(SCREEN_WIDTH+200,200))

			local event3 = cc.CallFunc:create(function()
				wukong:setRotationSkewY(0)
				bajie:setVisible(false)
			end)

			change:runAction(cc.Sequence:create({go3,event1}))
			bajie:runAction(cc.Sequence:create({delay, event4, delay1, event2, go4 , event3}))


		elseif hua == self.message[5].msg then
			AudioEngine.stopAllEffects()
			self:WaitToDialog(0.2)

			wukong:setAnimation(0, "move", true)
			tangseng:setAnimation(0, "move", true)
			wujing:setAnimation(0, "move", true)

			Common.playSound("audio/hero/long_01.mp3")

			local go1 = cc.MoveTo:create(2.7, cc.p(SCREEN_WIDTH+200,100))
			local go2 = cc.MoveTo:create(2.8, cc.p(SCREEN_WIDTH+200,200))
			local go3 = cc.MoveTo:create(2.7, cc.p(SCREEN_WIDTH+200,300))

			local delay = cc.DelayTime:create(1)

			local go4 = cc.MoveTo:create(1.8, cc.p(300,200))

			local event = cc.CallFunc:create(function()
				longnv:setAnimation(1, "atk_ko", false)
				longnv:setAnimation(0, "idle", true)
			end)

			local delay1 = cc.DelayTime:create(4)

			local event1 = cc.CallFunc:create(function()
				self:StoryEnd()
			end)			

			wukong:runAction(go1)
			tangseng:runAction(go2)
			wujing:runAction(go3)
			longnv:runAction(cc.Sequence:create(delay, go4, event, delay1, event1))


		elseif hua == self.message[6].msg then
			AudioEngine.stopAllEffects()

            -- self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
