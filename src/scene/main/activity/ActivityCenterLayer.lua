local ActivityCenterLayer = class("ActivityCenterLayer", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")
local effects = require("tool.helper.Effects")
local scheduler = cc.Director:getInstance():getScheduler()
local DrawGoodsInfo = require("scene.main.activity.widget.DrawGoodsInfo")
local CheckGoodsInfo = require("scene.main.activity.widget.CheckGoodsInfo")
local LevelGoodsInfo = require("scene.main.activity.widget.LevelGoodsInfo")
local LoginGoodsInfo = require("scene.main.activity.widget.LoginGoodsInfo")

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

local CHECK_PANEL = 1
local LOGIN_PANEL = CHECK_PANEL + 1
local LEVEL_PANEL = LOGIN_PANEL + 1
local DRAW_PANEL = LEVEL_PANEL + 1
local SLOT_PANEL = DRAW_PANEL + 1
local RECOMMEND_HERO_PANEL = SLOT_PANEL + 1
local GROWTHFUND_PANEL = RECOMMEND_HERO_PANEL + 1
local DISCOUNT_PURCHASE_PANEL = GROWTHFUND_PANEL + 1
local LEVEL_LIMIT_PANEL = DISCOUNT_PURCHASE_PANEL + 1
local PURCHASE_COUNT_PANEL = LEVEL_LIMIT_PANEL + 1
local MONTH_CARD_PANEL = PURCHASE_COUNT_PANEL + 1
local POWER_PANEL = MONTH_CARD_PANEL + 1

-- 7天登录礼包数据
local loginZOrder1 = 1
local loginZOrder2 = loginZOrder1 + 1
local loginZOrder3 = loginZOrder2 + 1

local LOGIN_PURCHASE_PANEL = 1
local LOGIN_TODAYTASK_PANEL = LOGIN_PURCHASE_PANEL + 1
local LOGIN_DISCOUNT_PANEL = LOGIN_TODAYTASK_PANEL + 1

--[[ 以下条件类型需特殊处理]]
local SIMPLEMAP_TYPE = 2
local DIFFICULTYMAP_TYPE = 3
local WEAREQUIP_TYPE = 21

-- 基金和等级界面数据
local LAYERCOLORTAG = 10
local ACTIVITYPANELTAG = LAYERCOLORTAG + 1

local BUY_FUND_VIP = 2
local BUY_FUND_PRICE = 1000

local UNFINISHSTATUS = 0
local RECEIVESTATUS = UNFINISHSTATUS + 1
local FINISHSTATUS = RECEIVESTATUS + 1

-- 拉吧界面数据
local CARDSPACE = 102
local CELLTOTAL = 6

-- 折扣界面数据
local DISCOUNT_TOTAL = 2

-- 月卡界面数据
local NORMAL_CARD_ID = 7
local SUPER_CARD_ID = 8

-- 品尝人参果界面数据
local EAT_PRICE = 100
local POWER_UNAVAILABLE = 0 -- 不可领取
local POWER_AVAILABLE = 1 -- 可领取
local POWER_PAYABLE =2 -- 可购买

function ActivityCenterLayer:ctor(activityDailyCheckInfo, activityAccCheckInfo, activityInfo, jumpPanel)
    self.data.jumpPanelIdx = jumpPanel
    self.data.activityIsOpenTab = activityInfo.IsOpen or {}
    self.data.activityIsNoticeTab = activityInfo.IsNotice or {}

    self.checkControls = {}
    self.checkData = {}
    self.checkData.dailyInfo = activityDailyCheckInfo
    self.checkData.accInfo = activityAccCheckInfo

    self.data.allNodeTab = {}
    self.listeners = {}
    self:addListener()

    self.data.createUIFuncTab = {self.createDailyCheckUI, 
                                self.createLoginUI,
                                self.createLevelUI,
                                self.createDrawUI,
                                self.createSlotUI,
                                self.createRecommendHeroUI,
                                self.createGrowthFundUI,
                                self.createDiscountUI,
                                self.createLevelLimitUI,
                                self.createAccumulatePurchaseUI,
                                self.createMonthCardUI,
                                self.createPowerUI,
                                }
    self.data.updateUIFuncTab = {self.updateDailyCheckUI, 
                                self.updateLoginUI,
                                self.updateLevelUI,
                                self.updateDrawUI,
                                self.updateSlotUI,
                                self.updateRecommendHeroUI,
                                self.updateGrowthFundUI,
                                self.updateDiscountUI,
                                self.updateLevelLimitUI,
                                self.updateAccumulatePurchaseUI,
                                self.updateMonthCardUI,
                                self.updatePowerUI,
                                } 

    self:asyncAddImage()
    self.controls.scheduler_showTime = scheduler:scheduleScriptFunc(handler(self, self.showTime), 1, false)
end

function ActivityCenterLayer:onEnter()
    if self.data.isFirstJoin then
        if not self.data.allNodeTab[self.data.currPanel] then
            self.data.createUIFuncTab[self.data.currPanel](self)
        elseif self.data.updateUIFuncTab[self.data.currPanel] then
            self.data.updateUIFuncTab[self.data.currPanel](self)
            self:showPanel(self.data.allNodeTab[self.data.currPanel])
        end
        self.data.activityAlertTab[self.data.currPanel]:setVisible(false)
    end
    self.data.isFirstJoin = true
end

function ActivityCenterLayer:onCleanup()
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
    if self.controls.scheduler_showTime then
        scheduler:unscheduleScriptEntry(self.controls.scheduler_showTime)
    end
end

function ActivityCenterLayer:addListener()
    local listener = application:addEventListener(AppEvent.UI.Activity.LoginAward, function(event)
        local result = event.data
        local taskID = result.TaskID

        local tab = {Type = self.loginData.currPanel, Days = self.loginData.currDay, ID = taskID}
        rpc:call("Activity.ReceiveWeekLoginAward", tab, function(event)
            if event.status == Exceptions.Nil then
                local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                self:addChild(alertShow, btnZOrder)

                for k,questInfo in pairs(self.loginData.info[self.loginData.currDay].Quest) do
                    if questInfo.ID == taskID then
                        questInfo.Status = true
                    end
                end
                self:updateLoginUI()
            end
        end)
    end)
    table.insert(self.listeners, listener)

    local listener = application:addEventListener(AppEvent.UI.Activity.DrawAward, function(event)
        local result = event.data
        local value = result.Value
        local awardInfo = result.AwardsInfo

        table.sort(awardInfo, function(a, b)
            return a.Type > b.Type
        end)
        local alertShow = require("scene.main.ReceiveGoods").new(awardInfo, "image/ui/img/btn/btn_815.png")
        self:addChild(alertShow, btnZOrder)

        if self.data.currPanel == GROWTHFUND_PANEL then
            self.growthFundData.info.Status[tostring(value)] = true
        elseif self.data.currPanel == PURCHASE_COUNT_PANEL then
            self.accumulateData.info.Recived[tostring(value)] = true
        end
        self.data.updateUIFuncTab[self.data.currPanel](self)
    end)
    table.insert(self.listeners, listener)

    local listener = application:addEventListener(AppEvent.UI.Activity.BuyFund, function(event)
        if GameCache.Avatar.VIP < BUY_FUND_VIP then
            local layer = require("tool.helper.CommonLayer").ToBuyVIP("亲亲，提升VIP等级可购买")
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(layer)
            return 
        end

        require("tool.helper.CommonLayer").buyGoldAlert(BUY_FUND_PRICE, "购买基金", function()
            if Common.isCostMoney(1001, BUY_FUND_PRICE) then
                rpc:call("Activity.BuyGrowthFund", nil, function(event)
                    if event.status == Exceptions.Nil then
                        self.growthFundData.info = event.result
                        self:updateGrowthFundUI()
                    end
                end)
            end
        end)
    end)
    table.insert(self.listeners, listener)
end

function ActivityCenterLayer:asyncAddImage()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local imagePathTab = {"image/ui/img/bg/bg_205.png","image/ui/img/bg/bg_263.png", 
                        "image/ui/img/bg/bg_328.png", "image/ui/img/bg/bg_323.png", 
                        "image/ui/img/bg/bg_327.png", "image/ui/img/bg/bg_325.png", 
                        "image/ui/img/bg/bg_139.png", "image/ui/img/bg/bg_163.png", 
                        "image/ui/img/bg/bg_160.png", "image/ui/img/bg/bg_324.png", 
                        "image/ui/img/bg/bg_329.png", "image/ui/img/bg/bg_330.png", 
                        "image/ui/img/bg/bg_336.png", "image/ui/img/bg/bg_333.png", 
                        "image/ui/img/bg/bg_334.png", "image/ui/img/bg/bg_331.png", 
                        "image/ui/img/bg/bg_337.png", "image/ui/img/bg/bg_356.png",
                        }
    for k,path in pairs(imagePathTab) do
        cc.Director:getInstance():getTextureCache():addImageAsync(path, function()
            if k == #imagePathTab then
                self:createUI()
                self:filterRightPanel()
            end
        end)
    end
end

function ActivityCenterLayer:createUI()
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_205.png") 
    self.controls.bg:setContentSize(cc.size(902, 515))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.4)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()
    local bgSize = self.data.bgSize

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgSize.width * 0.98, bgSize.height * 0.96)
    self.controls.bg:addChild(btn_close, btnZOrder)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
end

function ActivityCenterLayer:filterRightPanel()
    if self.data.jumpPanelIdx then
        if self.data.activityIsOpenTab[self.data.jumpPanelIdx] then
            self.data.currPanel = self.data.jumpPanelIdx
        else
            self.data.currPanel = CHECK_PANEL
        end
    else
        local isHaveNotice = false
        for i=1,#self.data.activityIsNoticeTab do
            if self.data.activityIsOpenTab[i] and self.data.activityIsNoticeTab[i] then
                self.data.currPanel = i
                isHaveNotice = true
                break
            end
        end
        if not isHaveNotice then
            self.data.currPanel = CHECK_PANEL
        end
    end

    local node = cc.Node:create()
    self:addChild(node)
    node:runAction(cc.Sequence:create({cc.DelayTime:create(0.1), cc.CallFunc:create(function()
        self:createLeftIconPanel()
    end)}))
end

function ActivityCenterLayer:createLeftIconPanel()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_263.png")
    bg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height + 60)
    self.controls.bg:addChild(bg)

    self.controls.iconView = self:createIconView(cc.size(self.data.bgSize.width, 120))
    self.controls.iconView:setPosition(0, self.data.bgSize.height)
    self.controls.bg:addChild(self.controls.iconView, btnZOrder)
end

function ActivityCenterLayer:createDailyCheckUI()
    self.controls.CheckNode = cc.Node:create()
    self.controls.CheckNode.Name = CHECK_PANEL
    self.controls.bg:addChild(self.controls.CheckNode, bgZOrder)
    self.data.allNodeTab[CHECK_PANEL] = self.controls.CheckNode

    local bgSize = self.data.bgSize
    local bg = cc.Sprite:create("image/ui/img/bg/bg_328.png")
    bg:setPosition(bgSize.width * 0.478, bgSize.height * 0.512)
    self.controls.CheckNode:addChild(bg)

    local accSpri = cc.Sprite:create("image/ui/img/btn/btn_1296.png")
    accSpri:setPosition(bgSize.width * 0.38, bgSize.height * 0.18)
    self.controls.CheckNode:addChild(accSpri)

    self.checkControls.currMonth = Common.finalFont(self.checkData.dailyInfo.Month.."月签到次数:", 1, 1, 25, cc.c3b(214, 221, 232), 1)
    self.checkControls.currMonth:enableOutline(cc.c4b(27, 38, 64, 255), 1)
    self.checkControls.currMonth:setPosition(bgSize.width * 0.13, bgSize.height * 0.15)
    self.controls.CheckNode:addChild(self.checkControls.currMonth)

    self.checkControls.currMonthCheckCount = Common.finalFont(self.checkData.dailyInfo.CheckCount.."次", 1, 1, 25, cc.c3b(142, 239, 109), 1)
    self.checkControls.currMonthCheckCount:setPosition(bgSize.width * 0.13, bgSize.height * 0.08)
    self.controls.CheckNode:addChild(self.checkControls.currMonthCheckCount)

    self.checkControls.accCheckCount = Common.finalFont(self.checkData.accInfo.CheckCount.."/"..self.checkData.accInfo.AwardsCount, 1, 1, 25, cc.c3b(142, 239, 109), 1)
    self.checkControls.accCheckCount:setPosition(bgSize.width * 0.38, bgSize.height * 0.1)
    self.controls.CheckNode:addChild(self.checkControls.accCheckCount)

    local numOneRow = 5
    local rowHeight = 105
    local viewHeight = nil
    local function dailyCheckView(viewSize)
        local function cellSizeForTable(table,idx) 
            viewHeight = math.ceil(#self.checkData.dailyInfo.AwardsList / numOneRow) * rowHeight
            return viewHeight, 100
        end

        local function tableCellAtIndex(tableview, idx)
            local cell = tableview:dequeueCell()
            local function getLayer()
                local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), viewSize.width, viewHeight)
                layerColor:setAnchorPoint(0 , 0)
                layerColor:setPosition(5 , 5)

                for k,v in pairs(self.checkData.dailyInfo.AwardsList) do
                    local goodsItem = CheckGoodsInfo.new(v)
                    goodsItem:setDailyCheck(self.checkData.dailyInfo.CheckCount, self.checkData.dailyInfo.TodayStatus)
                    local size = cc.size(115, 105)
                    goodsItem:setPosition(size.width * 0.5 + ( (k - 1) % numOneRow) * size.width, 
                                layerColor:getContentSize().height - size.height * 0.55 - math.floor(((k - 1)/numOneRow)) * size.height)
                    layerColor:addChild(goodsItem)
                    goodsItem:addTouchEventListener(function(sender, eventType, isAddDay)
                        if eventType == ccui.TouchEventType.ended then
                            self:DailyCheck(sender, isAddDay)
                        end
                    end)
                end
                return layerColor
            end

            if nil == cell then
                cell = cc.TableViewCell:new()
                cell:addChild(getLayer())
            end

            return cell
        end

        local function numberOfCellsInTableView(table)
            return 1
        end

        local tableView = cc.TableView:create(viewSize)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()
        return tableView
    end
    self.checkControls.dailyCheckView = dailyCheckView(cc.size(bgSize.width * 0.85, bgSize.height * 0.61))
    self.checkControls.dailyCheckView:setPosition(bgSize.width * 0.3, bgSize.height * 0.3)
    self.controls.CheckNode:addChild(self.checkControls.dailyCheckView)

    local initHeight = -viewHeight + self.checkControls.dailyCheckView:getViewSize().height
    local scrollHeight = initHeight + (math.floor(self.checkData.dailyInfo.CheckCount / numOneRow) * rowHeight)
    scrollHeight = (scrollHeight > 0) and 0 or scrollHeight
    self.checkControls.dailyCheckView:setContentOffset(cc.p(0, scrollHeight), true)

    local clickLayer = Common.createClickLayer(bgSize.width * 0.85, bgSize.height * 0.6, 
                                                bgSize.width * 0.3, bgSize.height * 0.3)
    self.controls.CheckNode:addChild(clickLayer)

    local function accCheckView(viewSize)
        local function cellSizeForTable(table,idx) 
            return viewSize.height, (#self.checkData.accInfo.AwardsList) * 130
        end

        local function tableCellAtIndex(tableview, idx)
            local cell = tableview:dequeueCell()
            if cell then
               cell:removeFromParent()
               cell = nil
            end

            local function getLayer()
                local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), (#self.checkData.accInfo.AwardsList) * 130, viewSize.height)

                for k,v in pairs(self.checkData.accInfo.AwardsList) do
                    local goodsItem = CheckGoodsInfo.new(v)
                    goodsItem:setAccCheck(self.checkData.accInfo.CheckCount, self.checkData.accInfo.AwardsCount)
                    local size = goodsItem:getContentSize()
                    goodsItem:setPosition(layerColor:getContentSize().width - size.width * 0.8 - (k - 1) * 125, viewSize.height * 0.5)
                    layerColor:addChild(goodsItem)
                    goodsItem:addTouchEventListener(function(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            self:AccCheck()
                        end
                    end)
                end

                return layerColor
            end

            cell = cc.TableViewCell:new()
            cell:addChild(getLayer())
            return cell
        end
        local function numberOfCellsInTableView(table)
            return 1
        end
        local tableView = cc.TableView:create(viewSize)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()
        return tableView
    end
    self.checkControls.accCheckView = accCheckView(cc.size(bgSize.width * 0.56, bgSize.height * 0.22))
    self.checkControls.accCheckView:setPosition(bgSize.width * 0.48, 20)
    self.controls.CheckNode:addChild(self.checkControls.accCheckView)
end

function ActivityCenterLayer:updateDailyCheckUI()
    -- if UNFINISHSTATUS == self.checkData.dailyInfo.TodayStatus then
    --     self.data.activityAlertTab[CHECK_PANEL]:setVisible(true)
    -- elseif RECEIVESTATUS == self.checkData.dailyInfo.TodayStatus then
    --     local doubleVIPLevel = self.checkData.dailyInfo.AwardsList[self.checkData.dailyInfo.CheckCount].DoubleVIPLevel
    --     if GameCache.Avatar.VIP >= doubleVIPLevel then
    --         self.data.activityAlertTab[CHECK_PANEL]:setVisible(true)
    --     else
    --         self.data.activityAlertTab[CHECK_PANEL]:setVisible(false)
    --     end
    -- else
    --     self.data.activityAlertTab[CHECK_PANEL]:setVisible(false)
    -- end
end

function ActivityCenterLayer:createLevelUI()
    self.controls.LevelNode = cc.Node:create()
    self.controls.LevelNode.Name = LEVEL_PANEL
    self.controls.bg:addChild(self.controls.LevelNode, bgZOrder)
    self.data.allNodeTab[LEVEL_PANEL] = self.controls.LevelNode

    local bgSize = self.data.bgSize
    local bg = cc.Sprite:create("image/ui/img/bg/bg_323.png")
    bg:setPosition(bgSize.width * 0.478, bgSize.height * 0.512)
    self.controls.LevelNode:addChild(bg)

    rpc:call("Game.GetMultiSysInfo", {"AvatarLevel"}, function(event)
        if event.status == Exceptions.Nil then
            self.data.activityLevelTabs = event.result.AvatarLevel

            table.sort(self.data.activityLevelTabs, function(a, b)
                return a.Level < b.Level
            end)
            for k,info in pairs(self.data.activityLevelTabs) do
                local goodsItem = LevelGoodsInfo.new(info)
                self.controls.LevelNode:addChild(goodsItem)
                goodsItem:setPosition(bgSize.width * 0.45 + (k - 1)%4 * 132, 
                                    bgSize.height * 0.58 - math.floor((k - 1)/4) * 180)
                goodsItem:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        rpc:call("Activity.ReceiveAvatarLevelAward", info.Level, function(event)
                            if (event.status == Exceptions.Nil) and (event.result) then
                                local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                                self:addChild(alertShow, btnZOrder)
                                sender:getStatus()

                                self:updateLevelUI()
                            end
                        end)
                    end
                end)
            end
        end
    end)
end

function ActivityCenterLayer:updateLevelUI( ... )
    local finishTotal = 0
    local isHaveReceive = false
    for k,v in pairs(self.data.activityLevelTabs) do
        if FINISHSTATUS == v.Status then
            finishTotal = finishTotal + 1
        elseif RECEIVESTATUS == v.Status then
            isHaveReceive = true
        end
    end
    -- if isHaveReceive then
    --     self.data.activityAlertTab[LEVEL_PANEL]:setVisible(true)
    -- else
    --     self.data.activityAlertTab[LEVEL_PANEL]:setVisible(false)
    -- end

    -- 当该活动做完时及时从面板上清除点
    if finishTotal == (#self.data.activityLevelTabs) then
        self:finishActivity(LEVEL_PANEL)
    end
end

function ActivityCenterLayer:createLoginUI()
    self.controls.LoginNode = cc.Node:create()
    self.controls.LoginNode.Name = LOGIN_PANEL
    self.controls.bg:addChild(self.controls.LoginNode, bgZOrder)    
    self.data.allNodeTab[LOGIN_PANEL] = self.controls.LoginNode

    self.loginData = {}
    self.loginControls = {}
    self.loginData.info = {}

    self.loginData.currPanel = LOGIN_PURCHASE_PANEL

    local bgSize = self.data.bgSize
    local bg = cc.Sprite:create("image/ui/img/bg/bg_327.png")
    bg:setPosition(bgSize.width * 0.49, bgSize.height * 0.53)
    self.controls.LoginNode:addChild(bg)

    self.loginData.panelTab = {}
    self.loginControls.purchasePanel = cc.Node:create()
    self.loginControls.purchasePanel:setLocalZOrder(loginZOrder2)
    self.controls.LoginNode:addChild(self.loginControls.purchasePanel)
    self.loginData.panelTab[LOGIN_PURCHASE_PANEL] = self.loginControls.purchasePanel

    self.loginControls.todayTaskPanel = cc.Node:create()
    self.loginControls.todayTaskPanel:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
    self.loginControls.todayTaskPanel:setLocalZOrder(loginZOrder1)
    self.controls.LoginNode:addChild(self.loginControls.todayTaskPanel)
    self.loginData.panelTab[LOGIN_TODAYTASK_PANEL] = self.loginControls.todayTaskPanel

    self.loginControls.discountPanel = cc.Node:create()
    self.loginControls.discountPanel:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
    self.loginControls.discountPanel:setLocalZOrder(loginZOrder1)
    self.controls.LoginNode:addChild(self.loginControls.discountPanel)
    self.loginData.panelTab[LOGIN_DISCOUNT_PANEL] = self.loginControls.discountPanel

    self.loginData.activeBtnTab = {}
    local nameTab = {"充值有礼", "今日目标", "半价抢购"}
    local childNameTab = {"purchase", "task", "discount"}

    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.loginData.activeBtnTab) do
                if name == v:getName() then
                    v:setTouchStatus()
                    v:setFontColor(cc.c3b(253, 230, 154))
                    v:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
                else
                    v:setNormalStatus()
                    v:setFontColor(cc.c3b(177, 174, 170))
                    v:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
                end
            end

            if name == childNameTab[1] then
                self.loginData.currPanel = LOGIN_PURCHASE_PANEL
            elseif name == childNameTab[2] then
                self.loginData.currPanel = LOGIN_TODAYTASK_PANEL
            elseif name == childNameTab[3] then
                self.loginData.currPanel = LOGIN_DISCOUNT_PANEL
            end

            for k,panel in pairs(self.loginData.panelTab) do
                if k == self.loginData.currPanel then
                    panel:setPosition(0, 0)
                    panel:setLocalZOrder(loginZOrder2)
                else
                    panel:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                    panel:setLocalZOrder(loginZOrder1)
                end
            end
            self:updateLoginUI()
        end
    end
    for i=1,3 do
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png", "image/ui/img/btn/btn_398.png", cc.size(142, 68))
        btn:setButtonBounce(false)
        btn:setAnchorPoint(0.5, 0)
        btn:setBgTouchAnchorPoint(0.5, 0)
        btn:setChildPos(0.95, 1.3)
        btn:setCircleFont(nameTab[i] , 1, 1, 25, cc.c3b(177, 174, 170))
        btn:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
        btn:setFontPos(0.5, 0.9)
        btn:getFont():setAdditionalKerning(-2)
        btn:setPosition(bgSize.width * 0.5 + (i - 1) * 155, bgSize.height * 0.842)
        btn:addTouchEventListener(btnTouchEvent)
        self.controls.LoginNode:addChild(btn, loginZOrder3)
        table.insert(self.loginData.activeBtnTab, btn)
        btn:setName(childNameTab[i])
        btn:setChildTextureVisible(false)

        if i == 1 then
            btn:setTouchStatus()
            btn:setFontColor(cc.c3b(253, 230, 154))
            btn:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
        end
    end

    local btnBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_352.png")
    btnBg:setContentSize(cc.size(203, 265))
    btnBg:setPosition(bgSize.width * 0.13, bgSize.height * 0.325)
    self.controls.LoginNode:addChild(btnBg, loginZOrder3)

    rpc:call("Activity.GetWeekLoginInfo", 0, function(event)
        if event.status == Exceptions.Nil then
            local info = event.result
            self.loginData.currDay = info.Days
            self.loginData.maxDay = self.loginData.currDay
            self.loginData.info[self.loginData.currDay] = info

            local dayBtnTab = {}
            function btnTouchEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local name = sender:getTag()
                    for k,v in pairs(dayBtnTab) do
                        if name == v:getTag() then
                            v:setTouchStatus()
                            v:setFontColor(cc.c3b(255, 255, 0))
                        else
                            v:setNormalStatus()
                            v:setFontColor(cc.c3b(255,255,255))
                        end
                    end
                    
                    self.loginData.currDay = name
                    if self.loginData.info[self.loginData.currDay] then
                        self:updateLoginUI()
                    else
                        rpc:call("Activity.GetWeekLoginInfo", self.loginData.currDay, function(event)
                            if event.status == Exceptions.Nil then
                                self.loginData.info[self.loginData.currDay] = event.result
                                self:updateLoginUI()
                            end
                        end)
                    end
                end
            end
            for i=1,7 do
                local btn = nil
                if i ~= 7 then
                    btn = createMixScale9Sprite("image/ui/img/btn/btn_1425.png", "image/ui/img/btn/btn_1426.png", nil, cc.size(95, 62))
                    btn:setPosition(52 + (i - 1)%2 * 98, 228 - math.floor((i - 1)/2) * 64)
                else
                    btn = createMixScale9Sprite("image/ui/img/btn/btn_1425.png", "image/ui/img/btn/btn_1426.png", nil, cc.size(192, 62))
                    btn:setPosition(102, 34)
                end
                btn:setButtonBounce(false)
                btnBg:addChild(btn)
                if i > self.loginData.maxDay then
                    btn:setCircleFont("第"..i.."天", 1, 1, 25, cc.c3b(177, 174, 170))
                    btn:setTouchEnable(false)
                else
                    if i == self.loginData.currDay then
                        btn:setCircleFont("第"..i.."天", 1, 1, 25, cc.c3b(255, 255, 0))
                        btn:setTouchStatus()
                    else
                        btn:setCircleFont("第"..i.."天", 1, 1, 25, cc.c3b(255, 255, 255))
                    end
                    table.insert(dayBtnTab, btn)
                    btn:setTag(i)
                    btn:addTouchEventListener(btnTouchEvent)
                end
            end

            self:loginPurchasePanel()
            self:loginTodayTaskPanel() 
            self:loginDiscountPanel()
            self:updateLoginUI()

            local isNotice = self:isNoticeTaskAward()
            self.loginData.activeBtnTab[2]:setChildTextureVisible(isNotice)
        end
    end)
end

function ActivityCenterLayer:loginPurchasePanel()
    local bgSize = self.data.bgSize
    local title = cc.Sprite:create("image/ui/img/bg/bg_349.png")
    self.loginControls.purchasePanel:addChild(title)
    title:setPosition(bgSize.width * 0.6, bgSize.height * 0.7)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_350.png")
    bg:setContentSize(cc.size(624, 264))
    self.loginControls.purchasePanel:addChild(bg)
    bg:setPosition(bgSize.width * 0.605, bgSize.height * 0.34)
    local bottom = cc.Sprite:create("image/ui/img/bg/bg_351.png")
    self.loginControls.purchasePanel:addChild(bottom)
    bottom:setPosition(bgSize.width * 0.605, bgSize.height * 0.33)

    local lab = Common.finalFont("今日累计充值", bgSize.width * 0.35, bgSize.height * 0.54, 20, cc.c3b(255, 255, 255))
    self.loginControls.purchasePanel:addChild(lab)
    lab = Common.finalFont("元宝,即可领取!", bgSize.width * 0.58, bgSize.height * 0.54, 20, cc.c3b(255, 255, 255))
    self.loginControls.purchasePanel:addChild(lab)
    lab = Common.finalFont("进度:", bgSize.width * 0.76, bgSize.height * 0.54, 20, cc.c3b(255, 255, 255))
    self.loginControls.purchasePanel:addChild(lab)
    lab = Common.finalFont("礼包每日都不同,千万不要错过咯!", bgSize.width * 0.6, bgSize.height * 0.28, 20, cc.c3b(151, 255, 74))
    self.loginControls.purchasePanel:addChild(lab)

    self.loginControls.todayAccumulate = Common.finalFont("", bgSize.width * 0.46, bgSize.height * 0.54, 20, cc.c3b(255, 255, 0))
    self.loginControls.purchasePanel:addChild(self.loginControls.todayAccumulate)

    self.loginControls.purchaseProgress = ColorLabel.new("", 20, nil, true)
    self.loginControls.purchaseProgress:setAnchorPoint(0, 0.5)
    self.loginControls.purchaseProgress:setPosition(bgSize.width * 0.79, bgSize.height * 0.54)
    self.loginControls.purchasePanel:addChild(self.loginControls.purchaseProgress)

    local function createGoodsView(tableSize)
        local goodsTabs = nil
        local function cellSizeForTable(table,idx) 
            goodsTabs = BaseConfig.getLoginPurchaseConfig(self.loginData.currDay).GoodsList
            return tableSize.height,(#goodsTabs) * 95
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()

            local function getLayer()
                local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), (#goodsTabs) * 95, tableSize.height)
                for k,v in pairs(goodsTabs) do
                    local goodsInfo = {}
                    goodsInfo.ID = v.GoodsID
                    goodsInfo.Type = v.GoodsType
                    goodsInfo.Num = v.Num

                    local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_MIDDLETYPE)
                    goodsItem:setPosition((k - 1) * 95 + 45, tableSize.height * 0.5)
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

    local viewSize = cc.size(580, 90)
    self.loginControls.purchaseAwardView = createGoodsView(viewSize)
    self.loginControls.purchaseAwardView:setPosition(bgSize.width * 0.28, bgSize.height * 0.32)
    self.loginControls.purchasePanel:addChild(self.loginControls.purchaseAwardView)

    local layer = Common.createClickLayer(viewSize.width, viewSize.height, bgSize.width * 0.28, bgSize.height * 0.32)
    self.loginControls.purchasePanel:addChild(layer)

    self.loginControls.btn_purchase = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(130, 70))
    self.loginControls.btn_purchase:setButtonBounce(false)
    self.loginControls.btn_purchase:setCircleFont("前往", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.loginControls.btn_purchase:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.loginControls.btn_purchase:setPosition(bgSize.width * 0.6, bgSize.height * 0.16)
    self.loginControls.purchasePanel:addChild(self.loginControls.btn_purchase)

end

function ActivityCenterLayer:loginTodayTaskPanel()
    local bgSize = self.data.bgSize
    local function createGoodsView(tableSize)
        local panelName = "panel"
        local function cellSizeForTable(table,idx) 
            return 132,tableSize.width
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()

            local function getLayer()
                local loginPanel = require("scene.main.activity.widget.LoginPanel").new()
                loginPanel:setName(panelName)
                
                return loginPanel
            end

            local panel = nil
            if cell then
                panel = cell:getChildByName(panelName)
            else
                cell = cc.TableViewCell:new()
                panel = getLayer()
                cell:addChild(panel)
            end

            if (idx % 2) == 0 then
                panel:setBgVisible(true)
            else
                panel:setBgVisible(false)
            end

            if self.loginData.currDay < (self.loginData.maxDay - 1) then
                panel:setJump(false)
            else
                panel:setJump(true)
            end

            local info = self.loginData.info[self.loginData.currDay].Quest[idx + 1]
            panel:updatePanelInfo(info)

            return cell
        end

        local function numberOfCellsInTableView(table)
           return #(self.loginData.info[self.loginData.currDay].Quest)
        end

        local tableView = cc.TableView:create(tableSize)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()
        return tableView 
    end

    local view = cc.size(620, 390)
    self.loginControls.taskView = createGoodsView(view)
    self.loginControls.taskView:setPosition(bgSize.width * 0.26, bgSize.height * 0.08)
    self.loginControls.todayTaskPanel:addChild(self.loginControls.taskView)

    local clickLayer = Common.createClickLayer(view.width, view.height, bgSize.width * 0.26, bgSize.height * 0.08)
    self.loginControls.todayTaskPanel:addChild(clickLayer)

end

function ActivityCenterLayer:loginDiscountPanel()
    local bgSize = self.data.bgSize
    local discountTitle = cc.Sprite:create("image/ui/img/bg/bg_354.png")
    discountTitle:setPosition(bgSize.width * 0.4, bgSize.height * 0.675)
    self.loginControls.discountPanel:addChild(discountTitle)

    self.loginControls.discountGoodsName = Common.finalFont("今日", 1, 1, 20, cc.c3b(255, 255, 255), 1)
    self.loginControls.discountGoodsName:setAnchorPoint(0, 0.5)
    self.loginControls.discountGoodsName:setPosition(bgSize.width * 0.48, bgSize.height * 0.61)
    self.loginControls.discountPanel:addChild(self.loginControls.discountGoodsName)

    self.loginControls.discountGoodsNum = Common.finalFont("", 1, 1, 18, cc.c3b(255, 255, 255), 1)
    self.loginControls.discountGoodsNum:setAnchorPoint(0, 0.5)
    self.loginControls.discountGoodsNum:setPosition(bgSize.width * 0.48, bgSize.height * 0.5)
    self.loginControls.discountPanel:addChild(self.loginControls.discountGoodsNum)

    local descBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    descBg:setContentSize(cc.size(240, 180))
    descBg:setOpacity(150)
    descBg:setPosition(bgSize.width * 0.8, bgSize.height * 0.6)
    self.loginControls.discountPanel:addChild(descBg)

    self.loginControls.goodsDesc = Common.finalFont("", 1, 1, 18, cc.c3b(255, 255, 255), 1)
    self.loginControls.goodsDesc:setDimensions(200, 180)
    self.loginControls.goodsDesc:setAnchorPoint(0, 0.5)
    self.loginControls.goodsDesc:setPosition(20, 25)
    descBg:addChild(self.loginControls.goodsDesc)

    local bottomBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_347.png")
    bottomBg:setContentSize(cc.size(642, 180))
    bottomBg:setPosition(bgSize.width * 0.605, bgSize.height * 0.21)
    self.loginControls.discountPanel:addChild(bottomBg)

    local discountSpri = cc.Sprite:create("image/ui/img/btn/btn_1388.png")
    discountSpri:setPosition(bgSize.width * 0.45, bgSize.height * 0.3)
    self.loginControls.discountPanel:addChild(discountSpri)

    local lab_nowPrice = Common.finalFont("现价:", 1, 1, 25, cc.c3b(255, 255, 255), 1)
    lab_nowPrice:setAnchorPoint(0, 0.5)
    lab_nowPrice:setPosition(bgSize.width * 0.5, bgSize.height * 0.34)
    self.loginControls.discountPanel:addChild(lab_nowPrice)
    local lab_oldPrice = Common.finalFont("原价:", 1, 1, 20, cc.c3b(255, 255, 255), 1)
    lab_oldPrice:setAnchorPoint(0, 0.5)
    lab_oldPrice:setPosition(bgSize.width * 0.5, bgSize.height * 0.27)
    self.loginControls.discountPanel:addChild(lab_oldPrice)
    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setScale(1.2)
    goldSpri:setPosition(bgSize.width * 0.6, bgSize.height * 0.34)
    self.loginControls.discountPanel:addChild(goldSpri)
    goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(bgSize.width * 0.58, bgSize.height * 0.27)
    self.loginControls.discountPanel:addChild(goldSpri)

    self.loginControls.discharge_nowPrice = Common.finalFont("", 1, 1, 25, cc.c3b(255, 255, 0), 1)
    self.loginControls.discharge_nowPrice:setAnchorPoint(0, 0.5)
    self.loginControls.discharge_nowPrice:setPosition(bgSize.width * 0.625, bgSize.height * 0.34)
    self.loginControls.discountPanel:addChild(self.loginControls.discharge_nowPrice)

    self.loginControls.discharge_oldPrice = Common.finalFont("", 1, 1, 20, cc.c3b(255, 255, 0), 1)
    self.loginControls.discharge_oldPrice:setAnchorPoint(0, 0.5)
    self.loginControls.discharge_oldPrice:setPosition(bgSize.width * 0.605, bgSize.height * 0.27)
    self.loginControls.discountPanel:addChild(self.loginControls.discharge_oldPrice)

    self.controls.discharge_timeout = Common.finalFont(":", 1, 1, 20, cc.c3b(255, 255, 255), 1)
    self.controls.discharge_timeout:setAnchorPoint(0, 0.5)
    self.controls.discharge_timeout:setPosition(bgSize.width * 0.75, bgSize.height * 0.34)
    self.loginControls.discountPanel:addChild(self.controls.discharge_timeout)

    self.loginControls.drawNode = cc.DrawNode:create()
    self.loginControls.drawNode:drawLine( cc.p(bgSize.width * 0.5, bgSize.height * 0.27), cc.p(bgSize.width * 0.68, bgSize.height * 0.27), cc.c4f(1,0,0,1))
    self.loginControls.discountPanel:addChild(self.loginControls.drawNode)

    self.loginControls.btn_discharge = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(130, 70))
    self.loginControls.btn_discharge:setButtonBounce(false)
    self.loginControls.btn_discharge:setCircleFont("购买", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.loginControls.btn_discharge:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.loginControls.btn_discharge:setPosition(bgSize.width * 0.6, bgSize.height * 0.15)
    self.loginControls.discountPanel:addChild(self.loginControls.btn_discharge)
end

function ActivityCenterLayer:updateLoginUI()
    -- local finishTotal = 0
    -- local isHaveReceive = false
    -- for k,v in pairs(self.data.activityLoginTabs) do
    --     if FINISHSTATUS == v.Status then
    --         finishTotal = finishTotal + 1
    --     elseif RECEIVESTATUS == v.Status then
    --         isHaveReceive = true
    --     end
    -- end
    -- -- if isHaveReceive then
    -- --     self.data.activityAlertTab[LOGIN_PANEL]:setVisible(true)
    -- -- else
    -- --     self.data.activityAlertTab[LOGIN_PANEL]:setVisible(false)
    -- -- end

    -- -- 当该活动做完时及时从面板上清除点
    -- if finishTotal == (#self.data.activityLoginTabs) then
    --     self:finishActivity(LOGIN_PANEL)
    -- end
    local bgSize = self.data.bgSize
    local function updatePurchasePanel()
        local currDayConfig = BaseConfig.getLoginPurchaseConfig(self.loginData.currDay)
        local purchaseGold = currDayConfig.Gold
        self.loginControls.todayAccumulate:setString(purchaseGold)

        local purchasInfo = self.loginData.info[self.loginData.currDay].Recharge -- 充值信息
        local accumulateGold = purchasInfo.RechargeAmount 
        if accumulateGold >= purchaseGold then
            self.loginControls.purchaseProgress:setString("[239,239,168]"..accumulateGold.."[=][255,255,255]/"..purchaseGold.."[=]")
            self.loginControls.btn_purchase:setString("领取")
            self.loginControls.btn_purchase:addTouchEventListener(function(sender, eventType, isInside)
                if eventType == ccui.TouchEventType.ended and isInside then
                    -- 领取
                    local tab = {Type = self.loginData.currPanel, Days = self.loginData.currDay, ID = 0}
                    rpc:call("Activity.ReceiveWeekLoginAward", tab, function(event)
                        if event.status == Exceptions.Nil then
                            local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                            self:addChild(alertShow, btnZOrder)

                            purchasInfo.Status = true
                            self.loginControls.btn_purchase:setString("已领取")
                            self.loginControls.btn_purchase:setTouchEnable(false)
                        end
                    end)
                end
            end)
        else
            self.loginControls.purchaseProgress:setString("[249,24,24]"..accumulateGold.."[=][255,255,255]/"..purchaseGold.."[=]")
            self.loginControls.btn_purchase:setString("前往")
            self.loginControls.btn_purchase:addTouchEventListener(function(sender, eventType, isInside)
                if eventType == ccui.TouchEventType.ended and isInside then
                    application:pushScene("main.recharge.RechargeScene")
                end
            end)
        end

        if self.loginData.currDay < self.loginData.maxDay then
            self.loginControls.btn_purchase:setString("已错过")
            self.loginControls.btn_purchase:setTouchEnable(false)
        elseif purchasInfo.Status then
            self.loginControls.btn_purchase:setString("已领取")
            self.loginControls.btn_purchase:setTouchEnable(false)
        else
            self.loginControls.btn_purchase:setTouchEnable(true)
        end

        self.loginControls.purchaseAwardView:reloadData()
        if #(BaseConfig.getLoginPurchaseConfig(self.loginData.currDay).GoodsList) > 6 then
            self.loginControls.purchaseAwardView:setTouchEnabled(true)
        else
            self.loginControls.purchaseAwardView:setTouchEnabled(false)
        end
    end

    local function updateTaskPanel()
        local questInfoTab = self.loginData.info[self.loginData.currDay].Quest
        local canReceiveTab = {} -- 可领取
        local unReceiveTab = {} -- 未领取
        local receivedTab = {} -- 已领取

        for k,questInfo in pairs(questInfoTab) do
            if questInfo.Status then
                table.insert(receivedTab, questInfo)
            elseif self:isCanReceiveAward(questInfo) then
                table.insert(canReceiveTab, questInfo)
            else
                table.insert(unReceiveTab, questInfo)
            end
        end
        self.loginData.info[self.loginData.currDay].Quest = {}
        for k,info in pairs(canReceiveTab) do
            table.insert(self.loginData.info[self.loginData.currDay].Quest, info)
        end
        for k,info in pairs(unReceiveTab) do
            table.insert(self.loginData.info[self.loginData.currDay].Quest, info)
        end
        for k,info in pairs(receivedTab) do
            table.insert(self.loginData.info[self.loginData.currDay].Quest, info)
        end

        self.loginControls.taskView:reloadData()

        local isNotice = self:isNoticeTaskAward()
        self.loginData.activeBtnTab[2]:setChildTextureVisible(isNotice)
    end

    local function updateDiscountPanel()
        local currDayConfig = BaseConfig.getLoginSaleConfig(self.loginData.currDay)

        if self.loginControls.discountGoodsItem then
            self.loginControls.discountGoodsItem:removeFromParent()
            self.loginControls.discountGoodsItem = nil
        end
        local goodsInfo = {}
        for k,info in pairs(currDayConfig.GoodsList) do
            goodsInfo.ID = info.GoodsID
            goodsInfo.Type = info.GoodsType
            goodsInfo.Num = info.Num
        end
        self.loginControls.discountGoodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_MIDDLETYPE)
        self.loginControls.discountGoodsItem:setPosition(bgSize.width * 0.42, bgSize.height * 0.55)
        self.loginControls.discountPanel:addChild(self.loginControls.discountGoodsItem)
        if self.loginControls.discountGoodsItem.setTips then
            self.loginControls.discountGoodsItem:setTips(false)
        end

        local configInfo = self.loginControls.discountGoodsItem:getGoodsConfigInfo()
        local name,color = self:getGoodsNameAndColor(goodsInfo)
        self.loginControls.discountGoodsName:setString(name)
        self.loginControls.discountGoodsName:setColor(color)
        self.loginControls.discountGoodsNum:setString("拥有:"..self:showGoodsOwnNum(goodsInfo))
        local desc = configInfo.desc or configInfo.Desc
        self.loginControls.goodsDesc:setString(desc)

        self.loginControls.discharge_nowPrice:setString(currDayConfig.Gold)
        self.loginControls.discharge_oldPrice:setString(currDayConfig.Gold * 2)

        local buyPrice = nil
        if self.loginData.currDay < self.loginData.maxDay then
            self.loginControls.drawNode:setPosition(0, 36)
            buyPrice = currDayConfig.Gold * 2
        else
            self.loginControls.drawNode:setPosition(0, 0)
            buyPrice = currDayConfig.Gold
        end

        if self.loginData.info[self.loginData.currDay].Sale.Status then
            self.loginControls.btn_discharge:setString("已购买")
            self.loginControls.btn_discharge:setTouchEnable(false)
        else
            self.loginControls.btn_discharge:setString("购买")
            self.loginControls.btn_discharge:setTouchEnable(true)
        end
        self.loginControls.btn_discharge:addTouchEventListener(function(sender, eventType, isInside)
            if eventType == ccui.TouchEventType.ended and isInside then
                if not Common.isCostMoney(1001, buyPrice) then
                    return
                end

                local tab = {Type = self.loginData.currPanel, Days = self.loginData.currDay, ID = 0}
                rpc:call("Activity.ReceiveWeekLoginAward", tab, function(event)
                    if event.status == Exceptions.Nil then
                        local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                        self:addChild(alertShow, btnZOrder)

                        self.loginData.info[self.loginData.currDay].Sale.Status = true
                        self.loginControls.btn_discharge:setString("已购买")
                        self.loginControls.btn_discharge:setTouchEnable(false)
                    end
                end)
            end
        end)
    end

    if self.loginData.currPanel == LOGIN_PURCHASE_PANEL then
        updatePurchasePanel()
    elseif self.loginData.currPanel == LOGIN_TODAYTASK_PANEL then
        updateTaskPanel()
    elseif self.loginData.currPanel == LOGIN_DISCOUNT_PANEL then
        updateDiscountPanel()
    end
end

function ActivityCenterLayer:getGoodsNameAndColor(info)
    local goodsType = info.Type
    local name = ""
    local nameColor = cc.c3b(0,162,255)
    if goodsType == BaseConfig.GT_HERO or goodsType == BaseConfig.GT_SOUL then
        local starLevel = BaseConfig.GetSoul(info.ID).starLevel
        local configInfo = BaseConfig.GetHero(info.ID, starLevel)
        name = configInfo.name
        nameColor = Common.getHeroStarLevelColor(starLevel).Color
        if goodsType == BaseConfig.GT_SOUL then
            name = name.."(魂魄)"
        end
    elseif goodsType == BaseConfig.GT_EQUIP then
        local compoundId = BaseConfig.GetProps(info.ID).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local starLevel =  fragToEquipConfig.starLevel
        local configInfo = BaseConfig.GetEquip(info.ID, starLevel)
        name = configInfo.name
        nameColor = Common.getHeroStarLevelColor(starLevel).Color
    elseif goodsType == BaseConfig.GT_PROPS then
        local nameColorTab = {cc.c3b(217,217,217), cc.c3b(0,255,50), cc.c3b(0,162,255), 
                    cc.c3b(255,0,200), cc.c3b(255,0,0), cc.c3b(255,102,0)} -- 灰、绿、蓝、紫、红、橙
        local configInfo = BaseConfig.GetProps(info.ID)
        local colorIdx = configInfo.quality
        name = configInfo.name
        nameColor = nameColorTab[colorIdx]
    elseif goodsType == BaseConfig.GT_MONEY then
        local configInfo = BaseConfig.getCurrencyConfig(info.ID)
        name = configInfo.Name
    end
    return name, nameColor
end

function ActivityCenterLayer:showGoodsOwnNum(info)
    local goodsType = info.Type
    local ownNum = 0
    if goodsType == BaseConfig.GT_SOUL then
        local goodsInfo = GameCache.GetSoul(info.ID)
        if goodsInfo then
            ownNum = goodsInfo.Num
        end
    elseif goodsType == BaseConfig.GT_EQUIP then
        local compoundId = BaseConfig.GetProps(info.ID).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local starLevel =  fragToEquipConfig.starLevel

        local goodsInfo = GameCache.GetEquip(info.ID, starLevel)
        if goodsInfo then
            ownNum = goodsInfo.Num
        end
    elseif goodsType == BaseConfig.GT_PROPS then
        local propsConfigInfo = BaseConfig.GetProps(info.ID)
        if (propsConfigInfo.type == 1) or (propsConfigInfo.type == 4) then
            local goodsInfo = GameCache.GetFrag(info.ID)
            if goodsInfo then
                ownNum = goodsInfo.Num
            end
        elseif (propsConfigInfo.type ~= 2) then
            local goodsInfo = GameCache.GetProps(info.ID)
            if goodsInfo then
                ownNum = goodsInfo.Num
            end
        end
    elseif goodsType == BaseConfig.GT_MONEY then
        if info.ID == 1001 then
            ownNum = GameCache.Avatar.Gold
        elseif info.ID == 1002 then
            ownNum = GameCache.Avatar.Coin
        end
    end
    return Common.numConvert(ownNum)
end

function ActivityCenterLayer:isNoticeTaskAward()
    local taskInfoTabs = self.loginData.info[self.loginData.currDay].Quest
    for k,taskInfo in pairs(taskInfoTabs) do
        if self:isCanReceiveAward(taskInfo) then
            return true
        end
    end
    
    return false
end

function ActivityCenterLayer:isCanReceiveAward(taskInfo)
    if taskInfo.Status then
        return false
    end

    local taskConfig = BaseConfig.getLoginTaskConfig(taskInfo.ID)
    local currValue = taskInfo.Step
    local totalValue = taskConfig.Value[#taskConfig.Value]

    local conditionType = taskConfig.Type
    if (conditionType == SIMPLEMAP_TYPE) or (conditionType == DIFFICULTYMAP_TYPE) then
        totalValue = 1
    elseif conditionType == WEAREQUIP_TYPE then
        totalValue = 1
    end

    if currValue < totalValue then
        return false
    else
        return true
    end
end

function ActivityCenterLayer:createDrawUI()
    self.data.maxQuan = 2
    self.data.isCanDraw = true

    self.controls.drawNode = cc.Node:create()
    self.controls.drawNode.Name = DRAW_PANEL
    self.controls.bg:addChild(self.controls.drawNode, bgZOrder)
    self.data.allNodeTab[DRAW_PANEL] = self.controls.drawNode

    local bgSize = self.data.bgSize
    local bg = cc.Sprite:create("image/ui/img/bg/bg_325.png")
    bg:setPosition(bgSize.width * 0.48, bgSize.height * 0.498)
    self.controls.drawNode:addChild(bg)

    rpc:call("Game.GetMultiSysInfo", {"Online"}, function(event)
        if event.status == Exceptions.Nil then
            self.data.activityDrawTabs = event.result.Online 

            self.data.nextFreeTime = self.data.activityDrawTabs.CollectStatus[1].NextFreeTime
            self.data.maxDailyFreeUseCount = self.data.activityDrawTabs.MainStatus[1].MaxDailyFreeUseCount
            self.data.dailyFreeUseCount = self.data.activityDrawTabs.CollectStatus[1].DailyFreeUseCount
            self.data.currCollectSet = self.data.activityDrawTabs.MainStatus[1].SetType + 1

            local cardBg = cc.Sprite:create("image/ui/img/btn/btn_870.png")
            cardBg:setPosition(bgSize.width * 0.605, bgSize.height * 0.61)
            self.controls.drawNode:addChild(cardBg)

            local desc = Common.finalFont(self.data.activityDrawTabs.MainStatus[1].Desc, 1, 1, 20, cc.c3b(255,246,0), 1)
            desc:setAnchorPoint(0, 0.5)
            desc:setPosition(bgSize.width * 0.55, bgSize.height * 0.905)
            self.controls.drawNode:addChild(desc)

            local btn_help = createMixSprite("image/ui/img/btn/btn_868.png")
            btn_help:setPosition(bgSize.width * 0.88, bgSize.height * 0.905)
            self.controls.drawNode:addChild(btn_help)
            btn_help:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local node = self:helpUI()
                    self:addChild(node, btnZOrder)
                end
            end)
            
            self.controls.timeCount = Common.finalFont("", 1, 1, 20, nil, 1)
            self.controls.timeCount:setAdditionalKerning(-2)
            self.controls.timeCount:setPosition(bgSize.width * 0.89, bgSize.height * 0.66)
            self.controls.drawNode:addChild(self.controls.timeCount)

            self.controls.btn_draw = createMixScale9Sprite("image/ui/img/btn/btn_831.png", nil, "image/ui/img/btn/btn_871.png", cc.size(134, 84))
            self.controls.btn_draw:setChildPos(0.5, 0.55)
            self.controls.btn_draw:setPosition(bgSize.width * 0.89, bgSize.height * 0.52)
            self.controls.drawNode:addChild(self.controls.btn_draw)
            self.controls.btn_draw:addTouchEventListener(function(sender, eventType)
                if (eventType == ccui.TouchEventType.ended) and (self.data.isCanDraw) then
                    local isCan = false
                    if self.data.isFree then
                        isCan = true
                    elseif Common.isCostMoney(1001, self.data.nextPrice) then
                        isCan = true
                    end
                    if isCan then
                        Common.addTopSwallowLayer()
                        self.data.isCanDraw = false
                        self.data.quanCount = 1
                        self.data.playTime = 0.03
                        self:Collect()
                    end
                end
            end)
            local lightNum = 0
            for k,v in pairs(self.data.activityDrawTabs.CollectStatus[1].CardMatrix) do
                if v.IsLight then
                    lightNum = lightNum + 1
                end
            end
            if lightNum >= 12 then
                self.controls.btn_draw:setNorGLProgram(false)
                self.controls.btn_draw:setTouchEnable(false)
            end

            local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_869.png")
            priceSpri:setPosition(bgSize.width * 0.89, bgSize.height * 0.4)
            self.controls.drawNode:addChild(priceSpri)

            self.controls.free = Common.finalFont("免费", 1, 1, 20, cc.c3b(255, 246, 0), 1)
            self.controls.free:setPosition(bgSize.width * 0.89, bgSize.height * 0.4)
            self.controls.drawNode:addChild(self.controls.free)
            self.controls.free:setVisible(false)

            self.controls.costGoldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
            self.controls.costGoldSpri:setPosition(bgSize.width * 0.87, bgSize.height * 0.4)
            self.controls.drawNode:addChild(self.controls.costGoldSpri)
            self.controls.costGoldSpri:setVisible(false)
            
            self.data.nextPrice = self.data.activityDrawTabs.CollectStatus[1].NextPrice
            self.controls.costGold = Common.finalFont(self.data.nextPrice, 1, 1, 20, cc.c3b(255, 246, 0), 1)
            self.controls.costGold:setAnchorPoint(0, 0.5)
            self.controls.costGold:setPosition(bgSize.width * 0.89, bgSize.height * 0.4)
            self.controls.drawNode:addChild(self.controls.costGold)
            self.controls.costGold:setVisible(false)

            self.data.cardAnimTab = {}
            for i=1,12 do
                local cardAnim = DrawGoodsInfo.new(self.data.activityDrawTabs.CollectStatus[1].CardMatrix[i], true)
                cardAnim:setPosition(bgSize.width * 0.452 + ((i - 1) % 4) * 93, bgSize.height * 0.78 - (math.floor((i - 1) / 4)) * 93)
                self.controls.drawNode:addChild(cardAnim)
                self.data.cardAnimTab[i] = cardAnim
                cardAnim:addTouchEventListener(function(sender, eventType)
                    if (eventType == ccui.TouchEventType.ended) and (self.data.isCanDraw) then
                        cardAnim:flipAction()
                    end
                end)
            end
            self.data.setAnimTab = {}
            for i=1,5 do
                local setAnim = DrawGoodsInfo.new(self.data.activityDrawTabs.MainStatus[1].SetList[i])
                setAnim:setPosition(bgSize.width * 0.46 + (i - 1) * 98, bgSize.height * 0.16)
                self.controls.drawNode:addChild(setAnim)
                setAnim:setTips(true)
                setAnim:setSetDesc(i)
                setAnim:setNumVisible(true)
                self.data.setAnimTab[i] = setAnim
                self.data.setAnimTab[i]:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if setAnim:isReceive() then
                            self:activityDraw(i)
                        end
                    end
                end)
            end
        end
    end)
end

function ActivityCenterLayer:helpUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(600, 160))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local lab = Common.finalFont("活动规则：", bgSize.width * 0.05, bgSize.height * 0.8, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab, bgZOrder)
    lab = Common.finalFont("1.每在线5分钟可获得一次抽奖机会,每日共有20次免费机会", bgSize.width * 0.05, bgSize.height * 0.6, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab, bgZOrder)
    lab = Common.finalFont("2.每次抽卡均有机会点亮一张图鉴,点亮图鉴可获得对应的奖励", bgSize.width * 0.05, bgSize.height * 0.4, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab, bgZOrder)
    lab = Common.finalFont("3.每点亮一套图鉴可获得额外大奖,一共可点亮5套图鉴", bgSize.width * 0.05, bgSize.height * 0.2, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab, bgZOrder)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            node:removeFromParent()
            node = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    return node
end

function ActivityCenterLayer:showTime(dt)
    if self.controls.timeCount then
        if self.data.nextFreeTime > 0 then
            self.data.nextFreeTime  = self.data.nextFreeTime  - 1
            local time = Common.timeFormat(self.data.nextFreeTime)
            self.controls.timeCount:setString(time.."后免费")
            self.data.isFree = false
            if self.data.activityAlertTab[DRAW_PANEL] then
                -- self.data.activityAlertTab[DRAW_PANEL]:setVisible(false)
                self.controls.free:setVisible(false)
                self.controls.costGoldSpri:setVisible(true)
                self.controls.costGold:setVisible(true)
            end
        else
            local surplusFreeCount = self.data.maxDailyFreeUseCount - self.data.dailyFreeUseCount
            if surplusFreeCount < 1 then
                self.controls.timeCount:setString("今日免费次数用完")
                self.data.isFree = false
                if self.data.activityAlertTab[DRAW_PANEL] then
                    -- self.data.activityAlertTab[DRAW_PANEL]:setVisible(false)
                    self.controls.free:setVisible(false)
                    self.controls.costGoldSpri:setVisible(true)
                    self.controls.costGold:setVisible(true)
                end
            else
                self.controls.timeCount:setString("免费次数"..surplusFreeCount.."/"..self.data.maxDailyFreeUseCount)
                self.data.isFree = true
                if self.data.activityAlertTab[DRAW_PANEL] then
                    -- self.data.activityAlertTab[DRAW_PANEL]:setVisible(true)
                    self.controls.free:setVisible(true)
                    self.controls.costGoldSpri:setVisible(false)
                    self.controls.costGold:setVisible(false)
                end
            end
        end
    end

    if self.controls.discharge_timeout then
        if self.loginData.currDay < self.loginData.maxDay then
            self.controls.discharge_timeout:setVisible(false)
        else
            self.controls.discharge_timeout:setVisible(true)
            if self.loginData.info[self.loginData.currDay].Sale.RemainSeconds > 0 then
                self.loginData.info[self.loginData.currDay].Sale.RemainSeconds  = self.loginData.info[self.loginData.currDay].Sale.RemainSeconds  - 1
                local time = Common.timeFormat(self.loginData.info[self.loginData.currDay].Sale.RemainSeconds)
                self.controls.discharge_timeout:setString("("..time..")")
            else
                self.controls.discharge_timeout:setVisible(false)
            end
        end
    end

    if self.controls.power_timeout then
        if self.powerData.info.NextCD > 0 then
            self.controls.power_timeout:setVisible(true)
            self.powerData.info.NextCD  = self.powerData.info.NextCD  - 1
            local time = Common.timeFormat(self.powerData.info.NextCD)
            self.controls.power_timeout:setString("下次品尝人参果 "..time)
        else
            self.controls.power_timeout:setVisible(false)
        end
    end
end

function ActivityCenterLayer:playHeroAnimAction()
    local oldIdxTab = {}
    local newIdxTab = {}
    for i=1,12 do
        oldIdxTab[i] = i
        self.data.cardAnimTab[i]:setChooseBorderVisible(false)
    end
    for i=1,12 do
        local tempIdx = math.random(1, (#oldIdxTab))
        local tempValue = oldIdxTab[tempIdx]
        newIdxTab[i] = tempValue
        table.remove(oldIdxTab, tempIdx)
    end
    for i=1,12 do
        local value = newIdxTab[i]
        if value == (self.data.lastIdx) then
            local lastValue = newIdxTab[12]
            newIdxTab[12] = value
            newIdxTab[i] = lastValue
        end
    end
    
    local function playAction(idx)
        local heroIdx = newIdxTab[idx]
        self.data.cardAnimTab[heroIdx]:setChooseBorderVisible(true)
        local delay = cc.DelayTime:create(self.data.playTime)
        local func = function()
            if idx == 12 then
                self.data.quanCount = self.data.quanCount + 1
                if self.data.quanCount > self.data.maxQuan then
                    local currCardAnim = self.data.cardAnimTab[self.data.lastIdx]
                    local isLight = currCardAnim:isLight()
                    if isLight then
                        Common.removeTopSwallowLayer()
                        self.data.isCanDraw = true
                        application:showFlashNotice("已经点亮该图鉴")
                    else
                        currCardAnim:setLight(true)
                        currCardAnim:flipAction()
                        local delay = cc.DelayTime:create(0.8)
                        self.controls.drawNode:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
                            Common.removeTopSwallowLayer()
                            self.data.isCanDraw = true

                            local drawReward = currCardAnim:getRewardInfo()
                            local alertShow = require("scene.main.ReceiveGoods").new({drawReward}, "image/ui/img/btn/btn_815.png")
                            self:addChild(alertShow, btnZOrder)

                            local bgSize = self.data.bgSize
                            if self.data.isOver then
                                self.data.isCanDraw = false
                                local congratulateUI = self:congratulate()
                                congratulateUI:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                                self:addChild(congratulateUI, bgZOrder)

                                local setAnim = self.data.setAnimTab[self.data.currCollectSet]
                                local isFinish = setAnim:isFinish()
                                if not isFinish then
                                    setAnim:setReceive()
                                end
                                return
                            end
                            if self.data.cardInfoTab then
                                for i=1,12 do
                                    self.data.cardAnimTab[i]:removeFromParent()
                                    self.data.cardAnimTab[i] = nil
                                    
                                    local cardAnim = DrawGoodsInfo.new(self.data.cardInfoTab[i], true)
                                    cardAnim:setPosition(bgSize.width * 0.452 + ((i - 1) % 4) * 93, bgSize.height * 0.78 - (math.floor((i - 1) / 4)) * 93)
                                    self.controls.drawNode:addChild(cardAnim)
                                    self.data.cardAnimTab[i] = cardAnim
                                    cardAnim:addTouchEventListener(function(sender, eventType)
                                        if (eventType == ccui.TouchEventType.ended) and (self.data.isCanDraw) then
                                            cardAnim:flipAction()
                                        end
                                    end)
                                end

                                local congratulateUI = self:congratulate()
                                congratulateUI:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                                self:addChild(congratulateUI, bgZOrder)

                                local setAnim = self.data.setAnimTab[self.data.currCollectSet]
                                local isFinish = setAnim:isFinish()
                                if not isFinish then
                                    setAnim:setReceive()
                                end
                                self.data.currCollectSet = self.data.currCollectSet + 1
                            end
                        end)))
                    end
                else
                    self.data.playTime = self.data.playTime + 0.08
                    self:playHeroAnimAction()
                end
            else
                if self.data.quanCount == self.data.maxQuan then
                    self.data.playTime = self.data.playTime + 0.02
                end
                self.data.cardAnimTab[heroIdx]:setChooseBorderVisible(false)
                playAction(idx + 1)
            end
        end
        self.data.cardAnimTab[heroIdx]:runAction(cc.Sequence:create(delay, cc.CallFunc:create(func)))
    end
    playAction(1)
end

function ActivityCenterLayer:congratulate()
    local node = cc.Node:create()

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(-SCREEN_WIDTH * 0.5, -SCREEN_HEIGHT * 0.5)
    node:addChild(bgLayer)

    local bg = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    bg:setScale(0.85)
    bg:setPosition(0, 95)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local fontBg = cc.Sprite:create("image/ui/img/bg/bg_163.png")
    fontBg:setScaleX(0.6)
    fontBg:setScaleY(0.6)
    fontBg:setPosition(0, 10)
    node:addChild(fontBg)

    local title = createMixScale9Sprite("image/ui/img/bg/bg_160.png", nil, "image/ui/img/btn/btn_873.png", cc.size(230, 45))
    title:setTouchEnable(false)
    title:setChildPos(0.5, 0.9)
    title:setPosition(0, bgSize.height * 0.16)
    node:addChild(title)

    local font = ColorLabel.new("", 25, 10)
    font:setPosition(0, 10)
    node:addChild(font)
    font:setString("[255,255,255]已成功收集[=][42,255,0]第"..self.data.currCollectSet.."套[=][255,255,255]图鉴点击下方图标领取奖励[=]")

    local function onTouchBegan(touch, event)
        node:removeFromParent()
        node = nil
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
    return node
end

function ActivityCenterLayer:createSlotUI()
    self.controls.SlotNode = cc.Node:create()
    self.controls.SlotNode.Name = SLOT_PANEL
    self.controls.bg:addChild(self.controls.SlotNode, bgZOrder)    
    self.data.allNodeTab[SLOT_PANEL] = self.controls.SlotNode

    local bg = cc.Sprite:create("image/ui/img/bg/bg_324.png")
    bg:setPosition(self.data.bgSize.width * 0.472, self.data.bgSize.height * 0.524)
    self.controls.SlotNode:addChild(bg)

    self.slotControls = {}
    self.slotData = {}

    local showGoodsTabs = {}
    for k,configGoodsInfo in ipairs(BaseConfig.getActivityBarAwards()) do
        local goodsInfo = {}
        goodsInfo.ID = configGoodsInfo.GoodsID
        goodsInfo.Type = configGoodsInfo.GoodsType
        goodsInfo.Num = configGoodsInfo.Num
        showGoodsTabs[k] = goodsInfo
    end
    self.slotData.goodsInfoTabs = showGoodsTabs

    self.controls.fireworksEffect = effects:CreateAnimation(self.controls.SlotNode, 0, 0, nil, 48, false)
    self.controls.fireworksEffect:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5)
    self.controls.fireworksEffect:setLocalZOrder(1)
    self.controls.fireworksEffect:setVisible(false)

    local function createLookView(viewSize)
        local layoutHeight = 70 * (#showGoodsTabs)
        local function cellSizeForTable(table,idx) 
            return layoutHeight,viewSize.width
        end
        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            
            local function getLayer()
                local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), viewSize.width, layoutHeight)
                for k,goodsInfo in pairs(showGoodsTabs) do
                    local item = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_SMALLTYPE)
                    item:setPosition(viewSize.width * 0.24, layoutHeight - 32 - (k - 1) * 70)
                    if item.setNumVisible then
                        item:setNumVisible(false)
                    end
                    layerColor:addChild(item)

                    local numLab = Common.finalFont("x "..Common.numConvert(goodsInfo.Num), 1, 1, 20, cc.c3b(255, 255, 0), 1)
                    numLab:enableOutline(cc.c3b(79, 1, 0), 2)
                    numLab:setAnchorPoint(0, 0.5)
                    numLab:setAdditionalKerning(-2)
                    numLab:setPosition(viewSize.width * 0.44, layoutHeight - 32 - (k - 1) * 70)
                    layerColor:addChild(numLab)
                end
                return layerColor
            end

            if nil == cell then
                cell = cc.TableViewCell:new()
                cell:addChild(getLayer())
            end
            return cell
        end
        local function numberOfCellsInTableView(table)
           return 1
        end
        local tableView = cc.TableView:create(viewSize)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()
        return tableView      
    end

    local viewSize = cc.size(200, 320)
    local view = createLookView(viewSize)
    view:setPosition(self.data.bgSize.width * 0.37 - viewSize.width * 0.5, self.data.bgSize.height * 0.38 - viewSize.height * 0.5)
    self.controls.SlotNode:addChild(view)

    local clickLayer = Common.createClickLayer(viewSize.width, viewSize.height, 
                                                self.data.bgSize.width * 0.37 - viewSize.width * 0.5, 
                                                self.data.bgSize.height * 0.38 - viewSize.height * 0.5)
    self.controls.SlotNode:addChild(clickLayer)

    local mode = cc.Sprite:create("image/ui/img/btn/btn_1274.png")
    local modeSize = mode:getContentSize()
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setAlphaThreshold(0.5)
    clippingNode:setStencil(mode)
    clippingNode:setPosition(self.data.bgSize.width * 0.64, self.data.bgSize.height * 0.48)
    self.controls.SlotNode:addChild(clippingNode)

    local line = cc.Sprite:create("image/ui/img/btn/btn_1269.png")
    line:setPosition(self.data.bgSize.width * 0.75, self.data.bgSize.height * 0.47)
    self.controls.SlotNode:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_1269.png")
    line:setFlippedX(true)
    line:setPosition(self.data.bgSize.width * 0.532, self.data.bgSize.height * 0.47)
    self.controls.SlotNode:addChild(line)

    self.slotControls.rollBg1 = cc.Sprite:create("image/ui/img/btn/btn_1273.png")
    self.slotControls.rollBg1:setPosition(self.data.bgSize.width * 0.64, self.data.bgSize.height * 0.48)
    self.controls.SlotNode:addChild(self.slotControls.rollBg1)
    self.slotControls.rollBg2 = cc.Sprite:create("image/ui/img/btn/btn_1311.png")
    self.slotControls.rollBg2:setPosition(self.data.bgSize.width * 0.64, self.data.bgSize.height * 0.48)
    self.controls.SlotNode:addChild(self.slotControls.rollBg2)
    self:setSlotBlink(false)

    local soltScrollNode = cc.Node:create()
    clippingNode:addChild(soltScrollNode)

    self.slotData.slotCenterIdx = 3
    self.slotData.slotRollSpeed = 0
    self.slotData.slotLayoutTab = {}

    self.slotData.slotGoodsTotal = (#self.slotData.goodsInfoTabs)
    for i=1,CELLTOTAL do
        local path = nil
        if (i % 2) == 0 then
            path = "image/ui/img/btn/btn_1271.png"
        else
            path = "image/ui/img/btn/btn_1270.png"
        end
        local bg = cc.Sprite:create(path)
        bg:setPosition(0, (i - 3) * CARDSPACE)
        soltScrollNode:addChild(bg)
        local bgSize = bg:getContentSize()

        local item = Common.getGoods(self.slotData.goodsInfoTabs[i], false, BaseConfig.GOODS_MIDDLETYPE)
        item:setName("icon")
        item:setPosition(bgSize.width * 0.3, bgSize.height * 0.5)
        if item.setNumVisible then
            item:setNumVisible(false)
        end
        if item.setTips then
            item:setTips(false)
        end
        if item.setTouchEnable then
            item:setTouchEnable(false)
        end
        bg:addChild(item)

        local numLab = Common.finalFont("x "..Common.numConvert(self.slotData.goodsInfoTabs[i].Num), 1, 1, 20, cc.c3b(255, 255, 0), 1)
        numLab:setName("num")
        numLab:enableOutline(cc.c3b(79, 1, 0), 2)
        numLab:setAnchorPoint(0, 0.5)
        numLab:setAdditionalKerning(-2)
        numLab:setPosition(bgSize.width * 0.52, bgSize.height * 0.5)
        bg:addChild(numLab)

        bg.idx = CELLTOTAL - i
        self.slotData.slotLayoutTab[i] = bg
    end

    self.slotControls.costGoldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    self.slotControls.costGoldSpri:setPosition(self.data.bgSize.width * 0.84, self.data.bgSize.height * 0.238)
    self.controls.SlotNode:addChild(self.slotControls.costGoldSpri)
    self.slotControls.costGold = Common.finalFont("", 1, 1, 20, cc.c3b(255, 246, 0), 1)
    self.slotControls.costGold:setPosition(self.data.bgSize.width * 0.9, self.data.bgSize.height * 0.238)
    self.controls.SlotNode:addChild(self.slotControls.costGold)

    self.slotControls.useCountLab = Common.finalFont("今日剩余", 1, 1, 20, cc.c3b(120, 255, 0), 1)
    self.slotControls.useCountLab:setPosition(self.data.bgSize.width * 0.88, self.data.bgSize.height * 0.32)
    self.controls.SlotNode:addChild(self.slotControls.useCountLab)
    
    local rockStick = require("scene.main.activity.widget.RockStick").new()
    rockStick:setPosition(self.data.bgSize.width * 0.89, self.data.bgSize.height * 0.65)
    self.controls.SlotNode:addChild(rockStick)
    rockStick:addFinishEventListener(function(sender, rollSpeed)
        local totalCount = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP).GambleBarCount
        if self.slotData.useCount >= totalCount then
            local layer = require("tool.helper.CommonLayer").ToBuyVIP("亲亲，今天的次数用完了。提升VIP等级可以获得更多的拉吧次数")
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(layer)
            return
        end

        local nextPrice = BaseConfig:getActivityBarPrice(self.slotData.useCount + 1).Price
        if Common.isCostMoney(1001, nextPrice) then
            sender:setBallTouchEnabled(false)
            rpc:call("Activity.UseGambleBar", nil, function(event)
                if event.status == Exceptions.Nil then
                    self.slotData.receiveGoodsInfo = event.result
                    local rad = 1
                    for k,goodsInfo in pairs(self.slotData.goodsInfoTabs) do
                        if self.slotData.receiveGoodsInfo.Type == goodsInfo.Type 
                            and self.slotData.receiveGoodsInfo.ID == goodsInfo.ID 
                            and self.slotData.receiveGoodsInfo.Num == goodsInfo.Num then
                            rad = k
                            break
                        end
                    end

                    self.slotData.slotBlinkSpeed = 0.1
                    self:setSlotBlink(true)
                    Common.playSound("res/audio/effect/la_1.mp3", false)
                    self.slotData.slotCenterIdx = self.slotData.slotCenterIdx + 1
                    self.slotData.slotRollSpeed = rollSpeed
                    self.slotData.slotRollDelayTime = 0
                    local isDelay = math.random(1, 2)
                    isDelay = (1 == isDelay) and true or false
                    Common.addTopSwallowLayer()
                    self:playRollAction(soltScrollNode, rad, false, isDelay, function()
                        Common.removeTopSwallowLayer()
                        sender:setBallTouchEnabled(true)

                        local alertShow = require("scene.main.ReceiveGoods").new({self.slotData.receiveGoodsInfo}, "image/ui/img/btn/btn_815.png")
                        self:addChild(alertShow, btnZOrder)

                        self.slotData.useCount = self.slotData.useCount + 1
                        self:updateSlotUI()
                    end)
                else
                    sender:setBallTouchEnabled(true)
                end
            end)
        end
    end)
    
    self.slotData.useCount = 0
    rpc:call("Game.GetMultiSysInfo", {"Gamblebar"}, function(event)
        if event.status == Exceptions.Nil then
            self.slotData.useCount = event.result.Gamblebar 
            self:updateSlotUI()
        end
    end)
end

function ActivityCenterLayer:updateSlotUI()
    local vipPrivilegeConfig = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP)
    local totalCount = vipPrivilegeConfig.GambleBarCount
    if self.slotData.useCount < totalCount then
        local nextPrice = BaseConfig:getActivityBarPrice(self.slotData.useCount + 1).Price
        self.slotControls.costGold:setString(nextPrice)
        if nextPrice == 0 then
            self.slotControls.costGold:setString("免费")
        end
    else
        self.slotControls.costGoldSpri:setVisible(false)  
        self.slotControls.costGold:setVisible(false)
    end

    self.slotControls.useCountLab:setString("今日剩余("..(totalCount - self.slotData.useCount).."/"..totalCount..")")

    -- if self.slotData.useCount >= totalCount then
    --     self.data.activityAlertTab[SLOT_PANEL]:setVisible(false)
    -- else
    --     self.data.activityAlertTab[SLOT_PANEL]:setVisible(true)
    -- end
end

-- rad中奖号, isMustStop是否手动停止转盘, isDelay停顿模式, finishFunc转盘停止事件
function ActivityCenterLayer:playRollAction(node, rad, isMustStop, isDelay, finishFunc)
    Common.playSound("res/audio/effect/la_2.mp3", false)
    -- 背景图片复用处理，和数据的处理无关
    self.slotData.slotCenterIdx = ((self.slotData.slotCenterIdx - 1) <= 0) and CELLTOTAL or (self.slotData.slotCenterIdx - 1)
    local overNumber = ((self.slotData.slotCenterIdx + 3) > CELLTOTAL) and ((self.slotData.slotCenterIdx + 3) - CELLTOTAL) or (self.slotData.slotCenterIdx + 3)
    local afterNumber = ((overNumber + 1) > CELLTOTAL) and 1 or (overNumber + 1)

    local overLayout = self.slotData.slotLayoutTab[overNumber] -- 即将要被刷新的面板
    local afterLayout = self.slotData.slotLayoutTab[afterNumber] -- 即将要被刷新面板的上一个面板

    local afterPosY = afterLayout:getPositionY()
    overLayout:setPositionY(afterPosY - CARDSPACE)

    -- 真实数据处理
    local centerLayer = self.slotData.slotLayoutTab[self.slotData.slotCenterIdx]
    local reallyCenterIdx = centerLayer.idx

    local function setoverLayoutData(idx, isLast)
        overLayout.idx = idx
        overLayout:getChildByName("icon"):removeFromParent()
        local bgSize = overLayout:getContentSize()
        local tempGoodsInfo = nil
        if isLast then
            tempGoodsInfo = self.slotData.receiveGoodsInfo
        else
            tempGoodsInfo = self.slotData.goodsInfoTabs[overLayout.idx]
        end
        local item = Common.getGoods(tempGoodsInfo, false, BaseConfig.GOODS_MIDDLETYPE)
        item:setName("icon")
        item:setPosition(bgSize.width * 0.3, bgSize.height * 0.5)
        if item.setNumVisible then
            item:setNumVisible(false)
        end
        if item.setTips then
            item:setTips(false)
        end
        if item.setTouchEnable then
            item:setTouchEnable(false)
        end
        overLayout:addChild(item)
        overLayout:getChildByName("num"):setString("x "..Common.numConvert(tempGoodsInfo.Num))
    end
    setoverLayoutData((math.random(1, self.slotData.slotGoodsTotal)))

    -- 滚动速度控制
    local minSpeed = 0.2
    if self.slotData.slotRollSpeed < 0.1 then
        self.slotData.slotRollSpeed = self.slotData.slotRollSpeed + 0.002
    else
        if isDelay then
            self.slotData.slotRollDelayTime = self.slotData.slotRollDelayTime + 0.02
        end
        self.slotData.slotRollSpeed = self.slotData.slotRollSpeed + 0.02
        if self.slotData.slotRollSpeed > minSpeed then
            self.slotData.slotRollSpeed = minSpeed
        end
    end
    -- 启动手动停止
    if (not isMustStop) and (self.slotData.slotRollSpeed == minSpeed) then
        isMustStop = true
        setoverLayoutData(rad, true)
    end
    if isMustStop and (self.slotData.slotRollSpeed == minSpeed) and (reallyCenterIdx == rad) then
        if finishFunc then
            Common.stopAllSounds()
            self:setSlotBlink(false)
            self.controls.fireworksEffect:setVisible(true)
            effects:RepeatAnimation(self.controls.fireworksEffect)

            centerLayer:runAction(cc.Sequence:create(cc.Blink:create(2, 10)))

            local delay = cc.DelayTime:create(2)
            node:runAction(cc.Sequence:create({delay, cc.CallFunc:create(finishFunc)}))
        end
        return
    end

    local move = cc.MoveBy:create(0.01 + self.slotData.slotRollSpeed, cc.p(0, CARDSPACE))
    local delay = cc.DelayTime:create(self.slotData.slotRollDelayTime)
    node:runAction(cc.Sequence:create({move, delay, cc.CallFunc:create(function()
        self:playRollAction(node, rad, isMustStop, isDelay, finishFunc)
    end)}))
end

function ActivityCenterLayer:setSlotBlink(visible)
    self.slotControls.rollBg1:stopAllActions()
    self.slotControls.rollBg2:stopAllActions()
    self.slotControls.rollBg1:setVisible(false)
    self.slotControls.rollBg2:setVisible(true)

    if not visible then
        return 
    end

    local function blink1(delayTime)
        local delay = cc.DelayTime:create(delayTime)
        local hide = cc.Hide:create()
        local show = cc.Show:create()
        local rep = cc.Sequence:create(hide, delay, show, delay:clone())
        self.slotControls.rollBg1:runAction(cc.Sequence:create({hide, delay, show, delay:clone(), cc.CallFunc:create(function()
            self.slotData.slotBlinkSpeed = self.slotData.slotBlinkSpeed + 0.02
            blink1(self.slotData.slotBlinkSpeed)
        end)}))
    end
    local function blink2(delayTime)
        local delay = cc.DelayTime:create(delayTime)
        local hide = cc.Hide:create()
        local show = cc.Show:create()
        local rep = cc.Sequence:create(hide, delay, show, delay:clone())
        self.slotControls.rollBg2:runAction(cc.Sequence:create({show, delay, hide, delay:clone(), cc.CallFunc:create(function()
            blink2(self.slotData.slotBlinkSpeed)
        end)}))
    end
    blink1(self.slotData.slotBlinkSpeed)
    blink2(self.slotData.slotBlinkSpeed)
end

function ActivityCenterLayer:createRecommendHeroUI()
    self.controls.recommendHeroNode = cc.Node:create()
    self.controls.recommendHeroNode.Name = RECOMMEND_HERO_PANEL
    self.controls.bg:addChild(self.controls.recommendHeroNode, bgZOrder)    
    self.data.allNodeTab[RECOMMEND_HERO_PANEL] = self.controls.recommendHeroNode

    self.recommendData = {}
    self.recommendControls = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_329.png")
    bg:setPosition(self.data.bgSize.width * 0.502, self.data.bgSize.height * 0.535)
    self.controls.recommendHeroNode:addChild(bg)
    local bgSize = self.data.bgSize

    for i=1,4 do
        local recommendConfig = BaseConfig.getRecommendHeroConfig(i)
        local heroID = recommendConfig.Hero
        local scaleConfig = BaseConfig.GetHeroScale(heroID)
        local heroScale = scaleConfig.ShowScale / 10000
        local heroOffset = scaleConfig.Offset
        local heroAnim = require("tool.helper.HeroAction").new(0, 0, heroID)
        heroAnim:setPosition(bgSize.width * 0.15 + heroOffset[1] + (i - 1) * 210, bgSize.height * 0.38 + heroOffset[2])
        heroAnim:setScale(heroScale)
        self.controls.recommendHeroNode:addChild(heroAnim)
        heroAnim:addTouchEvent(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                rpc:call("Activity.HeroRecommandInfo", nil, function(event)
                    if event.status == Exceptions.Nil then
                        self.recommendData.info = event.result or {}
                        local layer = require("scene.main.activity.widget.HeroInfoShowPanel").new(heroID, self.recommendData.info[tostring(heroID)], recommendConfig.ID)
                        local scene = cc.Director:getInstance():getRunningScene()
                        scene:addChild(layer)
                    end
                end)
            end
        end)

        local nameBg = cc.Sprite:create("image/ui/img/btn/btn_1397.png")
        nameBg:setPosition(bgSize.width * 0.15 + heroOffset[1] + (i - 1) * 210, bgSize.height * 0.2)
        self.controls.recommendHeroNode:addChild(nameBg)

        local typeName = Common.finalFont(recommendConfig.Type, 1, 1, 25, nil, 1)
        typeName:enableOutline(cc.c3b(17, 60, 45), 1)
        typeName:setPosition(bgSize.width * 0.15 + heroOffset[1] + (i - 1) * 210, bgSize.height * 0.2)
        self.controls.recommendHeroNode:addChild(typeName)
    end
end

function ActivityCenterLayer:createGrowthFundUI()
    self.controls.growthFundNode = cc.Node:create()
    self.controls.growthFundNode.Name = GROWTHFUND_PANEL
    self.controls.bg:addChild(self.controls.growthFundNode, bgZOrder)    
    self.data.allNodeTab[GROWTHFUND_PANEL] = self.controls.growthFundNode

    self.growthFundData = {}
    self.growthFundControls = {}

    self.growthFundData.growthFundTabs = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_330.png")
    bg:setPosition(self.data.bgSize.width * 0.48, self.data.bgSize.height * 0.532)
    self.controls.growthFundNode:addChild(bg)
    local bgSize = self.data.bgSize

    local lab = Common.finalFont("亲~已有", 1, 1, 20, nil, 1)
    lab:setPosition(bgSize.width * 0.26, bgSize.height * 0.67)
    self.controls.growthFundNode:addChild(lab)
    lab = Common.finalFont("人购买啦~", 1, 1, 20, nil, 1)
    lab:setPosition(bgSize.width * 0.3, bgSize.height * 0.62)
    self.controls.growthFundNode:addChild(lab)

    self.growthFundControls.lab_buyPeople = Common.finalFont("", 1, 1, 20, cc.c3b(255, 255, 0), 1)
    self.growthFundControls.lab_buyPeople:setAdditionalKerning(-1)
    self.growthFundControls.lab_buyPeople:setPosition(bgSize.width * 0.34, bgSize.height * 0.67)
    self.controls.growthFundNode:addChild(self.growthFundControls.lab_buyPeople)

    self.growthFundControls.noticeSpri = cc.Sprite:create("image/ui/img/bg/bg_336.png")
    self.growthFundControls.noticeSpri:setPosition(bgSize.width * 0.65, bgSize.height * 0.84)
    self.controls.growthFundNode:addChild(self.growthFundControls.noticeSpri)

    self.growthFundControls.btn_buy = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(130, 70))
    self.growthFundControls.btn_buy:setButtonBounce(false)
    self.growthFundControls.btn_buy:setFont("购买" , 1, 1, 30, cc.c3b(248, 216, 136))
    self.growthFundControls.btn_buy:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.growthFundControls.btn_buy:setPosition(bgSize.width * 0.85, bgSize.height * 0.88)
    self.controls.growthFundNode:addChild(self.growthFundControls.btn_buy)
    self.growthFundControls.btn_buy:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            application:dispatchCustomEvent(AppEvent.UI.Activity.BuyFund, {})
        end
    end)

    self.growthFundControls.buyQuan = cc.Sprite:create("image/ui/img/btn/btn_595.png")
    self.growthFundControls.buyQuan:setPosition(bgSize.width * 0.78, bgSize.height * 0.88)
    self.controls.growthFundNode:addChild(self.growthFundControls.buyQuan)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
    self.growthFundControls.buyQuan:runAction(rep)

    self.growthFundControls.btn_buyLevel = createMixSprite("image/ui/img/bg/box_2_0.png")
    self.growthFundControls.btn_buyLevel:setButtonBounce(false)
    self.growthFundControls.btn_buyLevel:setFont("超值礼包限购" , 1, 1, 20, cc.c3b(255, 255, 255), 1)
    self.growthFundControls.btn_buyLevel:getFont():setAdditionalKerning(-2)
    self.growthFundControls.btn_buyLevel:setFontPos(0.5, 0.2)
    self.growthFundControls.btn_buyLevel:setPosition(bgSize.width * 0.78, bgSize.height * 0.88)
    self.controls.growthFundNode:addChild(self.growthFundControls.btn_buyLevel)
    self.growthFundControls.btn_buyLevel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hidePanel(self.data.allNodeTab[self.data.currPanel])
            self.data.currPanel = LEVEL_LIMIT_PANEL
            if not self.data.allNodeTab[self.data.currPanel] then
                self.data.createUIFuncTab[self.data.currPanel](self)
            end
            self:showPanel(self.data.allNodeTab[self.data.currPanel])
            self.controls.iconView:reloadData()
        end
    end)
    self.growthFundControls.btn_buyLevel:setVisible(false)

    rpc:call("Activity.GrowthFundInfo", nil, function(event)
        if event.status == Exceptions.Nil then
            self.growthFundData.info = event.result
            self.growthFundData.info.Status = event.result.Status or {}

            BaseConfig.getFundConfig()
            self.growthFundData.growthFundConfig = {}
            for k,config in pairs(BaseConfig.growth_fund) do
                table.insert(self.growthFundData.growthFundConfig, config)
            end
            table.sort(self.growthFundData.growthFundConfig, function(a, b)
                return a.Level < b.Level
            end)

            local viewSize = cc.size(bgSize.width, bgSize.height * 0.72)
            self.growthFundControls.view = self:createActivityView(viewSize, GROWTHFUND_PANEL)
            self.growthFundControls.view:setPosition(bgSize.width * 0.38, bgSize.height * 0.07)
            self.controls.growthFundNode:addChild(self.growthFundControls.view)

            self.growthFundData.viewInitHeightPosY = self.growthFundControls.view:getContentOffset().y
            
            self:updateGrowthFundUI()
        end
    end)
end

function ActivityCenterLayer:updateGrowthFundUI()
    local isFinishActivity = true
    for k,growthFundConfig in pairs(self.growthFundData.growthFundConfig) do
        if not self.growthFundData.info.Status[tostring(growthFundConfig.Level)] then
            isFinishActivity = false
        end
    end
    if isFinishActivity then
        self:finishActivity(GROWTHFUND_PANEL)
        return 
    end
    
    if self.growthFundData.info.IsBought then
        self.growthFundControls.noticeSpri:setVisible(false)
        self.growthFundControls.btn_buy:setVisible(false)
        self.growthFundControls.btn_buy:setTouchEnable(false)

        if self.data.activityIsNoticeTab[LEVEL_LIMIT_PANEL] then
            self.growthFundControls.btn_buyLevel:setVisible(true)
            self.growthFundControls.btn_buyLevel:setTouchEnable(true)
            self.growthFundControls.buyQuan:setVisible(true)
        else
            self.growthFundControls.btn_buyLevel:setVisible(false)
            self.growthFundControls.btn_buyLevel:setTouchEnable(false)
            self.growthFundControls.buyQuan:setVisible(false)
        end
    else
        self.growthFundControls.btn_buyLevel:setVisible(false)
        self.growthFundControls.btn_buyLevel:setTouchEnable(false)
        self.growthFundControls.buyQuan:setVisible(false)
    end
    
    self.growthFundControls.lab_buyPeople:setString(self.growthFundData.info.HowManyPepoleBuy)

    table.sort(self.growthFundData.growthFundConfig, function(a, b)
        return a.Level < b.Level
    end)
    self.growthFundControls.view:reloadData()

    local isHaveReceive = false
    local number = 1
    for k,growthFundConfig in pairs(self.growthFundData.growthFundConfig) do
        if GameCache.Avatar.Level >= growthFundConfig.Level then
            if not self.growthFundData.info.Status[tostring(growthFundConfig.Level)] then
                isHaveReceive = true
                number = k
                break
            end
        end
    end
    if isHaveReceive then
        local posY = self.growthFundData.viewInitHeightPosY
        local y = ((posY + 110 * (number - 1)) > 0) and 0 or (posY + 110 * (number - 1))
        self.growthFundControls.view:setContentOffset(cc.p(0, y), false)
    end
end

function ActivityCenterLayer:createActivityView(viewSize, viewType)
    local function cellSizeForTable(table,idx) 
        return 110,viewSize.width
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local function getLayout()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,0,0), viewSize.width, 110)
            layerColor:setAnchorPoint(0, 0)
            layerColor:setTag(LAYERCOLORTAG)

            local panel = nil
            if viewType == GROWTHFUND_PANEL then
                panel = require("scene.main.activity.widget.FundPanel").new()
            elseif viewType == PURCHASE_COUNT_PANEL then
                panel = require("scene.main.activity.widget.AccumulatePanel").new()
            end
            local layerSize = layerColor:getContentSize()
            panel:setPosition(0, layerSize.height * 0.52)
            panel:setTag(ACTIVITYPANELTAG)
            layerColor:addChild(panel)

            return layerColor
        end

        local layerColor = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            layerColor = getLayout()
            cell:addChild(layerColor)
        else
            layerColor = cell:getChildByTag(LAYERCOLORTAG)
        end

        local activityPanel = layerColor:getChildByTag(ACTIVITYPANELTAG)
        if (idx + 1)%2 == 0 then
            activityPanel:setBgOpacity(0)
        else
            activityPanel:setBgOpacity(255)
        end
        
        if viewType == GROWTHFUND_PANEL then
            local growthFundConfig = self.growthFundData.growthFundConfig[idx + 1]
            if  self.growthFundData.info.IsBought then
                activityPanel:updatePanelInfo(growthFundConfig, self.growthFundData.info.Status[tostring(growthFundConfig.Level)], 
                                                GameCache.Avatar.Level, growthFundConfig.Level)
                activityPanel:setReceiveStatus()
            else
                activityPanel:setBuyStatus(growthFundConfig)
            end
        elseif viewType == PURCHASE_COUNT_PANEL then
            local accumulateConfig = self.accumulateData.accumulateConfig[idx + 1]
            activityPanel:updatePanelInfo(accumulateConfig, self.accumulateData.info.Recived[tostring(accumulateConfig.Gold)],
                                                GameCache.Avatar.AccPurchase, accumulateConfig.Gold)
            activityPanel:updatePurchaseCount(GameCache.Avatar.AccPurchase, accumulateConfig.Gold)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
        if viewType == GROWTHFUND_PANEL then
            return (#self.growthFundData.growthFundConfig)
        elseif viewType == PURCHASE_COUNT_PANEL then
            return (#self.accumulateData.accumulateConfig)
        end
    end

    local tableView = cc.TableView:create(viewSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView   
end

function ActivityCenterLayer:createDiscountUI()
    self.controls.discountNode = cc.Node:create()
    self.controls.discountNode.Name = DISCOUNT_PURCHASE_PANEL
    self.controls.bg:addChild(self.controls.discountNode, bgZOrder)    
    self.data.allNodeTab[DISCOUNT_PURCHASE_PANEL] = self.controls.discountNode

    self.discountData = {}
    self.discountControls = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_333.png")
    bg:setPosition(self.data.bgSize.width * 0.455, self.data.bgSize.height * 0.495)
    self.controls.discountNode:addChild(bg)
    local bgSize = self.data.bgSize

    local date = Common.finalFont("活动时间:", 1, 1, 20, cc.c3b(255, 255, 0), 1)
    date:setPosition(bgSize.width * 0.5, bgSize.height * 0.88)
    self.controls.discountNode:addChild(date)

    self.discountControls.lab_date = Common.finalFont("", 1, 1, 20, nil, 1)
    self.discountControls.lab_date:setAnchorPoint(0, 0.5)
    self.discountControls.lab_date:setPosition(bgSize.width * 0.56, bgSize.height * 0.88)
    self.controls.discountNode:addChild(self.discountControls.lab_date)

    self.discountData.remainingCountTab = {}
    self.discountData.changeButtonTab = {}
    local discountConfig = BaseConfig.getDiscountConfig()
    for k1,discountInfo in pairs(discountConfig) do
        local goodsItem = Common.getGoods({Type = BaseConfig.GT_MONEY, ID = 1001, Num = discountInfo.Price}, false, BaseConfig.GOODS_MIDDLETYPE)
        local height = bgSize.height - 155 - (k1 - 1) * 130
        goodsItem:setPosition(bgSize.width * 0.45, height)
        self.controls.discountNode:addChild(goodsItem)

        local discountSpri = cc.Sprite:create("image/ui/img/btn/btn_1388.png")
        discountSpri:setPosition(bgSize.width * 0.4, height + 30)
        self.controls.discountNode:addChild(discountSpri)

        local equal = cc.Sprite:create("image/ui/img/btn/btn_1396.png")
        equal:setPosition(bgSize.width * 0.535, height + 10)
        self.controls.discountNode:addChild(equal)
        equal = cc.Sprite:create("image/ui/img/btn/btn_1396.png")
        equal:setPosition(bgSize.width * 0.535, height - 10)
        self.controls.discountNode:addChild(equal)

        for k2,goodsInfo in pairs(discountInfo.Goods) do
            local awardInfo = {}
            awardInfo.Type = goodsInfo.GoodsType
            awardInfo.ID = goodsInfo.GoodsID
            awardInfo.Num = goodsInfo.Num

            local awardItem = Common.getGoods(awardInfo, false, BaseConfig.GOODS_MIDDLETYPE)
            awardItem:setPosition(bgSize.width * 0.62 + (k2 - 1) * 110, height)
            self.controls.discountNode:addChild(awardItem)
        end

        local btn_change = createMixScale9Sprite("image/ui/img/btn/btn_818.png", "image/ui/img/btn/btn_819.png", nil, cc.size(130, 56))
        btn_change:setButtonBounce(false)
        btn_change:setFont("兑换" , 1, 1, 25, cc.c3b(248, 216, 136))
        btn_change:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        btn_change:setPosition(bgSize.width * 0.88, height - 15)
        btn_change:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if Common.isCostMoney(1001, discountInfo.Price) then
                    rpc:call("Activity.DiscountPurchase", k1, function(event)
                        if event.status == Exceptions.Nil then
                            local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                            self:addChild(alertShow)

                            self.discountData.info.Remaining[tostring(k1)] = self.discountData.info.Remaining[tostring(k1)] - 1
                            self:updateDiscountUI()
                        end
                    end)
                end
            end
        end)
        self.controls.discountNode:addChild(btn_change)
        self.discountData.changeButtonTab[k1] = btn_change

        local lab = Common.finalFont("剩余次数:", 1, 1, 20, cc.c3b(255, 255, 0), 1)
        lab:setPosition(bgSize.width * 0.86, height + 35)
        self.controls.discountNode:addChild(lab)

        local lab_count = Common.finalFont("", 1, 1, 20, nil, 1)
        lab_count:setAnchorPoint(0, 0.5)
        lab_count:setPosition(bgSize.width * 0.92, height + 35)
        self.controls.discountNode:addChild(lab_count)
        self.discountData.remainingCountTab[k1] = lab_count
    end

    rpc:call("Activity.DiscountPurchaseInfo", nil, function(event)
        if event.status == Exceptions.Nil then
            self.discountData.info = event.result
            self:updateDiscountUI()
        end
    end)
end

function ActivityCenterLayer:updateDiscountUI()
    self.discountControls.lab_date:setString(self.discountData.info.Time)

    local isFinishActivity = true
    for i=1,3 do
        local remainingCount = self.discountData.info.Remaining[tostring(i)]
        self.discountData.remainingCountTab[i]:setString(remainingCount.."/"..DISCOUNT_TOTAL)
        if remainingCount < 1 then
            self.discountData.changeButtonTab[i]:setNorGLProgram(false)
            self.discountData.changeButtonTab[i]:setTouchEnable(false)
        else
            isFinishActivity = false
        end
    end
    if isFinishActivity then
        self:finishActivity(DISCOUNT_PURCHASE_PANEL)
        return 
    end
end

function ActivityCenterLayer:createLevelLimitUI()
    self.controls.levelLimitNode = cc.Node:create()
    self.controls.levelLimitNode.Name = LEVEL_LIMIT_PANEL
    self.controls.bg:addChild(self.controls.levelLimitNode, bgZOrder)    
    self.data.allNodeTab[LEVEL_LIMIT_PANEL] = self.controls.levelLimitNode

    self.levelLimitData = {}
    self.levelLimitControls = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_334.png")
    bg:setPosition(self.data.bgSize.width * 0.442, self.data.bgSize.height * 0.505)
    self.controls.levelLimitNode:addChild(bg)
    local bgSize = self.data.bgSize

    self.levelLimitControls.levelSpri = cc.Sprite:create("image/ui/img/btn/btn_1390.png")
    self.levelLimitControls.levelSpri:setPosition(bgSize.width * 0.49, bgSize.height * 0.94)
    self.controls.levelLimitNode:addChild(self.levelLimitControls.levelSpri)

    self.levelLimitControls.lab_limitDesc = Common.finalFont("", 1, 1, 20, cc.c3b(0, 255, 0), 1)
    self.levelLimitControls.lab_limitDesc:setPosition(bgSize.width * 0.64, bgSize.height * 0.24)
    self.controls.levelLimitNode:addChild(self.levelLimitControls.lab_limitDesc)

    self.levelLimitControls.btn_receive = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_1389.png", cc.size(160, 65))
    self.levelLimitControls.btn_receive:setButtonBounce(false)
    self.levelLimitControls.btn_receive:setChildPos(0.2, 0.55)
    self.levelLimitControls.btn_receive:setCircleFont("购买", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    self.levelLimitControls.btn_receive:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.levelLimitControls.btn_receive:setPosition(bgSize.width * 0.64, bgSize.height * 0.13)
    self.controls.levelLimitNode:addChild(self.levelLimitControls.btn_receive)
    self.levelLimitControls.btn_receive:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.activityIsNoticeTab[LEVEL_LIMIT_PANEL] then
                local allHero = GameCache.GetAllHero()
                local count = 0
                for k,heroInfo in pairs(allHero) do
                    if heroInfo.Level >= self.levelLimitData.currConfig.Condition[2] then
                        count = count + 1
                    end
                end
                if count < self.levelLimitData.currConfig.Condition[3] then
                    application:showFlashNotice("条件未达到～")
                    return 
                end

                if Common.isCostMoney(1001, self.levelLimitData.currConfig.Price) then
                    rpc:call("Activity.BuyLevelLimitGift", self.levelLimitData.currConfig.Level, function(event)
                        if event.status == Exceptions.Nil then
                            local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                            self:addChild(alertShow, btnZOrder)

                            self.data.activityAlertTab[LEVEL_LIMIT_PANEL]:setVisible(false)
                            self.data.activityIsNoticeTab[LEVEL_LIMIT_PANEL] = false
                            self:updateLevelLimitUI()
                        end
                    end)
                end
            else
                application:showFlashNotice("等级未达到～")
            end
        end
    end)

    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(bgSize.width * 0.76, bgSize.height * 0.13)
    self.controls.levelLimitNode:addChild(goldSpri)

    self.levelLimitControls.gold = Common.finalFont("", 1, 1, 20, cc.c3b(255, 255, 0), 1)
    self.levelLimitControls.gold:setAnchorPoint(0, 0.5)
    self.levelLimitControls.gold:setPosition(bgSize.width * 0.78, bgSize.height * 0.13)
    self.controls.levelLimitNode:addChild(self.levelLimitControls.gold)

    self.levelLimitControls.awardNode = cc.Node:create()
    self.controls.levelLimitNode:addChild(self.levelLimitControls.awardNode)

    local levelTab = {}
    BaseConfig.getLevelLimitConfig()
    for k,config in pairs(BaseConfig.level_limit) do
        table.insert(levelTab, config.Level)
    end
    table.sort(levelTab, function(a, b)
        return a < b
    end)
    self.levelLimitData.minLevel = levelTab[1]
    self.levelLimitData.maxLevel = levelTab[#levelTab]

    self:updateLevelLimitUI()
end

function ActivityCenterLayer:updateLevelLimitUI()
    local bgSize = self.data.bgSize
    self.levelLimitControls.awardNode:removeAllChildren()

    local level = math.floor(GameCache.Avatar.Level / 10) * 10
    level = (level >= self.levelLimitData.maxLevel) and self.levelLimitData.maxLevel or level
    local levelConfig = nil
    if self.data.activityIsNoticeTab[LEVEL_LIMIT_PANEL] then
        levelConfig = BaseConfig.getLevelLimitConfig(level)
    elseif level >= self.levelLimitData.maxLevel then
        self:finishActivity(LEVEL_LIMIT_PANEL)
        return 
    else
        level = ((level + 10) > self.levelLimitData.minLevel) and (level + 10) or self.levelLimitData.minLevel
        levelConfig = BaseConfig.getLevelLimitConfig(level)
    end
    for k,goodsInfo in pairs(levelConfig.Goods) do
        local awardInfo = {}
        awardInfo.Type = goodsInfo.GoodsType
        awardInfo.ID = goodsInfo.GoodsID
        awardInfo.Num = goodsInfo.Num

        local awardItem = Common.getGoods(awardInfo, false, BaseConfig.GOODS_MIDDLETYPE)
        awardItem:setPosition(bgSize.width * 0.4 + ((k - 1)%5) * 110, bgSize.height * 0.65 - (math.floor((k - 1)/5) * 120))
        self.levelLimitControls.awardNode:addChild(awardItem)
    end
    local levelSpriPathTab = {[20] = "image/ui/img/btn/btn_1398.png", [30] = "image/ui/img/btn/btn_1390.png", 
                            [40] = "image/ui/img/btn/btn_1391.png", [50] = "image/ui/img/btn/btn_1392.png",
                            [60] = "image/ui/img/btn/btn_1393.png", [70] = "image/ui/img/btn/btn_1399.png",}
    self.levelLimitControls.levelSpri:setTexture(levelSpriPathTab[level])
    self.levelLimitControls.lab_limitDesc:setString("(购买条件:"..levelConfig.ConditionDesc..")")
    self.levelLimitControls.gold:setString(levelConfig.Price)

    self.levelLimitData.currConfig = levelConfig
end

function ActivityCenterLayer:createAccumulatePurchaseUI()
    self.controls.accumulatePurchaseNode = cc.Node:create()
    self.controls.accumulatePurchaseNode.Name = PURCHASE_COUNT_PANEL
    self.controls.bg:addChild(self.controls.accumulatePurchaseNode, bgZOrder)    
    self.data.allNodeTab[PURCHASE_COUNT_PANEL] = self.controls.accumulatePurchaseNode

    self.accumulateData = {}
    self.accumulateControls = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_331.png")
    bg:setPosition(self.data.bgSize.width * 0.492, self.data.bgSize.height * 0.505)
    self.controls.accumulatePurchaseNode:addChild(bg)
    local bgSize = self.data.bgSize

    local date = Common.finalFont("活动时间:", 1, 1, 20, cc.c3b(255, 255, 0), 1)
    date:setPosition(bgSize.width * 0.5, bgSize.height * 0.82)
    self.controls.accumulatePurchaseNode:addChild(date)

    self.accumulateControls.lab_date = Common.finalFont("", 1, 1, 20, nil, 1)
    self.accumulateControls.lab_date:setAnchorPoint(0, 0.5)
    self.accumulateControls.lab_date:setPosition(bgSize.width * 0.56, bgSize.height * 0.82)
    self.controls.accumulatePurchaseNode:addChild(self.accumulateControls.lab_date)

    rpc:call("Activity.AccPurchaseInfo", nil, function(event)
        if event.status == Exceptions.Nil then
            self.accumulateData.info = event.result
            GameCache.Avatar.AccPurchase = self.accumulateData.info.PurchaseGoldCount
            self.accumulateData.info.Recived = event.result.Recived or {}

            BaseConfig.getAccumulatePurchaseConfig()
            self.accumulateData.accumulateConfig = {}
            for k,config in pairs(BaseConfig.accumulate_purchase) do
                table.insert(self.accumulateData.accumulateConfig, config)
            end
            table.sort(self.accumulateData.accumulateConfig, function(a, b)
                return a.Gold < b.Gold
            end)

            local viewSize = cc.size(bgSize.width, bgSize.height * 0.72)
            self.accumulateControls.view = self:createActivityView(viewSize, PURCHASE_COUNT_PANEL)
            self.accumulateControls.view:setPosition(bgSize.width * 0.38, bgSize.height * 0.06)
            self.controls.accumulatePurchaseNode:addChild(self.accumulateControls.view)

            self.accumulateData.viewInitHeightPosY = self.accumulateControls.view:getContentOffset().y
            
            self:updateAccumulatePurchaseUI()
        end
    end)
end

function ActivityCenterLayer:updateAccumulatePurchaseUI()
    local isFinishActivity = true
    for k,accumulateConfig in pairs(self.accumulateData.accumulateConfig) do
        if not self.accumulateData.info.Recived[tostring(accumulateConfig.Gold)] then
            isFinishActivity = false
        end
    end
    if isFinishActivity then
        self:finishActivity(PURCHASE_COUNT_PANEL)
        return 
    end

    self.accumulateControls.lab_date:setString(self.accumulateData.info.Time)
    self.accumulateControls.view:reloadData()

    table.sort(self.accumulateData.accumulateConfig, function(a, b)
        return a.Gold < b.Gold
    end)
    self.accumulateControls.view:reloadData()

    local isHaveReceive = false
    local number = 1
    for k,accumulateConfig in pairs(self.accumulateData.accumulateConfig) do
        if GameCache.Avatar.AccPurchase >= accumulateConfig.Gold then
            if not self.accumulateData.info.Recived[tostring(accumulateConfig.Gold)] then
                isHaveReceive = true
                number = k
                break
            end
        end
    end
    if isHaveReceive then
        local posY = self.accumulateData.viewInitHeightPosY
        local y = ((posY + 110 * (number - 1)) > 0) and 0 or (posY + 110 * (number - 1))
        self.accumulateControls.view:setContentOffset(cc.p(0, y), false)
    end
end

function ActivityCenterLayer:createMonthCardUI()
    self.controls.monthCardNode = cc.Node:create()
    self.controls.monthCardNode.Name = MONTH_CARD_PANEL
    self.controls.bg:addChild(self.controls.monthCardNode, bgZOrder)    
    self.data.allNodeTab[MONTH_CARD_PANEL] = self.controls.monthCardNode

    self.monthCardData = {}
    self.monthCardControls = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_337.png")
    bg:setPosition(self.data.bgSize.width * 0.492, self.data.bgSize.height * 0.505)
    self.controls.monthCardNode:addChild(bg)
    local bgSize = self.data.bgSize

    local purchaseConfig = {}
    for k,config in pairs(BaseConfig.purchaseConfig) do
        purchaseConfig[config.ID] = config
    end
    local normalConfig = purchaseConfig[NORMAL_CARD_ID]
    local superConfig = purchaseConfig[SUPER_CARD_ID]

    local function buyFunc(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            local id = sender:getTag()
            local purchaseItem = purchaseConfig[id]
            rpc:call("Game.CreatePurchaseOrder", purchaseItem.IAPID, function(event)
                if event.status == Exceptions.Nil then
                    local orderID = event.result
                    if GAME_BASE_INFO.SDK then
                         SDK_doPay(orderID, purchaseItem, function(status)        
                             if "success" == status then        
                                 sender:setString("已购买")        
                                 sender:setTouchEnable(false)        
                             end        
                         end)
                    else
                        sender:setString("已购买")
                        sender:setTouchEnable(false)
                    end
                end
            end) 

        end
    end
    
    self.monthCardControls.buy_normal = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(155, 60))
    self.monthCardControls.buy_normal:setButtonBounce(false)
    self.monthCardControls.buy_normal:setCircleFont("￥"..normalConfig.Money.."购买", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    self.monthCardControls.buy_normal:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.monthCardControls.buy_normal:setPosition(bgSize.width * 0.52, bgSize.height * 0.19)
    self.controls.monthCardNode:addChild(self.monthCardControls.buy_normal)
    self.monthCardControls.buy_normal:addTouchEventListener(buyFunc)
    self.monthCardControls.buy_normal:setTag(NORMAL_CARD_ID)

    self.monthCardControls.buy_super = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(155, 60))
    self.monthCardControls.buy_super:setButtonBounce(false)
    self.monthCardControls.buy_super:setCircleFont("￥"..superConfig.Money.."购买", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    self.monthCardControls.buy_super:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.monthCardControls.buy_super:setPosition(bgSize.width * 0.81, bgSize.height * 0.19)
    self.controls.monthCardNode:addChild(self.monthCardControls.buy_super)
    self.monthCardControls.buy_super:addTouchEventListener(buyFunc)
    self.monthCardControls.buy_super:setTag(SUPER_CARD_ID)

    rpc:call("Activity.MonthCardInfo", price, function(event)
        if event.status == Exceptions.Nil then
            local buyInfo = event.result or {}
            for k,price in pairs(buyInfo) do
                if tonumber(price) == normalConfig.Money then
                    self.monthCardControls.buy_normal:setString("已购买")
                    self.monthCardControls.buy_normal:setTouchEnable(false)
                elseif tonumber(price) == superConfig.Money then
                    self.monthCardControls.buy_super:setString("已购买")
                    self.monthCardControls.buy_super:setTouchEnable(false)
                end
            end
        end
    end)
end

function ActivityCenterLayer:createPowerUI()
    self.controls.powerNode = cc.Node:create()
    self.controls.powerNode.Name = POWER_PANEL
    self.controls.bg:addChild(self.controls.powerNode, bgZOrder)    
    self.data.allNodeTab[POWER_PANEL] = self.controls.powerNode

    self.powerData = {}
    self.powerControls = {}
    self.powerData.info = {}

    local bg = cc.Sprite:create("image/ui/img/bg/bg_356.png")
    bg:setPosition(self.data.bgSize.width * 0.501, self.data.bgSize.height * 0.502)
    self.controls.powerNode:addChild(bg)
    local bgSize = self.data.bgSize

    self.powerControls.anim = sp.SkeletonAnimation:create("image/spine/ui_effect/52/skeleton.json", "image/spine/ui_effect/52/skeleton.atlas")
    self.powerControls.anim:setPosition(bgSize.width * 0.26, bgSize.height * 0.03)
    self.controls.powerNode:addChild(self.powerControls.anim)
    self.powerControls.anim:setAnimation(0, "animation", true)

    local titleSpri = cc.Sprite:create("image/ui/img/bg/bg_355.png")
    titleSpri:setPosition(bgSize.width * 0.7, bgSize.height * 0.7)
    self.controls.powerNode:addChild(titleSpri)

    self.controls.power_timeout = Common.finalFont("", 1, 1, 20, nil, 1)
    self.controls.power_timeout:setAdditionalKerning(-2)
    self.controls.power_timeout:setPosition(bgSize.width * 0.7, bgSize.height * 0.38)
    self.controls.powerNode:addChild(self.controls.power_timeout)

    self.powerControls.priceNode = cc.Node:create()
    self.controls.powerNode:addChild(self.powerControls.priceNode)

    local price = Common.finalFont("回购价:", 1, 1, 25, nil, 1)
    price:setAnchorPoint(0, 0.5)
    price:setAdditionalKerning(-2)
    price:setPosition(bgSize.width * 0.58, bgSize.height * 0.3)
    self.powerControls.priceNode:addChild(price)
    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setScale(1.2)
    goldSpri:setPosition(bgSize.width * 0.7, bgSize.height * 0.3)
    self.powerControls.priceNode:addChild(goldSpri)

    self.powerControls.buyPrice = Common.finalFont(EAT_PRICE, 1, 1, 25, cc.c3b(255, 255, 0), 1)
    self.powerControls.buyPrice:setAdditionalKerning(-1)
    self.powerControls.buyPrice:setAnchorPoint(0, 0.5)
    self.powerControls.buyPrice:setPosition(bgSize.width * 0.73, bgSize.height * 0.3)
    self.powerControls.priceNode:addChild(self.powerControls.buyPrice)

    self.powerControls.btn_eat = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(150, 64))
    self.powerControls.btn_eat:setButtonBounce(false)
    self.powerControls.btn_eat:setCircleFont("品尝人参果", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.powerControls.btn_eat:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.powerControls.btn_eat:getFont():setAdditionalKerning(-2)
    self.powerControls.btn_eat:setPosition(bgSize.width * 0.7, bgSize.height * 0.16)
    self.controls.powerNode:addChild(self.powerControls.btn_eat)
    self.powerControls.btn_eat:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            if self.powerData.info.Status == POWER_PAYABLE then
                if not Common.isCostMoney(1001, EAT_PRICE) then
                    return 
                end
            end
            rpc:call("Activity.AcceptPower", nil, function(event)
                if event.status == Exceptions.Nil then
                    self.powerData.info = event.result
                    self:updatePowerUI()

                    application:showFlashNotice("领取体力成功~!")
                end
            end)
        end
    end)
    self.powerControls.starEffect = effects:CreateAnimation(self.controls.powerNode, bgSize.width * 0.7, bgSize.height * 0.155, nil, 21, true)
    self.powerControls.starEffect:setScaleX(0.8)
    self.powerControls.starEffect:setVisible(false)

    rpc:call("Activity.GetDailyPowerStatus", nil, function(event)
        if event.status == Exceptions.Nil then
            self.powerData.info = event.result
            self:updatePowerUI()
        end
    end)
end

function ActivityCenterLayer:updatePowerUI()
    local bgSize = self.data.bgSize
    self.powerControls.priceNode:setVisible(false)
    self.powerControls.starEffect:setVisible(false)
    if self.powerData.info.Status == POWER_UNAVAILABLE then
        self.powerControls.btn_eat:setVisible(false)
        self.powerControls.btn_eat:setTouchEnable(false)
    elseif self.powerData.info.Status == POWER_AVAILABLE then
        self.powerControls.btn_eat:setVisible(true)
        self.powerControls.btn_eat:setTouchEnable(true)
        self.powerControls.btn_eat:setString("品尝人参果")
        self.powerControls.starEffect:setVisible(true)
    elseif self.powerData.info.Status == POWER_PAYABLE then
        self.powerControls.priceNode:setVisible(true)
        self.powerControls.btn_eat:setVisible(true)
        self.powerControls.btn_eat:setTouchEnable(true)
        self.powerControls.btn_eat:setString("补回人参果")
    end
end

function ActivityCenterLayer:createIconView(viewSize)
    local iconWidth = 120
    local function getLayoutWidth()
        local openNum = 0
        for k,activityIsOpen in pairs(self.data.activityIsOpenTab) do
            if activityIsOpen then
                openNum = openNum + 1
            end
        end
        return openNum * iconWidth
    end
    local function cellSizeForTable(table,idx) 
        return viewSize.height, getLayoutWidth()
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        
        local layoutWidth = getLayoutWidth()
        local bgSize = self.data.bgSize
        local function getLayer()
            local function iconTouchEvent(sender, eventType)
                if (eventType == ccui.TouchEventType.ended) and (not table:isTouchMoved()) then
                    for k,v in pairs(self.data.allNodeTab) do
                        if v then
                            self:hidePanel(v)
                        end
                    end
                    local panelIdx = sender:getTag()
                    for k,v in pairs(self.data.btnIconTab) do
                        v:setChildTextureVisible(false)
                        if panelIdx == v:getTag() then
                            v:setChildTextureVisible(true)
                        end
                    end
                    
                    self.data.currPanel = panelIdx
                    if not self.data.allNodeTab[panelIdx] then
                        self.data.createUIFuncTab[panelIdx](self)
                    elseif self.data.updateUIFuncTab[panelIdx] then
                        self.data.updateUIFuncTab[panelIdx](self)
                    end
                    self.data.activityAlertTab[panelIdx]:setVisible(false)
                    self:showPanel(self.data.allNodeTab[panelIdx])
                end
            end

            local iconNumPathTab = {1400, 1401, 1402, 1403, 1411, 1405, 1408, 1406, 1404, 1407, 1410, 1429}
            self.data.btnIconTab = {}
            self.data.activityAlertTab = {}
            local iconNum = 0
            local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), layoutWidth, viewSize.height)
            for panelIdx,activityIsOpen in pairs(self.data.activityIsOpenTab) do
                if activityIsOpen then
                    iconNum = iconNum + 1
                    local iconPath = string.format("image/ui/img/btn/btn_%4d.png", iconNumPathTab[panelIdx])
                    local iconSpri = createMixSprite(iconPath, nil, "image/icon/border/border_circle_02.png")
                    iconSpri:setChildTextureVisible(false)
                    iconSpri:setButtonBounce(false)
                    iconSpri:setPosition(iconWidth * 0.45 + iconWidth * (iconNum - 1), viewSize.height * 0.47)
                    layerColor:addChild(iconSpri)
                    iconSpri:setTag(panelIdx)
                    iconSpri:getChild():setLocalZOrder(-1)
                    iconSpri:setScale(0.95)
                    iconSpri:addTouchEventListener(iconTouchEvent)
                    self.data.btnIconTab[panelIdx] = iconSpri
                    local iconSize = iconSpri:getContentSize()
                    local alert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
                    alert:setPosition(iconSize.width * 0.4, iconSize.height * 0.4)
                    iconSpri:addChild(alert)
                    alert:setVisible(false)
                    self.data.activityAlertTab[panelIdx] = alert
                    if self.data.activityIsNoticeTab[panelIdx] then
                        alert:setVisible(true)
                    end

                    if panelIdx == self.data.currPanel then
                        iconSpri:setChildTextureVisible(true)
                        if not self.data.allNodeTab[panelIdx] then
                            self.data.createUIFuncTab[panelIdx](self)
                        end
                        self.data.activityAlertTab[panelIdx]:setVisible(false)
                    end
                end
            end
            return layerColor
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:addChild(getLayer())
        else
            cell:removeAllChildren()
            cell:addChild(getLayer())
        end
        return cell
    end
    local function numberOfCellsInTableView(table)
       return 1
    end
    local tableView = cc.TableView:create(viewSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView      
end

function ActivityCenterLayer:showPanel(node)
    node:setPosition(0, 0)
    node:setLocalZOrder(bgZOrder)
end

function ActivityCenterLayer:hidePanel(node)
    node:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)
    node:setLocalZOrder(-1)
end

function ActivityCenterLayer:finishActivity(panelIdx)
    self.data.activityIsOpenTab[panelIdx] = false
    self.data.allNodeTab[panelIdx]:removeFromParent()
    self.data.allNodeTab[panelIdx] = nil

    self.data.currPanel = CHECK_PANEL
    if not self.data.allNodeTab[self.data.currPanel] then
        self.data.createUIFuncTab[self.data.currPanel](self)
    end
    self.data.activityAlertTab[self.data.currPanel]:setVisible(false)
    self:showPanel(self.data.allNodeTab[self.data.currPanel])
    self.controls.iconView:reloadData()
end

--[[
    翻牌
]]
function ActivityCenterLayer:Collect()
    rpc:call("Activity.Collect", nil, function(event)
        if event.status == Exceptions.Nil then
            local result = event.result
            self.data.lastIdx = result.LightIdx + 1

            local isDelay = false -- 是否需要停留等待卡牌翻转到正面
            for k,v in pairs(self.data.cardAnimTab) do
                local isFront = v:isFront()
                if not isFront then
                    v:flipAction()
                    isDelay = true
                end
            end
            if isDelay then
                local delay = cc.DelayTime:create(0.5)
                self.controls.drawNode:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
                    self:playHeroAnimAction()
                end)))
            else
                self:playHeroAnimAction()
            end
            if not result.CollectStatus then
                self.data.isOver = true
                self.controls.btn_draw:setNorGLProgram(false)
                self.controls.btn_draw:setTouchEnable(false)
                return 
            end

            self.data.cardInfoTab = result.CollectStatus[1].CardMatrix
            self.data.nextFreeTime = result.CollectStatus[1].NextFreeTime
            self.data.dailyFreeUseCount = result.CollectStatus[1].DailyFreeUseCount
            self.data.nextPrice = result.CollectStatus[1].NextPrice
            self.controls.costGold:setString(self.data.nextPrice)
        else
            self.data.isCanDraw = true
        end
    end)
end

--[[
    套卡奖励
]]
function ActivityCenterLayer:activityDraw(setType)
    rpc:call("Activity.Draw", setType, function(event)
        if event.status == Exceptions.Nil then
            local result = event.result
            local setAnim = self.data.setAnimTab[setType]
            setAnim:setFinish()

            local isAllFinish = true
            for k,v in pairs(self.data.setAnimTab) do
                isAllFinish = v:isFinish()
                if not isAllFinish then
                    break
                end
            end
            if isAllFinish then
                if self.controls.scheduler_showTime then
                    scheduler:unscheduleScriptEntry(self.controls.scheduler_showTime)
                end
                self:finishActivity(DRAW_PANEL)
            end
            local alertShow = require("scene.main.ReceiveGoods").new(result, "image/ui/img/btn/btn_815.png")
            self:addChild(alertShow, btnZOrder)
        end
    end)
end

--[[
    每日签到
]]
function ActivityCenterLayer:DailyCheck(sender, isAddDay)
    rpc:call("Activity.DailyCheck", nil, function(event)
        local goodsInfo = event.result
        if event.status == Exceptions.Nil then
            sender:setGoodsInfo()
            if isAddDay then
                self.checkData.dailyInfo.CheckCount = self.checkData.dailyInfo.CheckCount + 1
                self.checkData.accInfo.CheckCount = self.checkData.accInfo.CheckCount + 1
            end
            self.checkControls.currMonthCheckCount:setString(self.checkData.dailyInfo.CheckCount.."次")
            self.checkControls.accCheckCount:setString(self.checkData.accInfo.CheckCount.."/"..self.checkData.accInfo.AwardsCount)
            self.checkControls.accCheckView:reloadData()

            self.checkData.dailyInfo.TodayStatus = FINISHSTATUS
            self.data.activityAlertTab[CHECK_PANEL]:setVisible(false)

            local alertShow = require("scene.main.ReceiveGoods").new({goodsInfo}, "image/ui/img/btn/btn_815.png")
            self:addChild(alertShow)
        end
    end)
end

--[[
    累积签到
]]
function ActivityCenterLayer:AccCheck()
    rpc:call("Activity.AccCheck", nil, function(event)
        if event.status == Exceptions.Nil then
            local getGoodsInfoTabs =event.result.AwardsList
            self.checkData.accInfo.AwardsList = event.result.NextInfo.AwardsList
            self.checkData.accInfo.CheckCount = event.result.NextInfo.CheckCount
            self.checkData.accInfo.AwardsCount = event.result.NextInfo.AwardsCount
            
            self.checkControls.accCheckView:reloadData()
            self.checkControls.accCheckCount:setString(self.checkData.accInfo.CheckCount.."/"..self.checkData.accInfo.AwardsCount)

            local alertShow = require("scene.main.ReceiveGoods").new(getGoodsInfoTabs, "image/ui/img/btn/btn_815.png")
            self:addChild(alertShow)
        end
    end)
end

return ActivityCenterLayer


