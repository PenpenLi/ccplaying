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
    local zhubajie = self:CreatePerson(380, 200, 1027, bajie_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local dashou_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local dashou = self:CreateMonster(SCREEN_WIDTH, 200, "gw_shitouren")
    dashou:setRotationSkewY(180)

    local fennu = self:CreateEmoji("dummy/fennu.png")

    local fennu1 = self:CreateEmoji("dummy/fennu.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_dashou = self:CreateMonsterIcon("gw_shitouren")



    self.message = {
        {icon = icon_dashou, dir = 2, speak = "打手", msg = "此路是我开，此树…"},
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "麻痹呀！闹够了没？"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "打死你丫的！"},

    }


    self:AddInitEndEvent(function (  )

    	zhubajie:setVisible(true)
    	wanjia:setVisible(true)
		dashou:setVisible(true)


		zhubajie:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		dashou:setAnimation(0,"move", true)
            local go = cc.MoveBy:create(1, cc.p(-250,0))

            local event = cc.CallFunc:create(function()
                dashou:setAnimation(0, "idle", true)
				self:WaitToDialog(0.2)
            end)

            dashou:runAction(cc.Sequence:create({go,event}))

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
            self:Emoji(wanjia, fennu)
            self:WaitToDialog(0.2)


        elseif hua == self.message[2].msg then
            self:Emoji(zhubajie, fennu1)
            self:WaitToDialog(0.2)
			zhubajie:setAnimation(1, "atk1", false)
			zhubajie:setAnimation(0, "idle", true)


        elseif hua == self.message[3].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end



return Story
