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

	local diao_skins = {
		["Arm"] = 1016,
		["Hat"] = 1092,
		["Coat"] = 1067,
	}
	local dapengdiao = self:CreatePerson(SCREEN_WIDTH-350, 200, 1048, diao_skins)
	dapengdiao:setRotationSkewY(180)

	local cahan = self:CreateEmoji("dummy/cahan.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_dapengdiao = self:CreateIcon(1048, diao_skins)


    self.message = {
		{icon = icon_dapengdiao,dir = 2, speak = "金翅大鹏雕", msg = "鸟嘴怪，我都快被你感动了，居然又来作死，还嫌被吊打得不够呀？"},
		{icon = icon_leizhenzi, dir = 1, speak = "雷震子", msg = "你不特么也是个鸟嘴怪！"},
		{icon = icon_dapengdiao,dir = 2, speak = "金翅大鹏雕", msg = "嘴还挺硬的嘛！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你确定你不是在自己吐槽自己？"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)
		dapengdiao:setVisible(true)

		leizhenzi:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		dapengdiao:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(2, cc.p(350,200))
		local go1 = cc.MoveTo:create(2, cc.p(200,200))

		local event = cc.CallFunc:create(function()
			dapengdiao:setAnimation(1, "atk_ko", false)
			dapengdiao:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			leizhenzi:setAnimation(0, "idle", true)
			self:WaitToDialog(0.5)
		end)

		leizhenzi:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.0)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.5)

		elseif hua == self.message[3].msg then
			self:Emoji(wanjia, cahan)
			self:WaitToDialog(0.5)

		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
