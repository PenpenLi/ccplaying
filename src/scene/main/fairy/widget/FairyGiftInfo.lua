local FairyGiftInfo = class("FairyGiftInfo", require("tool.helper.GoodsInfoIcon"))
local scheduler = cc.Director:getInstance():getScheduler()

function FairyGiftInfo:ctor(heroInfo)
    FairyGiftInfo.super.ctor(self, BaseConfig.GOODS_PROPS, heroInfo, BaseConfig.GOODS_MIDDLETYPE)
    self:setNum()
    self:setNameAndDesc()

    local function onNodeEvent(event)
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    local size = self:getContentSize()
    local clickArea = cc.Node:create()
    clickArea:setContentSize(cc.size(88, 88))
    self:addChild(clickArea)
    clickArea:setPosition(-size.width * 0.5, -size.height * 0.5)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            if self.data.isCanEat then
            	self.data.intervalSpeed = 120
	    		self.data.playSpeedCount = 0

	        	self.data.isContinueEat = true
	        	self:onceEatEvent()
	            return true
            else
                if not self.data.isUnLock then
                    application:showFlashNotice("仙女未解锁~!")
                    return false
                end
            	application:showFlashNotice("仙女已达最大等级~!")
            end
        end
        return false
    end

    local function onTouchMoved(touch, event)
    	local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if not cc.rectContainsPoint(rect, locationInNode) then
        	self.data.isContinueEat = false
			application:dispatchCustomEvent(AppEvent.UI.Fairy.Upgrade, {ID = self.data.goodsInfo.ID})
        end
    end

    local function onTouchEnded(touch, event)
        if self.data.isContinueEat then
            self.data.isContinueEat = false
            application:dispatchCustomEvent(AppEvent.UI.Fairy.Upgrade, {ID = self.data.goodsInfo.ID})
        end
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, clickArea)

    self.data.leastIntervalSpeed = 5
    self.data.intervalSpeed = 120
    self.data.playSpeedCount = 0

    self.data.isUnLock = true
	self.data.isCanEat = true
    self.data.isContinueEat = false
    self.controls.scheduler = scheduler:scheduleScriptFunc(handler(self, self.continueEatEvent), 0, false)
end

function FairyGiftInfo:onCleanup()
	scheduler:unscheduleScriptEntry(self.controls.scheduler)
end

function FairyGiftInfo:setNameAndDesc()
    local size = self:getContentSize()
    local propsConfig = self:getGoodsConfigInfo()

    local favorValue = Common.finalFont("好感+"..propsConfig.useValue, 0, -size.height * 0.65, 20, cc.c3b(255, 220, 20))
    self:addChild(favorValue)
end

function FairyGiftInfo:isEqualID(id)
	return (id == self.data.goodsInfo.ID)
end

function FairyGiftInfo:setIsContinueEat(value)
	self.data.isContinueEat = value
end

function FairyGiftInfo:setTouchEnable(value)
	self.data.isCanEat = value
end

function FairyGiftInfo:setFairyUnLock(value)
    self.data.isUnLock = value
end

function FairyGiftInfo:continueEatEvent(dt)
	if self.data.isContinueEat then
		self.data.playSpeedCount = self.data.playSpeedCount + 1
		self.data.intervalSpeed = self.data.intervalSpeed - 1
		self.data.intervalSpeed = (self.data.intervalSpeed < self.data.leastIntervalSpeed) and self.data.leastIntervalSpeed 
										or self.data.intervalSpeed
		if (self.data.playSpeedCount % self.data.intervalSpeed == 0) then
			self:onceEatEvent()
		end

	end
end

function FairyGiftInfo:onceEatEvent()
	self.data.goodsInfo.Num = self.data.goodsInfo.Num - 1
	self:setNum()
	Common.eatPillEffect(self)

    local propsConfig = self:getGoodsConfigInfo()
	application:dispatchCustomEvent(AppEvent.UI.Fairy.UpdateFairyInfo, {ID = self.data.goodsInfo.ID, Value = propsConfig.useValue})
	if self.data.goodsInfo.Num <= 0 then
		self.data.isContinueEat = false
        application:dispatchCustomEvent(AppEvent.UI.Fairy.Upgrade, {ID = self.data.goodsInfo.ID})
		application:dispatchCustomEvent(AppEvent.UI.Fairy.UpdateGiftView, {ID = self.data.goodsInfo.ID})
	end

    Common.CloseSystemLayer({6})
    Common.OpenSystemLayer({6})
end
return FairyGiftInfo


