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
    local sunwukong = self:CreatePerson(380, 200, 1018, wukong_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

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

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

    local icon_shejing = self:CreateIcon(1044, she_skins)

    local icon_huyao = self:CreateIcon(1036, hu_skins)



    self.message = {
        {icon = icon_huyao, dir = 2, speak = "狐妖姐姐",msg = "哟，小猴子还跟着呀！"},
		{icon = icon_shejing, dir = 2, speak = "蛇精妹妹",msg = "姐姐，我讨厌这只猴子，把它扔进动物园吧！"},
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空",msg = "呔！区区小妖精，竟敢羞辱你斗战胜佛孙爷爷，这就让你们试试俺的大棒子！"},
        {icon = icon_huyao, dir = 2, speak = "狐妖姐姐",msg = "试试就试试！"},
    }


    self:AddInitEndEvent(function (  )

    	sunwukong:setVisible(true)
    	wanjia:setVisible(true)
		shejing:setVisible(true)
		huyao:setVisible(true)

    	sunwukong:setAnimation(0, "idle", true)
    	wanjia:setAnimation(0, "idle", true)
		shejing:setAnimation(0, "idle", true)
		huyao:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shejing, qiaoda)

        elseif hua == self.message[2].msg then
			self:Emoji(sunwukong, fennu)
			sunwukong:setAnimation(1, "atk3", false)
			sunwukong:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)

			huyao:setAnimation(1, "atk_ko", false)
			huyao:setAnimation(0, "idle", true)


        elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
