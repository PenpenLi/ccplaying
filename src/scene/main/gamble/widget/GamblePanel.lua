local GamblePanel = class("GamblePanel", function()
    local node = cc.Node:create()
    node.controls = {}
    node.handlers = {}
    node.data = {}
    return node
end)
local effects = require("tool.helper.Effects")
local CommonView = require("tool.helper.CommonView")

local ALLPANEL = 1
local VIPPANEL = ALLPANEL + 1
local HEROPANEL = VIPPANEL + 1
local EQUIPPANEL = HEROPANEL + 1

local SMALLPANEL = 1
local MIDDLEPANEL = SMALLPANEL + 1
local BIGPANEL = MIDDLEPANEL + 1

local ZORDER = 2

local smallPath = nil
local middlePath = nil
local bigPath = nil
local leftPath = nil

--[[
    boxType -- 1、综合，2、VIP，3、星将，4、装备
]]
function GamblePanel:ctor(boxType, size)
    self.data.boxType = boxType
    self.data.bgSize = size
    self.data.currPanel = MIDDLEPANEL
    self.data.isTouch = true -- 在播放动作时不允许有操作
    self.data.fontSpriTab = {} -- 把名字图片存在一起方便管理
    self.controls.middleStoneLight = nil
    self.controls.middleStoneSpri = nil
    self.controls.middleFontSpri = nil
    self.controls.bigBottomSpri = nil
    self.data.isFree = true
    self.data.isCanBuy = true

    if boxType == 1 then
        bigPath = "image/ui/img/bg/bg_227.png"
        smallPath = "image/ui/img/bg/bg_220.png"
        middlePath = "image/ui/img/bg/bg_214.png"
        leftPath = "image/ui/img/bg/bg_223.png"
    elseif boxType == 2 then
        bigPath = "image/ui/img/bg/bg_217.png"
        smallPath = "image/ui/img/bg/bg_218.png"
        middlePath = "image/ui/img/bg/bg_216.png"
        leftPath = "image/ui/img/bg/bg_221.png"
    elseif boxType == 3 then
        bigPath = "image/ui/img/bg/bg_217.png"
        smallPath = "image/ui/img/bg/bg_288.png"
        middlePath = "image/ui/img/bg/bg_287.png"
        leftPath = "image/ui/img/bg/bg_289.png"
    else
        bigPath = "image/ui/img/bg/bg_217.png"
        smallPath = "image/ui/img/bg/bg_219.png"
        middlePath = "image/ui/img/bg/bg_215.png"
        leftPath = "image/ui/img/bg/bg_222.png"
    end

    self.controls.bigNode = cc.Sprite:create(bigPath)
    self.controls.bigNode:setPosition(self.data.bgSize.width * 0.348, self.data.bgSize.height * 0.5)
    self:addChild(self.controls.bigNode)
    self.controls.bigNode:setTag(BIGPANEL)
    self.controls.bigNode:setOpacity(0)

    self.controls.smallNode = cc.Sprite:create(smallPath)
    self:addChild(self.controls.smallNode)
    self.controls.smallNode:setTag(SMALLPANEL)
    self.controls.smallNode:setOpacity(0)

    self.controls.middleNode = cc.Sprite:create(middlePath)
    self:addChild(self.controls.middleNode)
    self.controls.middleNode:setTag(MIDDLEPANEL)

    self.data.smallSize = self.controls.smallNode:getContentSize()
    self.data.middleSize = self.controls.middleNode:getContentSize()
    self.data.bigSize = self.controls.bigNode:getContentSize()
end

function GamblePanel:createUI()
    self.controls.leftSpri = cc.Sprite:create(leftPath)
    self.controls.leftSpri:setAnchorPoint(0.5, 0)
    self:addChild(self.controls.leftSpri)
    self.controls.leftSpri:setScale(0)

    self.controls.bottomSpri = cc.Sprite:create("image/ui/img/btn/btn_900.png")
    self.data.bottomSize = self.controls.bottomSpri:getContentSize()
    self:addChild(self.controls.bottomSpri)
    self.controls.bottomSpri:setScale(0)

    self:smallUI()
    self:middleUI()
    self:bigUI()
    self:setSmallChildsVisible(false)

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
        local tag = target:getTag()
        if self.data.isTouch then

            if (self.data.currPanel == SMALLPANEL) and (tag == SMALLPANEL) then
                -- 由小变大
                CCLog(self.data.boxType, "=================SMALLPANEL")
                if self.data.boxType ~= VIPPANEL then
                    self:setNotTouchEnable()
                    application:dispatchCustomEvent(AppEvent.UI.Box.SmallToBig, {CurrPanel = self})
                    Common.CloseGuideLayer( { 4} )  
                    Common.ResetGuideLayer( { big = 5, small = 3 } )
                    Common.OpenGuideLayer( { 5} )   
                else
                    application:showFlashNotice("功能暂未开放!")
                    -- local layer = require("tool.helper.CommonLayer").ToBuyVIP("VIP10才能开启该功能~")
                    -- local runningScene = cc.Director:getInstance():getRunningScene()
                    -- runningScene:addChild(layer)
                end
            elseif (self.data.currPanel == MIDDLEPANEL) and (tag == MIDDLEPANEL)  then
                -- 由中变大
                CCLog(self.data.boxType, "=================MIDDLEPANEL")
                Common.CloseGuideLayer( {4,5} )

                if self.data.boxType ~= VIPPANEL then
                    self.data.currPanel = BIGPANEL
                    self:setNotTouchEnable()
                    application:dispatchCustomEvent(AppEvent.UI.Box.MiddleToBig, {})
                else
                    application:showFlashNotice("功能暂未开放!")
                    -- local layer = require("tool.helper.CommonLayer").ToBuyVIP("VIP10才能开启该功能~")
                    -- local runningScene = cc.Director:getInstance():getRunningScene()
                    -- runningScene:addChild(layer)
                end
            end
        end
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.controls.smallNode)
    local listener2 = listener1:clone()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, self.controls.middleNode)
end

function GamblePanel:smallUI()
    -- body
    local alertZOrder = 10
    self.controls.alert2 = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.alert2:setPosition(self.data.smallSize.width * 0.95, self.data.smallSize.height * 0.92)
    self.controls.smallNode:addChild(self.controls.alert2, alertZOrder)
    self.controls.alert2:setVisible(false)
    self.controls.alert2:setName("alert2")
end

-- 负责创建需要的控件，位置留着由每个子类去设置
function GamblePanel:middleUI(fontPathTab, stoneSpriPath, fontSpriPath)
    for k,v in pairs(fontPathTab) do
        local fontSpri = cc.Sprite:create(v)
        self:addChild(fontSpri, ZORDER)
        self.data.fontSpriTab[k] = fontSpri
    end

    local pricePath = nil
    if self.data.boxType == 1 then
        pricePath = "image/ui/img/btn/btn_035.png"
    else
        pricePath = "image/ui/img/btn/btn_060.png"
    end
    self.controls.middlePriceSpri = cc.Sprite:create(pricePath)
    self.controls.bottomSpri:addChild(self.controls.middlePriceSpri, ZORDER)

    self.controls.middlePriceFont = Common.finalFont("", 1, 1, 20, nil, 1)
    self.controls.middlePriceFont:setAnchorPoint(0, 0.5)
    self.controls.bottomSpri:addChild(self.controls.middlePriceFont, ZORDER)

    self.controls.middleFreeCount = Common.finalFont("" , 1, 1, 20, nil, 1)
    self.controls.middleFreeCount:setAdditionalKerning(-2)
    self.controls.bottomSpri:addChild(self.controls.middleFreeCount, ZORDER)

    self.controls.btn_look = effects:CreateAnimation(self.controls.bottomSpri, 0, 0, nil, 17, true)
    self.controls.btn_look:setTimeScale(0.2)

    self.controls.middleStoneSpri = cc.Sprite:create(stoneSpriPath)
    self:addChild(self.controls.middleStoneSpri)
    self.controls.middleFontSpri = cc.Sprite:create(fontSpriPath)
    self:addChild(self.controls.middleFontSpri)

    local alertZOrder = 10
    self.controls.alert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.alert:setPosition(self.data.middleSize.width * 0.95, self.data.middleSize.height * 0.92)
    self.controls.middleNode:addChild(self.controls.alert, alertZOrder)
    self.controls.alert:setVisible(false)
end

function GamblePanel:bigUI()

    self.controls.bigBottomSpri = cc.Sprite:create("image/ui/img/bg/bg_224.png")
    self.controls.bigBottomSpri:setPosition(self.data.bigSize.width * 0.5, self.data.bigSize.height * 0.18)
    self.controls.bigNode:addChild(self.controls.bigBottomSpri)
    self.controls.bigBottomSpri:setScaleY(0)

    local size = self.controls.bigBottomSpri:getContentSize()
    self.controls.bigFreeCount = Common.finalFont("", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.bigFreeCount:setPosition(size.width * 0.22, size.height * 0.8)
    self.controls.bigBottomSpri:addChild(self.controls.bigFreeCount)

    self.controls.bigFont1 = Common.finalFont("必出三星" , 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.bigFont1:setPosition(size.width * 0.5, size.height * 0.8)
    self.controls.bigBottomSpri:addChild(self.controls.bigFont1)

    self.controls.bigFont2 = Common.finalFont("必出四星" , 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.bigFont2:setPosition(size.width * 0.8, size.height * 0.8)
    self.controls.bigBottomSpri:addChild(self.controls.bigFont2)

    local btn_one = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_908.png", cc.size(140, 70))
    btn_one:setPosition(size.width * 0.2, size.height * 0.3)
    self.controls.bigBottomSpri:addChild(btn_one)
    btn_one:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            CCLog("------------------------买一个--------------------------")
            -- Common.CloseGuideLayer( {2,4,6} )
            if self.data.isFree then
                if self.data.isCanBuy then
                    self.data.isCanBuy = false
                    self:buyGamble(self.data.boxType, 1)
                end
            else
                local priceInfo = self.data.priceInfoTab[1]
                if Common.isCostMoney(priceInfo.MoneyType, priceInfo.Price) then
                    if self.data.isCanBuy then
                        self.data.isCanBuy = false
                        self:buyGamble(self.data.boxType, 1)
                    end
                end
            end
        end
    end)

    local btn_ten = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_909.png", cc.size(140, 70))
    btn_ten:setPosition(size.width * 0.5, size.height * 0.3)
    self.controls.bigBottomSpri:addChild(btn_ten)
    btn_ten:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            CCLog("-----------------------10连抽---------------------------")
            local priceInfo = self.data.priceInfoTab[2]
            if Common.isCostMoney(priceInfo.MoneyType, priceInfo.Price) then
                if self.data.isCanBuy then
                    self.data.isCanBuy = false
                    self:buyGamble(self.data.boxType, 10)
                end
            end
        end
    end)

    local btn_twenty = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_910.png", cc.size(140, 70))
    btn_twenty:setChildPos(0.5, 0.55)
    btn_twenty:setPosition(size.width * 0.8, size.height * 0.3)
    self.controls.bigBottomSpri:addChild(btn_twenty)
    btn_twenty:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            CCLog("-------------------20连抽-------------------------------")
            local priceInfo = self.data.priceInfoTab[3]
            if Common.isCostMoney(priceInfo.MoneyType, priceInfo.Price) then
                if self.data.isCanBuy then
                    self.data.isCanBuy = false
                    self:buyGamble(self.data.boxType, 20)
                end
            end
        end
    end)
end

function GamblePanel:updateUI(priceTab)
    self.data.priceShowTab = {}
    self.data.priceInfoTab = priceTab
    local size = self.controls.bigBottomSpri:getContentSize()
    self.controls.middlePriceFont:setString(priceTab[1].Price)
    for i=1,3 do
        local pricePath = nil
        if self.data.boxType == 1 then
            pricePath = "image/ui/img/btn/btn_035.png"
        else
            pricePath = "image/ui/img/btn/btn_060.png"
        end
        local price = cc.Sprite:create(pricePath)
        price:setPosition(size.width * 0.14 + (i - 1) * size.width * 0.31, size.height * 0.62)
        self.controls.bigBottomSpri:addChild(price)

        local fontPrice = Common.finalFont(Common.numConvert(priceTab[i].Price), 1, 1, 20, cc.c3b(245, 117, 55))
        fontPrice:setAnchorPoint(0, 0.5)
        fontPrice:setPosition(size.width * 0.17 + (i - 1) * size.width * 0.31, size.height * 0.62)
        self.controls.bigBottomSpri:addChild(fontPrice)

        self.data.priceShowTab[i] = {}
        self.data.priceShowTab[i].price = price
        self.data.priceShowTab[i].fontPrice = fontPrice
    end
end

function GamblePanel:showFreeTime()
    if self.data.gambleInfo then
        if self.data.gambleInfo.AllNextFreeTime > 0 then
            self.data.gambleInfo.AllNextFreeTime  = self.data.gambleInfo.AllNextFreeTime  - 1
            local time = Common.timeFormat(self.data.gambleInfo.AllNextFreeTime)
            self.controls.middleFreeCount:setString(time.."后免费")
            self.controls.bigFreeCount:setString(time.."后免费")
            self.data.isFree = false
            if self.data.priceShowTab then
                self.data.priceShowTab[1].price:setVisible(not self.data.isFree)
                self.data.priceShowTab[1].fontPrice:setVisible(not self.data.isFree)
            end
            if self.controls.alert then
                self.controls.alert:setVisible(false)
            end
            if self.controls.alert2 then
                self.controls.alert2:setVisible(false)
            end
        else
            local surplusFreeCount = self.data.gambleInfo.AllTotalFreeCount - self.data.gambleInfo.AllBuyFreeCount
            if surplusFreeCount < 1 then
                self.controls.middleFreeCount:setString("今日免费次数用完")
                self.controls.bigFreeCount:setString("今日免费次数用完")
                self.data.isFree = false
                if self.data.priceShowTab then
                    self.data.priceShowTab[1].price:setVisible(not self.data.isFree)
                    self.data.priceShowTab[1].fontPrice:setVisible(not self.data.isFree)
                end
                if self.controls.alert then
                    self.controls.alert:setVisible(false)
                end
                if self.controls.alert2 then
                    self.controls.alert2:setVisible(false)
                end
            else
                self.controls.middleFreeCount:setString("免费次数"..surplusFreeCount.."/"..self.data.gambleInfo.AllTotalFreeCount)
                self.controls.bigFreeCount:setString("免费次数"..surplusFreeCount.."/"..self.data.gambleInfo.AllTotalFreeCount)
                self.data.isFree = true
                if self.data.priceShowTab then
                    self.data.priceShowTab[1].price:setVisible(not self.data.isFree)
                    self.data.priceShowTab[1].fontPrice:setVisible(not self.data.isFree)
                end
                if self.controls.alert then
                    if self.data.currPanel == MIDDLEPANEL then
                        self.controls.alert:setVisible(true)
                    else
                        self.controls.alert:setVisible(false)
                    end
                end
                if self.controls.alert2 then
                    if self.data.currPanel == SMALLPANEL then
                        self.controls.alert2:setVisible(true)
                    else
                        self.controls.alert2:setVisible(false)
                    end
                end
            end
        end
    end
end

function GamblePanel:buyReturn(nextFreeTime, freeBuyCount, goodsTabs)
    CCLog('===========+++=========buy', self.data.boxType)
    self.data.gambleInfo.AllBuyFreeCount = freeBuyCount
    self.data.gambleInfo.AllNextFreeTime = nextFreeTime
end

function GamblePanel:setSmallChildsVisible(value)
    local childTab = self.controls.smallNode:getChildren()
    for k,v in pairs(childTab) do
        if "alert2" ~= v:getName() then
            v:setVisible(value)
        end
    end
end

function GamblePanel:setMiddleChildsVisible(value)
    local childTab = self.controls.middleNode:getChildren()
    for k,v in pairs(childTab) do
        v:setVisible(value)
    end
end

function GamblePanel:setBigChildsVisible(value)
    local light = self.controls.bigNode:getChildByName("light")
    if value then
        self.controls.bigBottomSpri:setScaleY(0)
        self.controls.bigBottomSpri:runAction(cc.Sequence:create(cc.ScaleTo:create(0.06, 1, 1.2), cc.ScaleTo:create(0.1, 1, 1)))
        if light then
            light:setPosition(0, 0)
        end
    else
        self.controls.bigBottomSpri:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 1, 1.2), cc.ScaleTo:create(0.05, 1, 0)))
        if light then
            light:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
        end
    end
end

function GamblePanel:setStoneVisible(value)
    if self.controls.middleStoneLight then
        self.controls.middleStoneLight:setVisible(value)
        self.controls.middleStoneLight:setPosition(self.data.bgSize.width * 0.345, self.data.bgSize.height * 0.68)
        self.controls.middleStoneLight:setScale(1)
    end
    self.controls.middleStoneSpri:setVisible(value)
    self.controls.middleStoneSpri:setPosition(self.data.bgSize.width * 0.345, self.data.bgSize.height * 0.68)
    self.controls.middleStoneSpri:setScale(1)
    self.controls.middleFontSpri:setVisible(value)
    self.controls.middleFontSpri:setPosition(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.44)
    self.controls.middleFontSpri:setScale(1)
end

function GamblePanel:setCanTouchEnable()
    application:dispatchCustomEvent(AppEvent.UI.Box.IsTouchEnable, {IsTouchEnable = true})
end

function GamblePanel:setNotTouchEnable()
    application:dispatchCustomEvent(AppEvent.UI.Box.IsTouchEnable, {IsTouchEnable = false})
end

function GamblePanel:setTouchEnable(value)
    self.data.isTouch = value 
end

function GamblePanel:getBoxType()
    return self.data.boxType
end

function GamblePanel:getCurrPanel()
    return self.data.currPanel
end

function GamblePanel:getSmallPanelPos()
    local posX = self.controls.smallNode:getPositionX()
    local posY = self.controls.smallNode:getPositionY()
    return posX, posY
end

function GamblePanel:lookHeroUI(heroInfoTabs)
    table.sort(heroInfoTabs, function(a, b)
        return a.StarLevel > b.StarLevel
    end)
    local node = cc.Node:create()
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    node:addChild(layer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    bg:setContentSize(cc.size(780, 480))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local ccSize = bg:getContentSize()

    local detailName = createMixSprite("image/ui/img/btn/btn_837.png", nil, "image/ui/img/btn/btn_1290.png")
    detailName:getBg():setScaleX(1.8)
    detailName:getBg():setScaleY(1.2)
    detailName:setChildPos(0.5, 0.6)
    detailName:setTouchEnable(false)
    detailName:setPosition(ccSize.width * 0.5, ccSize.height * 0.95)
    bg:addChild(detailName)

    local function createItem(goodsInfo)
        local item = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_BIGTYPE) 
        item:setNumVisible(false)
        return item 
    end
    local view = CommonView.new(cc.size(ccSize.width * 0.95, ccSize.height * 0.82), 60, 15, heroInfoTabs, 5, 140, 130, createItem, nil, false, BaseConfig.GOODS_BIGTYPE) 
    bg:addChild(view)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local startpos = bg:convertToNodeSpace(touch:getStartLocationInView())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
            node:removeFromParent()
            node = nil
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end


function GamblePanel:leftSpriAction(func)
    local scaleTime11 = 0.12
    local scaleTime12 = 0.1
    local scale11 = cc.ScaleTo:create(scaleTime11, 1, 1.15)
    local scale12 = cc.ScaleTo:create(scaleTime12, 1, 0)
    local scale21 = cc.ScaleTo:create(scaleTime11, 0)
    local func11 = cc.CallFunc:create(func)
    self.controls.leftSpri:runAction(cc.Sequence:create(scale11, scale12, func11))
    self.controls.bottomSpri:runAction(cc.Sequence:create(scale21))
end
function GamblePanel:fontSpriAction(totalSpace, centerPosX, centerPosY, keepTime, scaleValue)
    local fontNum = #self.data.fontSpriTab
    local space = (totalSpace / fontNum) * 0.85
    local halfSpace = space / 2
    local beginX = centerPosX - (math.floor(fontNum / 2) + 1) * halfSpace
    local extraSpace = 0 
    for k,v in pairs(self.data.fontSpriTab) do
        local posX = beginX + (k - 1) * space
        if fontNum == 3 then
            posX = (beginX + space * 0.28) + (k - 1) * space
            if k == 3 then
                posX = (beginX + space * 0.28) + (k - 1) * space * 0.88
            end
        end
        local sortDelay = cc.DelayTime:create((k - 1) * 0.08)
        local fontMove = cc.MoveTo:create(keepTime, cc.p(posX, centerPosY + extraSpace)) 
        local fontScale1 = cc.ScaleTo:create(keepTime, scaleValue)
        local fontSpawn1 = cc.Spawn:create(fontMove, fontScale1)
        v:stopAllActions()
        v:runAction(cc.Sequence:create(sortDelay, fontSpawn1))
    end
end

function GamblePanel:vipStoneMoveActon()
    if not self.data.isVipStoneMove then
        self.data.isVipStoneMove = true
        local move = cc.MoveBy:create(1, cc.p(0, 12))
        local move_reverse = move:reverse()
        self.controls.middleStoneLight:runAction(cc.RepeatForever:create(cc.Sequence:create(move:clone(), move_reverse:clone())))
        self.controls.middleStoneSpri:runAction(cc.RepeatForever:create(cc.Sequence:create(move:clone(), move_reverse:clone())))
    end
end

--[[ 
    middleToBig和middleToSmall同步执行
]]--
function GamblePanel:changeBigStarFunc1()
   if self.controls.alert then
       self.controls.alert:setVisible(false)
   end
end
function GamblePanel:changeBigEndFunc1()
    self:setBigChildsVisible(true)
    self:setCanTouchEnable()
    self.controls.bigTitle:setScale(1)
    self.controls.bigStove:setScale(1)
    if self.controls.lookHero then
        self.controls.lookHero:setScale(1)
    end
    if self.controls.lamp then
        self.controls.lamp:setScale(1)
    end
    if self.data.boxType == VIPPANEL then
        self:vipStoneMoveActon()
    end

    Common.OpenGuideLayer({4,5})
end
-- 从中等显示变为最大显示
-- 因为每个锚点不同，所以移动到的大图中点的距离也不同
-- 动作：左边条幅和下边条幅隐藏，中图放大至大图尺寸并移动到大图位置并逐渐谈出，大图淡入，字体图片和中图子控件移动到大图位置
local firstChangeTime = 0.8
local firstDelayTime = 0.3
function GamblePanel:middleToBig(posX, posY, bigFontPos)
    
    self.data.currPanel = BIGPANEL
    self:changeBigStarFunc1()
    local function changeBig()
        local function middleAction()
            local scaleW = self.data.bigSize.width / self.data.middleSize.width
            local scaleH = self.data.bigSize.height / self.data.middleSize.height
            local scale = cc.ScaleTo:create(firstChangeTime, scaleW, scaleH)
            local fadeout = cc.FadeOut:create(firstChangeTime)
            local move = cc.MoveTo:create(firstChangeTime, cc.p(posX, posY))
            local spawn = cc.Spawn:create(scale, move, fadeout)
            self.controls.middleNode:runAction(cc.Sequence:create(spawn, cc.CallFunc:create(handler(self, self.changeBigEndFunc1))))
        end
        local function bigAction()
            local delay = cc.DelayTime:create(firstDelayTime)
            local fadeIn = cc.FadeIn:create(firstChangeTime - firstDelayTime)
            self.controls.bigNode:runAction(cc.Sequence:create(delay, fadeIn))
        end
        local function childAction()
            local move1 = cc.MoveTo:create(firstDelayTime, cc.p(self.data.bgSize.width * 0.345, self.data.bgSize.height * 0.68))
            local move2 = cc.MoveTo:create(firstDelayTime, cc.p(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.44))
            local scale = cc.ScaleTo:create(firstDelayTime, 1)
            local spawn1 = cc.Spawn:create(move1:clone(), scale)
            local spawn2 = cc.Spawn:create(move2:clone(), scale)
            local delay = cc.DelayTime:create(0.1)

            if self.controls.middleStoneLight then
                self.controls.middleStoneLight:runAction(spawn1)
            end
            self.controls.middleStoneSpri:runAction(cc.Sequence:create(spawn1:clone()))
            self.controls.middleFontSpri:runAction(cc.Sequence:create(delay, spawn2:clone()))
        end
        middleAction()
        bigAction()
        self:fontSpriAction(self.data.bgSize.width * 0.22, bigFontPos.x + 15, bigFontPos.y, firstDelayTime, 1)
        childAction()
    end
    self:leftSpriAction(changeBig)
end

function GamblePanel:changeSmallStarFunc1()
    if self.controls.alert then
        self.controls.alert:setVisible(false)
    end
    self:setMiddleChildsVisible(false)
    self:setStoneVisible(false)
end
function GamblePanel:changeSmallEndFunc1()
    self:setSmallChildsVisible(true)
end
-- 从中等显示变为最小显示
-- 动作：左边条幅和下边条幅隐藏，中图子控件隐藏，中图缩小至小图尺寸并移动到小图位置并逐渐谈出，小图淡入，字体图片移动到小图位置
function GamblePanel:middleToSmall(middlePosX, middlePosY, smallPosX, smallPosY, delayTime)
    self.data.currPanel = SMALLPANEL
    self:changeSmallStarFunc1()

    local function changeSmall()
        local function middleAction()
            local scaleW = self.data.smallSize.width / self.data.middleSize.width
            local scaleH = self.data.smallSize.height / self.data.middleSize.height
            local scale = cc.ScaleTo:create(firstChangeTime, scaleW, scaleH)
            local fadeout = cc.FadeOut:create(firstChangeTime)
            local move = cc.MoveTo:create(firstChangeTime, cc.p(middlePosX, middlePosY))
            local spawn = cc.Spawn:create(scale, move, fadeout)
            self.controls.middleNode:runAction(cc.Sequence:create(spawn, cc.CallFunc:create(handler(self, self.changeSmallEndFunc1))))
        end
        local function smallAction()
            local fadeIn = cc.FadeIn:create(firstChangeTime)
            local sortDelay = cc.DelayTime:create(firstChangeTime * 0.5 + delayTime * 0.1)
            local scale1 = cc.ScaleTo:create(0.1, 1.1)
            local scale2 = cc.ScaleTo:create(0.12, 0.85)
            local scale3 = cc.ScaleTo:create(0.1, 1.02)
            local scale4 = cc.ScaleTo:create(0.1, 0.9)
            local scale5 = cc.ScaleTo:create(0.1, 1)

            local seq1 = cc.Sequence:create(fadeIn)
            local seq2 = cc.Sequence:create(sortDelay, scale1, scale2, scale3, scale4, scale5)
            local spawn1 = cc.Spawn:create(seq1, seq2)
            self.controls.smallNode:runAction(spawn1)
        end
        middleAction()
        smallAction()

        local sortDelay = cc.DelayTime:create(delayTime * 0.14)
        self:runAction(cc.Sequence:create(sortDelay, cc.CallFunc:create(function()
            self:fontSpriAction(self.data.smallSize.width * 0.5, 
                            smallPosX, smallPosY + self.data.smallSize.height * 0.38, firstDelayTime, 0.8)
        end)))
    end
    self.controls.smallNode:setPosition(smallPosX, smallPosY)
    self:leftSpriAction(changeSmall)
end

--[[ 
    smallToBig和bigToSmall同步执行
]]--
local secondChangeTime = 0.6
local secondDelayTime1 = 0.1
local secondDelayTime2 = 0.2
function GamblePanel:changeBigStarFunc2()  

end
function GamblePanel:changeBigEndFunc2()
    self:setBigChildsVisible(true)
    self:setStoneVisible(true)
    self:setCanTouchEnable()
    self.controls.bigTitle:setScale(1)
    self.controls.bigStove:setScale(1)
    if self.controls.lookHero then
        self.controls.lookHero:setScale(1)
    end
    if self.controls.lamp then
        self.controls.lamp:setScale(1)
    end
    if self.data.boxType == VIPPANEL then
        self:vipStoneMoveActon()
    end
end
-- 从最小显示变为最大显示
-- 动作:隐藏小图子控件，小图弹出，大图淡入，大图子控件显示在相对于位置，字体图片移动到大图位置
function GamblePanel:smallToBig(bigFontPos)
    self.data.currPanel = BIGPANEL
    self:changeBigStarFunc2()

    local scale1 = cc.ScaleTo:create(secondDelayTime1, 1, 1.2)
    local scale2 = cc.ScaleTo:create(secondDelayTime2, 1, 0)
    local fadeIn = cc.FadeIn:create(secondChangeTime)
    self.controls.smallNode:runAction(cc.Sequence:create(scale1, scale2, cc.CallFunc:create(handler(self, self.changeBigEndFunc2))))
    self.controls.bigNode:runAction(cc.Sequence:create(fadeIn))
    self:fontSpriAction(self.data.bgSize.width * 0.22, bigFontPos.x + 15, bigFontPos.y, secondChangeTime - secondDelayTime2, 1)
end

function GamblePanel:changeSmallStarFunc2()
    for k,v in pairs(self.data.fontSpriTab) do
        v:setScale(1)
    end 
    self:setSmallChildsVisible(true)
    self:setBigChildsVisible(false)
    self:setStoneVisible(false)
    self.controls.smallNode:setOpacity(255)
    self.controls.smallNode:setScaleY(0)
    self.controls.bigTitle:setScale(0)
    self.controls.bigStove:setScale(0)
    if self.controls.lookHero then
        self.controls.lookHero:setScale(0)
    end
    if self.controls.lamp then
        self.controls.lamp:setScale(0)
    end
end
function GamblePanel:changeSmallEndFunc2()
    
end
-- 从最大显示变为最小显示
-- 动作:隐藏大图子控件，大图淡出，小图弹入，小图子控件显示，字体图片移动到小图位置
function GamblePanel:bigToSmall(smallPosX, smallPosY)
    self.data.currPanel = SMALLPANEL
    self:changeSmallStarFunc2()
    self.controls.smallNode:setPosition(smallPosX, smallPosY)

    local fadeout = cc.FadeOut:create(secondChangeTime)
    local delay = cc.DelayTime:create(secondDelayTime1 + secondDelayTime2)
    local scale1 = cc.ScaleTo:create(secondDelayTime2, 1, 1.2)
    local scale2 = cc.ScaleTo:create(secondDelayTime1, 1, 1)
    self.controls.smallNode:runAction(cc.Sequence:create(delay, scale1, scale2))
    self.controls.bigNode:runAction(cc.Sequence:create(fadeout, cc.CallFunc:create(handler(self, self.changeSmallEndFunc2))))
    self:fontSpriAction(self.data.smallSize.width * 0.5, 
                            smallPosX, smallPosY + self.data.smallSize.height * 0.38, secondChangeTime - secondDelayTime2, 0.8)
end

--[[
    购买
]]
function GamblePanel:buyGamble(gambleType, buyNum)
    rpc:call("Gamble.Buy", {Type = gambleType, Num = buyNum}, function(event)
        self.data.isCanBuy = true
        if event.status == Exceptions.Nil then
            Common.CloseGuideLayer( {4,5} )
            if GameCache.NewbieGuide.Step == 4 or GameCache.NewbieGuide.Step == 5 then
                Common.SaveGuideLayer(  )
            end
            local value = event.result
            self:buyReturn(value.NextFreeTime, value.FreeBuyCount, value.List)
            local layer = require("scene.main.gamble.ShowGoodsInfo").new(value.List, self.data.bgSize)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(layer)

            
        end
    end)
end

return GamblePanel

