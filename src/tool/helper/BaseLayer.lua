local ROLLING_MESSAGE_NODE_NAME = "rolling_message_node"    
local PANEL_WIDTH = display.width * 0.8
local PANEL_HEIGHT = 25
local FONT_SIZE = 24
local PANEL_SIZE = cc.size(PANEL_WIDTH, PANEL_HEIGHT)

local BaseLayer = class("BaseLayer", function()
    local self = cc.Layer:create()

    local function onNodeEvent(event)
        CCLog("layer event:", event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        elseif event == "cleanup" then
            self:onCleanup()
        elseif event == "enterTransitionFinish" then
            if GameCache.NewbieGuide.Step < 9 then
                application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.CreateGuide, {page = self.__cname})
            end

            if GameCache.OpenSystem.State then
                application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.CreateSystem, {page = self.__cname})
            end
            
            self:onEnterTransitionFinish()
            
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    self.controls = {}
    self.handlers = {}
    self.data = {}

    return self
end)

function BaseLayer:ctor()
    CCLog(self.__cname or tolua.type(self), ":ctor()")

    self:createRollingMessage()
end

function BaseLayer:onEnter()
    CCLog(self.__cname or tolua.type(self), ":onEnter()")

        -- 测试滚动消息
    -- local msg =     {
    --     Content = "使用的一些基本数据类型。这些数据类型可以在编译时改变以便适应你的需求",
    --     Duration = 10,
    --     Expire = "2015-10-16T16:15:49Z",
    --     Priority = 3,
    -- }
    --
    -- application:pushRollingMessage(msg)
end

function BaseLayer:onExit()
    CCLog(self.__cname or tolua.type(self), ":onExit()")
    application:dispatchCustomEvent(AppEvent.UI.MainLayer.updateAlert, {})
end

function BaseLayer:exitAction(callFunc)
    local scale1 = cc.ScaleBy:create(0.05, 1.1)
    local delay = cc.DelayTime:create(0.1)
    local scale2 = cc.ScaleBy:create(0.1, 0)
    self:runAction(cc.Sequence:create(scale1, delay, scale2, cc.CallFunc:create(function()
        if callFunc then
            callFunc()
        end
        self:removeFromParent()
        self = nil
    end)))
end

function BaseLayer:onCleanup()
    print(self.__cname or tolua.type(self), ":onCleanup()")
    
end

function BaseLayer:onEnterTransitionFinish()
    CCLog(self.__cname or tolua.type(self), ":onEnterTransitionFinish()")

    if not GameCache.isExamine then
        local quickGuide = require("tool.helper.QuickGuide"):getInstance()
        quickGuide:init()
    end
end

function BaseLayer:onExitTransitionStart()
    CCLog(self.__cname or tolua.type(self), ":onExitTransitionStart()")
end

function BaseLayer:makeModel()
    local function onTouchBegan(touch, event)
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function BaseLayer:createRollingMessage()
    local node = ccui.Layout:create()
    node:setPosition(cc.p(display.width / 2, display.top + PANEL_HEIGHT))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setContentSize(cc.size(PANEL_WIDTH, PANEL_HEIGHT * 2))
    --node:setBackGroundImage("image/ui/img/bg/bg_151.png")
    node:setClippingEnabled(true)

    local spriteBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_151.png")
    spriteBg:setContentSize(PANEL_SIZE)
    spriteBg:setAnchorPoint(cc.p(0, 0))
    spriteBg:setPosition(cc.p(0, 0))
    node:addChild(spriteBg)    
    node:setName(ROLLING_MESSAGE_NODE_NAME)

    self:addChild(node, 99999)

    local handler 
    handler = application:addEventListener(AppEvent.UI.Message.Message, function(event)
        if not tolua.isnull(self) then
            if event.data then
                self:showRollingMessage(event.data)
            end
        else
            application:removeEventListener(handler)
        end
    end)
end

function BaseLayer:showRollingMessage(message)
    local ColorLabel = require("tool.helper.ColorLabel")

    local function getMessageContentString(message)
        CCLog(vardump(message))
        local DEF_COLOR_BEGIN = "[20, 250, 20]"
        local COLOR_CLOSE = "[=]"
        local KEY_COLOR_BEZGIN = "[255, 234, 0]"

        local format = message.Content[1]
        local args = {}
        for i = 2, #message.Content do
            local arg = COLOR_CLOSE .. KEY_COLOR_BEZGIN .. message.Content[i] .. COLOR_CLOSE .. DEF_COLOR_BEGIN

            table.insert(args, arg)
        end

        return DEF_COLOR_BEGIN .. string.format(message.Content[1], unpack(args)) .. COLOR_CLOSE
    end

    local node = self:getChildByName(ROLLING_MESSAGE_NODE_NAME)
    if node and node:numberOfRunningActions() == 0 then
        node:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.1), 
            cc.MoveTo:create(0.5, cc.p(display.width / 2, display.top - PANEL_HEIGHT / 2)),
            cc.CallFunc:create(function()    
                local colorStr = getMessageContentString(message)
                CCLog("colorstr:", colorStr)
                local labelMessage = ColorLabel.new(colorStr, FONT_SIZE, #colorStr, true)
                --local labelMessage = Common.finalFont(getMessageContentString(message), 0, 0, FONT_SIZE, cc.c3b(20, 250, 20), 0)
                --labelMessage:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                --labelMessage:setDimensions(PANEL_WIDTH, PANEL_HEIGHT)
                labelMessage:setPosition(cc.p(PANEL_WIDTH, PANEL_HEIGHT / 2 + 1))
                --labelMessage:setAnchorPoint(cc.p(0, 0.5))
                labelMessage:setAnchorPoint(0, 0.5)
                node:addChild(labelMessage)

                local contentSize = labelMessage:getContentSize()
                CCLog(vardump(contentSize, "contentSize"))
                local distance = PANEL_WIDTH + contentSize.width
                local useTime = distance / (PANEL_WIDTH / 8.0)                      

                labelMessage:runAction(cc.Sequence:create({cc.MoveBy:create(useTime, cc.p(-distance, 0)), cc.RemoveSelf:create()}))
                node:runAction(cc.Sequence:create({cc.DelayTime:create(useTime + 0.5), 
                                                   cc.Sequence:create({cc.DelayTime:create(0.1),cc.MoveTo:create(0.5, cc.p(display.width / 2, display.top + PANEL_HEIGHT))}
                )}))
            end),                   
        }))     
    end
end

function BaseLayer:startSetupUIThread()
    self._setupUI_Thread = coroutine.create(handler(self, self.setupUI))
    self:scheduleSetupUI()
end

function BaseLayer:unscheduleSetupUI()
    if self._setupUIscheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        CCLog("scheduler:unscheduleScriptEntry(", self._setupUIscheduleEntryID, ")")
        scheduler:unscheduleScriptEntry(self._setupUIscheduleEntryID)
        self._setupUIscheduleEntryID = nil
        self._setupUI_Thread = nil
    end
end

function BaseLayer:scheduleSetupUI()
    if tolua.isnull(self) then
        CCLog(debug.traceback())
        return
    end

    local scheduler = cc.Director:getInstance():getScheduler()

    if self._setupUIscheduleEntryID ~= nil then
        scheduler:unscheduleScriptEntry(self._setupUIscheduleEntryID)
        self._setupUIscheduleEntryID = nil
    end
    local frame = 1.0 / 60 * 0.95

    local updateFunc = function()
        local st = os.clock()
        local status = true 

        while status do
            status, err = coroutine.resume(self._setupUI_Thread)
            if not status then
                self:unscheduleSetupUI()
                CCLog("resume setupUI fail:", err)
            end

            local ct = os.clock()
            if ct - st > frame then
                break
            end
        end

        if tolua.isnull(self) then
            self:unscheduleSetupUI()
        end
    end

    local _setupUIscheduleEntryID = scheduler:scheduleScriptFunc(updateFunc, 1.0 / 60, false)
    self._setupUIscheduleEntryID = _setupUIscheduleEntryID    
end

return BaseLayer