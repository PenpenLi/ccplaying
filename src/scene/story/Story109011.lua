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
    local tianwang = self:CreatePerson(SCREEN_WIDTH+200, 200, 1031, ta_skins)
	tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(450, 200, GameCache.Avatar.Figure)

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local daku = self:CreateEmoji("dummy/daku.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = GameCache.Avatar.Name .. "，你一定得帮帮我啊！我儿子不见啦！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "李天王请放心，您儿子就是我儿子…"},
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = "你说什么，哪吒是你儿子！！！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "不，我意思是…哎呀，有些细节是可以忽略的，我们还是先去你家看看现场吧。"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "idle", true)

		local go = cc.MoveTo:create(2.2, cc.p(SCREEN_WIDTH-400,200))
		local event = cc.CallFunc:create(function()
			tianwang:setAnimation(0, "idle", true)
			self:Emoji(tianwang, daku)
			self:WaitToDialog(0.2)
		end)

		tianwang:runAction(cc.Sequence:create({go,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, jingkong)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
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
