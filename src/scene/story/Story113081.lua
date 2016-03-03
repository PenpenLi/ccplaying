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

    local fennu = self:CreateEmoji("dummy/fennu.png")



    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_shoujingjing = self:CreateIcon(1035, bai_skins)



    self.message = {
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精", msg = "我的减肥药，时尚时尚最时尚~"},
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精", msg = "你们是来买药的吧！"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "买药？！你卖的假药可把俺整惨了，俺老猪今天是来讨公道的！"},
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精",msg = "滚犊子！我的药可都是纯天然的…"},
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精",msg = "小伙伴们，快来把这群逗比都给我轰走！"},
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
				self:WaitToDialog(0.2)
            end)

            shoujingjing:runAction(cc.Sequence:create({go,event}))

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


        elseif hua == self.message[2].msg then
            self:Emoji(zhubajie, fennu)
            self:WaitToDialog(0.2)


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


        elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			shoujingjing:setAnimation(1, "atk_ko", false)
			shoujingjing:setAnimation(0, "idle", true)


        elseif hua == self.message[5].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
