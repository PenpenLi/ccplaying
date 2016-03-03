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
    local tangseng = self:CreatePerson(150, 200, 1026, tangseng_skins)  

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
	local longnv = self:CreatePerson(350, 150, 1040, longnv_skins)  	

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
	local wukong = self:CreatePerson(200, 100, 1018, wukong_skins)

	local cahnge_skins = {
		["Arm"] = 1022,
		["Hat"] = 1082,
		["Coat"] = 1061,
	}
	local change = self:CreatePerson(SCREEN_WIDTH+250, 200, 1033, cahnge_skins)
	change:setRotationSkewY(180)

	local er_skins = {
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local er = self:CreatePerson(SCREEN_WIDTH-220, 200, 1019, er_skins)
	er:setRotationSkewY(180)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wukong = self:CreateIcon(1018, wukong_skins)

	local icon_bajie = self:CreateIcon(1027, bajie_skins)

	local icon_wujing = self:CreateIcon(1028, wujing_skins)

	local icon_change = self:CreateIcon(1033, cahnge_skins)

	local icon_er = self:CreateIcon(1019, er_skins)


    self.message = {
		{icon = icon_wukong, dir = 1, speak = "孙悟空", msg = "小杨，怎么是你？"},
		{icon = icon_change, dir = 2, speak = "嫦娥", msg = "哼，这么多人打我们家尖尖一个，你们还是不是人呐！是不是人呐！！是不是人呐！！！"},
		--{icon = icon_er, dir = 1, speak = "二郎神", msg = "娥酱，人家好受伤的说哦…"},
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "贫僧可没动手的呀，我们刚刚买宵夜去了…"},
		{icon = icon_change, dir = 2, speak = "嫦娥", msg = "跟姐玩儿吐槽是吧！好，你们打了姐的闺蜜还吐槽，那就别怪姐我召唤大杀器了！！！"},
    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wukong:setVisible(true)
		bajie:setVisible(true)
		wujing:setVisible(true)
		change:setVisible(true)
		er:setVisible(true)
		longnv:setVisible(true)

		tangseng:setAnimation(0, "idle", true)
		wukong:setAnimation(0, "idle", true)
		bajie:setAnimation(0, "idle", true)
		wujing:setAnimation(0, "idle", true)
		change:setAnimation(0, "move", true)
		er:setAnimation(0, "idle", true)
		longnv:setAnimation(0, "idle", true)


		self:WaitToDialog(0.2)
		self:Emoji(wukong, jingdai)
		AudioEngine.stopAllEffects()
		Common.playSound("audio/hero/s_03.mp3")	

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)
			AudioEngine.stopAllEffects()
			Common.playSound("audio/hero/c_03.mp3")
			self:WaitToDialog(0.2)

			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-350,200))

			local event = cc.CallFunc:create(function()
				change:setAnimation(1, "atk1", false)
				change:addAnimation(1, "atk1", false)
				change:addAnimation(1, "atk1", false)
				change:setAnimation(0, "idle", true)
			end)

			change:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tangseng, koubi)
			AudioEngine.stopAllEffects()
			Common.playSound("audio/hero/t_01.mp3")

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			change:setAnimation(0, "atk_ko", true)
			AudioEngine.stopAllEffects()
			Common.playSound("audio/hero/c_04.mp3")


		elseif hua == self.message[4].msg then

			local scene = cc.Director:getInstance():getRunningScene()
        	scene:runAction(cc.Shake:create(1, 10))

        	local delay = cc.DelayTime:create(0.5)

        	-- 播放特效，然后消失
        	local event_texiao = cc.CallFunc:create(function()
        		self:CreateEffect(tangseng:getPositionX(), tangseng:getPositionY(), 9)
        		self:CreateEffect(wukong:getPositionX(), wukong:getPositionY(), 9)
        		self:CreateEffect(bajie:getPositionX(), bajie:getPositionY(), 9)
        		self:CreateEffect(wujing:getPositionX(), wujing:getPositionY(), 9)
        		self:CreateEffect(longnv:getPositionX(), longnv:getPositionY(), 9)
			end)

        	local delay1 = cc.DelayTime:create(0.3)

        	local event_xiaoshi = cc.CallFunc:create(function()
				tangseng:setVisible(false)
				wukong:setVisible(false)
				bajie:setVisible(false)
				wujing:setVisible(false)
				longnv:setVisible(false)
        	end)

        	local event = cc.CallFunc:create(function() self:StoryEnd()  end)

            self:runAction(cc.Sequence:create(delay,event_texiao, delay1, event_xiaoshi,event))
        end
    end)


	self:StoryBegin()

end


return Story
