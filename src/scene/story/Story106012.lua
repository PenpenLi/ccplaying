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
    local leizhenzi = self:CreatePerson(SCREEN_WIDTH*0.5+180, 200, 1048, lei_skins)
	leizhenzi:setRotationSkewY(180)

    local wanjia = self:CreatePerson(SCREEN_WIDTH*0.5-170, 200, GameCache.Avatar.Figure)

	--local tieshangongzhu = self:CreatePerson(SCREEN_WIDTH+200, 200, 1042)

	local biti = self:CreateEmoji("dummy/biti.png")

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	--local icon_tieshangongzhu = self:CreateIcon(1042)


    self.message = {
		{icon = icon_leizhenzi, dir = 2, speak = "雷震子", msg = "我们刚才好像莫名其妙地打了一群怪呀…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "作为一名玩家，打打怪升升级也是很合理很合逻辑的呀！"},
		{icon = icon_leizhenzi,dir = 1, speak = "雷震子", msg = "你说得好有道理，我竟然无言以对…"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)

		self:WaitToDialog(0.2)
		self:Emoji(leizhenzi, yiwen)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, koubi)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(leizhenzi, biti)


		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)
			--self:Emoji(wanjia, fennu)
            --wanjia:setAnimation(1, "atk_ko", false)
            --wanjia:setAnimation(0, "idle", true)


		--elseif hua == self.message[4].msg then
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
