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


	local xu_skins = {
		["Arm"] = 1043,
		["Hat"] = 1090,
		["Coat"] = 1071,
	}
    local xuxian = self:CreatePerson(-150, 200, 1043, xu_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)
	--baogongtou:setRotationSkewY(180)

	local yiwen = self:CreateEmoji("dummy/yiwen.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "Dr.许，咱们这是要去哪呀？"},
		{icon = icon_xuxian,dir = 2, speak = "许仙", msg = "法海的老巢！"},

    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)

		xuxian:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

        local go = cc.MoveTo:create(2.5, cc.p(550,200))
		local go1 = cc.MoveTo:create(2.5, cc.p(350,200))
        local event = cc.CallFunc:create(function()
            xuxian:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:Emoji(wanjia, yiwen)
			self:WaitToDialog(0.2)
        end)
        xuxian:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			xuxian:setRotationSkewY(180)

		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)
			--self:Emoji(wanjia, fennu)

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
