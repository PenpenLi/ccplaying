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


	local niu_skins = {
		["Arm"] = 1008,
		["Hat"] = 1079,
		["Coat"] = 1054,
	}
    local niumowang = self:CreatePerson(400, 200, 1016, niu_skins)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local tieshan_skins = {
		["Arm"] = 1024,
		["Hat"] = 1084,
		["Coat"] = 1062,
	}
	local tieshangongzhu = self:CreatePerson(SCREEN_WIDTH+200, 200, 1042, tieshan_skins)
	tieshangongzhu:setRotationSkewY(180)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local daku = self:CreateEmoji("dummy/daku.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local biti = self:CreateEmoji("dummy/biti.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_niumowang = self:CreateIcon(1016, niu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_tieshangongzhu = self:CreateIcon(1042, tieshan_skins)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "不好，嫂子来了！"},
		{icon = icon_tieshangongzhu, dir = 2, speak = "铁扇公主", msg = "死牛，你在干什么！"},
		{icon = icon_niumowang, dir = 1, speak = "牛魔王", msg = "夫…夫人，没…我在和好兄弟们唠嗑呢。"},
		{icon = icon_tieshangongzhu, dir = 2, speak = "铁扇公主", msg = "屁！是你把网线弄断了吧，是不是还想偷银行卡去改密码呀！死牛你今天晚上就在搓衣板上睡吧！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "嫂子、牛老大，那什么，我还有点事，就先走啦，空了打麻将呀！"},
		{icon = icon_niumowang,dir = 1, speak = "牛魔王", msg = "别…夫人我错了，夫人您听我说…夫人，别…啊！！！"},

    }


    self:AddInitEndEvent(function (  )
		niumowang:setVisible(true)
		wanjia:setVisible(true)
		tieshangongzhu:setVisible(true)


		niumowang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		tieshangongzhu:setAnimation(0, "move", true)
        self:Emoji(niumowang, jingkong)
        self:Emoji(wanjia, jingdai)
		self:WaitToDialog(0.2)

        --local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-350,200))
        local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))

		local event = cc.CallFunc:create(function()
            tieshangongzhu:setAnimation(0, "idle", true)

            tieshangongzhu:setAnimation(1, "atk_ko", false)
            tieshangongzhu:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		--niumowang:runAction(go)
        tieshangongzhu:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then

			--local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-200,200))
			--local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-200,200))
			--local event = cc.CallFunc:create(function()
				--self:StoryEnd()
			--end)

			--niumowang:runAction(go)
			--wanjia:runAction(cc.Sequence:create({go1,event}))


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
            tieshangongzhu:setAnimation(1, "atk3", false)
            tieshangongzhu:setAnimation(0, "idle", true)
			self:Emoji(tieshangongzhu, fennu)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, biti)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)

			wanjia:setRotationSkewY(180)
			wanjia:setAnimation(0, "move", true)

			local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			wanjia:runAction(go1)

			self:Emoji(niumowang, daku)


		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
