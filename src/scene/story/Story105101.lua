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


	local niu_skins = {
		["Arm"] = 1008,
		["Hat"] = 1079,
		["Coat"] = 1054,
	}
    local niumowang = self:CreatePerson(SCREEN_WIDTH-400, 200, 1016, niu_skins)
	niumowang:setRotationSkewY(180)

    local wanjia = self:CreatePerson(400, 200, GameCache.Avatar.Figure)

	--local jianxiao = self:CreateEmoji("dummy/jianxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_niumowang = self:CreateIcon(1016, niu_skins)

	--local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		--{icon = icon_wanjia, person = wanjia, speak = GameCache.Avatar.Name .."", msg = "牛老大，你这“洞府”的装潢都过时了吧，咋也不翻新一下呢？"},
		{icon = icon_niumowang, dir = 2, speak = "牛魔王", msg = "嘘，小声点，快到了，别让那娘们儿发现了咱…"},

    }


    self:AddInitEndEvent(function (  )
		niumowang:setVisible(true)
		wanjia:setVisible(true)

		niumowang:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)

        --local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-350,200))
		--local go1 = cc.MoveTo:create(3, cc.p(350,200))

		--local event = cc.CallFunc:create(function()
			--niumowang:setAnimation(0, "idle", true)
			--niumowang:setRotationSkewY(180)
			--wanjia:setAnimation(0, "idle", true)

			--self:WaitToDialog(0.2)
		--end)

		--niumowang:runAction(go)
        --wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			niumowang:setRotationSkewY(0)
			niumowang:setAnimation(0, "move", true)
			wanjia:setAnimation(0, "move", true)

			local go = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+200,200))
			local go1 = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH+200,200))
			local event = cc.CallFunc:create(function()
				self:StoryEnd()
			end)

			niumowang:runAction(go)
			wanjia:runAction(cc.Sequence:create({go1,event}))

			--self:WaitToDialog(0.5)
			--self:Emoji(niumowang, jianxiao)


		--elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)
            --niumowang:setAnimation(1, "atk_ko", false)
            --niumowang:setAnimation(0, "idle", true)


		--elseif hua == self.message[4].msg then


		--elseif hua == self.message[5].msg then

            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
