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
    local xuxian = self:CreatePerson(-180, 200, 1043, xu_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local bao_skins = {
		["Arm"] = 1008,
		["Hat"] = 1096,
		["Coat"] = 1068,
	}
	local baogongtou = self:CreatePerson(SCREEN_WIDTH-400, 200, 1049, bao_skins)
	--baogongtou:setRotationSkewY(180)

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local cahan = self:CreateEmoji("dummy/cahan.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	--local icon_baogongtou = self:CreateIcon(1049)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "这包工头是狗变得么，跑得这么快！"},
		{icon = icon_xuxian,dir = 2, speak = "许仙", msg = "建国以后，不是就不允许动物修炼成精了么？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "吐得一口好槽…"},
    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)
		baogongtou:setVisible(true)

		xuxian:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		baogongtou:setAnimation(0, "move", true)
		--self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(2.5, cc.p(550,200))
		local go1 = cc.MoveTo:create(2.5, cc.p(350,200))
		local go2 = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))
        local event = cc.CallFunc:create(function()
            xuxian:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
        end)
        xuxian:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))
		baogongtou:runAction(go2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			xuxian:setRotationSkewY(180)
			self:Emoji(xuxian, yiwen)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, cahan)

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			--local event =cc.CallFunc:create(function()
				--xiaoyaoguai:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.5)
			--end)
			--xiaoyaoguai:runAction(cc.Sequence:create({go,event}))


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
