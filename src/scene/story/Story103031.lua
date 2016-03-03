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
    local tangseng = self:CreatePerson(SCREEN_WIDTH*0.5+180, 200, 1026, tangseng_skins)
	tangseng:setRotationSkewY(180)

    local wanjia = self:CreatePerson(SCREEN_WIDTH*0.5-170, 200, GameCache.Avatar.Figure)

	local jingdai = self:CreateEmoji("dummy/jingdai.png")

	local han = self:CreateEmoji("dummy/han.png")

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local zhuakuang = self:CreateEmoji("dummy/zhuakuang.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_tangseng = self:CreateIcon(1026, tangseng_skins)


	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)




    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "这尼玛强制降温简直是要人命呀，我被冻得都快掉渣了！唐Boss，咱们现在该肿么办呀？"},
		{icon = icon_tangseng, dir = 2, speak = "唐僧", msg = "我们先去看看我儿子怎么了…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "什么！！！你儿子！！！"},
		{icon = icon_tangseng, dir = 2, speak = "唐僧", msg = "对呀，“My sun”，呆梨不是有首民歌就是这么唱的么?"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "你的英语老师已经哭晕在厕所…"},


    }


    self:AddInitEndEvent(function (  )

    	tangseng:setVisible(true)
    	wanjia:setVisible(true)

    	tangseng:setAnimation(0, "idle", true)
    	wanjia:setAnimation(0, "idle", true)

		self:WaitToDialog(0.2)
		self:Emoji(wanjia, zhuakuang)
    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)


        elseif hua == self.message[2].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, jingdai)


        elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(tangseng, yiwen)


        elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, han)


        elseif hua == self.message[5].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
