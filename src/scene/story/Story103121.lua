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
    local tangseng = self:CreatePerson(-180, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local wangmu_skins = {
		["Arm"] = 1036,
		["Hat"] = 1084,
		["Coat"] = 1065,
	}
	local wangmu = self:CreatePerson(SCREEN_WIDTH-350, 200, 1030, wangmu_skins)
	wangmu:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local fennu1 = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	--local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_wangmu = self:CreateIcon(1030, wangmu_skins)


    self.message = {
		{icon = icon_wangmu, dir = 2, speak = "王母娘娘", msg = "小唐唐，你竟敢违抗天庭，你可知罪？"},
		--{icon = icon_wanjia, dir = wanjia, speak = GameCache.Avatar.Name .."", msg = "小…小唐唐…你对王母做过什么？"}
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "你让世间的美少女们愁眉不展，那才是最大的罪过！"},
		{icon = icon_wangmu, dir = 2, speak = "王母娘娘", msg = "呸，你放着好好的经不念，成天就知道去逛夜店！来人，把这个和（yin）尚（seng）给我拿下！"},

    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wanjia:setVisible(true)
		wangmu:setVisible(true)

		tangseng:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		wangmu:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(2, cc.p(380,200))

		local go1 = cc.MoveTo:create(2, cc.p(180,200))

		local event = cc.CallFunc:create(function()
			tangseng:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
		end)

		local delay = cc.DelayTime:create(2)

		local event1 = cc.CallFunc:create(function()
			wangmu:setAnimation(1, "atk3", false)
			wangmu:setAnimation(0, "idle", true)

			self:Emoji(wangmu, fennu)
			self:WaitToDialog(0.2)
		end)

		tangseng:runAction(go)
        wanjia:runAction(cc.Sequence:create(go1, event))
		wangmu:runAction(cc.Sequence:create(delay, event1))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tangseng, fennu1)

		elseif hua == self.message[2].msg then
            wangmu:setAnimation(1, "atk_ko", false)
            wangmu:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)

		elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
