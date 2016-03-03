--
-- Author: Kamirotto
-- Date: 2015-04-24 15:18:47
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
    local tangseng = self:CreatePerson(350, 200, 1026, tangseng_skins)

    local wanjia = self:CreatePerson(200, 200, GameCache.Avatar.Figure)

	local xuanbingniao = self:CreateMonster(SCREEN_WIDTH+300, 200, "bs_xuanbingniao")
	xuanbingniao:setRotationSkewY(180)


	local han = self:CreateEmoji("dummy/han.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)


	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


	local icon_xuanbingniao = self:CreateMonsterIcon("bs_xuanbingniao")




    self.message = {
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "儿子呀…你在哪儿？"},
		{icon = icon_xuanbingniao, dir = 2, speak = "玄冰鸟", msg = "小日日被王母娘娘请到天庭去喝茶了，现在这里伦家说了算，你们就叫窝小冰冰吧。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "你不卖萌咱们还能做朋友…"},


    }


    self:AddInitEndEvent(function (  )

    	tangseng:setVisible(true)
    	wanjia:setVisible(true)
		xuanbingniao:setVisible(true)


    	tangseng:setAnimation(0, "idle", true)
    	wanjia:setAnimation(0, "idle", true)
		xuanbingniao:setAnimation(0, "idle", true)
self:WaitToDialog(0.5)

		--local go = cc.MoveTo:create(2, cc.p(350,200))
		--local go1 = cc.MoveTo:create(2, cc.p(200,200))

		--local event = cc.CallFunc:create(function()
		--	tangseng:setAnimation(0, "idle", true)
		--	wanjia:setAnimation(0, "idle", true)
		--	self:WaitToDialog(0.5)
		--end)

		--tangseng:runAction(go)
		--wanjia:runAction(cc.Sequence:create({go1,event}))


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.5)
			
			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH-350,200))
--            local delay = cc.DelayTime:create(1)
			local event = cc.CallFunc:create(function()
				xuanbingniao:setAnimation(0, "idle", true)
--				self:WaitToDialog(0.5)
			end)

            xuanbingniao:runAction(cc.Sequence:create({go,delay,event}))


        elseif hua == self.message[2].msg then
			self:WaitToDialog(0.5)
			self:Emoji(wanjia, han)


		elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
