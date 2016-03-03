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


	local huang_skins = {
		["Arm"] = 0,
		["Hat"] = 1094,
		["Coat"] = 1067,
	}
	local huanghe = self:CreatePerson(SCREEN_WIDTH-380, 200, 1043, huang_skins)
	huanghe:setRotationSkewY(180)

	local jianxiao = self:CreateEmoji("dummy/jianxiao.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    --local icon_erye = self:CreateIcon(1015)

	--local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_huanghe = self:CreateIcon(1043, huang_skins)


    self.message = {
		{icon = icon_huanghe,dir = 2, speak = "黄鹤", msg = "嘿嘿，傻x们，爷爷我从密道走啦，掰掰~"},
    }


    self:AddInitEndEvent(function (  )
		huanghe:setVisible(true)

		huanghe:setAnimation(0, "idle", true)

		self:Emoji(huanghe, jianxiao)

		self:WaitToDialog(0.2)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			--self:WaitToDialog(0.5)
			huanghe:setAnimation(0, "move", true)
			huanghe:setRotationSkewY(0)

			local go = cc.MoveTo:create(1.8, cc.p(SCREEN_WIDTH+200,200))

			local event = cc.CallFunc:create(function()
				self:StoryEnd()
			end)

			huanghe:runAction(cc.Sequence:create({go,event}))


		--elseif hua == self.message[2].msg then
            --self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
