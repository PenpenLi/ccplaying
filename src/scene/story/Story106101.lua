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

	local bishi = self:CreateEmoji("dummy/bishi.png")
	local se = self:CreateEmoji("dummy/se.png")

    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_leizhenzi = self:CreateIcon(1048, lei_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_leizhenzi,dir = 2, speak = "雷震子", msg = "前面有个洞！要不要进去看看…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "控制一下你的表情，太猥琐了！"},
    }


    self:AddInitEndEvent(function (  )
		leizhenzi:setVisible(true)
		wanjia:setVisible(true)

		leizhenzi:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)

        --self:Emoji(leizhenzi, daku)
		--self:WaitToDialog(0.5)

        local go = cc.MoveTo:create(3, cc.p(500,200))
		local go1 = cc.MoveTo:create(3, cc.p(350,200))

		local event = cc.CallFunc:create(function()
			wanjia:setAnimation(0, "idle", true)
            --leizhenzi:setAnimation(1, "atk_ko", false)
            leizhenzi:setAnimation(0, "idle", true)
            self:Emoji(leizhenzi, se)
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
			self:Emoji(wanjia, bishi)

		elseif hua == self.message[2].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
