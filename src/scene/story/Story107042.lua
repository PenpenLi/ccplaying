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

	local long_skins = {
		["Arm"] = 1015,
		["Hat"] = 0,
		["Coat"] = 1068,
	}
	local baogongtou = self:CreatePerson(SCREEN_WIDTH-260, 200, 1032, long_skins)
	baogongtou:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local kelian = self:CreateEmoji("dummy/kelian.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_baogongtou = self:CreateIcon(1032, long_skins)


    self.message = {
		{icon = icon_baogongtou,dir = 2, speak = "包工头", msg = "大爷们我错啦，我也是被逼的呀！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "什么情况，从实招来！"},
		{icon = icon_baogongtou,dir = 2, speak = "包工头", msg = "其实我是在建国前修炼成精的…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "不是问你这个！！！"},
		{icon = icon_baogongtou,dir = 2, speak = "包工头", msg = "其实我是受了雷峰装饰公司的指示，要跟你们两夫妇制造点“小麻烦”的。"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "走，找法海算账去！"},

    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)
		baogongtou:setVisible(true)

		xuxian:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		baogongtou:setAnimation(0, "idle", true)

        --local go = cc.MoveTo:create(2, cc.p(350,200))
		--local go1 = cc.MoveTo:create(2, cc.p(200,200))
        --local event = cc.CallFunc:create(function()
            --xuxian:setAnimation(0, "idle", true)
			--wanjia:setAnimation(0, "idle", true)
			--
        --end)
        --xuxian:runAction(go)
        --wanjia:runAction(cc.Sequence:create({go1,event}))

		self:Emoji(baogongtou, kelian)

		self:WaitToDialog(0.2)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			wanjia:setAnimation(1, "atk1", false)
			wanjia:setAnimation(0, "idle", true)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, fennu)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
			self:Emoji(xuxian, fennu)
			xuxian:setAnimation(1, "atk3", false)
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
