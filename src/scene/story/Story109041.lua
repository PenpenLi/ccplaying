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


	local ta_skins = {
		["Arm"] = 1037,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local tianwang = self:CreatePerson(400, 200, 1031, ta_skins)

    local wanjia = self:CreatePerson(SCREEN_WIDTH-350, 200, GameCache.Avatar.Figure)
	wanjia:setRotationSkewY(180)

	local cahan = self:CreateEmoji("dummy/cahan.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "这里怎么会有鱼人？"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "太岳山脚下有片泽地，犬子常去嬉戏，不知是否与此事有所联系？"},
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "天王咱能说点儿通俗易懂的话不？"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		--local go = cc.MoveTo:create(3, cc.p(400,200))
		--local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-350,200))
		--local event = cc.CallFunc:create(function()
			--tianwang:setAnimation(0, "idle", true)
			--wanjia:setAnimation(0, "idle", true)
			--
		--end)

		--tianwang:runAction(go)
		--wanjia:runAction(cc.Sequence:create({go1,event}))
		self:WaitToDialog(0.2)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, cahan)

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
