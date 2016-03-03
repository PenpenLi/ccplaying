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


	local wukong_skins = {
		["Arm"] = 1003,
		["Hat"] = 1090,
		["Coat"] = 1068,
	}
    local sunwukong = self:CreatePerson(350, 200, 1018, wukong_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local she_skins = {
		["Arm"] = 1025,
		["Hat"] = 1089,
		["Coat"] = 0,
	}
    local shejing = self:CreatePerson(SCREEN_WIDTH-180, 300, 1044, she_skins)
    shejing:setRotationSkewY(180)

	local hu_skins = {
		["Arm"] = 1041,
		["Hat"] = 1090,
		["Coat"] = 0,
	}
    local huyao = self:CreatePerson(SCREEN_WIDTH-220, 150, 1036, hu_skins)
    huyao:setRotationSkewY(180)

	local fennu = self:CreateEmoji("dummy/fennu.png")

	local tushe = self:CreateEmoji("dummy/tushe.png")

	local jianxiao = self:CreateEmoji("dummy/jianxiao.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_sunwukong = self:CreateIcon(1018, wukong_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_shejing = self:CreateIcon(1044, she_skins)

    local icon_huyao = self:CreateIcon(1036, hu_skins)



    self.message = {
        {icon = icon_sunwukong, dir = 1, speak = "孙悟空", msg = "妈蛋，你爷爷我纵横相亲界数千年，今天居然遇上了你们这两个不要脸的饭托！"},
        {icon = icon_huyao, dir = 2, speak = "狐妖姐姐", msg = "呸，瞧你长得那个猴子样儿，没钱还好意思来相亲！"},
		{icon = icon_shejing, dir = 2, speak = "蛇精妹妹", msg = "我看你还是早点回家继续当互撸娃吧！姐姐，我们走…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "天空一声巨响，老子闪亮登场！猴哥，我来帮你！"}


    }


    self:AddInitEndEvent(function (  )

    	sunwukong:setVisible(true)
    	-- wanjia:setVisible(true)
		shejing:setVisible(true)
		huyao:setVisible(true)


    	sunwukong:setAnimation(0, "idle", true)
    	-- wanjia:setAnimation(0, "idle", true)
		shejing:setAnimation(0, "idle", true)
		huyao:setAnimation(0, "idle", true)

		self:Emoji(sunwukong, fennu)
		self:WaitToDialog(0.2)


    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(huyao, tushe)


        elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(shejing, jianxiao)


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.1)
			shejing:setRotationSkewY(0)
			huyao:setRotationSkewY(0)
			self:Emoji(wanjia, fennu)

			shejing:setAnimation(0,"move", true)
			huyao:setAnimation(0,"move", true)

			local go = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+180,150))
			local go1 = cc.MoveTo:create(1.5, cc.p(SCREEN_WIDTH+220,300))

			shejing:runAction(go1)
			huyao:runAction(go)


			self:CreateEffect(wanjia:getPositionX(), wanjia:getPositionY()+100, 19)

			local delay = cc.DelayTime:create(2.0)
			local event = cc.CallFunc:create(function ( )
				wanjia:setVisible(true)
				wanjia:addAnimation(1, "atk_ko", false)
				wanjia:addAnimation(0, "idle", true)
				self:WaitToDialog(0.8)
			end)

			self:runAction(cc.Sequence:create({delay,event}))


		elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
