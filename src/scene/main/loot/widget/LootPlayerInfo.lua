local LootPlayerInfo = class("LootPlayerInfo", function()
    return cc.Node:create()
end)

local NeedEndurance = 2

function LootPlayerInfo:ctor(info, id, seat)
    self.controls = {}
    self.data = {}

    self.data.treasureID = id
    self.data.seat = seat
    self.data.playerInfo = info

    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_229.png")
    self.controls.bg:setScaleX(1.1)
    self.controls.bg:setScaleY(1.05)
    local size = self.controls.bg:getContentSize()
    self:addChild(self.controls.bg)

    self.controls.head_bg = createMixSprite("image/icon/border/head_bg.png", nil, "image/ui/img/bg/newhead.png")
    self.controls.head_bg:setChildPos(0.48, 0.48)
    self.controls.head_bg:setTouchEnable(false)
    self.controls.head_bg:setPosition(-size.width * 0.45, 2)
    self:addChild(self.controls.head_bg)

    self.controls.head = cc.Sprite:create("image/icon/head/xj_1001.png") --
    self.controls.head_bg:addChild(self.controls.head)

    self.controls.level = Common.finalFont("", 0, -self.controls.head_bg:getContentSize().height * 0.5, 
                                                20, nil, 1) --
    self.controls.level:setAnchorPoint(0.5, 0)
    self.controls.head_bg:addChild(self.controls.level)

    local nameBg = cc.Sprite:create("image/ui/img/btn/btn_929.png")
    nameBg:setAnchorPoint(0, 0.5)
    nameBg:setPosition(-size.width * 0.34, size.height * 0.22)
    self:addChild(nameBg)

    self.controls.name = Common.systemFont("", -size.width * 0.32, size.height * 0.22, 
                                                25, cc.c3b(10, 51, 91))
    self.controls.name:setAnchorPoint(0, 0.5)
    self:addChild(self.controls.name)

    local tfp = Common.finalFont("战力", -size.width * 0.33, -size.height * 0.2, 
                                                20, cc.c3b(71, 105, 169))
    tfp:setAnchorPoint(0, 0.5)
    self:addChild(tfp)

    self.controls.ftp = Common.finalFont("", -size.width * 0.25, -size.height * 0.2, 
                                                25, cc.c3b(255, 194, 1), 1)
    self.controls.ftp:setAnchorPoint(0, 0.5)
    self.controls.ftp:setAdditionalKerning(-2)
    self:addChild(self.controls.ftp)

    self.controls.probability = Common.finalFont(" ", size.width * 0.38, size.height * 0.35, 
                                                20, cc.c3b(255, 78, 0)) --
    self.controls.probability:setAnchorPoint(0, 0.5)
    self:addChild(self.controls.probability)

    local btn_five = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, nil, cc.size(130, 60))
    btn_five:setButtonBounce(false)
    btn_five:setCircleFont("抢五次", 1, 1, 25, cc.c3b(238, 205, 142))
    btn_five:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_five:setPosition(size.width * 0.1, -size.height * 0.15)
    self:addChild(btn_five)
    btn_five:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local openVipLevel = 0
            for i=1,15 do
                local privilege = BaseConfig.getVipPrivilege(i)
                if 1 == privilege.LootSweep then
                    openVipLevel = i
                    break
                end
            end
            if GameCache.Avatar.VIP < openVipLevel then
                application:showFlashNotice("VIP"..openVipLevel.."开启")
                return 
            end
            if GameCache.Avatar.Endurance < (NeedEndurance * 5) then
                require("tool.helper.CommonLayer").NeedEndurance()
            else
                local parent = self:getParent():getParent() 
                parent:sweep(self.data.treasureID, self.data.seat, self.data.playerInfo)
            end
        end
    end)

    local btn_one = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, "image/ui/img/btn/btn_670.png", cc.size(136, 60))
    btn_one:setButtonBounce(false)
    btn_one:setChildPos(0.2, 0.5)
    btn_one:setCircleFont("抢夺", 1, 1, 25, cc.c3b(238, 205, 142))
    btn_one:setFontPos(0.6, 0.5)
    btn_one:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_one:setPosition(size.width * 0.4, -size.height * 0.15)
    self:addChild(btn_one)
    btn_one:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if GameCache.Avatar.Endurance < NeedEndurance then
                require("tool.helper.CommonLayer").NeedEndurance()
            else
                local parent = self:getParent():getParent() 
                parent:Loot(self.data.treasureID, self.data.seat, self.data.playerInfo)
            end
        end
    end)
end

local pTabs = {"低概率", "中概率", "高概率"}

function LootPlayerInfo:updateInfo(playerInfo)
    self.data.playerInfo = playerInfo
    local path = string.format("image/icon/head/xj_%d.png", playerInfo.Icon)
    self.controls.head:setTexture(path)
    self.controls.level:setString("lv."..playerInfo.Level)
    self.controls.name:setString(playerInfo.Name)
    self.controls.ftp:setString(playerInfo.TFP)
    self.controls.probability:setString(pTabs[playerInfo.P])

    local Head_Texture_VIP = { "image/ui/img/bg/newhead.png", "image/ui/img/bg/newhead2.png", "image/ui/img/bg/newhead3.png" }
    local vipPath = nil
    if playerInfo.VIP < 15 then
        vipPath = Head_Texture_VIP[math.floor(playerInfo.VIP/5)+1]
    else
        vipPath = "image/ui/img/bg/newhead4.png"
    end
    self.controls.head_bg:setChildTexture(vipPath)
end

return LootPlayerInfo

