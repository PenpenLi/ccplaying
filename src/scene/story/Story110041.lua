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


	local ta_skins = {
		["Arm"] = 1037,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local tianwang = self:CreatePerson(-180, 200, 1031, ta_skins)
	--tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

	local dao_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
	local daotong = self:CreatePerson(SCREEN_WIDTH-280, 200, 1056, dao_skins)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_daotong = self:CreateIcon(1056, dao_skins)


    self.message = {
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "敢问前面的小道友，到金光洞该怎么走？"},
		{icon = icon_daotong, dir = 2, speak = "老道童", msg = "谁小了，你哪只眼睛看见我小了！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "这位老道友，请问…"},
		{icon = icon_daotong, dir = 2, speak = "老道童", msg = "问什么问，问了也没用，师父交代了，不管是谁来都不能说哪咤在这里！"},
		{icon = icon_tianwang, dir = 1, speak = "托塔天王", msg = "哪咤果然在这里！快说，到金光洞该怎么走！！！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)
		daotong:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		daotong:setAnimation(0, "idle", true)

		local go = cc.MoveTo:create(2, cc.p(380,200))
		local go1 = cc.MoveTo:create(2, cc.p(180,200))

		local event = cc.CallFunc:create(function()
			tianwang:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
		end)

		tianwang:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))


		--self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			daotong:setRotationSkewY(180)
			self:Emoji(daotong, fennu)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(daotong, qiaoda)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			tianwang:setAnimation(1, "atk1", false)
			tianwang:setAnimation(0, "idle", true)

		elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
