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
    local erye = self:CreatePerson(-100, 200, 1015, er_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)
	--wanjia:setRotationSkewY(180)

	local jianxiao = self:CreateEmoji("dummy/jianxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		--{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "叫我官人！"},
		--{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = GameCache.Avatar.Name .. "，前方似有密道，我们快追！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "嚯哟，居然有个金屋藏娇的地方，难道这里住的就是传说中黄鹤的小姨子？"},
    }


    self:AddInitEndEvent(function (  )
		erye:setVisible(true)
		wanjia:setVisible(true)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(2.5, cc.p(650,200))
		local go1 = cc.MoveTo:create(2.5, cc.p(400,200))

		local event = cc.CallFunc:create(function()
			self:Emoji(wanjia, jianxiao)
			erye:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
		end)

		local delay = cc.DelayTime:create(0.5)

		local event1 = 	cc.CallFunc:create(function()
			erye:setRotationSkewY(180)
			self:WaitToDialog(0.2)
		end)

		erye:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event,delay, event1}))

		--self:WaitToDialog(0.5)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)
			--self:Emoji(wanjia, han)


		--elseif hua == self.message[3].msg then
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
