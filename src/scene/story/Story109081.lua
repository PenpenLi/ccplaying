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
    local tianwang = self:CreatePerson(-150, 200, 1031, ta_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)
	--wanjia:setRotationSkewY(180)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1067,
	}
	local longnv = self:CreatePerson(SCREEN_WIDTH-260, 200, 1040, longnv_skins)

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_longnv = self:CreateIcon(1040, longnv_skins)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "姑姑，是你吗？ "},
		{icon = icon_longnv,dir = 2, speak = "龙女", msg = "是你妹呀！这世上傻x怎么这么多呀，刚赶走一个这儿又来了一双！"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "死妖女，还我儿子来！"},
		{icon = icon_longnv,dir = 2, speak = "龙女", msg = "刚刚那个撸断了一只手一来就管我叫姑姑的傻x就是你儿子么？"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "废话少说，让你试试我玲珑宝塔的厉害！"},
		{icon = icon_longnv,dir = 2, speak = "龙女", msg = "你这是在自寻死路！！！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		longnv:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		longnv:setAnimation(0, "idle", true)

		local go = cc.MoveTo:create(2, cc.p(400,200))
		local go1 = cc.MoveTo:create(2, cc.p(200,200))
		local event = cc.CallFunc:create(function()
			tianwang:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:Emoji(wanjia, jingdai)
			self:WaitToDialog(0.2)
		end)

		tianwang:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			longnv:setRotationSkewY(180)
			self:Emoji(longnv, qiaoda)
			longnv:setAnimation(1, "atk3", false)
			longnv:setAnimation(0, "idle", true)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, fennu)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			local event = cc.CallFunc:create(function()
				tianwang:setAnimation(1, "atk_ko", false)
				tianwang:setAnimation(0, "idle", true)
			end)
			local delay = cc.DelayTime:create(1.5)
			local event1 = cc.CallFunc:create(function()
				self:WaitToDialog(0.2)
				longnv:setAnimation(1, "atk_ko", false)
				longnv:setAnimation(0, "idle", true)
			end)

			local delay1 = cc.DelayTime:create(2.5)
			local event2 = cc.CallFunc:create(function()
 				self:StoryEnd()
			end)

			tianwang:runAction(cc.Sequence:create({event, delay, event1, delay1, event2}))

		elseif hua == self.message[5].msg then
			-- self:WaitToDialog(0.2)
			-- longnv:setAnimation(1, "atk_ko", false)
			-- longnv:setAnimation(0, "idle", true)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		elseif hua == self.message[6].msg then

        end
    end)


	self:StoryBegin()

end


return Story
