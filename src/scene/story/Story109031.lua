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
    local tianwang = self:CreatePerson(-350, 200, 1031, ta_skins)
	--tianwang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(-150, 200, GameCache.Avatar.Figure)

	local fennu = self:CreateEmoji("dummy/fennu.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_tianwang = self:CreateIcon(1031, ta_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "是有什么发现么？"},
		{icon = icon_wanjia, dir = 2, speak = GameCache.Avatar.Name .."", msg = "嗯！我发现你们家真大呀，装修没少花钱吧。现在的装修公司都挺黑的，我有个朋友也是才装修完房子，被坑惨了…"},
		{icon = icon_tianwang,dir = 1, speak = "托塔天王", msg = "干正事儿！"},
    }


    self:AddInitEndEvent(function (  )
		tianwang:setVisible(true)
		wanjia:setVisible(true)

		tianwang:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

		local go = cc.MoveTo:create(3, cc.p(400,200))
		local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-350,200))
		local event = cc.CallFunc:create(function()
			tianwang:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			wanjia:setRotationSkewY(180)
			self:WaitToDialog(0.2)
		end)

		tianwang:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tianwang, fennu)

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

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
