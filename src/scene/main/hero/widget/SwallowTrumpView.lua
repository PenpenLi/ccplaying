local SwallowTrumpView = class("SwallowTrumpView", require("tool.helper.CommonView"))
local bgZOrder = 2

function SwallowTrumpView:ctor(equipTab, Num, sureFunc)
    self.data.chooseNum = Num
    self.data.sureFunc = sureFunc
    self.data.chooseGoodsTabs = {}

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    self:addChild(layer)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(780, 480))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    local ccSize = self.controls.bg:getContentSize()

    SwallowTrumpView.super.ctor(self, cc.size(ccSize.width - 30, ccSize.height * 0.62), SCREEN_WIDTH * 0.5 - ccSize.width * 0.45, SCREEN_HEIGHT * 0.295, equipTab, 6, 120, 100, handler(self, self.getGoodsItem), handler(self, self.touchEvent), false, 2) 

    local detailName = createMixSprite("image/ui/img/btn/btn_608.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("选择你要添加的法宝", 1, 1, 22, cc.c3b(255, 200, 125))
    detailName:setPosition(ccSize.width * 0.5, ccSize.height * 0.9)
    self.controls.bg:addChild(detailName, bgZOrder)
    local line = cc.Sprite:create("image/ui/img/btn/btn_604.png")
    line:setPosition(ccSize.width * 0.13, ccSize.height * 0.9)
    self.controls.bg:addChild(line, bgZOrder)
    line = cc.Sprite:create("image/ui/img/btn/btn_604.png")
    line:setScaleX(-1)
    line:setPosition(ccSize.width * 0.87, ccSize.height * 0.9)
    self.controls.bg:addChild(line, bgZOrder)

    local btn_sure = createMixSprite("image/ui/img/btn/btn_593.png")
    btn_sure:setCircleFont("确认选择", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(ccSize.width * 0.5, ccSize.height * 0.12)
    self.controls.bg:addChild(btn_sure, bgZOrder)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.data.sureFunc(self.data.chooseNum, self.data.chooseGoodsTabs)
            self:removeFromParent()
            self = nil
        end
    end)

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
            self:removeFromParent()
            self = nil
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.bg)
end

function SwallowTrumpView:getGoodsItem(goodsInfo)
    local equipItem = require("scene.main.hero.widget.SwallowTrumpInfo").new(goodsInfo)
    return equipItem
end

function SwallowTrumpView:touchEvent(goodsItem)
    local goodsInfo = goodsItem:getGoodsInfo()
    if goodsItem.data.isChoose then
        -- 取消选中
        self.data.chooseNum = self.data.chooseNum - 1
        self:addGoodsToEquipList(goodsInfo)
    else
        if self.data.chooseNum >= 6 then
            application:showFlashNotice("法宝已添加满～")
            return
        end
        self.data.chooseNum = self.data.chooseNum + 1
        GameCache.minusEquip(goodsInfo.ID, goodsInfo.StarLevel, 1)
        table.insert(self.data.chooseGoodsTabs, goodsInfo)
    end
    
    goodsItem:setIsChoose(not goodsItem.data.isChoose)
end

function SwallowTrumpView:addGoodsToEquipList(goodsInfo)
    -- 将此装备添加到背包中，从已选装备列表中移除此装备
    GameCache.addEquip(goodsInfo.ID, goodsInfo.StarLevel, 1)

    for k,v in pairs(self.data.chooseGoodsTabs) do
        if v.ID == goodsInfo.ID then
            table.remove(self.data.chooseGoodsTabs, k)
            break
        end
    end
end

return SwallowTrumpView

