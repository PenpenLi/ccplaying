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
    local tianwang = self:CreatePerson(-230, 200, 1031, ta_skins)
	--tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	local han = self:CreateEmoji("dummy/han.png")

	local yiwen = self:CreateEmoji("dummy/yiwen.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "金光洞应该就在附近了，仔细找找！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你怎么知道的？"},
		{icon = icon_tianwang, dir = 2, speak = "托塔天王", msg = "我闻到我儿子特有的脚臭味儿了，那种肉被烧焦后又混着汗水的味道…快走！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "…"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(3, cc.p(550,200))
		local go1 = cc.MoveTo:create(2.5, cc.p(300,200))

		local event = cc.CallFunc:create(function()
			wanjia:setAnimation(0, "idle", true)
		end)

		local event1 = cc.CallFunc:create(function()
			tianwang:setAnimation(0, "idle", true)
			tianwang:setRotationSkewY(180)
			self:WaitToDialog(0.2)
		end)

		tianwang:runAction(cc.Sequence:create({go, event1}))
		wanjia:runAction(cc.Sequence:create({go1, event}))

		--self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, yiwen)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			tianwang:setRotationSkewY(0)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, han)
			tianwang:setAnimation(0, "move", true)
			local go2 = cc.MoveTo:create(2.5, cc.p(SCREEN_WIDTH+200,200))
			local event = cc.CallFunc:create(function()
				self:StoryEnd()
			end)
			tianwang:runAction(cc.Sequence:create({go2,event}))

		elseif hua == self.message[4].msg then
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
