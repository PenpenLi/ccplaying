
local ReceiveGoods = class("ReceiveGoods", BaseLayer)
local effects = require("tool.helper.Effects")

function ReceiveGoods:ctor(goodsInfoTabs, titlePath, callFunc)
    local beforeGoodsInfoTabs = {}
    local afterGoodsInfoTabs = {}
    for k,goodsInfo in pairs(goodsInfoTabs) do
        if goodsInfo.Type == BaseConfig.GT_SOUL then
            table.insert(afterGoodsInfoTabs, goodsInfo)
        elseif goodsInfo.Type == BaseConfig.GT_PROPS then
            local propsConfig = BaseConfig.GetProps(goodsInfo.ID)
            if (propsConfig.type == 1) or (propsConfig.type == 4) then
                table.insert(afterGoodsInfoTabs, goodsInfo)
            else
                table.insert(beforeGoodsInfoTabs, goodsInfo)
            end
        else
            table.insert(beforeGoodsInfoTabs, goodsInfo)
        end
    end
    goodsInfoTabs = {}
    for k,goodsInfo in pairs(beforeGoodsInfoTabs) do
        table.insert(goodsInfoTabs, goodsInfo)
    end
    for k,goodsInfo in pairs(afterGoodsInfoTabs) do
        table.insert(goodsInfoTabs, goodsInfo)
    end

    Common.addTopSwallowLayer()
    local isExit = false
    local goodsTotal = (#goodsInfoTabs)

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    self:addChild(bgLayer)
    
    local openEffect = effects:CreateAnimation(self, SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5, nil, 13, false)
    openEffect:setScale(1.3)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_189.png")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    local bgSize = bg:getContentSize()

    local blackBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_190.png")
    local blackBgSize = cc.size(bgSize.width * 0.9, 110)  
    blackBg:setContentSize(blackBgSize)
    blackBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    if goodsTotal > 5 then
        blackBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.52)
        blackBg:setContentSize(cc.size(bgSize.width * 0.9, 200) )
    else
        
    end
    bg:addChild(blackBg)

    titlePath = titlePath or "image/ui/img/btn/btn_815.png"
    local tishiBg = cc.Sprite:create(titlePath)
    tishiBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.9)
    bg:addChild(tishiBg)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bgLayer)

    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
    btn_sure:setCircleFont("真棒" , 1, 1, 30, cc.c3b(253, 230, 154))
    btn_sure:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
    btn_sure:setPosition(bgSize.width * 0.5, 70)
    bg:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.began then
            Common.addTopSwallowLayer()
        end
        if eventType == ccui.TouchEventType.ended then
            Common.removeTopSwallowLayer()
        end
        if eventType == ccui.TouchEventType.ended and isInside then
            if isExit then
                return
            end

            if callFunc then
                callFunc()
            end
            self:exitAction()

            isExit = true
        end
    end)

    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
    scrollview:setContentSize(cc.size(bgSize.width, 110))    
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:setInnerContainerSize(cc.size(bgSize.width, 110))    
    scrollview:setPosition(0,155)
    bg:addChild(scrollview)

    local container_size = cc.size(bgSize.width, 110)
    if goodsTotal > 5 then
        local h = math.ceil(goodsTotal/5) * 100
        scrollview:setContentSize(cc.size(bgSize.width, 180)) 
        scrollview:setInnerContainerSize(cc.size(bgSize.width, h)) 
        scrollview:setPosition(0,125)
        container_size = cc.size(bgSize.width, h)
    end

    bg:setScale(0.01)
    local delay1 = cc.DelayTime:create(0.1) 
    local scale1 = cc.ScaleTo:create(0.2, 1.3)
    local scale2 = cc.ScaleTo:create(0.08, 1)
    local createGoods = cc.CallFunc:create(function()
        local itemWidth = 60
        local initWidth = container_size.width * 0.5 - itemWidth * (goodsTotal - 1)
        for k,v in pairs(goodsInfoTabs) do
            if goodsTotal > 5 then
                local goodsItem = Common.getGoods(v, true, BaseConfig.GOODS_MIDDLETYPE)
                goodsItem:setPosition(container_size.width * 0.14 + ((k - 1)%5) * itemWidth * 2, container_size.height - math.floor((k - 1) / 5) * 95 - 45)
                scrollview:addChild(goodsItem)
                goodsItem:setScale(0)
                local scale1 = cc.ScaleTo:create(0.08, 1.2)
                local scale2 = cc.ScaleTo:create(0.05, 1)
                local delay = cc.DelayTime:create((k - 1) * 0.1)
                goodsItem:runAction(cc.Sequence:create(delay, scale1, scale2, cc.CallFunc:create(function (  )
                    if k%5 == 0 then
                        scrollview:scrollToPercentVertical((math.floor(k/5) * 110)/container_size.height *100, 0.1, false)
                    end
                    
                    if k == goodsTotal then
                        Common.removeTopSwallowLayer()
                    end
                end)))
                  
            else
                local goodsItem = Common.getGoods(v, true, BaseConfig.GOODS_MIDDLETYPE)
                goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2, container_size.height * 0.5)
                scrollview:addChild(goodsItem)
                if goodsTotal > 1 then
                    goodsItem:setPosition(initWidth, container_size.height * 0.5)
                    local delayTime = 0.2 + (k - 1) * 0.1
                    local moveTime = 0.2
                    local delay = cc.DelayTime:create(delayTime)
                    local move = cc.EaseBounceOut:create(cc.MoveTo:create(moveTime, cc.p(initWidth + (k - 1) * itemWidth * 2, container_size.height * 0.5)))
                    local sequence = cc.Sequence:create(delay, move, cc.CallFunc:create(function()
                        if k == goodsTotal then
                            Common.removeTopSwallowLayer()
                        end
                    end))
                    goodsItem:runAction(sequence)
                else
                    Common.removeTopSwallowLayer()
                end 
            end
        end
    end)
    bg:runAction(cc.Sequence:create(delay1, scale1, scale2, createGoods))
    Common.playSound("audio/effect/award.mp3")


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        if isExit then
            return
        end

        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            if callFunc then
                callFunc()
            end
            self:exitAction()
            isExit = true
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end

function ReceiveGoods:onEnterTransitionFinish()
end

return ReceiveGoods
