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

	local fa_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local fahai = self:CreatePerson(SCREEN_WIDTH-200, 200, 1045, fa_skins)
	fahai:setRotationSkewY(180)

	local bai_skins = {
		["Arm"] = 1000,
		["Hat"] = 1082,
		["Coat"] = 1056,
	}
	local baisuzhen = self:CreatePerson(SCREEN_WIDTH-400, 200, 1020, bai_skins)

	local qinqin = self:CreateEmoji("dummy/qinqin.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_fahai = self:CreateIcon(1045, fa_skins)

	local icon_baisuzhen = self:CreateIcon(1020, bai_skins)


    self.message = {
		{icon = icon_baisuzhen,dir = 1, speak = "白娘子", msg = "法老呀，你这壶龙井的茶叶还行，只可惜这水用的不是清早从荷叶上采摘下来的露水，口感次了些。"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你们究竟有何居心？"},
		{icon = icon_fahai,dir = 2, speak = "法海", msg = "小白你还是那么懂（gao）生（bi）活（ge）呀…"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "法海，还我老婆！"},
		{icon = icon_baisuzhen,dir = 2, speak = "白娘子", msg = "老公，快过来喝茶！"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "老婆大人小心，法海那秃驴对你有非分之想！"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = GameCache.Avatar.Name .. "，快帮我揍飞这个花和尚！"},
    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)
		fahai:setVisible(true)
		baisuzhen:setVisible(true)

		xuxian:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		fahai:setAnimation(0, "idle", true)
		baisuzhen:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.2)

			local go = cc.MoveTo:create(2, cc.p(400,200))
		    local go1 = cc.MoveTo:create(2, cc.p(200,200))
			local event = cc.CallFunc:create(function()
				xuxian:setAnimation(1, "atk1", false)
				xuxian:setAnimation(0, "idle", true)
				wanjia:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)
			xuxian:runAction(go)
			wanjia:runAction(cc.Sequence:create({go1,event}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			baisuzhen:setRotationSkewY(180)
			self:Emoji(baisuzhen, qinqin)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
			self:Emoji(xuxian, fennu)
			xuxian:setAnimation(1, "atk_ko", false)
			xuxian:setAnimation(0, "idle", true)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
