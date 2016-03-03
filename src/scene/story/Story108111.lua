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


	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 1068,
	}
    local sunwukong = self:CreatePerson(-150, 200, 1018, wukong_skins)

	local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	local se = self:CreateEmoji("dummy/se.png")

	local cahan = self:CreateEmoji("dummy/cahan.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\


	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_sunwukong = self:CreateIcon(1018, wukong_skins)




    self.message = {
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "怎么感觉好像刚举行完一场轰趴一样…"},
		{icon = icon_sunwukong, dir = 2, speak = "孙悟空", msg = "这生活作风也太不矜持了吧，嘿嘿嘿，不过我喜欢！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "老孙…注意口水，要滴下来了…"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)

		sunwukong:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		--self:WaitToDialog(0.2)

        local go = cc.MoveTo:create(2, cc.p(440,200))
		local go1 = cc.MoveTo:create(2, cc.p(240,200))

			local event = cc.CallFunc:create(function()
				sunwukong:setAnimation(0, "idle", true)
				wanjia:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
			end)

        sunwukong:runAction(go)
		wanjia:runAction(cc.Sequence:create({go1,event}))


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, se)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, cahan)


		elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
