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


    local bajie_skins = {
        ["Arm"] = 1006,
        ["Hat"] = 1093,
        ["Coat"] = 0,
    }
    local zhubajie = self:CreatePerson(380, 200, 1027, bajie_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

    local bai_skins = {
        ["Arm"] = 0,
        ["Hat"] = 1082,
        ["Coat"] = 1064,
    }
    local shoujingjing = self:CreatePerson(SCREEN_WIDTH, 200, 1035, bai_skins)
    shoujingjing:setRotationSkewY(180)

    local haixiu = self:CreateEmoji("dummy/haixiu.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_shoujingjing = self:CreateIcon(1035, bai_skins)


    self.message = {
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精", msg = "呀，我是不是该认真地考虑一下你对我的感情了呢？"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "滚！！！老子只爱嫦娥女神一个人！"},


    }


    self:AddInitEndEvent(function (  )

    	zhubajie:setVisible(true)
    	wanjia:setVisible(true)
		shoujingjing:setVisible(true)


		zhubajie:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		shoujingjing:setAnimation(0,"move", true)
            local go = cc.MoveBy:create(1, cc.p(-250,0))

            local event = cc.CallFunc:create(function()
                shoujingjing:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.5)
				self:Emoji(shoujingjing, haixiu)
				self:WaitToDialog(1.0)

            end)

            shoujingjing:runAction(cc.Sequence:create({go,event}))

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
            self:Emoji(zhubajie, qiaoda)
            self:WaitToDialog(0.2)

        elseif hua == self.message[2].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
