local LevelGoodsInfo = class("LevelGoodsInfo", function()
    return cc.Node:create()
end)

function LevelGoodsInfo:ctor(goodsInfo)
    self.goodsInfo = goodsInfo

    -- 任务状态
    self.UnFinishStatus = 0
    self.ReceiveStatus = self.UnFinishStatus + 1
    self.FinishStatus = self.ReceiveStatus + 1

    self.bg = cc.Sprite:create("image/ui/img/btn/btn_412.png")
    self.bg:setOpacity(0)
    self:addChild(self.bg)
    local bgSize = self.bg:getContentSize()

    local activityConfig = self:getAwardConfig()
    for k,v in pairs(activityConfig.Award) do
        local goodsInfo = {}
        goodsInfo.ID = v.GoodsID
        goodsInfo.Type = v.GoodsType
        goodsInfo.Num = v.Num
        goodsInfo.StarLevel = v.Star

        local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_BIGTYPE)
        goodsItem:setPosition((k - 1) * 70, 0)
        self:addChild(goodsItem)

        break
    end

    self.getLabel = load_animation("image/spine/skill_effect/ragebox/blue/", 1)
    self.getLabel:setScale(0.9)
    self.getLabel:setAnimation(0, "animation", true)
    self:addChild(self.getLabel)

    self.gou = cc.Sprite:create("image/ui/img/btn/btn_502.png")
    self:addChild(self.gou)

    if self.UnFinishStatus == self.goodsInfo.Status then
        self.getLabel:setVisible(false)
        self.gou:setVisible(false)
    elseif self.ReceiveStatus == self.goodsInfo.Status then
        self.getLabel:setVisible(true)
        self.gou:setVisible(false)
    elseif self.FinishStatus == self.goodsInfo.Status then
        self.getLabel:setVisible(false)
        self.gou:setVisible(true)
    end

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
            if self.func and (self.goodsInfo.Status == self.ReceiveStatus) then
                self.func(self, 2)
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.bg)
end

function LevelGoodsInfo:getAwardConfig()
    return BaseConfig.getActivityLevelAward(self.goodsInfo.Level)
end

function LevelGoodsInfo:getStatus()
    self.goodsInfo.Status = self.FinishStatus
    self.getLabel:setVisible(false)
    self.gou:setVisible(true)
end

function LevelGoodsInfo:addTouchEventListener(event)
    self.func = event
end

return LevelGoodsInfo


