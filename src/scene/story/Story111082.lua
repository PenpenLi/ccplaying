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
    local erye = self:CreatePerson(-130, 200, 1015, er_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)
	--wanjia:setRotationSkewY(180)

	--local han = self:CreateEmoji("dummy/han.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		--{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "叫我官人！"},
		{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = GameCache.Avatar.Name .. "，前方似有密道，我们快追！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "是的二爷，好的二爷！"},
    }


    self:AddInitEndEvent(function (  )
		erye:setVisible(true)
		wanjia:setVisible(true)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(2.6, cc.p(650,200))
		local go1 = cc.MoveTo:create(2.6, cc.p(400,200))

		local event = cc.CallFunc:create(function()
			erye:setAnimation(0, "idle", true)
			erye:setRotationSkewY(180)
			wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		erye:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))

		--self:WaitToDialog(0.5)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			erye:setRotationSkewY(0)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(2.4, cc.p(SCREEN_WIDTH+400,200))
			local go1 = cc.MoveTo:create(2.4, cc.p(SCREEN_WIDTH+150,200))

			local event = cc.CallFunc:create(function()
				self:StoryEnd()
			end)

			erye:runAction(go)
			wanjia:runAction(cc.Sequence:create({go1,event}))


		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)
			--self:Emoji(wanjia, han)


		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
