local ExchangeInfo = class("ExchangeInfo", function()
    return cc.Node:create()
end)

function ExchangeInfo:ctor(goodsInfo, exchangeFunc)
    self.goodsInfo = goodsInfo
    self.exchangeFunc = exchangeFunc
    self:createUI()

    -- if self.goodsInfo.IsExchanged then
    --     self:setTouchEnable(false)
    -- else
    --     self:setTouchEnable(true)
    -- end
end

function ExchangeInfo:createUI()
    local infoBG = cc.Sprite:create("image/ui/img/bg/bg_170.png")
    self:addChild(infoBG)
    local size = infoBG:getContentSize()

    local goodsItem = Common.getGoods(self.goodsInfo, false, 2)
    goodsItem:setPosition(-size.width * 0.25, size.height * 0.15)
    self:addChild(goodsItem)

    local goodsName = Common.finalFont("", size.width * 0.68, size.height * 0.75, 22)
    infoBG:addChild(goodsName)
    if self.goodsInfo.Type == 4 then
        goodsName:setString("货币")
    else
        local configInfo = goodsItem:getGoodsConfigInfo()
        goodsName:setString(configInfo.name)
    end

    local errantry = createMixSprite("image/ui/img/btn/btn_040.png")
    errantry:setTouchEnable(false)
    errantry:setPosition(-size.width * 0.36, -size.height * 0.2)
    errantry:setCircleFont(self.goodsInfo.Price * self.goodsInfo.Num, 1, 1, 20, cc.c3b(245, 117, 55), 1)
    errantry:getFont():setAdditionalKerning(-2)
    errantry:setFontPos(2.6, 0.5)
    self:addChild(errantry)
    if (self.goodsInfo.Price * self.goodsInfo.Num) > GameCache.Avatar.Errantry then
        errantry:setFontColor(cc.c3b(255, 0, 0))
    end

    self.btn_exchange = createMixSprite("image/ui/img/btn/btn_610.png")
    self.btn_exchange:setCircleFont("兑换" , 1, 1, 25, cc.c3b(248, 216, 136))
    self.btn_exchange:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    self.btn_exchange:setPosition(size.width * 0.2, -size.height * 0.2)
    self:addChild(self.btn_exchange)
    self.btn_exchange:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.exchangeFunc(self)
        end
    end)
end

function ExchangeInfo:setTouchEnable(value)
    self.btn_exchange:setNorGLProgram(value)
    self.btn_exchange:setTouchEnable(value)
end

return ExchangeInfo

