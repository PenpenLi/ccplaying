
local FirstGift = class("FirstGift", BaseLayer)

local NOTRECHARGE = 0
local NOTRECEIVE = 1

function FirstGift:ctor(func)
    local giftConfig = BaseConfig.getFirstGift(1)
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    self:addChild(bgLayer)

    self.controls.bg = cc.Sprite:create("image/ui/img/btn/btn_1345.png")
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.6)
    self:addChild(self.controls.bg)
    local bgSize = self.controls.bg:getContentSize()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bgLayer)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgSize.width * 0.85, bgSize.height * 0.82)
    self.controls.bg:addChild(btn_close)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
            self = nil
        end
    end)

    self.controls.goodsItemNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.goodsItemNode, 1)
    local goodsTotal = #giftConfig.Award
    local itemWidth = 60
    local initWidth = bgSize.width * 0.5 - itemWidth * (goodsTotal - 1)
    for k,info in pairs(giftConfig.Award) do
        local goodsInfo = {}
        goodsInfo.ID = info.GoodsID
        goodsInfo.Type = info.GoodsType
        goodsInfo.Num = info.Num

        local quan = cc.Sprite:create("image/ui/img/btn/btn_595.png")
        quan:setPosition(initWidth + (k - 1) * itemWidth * 2, bgSize.height * 0.18)
        self.controls.bg:addChild(quan)
        local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
        quan:runAction(rep)

        local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_MIDDLETYPE)
        goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2, bgSize.height * 0.18)
        self.controls.goodsItemNode:addChild(goodsItem)
    end
    
    local bg1 = cc.Sprite:create("image/ui/img/btn/btn_1344.png")
    bg1:setPosition(bgSize.width * 0.5, -bgSize.height * 0.08)
    self.controls.bg:addChild(bg1)

    local btn_get = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(150, 70))
    btn_get:setButtonBounce(false)
    btn_get:setCircleFont("前往充值", 1, 1, 25, cc.c3b(238, 205, 142))
    btn_get:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    btn_get:setPosition(bgSize.width * 0.5, -bgSize.height * 0.15)
    self.controls.bg:addChild(btn_get)
    btn_get:addTouchEventListener(function(sender, eventType, isIn)
        if eventType == ccui.TouchEventType.ended and isIn then
            if NOTRECHARGE == GameCache.PurchaseGiftStatus then
                application:pushScene("main.recharge.RechargeScene") 
            elseif NOTRECEIVE == GameCache.PurchaseGiftStatus then
                rpc:call("Gamble.ReceivePurchaseGift", nil, function(event)
                    if event.status == Exceptions.Nil then
                        local tempGoodsInfoTabs = event.result
                        local alertShow = require("scene.main.ReceiveGoods").new(tempGoodsInfoTabs)
                        local runningScene = cc.Director:getInstance():getRunningScene()
                        runningScene:addChild(alertShow)

                        if func then
                            func()
                        end
                    end
                end)

                -- local tempGoodsInfoTabs = {} 
                -- for k,info in pairs(giftConfig.Award) do
                --     local goodsInfo = {}
                --     goodsInfo.ID = info.GoodsID
                --     goodsInfo.Type = info.GoodsType
                --     goodsInfo.Num = info.Num
                --     table.insert(tempGoodsInfoTabs, goodsInfo)
                -- end
            end
            self:removeFromParent()
            self = nil
        end
    end)
    if NOTRECHARGE == GameCache.PurchaseGiftStatus then
        btn_get:setString("前往充值")
    elseif NOTRECEIVE == GameCache.PurchaseGiftStatus then
        btn_get:setString("领取")
    end
end

return FirstGift
