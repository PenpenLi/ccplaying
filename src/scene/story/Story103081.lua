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


    local tangseng_skins = {
        ["Arm"] = 1042,
        ["Hat"] = 1092,
        ["Coat"] = 1067,
    }
    local tangseng = self:CreatePerson(-200, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)



    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\




    --local icon_tangseng = self:CreateIcon(1026)


	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)




    self.message = {
        --{icon = icon_tangseng, dir = tangseng, speak = "唐僧", msg = "走，上天庭救儿子！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "我要飞得更高~飞得更高~~"}


    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wanjia:setVisible(true)

		tangseng:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+350,200))
		local go1 = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+200,200))
        local event = cc.CallFunc:create(function()
            self:StoryEnd()
        end)
        tangseng:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
--            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
