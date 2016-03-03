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
		["Hat"] = 1077,
		["Coat"] = 1053,
	}
    local sunwukong = self:CreatePerson(SCREEN_WIDTH-400, 200, 1018, wukong_skins)
	sunwukong:setRotationSkewY(180)

    local wanjia = self:CreatePerson(400, 200, GameCache.Avatar.Figure)

	local jianxiao = self:CreateEmoji("dummy/jianxiao.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local deyi = self:CreateEmoji("dummy/deyi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)


    self.message = {
		{icon = icon_sunwukong, dir = 2, speak = "孙悟空", msg = "我最近听说了有个法宝能让渣男一秒变型男，丑女一秒变女神！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "我知道个软件好像也可以…"},
		{icon = icon_sunwukong,dir = 2, speak = "孙悟空", msg = "次奥，说正经的！如果我们找到了这个法宝，再给八戒一用，嘿嘿，那个赔钱货和嫦娥妹妹就有希望了！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "那么现在问题来了…"},
		{icon = icon_sunwukong,dir = 2, speak = "孙悟空", msg = "宝贝收藏哪家强，东海龙宫找龙王！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "走你~"},
    }


    self:AddInitEndEvent(function (  )
		sunwukong:setVisible(true)
		wanjia:setVisible(true)

		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

		self:Emoji(sunwukong, deyi)

		self:WaitToDialog(0.2)

        --local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))

		--local event = cc.CallFunc:create(function()
            --sunwukong:setAnimation(0, "idle", true)
            --sunwukong:setAnimation(1, "atk_ko", false)
            --sunwukong:setAnimation(0, "idle", true)
			--self:WaitToDialog(0.2)
		--end)

		--niumowang:runAction(go)
        --sunwukong:runAction(cc.Sequence:create({go,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, koubi)


		elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, fennu)
            sunwukong:setAnimation(1, "atk1", false)
            sunwukong:setAnimation(0, "idle", true)


		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)


		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(sunwukong, jianxiao)

		elseif hua == self.message[5].msg then

			sunwukong:setRotationSkewY(0)
			wanjia:setAnimation(0, "move", true)
			sunwukong:setAnimation(0, "move", true)
			local go1 = cc.MoveTo:create(2, cc.p(SCREEN_WIDTH+250,200))
			local go2 = cc.MoveTo:create(2.5, cc.p(SCREEN_WIDTH+150,200))

			local event = cc.CallFunc:create(function()  self:StoryEnd() end)
			sunwukong:runAction(cc.Sequence:create( go1, event ))
			wanjia:runAction(go2)
			self:WaitToDialog(0.2)


		elseif hua == self.message[6].msg then

        end
    end)


	self:StoryBegin()

end


return Story
