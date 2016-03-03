local VipPanel = class("VipPanel", require("scene.main.gamble.widget.GamblePanel"))
local effects = require("tool.helper.Effects")

local ZORDER = 2

function VipPanel:ctor(boxType, bgSize)
    VipPanel.super.ctor(self, boxType, bgSize)

    self.controls.middleNode:setAnchorPoint(1, 1)
    self.controls.middleNode:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.94)

    self:createUI()
end

function VipPanel:smallUI()
    local title = cc.Sprite:create("image/ui/img/bg/bg_221.png")
    title:setRotation(90)
    title:setScaleY(0.9)
    title:setPosition(self.data.smallSize.width * 0.5, self.data.smallSize.height * 0.85)
    self.controls.smallNode:addChild(title)

    local fontSpri = cc.Sprite:create("image/ui/img/btn/btn_914.png")
    fontSpri:setPosition(self.data.smallSize.width * 0.5, self.data.smallSize.height * 0.4)
    self.controls.smallNode:addChild(fontSpri)
end

function VipPanel:middleUI()
    self.controls.leftSpri:setScale(1)
    self.controls.leftSpri:setPosition(self.data.bgSize.width * 0.565, self.data.bgSize.height * 0.508)
    self.controls.bottomSpri:setScale(1)
    self.controls.bottomSpri:setPosition(self.data.bgSize.width * 0.78, self.data.bgSize.height * 0.6)

    local fontPathTab = {"image/ui/img/btn/btn_895.png",
                        "image/ui/img/btn/btn_893.png", "image/ui/img/btn/btn_894.png"}
    for k,v in pairs(fontPathTab) do
        local fontSpri = cc.Sprite:create(v)
        fontSpri:setPosition(self.data.bgSize.width * 0.56, 
                        self.data.bgSize.height * 0.83 - (k - 1) * self.data.bgSize.height * 0.08)
        self:addChild(fontSpri, ZORDER)
        self.data.fontSpriTab[k] = fontSpri
    end

    local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    priceSpri:setPosition(self.data.bottomSize.width * 0.43, self.data.bottomSize.height * 0.5)
    self.controls.bottomSpri:addChild(priceSpri, ZORDER)

    self.controls.middlePriceFont = Common.finalFont("" , 1, 1, 20, nil, 1)
    self.controls.middlePriceFont:setAnchorPoint(0, 0.5)
    self.controls.middlePriceFont:setPosition(self.data.bottomSize.width * 0.48, self.data.bottomSize.height * 0.5)
    self.controls.bottomSpri:addChild(self.controls.middlePriceFont, ZORDER)

    self.controls.btn_look = effects:CreateAnimation(self.controls.bottomSpri, 0, 0, nil, 17, true)
    self.controls.btn_look:setPosition(self.data.bottomSize.width * 0.85, self.data.bottomSize.height * 0.5)
    self.controls.btn_look:setTimeScale(0.2)

    self.controls.middleStoneLight = cc.Sprite:create("image/ui/img/btn/btn_901.png")
    self.controls.middleStoneLight:setPosition(self.data.bgSize.width * 0.79, self.data.bgSize.height * 0.81)
    self:addChild(self.controls.middleStoneLight)
    self.controls.middleStoneLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    self.controls.middleStoneLight:setScale(0.7)

    self.controls.middleStoneSpri = cc.Sprite:create("image/ui/img/btn/btn_524.png")
    self.controls.middleStoneSpri:setPosition(self.data.bgSize.width * 0.79, self.data.bgSize.height * 0.81)
    self:addChild(self.controls.middleStoneSpri)
    self.controls.middleFontSpri = cc.Sprite:create("image/ui/img/btn/btn_897.png")
    self.controls.middleFontSpri:setPosition(self.data.bgSize.width * 0.78, self.data.bgSize.height * 0.705)
    self:addChild(self.controls.middleFontSpri)

    local posTabs = {{0, 50}, {120, 40}, {130, 100}}
    for i=1,3 do
        local star = cc.Sprite:create("image/ui/img/btn/btn_543.png")
        star:setPosition(posTabs[i][1], posTabs[i][2])
        self.controls.middleStoneSpri:addChild(star)
        local scale1 = cc.ScaleBy:create(i / 2, 0.01)
        local scale2 = scale1:reverse()
        star:runAction(cc.RepeatForever:create(cc.Sequence:create(scale1, scale2)))
    end
end

function VipPanel:bigUI()
    self.controls.lamp = effects:CreateAnimation(self.controls.bigNode, 0, 0, nil, 15, true)
    self.controls.lamp:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.7)
    self.controls.lamp:setScale(0)
    
    self.controls.bigTitle = cc.Sprite:create("image/ui/img/bg/bg_221.png")
    self.controls.bigTitle:setRotation(90)
    self.controls.bigTitle:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.9)
    self.controls.bigNode:addChild(self.controls.bigTitle)
    self.controls.bigTitle:setScale(0)

    self.controls.bigStove = createMixSprite("image/ui/img/btn/btn_902.png", nil, "image/ui/img/btn/btn_904.png")
    self.controls.bigStove:setTouchEnable(false)
    self.controls.bigStove:setChildPos(0.5, 1)
    self.controls.bigStove:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.5)
    self.controls.bigNode:addChild(self.controls.bigStove)
    self.controls.bigStove:setScale(0)
    
    local quanNode = cc.Node:create()
    quanNode:setName("light")
    quanNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
    self.controls.bigNode:addChild(quanNode)
    for i=1,2 do
        local quanLight = cc.Sprite:create("image/ui/img/btn/btn_545.png")
        quanLight:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.66)
        quanNode:addChild(quanLight)
        local function changeScale()
            quanLight:setScale(0.1)
            quanLight:setOpacity(255)
        end
        changeScale()

        local allTime = 4
        local delay = cc.DelayTime:create(allTime * 0.5 * (i - 1))
        local function palyAction()
            local scale1 = cc.ScaleTo:create(allTime, 1)
            local fadeout1 = cc.FadeOut:create(allTime)
            local spawn1 = cc.Spawn:create(scale1, fadeout1)
            local seq1 = cc.Sequence:create(spawn1, cc.CallFunc:create(changeScale))
            quanLight:runAction(cc.RepeatForever:create(seq1))
        end
        quanLight:runAction(cc.Sequence:create(delay, cc.CallFunc:create(palyAction)))
    end

    self.controls.bigBottomSpri = cc.Sprite:create("image/ui/img/bg/bg_224.png")
    self.controls.bigBottomSpri:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.18)
    self.controls.bigNode:addChild(self.controls.bigBottomSpri)
    self.controls.bigBottomSpri:setScaleY(0)

    local size = self.controls.bigBottomSpri:getContentSize()
    local font1 = Common.finalFont("本周热点" , 1, 1, 25, cc.c3b(72, 106, 167))
    font1:setPosition(size.width * 0.12, size.height * 0.8)
    self.controls.bigBottomSpri:addChild(font1)

    local font2Bg = cc.Sprite:create("image/ui/img/btn/btn_903.png")
    font2Bg:setPosition(size.width * 0.47, size.height * 0.62)
    self.controls.bigBottomSpri:addChild(font2Bg)
    local font2 = Common.finalFont("本日热点" , 1, 1, 25, cc.c3b(72, 106, 167))
    font2:setPosition(size.width * 0.48, size.height * 0.8)
    self.controls.bigBottomSpri:addChild(font2)

    local font3 = Common.finalFont("必出热点物品" , 1, 1, 25, cc.c3b(72, 106, 167))
    font3:setPosition(size.width * 0.85, size.height * 0.8)
    self.controls.bigBottomSpri:addChild(font3)

    local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    priceSpri:setPosition(size.width * 0.8, size.height * 0.62)
    self.controls.bigBottomSpri:addChild(priceSpri)

    local btn_buy = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_907.png", cc.size(140, 70))
    btn_buy:setChildPos(0.5, 0.6)
    btn_buy:setPosition(size.width * 0.85, size.height * 0.3)
    self.controls.bigBottomSpri:addChild(btn_buy)
    btn_buy:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            CCLog("------------------------购买--------------------------")
            local priceInfo = self.data.gambleInfo.VipBuyCost
            if Common.isCostMoney(priceInfo.MoneyType, priceInfo.Price) then
                if self.data.isCanBuy then
                    self.data.isCanBuy = false
                    self:buyGamble(self.data.boxType, 1)
                end
            end
        end
    end)
end

function VipPanel:updateUI(gambleInfo)
    self.data.gambleInfo = gambleInfo
    self.controls.middlePriceFont:setString(self.data.gambleInfo.VipBuyCost.Price)

    local size = self.controls.bigBottomSpri:getContentSize()
    local weekGoods = Common.getGoods(self.data.gambleInfo.VipWeekHot, false)
    weekGoods:setNumVisible(false)
    weekGoods:setPosition(size.width * 0.12, size.height * 0.4)
    self.controls.bigBottomSpri:addChild(weekGoods)
    for k,v in pairs(self.data.gambleInfo.VipDailyHot) do
        local dailyGoods = Common.getGoods(v, false, 2)
        dailyGoods:setNumVisible(false)
        dailyGoods:setPosition(size.width * 0.32 + (k - 1) * size.width * 0.15, size.height * 0.4)
        self.controls.bigBottomSpri:addChild(dailyGoods)
    end
    local priceFont = Common.finalFont(self.data.gambleInfo.VipBuyCost.Price, 1, 1, 20, cc.c3b(245, 117, 55))
    priceFont:setAnchorPoint(0, 0.5)
    priceFont:setPosition(size.width * 0.84, size.height * 0.62)
    self.controls.bigBottomSpri:addChild(priceFont)

end

function VipPanel:showFreeTime()
end

function VipPanel:buyReturn(nextFreeTime, freeBuyCount, goodsTabs)
end

function VipPanel:middleToBig(bigFontPos)
    local posX = self.controls.bigNode:getPositionX() + self.data.bigSize.width * 0.5
    local posY = self.controls.bigNode:getPositionY() + self.data.bigSize.height * 0.5
    VipPanel.super.middleToBig(self, posX, posY, bigFontPos)
end

function VipPanel:middleToSmall(smallPosX, smallPosY, delayTime)
    local middlePosX = smallPosX + self.data.smallSize.width * 0.5
    local middlePosY = smallPosY + self.data.smallSize.height * 0.5
    VipPanel.super.middleToSmall(self, middlePosX, middlePosY, smallPosX, smallPosY, delayTime)
end

function VipPanel:smallToBig(bigFontPos)
    VipPanel.super.smallToBig(self, bigFontPos)
end

function VipPanel:bigToSmall(smallPosX, smallPosY)
    VipPanel.super.bigToSmall(self, smallPosX, smallPosY)
end

function VipPanel:buyGamble(gambleType, buyNum)
    local buyCost = self.data.gambleInfo.VipBuyCost
    if Common.isCostMoney(buyCost.MoneyType, buyCost.Price) then
        VipPanel.super.buyGamble(self, gambleType, buyNum)
    end
end

return VipPanel

