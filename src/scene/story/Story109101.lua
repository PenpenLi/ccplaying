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
    local tianwang = self:CreatePerson(-200, 200, 1031, ta_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)
	--wanjia:setRotationSkewY(180)

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = "为什么我们要到龙宫来？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你的反射弧会不会太长了点呀…想想你儿子跟谁有仇嘛！"},
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = "你说得好有道理，我竟然无言以对！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		--self:WaitToDialog(0.1)
		local go = cc.MoveTo:create(3, cc.p(650,200))
		local event = cc.CallFunc:create(function()
			tianwang:setRotationSkewY(180)
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, yiwen)
			tianwang:setAnimation(0, "idle", true)
		end)
		tianwang:runAction(cc.Sequence:create({go,event}))

		local go1 = cc.MoveTo:create(3.5, cc.p(420,200))
		local event1 = cc.CallFunc:create(function()
			wanjia:setAnimation(0, "idle", true)

		end)


		wanjia:runAction(cc.Sequence:create({go1,event1}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, jingdai)

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
