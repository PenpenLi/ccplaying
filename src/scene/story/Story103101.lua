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
    local tangseng = self:CreatePerson(-150, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

    local qinqin = self:CreateEmoji("dummy/qinqin.png")

    local koubi = self:CreateEmoji("dummy/koubi.png")


    --

    -- 2\
    Story.super.ctor(self, callback)


    -- 3\


    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "哇，前面好像就是凌霄宝殿了，人生第一次来呀，好紧张呀！"},
		{icon = icon_tangseng, dir = 2, speak = "唐僧", msg = "年轻人，要学会淡定，蛋定…"},
    }


    self:AddInitEndEvent(function (  )
		tangseng:setVisible(true)
		wanjia:setVisible(true)

		tangseng:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		--self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(2.1, cc.p(500,200))
		local go1 = cc.MoveTo:create(2.1, cc.p(300,200))

		local event = cc.CallFunc:create(function()
			tangseng:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:Emoji(wanjia, qinqin)
			self:WaitToDialog(0.2)
		end)

        tangseng:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			tangseng:setRotationSkewY(180)
			self:Emoji(tangseng, koubi)

		elseif hua == self.message[2].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
