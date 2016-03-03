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
		["Arm"] = 1004,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local erye = self:CreatePerson(-200, 200, 1015, er_skins)

    local wanjia = self:CreatePerson(SCREEN_WIDTH-300, 200, GameCache.Avatar.Figure)
	--wanjia:setRotationSkewY(180)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erye = self:CreateIcon(1015, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "二爷出啥事呐，走得那么急？"},
		{icon = icon_erye,dir = 1, speak = "关圣帝君", msg = "追债！"},
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "居然有人敢欠二爷的钱？"},
		{icon = icon_erye,dir = 1, speak = "关圣帝君", msg = "帮民工讨工资！"},
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "这么刺激？那我也来帮你！"},
    }


    self:AddInitEndEvent(function (  )
		erye:setVisible(true)
		wanjia:setVisible(true)

		erye:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "idle", true)

		wanjia:setRotationSkewY(180)

		local go = cc.MoveTo:create(2.5, cc.p(400,200))
		local event = cc.CallFunc:create(function()
			erye:setAnimation(0, "idle", true)
		end)

		erye:runAction(cc.Sequence:create({go,event}))

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, jingdai)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			erye:setAnimation(1, "atk_ko", false)
			erye:setAnimation(0, "idle", true)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
