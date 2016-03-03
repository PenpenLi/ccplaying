local DrawGoods = class("DrawGoods", function()
    local node = cc.Node:create()
    node.controls = {}
    node.handlers = {}
    node.data = {}
    return node
end)

-- vip等级不同翻牌的次数不同
local vipTab = {0, 1, 2, 4, 6}
local costGoldTab = {0, 12, 28, 48, 68}

local GoldZOrder = 1

function DrawGoods:ctor(goodsList, endFunc)
    self.data.goodsList = goodsList
    self.controls.endFunc = endFunc
    -- 记录当前翻牌的次数
    self.data.drawCount = 1
    -- 防止在播放动作时可以点击翻牌
    self.data.isCanDraw = false

    self:createUI()
    self:drawShuffle()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function DrawGoods:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_240.png")
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)

    self.controls.layer = cc.LayerColor:create(cc.c4b(0,255,0,0), SCREEN_WIDTH, SCREEN_HEIGHT)
    self:addChild(self.controls.layer)

    local title = cc.Sprite:create("image/ui/img/btn/btn_946.png")
    title:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.88)
    self:addChild(title)

    self.data.goodsItemTab = {}
    for k,v in pairs(self.data.goodsList) do
        local item = self:drawItem(v)
        item:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.95)
        item:setScale(0)
        self.controls.layer:addChild(item)
        table.insert(self.data.goodsItemTab, item)
    end

    self.controls.sure = createMixSprite("image/ui/img/btn/btn_593.png")
    self.controls.sure:setCircleFont("不翻了" , 1, 1, 30, cc.c3b(253, 230, 154))
    self.controls.sure:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
    self.controls.sure:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.1)
    self:addChild(self.controls.sure)
    self.controls.sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.isCanDraw then
                sender:removeFromParent()
                sender = nil

                rpc:call("Tower.DrawEnd", nil, function(event)
                    if event.status == Exceptions.Nil then
                        self:exit()
                    end
                end)
            end
        end
    end)
    self.controls.sure:setScale(0)
end

function DrawGoods:exit()
    for k,v in pairs(self.data.goodsItemTab) do
        v:stopAllActions()
        local vipSpri = v:getChildByName("vipSpri")
        local vipLabel = v:getChildByName("vip")
        local goldSpri = v:getChildByName("goldSpri")
        local goldLabel = v:getChildByName("gold")
        vipSpri:setVisible(false)
        vipLabel:setVisible(false)
        goldSpri:setVisible(false)
        goldLabel:setVisible(false)

        local jump = cc.JumpTo:create(0.3, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5), 80, 1)
        local rotate = cc.RotateBy:create(0.2, 720)
        local scale = cc.ScaleTo:create(0.2, 0)
        local move = cc.MoveTo:create(0.2, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.95))
        local spawn = cc.Spawn:create(rotate, scale, move)
        local func = cc.CallFunc:create(function()
            if k == 5 then
                if self.controls.endFunc then
                    self.controls.endFunc()
                end
                self:removeFromParent()
                self = nil
            end
        end)
        v:runAction(cc.Sequence:create(jump, spawn, func))
    end
end

function DrawGoods:drawItem(goodsInfo)
    local node = cc.Node:create()
    node.isDraw = false -- 是否已经翻过了
    node.isFront = true -- 是否是卡牌正面

    local itemNode = cc.Node:create()
    itemNode:setName("itemNode")
    node:addChild(itemNode)
    local itemBg = cc.Sprite:create("image/ui/img/btn/btn_944.png")
    itemNode:addChild(itemBg)
    local goodsItem = Common.getGoods(goodsInfo, false)
    goodsItem:setName("item")
    itemNode:addChild(goodsItem)
    if goodsItem.setTouchEnable then
        goodsItem:setTouchEnable(false)
    end
    if goodsItem.setTips then
        goodsItem:setTips(false)
    end
    goodsItem:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if node.isFront then
                sender:setTips(true)
            else
                sender:setTips(false)
            end
        end
    end)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            return true
        end
        return false
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            if not self.data.isCanDraw then
                return
            end
            if not node.isDraw then
                if not node.isFront then
                    -- if self.data.drawCount > 4 then
                    --     return
                    -- end
                    if GameCache.Avatar.VIP < vipTab[self.data.drawCount] then
                        application:showFlashNotice("vip等级不够")
                        return
                    end
                    if GameCache.Avatar.Gold < costGoldTab[self.data.drawCount] then
                        application:showFlashNotice("元宝不足～!")
                        return
                    end
                    self.data.isCanDraw = false
                    self:Draw(goodsItem, node)
                end
            end
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, itemBg)

    local itemSize = itemBg:getContentSize()
    local vipSpri = cc.Sprite:create("image/ui/img/btn/btn_856.png")
    vipSpri:setName("vipSpri")
    vipSpri:setPosition(-15, -itemSize.height * 0.7)
    node:addChild(vipSpri)
    vipSpri:setVisible(false)
    local vipLabel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    vipLabel:setPosition(20, -itemSize.height * 0.7)
    vipLabel:setScale(0.45)
    vipLabel:setName("vip")
    node:addChild(vipLabel)
    vipLabel:setVisible(false)

    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(-itemSize.width * 0.18, -itemSize.height * 0.26)
    goldSpri:setName("goldSpri")
    node:addChild(goldSpri, GoldZOrder)
    goldSpri:setVisible(false)

    local goldLabel = Common.finalFont("10", 1, 1, 25, nil, 1)
    goldLabel:setPosition(itemSize.width * 0.1, -itemSize.height * 0.26)
    goldLabel:setName("gold")
    node:addChild(goldLabel, GoldZOrder)
    goldLabel:setVisible(false)

    local back = cc.Sprite:create("image/ui/img/btn/btn_945.png")
    back:setName("back")
    node:addChild(back)
    back:setVisible(false)

    return node
end

function DrawGoods:drawShuffle()
    -- 洗牌动作
    local function shuffle()
        local moveCenterTime = 0.5
        local moveCenter = cc.EaseElasticIn:create(cc.MoveTo:create(moveCenterTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)))
        local centerRotate = cc.RotateBy:create(0.2, 720)
        local goodsItem1 = self.data.goodsItemTab[1]
        local goodsItem2 = self.data.goodsItemTab[2]
        local goodsItem3 = self.data.goodsItemTab[3]
        local goodsItem4 = self.data.goodsItemTab[4]
        local goodsItem5 = self.data.goodsItemTab[5]
        for k,v in pairs(self.data.goodsItemTab) do
            if k ~= 3 then
                v:runAction(cc.Sequence:create(moveCenter:clone(), centerRotate:clone()))
            else
                local jump = cc.JumpBy:create(moveCenterTime, cc.p(0, 0), 30, 3)
                local func1 = cc.CallFunc:create(function()
                    local func11 = cc.CallFunc:create(function()
                        self:changeVip(vipTab[self.data.drawCount], costGoldTab[self.data.drawCount])
                        self.controls.sure:setScale(1)
                    end)
                    goodsItem1:runAction(cc.Sequence:create(cc.JumpTo:create(0.2, cc.p(SCREEN_WIDTH * 0.14, SCREEN_HEIGHT * 0.5), 120, 1)))
                    goodsItem2:runAction(cc.Sequence:create(cc.JumpTo:create(0.2, cc.p(SCREEN_WIDTH * 0.32, SCREEN_HEIGHT * 0.5), 80, 1)))
                    goodsItem4:runAction(cc.Sequence:create(cc.JumpTo:create(0.2, cc.p(SCREEN_WIDTH * 0.68, SCREEN_HEIGHT * 0.5), 80, 1)))
                    goodsItem5:runAction(cc.Sequence:create(cc.JumpTo:create(0.2, cc.p(SCREEN_WIDTH * 0.86, SCREEN_HEIGHT * 0.5), 120, 1), func11))
                end)
                v:runAction(cc.Sequence:create(jump, centerRotate:clone(), func1))
            end
        end
    end
    -- 藏牌动作
    local function hide()
        for k,v in pairs(self.data.goodsItemTab) do
            local delay = cc.DelayTime:create(2)
            local scale1 = cc.ScaleTo:create(0.4, 1.2)
            local scale2 = cc.ScaleTo:create(0.1, 1)
            local orbit = cc.OrbitCamera:create(0.4,1, 0, 0, 720, 0, 0)
            local func1 = cc.CallFunc:create(function()
                local item = v:getChildByName("itemNode")
                item:setVisible(false)
                local back = v:getChildByName("back")
                back:setVisible(true)
                v.isFront = false

                if k == 5 then
                    shuffle()
                end
            end)
            v:runAction(cc.Sequence:create(delay, cc.Spawn:create(scale1, orbit), scale2, func1))
        end
    end

    -- 发牌动作
    local function distribute()
        for k,v in pairs(self.data.goodsItemTab) do
            local move = cc.MoveTo:create(0.2, cc.p(SCREEN_WIDTH * 0.14 + SCREEN_WIDTH * (k - 1) * 0.18, SCREEN_HEIGHT * 0.5))
            local rotate = cc.RotateBy:create(0.2, 720)
            local scale = cc.ScaleTo:create(0.2, 1)
            local func = cc.CallFunc:create(function()
                if k == 5 then
                    hide()
                end
            end)
            local delay = cc.DelayTime:create((k - 1) * 0.2)
            v:runAction(cc.Sequence:create(delay, cc.Spawn:create(move, rotate, scale), func))
        end
    end
    distribute()
end

function DrawGoods:changeVip(vipLevel, goldNum)
    local count = 1
    for k,v in pairs(self.data.goodsItemTab) do
        if not v.isDraw then
            v.count = count
            local vipSpri = v:getChildByName("vipSpri")
            vipSpri:setVisible(true)
            local goldSpri = v:getChildByName("goldSpri")
            goldSpri:setVisible(true)

            local vipLabel = v:getChildByName("vip")
            vipLabel:setVisible(true)
            vipLabel:setString(vipLevel)
            local goldLabel = v:getChildByName("gold")
            goldLabel:setVisible(true)
            goldLabel:setString(goldNum)
            if goldNum == 0 then
                goldLabel:setString("免费")
            end
            if v.count == (5 - self.data.drawCount + 1) then
                self.data.isCanDraw = true
            end
            count = count + 1
        end
    end
end

--[[
    抽奖
]]--
function DrawGoods:Draw(item, node)
    rpc:call("Tower.Draw", nil, function(event)
        if event.status == Exceptions.Nil then
            local goodsInfo = event.result
            node.isDraw = true
            local vipLabel = node:getChildByName("vip")
            local vipSpri = node:getChildByName("vipSpri")
            local goldSpri = node:getChildByName("goldSpri")
            local goldLabel = node:getChildByName("gold")
            vipLabel:setVisible(false)
            vipSpri:setVisible(false)
            goldSpri:setVisible(false)
            goldLabel:setVisible(false)

            local orbit = cc.OrbitCamera:create(0.2,1, 0, 0, 90, 0, 0) 
            local orbit1 = cc.OrbitCamera:create(0.2,1, 0, -90, 90, 0, 0)
            local func1 = cc.CallFunc:create(function()
                local back = node:getChildByName("back")
                back:setVisible(false)
                item:removeFromParent()
                item = nil
                local goodsItem = Common.getGoods(goodsInfo, true)
                node:addChild(goodsItem)
                local itemBg = cc.Sprite:create("image/ui/img/btn/btn_944.png")
                goodsItem:addChild(itemBg, -1)
            end)
            local func2 = cc.CallFunc:create(function()
                node.isFront = true
                self.data.drawCount = self.data.drawCount + 1
                if self.data.drawCount <= 5 then
                    self:changeVip(vipTab[self.data.drawCount], costGoldTab[self.data.drawCount])
                else
                    self.data.isCanDraw = true
                    for k,v in pairs(self.data.goodsItemTab) do
                        if not v.isDraw then
                            local vipLabel = v:getChildByName("vip")
                            local vipSpri = v:getChildByName("vipSpri")
                            local goldSpri = v:getChildByName("goldSpri")
                            local goldLabel = v:getChildByName("gold")
                            vipLabel:setVisible(false)
                            vipSpri:setVisible(false)
                            goldSpri:setVisible(false)
                            goldLabel:setVisible(false)
                        end
                    end
                end
            end)
            node:runAction(cc.Sequence:create(orbit, func1, orbit1, func2))
        end
    end)
end

return DrawGoods
