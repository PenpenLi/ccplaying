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

	local shunfenger_skins = {
		["Arm"] = 1000,
		["Hat"] = 1096,
		["Coat"] = 0,
	}
	local shunfenger = self:CreatePerson(SCREEN_WIDTH-600, 300, 1054, shunfenger_skins)

	local er_skins = {
		["Arm"] = 1004,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local erye = self:CreatePerson(-180, 200, 1015, er_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	local huang_skins = {
		["Arm"] = 0,
		["Hat"] = 1094,
		["Coat"] = 1067,
	}
	local huanghe = self:CreatePerson(SCREEN_WIDTH-100, 200, 1043, huang_skins)
	huanghe:setRotationSkewY(180)

	local ju_skins = {
		["Arm"] = 1000,
		["Hat"] = 1096,
		["Coat"] = 1071,
	}
	local julingshen = self:CreatePerson(SCREEN_WIDTH-450, 200, 1052, ju_skins)

	local yan_skins = {
		["Arm"] = 1000,
		["Hat"] = 1090,
		["Coat"] = 1067,
	}
	local yan = self:CreatePerson(SCREEN_WIDTH-620, 150, 1053, yan_skins)

	-- local baoan_skins = {
	-- 	["Arm"] = 1027,
	-- 	["Hat"] = 1093,
	-- 	["Coat"] = 1068,
	-- }
	local baoan = self:CreateMonster(SCREEN_WIDTH+300, 200, "bs_baoanduizhang")
	baoan:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_huanghe = self:CreateIcon(1043, huang_skins)

	local icon_julingshen = self:CreateIcon(1052, ju_skins)


    self.message = {
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "二爷…"},
		{icon = icon_huanghe,dir = 2, speak = "黄鹤", msg = "桶纸们，咱们皮革厂效益一直不好，现在已经倒闭了！大家就各回各家，各找各妈吧！"},
		{icon = icon_julingshen,dir = 1, speak = "工人甲", msg = "工资呢，工资还没结呐！"},
		{icon = icon_huanghe,dir = 2, speak = "黄鹤", msg = "厂都倒闭了，还有个球的工资呀？保卫科长，后面的事儿就交给你啦，我先撤了！"},
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "黄鹤，你站住！"},
    }


    self:AddInitEndEvent(function (  )
		shunfenger:setVisible(true)
		erye:setVisible(true)
		wanjia:setVisible(true)
		huanghe:setVisible(true)
		julingshen:setVisible(true)
		yan:setVisible(true)
		baoan:setVisible(true)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		huanghe:setAnimation(0, "idle", true)
		julingshen:setAnimation(0, "idle", true)
		shunfenger:setAnimation(0, "idle", true)
		yan:setAnimation(0, "idle", true)
		baoan:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(2, cc.p(320,200))
		local go1 = cc.MoveTo:create(2, cc.p(120,200))

		local event = cc.CallFunc:create(function()
			erye:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
		end)
		self:WaitToDialog(0.2)
		erye:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))

		--self:WaitToDialog(0.5)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(julingshen, jingdai)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			-- self:WaitToDialog(0.2)
			huanghe:setRotationSkewY(0)
			huanghe:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+200,200))
			local go1 = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-100,200))

			local event = cc.CallFunc:create(function()
				baoan:setAnimation(1, "atk1", false)
				baoan:setAnimation(0, "idle", true)

			end)

			local delay = cc.DelayTime:create(1)

			local event1 = cc.CallFunc:create(function()
				self:Emoji(erye, fennu)
				erye:setAnimation(1, "atk1", false)
				erye:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)

			huanghe:runAction(go)
			baoan:runAction(cc.Sequence:create({go1,event, delay, event1}))


		elseif hua == self.message[4].msg then
			self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
