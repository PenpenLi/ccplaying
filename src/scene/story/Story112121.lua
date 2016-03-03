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


	local er_skins = {
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 1054,
	}
    local erlangshen = self:CreatePerson(450, 200, 1019, er_skins)

	local huang_skins = {
		["Arm"] = 0,
		["Hat"] = 1094,
		["Coat"] = 1067,
	}
	local huanghe = self:CreatePerson(SCREEN_WIDTH+200, 200, 1043, huang_skins)
	huanghe:setRotationSkewY(180)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local cahan = self:CreateEmoji("dummy/cahan.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erlangshen = self:CreateIcon(1019, er_skins)

	local icon_huanghe = self:CreateIcon(1043, huang_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_erlangshen, dir = 1, speak = "二郎神", msg = "里面的黄鹤听着，你已经被包围了，放下武器，快快出来投降！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "就两个人还特么“包围”，你也真敢说！"},
		{icon = icon_huanghe, dir = 2, speak = "黄鹤", msg = "我知道出来混迟早是要还的，最后只想再问一句…"},
		{icon = icon_erlangshen, dir = 1, speak = "二郎神", msg = "没爱过，人家和你没感情…直接开打吧，玩家一直点屏幕看对话看久了也烦！收拾了你，我也好早点下班呀！！！"},
    }


    self:AddInitEndEvent(function (  )
		erlangshen:setVisible(true)
		wanjia:setVisible(true)
		huanghe:setVisible(true)

		-- erlangshen:setAnimation(0, "move", true)
		-- wanjia:setAnimation(0, "move", true)
		huanghe:setAnimation(0, "move", true)

		-- local go = cc.MoveTo:create(2, cc.p(360,200))
		-- local go1 = cc.MoveTo:create(2, cc.p(200,200))

		-- local event = cc.CallFunc:create(function()
		-- 	erlangshen:setAnimation(0, "idle", true)
		-- 	wanjia:setAnimation(0, "idle", true)
		-- 	self:WaitToDialog(0.2)
		-- end)

		-- erlangshen:runAction(go)
		-- wanjia:runAction(cc.Sequence:create({go1,event}))

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, cahan)


		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.2)
			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-250,200))

			local event = cc.CallFunc:create(function()
				huanghe:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)

			huanghe:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			erlangshen:setAnimation(1, "atk1", false)
			erlangshen:setAnimation(0, "idle", true)

		elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
