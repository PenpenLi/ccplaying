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

    local qiche2 = self:CreateProp(SCREEN_WIDTH*0.5, 200, "dummy/qiche2")


	local guzhang = self:CreateEmoji("dummy/guzhang.png")

	local tushe = self:CreateEmoji("dummy/tushe.png")

	local haixiu = self:CreateEmoji("dummy/haixiu.png")

	local han = self:CreateEmoji("dummy/han.png")

	local biti = self:CreateEmoji("dummy/biti.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


	local icon_wukong = self:CreateIcon(1018, wukong_skins)

	local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wujing = self:CreateIcon(1028, wujing_skins)


    self.message = {
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "突然有点饿了，你们继续追，我去打包一份宵夜回来。"},
		{icon = icon_wukong, dir = 2, speak = "孙悟空", msg = "湿父等等我！"},
		{icon = icon_wujing, dir = 2, speak = "沙悟净", msg = "湿父我也陪你去！"},
    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wukong:setVisible(true)
		bajie:setVisible(true)
		wujing:setVisible(true)
		longnv:setVisible(true)
		qiche2:setVisible(true)


		tangseng:setAnimation(0, "move", true)
		wukong:setAnimation(0, "move", true)
		bajie:setAnimation(0, "move", true)
		wujing:setAnimation(0, "move", true)
		longnv:setAnimation(0, "move", true)
		qiche2:setAnimation(0, "move", true)

		--self:WaitToDialog(0.2)

		AudioEngine.stopAllEffects()

		local event = cc.CallFunc:create(function ()
			Common.playSound("audio/effect/Story_shache.mp3")
		end)

		local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+250, 200))

		local event1 = cc.CallFunc:create(function ()
			AudioEngine.stopAllEffects()
		end)		

		qiche2:runAction(cc.Sequence:create(event, go, event1))

		local delay = cc.DelayTime:create(1)

		local go_b = cc.MoveBy:create(2, cc.p(600, 0))

		local go_l = cc.MoveBy:create(2, cc.p(600, 0))

		local go_j = cc.MoveBy:create(2, cc.p(600, 0))

		local go_k = cc.MoveBy:create(2, cc.p(600, 0))

		local go_t = cc.MoveBy:create(2, cc.p(600, 0))		

		local event_k = cc.CallFunc:create(function ()
			wukong:setAnimation(0, "idle", true)
			wujing:setAnimation(0, "idle", true)
			bajie:setAnimation(0, "idle", true)
			tangseng:setAnimation(0, "idle", true)
			longnv:setAnimation(0, "idle", true)

			self:Emoji(tangseng, haixiu)
			self:WaitToDialog(0.2)

			Common.playSound("audio/hero/t_06.mp3")
		end)

		bajie:runAction(go_b)
		longnv:runAction(go_l)
		wujing:runAction(go_j)
		wukong:runAction(go_k)
		tangseng:runAction(cc.Sequence:create(go_t, event_k))

    end)



    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
        	AudioEngine.stopAllEffects()
			--self:WaitToDialog(0.2)

			tangseng:setRotationSkewY(180)
			wukong:setRotationSkewY(180)
			wujing:setRotationSkewY(180)
			bajie:setRotationSkewY(180)
			longnv:setRotationSkewY(180)

			tangseng:setAnimation(0, "move", true)

			local go_t = cc.MoveBy:create(1, cc.p(-300, 0))

			local event_t = cc.CallFunc:create(function ()
				Common.playSound("audio/hero/s_07.mp3")
				self:Emoji(wukong, guzhang)
				self:WaitToDialog(0.2)
			end)

			tangseng:runAction(cc.Sequence:create(go_t, event_t))

	
		elseif hua == self.message[2].msg then
			AudioEngine.stopAllEffects()

			wukong:setAnimation(0, "move", true)

			local go_k = cc.MoveBy:create(1, cc.p(-300, 0))

			local event_k = cc.CallFunc:create(function ()
				Common.playSound("audio/hero/sha.mp3")
				self:Emoji(wujing, tushe)
				self:WaitToDialog(0.2)
			end)

			wukong:runAction(cc.Sequence:create(go_k, event_k))		


		elseif hua == self.message[3].msg then
			AudioEngine.stopAllEffects()

			self:Emoji(longnv, han)
			self:Emoji(bajie, biti)

			wujing:setAnimation(0, "move", true)

			local go_j = cc.MoveBy:create(1.3, cc.p(-400, 0))

			local event_j = cc.CallFunc:create(function ()
				self:StoryEnd()
			end)

			wujing:runAction(cc.Sequence:create(go_j, event_j))							
			
			-- self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
