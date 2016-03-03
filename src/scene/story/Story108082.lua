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
        ["Hat"] = 1090,
        ["Coat"] = 1068,
    }
    local sunwukong = self:CreatePerson(-180, 200, 1018, wukong_skins)

    local wanjia = self:CreatePerson(-380, 200, GameCache.Avatar.Figure)

    local she_skins = {
        ["Arm"] = 1025,
        ["Hat"] = 1089,
        ["Coat"] = 0,
    }
    local shejing = self:CreatePerson(SCREEN_WIDTH-180, 300, 1044, she_skins)
    --shejing:setRotationSkewY(180)

    local hu_skins = {
        ["Arm"] = 1041,
        ["Hat"] = 1090,
        ["Coat"] = 0,
    }
    local huyao = self:CreatePerson(SCREEN_WIDTH-220, 150, 1036, hu_skins)
    --huyao:setRotationSkewY(180)

	local zhuakuang = self:CreateEmoji("dummy/zhuakuang.png")


    --

    -- 2\
    Story.super.ctor(self, callback)


    -- 3\


    local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

    local icon_huyao = self:CreateIcon(1036, hu_skins)


    self.message = {
        {icon = icon_huyao, dir = 2, speak = "狐妖姐姐", msg = "妹妹快逃，我们去找皇阿玛来帮忙！"},
        {icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."",msg = "这“皇阿玛”又是闹的哪出呀…你麻痹演清宫穿越剧呐你！"},
    }


    self:AddInitEndEvent(function (  )
        sunwukong:setVisible(true)
        wanjia:setVisible(true)
        huyao:setVisible(true)
		shejing:setVisible(true)


		sunwukong:setAnimation(0, "idle", true)
		wanjia:setAnimation(0, "idle", true)
		huyao:setAnimation(0, "move", true)
		shejing:setAnimation(0, "move", true)


        self:WaitToDialog(0.2)


        local go = cc.MoveBy:create(1.5, cc.p(400,0))
		local go1 = cc.MoveBy:create(1.5, cc.p(400,0))

        huyao:runAction(go)
		shejing:runAction(go1)

        sunwukong:setAnimation(0, "move", true)
        wanjia:setAnimation(0, "move", true)

        local go2 = cc.MoveTo:create(2, cc.p(380,200))
        local go3 = cc.MoveTo:create(2, cc.p(180,200))

        local event = cc.CallFunc:create(function()
            sunwukong:setAnimation(0, "idle", true)
            wanjia:setAnimation(0, "idle", true)
            --self:WaitToDialog(0.2)
        end)

        sunwukong:runAction(go2)
        wanjia:runAction(cc.Sequence:create(go3,event))



    end)

    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)
			self:Emoji(wanjia, zhuakuang)



        elseif hua == self.message[2].msg then
            self:StoryEnd()
        end
    end)



    self:StoryBegin()

end



return Story
