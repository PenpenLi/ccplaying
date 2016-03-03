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
		["Arm"] = 1004,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local erye = self:CreatePerson(-150, 200, 1015, er_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	local huang_skins = {
		["Arm"] = 0,
		["Hat"] = 1094,
		["Coat"] = 1067,
	}
	local huanghe = self:CreatePerson(SCREEN_WIDTH-400, 200, 1043, huang_skins)
	huanghe:setRotationSkewY(180)

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_huanghe = self:CreateIcon(1043, huang_skins)


    self.message = {
		{icon = icon_huanghe, dir = 2, speak = "黄鹤", msg = "唉呀妈呀，三十六计走为上计，隔壁老王救救我嘞…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "妈蛋，居然让那厮给跑掉了！"},
		{icon = icon_erye, dir = 2, speak = "关圣帝君", msg = "不着急，下一季咱们继续逮他！"},
    }


    self:AddInitEndEvent(function (  )
		erye:setVisible(true)
		wanjia:setVisible(true)
		huanghe:setVisible(true)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		huanghe:setAnimation(0, "idle", true)

		self:Emoji(huanghe, jingkong)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.2)
			huanghe:setRotationSkewY(0)
			huanghe:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))
			local go1 = cc.MoveTo:create(2.5, cc.p(600,200))
			local go2 = cc.MoveTo:create(2.5, cc.p(400,200))

			local event = cc.CallFunc:create(function()
				erye:setAnimation(0, "idle", true)
				wanjia:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)

			huanghe:runAction(go)
			erye:runAction(go1)
			wanjia:runAction(cc.Sequence:create({go2,event}))


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(erye, koubi)
			erye:setRotationSkewY(180)


		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[4].msg then
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
