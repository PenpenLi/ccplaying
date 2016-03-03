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
    local tianwang = self:CreatePerson(-180, 200, 1031, ta_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local long_skins = {
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 1055,
	}
	local longwang = self:CreatePerson(SCREEN_WIDTH-280, 200, 1032, long_skins)
	longwang:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local jingkong = self:CreateEmoji("dummy/jingkong.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_longwang = self:CreateIcon(1032, long_skins)


    self.message = {
		{icon = icon_longwang,dir = 2, speak = "东海龙王", msg = GameCache.Avatar.Name .. "，怎么又是你！"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "敖广，还我儿子！"},
		{icon = icon_longwang,dir = 2, speak = "东海龙王", msg = GameCache.Avatar.Name .. "，还我宝贝！"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "不要转移话题！"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你的反射弧会不会太长了点呀…想想你儿子跟谁有仇嘛！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		longwang:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		longwang:setAnimation(0, "idle", true)

		--self:WaitToDialog(0.1)

		local go = cc.MoveTo:create(2, cc.p(380,200))
		local go1 = cc.MoveTo:create(2, cc.p(180,200))
		local event = cc.CallFunc:create(function()
			tianwang:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:Emoji(longwang, jingkong)
			self:WaitToDialog(0.2)
		end)

		tianwang:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			tianwang:setAnimation(1, "atk1", false)
			tianwang:setAnimation(0, "idle", true)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			longwang:setAnimation(1, "atk1", false)
			longwang:setAnimation(0, "idle", true)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, fennu)
			tianwang:setAnimation(1, "atk3", false)
			tianwang:setAnimation(0, "idle", true)

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
