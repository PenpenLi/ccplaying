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


	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1077,
		["Coat"] = 1053,
	}
    local sunwukong = self:CreatePerson(380, 200, 1018, wukong_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local long_skins = {
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 1055,
	}
	local longwang = self:CreatePerson(SCREEN_WIDTH+250, 200, 1032, long_skins)
	longwang:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local jianxiao = self:CreateEmoji("dummy/jianxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_longwang = self:CreateIcon(1032, long_skins)


    self.message = {
		{icon = icon_longwang,dir = 2, speak = "东海龙王", msg = "该死的金毛猴头，我东海龙宫岂是你任意放肆之地！"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "猴哥，你的人气真高呀！"},
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "嘿嘿，龙王，今天来是想向你借样宝贝…"},
		{icon = icon_longwang,dir = 2, speak = "东海龙王", msg = "借你妹啊！把我的棒子还我先！"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)
		longwang:setVisible(true)

		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		longwang:setAnimation(0, "move", true)

        local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-300,200))

		local event = cc.CallFunc:create(function()
			self:Emoji(longwang, fennu)
            longwang:setAnimation(1, "atk1", false)
            longwang:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		--longwang:runAction(go)
        longwang:runAction(cc.Sequence:create({go,event}))
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, jianxiao)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.1)
			longwang:setAnimation(1, "atk_ko", false)
			longwang:setAnimation(0, "idle", true)

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
