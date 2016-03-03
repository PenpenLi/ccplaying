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


    --local erye = self:CreatePerson(SCREEN_WIDTH-400, 200, 1015)
	--erye:setRotationSkewY(180)

    local wanjia = self:CreatePerson(SCREEN_WIDTH-600, 200, GameCache.Avatar.Figure)

	local cahan = self:CreateEmoji("dummy/cahan.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    --local icon_erye = self:CreateIcon(1015)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "坑爹了，忘了找二爷要二郎神的电话号码了…"},
		--{icon = icon_erye,dir = 2, speak = "关圣帝君", msg = "不要把你的内心读白随便说出来，会尴尬的！"},
    }


    self:AddInitEndEvent(function (  )
		--erye:setVisible(true)
		wanjia:setVisible(true)

		--erye:setAnimation(0, "idle", true)





		self:Emoji(wanjia, cahan)
		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)
			wanjia:setAnimation(0, "move", true)
			local go = cc.MoveTo:create(2.6, cc.p(SCREEN_WIDTH+200,200))

			local event = cc.CallFunc:create(function()

				self:StoryEnd()
			end)

			wanjia:runAction(cc.Sequence:create({go,event}))
		--elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[6].msg then

        end
    end)


	self:StoryBegin()

end


return Story
