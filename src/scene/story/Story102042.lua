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



    local wanjia = self:CreatePerson(300, 200, GameCache.Avatar.Figure)

	local tudi_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local tudigong = self:CreatePerson(780, 200, 1056, tudi_skins)
	tudigong:setRotationSkewY(180)

	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1077,
		["Coat"] = 1053,
	}
    local sunwukong = self:CreatePerson(500, 200, 1018, wukong_skins)

	local jingkong = self:CreateEmoji("dummy/jingkong.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_tudigong = self:CreateIcon(1056, tudi_skins)


    self.message = {
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "土地老儿，你是不是觉得土地收归国有后你就是国家干部啦？"},
		{icon = icon_tudigong,dir = 2, speak = "土地公", msg = "不敢，不敢…"},
		{icon = icon_sunwukong,dir = 1, speak = "孙悟空", msg = "别忘了俺老孙可是斗战胜佛，就是专治各种不服！"},
		{icon = icon_tudigong,dir = 2, speak = "土地公", msg = "孙总息怒，孙总饶命呀！"},
		{icon = icon_tudigong,dir = 2, speak = "土地公", msg = "都怪这些日子ZF为了修地铁乱改道，但路牌却没人管。孙总是想要去龙宫吧，顺着这条道一直走便是…"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)
		tudigong:setVisible(true)

		sunwukong:setAnimation(1, "atk3", false)
		sunwukong:setAnimation(0, "idle", true)

		wanjia:setAnimation(0, "idle", true)

		tudigong:setAnimation(1, "hit", false)
		tudigong:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)
		--self:Emoji(tudigong, qiaoda)

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
			self:Emoji(tudigong, jingkong)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			sunwukong:setAnimation(1, "atk_ko", false)
			sunwukong:setAnimation(0, "idle", true)

			local delay = cc.DelayTime:create(0.5)

			local event = cc.CallFunc:create(function (  )
				tudigong:setAnimation(1, "hit", false)
				tudigong:setAnimation(0, "idle", true)
			end)

			tudigong:runAction(cc.Sequence:create({delay,event}))

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			--local event =cc.CallFunc:create(function()
				--xiaoyaoguai:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.5)
			--end)
			--xiaoyaoguai:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)

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
