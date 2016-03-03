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
	local taiyi = self:CreatePerson(SCREEN_WIDTH-180, 200, 1034, taiyi_skins)
	taiyi:setRotationSkewY(180)

	local nezha_skins = {
		["Arm"] = 1009,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local nezha = self:CreatePerson(SCREEN_WIDTH-380, 200, 1039, nezha_skins)
	nezha:setRotationSkewY(180)

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local han1 = self:CreateEmoji("dummy/han.png")

	local han2 = self:CreateEmoji("dummy/han.png")

	local kelian = self:CreateEmoji("dummy/kelian.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_taiyi = self:CreateIcon(1034, taiyi_skins)

	local icon_nezha = self:CreateIcon(1039, nezha_skins)


    self.message = {
		{icon = icon_nezha, dir = 2, speak = "哪吒", msg = "父王，你可还记得天朝电视台前些日子邀请你去参加《天朝好爸爸》的节目录制么？你答应了要带我去的！"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "当然记得，我当时不是赶巧有公务没办法脱身么！"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "好了三儿，不闹了，咱回家好不好？我答应回家就给你买炮娘和安妮的限量皮肤赔罪可以不？"},
		{icon = icon_nezha, dir = 2, speak = "哪吒", msg = "再加个EZ的我就考虑考虑！"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "行，你说了算。"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "走，快回家吧，你妈还在家里炖了汤呢…"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		taiyi:setVisible(true)
		nezha:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		taiyi:setAnimation(0, "idle", true)
		nezha:setAnimation(0, "idle", true)

		self:Emoji(nezha, kelian)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			tianwang:setAnimation(0, "move", true)

			local go = cc.MoveBy:create(0.8, cc.p(200,0))

			local event = cc.CallFunc:create(function()
				tianwang:setAnimation(0, "idle", true)
				--wanjia:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.2)
				--self:StoryEnd
			end)

			--tianwang:runAction(go)
			tianwang:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(nezha, koubi)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)

			nezha:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(1, cc.p(680,200))

			local event = cc.CallFunc:create(function()
				nezha:setAnimation(0, "idle", true)
			end)

			nezha:runAction(cc.Sequence:create({go, event}))


		elseif hua == self.message[5].msg then

			local go = cc.MoveTo:create(2.5, cc.p(-200,200))

			local delay = cc.DelayTime:create(0.2)

			local event = cc.CallFunc:create(function()
				tianwang:setRotationSkewY(180)
				tianwang:setAnimation(0, "move", true)
				self:WaitToDialog(0.2)
			end)

			local go1= cc.MoveTo:create(2.3, cc.p(-200,200))

			local delay1 = cc.DelayTime:create(1)

			local event1 = cc.CallFunc:create(function()
				self:Emoji(wanjia, han1)
				self:Emoji(taiyi, han2)
			end)

			local delay2 = cc.DelayTime:create(1.2)

			local event2 = cc.CallFunc:create(function()
				self:StoryEnd()
			end)

			nezha:runAction(go)
			tianwang:runAction(cc.Sequence:create({delay, event, go1, delay1, event1, delay2, event2}))


		elseif hua == self.message[6].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
