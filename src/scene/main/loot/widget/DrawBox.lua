local DrawBox = class("DrawBox", function()
    local node = cc.Node:create()
    node.controls = {}
    node.handlers = {}
    node.data = {}
    return node
end)

function DrawBox:ctor(isGetFrag, info, isFromLootLayer)
    self.data.isGetFrag = isGetFrag
    self.data.info = info
    self.data.isFromLootLayer = isFromLootLayer

    self.data.drawTabs = BaseConfig.getLootDraw()
    self:createUI()
end

function DrawBox:createUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    self:addChild(bgLayer)
    
    local bg = cc.Sprite:create("image/ui/img/bg/bg_163.png")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    bg:setScaleY(1.5)
    local ccSize = cc.size(928, 454)

    self.controls.bg = cc.Node:create()
    self:addChild(self.controls.bg)
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5 - ccSize.width * 0.5, SCREEN_HEIGHT * 0.5 - ccSize.height * 0.5)

    local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    light:setPosition(ccSize.width * 0.5, ccSize.height * 0.98)
    self.controls.bg:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
    light:runAction(rep)

    local win = createMixSprite("image/ui/img/bg/bg_160.png", nil, "image/ui/img/btn/btn_632.png")
    win:setTouchEnable(false)
    win:setChildPos(0.5, 0.95)
    win:setPosition(ccSize.width * 0.5, ccSize.height * 0.98)
    self.controls.bg:addChild(win)

    local desc = createMixScale9Sprite("image/ui/img/bg/bg_161.png",nil, nil, cc.size(300, 60))
    desc:setTouchEnable(false)
    desc:setPosition(ccSize.width * 0.5, ccSize.height * 0.9)
    self.controls.bg:addChild(desc)
    desc:setCircleFont("", 1, 1, 25, cc.c3b(151, 255, 74), 1)
    if self.data.isGetFrag then
        local name = BaseConfig.GetTreasure(self.data.info.TreasureID, self.data.info.Seat).Name
        desc:setString("抢到"..name)
    else
        desc:setString("碎片未抢到~")
    end

    local exp = cc.Sprite:create("image/ui/img/btn/btn_671.png")
    exp:setPosition(ccSize.width * 0.35, ccSize.height * 0.74)
    self.controls.bg:addChild(exp)

    self.controls.exp = Common.finalFont("+"..self.data.info.Exp, ccSize.width * 0.44, ccSize.height * 0.74, 20, cc.c3b(151, 255, 74), 1)
    self.controls.bg:addChild(self.controls.exp)

    local price = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    price:setPosition(ccSize.width * 0.56, ccSize.height * 0.74)
    self.controls.bg:addChild(price)

    self.controls.price = Common.finalFont("+"..self.data.info.Coin, ccSize.width * 0.64, ccSize.height * 0.74, 20, cc.c3b(151, 255, 74), 1)
    self.controls.bg:addChild(self.controls.price)

    local line = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    line:setPosition(ccSize.width * 0.5, ccSize.height * 0.61)
    line:setScaleY(0.6)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    line:setPosition(ccSize.width * 0.5, ccSize.height * 0.1)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ccSize.width * 0.5, ccSize.height * 0.56)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ccSize.width * 0.5, ccSize.height * 0.66)
    self.controls.bg:addChild(line)

    local tishi = Common.finalFont("请抽取战斗奖励", ccSize.width * 0.5, ccSize.height * 0.61, 25, nil, 1)
    self.controls.bg:addChild(tishi)

    self.data.drawTab = {}
    self.data.isCanDraw = true
    for i=1,4 do
        local p = createMixSprite("image/ui/img/btn/btn_320.png")
        p:retain()
        p:setPosition(ccSize.width * 0.24 + (i - 1) * 160, ccSize.height * 0.38)
        self.controls.bg:addChild(p)
        p.isDraw = false
        p.num = i
        p:addTouchEventListener(function(sender, eventType)
            if (eventType == ccui.TouchEventType.ended) and self.data.isCanDraw then
                self.data.isCanDraw = false
                for k,v in pairs(self.data.drawTab) do
                    v:setTouchEnable(false)
                end
                sender.isDraw = true
                self:Draw(sender)
            end
        end)
        table.insert(self.data.drawTab, p)
    end

    for k,v in pairs(self.data.drawTab) do
        local scale1 = cc.ScaleTo:create(0.4, 1.2)
        local scale2 = cc.ScaleTo:create(0.05, 1)
        local orbit = cc.OrbitCamera:create(0.4,1, 0, 0, 360, 0, 0)
        v:runAction(cc.Sequence:create(cc.Spawn:create(scale1, orbit), scale2))
    end
   
    self.controls.compound = createMixSprite("image/ui/img/btn/btn_593.png")
    self.controls.compound:setCircleFont("确定", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    self.controls.compound:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.controls.compound:setPosition(ccSize.width * 0.5, ccSize.height * 0.1)
    self.controls.bg:addChild(self.controls.compound)
    self.controls.compound:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onCleanup()
        end
    end)
    self.controls.compound:setScale(0)
end

function DrawBox:drawAction(beforeNode, propsInfo, func)
    local function getPropsInfo()
        local idx = math.random(1, #self.data.drawTabs)
        local goods = Common.getGoods(self.data.drawTabs[idx], false)
        return goods
    end

    local drawProps = nil
    if propsInfo then
        drawProps = Common.getGoods(propsInfo, true)
    else
        drawProps = getPropsInfo()
    end
    if drawProps.setTips then
        drawProps:setTips(false)
    end
    local goodsConfig = drawProps:getGoodsConfigInfo()
    if goodsConfig.name then
        local name = Common.finalFont(goodsConfig.name, 0, -70, 18, nil, 1)
        drawProps:addChild(name)
    end
    drawProps:setVisible(false)
    self.controls.bg:addChild(drawProps)

    local posX, posY = beforeNode:getPosition()
    local orbit = cc.OrbitCamera:create(0.2,1, 0, 0, 80, 0, 0) 
    local func1 = cc.CallFunc:create(function()
        beforeNode:removeFromParent()
        drawProps:setVisible(true)
        if propsInfo then
            if drawProps.setChooseBorderVisible then
                drawProps:setChooseBorderVisible(true)
            else
                local border = cc.Sprite:create("image/icon/border/border_selected.png")
                border:setPosition(0, 0)
                drawProps:addChild(border)
            end
        end
        drawProps:setPosition(posX, posY)
        local orbit1 = cc.OrbitCamera:create(0.2,1, 0, -90, 90, 0, 0)
        local delay = cc.DelayTime:create(0.5)
        drawProps:runAction(cc.Sequence:create(orbit1, delay, cc.CallFunc:create(function()
            if func then
                func()
            end
        end)))
    end)
    beforeNode:runAction(cc.Sequence:create(orbit, func1))
end

function DrawBox:onCleanup()
    local isFromLootLayer = self.data.isFromLootLayer
    self:removeFromParent()
    self = nil
    if isFromLootLayer then
        application:popScene()
        -- application:popScene()
    end
end

--[[
    抽奖
]]--
function DrawBox:Draw(backProps)
    rpc:call("Loot.Draw", nil, function(event)
        if event.status == Exceptions.Nil then
            local info = event.result
            self.controls.compound:setScale(1)
            self:drawAction(backProps, info, function()
                for k,v in pairs(self.data.drawTab) do
                    if not v.isDraw then
                        self:drawAction(v)
                    end
                end
            end)
        end
    end)
end

return DrawBox

