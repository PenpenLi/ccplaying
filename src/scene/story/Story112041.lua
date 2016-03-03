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
    local erlangshen = self:CreatePerson(SCREEN_WIDTH*0.5-150, 200, 1019, er_skins)

	local hua_skins = {
		["Arm"] = 1000,
		["Hat"] = 0,
		["Coat"] = 1058,
	}
	local huazai = self:CreatePerson(SCREEN_WIDTH*0.5+150, 200, 1049, hua_skins)
	huazai:setRotationSkewY(180)

    --local wanjia = self:CreatePerson(350, 200, GameCache.Avatar.Figure)

	local haixiu = self:CreateEmoji("dummy/haixiu.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erlangshen = self:CreateIcon(1019, er_skins)

	local icon_huazai = self:CreateIcon(1049, hua_skins)

	--local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "从天庭下来…唐Boss，你搬上去住啦？"},
		{icon = icon_huazai, dir = 2, speak = "华仔", msg = "我一直以为你只是在Cosplay写乐保介，万万没想到，你居然是天朝派来的卧底。"},
		{icon = icon_erlangshen, dir = 1, speak = "二郎神", msg = "跟我回去自首吧，转污点证人，至少能少判好几千年。"},
		{icon = icon_huazai, dir = 2, speak = "华仔", msg = "还是你放了我吧，大家毕竟做了那么几天的好兄弟，我也想做个好人…"},
		{icon = icon_erlangshen, dir = 1, speak = "二郎神", msg = "对不起，我是警察。"},
		{icon = icon_huazai, dir = 2, speak = "华仔", msg = "明白。最后在问你一个问题…"},
		{icon = icon_erlangshen, dir = 1, speak = "二郎神", msg = "爱过！"},
    }


    self:AddInitEndEvent(function (  )
		erlangshen:setVisible(true)
		huazai:setVisible(true)

		erlangshen:setAnimation(0, "idle", true)
		huazai:setAnimation(0, "idle", true)

		self:Emoji(huazai, jingdai)

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			--local go = cc.MoveTo:create(2, cc.p(350,200))

			--local event = cc.CallFunc:create(function()
				--wanjia:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.2)
			--end)

			--wanjia:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			erlangshen:setAnimation(1, "atk1", false)
			erlangshen:setAnimation(0, "idle", true)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(1.0)
			erlangshen:setRotationSkewY(180)
			self:Emoji(erlangshen, haixiu)

		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
