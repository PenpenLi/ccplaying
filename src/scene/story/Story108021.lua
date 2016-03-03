--
-- Author: Kamirotto
-- Date: 2015-04-24 15:18:47
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
		["Hat"] = 1090,
		["Coat"] = 1068,
	}
    local sunwukong = self:CreatePerson(350, 200, 1018, wukong_skins)

    --local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local she_skins = {
		["Arm"] = 1025,
		["Hat"] = 1089,
		["Coat"] = 0,
	}
    local shejing = self:CreatePerson(SCREEN_WIDTH-180, 300, 1044, she_skins)
    shejing:setRotationSkewY(180)

	local hu_skins = {
		["Arm"] = 1041,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
    local huyao = self:CreatePerson(SCREEN_WIDTH-220, 150, 1036, hu_skins)
    huyao:setRotationSkewY(180)

    local dipi = self:CreateMonster(SCREEN_WIDTH+200, 200, "gw_dipi2")

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local tushe = self:CreateEmoji("dummy/tushe.png")

	local deyi = self:CreateEmoji("dummy/deyi.png")

	local guzhang = self:CreateEmoji("dummy/guzhang.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	--local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_shejing = self:CreateIcon(1044, she_skins)

    local icon_huyao = self:CreateIcon(1036, hu_skins)

    local icon_dipi = self:CreateMonsterIcon("gw_dipi2")



    self.message = {
		{icon = icon_huyao, dir = 1, speak = "狐妖姐姐", msg = "妹妹走，陪我去洗手间补个妆。"},
		{icon = icon_shejing, dir = 2, speak = "蛇精妹妹", msg = "好的姐姐~"},
		{icon = icon_dipi, dir = 2, speak = "服务员", msg = "先森你好，这是你们的账单，一共消费八千八，不打折也没发票。"},
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "我擦，一盘西红柿炒番茄你就要收我八千八！不带这样坑爸爸的呀！"},
		-- {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "丑八怪，哪里跑！"}


    }


    self:AddInitEndEvent(function (  )

    	sunwukong:setVisible(true)
    	--wanjia:setVisible(true)
		shejing:setVisible(true)
		huyao:setVisible(true)

    	sunwukong:setAnimation(0, "idle", true)
    	--wanjia:setAnimation(0, "idle", true)
		shejing:setAnimation(0, "idle", true)
		huyao:setAnimation(0, "idle", true)


		local delay = cc.DelayTime:create(0.5)

		local event = cc.CallFunc:create(function ()
			huyao:setRotationSkewY(0)
			self:Emoji(huyao, tushe)
			self:WaitToDialog(0.2)
		end)

		huyao:runAction(cc.Sequence:create(delay, event))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


        elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			shejing:setRotationSkewY(0)

			shejing:setAnimation(0,"move", true)
			huyao:setAnimation(0,"move", true)

			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+180,150))
			local go1 = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+220,300))

			local event = cc.CallFunc:create(function ()
				dipi:setVisible(true)
				dipi:setAnimation(0, "move", true)
				dipi:setRotationSkewY(180)
			end)

			local delay = cc.DelayTime:create(0.5)

			local go2 = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-220, 200))

			local event1 = cc.CallFunc:create(function()
				dipi:setAnimation(0, "idle", true)
				self:Emoji(dipi, deyi)
			end)

			huyao:runAction(go)
			shejing:runAction(go1)
			dipi:runAction(cc.Sequence:create(event, delay, go2, event1))


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, fennu)

			sunwukong:setAnimation(1, "atk3", false)
			sunwukong:setAnimation(0, "idle", 0)


		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
