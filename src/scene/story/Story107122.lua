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
    local xuxian = self:CreatePerson(400, 200, 1043, xu_skins)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local fa_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local fahai = self:CreatePerson(SCREEN_WIDTH-260, 200, 1045, fa_skins)
	fahai:setRotationSkewY(180)

	local bai_skins = {
		["Arm"] = 1000,
		["Hat"] = 1082,
		["Coat"] = 1056,
	}
	local baisuzhen = self:CreatePerson(500, 200, 1020, bai_skins)
	baisuzhen:setRotationSkewY(180)

	local daku = self:CreateEmoji("dummy/daku.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local qinqin = self:CreateEmoji("dummy/qinqin.png")

	local guzhang = self:CreateEmoji("dummy/guzhang.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_fahai = self:CreateIcon(1045, fa_skins)

	local icon_baisuzhen = self:CreateIcon(1020, bai_skins)


    self.message = {
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "小贞贞呐，我听说宜屋的家具正在打折，我们去逛逛吧。"},
		{icon = icon_baisuzhen,dir = 1, speak = "白娘子", msg = "好呀，我正好想给家里换一张大一点的床…"},
		{icon = icon_fahai,dir = 2, speak = "法海", msg = "许汉文你个大笨蛋！"},
		{icon = icon_fahai,dir = 2, speak = "法海", msg = "我为你做了这么多事情，你何时才能理解我对的你心…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "突然信息量好大，让我一个人静静…"},
    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)
		fahai:setVisible(true)
		baisuzhen:setVisible(true)

		xuxian:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		fahai:setAnimation(0, "idle", true)
		baisuzhen:setAnimation(0, "idle", true)

		self:Emoji(xuxian, qinqin)

		self:WaitToDialog(0.2)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			xuxian:setRotationSkewY(180)
			self:WaitToDialog(0.2)
			self:Emoji(baisuzhen, guzhang)
			xuxian:setAnimation(0, "move", true)
			baisuzhen:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(3, cc.p(-200,200))
		    local go1 = cc.MoveTo:create(3, cc.p(-300,200))

			xuxian:runAction(go)
			baisuzhen:runAction(go1)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(fahai, daku)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[4].msg then
			fahai:setAnimation(0, "move", true)
			fahai:setRotationSkewY(0)
			local go2 = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+ 200,200))
			fahai:runAction(go2)
				self:Emoji(wanjia, jingdai)
				self:WaitToDialog(0.2)
		elseif hua == self.message[5].msg then
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
