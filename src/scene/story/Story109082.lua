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

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local longnv_skins = {
		["Arm"] = 1022,
		["Hat"] = 0,
		["Coat"] = 1067,
	}
	local longnv = self:CreatePerson(SCREEN_WIDTH-260, 200, 1040, longnv_skins)
	longnv:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local tushe = self:CreateEmoji("dummy/tushe.png")

	local kelian = self:CreateEmoji("dummy/kelian.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_longnv = self:CreateIcon(1040, longnv_skins)


    self.message = {
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "呵呵，看来是场误会呀，李某人在此给姑娘赔罪了！"},
		{icon = icon_longnv,dir = 2, speak = "龙女", msg = "滚！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "姑姑你别生气了… "},
		{icon = icon_longnv,dir = 2, speak = "龙女", msg = "滚！！！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		longnv:setVisible(true)

		tianwang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		longnv:setAnimation(0, "idle", true)

		self:Emoji(tianwang, tushe)

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			longnv:setRotationSkewY(180)
			self:Emoji(longnv, fennu)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, kelian)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0)
			longnv:setAnimation(1, "atk_ko", false)
			longnv:setAnimation(0, "idle", true)

			tianwang:setRotationSkewY(180)
			wanjia:setRotationSkewY(180)

			tianwang:setAnimation(0, "move", true)
			wanjia:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(1.5, cc.p(-200,200))
			local go1 = cc.MoveTo:create(1.5, cc.p(-400,200))
			local delay = cc.DelayTime:create(1)
			local event = cc.CallFunc:create(function()
				--tianwang:setAnimation(0, "idle", true)
				--wanjia:setAnimation(0, "idle", true)
				self:StoryEnd()
			end)

			tianwang:runAction(go)
			wanjia:runAction(cc.Sequence:create({go1,delay,event}))

		elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.2)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.2)

			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		--elseif hua == self.message[6].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
