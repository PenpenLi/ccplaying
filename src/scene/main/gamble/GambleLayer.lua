local GambleLayer = class("GambleLayer", BaseLayer)
local scheduler = cc.Director:getInstance():getScheduler()

local ALLPANEL = 1
local VIPPANEL = ALLPANEL + 1
local HEROPANEL = VIPPANEL + 1
local EQUIPPANEL = HEROPANEL + 1

local SMALLPANEL = 1
local MIDDLEPANEL = SMALLPANEL + 1
local BIGPANEL = MIDDLEPANEL + 1

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

function GambleLayer:ctor(gambleInfo)
    self.data.panelTab = {}
    self:createUI()
    for k,v in pairs(self.data.panelTab) do
        v:updateUI(gambleInfo[k])
    end

    self:addListener()
    -- 最右边三个小面板的中点坐标
    self.data.smallPosTabs = {{self.data.bgSize.width * 0.84, self.data.bgSize.height * 0.82}, 
                                {self.data.bgSize.width * 0.84, self.data.bgSize.height * 0.5}, 
                                {self.data.bgSize.width * 0.84, self.data.bgSize.height * 0.18}}
    -- 第一个名字图片的位置
    self.data.bigFontPos = {x = self.data.bgSize.width * 0.33, y = self.data.bgSize.height * 0.885}
end

function GambleLayer:onEnter()
    if not self.controls.scheduler_showTime then
        self.controls.scheduler_showTime = scheduler:scheduleScriptFunc(handler(self, self.showTime), 1, false)
    end
end

function GambleLayer:onEnterTransitionFinish()
    GambleLayer.super.onEnterTransitionFinish(self)
    Common.OpenGuideLayer( {4,5} )
end

function GambleLayer:onCleanup()
    scheduler:unscheduleScriptEntry(self.controls.scheduler_showTime)
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
    GambleLayer.super.onCleanup(self)
end

function GambleLayer:addListener()
    self.listeners = {}
    local listener = application:addEventListener(AppEvent.UI.Box.MiddleToBig, function(event)
        local posIdx = 1
        for k,v in pairs(self.data.panelTab) do
            if BIGPANEL == v:getCurrPanel() then
                v:setLocalZOrder(btnZOrder)
                v:middleToBig(self.data.bigFontPos)
            else
                v:setLocalZOrder(bgZOrder)
                v:middleToSmall(self.data.smallPosTabs[posIdx][1], self.data.smallPosTabs[posIdx][2], posIdx)
                posIdx = posIdx + 1
            end
        end
        self.controls.right:setScale(1)
    end)
    table.insert(self.listeners, listener)

    local listener = application:addEventListener(AppEvent.UI.Box.SmallToBig, function(event)
        local result = event.data
        local currPanel = result.CurrPanel
        local smallPosX, smallPosY = currPanel:getSmallPanelPos()
        for k,v in pairs(self.data.panelTab) do
            if BIGPANEL == v:getCurrPanel() then
                v:setLocalZOrder(bgZOrder)
                v:bigToSmall(smallPosX, smallPosY)
                break
            end
        end
        currPanel:setLocalZOrder(btnZOrder)
        currPanel:smallToBig(self.data.bigFontPos)
    end)
    table.insert(self.listeners, listener)

    local listener = application:addEventListener(AppEvent.UI.Box.IsTouchEnable, function(event)
        local result = event.data
        local isTouch = result.IsTouchEnable
        for k,v in pairs(self.data.panelTab) do
            v:setTouchEnable(isTouch)
            if isTouch then
                CCLog(v:getBoxType(), 'box++++++++++++YES++++++++++panel', v:getCurrPanel())
            end
        end
    end)
    table.insert(self.listeners, listener)
end

function GambleLayer:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    self.controls.pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = self.controls.pay:getContentSize()
    self.controls.pay:setPosition(SCREEN_WIDTH*0.5 - size.width * 0.5, SCREEN_HEIGHT - 55)
    self:addChild(self.controls.pay, bgZOrder)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(940, 586))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self.controls.bg:addChild(swallowLayer, bgZOrder)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.97, self.data.bgSize.height * 1.02)
    self.controls.bg:addChild(btn_close, btnZOrder)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            Common.CloseGuideLayer( {4,5} )
            cc.Director:getInstance():popScene()
        end
    end)

    self.controls.right = cc.Sprite:create("image/ui/img/bg/bg_225.png")
    self.controls.right:setPosition(self.data.bgSize.width * 0.84, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.right, bgZOrder)
    self.controls.right:setScale(0)

    local box1 = require("scene.main.gamble.widget.AllPanel").new(ALLPANEL, self.data.bgSize)
    self.controls.bg:addChild(box1, bgZOrder)
    table.insert(self.data.panelTab, box1)
    local box2 = require("scene.main.gamble.widget.VipPanel").new(VIPPANEL, self.data.bgSize)
    self.controls.bg:addChild(box2, bgZOrder)
    table.insert(self.data.panelTab, box2)
    local box3 = require("scene.main.gamble.widget.HeroPanel").new(HEROPANEL, self.data.bgSize)
    self.controls.bg:addChild(box3, bgZOrder)
    table.insert(self.data.panelTab, box3)
    local box4 = require("scene.main.gamble.widget.EquipPanel").new(EQUIPPANEL, self.data.bgSize)
    self.controls.bg:addChild(box4, bgZOrder)
    table.insert(self.data.panelTab, box4)
end

function GambleLayer:showTime(dt)
    for k,v in pairs(self.data.panelTab) do
        v:showFreeTime()
    end
end

return GambleLayer




