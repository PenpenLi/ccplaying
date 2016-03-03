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
    local leizhenzi = self:CreatePerson(350, 200, 1048, lei_skins)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local yan_skins = {
		["Arm"] = 1045,
		["Hat"] = 1088,
		["Coat"] = 1068,
	}
	local qianliyan = self:CreatePerson(SCREEN_WIDTH-350, 200, 1053, yan_skins)
	qianliyan:setRotationSkewY(180)

	local er_skins = {
		["Arm"] = 1045,
		["Hat"] = 1087,
		["Coat"] = 1067,
	}
	local shunfenger = self:CreatePerson(SCREEN_WIDTH-200, 200, 1054, er_skins)
	shunfenger:setRotationSkewY(180)

	local deyi = self:CreateEmoji("dummy/deyi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_qianliyan = self:CreateIcon(1053, yan_skins)

	local icon_shunfenger = self:CreateIcon(1054, er_skins)


    self.message = {
		{icon = icon_qianliyan,dir = 2, speak = "千里眼", msg = "39.281344,75.592312！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "什么？"},
		{icon = icon_shunfenger,dir = 2, speak = "顺风耳", msg = "大鹏雕老巢的坐标，笨蛋！"},
		{icon = icon_leizhenzi,dir = 1, speak = "雷震子", msg = "你们怎么知道我们想…"},
		{icon = icon_qianliyan,dir = 2, speak = "千里眼", msg = "千万不要小瞧了天朝的情报机关！"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)
		qianliyan:setVisible(true)
		shunfenger:setVisible(true)


		leizhenzi:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		qianliyan:setAnimation(0, "idle", true)
		shunfenger:setAnimation(0, "idle", true)

        --self:Emoji(leizhenzi, daku)
		self:WaitToDialog(0.5)

        --local go = cc.MoveTo:create(2, cc.p(350,200))
		--local go1 = cc.MoveTo:create(2, cc.p(200,200))

		--local event = cc.CallFunc:create(function()
            --leizhenzi:setAnimation(0, "idle", true)
			--wanjia:setAnimation(0, "idle", true)
            --leizhenzi:setAnimation(1, "atk_ko", false)
            --leizhenzi:setAnimation(0, "idle", true)
			--self:WaitToDialog(0.5)
		--end)

		--leizhenzi:runAction(go)
        --wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.5)
			--qianliyan:setRotationSkewY(180)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.5)

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.5)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.5)
			self:Emoji(qianliyan, deyi)

		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)
            --qianliyan:setAnimation(1, "atk_ko", false)
            --qianliyan:setAnimation(0, "idle", true)
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
