local TaskPanel = class("TaskPanel", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    return node
end)
local effects = require("tool.helper.Effects")
local commonLayer = require("tool.helper.CommonLayer")

local SIMPLEMAPTYPE = 2
local DIFFICULTYMAPTYPE = 3
local POWERTYPE = 12

local TASKPANEL = 1
local ACHIEVEMENTPANEL = TASKPANEL + 1

local NoJumpPanel = 0
local PowerPanel = 404
local EndurancePanel = 405
local CoinTreePanel = 406

function TaskPanel:ctor(currPanel)
    self.data.currPanel = currPanel
    self.data.nameColor = cc.c3b(31, 91, 10)
    self.data.descColor = cc.c3b(48, 124, 42)
    self.data.isViewScroll = false
    self.data.isCanClick = true

    self:createUI()
end

function TaskPanel:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_192.png") 
    self.controls.bg:setAnchorPoint(0, 0.5)
    self:addChild(self.controls.bg)
    local bgSize = self.controls.bg:getContentSize()
    self.data.bgSize = bgSize

    self.controls.taskImg = cc.Sprite:create("image/ui/img/btn/btn_813.png")
    self.controls.taskImg:setPosition(bgSize.width * 0.1, bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.taskImg)

    local imgBg = cc.Sprite:create("image/icon/border/border_star_3.png")
    imgBg:setPosition(bgSize.width * 0.1, bgSize.height * 0.5)
    self.controls.bg:addChild(imgBg)

    self.controls.taskName = Common.finalFont("名字", 1, 1, 25, self.data.nameColor)
    self.controls.taskName:setAnchorPoint(0, 0.5)
    self.controls.taskName:setPosition(bgSize.width * 0.22, bgSize.height * 0.76)
    self.controls.bg:addChild(self.controls.taskName)

    self.controls.taskDesc = Common.finalFont("任务描述", 1, 1, 20, self.data.descColor)
    self.controls.taskDesc:setAnchorPoint(0, 0.5)
    self.controls.taskDesc:setPosition(bgSize.width * 0.22, bgSize.height * 0.57)
    self.controls.bg:addChild(self.controls.taskDesc)

    local award = Common.finalFont("奖励:", 1, 1, 22, cc.c3b(255, 220, 0), 1)
    award:setAnchorPoint(0, 0.5)
    award:setPosition(bgSize.width * 0.21, bgSize.height * 0.28)
    self.controls.bg:addChild(award)
    self.controls.goodsNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.goodsNode)

    self.controls.taskCount = Common.finalFont("0/1", 1, 1, 25, cc.c3b(255, 220, 0), 1)
    self.controls.taskCount:setPosition(bgSize.width * 0.88, bgSize.height * 0.78)
    self.controls.bg:addChild(self.controls.taskCount)
    self.controls.btn_go = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 70))
    self.controls.btn_go:setButtonBounce(false)
    self.controls.btn_go:setCircleFont("前往", 1, 1, 30, cc.c3b(248, 216, 136), 1)
    self.controls.btn_go:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.controls.btn_go:setPosition(bgSize.width * 0.88, bgSize.height * 0.4)
    self.controls.bg:addChild(self.controls.btn_go)
    self.controls.btn_go:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.began then
            Common.addTopSwallowLayer()
            -- self.data.isViewScroll = false
        end
        -- if eventType == ccui.TouchEventType.moved then
        --     self.data.isViewScroll = true
        -- end
        if eventType == ccui.TouchEventType.ended then
            Common.removeTopSwallowLayer()
            if isInside then
                application:dispatchCustomEvent(AppEvent.UI.Task.GetCurrTaskID, 
                                                {TaskID = self.data.taskConfig.ID, 
                                                TaskType = self.data.taskConfig.Type, IsRefurbish = false})
                local taskType = self.data.taskConfig.Jump
                self:jumpToScene(taskType)
            end
        end
    end)

    self.controls.btn_finish = effects:CreateAnimation(self.controls.bg, bgSize.width * 0.86, bgSize.height * 0.5, nil, 18, true)

    self.controls.powerAlert = Common.finalFont("时间未到", 1, 1, 25, cc.c3b(10, 51, 91))
    self.controls.powerAlert:setPosition(bgSize.width * 0.88, bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.powerAlert)
    
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) and self.data.isTaskFinish and self.data.isCanClick then
            Common.addTopSwallowLayer()
            self.data.isViewScroll = false
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local deltaPos = touch:getDelta()
        if math.abs(deltaPos.y) > 5 then
            self.data.isViewScroll = true
        end
    end

    local function onTouchEnded(touch, event)
        Common.removeTopSwallowLayer()
        if self.data.isViewScroll then
            return
        end
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            self:ReceiveAwards(self.data.taskConfig.ID, self.data.taskConfig.Type)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.bg)
end

function TaskPanel:updatePanelInfo(taskInfo)
    local taskConfig = nil
    if TASKPANEL == self.data.currPanel then
        taskConfig = BaseConfig.getTask(taskInfo.ID)
    elseif ACHIEVEMENTPANEL == self.data.currPanel then
        taskConfig = BaseConfig.getAchievement(taskInfo.ID)
    end

    self.controls.powerAlert:setVisible(false)
    self.controls.btn_go:setScale(1)
    if taskInfo.IsFinish then
        self.data.isTaskFinish = true
        self.controls.bg:setTexture("image/ui/img/bg/bg_191.png")
        self.controls.btn_finish:setVisible(true)
        self.controls.taskCount:setVisible(false)
        self.controls.btn_go:setTouchEnable(false)
        self.controls.btn_go:setVisible(false)

        self.data.nameColor = cc.c3b(31, 91, 10)
        self.data.descColor = cc.c3b(48, 124, 42)
    else
        self.data.isTaskFinish = false

        self.controls.bg:setTexture("image/ui/img/bg/bg_192.png")
        self.controls.taskCount:setVisible(true)
        self.controls.btn_go:setTouchEnable(true)
        self.controls.btn_go:setVisible(true)
        self.controls.btn_finish:setVisible(false)

        self.data.nameColor = cc.c3b(10, 51, 91)
        self.data.descColor = cc.c3b(42, 87, 124)

        if TASKPANEL == self.data.currPanel then
            self.controls.taskCount:setString(taskInfo.Count.."/"..taskConfig.Value)
        elseif ACHIEVEMENTPANEL == self.data.currPanel then
            local achievementType = taskConfig.Type
            if (SIMPLEMAPTYPE == achievementType) or (DIFFICULTYMAPTYPE == achievementType) then
                self.controls.taskCount:setVisible(false)
            else
                self.controls.taskCount:setVisible(true)
                self.controls.taskCount:setString(taskInfo.Count.."/"..taskConfig.Value[(#taskConfig.Value)])
            end
        end
        if NoJumpPanel == taskConfig.Jump then
            self.controls.taskCount:setVisible(false)
            self.controls.btn_go:setTouchEnable(false)
            self.controls.btn_go:setVisible(false)
            self.controls.powerAlert:setVisible(false)
        end

        if POWERTYPE == taskConfig.Type then
            self.controls.taskCount:setVisible(false)
            self.controls.btn_go:setTouchEnable(false)
            self.controls.btn_go:setVisible(false)
            self.controls.powerAlert:setVisible(true)
        end
    end
    if TASKPANEL == self.data.currPanel then
        self.controls.taskImg:setTexture("image/icon/task/rw/"..taskConfig.Icon..".png")
    elseif ACHIEVEMENTPANEL == self.data.currPanel then
        self.controls.taskImg:setTexture("image/icon/task/cj/"..taskConfig.Icon..".png")
    end
    self.controls.taskName:setColor(self.data.nameColor)
    self.controls.taskDesc:setColor(self.data.descColor)
    self.controls.taskName:setString(taskConfig.Name)
    self.controls.taskDesc:setString(taskConfig.Desc)

    self.data.goodsInfoTabs = {}
    for k,v in pairs(taskConfig.Award) do
        local goodsInfo = {}
        goodsInfo.ID = v.GoodsID
        goodsInfo.Type = v.GoodsType
        goodsInfo.Num = v.Num
        table.insert(self.data.goodsInfoTabs, goodsInfo)
    end
    self:updateGoodsInfo(self.data.goodsInfoTabs)

    self.data.taskConfig = taskConfig
end

function TaskPanel:updateGoodsInfo(goodsInfoTabs)
    self.controls.goodsNode:removeAllChildren()
    for k,v in pairs(goodsInfoTabs) do
        local distance = 110

        local goodsItem = nil
        if BaseConfig.GT_AVATAR == v.Type and 1 == v.ID then
            goodsItem = cc.Sprite:create("image/ui/img/btn/btn_671.png")
            goodsItem:setScale(0.8)
        else
            goodsItem = Common.getGoods(v, false, BaseConfig.GOODS_LEASTTYPE)
        end
        if goodsItem.setNumVisible then
            goodsItem:setNumVisible(false)
        end
        local numLab = goodsItem:getChildByName("num")
        if numLab then
            numLab:setVisible(false)
        end
        goodsItem:setPosition(self.data.bgSize.width * 0.33 + (k - 1) * distance, self.data.bgSize.height * 0.28)
        self.controls.goodsNode:addChild(goodsItem)

        local num = Common.finalFont("x"..v.Num, 1, 1, 20, self.data.nameColor)
        num:setAnchorPoint(0, 0.5)
        num:setPosition(self.data.bgSize.width * 0.36 + (k - 1) * distance, self.data.bgSize.height * 0.28)
        self.controls.goodsNode:addChild(num)
    end
end

function TaskPanel:playOpenAction(time)
    self:setScaleY(0)
    local delay = cc.DelayTime:create(time)
    local scale1 = cc.ScaleTo:create(0.1, 1, 1.1)
    local scale2 = cc.ScaleTo:create(0.05, 1, 1)
    self:runAction(cc.Sequence:create(delay, scale1, scale2))
end

function TaskPanel:jumpToScene(panelID)
    if CoinTreePanel == panelID then
        local coinTree = require("scene.main.CoinTreeLayer").new(self.data.taskConfig.ID)
        coinTree:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(coinTree)
        return 
    end
    local callFunc = nil
    if PowerPanel == panelID then
        callFunc = function()
            application:dispatchCustomEvent(AppEvent.UI.Task.GetCurrTaskID, 
                                        {TaskID = self.data.taskConfig.ID, 
                                        TaskType = self.data.taskConfig.Type, IsRefurbish = true})
        end
    elseif EndurancePanel == panelID then
        callFunc = function()
            application:dispatchCustomEvent(AppEvent.UI.Task.GetCurrTaskID, 
                                        {TaskID = self.data.taskConfig.ID, 
                                        TaskType = self.data.taskConfig.Type, IsRefurbish = true})
        end
    end
    Common.jumpToScene(panelID, callFunc)
end

--[[
    领取奖励
]]
function TaskPanel:ReceiveAwards(task_id, task_type)
    self.data.isCanClick = false
    if TASKPANEL == self.data.currPanel then
        rpc:call("Task.ReceiveAwards", task_id, function(event)
            if (event.status == Exceptions.Nil) and (event.result) then
                application:dispatchCustomEvent(AppEvent.UI.Task.DrawAward, 
                                                    {TaskID = self.data.taskConfig.ID, Award = self.data.goodsInfoTabs, TaskInfo = nil})
            end
            self.data.isCanClick = true
        end)
    elseif ACHIEVEMENTPANEL == self.data.currPanel then
        rpc:call("Achievement.ReceiveAwards", task_type, function(event)
            if event.status == Exceptions.Nil then
                application:dispatchCustomEvent(AppEvent.UI.Task.DrawAward, 
                                                    {TaskID = self.data.taskConfig.ID, Award = self.data.goodsInfoTabs, TaskInfo = event.result})
            end
            self.data.isCanClick = true
        end)
    end
end

return TaskPanel




