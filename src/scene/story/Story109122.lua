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
	tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local long_skins = {
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 1055,
	}
	local longwang = self:CreatePerson(SCREEN_WIDTH-280, 200, 1032, long_skins)
	longwang:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_longwang = self:CreateIcon(1032, long_skins)


    self.message = {
		{icon = icon_tianwang,dir = 2, speak = "托塔天王", msg = "怎么办，哪吒好像也不在这里。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "天王莫急，要不我们先回去再从长计议？"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "嗯，有道理，快走！"},
		{icon = icon_longwang,dir = 2, speak = "东海龙王", msg = "别走…医药费赔我…咳咳！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		longwang:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		longwang:setAnimation(1, "hit", false)
		longwang:addAnimation(1, "hit", false)
		longwang:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			wanjia:setRotationSkewY(180)

			tianwang:setAnimation(0, "move", true)
			wanjia:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(2, cc.p(-200,200))
			local go1 = cc.MoveTo:create(2, cc.p(-350,200))

			local delay = cc.DelayTime:create(1.0)

			local event = cc.CallFunc:create(function()
				self:Emoji(longwang, fennu)
				longwang:setAnimation(0, "move", true)
			end)

			local go2 = cc.MoveBy:create(0.5, cc.p(-50,0))

			local event1 = cc.CallFunc:create(function()
				longwang:setAnimation(1, "hit", false)
				longwang:addAnimation(1, "hit", false)
				longwang:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)

			tianwang:runAction(go)
			wanjia:runAction(go1)
			longwang:runAction(cc.Sequence:create({delay, event, go2, event1}))

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
