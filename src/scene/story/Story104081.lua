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
    local shawujing = self:CreatePerson(-180, 200, 1028, wujing_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local menwei = self:CreateMonster(SCREEN_WIDTH-350, 200, "gw_baoan")
	menwei:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local fennu1 = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_shawujing = self:CreateIcon(1028, wujing_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_menwei = self:CreateMonsterIcon("gw_baoan")


    self.message = {
		{icon = icon_menwei, dir = 2, speak = "门卫", msg = "站到，干啥子嘞！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "让开，我们是相关部门的，来检查下你们厂排污！"},
		{icon = icon_shawujing, dir = 1, speak = "沙悟净", msg = "这是我好不容易捞着的出场机会了，快点让！"},
		{icon = icon_menwei, dir = 2, speak = "门卫", msg = "不让你是要打我咩？！"},
		{icon = icon_shawujing, dir = 1, speak = "沙悟净", msg = "打的就是你！"},
    }


    self:AddInitEndEvent(function (  )
		shawujing:setVisible(true)
		wanjia:setVisible(true)
		menwei:setVisible(true)

		shawujing:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		menwei:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(2.2, cc.p(380,200))
		local go1 = cc.MoveTo:create(2.2, cc.p(180,200))

		local event = cc.CallFunc:create(function()
			shawujing:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:Emoji(menwei, fennu)
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


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			menwei:setAnimation(1, "atk1", false)
			menwei:setAnimation(0, "idle", true)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shawujing, fennu)
			self:Emoji(wanjia, fennu1)

			shawujing:setAnimation(1, "atk3", false)
			shawujing:setAnimation(0, "idle", true)


		elseif hua == self.message[5].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
