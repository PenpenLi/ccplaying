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
	local wujing = self:CreatePerson(-300, 300, 1028, wujing_skins)

	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1071,
	}
    local tangseng = self:CreatePerson(-400, 300, 1026, tangseng_skins)

	local bajie_skins = {
		["Arm"] = 1006,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local bajie = self:CreatePerson(-200, 200, 1027, bajie_skins)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1069,
	}
	local longnv = self:CreatePerson(-300, 100, 1040, longnv_skins)

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
	local wukong = self:CreatePerson(-400, 100, 1018, wukong_skins)

	local cahnge_skins = {
		["Arm"] = 1000,
		["Hat"] = 1082,
		["Coat"] = 1061,
	}
	local change = self:CreatePerson(0, 340, 1033, cahnge_skins)

	local gaofushuai_skins = {
		["Arm"] = 1000,
		["Hat"] = 0,
		["Coat"] = 0,
	}

    local qiche = self:CreateProp(SCREEN_WIDTH+300, 100, "dummy/qiche1")
	qiche:setRotationSkewY(180)

    local qiche2 = self:CreateProp(SCREEN_WIDTH-285, 100, "dummy/qiche2")
	qiche2:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local daku = self:CreateEmoji("dummy/daku.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")

	local kelian = self:CreateEmoji("dummy/kelian.png")

	local heixian = self:CreateEmoji("dummy/heixian.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


	local icon_bajie = self:CreateIcon(1027, bajie_skins)

	local icon_gaofushuai = self:CreateIcon(1019, gaofushuai_skins)


    self.message = {
		{icon = icon_gaofushuai, dir = 2, speak = "一个高富帅", msg = "嫦娥酱，I'm here~上车！"},
		{icon = icon_bajie, dir = 1, speak = "猪八戒", msg = "亲，让我先做个备胎试试吧…"},
    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wukong:setVisible(true)
		bajie:setVisible(true)
		wujing:setVisible(true)
		longnv:setVisible(true)
		change:setVisible(true)


		tangseng:setAnimation(0, "move", true)
		wukong:setAnimation(0, "move", true)
		bajie:setAnimation(0, "move", true)
		wujing:setAnimation(0, "move", true)
		change:setAnimation(0, "move", true)
		longnv:setAnimation(0, "move", true)
		qiche:setAnimation(0, "move", true)

		--self:WaitToDialog(0.2)

		AudioEngine.stopAllEffects()

		local go = cc.MoveTo:create(2, cc.p(460,250))

		local event = cc.CallFunc:create(function ()
			change:setRotationSkewY(180)
		end)

		local delay = cc.DelayTime:create(1)

		local event2 = cc.CallFunc:create(function ()
			change:setRotationSkewY(0)
			change:setAnimation(0, "idle", true)
		end)

		qiche:setVisible(true)
		qiche:setAnimation(0, "move", true)

		local delay1 = cc.DelayTime:create(1)

		local event3 = cc.CallFunc:create(function ()
			Common.playSound("audio/effect/Story_shache.mp3")
		end)

		local delay2 = cc.DelayTime:create(1.3)

		local go1 = cc.MoveTo:create(0.5, cc.p(SCREEN_WIDTH-300,100))

		local go2 = cc.MoveBy:create(0.2, cc.p(15,0))

		local delay3 = cc.DelayTime:create(0.5)

		local event4 = cc.CallFunc:create(function ()
			qiche:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
			Common.playSound("audio/hero/e2_01.mp3")
		end)

		change:runAction(cc.Sequence:create(go, event, delay, event2))
		qiche:runAction(cc.Sequence:create(delay1, event3, delay2, go1, go2, delay3, event4))
    end)



    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
        	AudioEngine.stopAllEffects()
			--self:WaitToDialog(0.2)

			change:setAnimation(0, "move", true)
			local go_c = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-300, 100))

			local event_c = cc.CallFunc:create(function ()
				change:setVisible(false)
				qiche:setVisible(false)
				qiche2:setVisible(true)

				self:WaitToDialog(0.2)
				Common.playSound("audio/hero/z_02.mp3")
			end) 

			change:runAction(cc.Sequence:create(go_c, event_c))

			local delay = cc.DelayTime:create(1.5)

			local go_b = cc.MoveBy:create(2, cc.p(600, 0))

			local go_l = cc.MoveBy:create(2, cc.p(600, 0))

			local go_j = cc.MoveBy:create(2, cc.p(600, 0))

			local go_k = cc.MoveBy:create(2, cc.p(600, 0))

			local go_t = cc.MoveBy:create(2, cc.p(600, 0))

			local event_k = cc.CallFunc:create(function ()
				--wukong:setAnimation(1, "atk1", false)
				wukong:setAnimation(0, "idle", true)
				wujing:setAnimation(0, "idle", true)
				bajie:setAnimation(0, "idle", true)
				tangseng:setAnimation(0, "idle", true)
				longnv:setAnimation(0, "idle", true)

				self:Emoji(bajie, kelian)
				self:Emoji(wukong, fennu)
				self:Emoji(longnv, jingdai)
				self:Emoji(tangseng, koubi)
				self:Emoji(wujing, qiaoda)
				self:Emoji(qiche2, heixian)
			end)

			bajie:runAction(cc.Sequence:create(delay, go_b))
			longnv:runAction(cc.Sequence:create(delay, go_l))
			wujing:runAction(cc.Sequence:create(delay, go_j))		
			tangseng:runAction(cc.Sequence:create(delay, go_t))
			wukong:runAction(cc.Sequence:create(delay, go_k, event_k))	

	
		elseif hua == self.message[2].msg then
			AudioEngine.stopAllEffects()

			qiche2:setAnimation(0, "move", true)

			Common.playSound("audio/effect/Story_shache.mp3")

			local go = cc.MoveBy:create(0.5, cc.p(-20, 100))

			local event = cc.CallFunc:create(function ()
				qiche2:setRotationSkewY(0)
			end)

			local go2 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH+200, 200))

			-- local delay = cc.DelayTime:create(1)

			local event2 = cc.CallFunc:create(function ()
				self:StoryEnd()
			end)

			qiche2:runAction(cc.Sequence:create(go, event, go2, delay, event2))
			
            
        end
    end)


	self:StoryBegin()

end


return Story
