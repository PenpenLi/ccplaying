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


	local lei_skins = {
		["Arm"] = 1010,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local leizhenzi = self:CreatePerson(-200, 200, 1048, lei_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	--local qianliyan = self:CreatePerson(SCREEN_WIDTH-350, 200, 1053)
	--qianliyan:setRotationSkewY(180)

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_leizhenzi,dir = 1, speak = "雷震子", msg = "沙漠之中怎么会有泥鳅…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "话说完飞过一只海鸥…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "为毛我会跟着一起唱呀！！！"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)

		leizhenzi:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

        --self:Emoji(leizhenzi, daku)
		self:WaitToDialog(0.5)

        local go = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+200,200))
		local go1 = cc.MoveTo:create(2.5, cc.p(400,200))

		local event = cc.CallFunc:create(function()
			wanjia:setAnimation(0, "idle", true)
            --leizhenzi:setAnimation(1, "atk_ko", false)
            --leizhenzi:setAnimation(0, "idle", true)
			self:WaitToDialog(0.5)

			wanjia:setAnimation(0, "idle", true)
			

		end)

		local delay = cc.DelayTime:create(2)
		local event2 = cc.CallFunc:create(function() 
			self:Emoji(wanjia, qiaoda)
			self:WaitToDialog(0.2)
		end)

		leizhenzi:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event,delay, event2}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			-- self:WaitToDialog(0.0)


		elseif hua == self.message[2].msg then


		elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
