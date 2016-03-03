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


    local bajie_skins = {
        ["Arm"] = 1006,
        ["Hat"] = 1093,
        ["Coat"] = 0,
    }
    local zhubajie = self:CreatePerson(380, 200, 1027, bajie_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

    local tai2_skins = {
        ["Arm"] = 1026,
        ["Hat"] = 0,
        ["Coat"] = 1065,
    }
    local taibingzhenren = self:CreatePerson(SCREEN_WIDTH-250, 200, 1034, tai2_skins)
    taibingzhenren:setRotationSkewY(180)

	local kelian = self:CreateEmoji("dummy/kelian.png")

    local xu = self:CreateEmoji("dummy/xu.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_taibingzhenren = self:CreateIcon(1034, tai2_skins)


    self.message = {
        {icon = icon_taibingzhenren, dir = 2, speak = "太丙真人", msg = "做人留一面，日后好想见！这位先森，您又如何如此咄咄逼人呢？"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "你制假药坑害消费者，俺打你那是你活该！"},
        {icon = icon_taibingzhenren, dir = 2, speak = "太丙真人", msg = "兄弟你开个价，这事儿咱们私了吧！"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "呸你个山寨货，跟老子到派出所去！"},

    }


    self:AddInitEndEvent(function (  )

    	zhubajie:setVisible(true)
    	wanjia:setVisible(true)
		taibingzhenren:setVisible(true)


		zhubajie:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		taibingzhenren:setAnimation(0,"idle", true)

		self:Emoji(taibingzhenren, kelian)
		self:WaitToDialog(0.2)

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

        elseif hua == self.message[2].msg then
            self:WaitToDialog(0.2)
            self:Emoji(taibingzhenren, xu)

        elseif hua == self.message[3].msg then
            self:WaitToDialog(0.2)
            zhubajie:setAnimation(1, "atk3", false)
            zhubajie:setAnimation(0, "idle", true)

        elseif hua == self.message[4].msg then    
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
