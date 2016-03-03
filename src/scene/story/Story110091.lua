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
    local tianwang = self:CreatePerson(650, 200, 1031, ta_skins)
	tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(400, 200, GameCache.Avatar.Figure)


	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "没想到这金光洞中居然另有乾坤呀！"},
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "我才懒得管他是乾还是坤，是公的还是母的呢！"},
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "GO！GO！！GO！！！"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "…"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		self:Emoji(wanjia, jingdai)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			tianwang:setRotationSkewY(0)
			tianwang:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))

			local event = cc.CallFunc:create(function()
				--tianwang:setAnimation(0, "idle", true)
				--tianwang:setRotationSkewY(180)
				--wanjia:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.2)
				self:StoryEnd()
			end)

			--tianwang:runAction(go)
			tianwang:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)


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
