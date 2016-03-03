local GetGoodsTips = class("GetGoodsTips", require("tool.helper.CommonTips"))

function GetGoodsTips:ctor(goodsType, goodsInfo, goodsItem)
    GetGoodsTips.super.ctor(self, goodsType, goodsInfo, goodsItem)
    self.data.goodsItem = goodsItem
    
    self:createUI()
    Common.removeTopSwallowLayer()
end

function GetGoodsTips:onEnter()
    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateHeroInfo, {})
    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateEquipIntensify, {})
    GetGoodsTips.super.onEnter(self)
end

function GetGoodsTips:createUI()
    self.data.extraHeight = SCREEN_HEIGHT * 0.75 - self.data.size.height
    self:updateGoods()

    self.controls.layer = cc.LayerColor:create(cc.c4b(255,0,0,0), self.data.size.width, self.data.size.height)
    self.controls.bg:addChild(self.controls.layer)

    local btn_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    btn_bg:setContentSize(cc.size(self.data.size.width * 0.94, 90))
    btn_bg:setPosition(self.data.size.width * 0.5, 58)
    self.controls.bg:addChild(btn_bg)

    local btn_getWay = createMixSprite("image/ui/img/btn/btn_593.png")
    btn_getWay:setCircleFont("获取途径", 1, 1, 25, cc.c3b(251, 202, 118), 1)
    btn_getWay:setFontOutline(cc.c4b(77, 36, 0, 255), 2)
    btn_getWay:setPosition(self.data.size.width * 0.5, 60)
    self.controls.bg:addChild(btn_getWay, 1)
    btn_getWay:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not self.data.isOpenList then
                self.data.isOpenList = true
                self.controls.goodsList = require("scene.main.hero.widget.GetWayListBox").new(self.data.goodsType, self.data.goodsInfo, self.data.size)
                self.controls.goodsList:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                self:addChild(self.controls.goodsList, 1) 
                self:playOpenAction()
                self.controls.goodsList:playOpenAction()
                self.controls.layer:changeWidth(self.data.size.width * 2.04)
            end
        end
    end)

    local function onBegan(touch, event)
        return true
    end

    local function onEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            self:hide()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.layer)
end

function GetGoodsTips:updateGoods()
    GetGoodsTips.super.updateGoods(self, self.data.goodsInfo, self.data.extraHeight)
end

function GetGoodsTips:playOpenAction()
    local width = self.data.size.width
    local height = self.data.size.height
    local moveLeft = cc.MoveBy:create(0.1, cc.p(-width * 0.62, 0))
    local moveRight = cc.MoveBy:create(0.05, cc.p(width * 0.1, 0))
    self.controls.bg:runAction(cc.Sequence:create(moveLeft, moveRight))
end

function GetGoodsTips:hide()
    GetGoodsTips.super.hide(self)
    if self.controls.goodsList then
        self.controls.goodsList:playCloseAction()
    end
end

function GetGoodsTips:setBgPosition(x, y)
    self.controls.bg:setPosition(x, y)
end

function GetGoodsTips:getContentSize()
    return self.data.size
end

return GetGoodsTips

