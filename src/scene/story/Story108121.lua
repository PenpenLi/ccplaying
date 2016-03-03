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
		["Hat"] = 1090,
		["Coat"] = 1068,
	}
    local sunwukong = self:CreatePerson(-180, 200, 1018, wukong_skins)

	local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local wanyaohuang_skins = {
		["Arm"] = 1002,
		["Hat"] = 1093,
		["Coat"] = 1066,
	}
	local wanyaohuang = self:CreatePerson(SCREEN_WIDTH-250, 200, 1008, wanyaohuang_skins)
    wanyaohuang:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local deyi = self:CreateEmoji("dummy/deyi.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\




	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanyaohuang = self:CreateIcon(1008, wanyaohuang_skins)




    self.message = {
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "如果策划脑子没烧坏的话，你就是那俩妖精的“皇阿玛”吧！"},
		{icon = icon_wanyaohuang, dir = 2, speak = "万妖皇", msg = "是的，告诉我，你的梦想是什么…？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "世界和平！"},
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "妈蛋，严肃点！！！"},
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "这么说来，这饭托组织的负责人就是你人妖王咯？"},
		{icon = icon_wanyaohuang, dir = 2, speak = "万妖皇", msg = "第一，我是万妖皇，喝屋昂~皇…"},
		{icon = icon_wanyaohuang, dir = 2, speak = "万妖皇", msg = "第二，我们妖恋网可是专业的相亲O2O互联网科技公司。"},
		{icon = icon_wanyaohuang, dir = 2, speak = "万妖皇", msg = "第三，please叫我梦想导湿~"},
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "老子最讨厌的就废话多的人了！吃俺棒子！！!"},


    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)
		wanyaohuang:setVisible(true)

		wanyaohuang:setAnimation(0, "idle", true)
		sunwukong:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		--self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(2, cc.p(380,200))
		local go1 = cc.MoveTo:create(2, cc.p(180,200))

			local event = cc.CallFunc:create(function()
					sunwukong:setAnimation(0, "idle", true)
					wanjia:setAnimation(0, "idle", true)
					self:WaitToDialog(0.2)
			end)

        sunwukong:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			sunwukong:setRotationSkewY(180)
			self:Emoji(sunwukong, fennu)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			sunwukong:setRotationSkewY(0)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[6].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[7].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanyaohuang, deyi)


		elseif hua == self.message[8].msg then
			self:WaitToDialog(0.2)
			sunwukong:setAnimation(1, "atk3", false)
			sunwukong:setAnimation(0, "idle", true)


		elseif hua == self.message[9].msg then
            self:StoryEnd()
        end

        end)

self:StoryBegin()

end



return Story
