local CurrencyIcon = class("CurrencyIcon", function()
    local self = cc.Node:create()
    self.controls = {}
    self.handlers = {}
    self.data = {}

    local function onNodeEvent(event)
        if event == "cleanup" then
            if not tolua.isnull(self.controls.tipsBg) and self.data.isShowTips then
                self:closeTips()
                self.controls.tipsBg:removeFromParent()
                self.controls.tipsBg = nil
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return self
end)

local GoldType = 1001
local CoinTye = 1002
local ArenaCreditsType = 1003
local LeagueDevoteType = 1004
local ErrantryType = 1005
local EquipTokenType = 1006
local TowerCreditsType = 1007
local SkillPointType = 1008
local FairySkillPointType = 1009
local HomeMedal = 1010
local HomeWood = 1011
local CostCredits = 1012

local LayerTag = 1
local BgTag = LayerTag + 1
local ZhangTag = BgTag + 1
local NodeTag = ZhangTag + 1
local GoTag = NodeTag + 1

function CurrencyIcon:ctor(goodsInfo, sizeType)
    self.data.BIGSIZETYPE = BaseConfig.GOODS_BIGTYPE
    self.data.MIDDLESIZETYPE = BaseConfig.GOODS_MIDDLETYPE
    self.data.SMALLSIZETYPE = BaseConfig.GOODS_SMALLTYPE

    self.data.sizeTab = {cc.size(100, 100), cc.size(88, 88), cc.size(60, 60), cc.size(25, 25)}
    self.data.scaleValueTab = {1, 0.88, 0.6, 0.25}

    self.data.sizeType = sizeType or self.data.BIGSIZETYPE
    self.data.size = self.data.sizeTab[self.data.sizeType]

    self:setGoodsInfo(goodsInfo)
    self:createUI()
    self:setListener()

    self.data.isTouchEnable = true
end

function CurrencyIcon:setGoodsInfo(goodsInfo)
    self.data.goodsInfo = goodsInfo
    self.data.goodsConfigInfo = BaseConfig.getCurrencyConfig(self.data.goodsInfo.ID)
end

function CurrencyIcon:createUI()
    local path = self:getTexturePath()
    self.controls.currencySpri = cc.Sprite:create(path)
    self:addChild(self.controls.currencySpri)
    self.controls.currencySpri:setScale(self.data.scaleValueTab[self.data.sizeType])
end

function CurrencyIcon:getTexturePath()
    local path = nil
    if self.data.goodsInfo.ID == GoldType then
        path = "image/icon/props/gold.png"
    elseif self.data.goodsInfo.ID == CoinTye then
        path = "image/icon/props/coin.png"
    elseif self.data.goodsInfo.ID == ArenaCreditsType then
        path = "image/icon/props/arena.png"
    elseif self.data.goodsInfo.ID == LeagueDevoteType then
        path = "image/icon/props/skillPoint.png"
    elseif self.data.goodsInfo.ID == ErrantryType then
        path = "image/icon/props/errantry.png"
    elseif self.data.goodsInfo.ID == EquipTokenType then
        path = "image/icon/props/equipToken.png"
    elseif self.data.goodsInfo.ID == TowerCreditsType then
        path = "image/icon/props/tower.png"
    elseif self.data.goodsInfo.ID == SkillPointType then
        path = "image/icon/props/skillPoint.png"
    elseif self.data.goodsInfo.ID == FairySkillPointType then
        path = "image/icon/props/heart.png"
    elseif self.data.goodsInfo.ID == HomeMedal then
        path = "image/icon/props/medal.png"
    elseif self.data.goodsInfo.ID == HomeWood then
        path = "image/icon/props/wood.png"
    elseif self.data.goodsInfo.ID == CostCredits then
        path = "image/icon/props/costCredits.png"
    end
    return path
end

function CurrencyIcon:setListener()
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if not self.data.isTouchEnable then
            return false
        end

        if self.data.isTouchDown then
            if self.data.isShowTips then
                self:closeTips()
            end
            return false
        end

        self.data.scaleValue = self:getScale()
        if cc.rectContainsPoint(rect, locationInNode) then
            if not self.data.isTouchDown then
                self.data.isTouchDown = true
            end

            self:setScale(self.data.scaleValue * 0.95)
            if self.data.func then
                self.data.func(self, ccui.TouchEventType.began)
            end
            if self.data.isShowGetWay then
                self:getGoodsWayTips()
            end
            if self.data.isShowTips then
                self:openTips()
            end
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            self:setScale(self.data.scaleValue * 0.95)
            if self.data.func then
                self.data.func(self, ccui.TouchEventType.moved, true)
            end
        else
            self:setScale(self.data.scaleValue * 1)
            if self.data.func then
                self.data.func(self, ccui.TouchEventType.moved, false)
            end
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        self.data.isTouchDown = false
        self:setScale(self.data.scaleValue * 1)
        if self.data.isShowTips then
            self:closeTips()
        end
        if cc.rectContainsPoint(rect, locationInNode) then
            if self.data.func then
                self.data.func(self, ccui.TouchEventType.ended)
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.currencySpri)
end

function CurrencyIcon:updateGoodsInfo(goodsInfo)
    self:setGoodsInfo(goodsInfo)

    local path = self:getTexturePath()
    self.controls.currencySpri:setTexture(texture)
end

function CurrencyIcon:setNum(num)
    local num = num or self.data.goodsInfo.Num
    if num then
        local str = Common.numConvert(num)

        if self.controls.num then
            self.controls.num:setString(str)
        else
            self.controls.num = Common.finalFont(str, self.data.size.width * 0.46, -self.data.size.height * 0.48, 18, nil, 1)
            self.controls.num:setAnchorPoint(1, 0)
            self:addChild(self.controls.num)
            self.controls.num:setAdditionalKerning(-2)
        end
    end
end

function CurrencyIcon:setNumVisible(visible)
    if self.controls.num then
        self.controls.num:setVisible(visible)
    end
end

function CurrencyIcon:getIconSpri()
    return self.controls.currencySpri
end

function CurrencyIcon:setTouchEnable(value)
    self.data.isTouchEnable = value
end

function CurrencyIcon:getContentSize()
    return self.data.size
end

function CurrencyIcon:getGoodsInfo()
    return self.data.goodsInfo
end

function CurrencyIcon:getGoodsConfigInfo()
    return self.data.goodsConfigInfo
end

function CurrencyIcon:addTouchEventListener(event)
    self.data.func = event
end

function CurrencyIcon:setTips(visible)
    self.data.isShowTips = visible
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1/60), cc.CallFunc:create(function()
        self:createTips()
    end)))
end

function CurrencyIcon:setGetWay(visible)
    self.data.isShowGetWay = visible
end

function CurrencyIcon:createTips()
    local node = cc.Node:create()
    local tipsSize = cc.size(420, 190)
    self.controls.tipsBg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    self.controls.tipsBg:setScale9Enabled(true)
    self.controls.tipsBg:setContentSize(tipsSize)
    node:addChild(self.controls.tipsBg)
    self.controls.tipsBg:setVisible(false)

    local path = self:getTexturePath()
    self.controls.tipsSpri = cc.Sprite:create(path)
    self.controls.tipsSpri:setScale(self.data.scaleValueTab[self.data.SMALLSIZETYPE])
    self.controls.tipsSpri:setPosition(60, tipsSize.height - 65)
    self.controls.tipsBg:addChild(self.controls.tipsSpri)

    self.controls.tipsName = Common.finalFont(self.data.goodsConfigInfo.Name, 1, 1, 22, cc.c3b(0,162,255), 1)
    self.controls.tipsName:setPosition(tipsSize.width * 0.5, tipsSize.height - 65)
    self.controls.tipsBg:addChild(self.controls.tipsName)

    self.controls.tipsDesc = Common.finalFont(self.data.goodsConfigInfo.Desc, 1, 1, 18, nil, 1)
    self.controls.tipsDesc:setAnchorPoint(0, 1)
    self.controls.tipsDesc:setPosition(30, tipsSize.height - 110)
    self.controls.tipsBg:addChild(self.controls.tipsDesc)
    self.controls.tipsDesc:setDimensions(350, 60)

    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(node)
end

function CurrencyIcon:updateTips()
    local path = self:getTexturePath()
    self.controls.tipsSpri:setTexture(path)
    self.controls.tipsName:setString(self.data.goodsConfigInfo.Name)
    self.controls.tipsDesc:setString(self.data.goodsConfigInfo.Desc)
end

function CurrencyIcon:openTips()
    self:updateTips()
    local tipsSize = self.controls.tipsBg:getContentSize()
    local selfPos = self:convertToWorldSpace(cc.p(0, 0))
    local newPos = {}
    --左右
    if (selfPos.x + tipsSize.width) >= SCREEN_WIDTH then
        newPos.x = selfPos.x -tipsSize.width * 0.5
    else
        newPos.x = selfPos.x + tipsSize.width * 0.5
    end
    --上下
    if (selfPos.y + tipsSize.height) >= SCREEN_HEIGHT then
        newPos.y = selfPos.y -tipsSize.height * 0.5
    else
        newPos.y = selfPos.y + tipsSize.height * 0.5
    end
    self.controls.tipsBg:setPosition(newPos.x, newPos.y)

    self.controls.tipsBg:stopAllActions()
    self.controls.tipsBg:setVisible(true)
    self.controls.tipsBg:setScaleY(0)
    self.controls.tipsBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.06, 1, 1.2), cc.ScaleTo:create(0.1, 1, 1)))
end

function CurrencyIcon:closeTips()
    if not tolua.isnull(self.controls.tipsBg) then
        self.controls.tipsBg:stopAllActions()
        self.controls.tipsBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 1, 1.2), cc.ScaleTo:create(0.05, 1, 0), 
            cc.CallFunc:create(function()
            self.controls.tipsBg:setVisible(false)
        end)))
    end
end

function CurrencyIcon:getGoodsWayTips()
    local node = cc.Node:create()
    local bgSize = cc.size(360, 500)
    local tipsBg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    tipsBg:setScale9Enabled(true)
    tipsBg:setContentSize(bgSize)
    node:addChild(tipsBg)

    local path = self:getTexturePath()
    local goodsSpri = cc.Sprite:create(path)
    goodsSpri:setScale(0.8)
    goodsSpri:setPosition(bgSize.width * 0.5, bgSize.height * 0.88)
    tipsBg:addChild(goodsSpri)

    local titleName = createMixSprite("image/ui/img/bg/bg_254.png")
    titleName:setTouchEnable(false)
    titleName:setCircleFont(self.data.goodsConfigInfo.Name.."获取途径", 1, 1, 22, cc.c3b(252, 255, 0), 1)
    titleName:setPosition(bgSize.width * 0.5, bgSize.height * 0.75)
    tipsBg:addChild(titleName)

    self.data.wayConfig = BaseConfig.GetGoodsSource(self.data.goodsInfo.Type, self.data.goodsInfo.ID)
    local instanceList = self.data.wayConfig.InstanceList
    local normalMapTabs = {}
    for k,v in pairs(instanceList) do
        if (v.Type == 1) or (v.Type == 2) then
            table.insert(normalMapTabs, v)
        end
    end

    local viewSize = cc.size(bgSize.width * 0.9, bgSize.height * 0.62)
    local function tableCellTouched(table,cell)
        CCLog("cell touched at index: ",cell:getIdx())
        local instanceInfo = normalMapTabs[cell:getIdx() + 1]
        local isLock = Common.isInstanceNodeLock(instanceInfo.ID, instanceInfo.Type)
        if not isLock then
            application:pushScene("main.mapinstance.MapInstanceScene", instanceInfo.ID, instanceInfo.Type)
        end
    end
    local function cellSizeForTable(table,idx) 
        return viewSize.height * 0.25,viewSize.width
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local function updatePanel(layer)
            local bg = layer:getChildByTag(BgTag)
            local zhang = layer:getChildByTag(ZhangTag)
            local zhangNode = layer:getChildByTag(NodeTag)
            local goEffect = layer:getChildByTag(GoTag)

            local instanceInfo = normalMapTabs[idx + 1]
            local isLock = Common.isInstanceNodeLock(instanceInfo.ID, instanceInfo.Type)
            if isLock then
                bg:setState(1)
                goEffect:setVisible(false)
            else
                bg:setState(0)
                goEffect:setVisible(true)
            end
            local zhangName, nodeName, difficultyName = Common.getInstanceName(instanceInfo.ID, instanceInfo.Type)
            zhang:setString(zhangName)
            zhangNode:setString(nodeName.."("..difficultyName..")")
        end
        local function getLayout()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,0,0), viewSize.width, viewSize.height * 0.25 - 10)
            layerColor:setTag(LayerTag)
            local layerSize = layerColor:getContentSize()

            local bg = cc.Sprite:create("image/ui/img/bg/bg_251.png")
            bg:setTag(BgTag)
            layerColor:addChild(bg)
            bg:setPosition(layerSize.width * 0.5, layerSize.height * 0.5)
            
            local zhang = Common.finalFont("zhang" , layerSize.width * 0.15, layerSize.height * 0.66,nil,nil, 1)
            zhang:setTag(ZhangTag)
            zhang:setAnchorPoint(0, 0.5)
            layerColor:addChild(zhang)
            local zhangNode = Common.finalFont("node" , layerSize.width * 0.15, layerSize.height * 0.34,nil,cc.c3b(133, 185, 237), 1)
            zhangNode:setTag(NodeTag)
            zhangNode:setAnchorPoint(0, 0.5)
            layerColor:addChild(zhangNode)

            local goEffect = load_animation("image/spine/ui_effect/17/")
            goEffect:setTag(GoTag)
            goEffect:setAnimation(0, "animation", true)
            goEffect:setPosition(layerSize.width * 0.75, layerSize.height * 0.5)
            layerColor:addChild(goEffect)
            return layerColor
        end

        local layerColor = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            layerColor = getLayout()
            cell:addChild(layerColor)
        else
            layerColor = cell:getChildByTag(LayerTag)
        end
        updatePanel(layerColor)

        return cell
    end
    local function numberOfCellsInTableView(table)
        return (#normalMapTabs)
    end
    local wayList = cc.TableView:create(viewSize)
    wayList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    wayList:setDelegate()
    wayList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    wayList:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    wayList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    wayList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    wayList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    wayList:reloadData()
    tipsBg:addChild(wayList)
    wayList:setPosition(16, 36)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            node:removeFromParent()
            node = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tipsBg)

    local scene = cc.Director:getInstance():getRunningScene()
    node:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    scene:addChild(node)
end

return CurrencyIcon

