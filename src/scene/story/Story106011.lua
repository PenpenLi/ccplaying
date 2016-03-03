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


	local lei_skins = {
		["Arm"] = 1010,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local leizhenzi = self:CreatePerson(SCREEN_WIDTH+200, 200, 1048, lei_skins)
	leizhenzi:setRotationSkewY(180)

    local wanjia = self:CreatePerson(350, 200, GameCache.Avatar.Figure)

	--local tieshangongzhu = self:CreatePerson(SCREEN_WIDTH+200, 200, 1042)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local daku = self:CreateEmoji("dummy/daku.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	--local icon_tieshangongzhu = self:CreateIcon(1042)


    self.message = {
		{icon = icon_leizhenzi, dir = 2, speak = "雷震子", msg = GameCache.Avatar.Name .. "，我被大鹏物流的CEO打了，帮我报仇！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "冤冤相报何时了，佛曰多一事不如少一事…"},
		{icon = icon_leizhenzi,dir = 2, speak = "雷震子", msg = "但他们黑走了王母买的超（qi）短（bi）裙，难道你不期待王母穿超（qi）短（bi）裙的样子吗！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "妈蛋，金翅大鹏雕快给你爷爷出来！"},

    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)
		--tieshangongzhu:setVisible(true)


		leizhenzi:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "idle", true)
        
		--self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))

		local event = cc.CallFunc:create(function()
            leizhenzi:setAnimation(0, "idle", true)
            --leizhenzi:setAnimation(1, "atk_ko", false)
            --leizhenzi:setAnimation(0, "idle", true)
            self:Emoji(leizhenzi, daku)
			self:WaitToDialog(0.2)
		end)

		--niumowang:runAction(go)
        leizhenzi:runAction(cc.Sequence:create({go,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:Emoji(wanjia, koubi)
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.5)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.5)
			self:Emoji(wanjia, fennu)
            wanjia:setAnimation(1, "atk_ko", false)
            wanjia:setAnimation(0, "idle", true)


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
