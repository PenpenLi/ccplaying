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
    local tianwang = self:CreatePerson(SCREEN_WIDTH-280, 200, 1031, ta_skins)
	--tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(SCREEN_WIDTH-450, 200, GameCache.Avatar.Figure)

	local dao_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local daotong = self:CreatePerson(200, 200, 1056, dao_skins)

	local daku = self:CreateEmoji("dummy/daku.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_daotong = self:CreateIcon(1056, dao_skins)


    self.message = {
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "哪咤，爹爹来接你啦！"},
		{icon = icon_daotong, dir = 1, speak = "老道童", msg = "5555，千万别说是我说漏嘴的呀，会被罚的…"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "这位老道友，请问…"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		daotong:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		daotong:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

		local go = cc.MoveTo:create(2.5, cc.p(SCREEN_WIDTH+350,200))

		local go1 = cc.MoveTo:create(2.5, cc.p(SCREEN_WIDTH+200,200))

		local delay = cc.DelayTime:create(1)

		local event = cc.CallFunc:create(function()
			self:Emoji(daotong, daku)
			self:WaitToDialog(0.2)
		end)

		local delay1 = cc.DelayTime:create(2.5)

		local event1 =  cc.CallFunc:create(function()
			self:StoryEnd()
		end)

		tianwang:runAction(go)
		wanjia:runAction(go1)
		self:runAction(cc.Sequence:create({delay, event, delay1, event1}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then


		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[3].msg then
			--elf:WaitToDialog(0.5)
			--self:Emoji(tianwang, fennu)

		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
