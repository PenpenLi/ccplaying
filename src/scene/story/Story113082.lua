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

    local bai_skins = {
        ["Arm"] = 0,
        ["Hat"] = 1082,
        ["Coat"] = 1064,
    }
    local shoujingjing = self:CreatePerson(SCREEN_WIDTH-400, 200, 1035, bai_skins)
    shoujingjing:setRotationSkewY(180)

    local haixiu = self:CreateEmoji("dummy/haixiu.png")

    local jingdai = self:CreateEmoji("dummy/jingdai.png")

    local fennu = self:CreateEmoji("dummy/fennu.png")

    local zhuakuang = self:CreateEmoji("dummy/zhuakuang.png")


    --

    -- 2\
    Story.super.ctor(self, callback)



    -- 3\


    local icon_zhubajie = self:CreateIcon(1027, bajie_skins)

    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_shoujingjing = self:CreateIcon(1035, bai_skins)


    self.message = {
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精", msg = "擦，真Niubility！赶紧溜…"},
        {icon = icon_zhubajie, dir = 1, speak = "猪八戒",msg = "死妖怪站住，老子要追你到天涯海角！"},
        {icon = icon_shoujingjing, dir = 2, speak = "瘦精精",msg = "追我？你这算是在对我表白吗？"},
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "你脸红个屁呀！"}
    }


    self:AddInitEndEvent(function (  )
        zhubajie:setVisible(true)
        wanjia:setVisible(true)
        shoujingjing:setVisible(true)

        zhubajie:setAnimation(0, "idle", true)
        wanjia:setAnimation(0, "idle", true)
        shoujingjing:setAnimation(0,"idle", true)

		self:Emoji(shoujingjing, jingdai)
        self:WaitToDialog(0.2)
    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
            shoujingjing:setRotationSkewY(0)
            shoujingjing:setAnimation(0,"move", true)

            local go = cc.MoveBy:create(1, cc.p(250,0))
            self:WaitToDialog(0)
            local event = cc.CallFunc:create(function()
                shoujingjing:setRotationSkewY(180)
                shoujingjing:setAnimation(0,"idle", true)
                self:Emoji(zhubajie, fennu)
            end)

            shoujingjing:runAction(cc.Sequence:create({go,event}))


        elseif hua == self.message[2].msg then
            self:WaitToDialog(0.2)
			self:Emoji(shoujingjing, haixiu)


        elseif hua == self.message[3].msg then
            shoujingjing:setRotationSkewY(0)
            shoujingjing:setAnimation(0,"move", true)

            local go = cc.MoveBy:create(1, cc.p(250,0))

            self:WaitToDialog(0.2)

            local event = cc.CallFunc:create(function()
                shoujingjing:setRotationSkewY(180)
                shoujingjing:setAnimation(0,"idle", true)
                self:Emoji(wanjia, zhuakuang)
            end)

            shoujingjing:runAction(cc.Sequence:create({go,event}))


        elseif hua == self.message[4].msg then
            self:StoryEnd()
        end
    end)



    self:StoryBegin()

end



return Story
