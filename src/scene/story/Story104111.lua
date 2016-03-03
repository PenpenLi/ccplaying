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


	local wujing_skins = {
		["Arm"] = 1010,
		["Hat"] = 1083,
		["Coat"] = 0,
	}
    local shawujing = self:CreatePerson(-200, 200, 1028, wujing_skins)

    local wanjia = self:CreatePerson(-550, 200, GameCache.Avatar.Figure)

	--local baoweikezhang = self:CreatePerson(SCREEN_WIDTH-350, 200, 1037)
	--baoweikezhang:setRotationSkewY(180)

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_shawujing = self:CreateIcon(1028, wujing_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	--local icon_baoweikezhang = self:CreateIcon(1037)


    self.message = {
		{icon = icon_shawujing, dir = 2, speak = "沙悟净", msg = "咦，前面好像有个洞，要不要进去看看？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "加把劲儿，就快要到关底Boss了！"},
		{icon = icon_shawujing, dir = 2, speak = "沙悟净", msg = "你怎么知道的？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "这游戏的天（sha）才（bi）策划好像对洞有着某些特殊的癖好…"},


    }


    self:AddInitEndEvent(function (  )
		shawujing:setVisible(true)
		wanjia:setVisible(true)

		shawujing:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

        local go = cc.MoveTo:create(3.2, cc.p(SCREEN_WIDTH*0.5+180, 200))
		local go1 = cc.MoveTo:create(3.2, cc.p(SCREEN_WIDTH*0.5-170,200))

		local event = cc.CallFunc:create(function()
			shawujing:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		shawujing:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			shawujing:setRotationSkewY(180)
			--tangseng:setRotationSkewY(180)
			--tangseng:setAnimation(1, "move", true)
			--local go1 = cc.MoveTo:create(1, cc.p(SCREEN_WIDTH-500,200))
			--local event1 = cc.CallFunc:create(function()
			--	tangseng:setAnimation(0, "idle", true)
			--	self:WaitToDialog(0.5)
			--end)
			--tangseng:runAction(cc.Sequence:create({go1,event1}))


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, koubi)


		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
