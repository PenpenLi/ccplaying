local EquipPanel = class("EquipPanel", require("scene.main.gamble.widget.GamblePanel"))

local ZORDER = 2

local SMALLPANEL = 1
local MIDDLEPANEL = SMALLPANEL + 1
local BIGPANEL = MIDDLEPANEL + 1

function EquipPanel:ctor(boxType, bgSize)
    EquipPanel.super.ctor(self, boxType, bgSize)

    self.controls.middleNode:setAnchorPoint(1, 0)
    self.controls.middleNode:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.05)

    self:createUI()
end

function EquipPanel:smallUI()
    local title = cc.Sprite:create("image/ui/img/bg/bg_222.png")
    title:setRotation(90)
    title:setScaleY(0.9)
    title:setPosition(self.data.smallSize.width * 0.5, self.data.smallSize.height * 0.85)
    self.controls.smallNode:addChild(title)

    local fontSpri = cc.Sprite:create("image/ui/img/btn/btn_913.png")
    fontSpri:setPosition(self.data.smallSize.width * 0.48, self.data.smallSize.height * 0.38)
    self.controls.smallNode:addChild(fontSpri)

    EquipPanel.super.smallUI(self)
end

function EquipPanel:middleUI()
    self.controls.leftSpri:setScale(1)
    self.controls.leftSpri:setPosition(self.data.bgSize.width * 0.565, self.data.bgSize.height * 0.03)
    self.controls.bottomSpri:setScale(1)
    self.controls.bottomSpri:setPosition(self.data.bgSize.width * 0.78, self.data.bgSize.height * 0.12)

    self.controls.middleStoneLight = cc.Sprite:create("image/ui/img/btn/btn_901.png")
    self.controls.middleStoneLight:setPosition(self.data.bgSize.width * 0.79, self.data.bgSize.height * 0.32)
    self:addChild(self.controls.middleStoneLight)
    self.controls.middleStoneLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    self.controls.middleStoneLight:setScale(0.7)
    
    local fontPathTab = {"image/ui/img/btn/btn_891.png", "image/ui/img/btn/btn_892.png",
                        "image/ui/img/btn/btn_889.png", "image/ui/img/btn/btn_890.png"}
    EquipPanel.super.middleUI(self, fontPathTab, "image/ui/img/btn/btn_526.png", "image/ui/img/btn/btn_899.png")

    for k,v in pairs(self.data.fontSpriTab) do
        v:setPosition(self.data.bgSize.width * 0.56,
                        self.data.bgSize.height * 0.37 - (k - 1) * self.data.bgSize.height * 0.075)
    end
    self.controls.middlePriceSpri:setPosition(self.data.bottomSize.width * 0.11, self.data.bottomSize.height * 0.5)
    self.controls.middlePriceFont:setPosition(self.data.bottomSize.width * 0.16, self.data.bottomSize.height * 0.5)
    self.controls.middleFreeCount:setPosition(self.data.bottomSize.width * 0.51, self.data.bottomSize.height * 0.5)
    self.controls.btn_look:setPosition(self.data.bottomSize.width * 0.85, self.data.bottomSize.height * 0.5)
    self.controls.middleStoneSpri:setPosition(self.data.bgSize.width * 0.79, self.data.bgSize.height * 0.32)
    self.controls.middleFontSpri:setPosition(self.data.bgSize.width * 0.78, self.data.bgSize.height * 0.25)
end

function EquipPanel:bigUI()
    local quanNode = cc.Node:create()
    quanNode:setName("light")
    quanNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
    self.controls.bigNode:addChild(quanNode)
    for i=1,2 do
        local quanLight = cc.Sprite:create("image/ui/img/btn/btn_544.png")
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
    
    self.controls.bigTitle = cc.Sprite:create("image/ui/img/bg/bg_222.png")
    self.controls.bigTitle:setRotation(90)
    self.controls.bigTitle:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.9)
    self.controls.bigNode:addChild(self.controls.bigTitle)
    self.controls.bigTitle:setScale(0)

    self.controls.bigStove = createMixSprite("image/ui/img/btn/btn_902.png", nil, "image/ui/img/btn/btn_906.png")
    self.controls.bigStove:setTouchEnable(false)
    self.controls.bigStove:setChildPos(0.5, 1)
    self.controls.bigStove:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.5)
    self.controls.bigNode:addChild(self.controls.bigStove)
    self.controls.bigStove:setScale(0)
    
    EquipPanel.super.bigUI(self)
end

function EquipPanel:updateUI(gambleInfo)
    self.data.gambleInfo = gambleInfo
    EquipPanel.super.updateUI(self, self.data.gambleInfo.EquipBuyCost)
end

local MIDDLEPANEL = 2
function EquipPanel:showFreeTime()
    if self.data.gambleInfo then
        if self.data.gambleInfo.EquipNextFreeTime > 0 then
            self.data.gambleInfo.EquipNextFreeTime  = self.data.gambleInfo.EquipNextFreeTime  - 1
            local time = Common.timeFormat(self.data.gambleInfo.EquipNextFreeTime)
            self.controls.middleFreeCount:setString(time.."后免费")
            self.controls.bigFreeCount:setString(time.."后免费")
            self.data.isFree = false
            if self.data.priceShowTab then
                self.data.priceShowTab[1].price:setVisible(not self.data.isFree)
                self.data.priceShowTab[1].fontPrice:setVisible(not self.data.isFree)
            end
            if self.controls.alert then
                self.controls.alert:setVisible(false)
            end
            if self.controls.alert2 then
                self.controls.alert2:setVisible(false)
            end
        else
            self.controls.middleFreeCount:setString("本次免费")
            self.controls.bigFreeCount:setString("本次免费")
            self.data.isFree = true
            if self.data.priceShowTab then
                self.data.priceShowTab[1].price:setVisible(not self.data.isFree)
                self.data.priceShowTab[1].fontPrice:setVisible(not self.data.isFree)
            end
            if self.controls.alert then
                if self.data.currPanel == MIDDLEPANEL then
                    self.controls.alert:setVisible(true)
                else
                    self.controls.alert:setVisible(false)
                end
            end
            if self.controls.alert2 then
                if self.data.currPanel == SMALLPANEL then
                    self.controls.alert2:setVisible(true)
                else
                    self.controls.alert2:setVisible(false)
                end
            end
        end
    end
end

function EquipPanel:buyReturn(nextFreeTime, freeBuyCount, goodsTabs)
    self.data.gambleInfo.EquipNextFreeTime = nextFreeTime
end

function EquipPanel:middleToBig(bigFontPos)
    local posX = self.controls.bigNode:getPositionX() + self.data.bigSize.width * 0.5
    local posY = self.controls.bigNode:getPositionY() - self.data.bigSize.height * 0.5
    EquipPanel.super.middleToBig(self, posX, posY, bigFontPos)
end

function EquipPanel:middleToSmall(smallPosX, smallPosY, delayTime)
    local middlePosX = smallPosX + self.data.smallSize.width * 0.5
    local middlePosY = smallPosY - self.data.smallSize.height * 0.5
    EquipPanel.super.middleToSmall(self, middlePosX, middlePosY, smallPosX, smallPosY, delayTime)
end

function EquipPanel:smallToBig(bigFontPos)
    EquipPanel.super.smallToBig(self, bigFontPos)
end

function EquipPanel:bigToSmall(smallPosX, smallPosY)
    EquipPanel.super.bigToSmall(self, smallPosX, smallPosY)
end

function EquipPanel:buyGamble(gambleType, buyNum)
    local buyCost = self.data.gambleInfo.EquipBuyCost[1]
    if self.data.isFree then
        EquipPanel.super.buyGamble(self, gambleType, buyNum)
    else
        if Common.isCostMoney(buyCost.MoneyType, buyCost.Price) then
            EquipPanel.super.buyGamble(self, gambleType, buyNum)
        end
    end
end

return EquipPanel

