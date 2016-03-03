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
    local zhubajie = self:CreatePerson(480, 200, 1027, bajie_skins)

    local wanjia = self:CreatePerson(180, 200, GameCache.Avatar.Figure)

	local dashou_skins = {
		["Arm"] = 0,
		["Hat"] = 0,
		["Coat"] = 0,
	}
    local dashou = self:CreateMonster(SCREEN_WIDTH, 200, "gw_dipi2")
    dashou:setRotationSkewY(180)

    local han = self:CreateEmoji("dummy/han.png")

	local deyi = self:CreateEmoji("dummy/deyi.png")



    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_dashou = self:CreateMonsterIcon("gw_dipi2")



    self.message = {
        {icon = icon_dashou, dir = 2, speak = "打手",msg = "此路是我开，此树是我栽，要从此路过，留下买路财！"},
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "亲！21世纪了，创新在哪里？！"},


    }


    self:AddInitEndEvent(function (  )
        zhubajie:setVisible(true)
        wanjia:setVisible(true)

        dashou:setVisible(true)
        dashou:setAnimation(0, "move", true)

        local go = cc.MoveBy:create(1, cc.p(-250,0))

        local event = cc.CallFunc:create(function()
            dashou:setAnimation(0, "idle", true)
            self:Emoji(dashou, deyi)
            self:WaitToDialog(0.2)
        end)

        dashou:runAction(cc.Sequence:create({go, event}))

		-- self:WaitToDialog(0.2)

    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
            self:Emoji(wanjia, han)
            self:WaitToDialog(0.2)

        elseif hua == self.message[2].msg then


        -- elseif hua == self.message[3].msg then
        --     self:Emoji(wanjia, han)
        --     self:WaitToDialog(0.2)


        -- elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



    self:StoryBegin()

end



return Story
