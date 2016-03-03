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


	local ta_skins = {
		["Arm"] = 1037,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local tianwang = self:CreatePerson(380, 200, 1031, ta_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local taiyi_skins = {
		["Arm"] = 1019,
		["Hat"] = 0,
		["Coat"] = 1065,
	}
	local taiyi = self:CreatePerson(SCREEN_WIDTH+200, 200, 1034, taiyi_skins)
	taiyi:setRotationSkewY(180)

	local nezha_skins = {
		["Arm"] = 1009,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local nezha = self:CreatePerson(SCREEN_WIDTH+200, 200, 1039, nezha_skins)
	nezha:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_taiyi = self:CreateIcon(1034, taiyi_skins)

	local icon_nezha = self:CreateIcon(1039, nezha_skins)


    self.message = {
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "天王，这里究竟是哪里？"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "太2，快把我儿子交出来！"},
		{icon = icon_taiyi, dir = 2, speak = "太乙真人", msg = "太乙（yi）真人， 不是太2真人…"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "随便啦，快把我的儿子交出来！"},
		{icon = icon_nezha, dir = 2, speak = "哪吒", msg = "你不是我爸，你是小狗，我不跟小狗回去！"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "逆子，休得胡闹！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		taiyi:setVisible(true)
		nezha:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		taiyi:setAnimation(0, "move", true)
		nezha:setAnimation(0, "move", true)

		self:Emoji(tianwang, fennu)

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)

			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-180,200))

			local event = cc.CallFunc:create(function()
				taiyi:setAnimation(0, "idle", true)
				--wanjia:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
				--self:StoryEnd
			end)

			--tianwang:runAction(go)
			taiyi:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.5)

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

			local go1 = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-380,200))

			local event = cc.CallFunc:create(function()
				nezha:setAnimation(0, "idle", true)
				--wanjia:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
				--self:StoryEnd
			end)

			--tianwang:runAction(go)
			nezha:runAction(cc.Sequence:create({go1,event}))

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			local event = cc.CallFunc:create(function()
				tianwang:setAnimation(1, "atk1", false)
				tianwang:setAnimation(0, "idle", true)
			end)
			local delay = cc.DelayTime:create(2)
			local event1 = cc.CallFunc:create(function()
				self:StoryEnd()
			end)

			nezha:runAction(cc.Sequence:create(event, delay, event1))


		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then

        end
    end)


	self:StoryBegin()

end


return Story
