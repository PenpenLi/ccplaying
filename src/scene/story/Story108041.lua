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
    local sunwukong = self:CreatePerson(-200, 200, 1018, wukong_skins)

	local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)



    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\




	local icon_sunwukong = self:CreateIcon(1018, wukong_skins)




    self.message = {
        {icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "快追，别让那两个丑八怪给跑了！"},


    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)

		sunwukong:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+350,200))
		local go1 = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+200,200))

        sunwukong:runAction(go)
		wanjia:runAction(go1)


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then


            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
