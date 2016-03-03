local QuickGuide = class("QuickGuide")
local ColorLabel = require("tool.helper.ColorLabel")
local EffectManager = require("tool.helper.Effects")
local scheduler = cc.Director:getInstance():getScheduler()

QuickGuide.__sharedInstance = nil

local HEROPANEL = 102
local EquipIntensifyPanel = 106
local SimpleMapPanel = 201
local ActivityCenterLayer = 407

-- 小蜜蜂状态
local CLOSESTATUS = 0
local OPENSTATUS = 1
local REACHSTATUS = 2
local ENDSTATUS = 3

-- 是否进行引导
local GUIDE_NO = 0
local GUIDE_YES = 1

local IdleActionStatus = 0 --待机
local BlinkActionStatus = IdleActionStatus + 1 --眨眼
local FinishActionStatus = BlinkActionStatus + 1 --完成任务
local HitActionStatus = FinishActionStatus + 1 --撞击屏幕
local MoveActionStatus = HitActionStatus + 1 --移动

local GUIDE_POSX = 50
local GUIDE_POSY = 100
local LASTID = BaseConfig.getBeeCount()

local NODEZORDER = 10
local PANELNAME = "taskPanel"

function QuickGuide:getInstance()
    if not QuickGuide.__sharedInstance then
        QuickGuide.__sharedInstance = QuickGuide.new()
        QuickGuide.__sharedInstance:init()
    end
    return QuickGuide.__sharedInstance
end

function QuickGuide:ctor()
    self.beeStatus = CLOSESTATUS -- 记录任务状态
    self.beeAnimStatus = IdleActionStatus --小蜜蜂动画状态
    self.isHaveBee = false -- 是否存在小蜜蜂
    self.isShowBee = false -- 是否显示小蜜蜂
    self.isAutoShowFinish = true -- 是否主动打开完成界面
    self.isGuide = false

    local initStatus = false -- 判断小蜜蜂是否在屏幕内,是否已完成任务(主要用来第一次记录小蜜蜂的各种状态)
    local listener = application:addEventListener(AppEvent.UI.Heartbeat.Bee, function(event)
        local result = event.data
        self.IsDouble = result.IsDouble
        self.beeStatus = result.Status

        if CLOSESTATUS == self.beeStatus then
            self.isShowBee = false
        else
            self.isShowBee = true
            local alert = self.btn_guide:getChildByName("alert")
            if OPENSTATUS == self.beeStatus then
                -- 开启
            elseif REACHSTATUS == self.beeStatus then
                -- 完成
                if initStatus and (not GameCache.NewbieGuide.State) then
                    if (self.beeAnimStatus ~= MoveActionStatus) and (self.beeAnimStatus ~= FinishActionStatus) then
                        self:playFinishAnim()
                    end
                    if (not self.isOpenPanel) and self.isAutoShowFinish then
                        self:autoJump()
                    end
                end
            end

            if result.IsDouble then
                if self.isOpenPanel then
                    alert:setVisible(false)
                else
                    alert:setVisible(true)
                end
            else
                alert:setVisible(false)
            end
        end
        if not initStatus then
            -- 记录小蜜蜂的初始状态
            if self.isShowBee then
                self.isHaveBee = true
            end
            initStatus = true
            self:init()
        end
    end)
end

function QuickGuide:init()
    if not self.isHaveNode then
        self:createUI()
        self.isHaveNode = true
    else
        self:reset()
    end
end

function QuickGuide:createUI()
    self.node = cc.Layer:create()
    self.node:retain()

    local btnSize = cc.size(100, 80)
    self.btn_guide = cc.Node:create()
    self.btn_guide:setContentSize(btnSize)
    self.btn_guide:setAnchorPoint(0.5, 0.5)
    self.btn_guide:setPosition(GUIDE_POSX, SCREEN_HEIGHT * 0.5 - btnSize.height)
    self.node:addChild(self.btn_guide, 1)

    self.guideAnim = sp.SkeletonAnimation:create("image/spine/skill_effect/bee/skeleton.skel", "image/spine/skill_effect/bee/skeleton.atlas")
    self.guideAnim:setName("anim")
    self.guideAnim:setPosition(btnSize.width * 0.5, 0)
    self.btn_guide:addChild(self.guideAnim)
    self.guideAnim:setScaleX(1)
    self.guideAnim:setMix("idle", "blink", 0.1)
    self.guideAnim:setMix("blink", "idle", 0.1)
    self.guideAnim:setMix("idle", "move", 0.1)
    self.guideAnim:setMix("move", "hit", 0.1)
    self.guideAnim:setMix("idle", "completed", 0.1)
    self:playIdleAnim()

    self.blinkEffect = sp.SkeletonAnimation:create("image/spine/skill_effect/beepao/skeleton.skel", "image/spine/skill_effect/beepao/skeleton.atlas")
    self.blinkEffect:setPosition(btnSize.width * 0.5, btnSize.height * 0.4)
    self.btn_guide:addChild(self.blinkEffect)
    self.blinkEffect:setVisible(false)

    local xs = cc.Sprite:create("image/ui/img/bg/xsrenwu.png")
    xs:setPosition(btnSize.width * 0.5, -btnSize.height * 0.1)
    self.btn_guide:addChild(xs)

    local alert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    alert:setName("alert")
    alert:setPosition(btnSize.width * 0.85, btnSize.height * 0.85)
    self.btn_guide:addChild(alert)
    alert:setVisible(false)
    self.btnSize = btnSize

    self.guideEffect = EffectManager:CreateAnimation(self.node, 0, 0, nil, 1, true)
    self.guideEffect:setVisible(false)

    local function onTouchBegan(touch, event)
        if self.isGuide then
            self.isGuide = false
            self.guideEffect:setVisible(false)
        end

        if self.isOpenPanel then
            return false
        end

        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            self.listener:setSwallowTouches(true)
            self:playMoveAnim()
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local previousPos = touch:getPreviousLocation()
        local currPos = cc.p(self.btn_guide:getPositionX(), self.btn_guide:getPositionY())
        local deltaPos = touch:getDelta()
        local nowPos = cc.p(currPos.x, currPos.y + deltaPos.y)
        local endPos = self:endPosConvert(nowPos)
        self.btn_guide:setPosition(endPos)
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        local startLocation = touch:getStartLocation()
        local distance = cc.pGetDistance(location, startLocation)

        self:playIdleAnim()
        local endPos = self:endPosConvert(location)

        if distance < 20 then
            self.isOpenPanel = true
            rpc:call("Bee.Info", nil, function(event)
                if event.status == Exceptions.Nil then
                    self.listener:setSwallowTouches(false)

                    self.BeeInfo = event.result[1]
                    self.beeConfig = BaseConfig.getBeeConfig(self.BeeInfo.ID)

                    self:taskPanel()
                else
                    self.listener:setSwallowTouches(false)
                    self.isOpenPanel = false
                end
            end)
        else
            self:playHitAnim()
        end
    end

    self.listener = cc.EventListenerTouchOneByOne:create()
    self.listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self.node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener, self.btn_guide)

    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(self.node, -1)
end

function QuickGuide:reset()
    if not self.node then
        return 
    end
    self.node:removeFromParent()
    local runningScene = cc.Director:getInstance():getRunningScene()

    if self.isShowBee then
        if GameCache.NewbieGuide.State then
            runningScene:addChild(self.node, -1)
        else
            runningScene:addChild(self.node, NODEZORDER)
            local currPos = cc.p(self.btn_guide:getPositionX(), self.btn_guide:getPositionY())
            local endPos = self:endPosConvert(currPos)
            self.btn_guide:setPosition(endPos)
            if not self.isHaveBee then
                self.isHaveBee = true
                self:autoJump()
            end
            if self.isOpenPanel then
                self:autoJump()
            end
        end
    else
        runningScene:addChild(self.node, -1)
    end
end

function QuickGuide:taskPanel()
    local panel = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    panel:setName(PANELNAME)
    local panelBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1293.png")
    panelBg:setAnchorPoint(0, 0.5)
    local currPos = cc.p(self.btn_guide:getPositionX(), self.btn_guide:getPositionY())
    panelBg:setPosition(currPos.x, currPos.y)
    panel:addChild(panelBg)
    self.panelSize = panelBg:getContentSize()
    panelBg:setScale(0)

    local doubleLogo = nil -- 双倍描述
    local doubleClock = nil 
    local doubleTimeFont = nil -- 双倍倒计时
    local timeCount = self.BeeInfo.DoubleTime
    local schedulerTime = scheduler:scheduleScriptFunc(function()
        if doubleTimeFont then
            if timeCount > 0 then
                timeCount = timeCount - 1
                doubleTimeFont:setString(Common.timeFormat(timeCount))
            else
                doubleLogo:setVisible(false)
                doubleClock:setVisible(false)
                doubleTimeFont:setVisible(false)
                self.IsDouble = false
            end
        end
    end, 1, false)

    local function closePanel(isPlayCloseAction, isFinishTask)
        local function removePanel()
            self.isOpenPanel = false
            scheduler:unscheduleScriptEntry(schedulerTime)
            panel:removeFromParent()
            panel = nil

            if isFinishTask then
                self.isAutoShowFinish = false
                self:playIdleAnim()
                -- 是否开启下一个任务
                if 0 == self.BeeInfo.ID then
                    self.isAutoShowFinish = true
                    self.isShowBee = false
                    if ENDSTATUS == self.beeStatus then
                        self.node:removeFromParent()
                        self.node = nil
                    else
                        self.beeStatus = CLOSESTATUS
                        self.node:setLocalZOrder(-1)
                    end
                else
                    -- 新任务未完成
                    self.isAutoShowFinish = true
                    self:autoJump()
                end
            else
                if isPlayCloseAction then
                    -- (点击面板外触发)
                    if REACHSTATUS == self.beeStatus then
                        self.isAutoShowFinish = false
                    else
                        self.isAutoShowFinish = true
                    end
                else
                    -- 回到初始位置(点击前往触发)
                    self.isAutoShowFinish = true
                    self:jumpToScene()

                    if (GUIDE_YES == self.beeConfig.GuideAfter) and (OPENSTATUS == self.beeStatus) then
                        self.isGuide = true
                        self.guideEffect:setVisible(true)
                        local posX = nil
                        local posY = nil
                        local bigWidth = 1000 -- 判断屏幕分辨率问题
                        if self.beeConfig.GuideAfterPos[1] > bigWidth then
                            posX = SCREEN_WIDTH - (self.beeConfig.GuideAfterPos[1] - bigWidth)
                        else
                            posX = SCREEN_WIDTH*0.5 + self.beeConfig.GuideAfterPos[1]
                        end
                        posY = SCREEN_HEIGHT*0.5 + self.beeConfig.GuideAfterPos[2]
                        self.guideEffect:setPosition(posX, posY)
                    end

                end
            end
        end
        local action = cc.Sequence:create({cc.ScaleTo:create(0.1, 1.1),cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(removePanel)})
        panelBg:runAction(action)
    end

    local function openPanel()     
        local targetLogo = cc.Sprite:create("image/ui/img/btn/btn_1254.png")
        targetLogo:setPosition(self.panelSize.width * 0.16, self.panelSize.height * 0.8)
        targetLogo:setAnchorPoint(0.5, 1)
        panelBg:addChild(targetLogo)
        local taskDesc = ColorLabel.new("", 20, 15)
        taskDesc:setAnchorPoint(0, 1)
        taskDesc:setPosition(self.panelSize.width * 0.24,self.panelSize.height * 0.8)
        panelBg:addChild(taskDesc)
        local str = self.beeConfig.Desc
        taskDesc:setString(str)

        local finish = cc.Sprite:create("image/ui/img/btn/btn_1168.png")
        panelBg:addChild(finish, 1) 
        finish:setScale(0)
        local finishShadow = cc.Sprite:create("image/ui/img/btn/btn_1168.png")
        finishShadow:setPosition(self.panelSize.width * 0.85,self.panelSize.height * 0.8)
        panelBg:addChild(finishShadow, 1) 
        finishShadow:setOpacity(0)
        local finishDouble = nil
        if self.BeeInfo.DoubleTime > 0 then
            finishDouble = cc.Sprite:create("image/ui/img/btn/btn_1170.png")
            finishDouble:setPosition(80, 12)
            finishShadow:addChild(finishDouble)
            finishDouble:setOpacity(0)
        end

        if not self.BeeInfo.IsFinish then
            doubleLogo = cc.Sprite:create("image/ui/img/btn/btn_1256.png")
            doubleLogo:setPosition(self.panelSize.width * 0.35,self.panelSize.height * 0.12)
            panelBg:addChild(doubleLogo)

            doubleClock = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
            doubleClock:setPosition(self.panelSize.width * 0.52,self.panelSize.height * 0.12)
            panelBg:addChild(doubleClock)

            doubleTimeFont = Common.finalFont("", 1, 1, 20, cc.c3b(250, 248, 151), 1)
            doubleTimeFont:setAnchorPoint(0, 0.5)
            doubleTimeFont:setPosition(self.panelSize.width * 0.56,self.panelSize.height * 0.12)
            panelBg:addChild(doubleTimeFont)

            if timeCount < 1 then
                doubleLogo:setVisible(false)
                doubleClock:setVisible(false)
                doubleTimeFont:setVisible(false)
            end
        end

        local goodsTabs = self.beeConfig.Award
        local goodsView = self:createGoodsView(goodsTabs, cc.size(self.panelSize.width * 0.7, 65))
        goodsView:setName("view")
        panelBg:addChild(goodsView) 
        local goodsNum = #goodsTabs
        if goodsNum > 5 then
            goodsView:setPosition(60, self.panelSize.height * 0.26)
        else
            goodsView:setTouchEnabled(false)
            goodsView:setPosition(self.panelSize.width * 0.46 - goodsNum * 30, self.panelSize.height * 0.26)
        end

        local sure = createMixSprite("image/ui/img/btn/btn_957.png")
        sure:setScale(0.85)
        sure:setCircleFont("", 1, 1, 25, cc.c3b(255, 251, 233))
        sure:setFontOutline(cc.c4b(65, 26, 1, 255), 2)
        sure:setPosition(self.panelSize.width * 0.95,self.panelSize.height * 0.5)
        panelBg:addChild(sure)
        sure:addTouchEventListener(function(sender, eventType, inside)
            if (eventType == ccui.TouchEventType.ended) and inside then
                if self.BeeInfo.IsFinish then
                    rpc:call("Bee.ReceiveAwards", self.beeConfig.ID, function(event)
                        if event.status == Exceptions.Nil then
                            -- local tempGoods = {}
                            -- for k,v in pairs(self.beeConfig.Award) do
                            --     local goodsInfo = {}
                            --     goodsInfo.ID = v.GoodsID
                            --     goodsInfo.Type = v.GoodsType
                            --     if isDouble then
                            --         goodsInfo.Num = v.Num * 2
                            --     else
                            --         goodsInfo.Num = v.Num
                            --     end
                            --     table.insert(tempGoods, goodsInfo)
                            -- end
                            application:showIconNotice(event.result.AwardsList)
                            self.BeeInfo = event.result.NextStatus

                            if 0 ~= self.BeeInfo.ID then
                                self.beeConfig = BaseConfig.getBeeConfig(self.BeeInfo.ID)
                            end

                            if self.BeeInfo.IsFinish then
                                taskDesc:setString(self.beeConfig.Desc)
                                local goodsView = panelBg:getChildByName("view")
                                if goodsView then
                                    goodsView:removeFromParent()
                                    goodsView = nil
                                end
                                local goodsTabs = self.beeConfig.Award
                                local goodsView = self:createGoodsView(goodsTabs, cc.size(self.panelSize.width * 0.7, 65))
                                goodsView:setName("view")
                                panelBg:addChild(goodsView) 
                                local goodsNum = #goodsTabs
                                if goodsNum > 5 then
                                    goodsView:setPosition(60, self.panelSize.height * 0.26)
                                else
                                    goodsView:setTouchEnabled(false)
                                    goodsView:setPosition(self.panelSize.width * 0.46 - goodsNum * 30, self.panelSize.height * 0.26)
                                end
                            else
                                closePanel(false, true)
                            end
                        end
                    end)
                else
                    closePanel(false)
                end
            end
        end)

        local effect = EffectManager:CreateAnimation(sure, 0, 0, nil, 49, true)
        effect:registerSpineEventHandler(function ( event )
            local ram = math.random(1, 2)
            if 1 == ram then
                effect:setVisible(false)
            else
                effect:setVisible(true)
            end
        end, sp.EventType.ANIMATION_COMPLETE)

        if (GUIDE_YES == self.beeConfig.GuideBefore) and (OPENSTATUS == self.beeStatus) then
            self.isGuide = true
            self.guideEffect:setVisible(true)
            self.guideEffect:setPosition(SCREEN_WIDTH * 0.5 + self.beeConfig.GuideBeforePos[1], 
                                        SCREEN_HEIGHT * 0.5 + self.beeConfig.GuideBeforePos[2])
        end
        
        local function finishAction()
            finish:setPosition(self.panelSize.width * 0.5,self.panelSize.height * 0.5)
            local delayTime0 = 0.5
            local delayTime1 = 0.3
            local moveTime = 0.1
            local delay0 = cc.DelayTime:create(delayTime0)
            local delay1 = cc.DelayTime:create(delayTime1)
            local scale1 = cc.ScaleTo:create(moveTime, 1)
            local move1 = cc.MoveTo:create(moveTime, cc.p(self.panelSize.width * 0.85,self.panelSize.height * 0.8))
            local spawn1 = cc.Spawn:create(scale1, move1)

            local fadeTime = 0.05
            local fadein11 = cc.FadeIn:create(fadeTime)
            local scale11 = cc.ScaleTo:create(fadeTime, 1.5)
            local spawn11 = cc.Spawn:create(fadein11, scale11)
            local fadeout12 = cc.FadeOut:create(fadeTime)
            local scale12 = cc.ScaleTo:create(fadeTime, 1)
            local spawn12 = cc.Spawn:create(fadeout12, scale12)

            local delay2 = cc.DelayTime:create(delayTime0 + delayTime1 + moveTime)
            local shake1 = cc.Shake:create(0.2, 6)
            finish:runAction(cc.Sequence:create(delay0, cc.CallFunc:create(function()
                finish:setScale(6)
            end), delay1, spawn1))
            finishShadow:runAction(cc.Sequence:create(delay2, cc.CallFunc:create(function()
                if finishDouble then
                    finishDouble:setOpacity(255)
                end
            end), spawn11, spawn12))
            panelBg:runAction(cc.Sequence:create(delay2:clone(), shake1))
        end
        if self.BeeInfo.IsFinish then
            finishAction()
            sure:setString("领取")
            sure:setTexture("image/ui/img/btn/btn_956.png")
        else
            sure:setString("GO")
            sure:setTexture("image/ui/img/btn/btn_957.png")
        end
    end

    -- 这层屏蔽tableView中超出可视区域的物品
    local layer = Common.createClickLayer(self.panelSize.width, self.panelSize.height, 0, 0)
    panelBg:addChild(layer, 1)
    -- 这层主要是为了点击整个面板以外能关闭界面
    local closeLayer = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    closeLayer:setAnchorPoint(0, 0)
    closeLayer:setContentSize(self.panelSize)
    panelBg:addChild(closeLayer, 1)
    closeLayer:setOpacity(0)
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
            closePanel(true)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, closeLayer)

    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(panel)

    panel.openFunc = function()
        local action = cc.Sequence:create({cc.ScaleTo:create(0.2, 1.1),cc.ScaleTo:create(0.1, 1.0), cc.CallFunc:create(openPanel)})
        panelBg:runAction(action)
    end
    panel.openFunc()
end

function QuickGuide:createGoodsView(goodsTabs, tableSize)
    local function cellSizeForTable(table,idx) 
        return tableSize.height,(#goodsTabs) * 70
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), (#goodsTabs) * 70, tableSize.height)
            for k,v in pairs(goodsTabs) do
                local goodsInfo = {}
                goodsInfo.ID = v.GoodsID
                goodsInfo.Type = v.GoodsType
                goodsInfo.Num = v.Num

                local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_SMALLTYPE)
                goodsItem:setPosition((k - 1) * 70 + 30, tableSize.height * 0.5)
                layerColor:addChild(goodsItem)
            end
            return layerColor
        end

        if cell then
            cell:removeFromParent()
            cell = nil
        end
        cell = cc.TableViewCell:new()
        cell:addChild(getLayer())
        return cell
    end

    local function numberOfCellsInTableView(table)
       return 1
    end

    local tableView = cc.TableView:create(tableSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView 
end

function QuickGuide:autoJump()
    if not self:getIsEqualScene() then
        return
    end

    self.isOpenPanel = true
    self.isAutoShowFinish = false
    self.btn_guide:stopAllActions()

    local delay = cc.DelayTime:create(0.5)
    self.btn_guide:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
        rpc:call("Bee.Info", nil, function(event)
            if event.status == Exceptions.Nil then
                self.BeeInfo = event.result[1]
                self.beeConfig = BaseConfig.getBeeConfig(self.BeeInfo.ID)

                if not self:getIsEqualScene() then
                    self.isOpenPanel = false
                    self.isAutoShowFinish = true
                    return
                end
                self:taskPanel()
            end
        end)
    end)))
end

function QuickGuide:endPosConvert(endPos)
    local endX = GUIDE_POSX
    local endY = endPos.y

    if endY >= (SCREEN_HEIGHT - GUIDE_POSY) then
        endY = SCREEN_HEIGHT - GUIDE_POSY
    elseif endY <= GUIDE_POSY then
        endY = GUIDE_POSY
    end

    return {x = endX, y = endY}
end

function QuickGuide:jumpToScene()
    cc.Director:getInstance():popToRootScene()
    local delayFunc = function()
        if self.delayFunc then
            scheduler:unscheduleScriptEntry(self.delayFunc)
            self.delayFunc = nil

            local jump = self.beeConfig.Jump
            CCLog("=======进入新场景=========", jump)
            if (HEROPANEL == jump) or (EquipIntensifyPanel == jump) or (SimpleMapPanel == jump) or (ActivityCenterLayer == jump) then
                Common.jumpToScene(self.beeConfig.Jump, nil, self.beeConfig.Jump2, self.beeConfig.Jump3)
            else
                Common.jumpToScene(self.beeConfig.Jump)
            end
        end
    end
    self.delayFunc = scheduler:scheduleScriptFunc(delayFunc, 0, false)
end

function QuickGuide:playIdleAnim()
    self.beeAnimStatus = IdleActionStatus
    self.guideAnim:setAnimation(0, "idle", true)
    local playCount = 0
    local playTotal = math.random(2, 10)
    self.guideAnim:registerSpineEventHandler(function ( event )
        if self.beeAnimStatus == IdleActionStatus then
            playCount = playCount + 1
            if playCount > playTotal then
                self:playBlinkAnim()
            end
        end
    end, sp.EventType.ANIMATION_COMPLETE)
end

function QuickGuide:playBlinkAnim()
    self.beeAnimStatus = BlinkActionStatus
    self.guideAnim:setAnimation(0, "blink", false)
    self.blinkEffect:setVisible(true)
    self.blinkEffect:setAnimation(0, "animation", false)

    self.guideAnim:registerSpineEventHandler(function ( event )
        self:playIdleAnim()
    end, sp.EventType.ANIMATION_COMPLETE)
end

function QuickGuide:playFinishAnim()
    self.beeAnimStatus = FinishActionStatus
    self.guideAnim:setAnimation(0, "completed", true)
end

function QuickGuide:playHitAnim(callFunc)
    self.beeAnimStatus = HitActionStatus
    self.guideAnim:setAnimation(0, "hit", false)
    self.guideAnim:registerSpineEventHandler(function ( event )
        self:playIdleAnim()
        if callFunc then
            callFunc()
        end
    end, sp.EventType.ANIMATION_COMPLETE)
end

function QuickGuide:playMoveAnim()
    self.beeAnimStatus = MoveActionStatus
    self.guideAnim:setAnimation(0, "move", true)
end

function QuickGuide:isOpenBeePanel()
    return self.isOpenPanel
end

function QuickGuide:getIsEqualScene()
    local runningScene = cc.Director:getInstance():getRunningScene()
    local parent = self.node:getParent()
    local isEqual = (runningScene == parent)
    return isEqual
end

return QuickGuide

