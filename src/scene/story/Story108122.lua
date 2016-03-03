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
    local sunwukong = self:CreatePerson(380, 200, 1018, wukong_skins)

	local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local wanyaohuang_skins = {
		["Arm"] = 1002,
		["Hat"] = 1093,
		["Coat"] = 1066,
	}
	local wanyaohuang = self:CreatePerson(SCREEN_WIDTH-250, 200, 1008, wanyaohuang_skins)
    wanyaohuang:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local daku = self:CreateEmoji("dummy/daku.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\




	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanyaohuang = self:CreateIcon(1008, wanyaohuang_skins)




    self.message = {
		{icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "呔，叫你骗相亲人的钱！"},
		{icon = icon_wanyaohuang, dir = 2, speak = "万妖皇", msg = "这不能怪我呀，谁叫互联网时代，diao丝的钱最好挣呢！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "说谁diao丝呢！！"},
		{icon = icon_wanyaohuang, dir = 2, speak = "万妖皇", msg = "英雄饶命，求别打脸呀…"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)
		wanyaohuang:setVisible(true)

		wanyaohuang:setAnimation(0, "idle", true)
		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, fennu)
			wanjia:setAnimation(1, "atk3", false)
			wanjia:setAnimation(0, "idle", true)


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanyaohuang, daku)


		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
