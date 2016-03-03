local DrawBoxFive = class("DrawBoxFive", function()
    local node = cc.Node:create()
    node.controls = {}
    node.handlers = {}
    node.data = {}
    return node
end)

function DrawBoxFive:ctor(treasureID, seat, sweepInfo)
    self.data.treasureID = treasureID
    self.data.seat = seat
    self.data.DrawInfoTabs = sweepInfo
    
    self.data.isCloseUI = false
    self:createUI()
end

function DrawBoxFive:createUI()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    self:addChild(bgLayer)
    
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(650, 540))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    local ccSize = bg:getContentSize()

    local timu = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_874.png") 
    timu:setPosition(ccSize.width * 0.5, ccSize.height * 0.98)
    bg:addChild(timu)
    timu:setTouchEnable(false)

    local name = BaseConfig.GetTreasure(self.data.treasureID, self.data.seat).Name
    for k,info in pairs(self.data.DrawInfoTabs) do
        local panelBg = cc.Sprite:create("image/ui/img/bg/bg_173.png")
        if (k % 2 == 0) then
            panelBg:setOpacity(50)
        else
            panelBg:setOpacity(20)
        end
        bg:addChild(panelBg)
        local panelSize = panelBg:getContentSize()
        panelBg:setPosition(ccSize.width * 0.5, ccSize.height - 100 - (k - 1) * 90)

        local winPath = nil
        if info.IsWin then
            winPath = "image/ui/img/btn/btn_621.png"
        else
            winPath = "image/ui/img/btn/btn_622.png"
        end 
        local winSpri = cc.Sprite:create(winPath)
        winSpri:setPosition(panelSize.width * 0.11, panelSize.height * 0.5)
        panelBg:addChild(winSpri)

        local desc = nil
        local descColor = nil
        if info.IsGet then
            desc = "夺得"..name
            descColor = cc.c3b(200,255,109)
        else
            desc = "未抢到碎片"
            descColor = cc.c3b(255, 255, 255)
        end
        local descLab = Common.finalFont(desc, 1, 1, 20, descColor, 1)
        descLab:setAnchorPoint(0, 0.5)
        descLab:setPosition(panelSize.width * 0.19, panelSize.height * 0.68)
        panelBg:addChild(descLab)

        local expSpri = cc.Sprite:create("image/ui/img/btn/btn_671.png")
        expSpri:setAnchorPoint(0, 0.5)
        expSpri:setPosition(panelSize.width * 0.18, panelSize.height * 0.3)
        panelBg:addChild(expSpri)
        expSpri:setScale(0.8)
        local exp = Common.finalFont("+"..info.Exp, 1, 1, 20, cc.c3b(151, 255, 74), 1)
        exp:setAnchorPoint(0, 0.5)
        exp:setPosition(panelSize.width * 0.26, panelSize.height * 0.3)
        panelBg:addChild(exp)

        local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        priceSpri:setAnchorPoint(0, 0.5)
        priceSpri:setPosition(panelSize.width * 0.35, panelSize.height * 0.3)
        panelBg:addChild(priceSpri)
        local price = Common.finalFont("+"..info.Coin, 1, 1, 20, cc.c3b(151, 255, 74), 1)
        price:setAnchorPoint(0, 0.5)
        price:setPosition(panelSize.width * 0.42, panelSize.height * 0.3)
        panelBg:addChild(price)

        if info.Draw.Type > 0 and info.Draw.ID > 0 then
            local get = Common.finalFont("翻牌获得:", 1, 1, 18, nil, 1)
            get:setAnchorPoint(0, 0.5)
            get:setPosition(panelSize.width * 0.53, panelSize.height * 0.7)
            panelBg:addChild(get)
        
            local goodsItem = Common.getGoods(info.Draw, true, BaseConfig.GOODS_SMALLTYPE)
            goodsItem:setPosition(panelSize.width * 0.75, panelSize.height * 0.5)
            panelBg:addChild(goodsItem)
            if goodsItem.setNumVisible then
                goodsItem:setNumVisible(false)
            end
            local num = Common.finalFont("x "..info.Draw.Num, 1, 1, 20, nil, 1)
            num:setAnchorPoint(0, 0.5)
            num:setPosition(panelSize.width * 0.81, panelSize.height * 0.5)
            panelBg:addChild(num)
        end

        panelBg:setScaleY(0)
        local delay = cc.DelayTime:create((k - 1) * 0.1)
        local scale = cc.ScaleTo:create(0.2, 1, 1)
        panelBg:runAction(cc.Sequence:create(delay, scale, cc.CallFunc:create(function()
            if k == 5 then
                self.data.isCloseUI = true
            end
        end)))
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local startpos = target:convertToNodeSpace(touch:getStartLocation())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
            if self.data.isCloseUI then
                local parent = self:getParent()
                parent:onEnter()
                self:removeFromParent()
                self = nil
            end
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, bg)
end

return DrawBoxFive

