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
		["Arm"] = 1000,
		["Hat"] = 0,
		["Coat"] = 1054,
	}
    local erlangshen = self:CreatePerson(SCREEN_WIDTH-350, 200, 1019, er_skins)
	--huazai:setRotationSkewY(180)

    local wanjia = self:CreatePerson(-200, 200, GameCache.Avatar.Figure)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erlangshen = self:CreateIcon(1019, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "杨哥，你别太难过了，正邪不两立，你只是做了你该做的事情…"},
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "哦，没事，不用担心我。我只是在想一会儿上哪儿去做个发型，再约上几个姐妹去血拼一下！你不明白的啦，这几天快憋死我啦，终于可以做会我自己了，真舒服…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "杨…杨哥，二爷还叫咱去逮黄鹤呢，可能你还暂时不能去做发型…发型……"},
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "知道啦，事儿怎么这么多，神烦！"},
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "还有，别管人家叫杨哥，听着别扭。以后就叫我尖尖…或者杨姐吧，听着也像是在叫人家的名儿。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "尖…尖尖…杨…杨姐…"},
    }


    self:AddInitEndEvent(function (  )
		erlangshen:setVisible(true)
		wanjia:setVisible(true)

		erlangshen:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(2, cc.p(350,200))

		local event = cc.CallFunc:create(function()
			wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		wanjia:runAction(cc.Sequence:create({go,event}))

		--self:WaitToDialog(0.5)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			erlangshen:setRotationSkewY(180)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, jingdai)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(erlangshen, fennu)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, jingkong)

		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
