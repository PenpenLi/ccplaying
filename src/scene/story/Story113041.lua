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


    local bajie_skins = {
        ["Arm"] = 1006,
        ["Hat"] = 1093,
        ["Coat"] = 0,
    }
    local zhubajie = self:CreatePerson(SCREEN_WIDTH*0.5+180, 200, 1027, bajie_skins)
	zhubajie:setRotationSkewY(180)

    local wanjia = self:CreatePerson(SCREEN_WIDTH*0.5-170, 200, GameCache.Avatar.Figure)

	local qiaoda = self:CreateEmoji("dummy/qiaoda.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)




    self.message = {
        {icon = icon_zhubajie, dir = 2, speak = "猪八戒", msg = "哇塞，你看前方那是人山人海、旌旗舞动、锣鼓喧天呐！"},
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "说人话！"},
        {icon = icon_zhubajie, dir = 2, speak = "猪八戒",msg = "目测前面有怪…"},

    }


    self:AddInitEndEvent(function (  )
        zhubajie:setVisible(true)
        wanjia:setVisible(true)

		zhubajie:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)

        self:WaitToDialog(0.2)
    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
            self:WaitToDialog(0.2)
			self:Emoji(wanjia, qiaoda)

        elseif hua == self.message[2].msg then
            self:WaitToDialog(0.2)

        elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)



	self:StoryBegin()

end



return Story
