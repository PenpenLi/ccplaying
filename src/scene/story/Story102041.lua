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

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1077,
		["Coat"] = 1053,
	}
    local sunwukong = self:CreatePerson(550, 200, 1018, wukong_skins)

    local wanjia = self:CreatePerson(350, 200, GameCache.Avatar.Figure)

	local tudi_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local tudigong = self:CreatePerson(SCREEN_WIDTH+200, 200, 1056, tudi_skins)
	tudigong:setRotationSkewY(180)

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_tudigong = self:CreateIcon(1056, tudi_skins)


    self.message = {
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "土地，你给我出来！"},
		{icon = icon_tudigong,dir = 2, speak = "土地公", msg = "我不出来，你要打人！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "土地公，你出来吧，我们就是问个路而已！"},
		{icon = icon_tudigong,dir = 2, speak = "土地公", msg = "你们迷路了叫我干啥，你们手机上有导航呀！"},
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "麻痹的，打你昂！"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)
		tudigong:setVisible(true)

		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		tudigong:setAnimation(0, "idle", true)
		self:WaitToDialog(0.2)

		self:Emoji(sunwukong, fennu)

        --local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))

		--local event = cc.CallFunc:create(function()
            --sunwukong:setAnimation(0, "idle", true)
            --sunwukong:setAnimation(1, "atk_ko", false)
            --sunwukong:setAnimation(0, "idle", true)
			--self:WaitToDialog(0.2)
		--end)

		--niumowang:runAction(go)
        --sunwukong:runAction(cc.Sequence:create({go,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)
			tudigong:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-100, 200))
			local event = cc.CallFunc:create(function()
				-- tudigong:setAnimation(1, "idle", true)
				self:WaitToDialog(0.2)
				tudigong:setRotationSkewY(0)
			end)

			local go1 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH+200,200))
			tudigong:runAction(cc.Sequence:create({go,event,go1}))

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			--local event =cc.CallFunc:create(function()
				--xiaoyaoguai:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.5)
			--end)
			--xiaoyaoguai:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)
			tudigong:setAnimation(0, "move", true)
			tudigong:setRotationSkewY(180)
			local go = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-100, 200))
			local event = cc.CallFunc:create(function()
				-- tudigong:setAnimation(1, "idle", true)
				self:WaitToDialog(0.2)
				tudigong:setRotationSkewY(0)
			end)
			local go1 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH+200,200))
			tudigong:runAction(cc.Sequence:create({go,event,go1}))

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, fennu)
			sunwukong:setAnimation(1, "atk3", false)
			sunwukong:setAnimation(0, "idle", true)

		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)
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
