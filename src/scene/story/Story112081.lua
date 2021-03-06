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
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 1054,
	}
    local erlangshen = self:CreatePerson(SCREEN_WIDTH-350, 200, 1019, er_skins)
	erlangshen:setRotationSkewY(180)

    local wanjia = self:CreatePerson(360, 200, GameCache.Avatar.Figure)

	local yun = self:CreateEmoji("dummy/yun.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erlangshen = self:CreateIcon(1019, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "尖…尖尖呀，咱们在皮革厂里都转了好几圈了，你到底行不行呀？"},
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "放心，人家可是专业的…"},
    }


    self:AddInitEndEvent(function (  )
		erlangshen:setVisible(true)
		wanjia:setVisible(true)


		-- wanjia:setAnimation(0, "move", true)


		-- local go1 = cc.MoveTo:create(2.5, cc.p(360,200))

		-- local event = cc.CallFunc:create(function()
		-- 	erlangshen:setAnimation(0, "idle", true)
		-- 	wanjia:setAnimation(0, "idle", true)
		-- 	self:Emoji(wanjia, yun)
		-- 	self:WaitToDialog(0.2)
		-- end)

		-- wanjia:runAction(cc.Sequence:create({go1,event}))
		self:Emoji(wanjia, yun)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			erlangshen:setRotationSkewY(0)

			erlangshen:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))
			erlangshen:runAction(go)

		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)
			--self:Emoji(wanjia, han)

		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
