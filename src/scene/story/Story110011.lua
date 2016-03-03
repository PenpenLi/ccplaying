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
    local tianwang = self:CreatePerson(SCREEN_WIDTH-350, 200, 1031, ta_skins)
	tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(300, 200, GameCache.Avatar.Figure)

	--local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = GameCache.Avatar.Name .. "，我们在龙宫找不到哪吒，那现在该怎么办呢？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "哪吒会不会是到他师父那去玩儿了呀，要不打个电话问问？"},
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = "手机欠费了，我们还是飞过去吧！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "这…"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.5)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.5)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.5)
			--self:Emoji(tianwang, fennu)
			tianwang:setRotationSkewY(0)
			tianwang:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(2.5, cc.p(SCREEN_WIDTH+350,200))

			local event = cc.CallFunc:create(function()
				--tianwang:setAnimation(0, "idle", true)
				--wanjia:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.2)
				self:StoryEnd()
			end)

			--tianwang:runAction(go)
			tianwang:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
