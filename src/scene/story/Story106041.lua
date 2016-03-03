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
	--tieshangongzhu:setRotationSkewY(180)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	local yan_skins = {
		["Arm"] = 1045,
		["Hat"] = 1088,
		["Coat"] = 1068,
	}
	local qianliyan = self:CreatePerson(SCREEN_WIDTH-350, 200, 1053, yan_skins)

	local er_skins = {
		["Arm"] = 1045,
		["Hat"] = 1087,
		["Coat"] = 1067,
	}
	local shunfenger = self:CreatePerson(SCREEN_WIDTH-200, 200, 1054, er_skins)
	shunfenger:setRotationSkewY(180)

	local guzhang = self:CreateEmoji("dummy/guzhang.png")

	local tushe = self:CreateEmoji("dummy/tushe.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_qianliyan = self:CreateIcon(1053, yan_skins)

	local icon_shunfenger = self:CreateIcon(1054, er_skins)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "嘿！千里眼，顺风耳！"},
		{icon = icon_qianliyan,dir = 2, speak = "千里眼", msg = "来得正好，我们来玩一个游戏吧。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "可我们还有急事需要你们帮忙…"},
		{icon = icon_shunfenger,dir = 2, speak = "顺风耳", msg = "先陪我们玩，然后再帮你们的忙！"},
		{icon = icon_leizhenzi,dir = 1, speak = "雷震子", msg = "怎么一个玩儿法？"},
		{icon = icon_qianliyan,dir = 2, speak = "千里眼", msg = "打赢我们！"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)
		qianliyan:setVisible(true)
		shunfenger:setVisible(true)


		leizhenzi:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		qianliyan:setAnimation(0, "idle", true)
		shunfenger:setAnimation(0, "idle", true)

        --self:Emoji(leizhenzi, daku)
		self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(2, cc.p(350,200))
		local go1 = cc.MoveTo:create(2, cc.p(200,200))

		local event = cc.CallFunc:create(function()
            leizhenzi:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
            --leizhenzi:setAnimation(1, "atk_ko", false)
            --leizhenzi:setAnimation(0, "idle", true)
            qianliyan:setRotationSkewY(180)
			self:Emoji(qianliyan, guzhang)
			self:WaitToDialog(0.2)
		end)

		leizhenzi:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shunfenger, tushe)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
            qianliyan:setAnimation(1, "atk_ko", false)
            qianliyan:setAnimation(0, "idle", true)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
