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


	local er_skins = {
		["Arm"] = 1007,
		["Hat"] = 0,
		["Coat"] = 1054,
	}
    local erlangshen = self:CreatePerson(SCREEN_WIDTH-350, 200, 1019, er_skins)
	erlangshen:setRotationSkewY(180)

    local wanjia = self:CreatePerson(360, 200, GameCache.Avatar.Figure)

	local han = self:CreateEmoji("dummy/han.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_erlangshen = self:CreateIcon(1019, er_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = GameCache.Avatar.Name .. "，给我说说，那个黄鹤怎么了？"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "嗯…说是开了个皮革厂，然后吃喝嫖赌欠了3.5个亿，最后带着他的小姨子跑了…"},
		{icon = icon_erlangshen, dir = 2, speak = "二郎神", msg = "哦…带着小姨子跑了，还算是有情有义的一个人。"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "我觉得你focus的点好像有点奇怪嘞…"},
    }


    self:AddInitEndEvent(function (  )
		erlangshen:setVisible(true)
		wanjia:setVisible(true)

		erlangshen:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		--local go = cc.MoveTo:create(2, cc.p(350,200))

		--local event = cc.CallFunc:create(function()
			--wanjia:setAnimation(0, "idle", true)
			--self:WaitToDialog(0.2)
		--end)

		--wanjia:runAction(cc.Sequence:create({go,event}))

		self:WaitToDialog(0.2)

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, han)

		elseif hua == self.message[4].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[5].msg then
			--self:WaitToDialog(0.5)


		--elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
