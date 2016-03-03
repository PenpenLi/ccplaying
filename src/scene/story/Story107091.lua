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


	local xu_skins = {
		["Arm"] = 1043,
		["Hat"] = 1090,
		["Coat"] = 1071,
	}
    local xuxian = self:CreatePerson(-150, 200, 1043, xu_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	local mentu_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 1071,
	}
    local mentu = self:CreatePerson(SCREEN_WIDTH-260, 200, 1026, mentu_skins)
	mentu:setRotationSkewY(180)

	local deyi = self:CreateEmoji("dummy/deyi.png")

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_mentu = self:CreateIcon(1026, mentu_skins)


    self.message = {
		{icon = icon_mentu,dir = 2, speak = "法海门徒", msg = "大师有令，活捉许仙者重重有赏！"},
		--{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "什么情况，从实招来！"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "法海怎知我来了？"},
		{icon = icon_mentu,dir = 2, speak = "法海门徒", msg = "你不管嘛！"},

    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)
		mentu:setVisible(true)

		xuxian:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		mentu:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(2, cc.p(400,200))
		local go1 = cc.MoveTo:create(2, cc.p(200,200))
        local event = cc.CallFunc:create(function()
            xuxian:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			mentu:setAnimation(1, "atk1", false)
			mentu:setAnimation(0, "idle", true)
			self:Emoji(mentu, deyi)
			self:WaitToDialog(0.2)
        end)
        xuxian:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(xuxian, jingdai)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(mentu, koubi)

		elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
