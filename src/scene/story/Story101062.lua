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
	local wujing = self:CreatePerson(-370, 300, 1028, wujing_skins)

	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1071,
	}
    local tangseng = self:CreatePerson(-500, 200, 1026, tangseng_skins)  

	local bajie_skins = {
		["Arm"] = 1006,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local bajie = self:CreatePerson(-210, 200, 1027, bajie_skins)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1069,
	}
	local longnv = self:CreatePerson(-300, 150, 1040, longnv_skins)  	

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
	local wukong = self:CreatePerson(-450, 100, 1018, wukong_skins)

	local er_skins = {
		["Arm"] = 1000,
		["Hat"] = 0,
		["Coat"] = 0,
	}

	local qiche2 = self:CreateProp(-300, 200, "dummy/qiche2")

	local fennu = self:CreateEmoji("dummy/fennu.png")
	local jingkong = self:CreateEmoji("dummy/jingkong.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wukong = self:CreateIcon(1018, wukong_skins)

	local icon_bajie = self:CreateIcon(1027, bajie_skins)

	local icon_wujing = self:CreateIcon(1028, wujing_skins)

	local icon_er = self:CreateIcon(1019, er_skins)


    self.message = {
		{icon = icon_wukong, dir = 1, speak = "孙悟空", msg = "总算追到了！呔，敢跟八戒抢女人，兄弟们扁他！"},
		{icon = icon_er, dir = 2, speak = "一个高富帅", msg = "哎哟，哎哟，别打脸呀！疼！！疼！！！"},
    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wukong:setVisible(true)
		bajie:setVisible(true)
		wujing:setVisible(true)
		longnv:setVisible(true)

		qiche2:setVisible(true)
		qiche2:setAnimation(0, "move", true)

		tangseng:setAnimation(0, "move", true)
		wukong:setAnimation(0, "move", true)
		bajie:setAnimation(0, "move", true)
		wujing:setAnimation(0, "move", true)
		longnv:setAnimation(0, "move", true)

		local event_che = cc.CallFunc:create(function (  )
			Common.playSound("audio/effect/Story_shache.mp3")
		end)

		local delay1 = cc.DelayTime:create(1.2)
		local go_che = cc.MoveTo:create(0.4, cc.p(500, 200))
		local go_che1 = cc.MoveTo:create(0.2, cc.p(700, 100))
		local go_che2 = cc.MoveTo:create(0.1, cc.p(800, 100))
		local go_che3 = cc.MoveBy:create(0.1, cc.p(-15, 0))	

		local delay2 = cc.DelayTime:create(0.5)
		local event_che1 = cc.CallFunc:create(function (  )
			qiche2:setAnimation(0, "idle", true)
			--self:WaitToDialog(0.2)
			--Common.playSound("audio/hero/e2_01.mp3")
		end)
		
        qiche2:runAction(cc.Sequence:create(event_che, delay1, go_che, go_che1, go_che2, go_che3, delay2, event_che1))

		local delay3 = cc.DelayTime:create(1.8)
		
		local go_k = cc.MoveTo:create(2.2, cc.p(200, 100))
		local go_j = cc.MoveTo:create(2.2, cc.p(280, 300))
		local go_t = cc.MoveTo:create(2.2, cc.p(150, 200))
		local go_l = cc.MoveTo:create(2.2, cc.p(350, 150))
		local go_z = cc.MoveTo:create(2, cc.p(450, 200))

		local event = cc.CallFunc:create(function ()
			self:WaitToDialog(0.2)
			AudioEngine.stopAllEffects()
			Common.playSound("audio/hero/s_02.mp3")	

			self:Emoji(wukong, fennu)
			self:Emoji(qiche2, jingkong)

			tangseng:setAnimation(0, "idle", true)
			wukong:setAnimation(1, "atk1", false)
			wukong:setAnimation(0, "idle", true)
			wujing:setAnimation(0, "idle", true)
			bajie:setAnimation(0, "idle", true)
			longnv:setAnimation(0, "idle", true)
		end)
	
		wujing:runAction(cc.Sequence:create(delay3, go_j))
		tangseng:runAction(cc.Sequence:create(delay3, go_t))
		longnv:runAction(cc.Sequence:create(delay3, go_l))
		bajie:runAction(cc.Sequence:create(delay3, go_z))
		wukong:runAction(cc.Sequence:create(delay3, go_k, event))
    end)


    local function shakeScreen(  )
    	local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0))
    	self:addChild(layerColor)

		AudioEngine.stopAllEffects()
		Common.playSound("audio/effect/StoryFighting1.mp3")

		local event = cc.CallFunc:create(function (  )
			self:WaitToDialog(0.2)
			AudioEngine.stopAllEffects()
			Common.playSound("audio/hero/e2_02.mp3")
        	local scene = cc.Director:getInstance():getRunningScene()
        	scene:runAction(cc.Shake:create(0.5, 10))
		end)

    	layerColor:runAction(cc.Sequence:create( cc.FadeIn:create(0.5), event))--, delay, event2 ))
    end


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			AudioEngine.stopAllEffects()
			shakeScreen()


		elseif hua == self.message[2].msg then
			AudioEngine.stopAllEffects()
			self:StoryEnd()

        end
    end)


	self:StoryBegin()

end


return Story
