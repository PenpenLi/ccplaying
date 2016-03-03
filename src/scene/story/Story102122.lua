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

	--local longwang = self:CreatePerson(SCREEN_WIDTH+250, 200, 1032)
	--longwang:setRotationSkewY(180)

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")

	local bishi = self:CreateEmoji("dummy/bishi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_sunwukong,dir = 2, speak = "孙悟空", msg = "次奥，龙宫也不咋地嘛，连个好宝贝都没有。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "对了，话说我都不知道我们要找的那法宝叫啥呀？"},
		{icon = icon_sunwukong,dir = 2, speak = "孙悟空", msg = "名字挺难念的，好像是“佛陀削骨”，洋文是PS！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你麻痹呀…"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)

		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		self:Emoji(sunwukong, bishi)

		self:WaitToDialog(0.2)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			sunwukong:setRotationSkewY(180)

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			--local event =cc.CallFunc:create(function()
				--xiaoyaoguai:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.2)
			--end)
			--xiaoyaoguai:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, qiaoda)

		elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[5].msg then
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
