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
    local erye = self:CreatePerson(SCREEN_WIDTH-400, 200, 1015, er_skins)
	erye:setRotationSkewY(180)

    local wanjia = self:CreatePerson(400, 200, GameCache.Avatar.Figure)

	local cahan = self:CreateEmoji("dummy/cahan.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local qinqin = self:CreateEmoji("dummy/qinqin.png")
    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = GameCache.Avatar.Name .. "，我的档期冲突了，所以这一季的男一号要换人了。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "擦，你什么时候成男一号了？"},
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "不要把你的内心独白随便说出来，会尴尬的！"},
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "咳咳…那追捕黄鹤的事接下来就交给你和二郎神来办了，我就先走了。"},
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "二爷慢走，要保佑我今年的横财运哟！"},
    }


    self:AddInitEndEvent(function (  )
		erye:setVisible(true)
		wanjia:setVisible(true)

		erye:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)



		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, koubi)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(erye, cahan)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
			self:Emoji(wanjia, qinqin)
			self:WaitToDialog(0.2)

			erye:setRotationSkewY(0)
			erye:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))
			local event = cc.CallFunc:create(function()
				self:StoryEnd()
			end)

			erye:runAction(cc.Sequence:create({go,event}))


		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.2)


		--elseif hua == self.message[6].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
