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


	local xu_skins = {
		["Arm"] = 1043,
		["Hat"] = 1090,
		["Coat"] = 1071,
	}
    local xuxian = self:CreatePerson(-200, 200, 1043, xu_skins)

    local wanjia = self:CreatePerson(-400, 200, GameCache.Avatar.Figure)

	local bao_skins = {
		["Arm"] = 1008,
		["Hat"] = 1096,
		["Coat"] = 1068,
	}
	local baogongtou = self:CreatePerson(SCREEN_WIDTH-260, 200, 1049, bao_skins)
	baogongtou:setRotationSkewY(180)

	local long_skins = {
		["Arm"] = 1015,
		["Hat"] = 0,
		["Coat"] = 1068,
	}
	local longwang = self:CreatePerson(SCREEN_WIDTH-260, 200, 1032, long_skins)
	longwang:setRotationSkewY(180)

	local jingkong = self:CreateEmoji("dummy/jingkong.png")

	local koubi = self:CreateEmoji("dummy/koubi.png")


    -- 2\


    Story.super.ctor(self, callback)


    -- 3\


    local icon_xuxian = self:CreateIcon(1043, xu_skins)

	local icon_wanjia = self:CreateIcon(GameCache.Avatar.Figure)

	local icon_baogongtou = self:CreateIcon(1049, bao_skins)

	local icon_longwang = self:CreateIcon(1032, long_skins)

    self.message = {
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "终于逮到你了，兄弟你是狗变的么！"},
		{icon = icon_baogongtou,dir = 2, speak = "包工头", msg = "呸，你爷爷我是蛇变的！变身…"},
		{icon = icon_longwang,dir = 2, speak = "包工头", msg = "我要代表月亮消灭你们！！！"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "哇~我最怕蛇啦！！！"},
		{icon = icon_xuxian,dir = 1, speak = "许仙", msg = "骗你的…"},
		{icon = icon_wanjia, dir = 1, speak = GameCache.Avatar.Name .."", msg = "麻痹的你们怎么都不按常理出牌呀！"},
    }


    self:AddInitEndEvent(function (  )
		xuxian:setVisible(true)
		wanjia:setVisible(true)
		baogongtou:setVisible(true)

		xuxian:setAnimation(0, "move", true)
		wanjia:setAnimation(0, "move", true)
		baogongtou:setAnimation(0, "idle", true)

        local go = cc.MoveTo:create(1.5, cc.p(400,200))
		local go1 = cc.MoveTo:create(1.5, cc.p(200,200))
        local event = cc.CallFunc:create(function()
            xuxian:setAnimation(0, "idle", true)
			wanjia:setAnimation(0, "idle", true)
			self:WaitToDialog(0.2)
        end)
        xuxian:runAction(go)
        wanjia:runAction(cc.Sequence:create({go1,event}))

    end)


    self:AddDialogEndEvent(function ( eventname, hua )
        self.istouch = false
        self:DialogBoxVisible(false)

        if hua == self.message[1].msg then
			self:WaitToDialog(0.2)

		elseif hua == self.message[2].msg then
			self:WaitToDialog(1.0)

			local event = cc.CallFunc:create(function()
				baogongtou:setAnimation(0, "atk_ko", false)
				-- baogongtou:setAnimation(0, "idle",true)
			end)

			local delay = cc.DelayTime:create(1)

			--local go = cc.MoveTo:create(3, cc.p(SCREEN_WIDTH-300,200))
			local event1 =cc.CallFunc:create(function()
				baogongtou:setVisible(false)
				longwang:setVisible(true)
				longwang:setAnimation(1, "atk1", false)
				longwang:setAnimation(0, "idle",true)
			end)
			baogongtou:runAction(cc.Sequence:create(event, delay, event1))

		elseif hua == self.message[3].msg then
			self:WaitToDialog(0.2)
			self:Emoji(xuxian, jingkong)

		elseif hua == self.message[4].msg then
			self:WaitToDialog(0.2)
			self:Emoji(xuxian, koubi)

		elseif hua == self.message[5].msg then
			self:WaitToDialog(0.2)
			--wanjia:setRotationSkewY(180)
			--wanjia:setAnimation(0, "move", true)
			--local go1 = cc.MoveTo:create(2, cc.p(-350,200))
			--wanjia:runAction(go1)

		elseif hua == self.message[6].msg then
            self:StoryEnd()
        end
    end)


	self:StoryBegin()

end


return Story
