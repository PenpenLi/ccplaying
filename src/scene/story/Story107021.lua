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


	local xu_skins = {
		["Arm"] = 1043,
		["Hat"] = 1090,
		["Coat"] = 1071,
	}
    local xuxian = self:CreatePerson(-200, 200, 1043, xu_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	--local baogongtou = self:CreatePerson(SCREEN_WIDTH+300, 200, 1049)
	--baogongtou:setRotationSkewY(180)

	--local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	--local icon_baogongtou = self:CreateIcon(1049)


    self.message = {
		--{icon = icon_baogongtou,dir = 2, speak = "包工头", msg = "老板，装修已经弄完了，该结款咯！"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "快追，别让包工头跑啦！"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "我看你的气焰也挺嚣张的嘛！"},
    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)

		xuxian:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+350,200))
		local go1 = cc.MoveTo:create(5, cc.p(SCREEN_WIDTH+200,200))
        local event = cc.CallFunc:create(function()
            self:StoryEnd()
        end)
        xuxian:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			--local event =cc.CallFunc:create(function()
				--xiaoyaoguai:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.5)
			--end)
			--xiaoyaoguai:runAction(cc.Sequence:create({go,event}))

		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		--elseif hua == self.message[6].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
