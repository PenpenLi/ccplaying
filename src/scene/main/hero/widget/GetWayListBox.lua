local GoodsListTips = class("GoodsListTips", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")
local effects = require("tool.helper.Effects")

-- 面板类型
local COMPOUNDPANEL = 1
local LEVELPANEL = COMPOUNDPANEL + 1

local ArenaShopType = 2   
local ArenaShopOpenLevel = 14
local HomeShopType = 6   
local HomeShopOpenLevel = 18


function GoodsListTips:ctor(goodsType, goodsInfo, size)
    self.data.goodsItemType = goodsType
    self.data.goodsInfo = goodsInfo
    self.data.size = size
    self.data.viewSize = cc.size(self.data.size.width, self.data.size.height * 0.62)
    self.data.wayConfig = BaseConfig.GetGoodsSource(goodsInfo.Type, goodsInfo.ID)

    self.data.isOnlyOneWay = false
    self.data.isCanCompound = true
    self:createUI()
end

function GoodsListTips:createUI()
    self.controls.bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setScale9Enabled(true)
    self.controls.bg:setContentSize(self.data.size)
    self:addChild(self.controls.bg)

    local bg = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    bg:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.5)
    self.controls.bg:addChild(bg)

    local titleBg = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    titleBg:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.89)
    self.controls.bg:addChild(titleBg)

    self.controls.titleName = createMixSprite("image/ui/img/bg/bg_254.png")
    self.controls.titleName:setTouchEnable(false)
    self.controls.titleName:setCircleFont("获取途径", 1, 1, 25, cc.c3b(252, 255, 0), 1)
    self.controls.titleName:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.77)
    self.controls.bg:addChild(self.controls.titleName)

    self.controls.goodsItem = GoodsInfoNode.new(self.data.goodsItemType, self.data.goodsInfo, BaseConfig.GOODS_SMALLTYPE)
    self.controls.goodsItem:setPosition(self.data.size.width * 0.2, self.data.size.height * 0.89)
    self.controls.bg:addChild(self.controls.goodsItem)
    self.controls.goodsItem:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local panel = self:getChildByName("panel")
            if panel then
                panel:removeFromParent()
                panel = nil
            end
            local listUI = self:getWayListUI()
            self:addChild(listUI)
            if self.data.isOnlyOneWay then
                self:replacePanel(LEVELPANEL, self.data.size.width * 0.5)
            end

            local compound = self.controls.bg:getChildByTag(COMPOUNDPANEL)
            if compound then
                compound:removeFromParent()
                compound = nil
            end
            local level = self.controls.bg:getChildByTag(LEVELPANEL)
            if level then
                level:removeFromParent()
                level = nil
            end
            self.controls.titleName:setString("获取途径")
        end
    end)

    local listUI = self:getWayListUI()
    self:addChild(listUI)
    if self.data.isOnlyOneWay then
        self:replacePanel(LEVELPANEL, self.data.size.width * 0.5)
    end

    local node = cc.Node:create()
    self:addChild(node, 100)
    local function onTouchBegan(touch, event)
        self.data.isViewScroll = false
        return true
    end
    local function onTouchMoved(touch, event)
        local deltaPos = touch:getDelta()
        if math.abs(deltaPos.y) > 5 then
            self.data.isViewScroll = true
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function GoodsListTips:getWayListUI()
    local node = cc.Node:create()
    node:setName("panel")
    node:setPosition(-self.data.size.width * 0.5, -self.data.size.height * 0.42)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(self.data.viewSize)
    node:addChild(listView)

    local layoutSize = cc.size(self.data.size.width, 80)
    local function getLayout(text, func)
        local layout = ccui.Layout:create()
        layout:setTouchEnabled(false)
        layout:setContentSize(layoutSize)
        local bg = createMixSprite("image/ui/img/btn/btn_811.png",nil, "image/ui/img/btn/btn_810.png")
        bg:setTouchEnable(false)
        bg:setChildPos(0.5, 0)
        bg:setPosition(layoutSize.width * 0.5, layoutSize.height * 0.5)
        layout:addChild(bg)
        bg:getBg():setScaleX(0.8)
        bg:getChild():setScaleX(0.8)
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil,cc.size(140, 60))
        btn:setButtonBounce(false)
        btn:setCircleFont(text, 1, 1, 25, cc.c3b(238, 205, 142), 1)
        btn:setFontOutline(cc.c4b(70, 54, 14, 255), 1)
        btn:setPosition(layoutSize.width * 0.5, layoutSize.height * 0.5)
        btn:addTouchEventListener(function(sender, eventType, isInside)
            if eventType == ccui.TouchEventType.ended and isInside then
                func()
            end
        end)
        layout:addChild(btn)
        return layout
    end

    local wayNum = 0
    if self.data.wayConfig.ComposeID ~= 0 then
        wayNum = wayNum + 1
        local layout = getLayout("合成", function()
            self:replacePanel(COMPOUNDPANEL)
        end)
        listView:pushBackCustomItem(layout)
    end
    if (#self.data.wayConfig.InstanceList) ~= 0 then
        wayNum = wayNum + 1
        local layout = getLayout("通关", function()
            self:replacePanel(LEVELPANEL, self.data.size.width * 0.5)
        end)
        listView:pushBackCustomItem(layout)
    end
    if self.data.wayConfig.BuyType ~= 0 then
        wayNum = wayNum + 1
        local layout = getLayout("购买", handler(self, self.jumpGambleScene))
        listView:pushBackCustomItem(layout)
    end
    if self.data.wayConfig.ExchangeType ~= 0 then
        wayNum = wayNum + 1
        local layout = getLayout("兑换", handler(self, self.jumpExchangeScene, self.data.wayConfig.ExchangeType))
        listView:pushBackCustomItem(layout)
    end
    if self.data.wayConfig.Tower ~= 0 then
        wayNum = wayNum + 1
        local layout = getLayout("爬塔", handler(self, self.jumpTowerScene))
        listView:pushBackCustomItem(layout)
    end

    if (wayNum == 1) and ((#self.data.wayConfig.InstanceList) ~= 0) then
        self.data.isOnlyOneWay = true
    end

    return node
end

function GoodsListTips:compoundUI()
    local node = cc.Node:create()
    node:setName("panel")
    node:setPosition(-self.data.size.width * 0.5, -self.data.size.height * 0.42)

    local compoundId = BaseConfig.GetProps(self.data.goodsInfo.ID).useValue
    self.data.fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_252.png")
    bg:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.42)
    node:addChild(bg)

    local goodsItem = GoodsInfoNode.new(self.data.goodsItemType, self.data.goodsInfo, BaseConfig.GOODS_MIDDLETYPE)
    goodsItem:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.5)
    goodsItem:setTouchEnable(false)
    node:addChild(goodsItem)

    local compoundItem = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, self.data.goodsInfo, BaseConfig.GOODS_SMALLTYPE)
    compoundItem:setPosition(self.data.size.width * 0.24, self.data.size.height * 0.3)
    node:addChild(compoundItem)
    compoundItem:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local fragWayConfig = BaseConfig.GetGoodsSource(BaseConfig.GT_PROPS, self.data.goodsInfo.ID)
            self:compoundFragWayPanel(fragWayConfig)
        end
    end)

    if self.controls.goodsCompoundNum then
        self.controls.goodsCompoundNum = nil
    end
    self.controls.goodsCompoundNum = ColorLabel.new("")
    self.controls.goodsCompoundNum:setPosition(self.data.size.width * 0.25, 100)
    self.controls.goodsCompoundNum:setAnchorPoint(0.5, 1)
    node:addChild(self.controls.goodsCompoundNum)
    local fragNum = self:getFragNum(self.data.goodsInfo.ID)
    if fragNum >= self.data.fragToEquipConfig.num then
        self.controls.goodsCompoundNum:setString("[239,239,168]"..fragNum.."[=][255,255,255]/"..self.data.fragToEquipConfig.num.."[=]")
    else
        self.controls.goodsCompoundNum:setString("[249,24,24]"..fragNum.."/"..self.data.fragToEquipConfig.num.."[=]")
    end

    local priceImg = cc.Sprite:create("image/icon/props/coin.png")
    priceImg:setScale(0.66)
    priceImg:setPosition(self.data.size.width * 0.76, self.data.size.height * 0.3)
    node:addChild(priceImg)
    local price = ColorLabel.new("")
    price:setPosition(self.data.size.width * 0.76, 100)
    price:setAnchorPoint(0.5, 1)
    node:addChild(price)
    
    if GameCache.Avatar.Coin >= self.data.fragToEquipConfig.coin then
        price:setString("[239,239,168]"..Common.numConvert(GameCache.Avatar.Coin).."[=][255,255,255]/"..Common.numConvert(self.data.fragToEquipConfig.coin).."[=]")
    else
        price:setString("[249,24,24]"..Common.numConvert(GameCache.Avatar.Coin).."/"..Common.numConvert(self.data.fragToEquipConfig.coin).."[=]")
    end

    local btn_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    btn_bg:setContentSize(cc.size(self.data.size.width * 0.94, 90))
    btn_bg:setPosition(self.data.size.width * 0.5, 20)
    node:addChild(btn_bg)
    local btn_compound = createMixSprite("image/ui/img/btn/btn_593.png")
    btn_compound:setCircleFont("合成", 1, 1, 25, cc.c3b(251, 202, 118), 1)
    btn_compound:setFontOutline(cc.c4b(77, 36, 0, 255), 2)
    btn_compound:setPosition(self.data.size.width * 0.5, 20)
    node:addChild(btn_compound)
    btn_compound:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            if (GameCache.Avatar.Coin >= self.data.fragToEquipConfig.coin)
                and (fragNum >= self.data.fragToEquipConfig.num) and self.data.isCanCompound then
                self.data.isCanCompound = false
                local id = self.data.goodsInfo.ID
                rpc:call("Props.CompoundEquip", {ID = id, Count = 1}, function(event)
                    if event.status == Exceptions.Nil then
                        fragNum = event.result.Num
                        self:FragCompoundEquip(id, fragNum)
                        if fragNum >= self.data.fragToEquipConfig.num then
                            self.controls.goodsCompoundNum:setString("[239,239,168]"..fragNum.."[=][255,255,255]/"..self.data.fragToEquipConfig.num.."[=]")
                        else
                            self.controls.goodsCompoundNum:setString("[249,24,24]"..fragNum.."/"..self.data.fragToEquipConfig.num.."[=]")
                        end
                        if GameCache.Avatar.Coin >= self.data.fragToEquipConfig.coin then
                            price:setString("[239,239,168]"..Common.numConvert(GameCache.Avatar.Coin).."[=][255,255,255]/"..Common.numConvert(self.data.fragToEquipConfig.coin).."[=]")
                        else
                            price:setString("[249,24,24]"..Common.numConvert(GameCache.Avatar.Coin).."/"..Common.numConvert(self.data.fragToEquipConfig.coin).."[=]")
                        end

                        application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateHeroInfo, {})
                        application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateEquipIntensify, {})
                        local parent = self:getParent()
                        if parent then
                            parent:onEnter()
                        end
                    end
                    self.data.isCanCompound = true
                end)
            elseif fragNum < self.data.fragToEquipConfig.num then
                application:showFlashNotice("个数不足~!")
            elseif GameCache.Avatar.Coin < self.data.fragToEquipConfig.coin then
                application:showFlashNotice("银币不足~!")
            end
        end
    end)

    return node
end

function GoodsListTips:levelMapUI(instanceList)
    local node = cc.Node:create()
    node:setName("panel")
    node:setPosition(-self.data.size.width * 0.5, -self.data.size.height * 0.42)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(self.data.viewSize)
    node:addChild(listView)
    local function addLayoutToList(nodeID, difficulty, isLock)
        local layoutSize = cc.size(self.data.size.width, 80)
        local layout = ccui.Layout:create()
        layout:setContentSize(layoutSize)

        local zhangName, nodeName, difficultyName = Common.getInstanceName(nodeID, difficulty)
        local name = zhangName..nodeName..difficultyName
        local bg = createMixSprite("image/ui/img/bg/bg_251.png")
        bg:setButtonBounce(false)
        bg:setPosition(layoutSize.width * 0.5, layoutSize.height * 0.5)
        bg:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended and (not self.data.isViewScroll) then
                application:pushScene("main.mapinstance.MapInstanceScene", nodeID, difficulty)
            end
        end)
        layout:addChild(bg)
        local zhang = Common.finalFont(zhangName , layoutSize.width * 0.3, layoutSize.height * 0.65,nil,nil, 1)
        zhang:setAnchorPoint(0, 0.5)
        layout:addChild(zhang)
        local node = Common.finalFont(nodeName.."("..difficultyName..")", 
                                    layoutSize.width * 0.3, layoutSize.height * 0.35,nil,cc.c3b(133, 185, 237), 1)
        node:setAnchorPoint(0, 0.5)
        layout:addChild(node)
        local go = effects:CreateAnimation(layout, layoutSize.width * 0.8, layoutSize.height * 0.5, nil, 17, true)

        local lockDesc = Common.finalFont("未通关", 
                                    layoutSize.width * 0.76, layoutSize.height * 0.5,nil,nil,1)
        layout:addChild(lockDesc)

        if isLock then
            bg:setNorGLProgram(false)
            bg:setTouchEnable(false)
            go:setScale(0)
        else
            bg:setNorGLProgram(true)
            lockDesc:setScale(0)
        end

        listView:pushBackCustomItem(layout)
    end
    
    local currMap = Common.getInstanceCurrNode()
    local zhang = tonumber(string.sub(currMap, 2, 3))
    local zhangNode = tonumber(string.sub(currMap, 4, 5))
    CCLog(currMap, "currMap==============", zhang, "------------", zhangNode)

    -- 如果是每章都要掉落的情况
    if instanceList[1].ID == 0 then
        -- node处于第一章且小于5时显示的获取信息
        local function nodeLessthanFive()
            for i=1,zhangNode do
                local nodeID = tonumber("1010"..i)
                addLayoutToList(nodeID, instanceList[1].Type)
            end
        end
        -- node处于第一章且大于于5时或者大于第一章显示的获取信息
        local function nodeGreaterthanFive()
            if zhangNode > 5 then
                for i=(zhangNode - 4),zhangNode do
                    local nodeID = tonumber("1"..string.format("%02d", zhang)..string.format("%02d", i))
                    addLayoutToList(nodeID, instanceList[1].Type)
                end
            else
                local nodeIDTab = {}
                -- 章node数不够时依次向上一章递归
                --[[
                    zhang, zhangNodes, currNeedNode
                    当前章，当前章总节点数，当前需要显示的节点数(总共要显示5个节点)
                ]]--
                local function getBeforeZhang(zhang, zhangNodes, currNeedNode)
                    local surplusNode = zhangNodes - currNeedNode
                    if surplusNode < 0 then
                        for i=zhangNodes,1, -1 do
                            local nodeID = tonumber("1"..string.format("%02d", zhang)..string.format("%02d", i))
                            table.insert(nodeIDTab, nodeID)
                        end

                        surplusNode = -surplusNode
                        local beforeZhang = tonumber(zhang - 1)
                        local beforeZhangNodes = Common.getInstanceCount(beforeZhang)
                        getBeforeZhang(beforeZhang, beforeZhangNodes, surplusNode)
                    else
                        for i=zhangNodes,(surplusNode + 1), -1 do
                            local nodeID = tonumber("1"..string.format("%02d", zhang)..string.format("%02d", i))
                            table.insert(nodeIDTab, nodeID)
                        end
                    end
                end
                getBeforeZhang(zhang, zhangNode, 5)
                for i=5,1,-1 do
                    addLayoutToList(tonumber(nodeIDTab[i]), instanceList[1].Type)
                end
            end
        end
        if zhang > 1 then
            nodeGreaterthanFive()
        else
            if zhangNode > 5 then
                nodeGreaterthanFive()
            else
                nodeLessthanFive()
            end
        end
    else
        -- 只有普通副本时
        local normalMapTabs = {}
        for k,v in pairs(instanceList) do
            if (v.Type == 1) or (v.Type == 2) then
                table.insert(normalMapTabs, v)
            end
        end
        if (#normalMapTabs) < 5 then
            for k,v in pairs(normalMapTabs) do
                local isLock = Common.isInstanceNodeLock(v.ID, v.Type)
                addLayoutToList(v.ID, v.Type, isLock)
            end
            -- 还可能有传记副本时
        else
            for i=1,5 do
                local mapValue = normalMapTabs[i]
                local isLock = Common.isInstanceNodeLock(mapValue.ID, mapValue.Type)
                addLayoutToList(mapValue.ID, mapValue.Type, isLock)
            end
        end
    end

    return node
end

function GoodsListTips:replacePanel(panelType, posX, isFrag)
    local panel = self:getChildByName("panel")
    if panel then
        panel:removeFromParent()
        panel = nil
    end

    local newPanel = nil 
    if panelType == COMPOUNDPANEL then
        newPanel = self:compoundUI()
        local compound = self.controls.bg:getChildByTag(COMPOUNDPANEL)
        if nil == compound then
            local btn_compound = GoodsInfoNode.new(self.data.goodsItemType, self.data.goodsInfo, BaseConfig.GOODS_SMALLTYPE)
            btn_compound:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.89)
            self.controls.bg:addChild(btn_compound)
            btn_compound:setTag(COMPOUNDPANEL)
            btn_compound:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.controls.titleName:setString(btn_compound:getGoodsConfigInfo().name)

                    self:replacePanel(COMPOUNDPANEL)
                    local level = self.controls.bg:getChildByTag(LEVELPANEL)
                    if level then
                        level:removeFromParent()
                        level = nil
                    end
                end
            end)
            local tiao = cc.Sprite:create("image/ui/img/btn/btn_809.png")
            local size = btn_compound:getContentSize()
            tiao:setPosition(-size.width * 0.8, 0)
            btn_compound:addChild(tiao)
            self.controls.titleName:setString(btn_compound:getGoodsConfigInfo().name)
        end
    elseif panelType == LEVELPANEL then
        if not isFrag then
            local instanceList = self.data.wayConfig.InstanceList
            newPanel = self:levelMapUI(instanceList)
        else
            local wayConfig = BaseConfig.GetGoodsSource(BaseConfig.GT_PROPS, self.data.goodsInfo.ID)
            local instanceList = wayConfig.InstanceList
            newPanel = self:levelMapUI(instanceList)
        end
        local level = self.controls.bg:getChildByTag(LEVELPANEL)
        if (not level) and (not self.data.isOnlyOneWay) then
            local goodsType = self.data.goodsItemType
            if isFrag then
                goodsType = BaseConfig.GOODS_FRAG
            end
            local goodsItem = GoodsInfoNode.new(goodsType, self.data.goodsInfo, BaseConfig.GOODS_SMALLTYPE)
            goodsItem:setPosition(posX, self.data.size.height * 0.89)
            self.controls.bg:addChild(goodsItem)
            goodsItem:setTag(LEVELPANEL)
            goodsItem:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:replacePanel(LEVELPANEL, posX, isFrag)
                end
            end)
            local tiao = cc.Sprite:create("image/ui/img/btn/btn_809.png")
            local size = goodsItem:getContentSize()
            tiao:setPosition(-size.width * 0.8, 0)
            goodsItem:addChild(tiao)

            self.controls.titleName:setString(goodsItem:getGoodsConfigInfo().name)
        end
    end
    self:addChild(newPanel)
end

function GoodsListTips:compoundFragWayPanel(fragWayConfig)
    local wayNum = 0
    local function createButton(panel, text, callFunc)
        local bg = createMixSprite("image/ui/img/btn/btn_811.png",nil, "image/ui/img/btn/btn_810.png")
        bg:setTouchEnable(false)
        bg:setChildPos(0.5, 0)
        bg:setPosition(self.data.size.width * 0.5, self.data.size.height - 140 - wayNum * 80)
        panel:addChild(bg)
        bg:getBg():setScaleX(0.8)
        bg:getChild():setScaleX(0.8)
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil,cc.size(140, 60))
        btn:setButtonBounce(false)
        btn:setCircleFont(text, 1, 1, 25, cc.c3b(238, 205, 142), 1)
        btn:setFontOutline(cc.c4b(70, 54, 14, 255), 1)
        btn:setPosition(self.data.size.width * 0.5, self.data.size.height - 140 - wayNum * 80)
        btn:addTouchEventListener(function(sender, eventType, isInside)
            if eventType == ccui.TouchEventType.ended and isInside then
                if callFunc then
                    callFunc()
                end
            end
        end)
        panel:addChild(btn)
    end

    if next(fragWayConfig.InstanceList) then
        self:replacePanel(LEVELPANEL, self.data.size.width * 0.8, true)
    else
        local panel = self:getChildByName("panel")
        if panel then
            panel:removeFromParent()
            panel = nil
        end

        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, self.data.goodsInfo, BaseConfig.GOODS_SMALLTYPE)
        goodsItem:setPosition(self.data.size.width * 0.8, self.data.size.height * 0.89)
        self.controls.bg:addChild(goodsItem)
        goodsItem:setTag(LEVELPANEL)
        local tiao = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        local size = goodsItem:getContentSize()
        tiao:setPosition(-size.width * 0.8, 0)
        goodsItem:addChild(tiao)
        self.controls.titleName:setString(goodsItem:getGoodsConfigInfo().name)

        local newPanel = cc.Node:create()
        newPanel:setName("panel")
        newPanel:setPosition(-self.data.size.width * 0.5, -self.data.size.height * 0.42)
        self:addChild(newPanel)

        if fragWayConfig.BuyType ~= 0 then
            wayNum = wayNum + 1
            createButton(newPanel, "购买", handler(self, self.jumpGambleScene))
        end
        if fragWayConfig.ExchangeType ~= 0 then
            wayNum = wayNum + 1
            createButton(newPanel, "兑换", handler(self, self.jumpExchangeScene, fragWayConfig.ExchangeType))
        end
    end
end

function GoodsListTips:getFragNum(fragID)
    local fragInfo = GameCache.GetFrag(fragID)
    if fragInfo then
        return fragInfo.Num
    else
        return 0
    end
end

function GoodsListTips:FragCompoundEquip(fragID, currFragTotal)
    local fragToEquipConfig = self.data.fragToEquipConfig
    --碎片减少
    local propsInfo = {}
    propsInfo.ID = fragID
    propsInfo.Num = currFragTotal
    GameCache.addProps(propsInfo, true)
    GameCache.minusFrag(fragID, 0)

    --装备增加
    GameCache.addEquip(fragToEquipConfig.productID, fragToEquipConfig.starLevel, 1)
end

function GoodsListTips:playOpenAction()
    local width = self.data.size.width
    local height = self.data.size.height
    local moveRight = cc.MoveBy:create(0.1, cc.p(width * 0.62, 0))
    local moveLeft = cc.MoveBy:create(0.05, cc.p(-width * 0.1, 0))
    self:runAction(cc.Sequence:create(moveRight, moveLeft))
end

function GoodsListTips:playCloseAction()
    local scale1 = cc.ScaleTo:create(0.08, 1, 1.2)
    local scale2 = cc.ScaleTo:create(0.05, 1, 0)
    self.controls.bg:runAction(cc.Sequence:create(scale1, scale2))
end

function GoodsListTips:jumpExchangeScene(exchangeType)
    local isOpen = nil
    if exchangeType == ArenaShopType then
        if GameCache.Avatar.Level >= ArenaShopOpenLevel then
            isOpen = true
        end
    elseif exchangeType == HomeShopType then
        if GameCache.Avatar.Level >= HomeShopOpenLevel then
            isOpen = true
        end
    else
        isOpen = true
    end

    if isOpen then
        local layer = require("scene.main.ExchangeMall").new(exchangeType, function()
            application:dispatchCustomEvent(AppEvent.UI.Tips.UpdateInfo, {})
        end, self.data.goodsInfo.ID)
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer) 
    else
        application:showFlashNotice("等级不足,无法进入~")
    end
end

function GoodsListTips:jumpGambleScene()
    local handler = function(event)
        if event.status == Exceptions.Nil and event.result ~= nil then                    
            local value = event.result
            self.data.infoTab = {}
            self.data.allInfo = {}
            self.data.infoTab[1] = self.data.allInfo
            self.data.vipInfo = {}
            self.data.infoTab[2] = self.data.vipInfo
            self.data.heroInfo = {}
            self.data.infoTab[3] = self.data.heroInfo
            self.data.equipInfo = {}
            self.data.infoTab[4] = self.data.equipInfo
            
            self.data.allInfo.AllBuyFreeCount = value.AllBuyFreeCount
            self.data.allInfo.AllTotalFreeCount = value.AllTotalFreeCount
            self.data.allInfo.AllNextFreeTime = value.AllNextFreeTime
            self.data.allInfo.AllBuyCost = value.AllBuyCost
            self.data.vipInfo.VipWeekHot = value.VipWeekHot
            self.data.vipInfo.VipDailyHot = value.VipDailyHot
            self.data.vipInfo.VipBuyCost = value.VipBuyCost
            self.data.heroInfo.HeroNextFreeTime = value.HeroNextFreeTime
            self.data.heroInfo.HeroBuyCost = value.HeroBuyCost
            self.data.equipInfo.EquipNextFreeTime = value.EquipNextFreeTime
            self.data.equipInfo.EquipBuyCost = value.EquipBuyCost

            application:pushScene("main.gamble.GambleScene", self.data.infoTab) 
        end
    end
    rpc:call("Gamble.GetGambleInfo", nil, handler)
end

function GoodsListTips:jumpTowerScene()
    if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.tower then
        Common.openLevelDesc(BaseConfig.OpenSystemLevel.tower)
        return
    end

    rpc:call("Tower.Info", nil, function (event)
        if event.status == Exceptions.Nil and event.result ~= nil then
            application:pushScene("main.tower.TowerScene", event.result)
        end
    end)
end

return GoodsListTips

