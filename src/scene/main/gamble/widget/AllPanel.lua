local AllPanel = class("AllPanel", require("scene.main.gamble.widget.GamblePanel"))

local SMALLPANEL = 1
local MIDDLEPANEL = SMALLPANEL + 1
local BIGPANEL = MIDDLEPANEL + 1

function AllPanel:ctor(boxType, bgSize)
    AllPanel.super.ctor(self, boxType, bgSize)

    self.controls.middleNode:setAnchorPoint(0, 1)
    self.controls.middleNode:setPosition(self.data.bgSize.width * 0.03, self.data.bgSize.height * 0.94)

    self:createUI()
end

function AllPanel:smallUI()
    local title = cc.Sprite:create("image/ui/img/bg/bg_223.png")
    title:setRotation(90)
    title:setScaleY(0.9)
    title:setPosition(self.data.smallSize.width * 0.5, self.data.smallSize.height * 0.85)
    self.controls.smallNode:addChild(title)

    local fontSpri = cc.Sprite:create("image/ui/img/btn/btn_911.png")
    fontSpri:setPosition(self.data.smallSize.width * 0.5, self.data.smallSize.height * 0.4)
    self.controls.smallNode:addChild(fontSpri)

    AllPanel.super.smallUI(self)
end

function AllPanel:middleUI()
    self.controls.leftSpri:setScale(1)
    self.controls.leftSpri:setPosition(self.data.bgSize.width * 0.08, self.data.bgSize.height * 0.508)
    self.controls.bottomSpri:setScale(1)
    self.controls.bottomSpri:setPosition(self.data.bgSize.width * 0.29, self.data.bgSize.height * 0.6)

    local fontPathTab = {"image/ui/img/btn/btn_883.png", "image/ui/img/btn/btn_884.png",
                        "image/ui/img/btn/btn_885.png", "image/ui/img/btn/btn_886.png"}
    AllPanel.super.middleUI(self, fontPathTab, "image/ui/img/btn/btn_525.png", "image/ui/img/btn/btn_896.png")
    
    for k,v in pairs(self.data.fontSpriTab) do
        v:setPosition(self.data.bgSize.width * 0.075,
                        self.data.bgSize.height * 0.85 - (k - 1) * self.data.bgSize.height * 0.075)
    end
    self.controls.middlePriceSpri:setPosition(self.data.bottomSize.width * 0.12, self.data.bottomSize.height * 0.5)
    self.controls.middlePriceFont:setPosition(self.data.bottomSize.width * 0.17, self.data.bottomSize.height * 0.5)
    self.controls.middleFreeCount:setPosition(self.data.bottomSize.width * 0.55, self.data.bottomSize.height * 0.5)
    self.controls.btn_look:setPosition(self.data.bottomSize.width * 0.85, self.data.bottomSize.height * 0.5)
    self.controls.middleStoneSpri:setPosition(self.data.bgSize.width * 0.29, self.data.bgSize.height * 0.8)
    self.controls.middleFontSpri:setPosition(self.data.bgSize.width * 0.29, self.data.bgSize.height * 0.705)
end

function AllPanel:bigUI()
    self.controls.bigTitle = cc.Sprite:create("image/ui/img/bg/bg_223.png")
    self.controls.bigTitle:setRotation(90)
    self.controls.bigTitle:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.9)
    self.controls.bigNode:addChild(self.controls.bigTitle)
    self.controls.bigTitle:setScale(0)

    self.controls.bigStove = createMixSprite("image/ui/img/btn/btn_902.png", nil, "image/ui/img/btn/btn_905.png")
    self.controls.bigStove:setTouchEnable(false)
    self.controls.bigStove:setChildPos(0.5, 1)
    self.controls.bigStove:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.5)
    self.controls.bigNode:addChild(self.controls.bigStove)
    self.controls.bigStove:setScale(0)

    AllPanel.super.bigUI(self)
    self.controls.bigFont1:setVisible(false)
    self.controls.bigFont2:setVisible(false)

    self.controls.lookHero = createMixSprite("image/ui/img/btn/btn_1289.png")
    self.controls.lookHero:setButtonBounce(false)
    self.controls.lookHero:setPosition(self.data.bigSize.width * 0.12, self.data.bigSize.height * 0.92)
    self.controls.bigNode:addChild(self.controls.lookHero)
    self.controls.lookHero:setScale(0)
    self.controls.lookHero:addTouchEventListener(function(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            rpc:call("Gamble.Preview", self.data.boxType, function(event)
                if event.status == Exceptions.Nil then
                    self:lookHeroUI(event.result)
                end
            end)
        end 
    end)
end

function AllPanel:updateUI(gambleInfo)
    self.data.gambleInfo = gambleInfo
    AllPanel.super.updateUI(self, self.data.gambleInfo.AllBuyCost)
end

function AllPanel:middleToBig(bigFontPos)
    local posX = self.controls.bigNode:getPositionX() - self.data.bigSize.width * 0.5
    local posY = self.controls.bigNode:getPositionY() + self.data.bigSize.height * 0.5
    AllPanel.super.middleToBig(self, posX, posY, bigFontPos)
end

function AllPanel:middleToSmall(smallPosX, smallPosY, delayTime)
    local middlePosX = smallPosX - self.data.smallSize.width * 0.5
    local middlePosY = smallPosY + self.data.smallSize.height * 0.5
    AllPanel.super.middleToSmall(self, middlePosX, middlePosY, smallPosX, smallPosY, delayTime)
end

function AllPanel:smallToBig(bigFontPos)
    AllPanel.super.smallToBig(self, bigFontPos)
end

function AllPanel:bigToSmall(smallPosX, smallPosY)
    AllPanel.super.bigToSmall(self, smallPosX, smallPosY)
end

function AllPanel:buyGamble(gambleType, buyNum)
    local buyCost = self.data.gambleInfo.AllBuyCost[1]
    if self.data.isFree then
        AllPanel.super.buyGamble(self, gambleType, buyNum)
    else
        if Common.isCostMoney(buyCost.MoneyType, buyCost.Price) then
            AllPanel.super.buyGamble(self, gambleType, buyNum)
        end
    end
end

return AllPanel

