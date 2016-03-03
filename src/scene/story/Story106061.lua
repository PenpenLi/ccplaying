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


	local lei_skins = {
		["Arm"] = 1010,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local leizhenzi = self:CreatePerson(-200, 200, 1048, lei_skins)

    local wanjia = self:CreatePerson(-350, 200, GameCache.Avatar.Figure)

	--local qianliyan = self:CreatePerson(SCREEN_WIDTH-350, 200, 1053)
	--qianliyan:setRotationSkewY(180)

	--local deyi = self:CreateEmoji("dummy/deyi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_leizhenzi,dir = 2, speak = "雷震子", msg = "这里除了沙子就只有俩傻子，谁特么那么缺心眼会在这里开公司呀！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "再找找看吧…"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)

		leizhenzi:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

        --self:Emoji(leizhenzi, daku)
		--self:WaitToDialog(0.5)

        local go = cc.MoveTo:create(2.5, cc.p(450,200))
		local go1 = cc.MoveTo:create(2.5, cc.p(300,200))

		local event = cc.CallFunc:create(function()
            leizhenzi:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			leizhenzi:setRotationSkewY(180)
            --leizhenzi:setAnimation(1, "atk_ko", false)
            --leizhenzi:setAnimation(0, "idle", true)
			self:WaitToDialog(0.5)
		end)

		leizhenzi:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.5)
			--qianliyan:setRotationSkewY(180)

		elseif hua == self.message[2].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[3].msg then
			--self:WaitToDialog(0.5)

		--elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)
			--self:Emoji(qianliyan, deyi)

		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)
            --qianliyan:setAnimation(1, "atk_ko", false)
            --qianliyan:setAnimation(0, "idle", true)
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
