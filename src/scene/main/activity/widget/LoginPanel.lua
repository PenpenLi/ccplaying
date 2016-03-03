local LoginPanel = class("LoginPanel", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    return node
end)
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

local NoJumpPanel = 0
local PowerPanel = 404
local EndurancePanel = 405
local CoinTreePanel = 406

-- 以下条件类型需特殊处理
local SIMPLEMAP_TYPE = 2
local DIFFICULTYMAP_TYPE = 3
local WEAREQUIP_TYPE = 21

function LoginPanel:ctor(info)
    self.data.taskInfo = info
    self.data.isViewScroll = false
    self.data.isCanClick = true
    self.data.isJump = true

    self:createUI()
end

function LoginPanel:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_353.png") 
    self:addChild(self.controls.bg)
    local bgSize = self.controls.bg:getContentSize()
    self.data.bgSize = bgSize
    self.controls.bg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)

    local taskSpri = cc.Sprite:create("image/ui/img/btn/btn_1254.png")
    taskSpri:setPosition(bgSize.width * 0.09, bgSize.height * 0.8)
    self:addChild(taskSpri)

    self.controls.taskDesc = ColorLabel.new("", 20)
    self.controls.taskDesc:setAnchorPoint(0, 0.5)
    self.controls.taskDesc:setPosition(bgSize.width * 0.17, bgSize.height * 0.8)
    self:addChild(self.controls.taskDesc)

    self.controls.goodsNode = cc.Node:create()
    self:addChild(self.controls.goodsNode)

    self.controls.progress = ColorLabel.new("", 20)
    self.controls.progress:setPosition(bgSize.width * 0.9, bgSize.height * 0.9)
    self:addChild(self.controls.progress)

    self.controls.btn_recive = createMixSprite("image/ui/img/btn/btn_956.png", "image/ui/img/btn/btn_957.png")
    self.controls.btn_recive:setButtonBounce(false)
    self.controls.btn_recive:setScale(0.85)
    self.controls.btn_recive:setCircleFont("", 1, 1, 25, cc.c3b(255, 251, 233))
    self.controls.btn_recive:setFontOutline(cc.c4b(65, 26, 1, 255), 2)
    self.controls.btn_recive:setPosition(bgSize.width * 0.9,bgSize.height * 0.45)
    self:addChild(self.controls.btn_recive)

    self.controls.finish = cc.Sprite:create("image/ui/img/btn/btn_1168.png")
    self.controls.finish:setPosition(bgSize.width * 0.65, bgSize.height * 0.5)
    self:addChild(self.controls.finish)

    self.controls.btnEffect = require("tool.helper.Effects"):CreateAnimation(self.controls.btn_recive, 0, 0, nil, 49, true)

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
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.bg)
end

function LoginPanel:setBgVisible(visible)
    self.controls.bg:setVisible(visible)
end

function LoginPanel:setJump(visible)
    self.data.isJump = visible
end

function LoginPanel:updatePanelInfo(taskInfo)
    self.data.taskInfo = taskInfo

    local taskConfig = BaseConfig.getLoginTaskConfig(taskInfo.ID)
    local goodsInfoTabs = {}
    for k,v in pairs(taskConfig.GoodsList) do
        local goodsInfo = {}
        goodsInfo.ID = v.GoodsID
        goodsInfo.Type = v.GoodsType
        goodsInfo.Num = v.Num
        table.insert(goodsInfoTabs, goodsInfo)
    end
    self:updateGoodsInfo(goodsInfoTabs)

    local currValue = taskInfo.Step
    local totalValue = taskConfig.Value[#taskConfig.Value]
    local isFinish = false

    local conditionType = taskConfig.Type
    if (conditionType == SIMPLEMAP_TYPE) or (conditionType == DIFFICULTYMAP_TYPE) then
        totalValue = 1
    elseif conditionType == WEAREQUIP_TYPE then
        totalValue = 1
    end

    if currValue < totalValue then
        isFinish = false
        self.controls.progress:setString("[249,24,24]"..currValue.."[=][255,255,255]/"..totalValue.."[=]")

        self.controls.btnEffect:setVisible(false)
        if self.data.isJump then
            self.controls.btn_recive:setTouchEnable(true)
            self.controls.btn_recive:setNorGLProgram(true)
        else
            self.controls.btn_recive:setTouchEnable(false)
            self.controls.btn_recive:setNorGLProgram(false)
        end
        self.controls.btn_recive:setTouchStatus()
        self.controls.btn_recive:setString("GO")
        self.controls.finish:setVisible(false)
    else
        isFinish = true
        self.controls.progress:setString("[239,239,168]"..currValue.."[=][255,255,255]/"..totalValue.."[=]")

        if taskInfo.Status then
            self.controls.btn_recive:setTouchEnable(false)
            self.controls.btn_recive:setNorGLProgram(false)
            self.controls.btnEffect:setVisible(false)
            self.controls.btn_recive:setString("已领取")
        else
            self.controls.btn_recive:setTouchEnable(true)
            self.controls.btn_recive:setNorGLProgram(true)
            self.controls.btnEffect:setVisible(true)
            self.controls.btn_recive:setString("领取")
        end
        self.controls.btn_recive:setNormalStatus()
        self.controls.finish:setVisible(true)

    end

    self.controls.taskDesc:setString(taskConfig.Desc)
    self.controls.btn_recive:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.began then
            Common.addTopSwallowLayer()
        end
        
        if eventType == ccui.TouchEventType.ended then
            Common.removeTopSwallowLayer()
            if isInside and not self.data.isViewScroll then
                if self.data.isJump then
                    if not taskInfo.Status then
                        if isFinish then
                            CCLog('==========完成==========')
                            self:ReceiveAwards(taskInfo.ID)
                        else
                            local taskType = self.data.taskConfig.Jump
                            self:jumpToScene(taskType)
                        end
                    end
                elseif isFinish then
                    CCLog('==========完成==========')
                    self:ReceiveAwards(taskInfo.ID)
                end
            end
        end
    end)

    self.data.taskConfig = taskConfig
end

function LoginPanel:updateGoodsInfo(goodsInfoTabs)
    self.controls.goodsNode:removeAllChildren()
    for k,v in pairs(goodsInfoTabs) do
        local distance = 75

        local goodsItem = nil
        if BaseConfig.GT_AVATAR == v.Type and 1 == v.ID then
            goodsItem = cc.Sprite:create("image/ui/img/btn/btn_671.png")
            goodsItem:setScale(0.8)
        else
            goodsItem = Common.getGoods(v, false, BaseConfig.GOODS_SMALLTYPE)
        end
        
        goodsItem:setPosition(self.data.bgSize.width * 0.09 + (k - 1) * distance, self.data.bgSize.height * 0.35)
        self.controls.goodsNode:addChild(goodsItem)
    end
end

function LoginPanel:jumpToScene(panelID)
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
function LoginPanel:ReceiveAwards(id)
    application:dispatchCustomEvent(AppEvent.UI.Activity.LoginAward, 
                                                    {TaskID = id})
    
end

return LoginPanel




