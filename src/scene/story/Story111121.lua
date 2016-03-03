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


	local huang_skins = {
		["Arm"] = 0,
		["Hat"] = 1094,
		["Coat"] = 1067,
	}
	local huanghe = self:CreatePerson(-200, 200, 1043, huang_skins)

	local zhizhu = self:CreateMonster(SCREEN_WIDTH+220, 200, "bs_zhizhu")
	zhizhu:setRotationSkewY(180)

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local qinqin = self:CreateEmoji("dummy/qinqin.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_zhizhu = self:CreateMonsterIcon("bs_zhizhu")

	local icon_huanghe = self:CreateIcon(1043, huang_skins)


    self.message = {
		{icon = icon_huanghe, dir = 1, speak = "黄鹤", msg = "达令！达令你在哪里？！"},
		{icon = icon_zhizhu, dir = 2, speak = "蜘蛛精", msg = "什么事呀，哈尼？"},
		{icon = icon_huanghe, dir = 1, speak = "黄鹤", msg = "达令你听我说，我不是把我那皮革厂抵押给隔壁老王了么，但现在有两个穷逼来找我讨要工资，你先帮我把他们俩给打发咯！"},
		{icon = icon_zhizhu, dir = 2, speak = "蜘蛛精", msg = "萌大奶，爱你么么哒！"},
		{icon = icon_zhizhu, dir = 2, speak = "蜘蛛精", msg = "放马过来吧，讨债的穷逼们！"},
    }


    self:AddInitEndEvent(function (  )
		huanghe:setVisible(true)
		zhizhu:setVisible(true)

		huanghe:setAnimation(0, "move", true)
		zhizhu:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(1.8, cc.p(350,200))

		local event = cc.CallFunc:create(function()
			huanghe:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		huanghe:runAction(cc.Sequence:create({go,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)

			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH-220,200))

			local event = cc.CallFunc:create(function()
				zhizhu:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
				self:Emoji(zhizhu, yiwen)
			end)

			zhizhu:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(zhizhu, qinqin)

			huanghe:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH+200,200))

			huanghe:runAction(go)


		elseif hua == self.message[4].msg then
			zhizhu:setAnimation(0, "move", true)

			local go = cc.MoveBy:create(0.5, cc.p(-150,0))

			local event = cc.CallFunc:create(function()
				zhizhu:setAnimation(1, "atk_ko", false)
				zhizhu:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)

			zhizhu:runAction(cc.Sequence:create({go, event}))

		elseif hua == self.message[5].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
