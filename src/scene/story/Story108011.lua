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

	local se = self:CreateEmoji("dummy/se.png")

	local tushe = self:CreateEmoji("dummy/tushe.png")

	local ganga = self:CreateEmoji("dummy/ganga.png")

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



    self.message = {
        {icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "哟，两位可爱的美眉，你们平时都有些什么爱好呀？"},
		{icon = icon_shejing, dir = 2, speak = "蛇精妹妹", msg = "帅锅锅别急嘛，先点几个小菜咱们边吃边聊嘛！"},
		{icon = icon_huyao, dir = 2, speak = "狐妖姐姐", msg = "妹妹你别那么吃货好不好，一会儿把猴先生吓跑了的！"},
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "吃货好，吃货可爱呀！我们家二胖子也是个吃货，呵呵，呵呵呵…"},
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

		self:Emoji(sunwukong, se)
		self:WaitToDialog(0.2)


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shejing, tushe)


        elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(huyao, qiaoda)


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, ganga)
			self:Emoji(shejing, guzhang)


		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
