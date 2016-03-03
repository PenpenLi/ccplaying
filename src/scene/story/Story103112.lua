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


	local tangseng_skins = {
		["Arm"] = 1042,
		["Hat"] = 1092,
		["Coat"] = 1067,
	}
    local tangseng = self:CreatePerson(380, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local wangmu_skins = {
		["Arm"] = 1036,
		["Hat"] = 1084,
		["Coat"] = 1065,
	}
	local wangmuniangniang = self:CreatePerson(SCREEN_WIDTH+200, 200, 1030, wangmu_skins)
	wangmuniangniang:setRotationSkewY(180)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")


    --

    -- 2\
    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_wangmuniangniang = self:CreateIcon(1030, wangmu_skins)


    self.message = {
		{icon = icon_wangmuniangniang, dir = 2, speak = "王母娘娘", msg = "小唐唐，你竟敢违抗天庭，你可知罪？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "小…小唐唐…你对王母做过什么？"},
		{icon = icon_tangseng, dir = 2, speak = "唐僧", msg = "咱们的事情先放一放，下一关再说吧亲~还有一关呢！"},

    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wanjia:setVisible(true)
		wangmuniangniang:setVisible(true)

		tangseng:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		wangmuniangniang:setAnimation(0, "move", true)

        local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-350,200))

		local event = cc.CallFunc:create(function()
			wangmuniangniang:setAnimation(1, "atk3", false)
			wangmuniangniang:setAnimation(0, "idle", true)
			self:Emoji(wangmuniangniang, fennu)
			self:WaitToDialog(0.2)
		end)

        wangmuniangniang:runAction(cc.Sequence:create(go, event))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, jingdai)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tangseng, koubi)

		elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
