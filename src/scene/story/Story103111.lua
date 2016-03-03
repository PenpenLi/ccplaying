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
    local tangseng = self:CreatePerson(-180, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local erlangshen_skins = {
		["Arm"] = 1007,
		["Hat"] = 1094,
		["Coat"] = 1067,
	}
	local erlangshen = self:CreatePerson(SCREEN_WIDTH-300, 200, 1019, erlangshen_skins)
	erlangshen:setRotationSkewY(180)

	local tushe = self:CreateEmoji("dummy/tushe.png")


    --

    -- 2\
    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	--local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_erlangshen = self:CreateIcon(1019, erlangshen_skins)


    self.message = {
		--{icon = icon_wanjia, dir = wanjia, speak = GameCache.Avatar.Name .."", msg = "哇，前面好像就是凌霄宝殿了，人生第一次来呀，好紧张呀！"}
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "唐僧，你们擅闯天庭所谓何事！"},
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "前几天我在天狗商城买了些狗粮，悟空吃了之后毛色越来越好，所以想推荐给你也试一试。"},
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "我家金毛吃的是天朝特供狗粮，不劳你操心了，下去吧，不要逼我出手！"},
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "我就不下去，我就不下去，你倒是来打我呀！"},

    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wanjia:setVisible(true)
		erlangshen:setVisible(true)

		tangseng:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		erlangshen:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(2, cc.p(380,200))
		local go1 = cc.MoveTo:create(2, cc.p(180,200))

		local event = cc.CallFunc:create(function()
			tangseng:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)

			erlangshen:setAnimation(1, "atk1", false)
			erlangshen:setAnimation(0, "idle", true)

			self:WaitToDialog(0.2)
		end)

        tangseng:runAction(go)
		wanjia:runAction(cc.Sequence:create(go1, event))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
            erlangshen:setAnimation(1, "atk3", false)
            erlangshen:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)

		elseif hua == self.message[3].msg then

			self:WaitToDialog(0.2)
			self:Emoji(tangseng, tushe)


		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
