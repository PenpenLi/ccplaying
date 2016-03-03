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
	local zhubajie = self:CreatePerson(-200, 200, 1027, bajie_skins)

    local wanjia = self:CreatePerson(-400, 200, GameCache.Avatar.Figure)

    local bai_skins = {
        ["Arm"] = 0,
        ["Hat"] = 1082,
        ["Coat"] = 1064,
    }
    local shoujingjing = self:CreatePerson(SCREEN_WIDTH-400, 200, 1035, bai_skins)
    shoujingjing:setRotationSkewY(180)


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\



    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_shoujingjing = self:CreateIcon(1035, bai_skins)

	local yiwen = self:CreateEmoji("dummy/yiwen.png")

	local yun = self:CreateEmoji("dummy/yun.png")


    self.message = {
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精", msg = "我在这里！"},
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精",msg = "你来追我呀，来追我呀，追我呀，我呀，呀…"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "俺们这是到哪里了呀？"},
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "都说叫你不要乱跑了，现在我哪儿知道呀！"}

    }


    self:AddInitEndEvent(function (  )
        zhubajie:setVisible(true)
        wanjia:setVisible(true)
        shoujingjing:setVisible(true)

        self:WaitToDialog(0.2)
    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
            self:WaitToDialog(0.1)

            shoujingjing:setRotationSkewY(0)
            shoujingjing:setAnimation(0,"move", true)

            local go = cc.MoveBy:create(3, cc.p(600,0))

            shoujingjing:runAction(cc.Sequence:create({go}))


            zhubajie:setAnimation(0,"move", true)
            wanjia:setAnimation(0,"move", true)

            local event = cc.CallFunc:create(function()

                    zhubajie:setAnimation(0,"idle", true)
                    wanjia:setAnimation(0,"idle", true)
                    self:WaitToDialog(0.2)
            end)

            local go1 = cc.MoveTo:create(2.2, cc.p(400,200))

            local go2 = cc.MoveTo:create(2.2, cc.p(200,200))

            zhubajie:runAction(go1)
            wanjia:runAction(cc.Sequence:create({go2,event}))


        elseif hua == self.message[2].msg then
            self:WaitToDialog(0.2)
			
			self:Emoji(zhubajie, yiwen)


        elseif hua == self.message[3].msg then
            self:WaitToDialog(0.2)
			self:Emoji(wanjia, yun)
            zhubajie:setRotationSkewY(180)


        elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



    self:StoryBegin()

end



return Story
