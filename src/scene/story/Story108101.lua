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
    local sunwukong = self:CreatePerson(440, 200, 1018, wukong_skins)

	local wanjia = self:CreatePerson(240, 200, GameCache.Avatar.Figure)

	local fennu = self:CreateEmoji("dummy/fennu.png")

    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\




	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_sunwukong = self:CreateIcon(1018, wukong_skins)




    self.message = {
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "看上去前面又有一个洞呀…"},
		{icon = icon_sunwukong, dir = 2, speak = "孙悟空", msg = "妈蛋，这一季的洞怎么那么多，Shi策划是被狗日了吗？！"},


    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)

		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		self:WaitToDialog(0.2)

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, fennu)


		elseif hua == self.message[2].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
