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

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1077,
		["Coat"] = 1053,
	}
    local sunwukong = self:CreatePerson(400, 200, 1018, wukong_skins)
	sunwukong:setRotationSkewY(180)

	local yao_skins = {
		["Arm"] = 1011,
		["Hat"] = 1090,
		["Coat"] = 1069,
	}
	local xiaoyaoguai = self:CreatePerson(SCREEN_WIDTH+200, 200, 1052, yao_skins)
	xiaoyaoguai:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_xiaoyaoguai = self:CreateIcon(1052, yao_skins)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "猴哥，你确定这条是去龙宫的路？"},
		{icon = icon_sunwukong,dir = 2, speak = "孙悟空", msg = "额…要不我们去逮只小妖怪来问问吧！"},
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "嘿，妖怪，这是去龙宫的路么？"},
		{icon = icon_xiaoyaoguai,dir = 2, speak = "小妖怪", msg = "我是只有骨气的妖怪，打死我也不说！"},
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "嚯哟~很拽是伐！"},
    }


    self:AddInitEndEvent(function (  )
    	wanjia:setVisible(true)
		sunwukong:setVisible(true)
		xiaoyaoguai:setVisible(true)

		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		xiaoyaoguai:setAnimation(0, "idle", true)
		self:WaitToDialog(0.2)

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
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			sunwukong:setRotationSkewY(0)
			xiaoyaoguai:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(1.3, cc.p(SCREEN_WIDTH-200,200))
			local event =cc.CallFunc:create(function()
				xiaoyaoguai:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)
			xiaoyaoguai:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, fennu)
            sunwukong:setAnimation(1, "atk1", false)
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
