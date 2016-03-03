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
    local sunwukong = self:CreatePerson(-180, 200, 1018, wukong_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local gui_skins = {
		["Arm"] = 1043,
		["Hat"] = 1085,
		["Coat"] = 0,
	}
	local wugui = self:CreatePerson(SCREEN_WIDTH-280, 200, 1029, gui_skins)
	--wugui:setRotationSkewY(180)

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local biti = self:CreateEmoji("dummy/biti.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local touxiao = self:CreateEmoji("dummy/touxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_wugui = self:CreateIcon(1029, gui_skins)


    self.message = {
		{icon = icon_wugui,dir = 2, speak = "龟丞相", msg = "大大大大大~事不好啦...金毛猴子又来龙宫啦！！！大家快逃呀…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "猴哥，你的人气真高呀！"},
		{icon = icon_sunwukong,dir = 2, speak = "孙悟空", msg = "不要说话，让我一只猴静静…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "静静是谁？"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)
		wugui:setVisible(true)

		sunwukong:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		wugui:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(2, cc.p(480,200))
		local go1 = cc.MoveTo:create(2, cc.p(280,200))

		local event = cc.CallFunc:create(function()
            sunwukong:setAnimation(0, "idle", true)
            wanjia:setAnimation(0, "idle", true)
			wugui:setRotationSkewY(180)
			self:Emoji(wugui, jingkong)
			self:WaitToDialog(0.2)
		end)

		sunwukong:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			wugui:setRotationSkewY(0)
			wugui:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+200,200))
			-- local event = cc.CallFunc:create(function()
			-- 	self:WaitToDialog(0.2)
			-- end)
			wugui:runAction(go)
			self:Emoji(wanjia, biti)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, koubi)
			sunwukong:setRotationSkewY(180)

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			--local event =cc.CallFunc:create(function()
				--xiaoyaoguai:setAnimation(0, "idle", true)
				--self:WaitToDialog(0.5)
			--end)
			--xiaoyaoguai:runAction(cc.Sequence:create({go,event}))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, touxiao)

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
