local FairyIcon = class("Fairyo", require("tool.helper.CurrencyIcon"))

function FairyIcon:setGoodsInfo(goodsInfo)
    self.data.goodsInfo = goodsInfo
    self.data.goodsConfigInfo = BaseConfig.GetFairy(self.data.goodsInfo.ID)
end

function FairyIcon:createUI()
    local headBG = cc.Sprite:create("image/icon/border/border_circle_01.png")
    self:addChild(headBG)
    headBG:setScale(self.data.scaleValueTab[self.data.sizeType])

    local stencil = cc.Sprite:create("image/icon/border/border_circle_01.png")
    stencil:setScale(self.data.scaleValueTab[self.data.sizeType])
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setInverted(false)
    clippingNode:setAlphaThreshold(0.5)
    clippingNode:setStencil(stencil)
    self:addChild(clippingNode)

    local path = self:getTexturePath()
    self.controls.currencySpri = cc.Sprite:create(path)
    self.controls.currencySpri:setScale(0.8)
    clippingNode:addChild(self.controls.currencySpri)

    local border = cc.Sprite:create("image/icon/border/border_circle_03.png")
    self:addChild(border)
    border:setScale(self.data.scaleValueTab[self.data.sizeType])
end

function FairyIcon:getTexturePath()
    return string.format("res/image/ui/fairy/%s_head.png", self.data.goodsConfigInfo.Res)
end

function FairyIcon:updateGoodsInfo(goodsInfo)
    self:setGoodsInfo(goodsInfo)
    local path = self:getTexturePath()
    self.controls.currencySpri:setTexture(texture)
end

return FairyIcon

