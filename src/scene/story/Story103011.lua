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
    local tangseng = self:CreatePerson(SCREEN_WIDTH-450, 200, 1026, tangseng_skins)
	tangseng:setRotationSkewY(180)

    local wanjia = self:CreatePerson(350, 200, GameCache.Avatar.Figure)

	local shouxing_skins = {
		["Arm"] = 1044,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local shouxing = self:CreatePerson(SCREEN_WIDTH-250, 200, 1055, shouxing_skins)
    shouxing:setRotationSkewY(180)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local heixian = self:CreateEmoji("dummy/heixian.png")

	local se = self:CreateEmoji("dummy/se.png")

	local fennu = self:CreateEmoji("dummy/fennu.png")

    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_shouxing = self:CreateIcon(1055, shouxing_skins)


    self.message = {
        {icon = icon_tangseng, dir = 2, speak = "唐僧", msg = "穿迷你裙的菇凉们最可爱了，夏天果然是个让人热血沸腾的季节呀！"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "喂喂，破色戒咯喂…"},
		{icon = icon_shouxing, dir = 2, speak = "寿星公", msg = "小唐呀，不得了了呀！"},
		{icon = icon_shouxing, dir = 2, speak = "寿星公", msg = "上面的人说妹纸穿短裙会影响小盆友们的成长，所以王母宣布说不准人间着装过于暴露，还要强制降温！你快去劝劝呀…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "这还有没有天理啦…等等，唐总，为什么要你去劝？"},
		{icon = icon_tangseng, dir = 1, speak = "唐僧", msg = "正所谓我不入地狱谁入地狱！寿寿你放心，这事儿就交给贫僧吧！"},


    }


    self:AddInitEndEvent(function (  )

    	tangseng:setVisible(true)
    	wanjia:setVisible(true)

    	tangseng:setAnimation(0, "idle", true)
    	wanjia:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)
		self:Emoji(tangseng, se)
    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, heixian)


        elseif hua == self.message[2].msg then
			local event_texiao = cc.CallFunc:create(function()
				self:CreateEffect(shouxing:getPositionX(), shouxing:getPositionY(), 8)
			end)

			local delay = cc.DelayTime:create(0.3)

			local event_chuxian = cc.CallFunc:create(function()
				shouxing:setVisible(true)
				self:WaitToDialog(0.2)
			end)

			self:runAction(cc.Sequence:create(event_texiao, delay, event_chuxian))


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			tangseng:setRotationSkewY(0)


        elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, jingdai)


        elseif hua == self.message[5].msg then
            self:WaitToDialog(0.2)
			self:Emoji(tangseng, fennu)
			tangseng:setAnimation(1, "atk_ko", false)
			tangseng:setAnimation(0, "idle", true)


		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
