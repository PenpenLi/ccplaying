local HomeLayer = class("HomeLayer", BaseLayer)
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")
local HeroManager = require("tool.helper.HeroAction")
local BuildNode = require("scene.main.home.widget.BuildNode")

local scheduler = cc.Director:getInstance():getScheduler()

local buildZOrder = 2
local moveHeroZOrder = buildZOrder + 1
local topZOrder = moveHeroZOrder + 1

-- 星将移动方向标志
local StopMove = 1
local UpMove = StopMove + 1
local DownMove = UpMove + 1
local LeftMove = DownMove + 1
local RightMove = LeftMove + 1

local mapBgTab = {"image/ui/img/bg/bg_275.png", "image/ui/img/bg/bg_275.png", "image/ui/img/bg/bg_275.png"}
local Head_Texture_VIP = { "image/ui/img/bg/head.png", "image/ui/img/bg/head2.png", "image/ui/img/bg/head3.png" }

function HomeLayer:ctor(homeInfo, isOwn, avatarInfo)
    HomeLayer.super.ctor(self)

    self.data.homeInfoTabs = homeInfo
    self.data.isOwnHome = isOwn
    self.data.avatarInfo = avatarInfo
    self.data.isSyncing = false
    self.data.isLoot = false

    self:createUI()
    self:AvatarInfoUI()
    self:createBuild()
    self:addListener()

    self.data.buildTabs = {}
    self.data.moveHeroTab = {}
    self.data.isCreateMoveHero = false
    self.data.currHeroNum = 0
    self.data.totalHeroNum = 4

    self.data.playSpeedCount = 1
    self.data.showTime = scheduler:scheduleScriptFunc(handler(self, self.showTime), 0, false)

    if self.data.isOwnHome then
        GameCache.Avatar.homeInfo = {}
        local decorationInfo = homeInfo.Decoration
        local decorationConfig = BaseConfig.getHomeDecoration(decorationInfo.Level)
        GameCache.Avatar.homeInfo.atkHeroNum = decorationConfig.HeroNum
    else
        GameCache.Avatar.enemyHomeInfo = {}
        local decorationInfo = homeInfo.Decoration
        local decorationConfig = BaseConfig.getHomeDecoration(decorationInfo.Level)
        GameCache.Avatar.enemyHomeInfo.turretID = decorationConfig.Turret
        GameCache.Avatar.enemyHomeInfo.turretNum = decorationConfig.TurretNum
    end

end

function HomeLayer:onCleanup()
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
    scheduler:unscheduleScriptEntry(self.data.showTime)
    if self.data.exitTimeSchedule then
        scheduler:unscheduleScriptEntry(self.data.exitTimeSchedule)
    end
end

function HomeLayer:addListener()
    self.listeners = {}
    local listener = application:addEventListener(AppEvent.UI.Home.SyncHomeData, function(event)
        local result = event.data
        local touchEvent = result.TouchEvent
        local isSync = result.IsSync
        local callFunc = result.CallFunc
        if (touchEvent) and (not self.controls.tableView:isTouchMoved()) then
            touchEvent()
        end

        if isSync and (not self.data.isSyncing) then
            self.data.isSyncing = true
            rpc:call("Home.Info", nil, function (event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    CCLog("=========Sync===SUCCESS================")
                    self.data.isSyncing = false
                    local homeInfoTabs = event.result
                    local tempHomeInfo = {{}, homeInfoTabs.Decoration, homeInfoTabs.PillFactory, 
                                        homeInfoTabs.WoodFactory, homeInfoTabs.MetalFactory, homeInfoTabs.SoulFactory}
                    for i=1,6 do
                        local buildNode = self.data.buildTabs[i]
                        buildNode:updateBuildInfo(tempHomeInfo[i])
                        buildNode:updateBuild()
                        if buildNode:isSettleBuildPanel() then
                            buildNode:updatePanel()
                        end

                        local decorationInfo = homeInfoTabs.Decoration
                        local decorationConfig = BaseConfig.getHomeDecoration(decorationInfo.Level)
                        GameCache.Avatar.homeInfo.atkHeroNum = decorationConfig.HeroNum
                    end
                    if callFunc then
                        callFunc()
                    end
                end
            end) 
        end

        if self.data.isOwnHome then
            self.controls.wood:setString(Common.numConvert(GameCache.Avatar.Wood))
            self.controls.medal:setString(GameCache.Avatar.Medal)
        end
    end)
    table.insert(self.listeners, listener)
    listener = application:addEventListener(AppEvent.UI.Home.ExchangeBuild, function(event)
        local result = event.data
        local isBuild = result.IsExchangeBuild
        local figureID = result.FigureID
        local isBg = result.IsExchangeBg
        local backgroundID = result.BackgroundID

        if isBuild then
            self.data.buildTabs[CenterBuildPanel]:setExchangeBuild(figureID)
        end
        if isBg then
            rpc:call("Home.SetBackground", backgroundID, function (event)
                if event.status == Exceptions.Nil and event.result then
                    self.controls.bg:setTexture(mapBgTab[backgroundID])
                end
            end) 
        end
    end)
    table.insert(self.listeners, listener)
    listener = application:addEventListener(AppEvent.UI.Home.UpdateAvatar, function(event)
        local result = event.data
        local isAvatar = result.IsAvatar
        if isAvatar then
            if self.data.isOwnHome then
                self.controls.wood:setString(Common.numConvert(GameCache.Avatar.Wood))
                self.controls.medal:setString(Common.numConvert(GameCache.Avatar.Medal))
            else
                local enemyInfo = result.EnemyInfo
                self.data.avatarInfo = enemyInfo
                self.controls.wood:setString(Common.numConvert(self.data.avatarInfo.Wood))
                self.controls.pill:setString(Common.numConvert(self.data.avatarInfo.Pill))
                self.controls.coin:setString(Common.numConvert(self.data.avatarInfo.Coin))
                self.controls.soulNum:setString(self.data.avatarInfo.Soul)
            end
        end
    end)
    table.insert(self.listeners, listener)
    listener = application:addEventListener(AppEvent.UI.Home.IsLoot, function(event)
        local result = event.data
        self.data.isLoot = result.IsLoot
        if (not self.data.isLoot) and (self.data.exitTime < 1) then
            self:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                self:LootTimeFinish()
            end)}))
        end
    end)
    table.insert(self.listeners, listener)
end

function HomeLayer:createUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local bg1 = cc.Sprite:create("image/ui/img/bg/bg_283.png")
    self.controls.bg = cc.Sprite:create(mapBgTab[self.data.homeInfoTabs.Decoration.Figure])
    local bgSize = self.controls.bg:getContentSize()
    local voidNode = cc.ParallaxNode:create()
    voidNode:addChild(bg1, 1, cc.p(0.5,1), cc.p(bgSize.width * 0.5, bgSize.height))
    voidNode:addChild(self.controls.bg, 2, cc.p(1,1), cc.p(bgSize.width * 0.5, bgSize.height * 0.5 - 20))

    local viewSize = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
    local function cellSizeForTable(table,idx) 
        return viewSize.height,bgSize.width
    end
    local function tableCellAtIndex(table1, idx)
        local cell = table1:dequeueCell()
        local function getLayout()
            local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), bgSize.width, viewSize.height)
            layerColor:addChild(voidNode)
            return layerColor
        end
        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:addChild(getLayout())
        end
        return cell
    end
    local function numberOfCellsInTableView(table)
        return 1
    end
    self.controls.tableView = cc.TableView:create(viewSize)
    self.controls.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.controls.tableView:setDelegate()
    self.controls.tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self.controls.tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self.controls.tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.controls.tableView:reloadData()
    self:addChild(self.controls.tableView)
    self.controls.tableView:setOverRangePos(true)

    local ornament = cc.Sprite:create("image/ui/img/btn/btn_1100.png")
    ornament:setPosition(bgSize.width * 0.24, bgSize.height * 0.48)
    self.controls.bg:addChild(ornament, topZOrder)
    ornament = cc.Sprite:create("image/ui/img/btn/btn_1101.png")
    ornament:setPosition(bgSize.width * 0.85, bgSize.height * 0.66)
    self.controls.bg:addChild(ornament, topZOrder)
    ornament = cc.Sprite:create("image/ui/img/btn/btn_1102.png")
    ornament:setPosition(bgSize.width * 0.68, bgSize.height * 0.55)
    self.controls.bg:addChild(ornament, topZOrder)
    ornament = cc.Sprite:create("image/ui/img/btn/btn_1103.png")
    ornament:setPosition(bgSize.width * 0.958, bgSize.height * 0.806)
    self.controls.bg:addChild(ornament, topZOrder)
    ornament = cc.Sprite:create("image/ui/img/btn/btn_1104.png")
    ornament:setPosition(bgSize.width * 0.48, bgSize.height * 0.88)
    self.controls.bg:addChild(ornament, topZOrder)

    local back = createMixSprite("image/ui/img/btn/btn_1073.png")
    back:setPosition(back:getContentSize().width * 0.6, back:getContentSize().height * 0.6)
    self:addChild(back, topZOrder)
    back:addTouchEventListener(function( sender, eventType, inside )
        if (eventType == ccui.TouchEventType.ended) and inside then
            if self.data.isOwnHome then
                cc.Director:getInstance():popScene()
                GameCache.Avatar.homeInfo = nil
            else
                local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
                local runningScene = cc.Director:getInstance():getRunningScene()
                runningScene:addChild(swallowLayer, 100000)
                self:backOwnHome()
                GameCache.Avatar.enemyHomeInfo = nil
            end
        end
    end)

    local btn_selectEnemy = createMixSprite("image/ui/img/btn/btn_1072.png")
    btn_selectEnemy:setButtonBounce(false)
    btn_selectEnemy:setSwallowTouches(true)
    btn_selectEnemy:setPosition(SCREEN_WIDTH - 80, 80)
    self:addChild(btn_selectEnemy, topZOrder)
    btn_selectEnemy:addTouchEventListener(function( sender, eventType, inside )
        if (eventType == ccui.TouchEventType.ended) and inside then
            if Common.isCostMoney(1002, 1000) then
                local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
                local runningScene = cc.Director:getInstance():getRunningScene()
                runningScene:addChild(swallowLayer, 100000)
                self:selectLayer()
            end
        end
    end)
    local coinSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    coinSpri:setPosition(SCREEN_WIDTH - 110, 15)
    self:addChild(coinSpri, topZOrder)
    local coinCost = Common.finalFont("1000", 1, 1, 20, nil, 1)
    coinCost:setPosition(SCREEN_WIDTH - 60, 15)
    self:addChild(coinCost, topZOrder)

    if self.data.isOwnHome then
        back:setTexture("image/ui/img/btn/btn_1073.png")

        local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
        local size = pay:getContentSize()
        pay:setPosition(180, SCREEN_HEIGHT - 60)
        self:addChild(pay)

        local btn_search = createMixSprite("image/ui/img/btn/btn_1191.png")
        btn_search:setButtonBounce(false)
        btn_search:setSwallowTouches(true)
        btn_search:setPosition(SCREEN_WIDTH - 70, 190)
        self:addChild(btn_search, topZOrder)
        btn_search:addTouchEventListener(function( sender, eventType, inside )
            if (eventType == ccui.TouchEventType.ended) and inside then
                local runningScene = cc.Director:getInstance():getRunningScene()
                local searchLayer = self:searchUI()
                runningScene:addChild(searchLayer)
            end
        end)
        local btn_history = createMixSprite("image/ui/img/btn/btn_1070.png")
        btn_history:setButtonBounce(false)
        btn_history:setSwallowTouches(true)
        btn_history:setPosition(SCREEN_WIDTH - 70, 290)
        self:addChild(btn_history, topZOrder)
        btn_history:addTouchEventListener(function( sender, eventType, inside )
            if (eventType == ccui.TouchEventType.ended) and inside then
                rpc:call("Home.History", nil, function (event)
                    if event.status == Exceptions.Nil and event.result then
                        local recordLayer = require("scene.main.home.RecordLayer").new(event.result, function()
                            self.controls.historyAlert:setVisible(false)
                        end)
                        self:addChild(recordLayer, topZOrder)
                    end
                end)
            end
        end)
        self.controls.historyAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
        self.controls.historyAlert:setPosition(SCREEN_WIDTH - 40, 320)
        self:addChild(self.controls.historyAlert, topZOrder)
        self.controls.historyAlert:setVisible(self.data.homeInfoTabs.NewRecord)
    else
        back:setTexture("image/ui/img/btn/btn_1183.png")

        local shadeSpri = cc.Scale9Sprite:create("image/ui/img/btn/btn_1192.png")
        shadeSpri:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
        shadeSpri:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        self:addChild(shadeSpri, topZOrder)
        local fadeout = cc.FadeOut:create(0.5)
        local fadeout_reverse = fadeout:reverse()
        shadeSpri:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeout, fadeout_reverse)))
    end
end

function HomeLayer:AvatarInfoUI()
    local icon = createMixSprite("image/icon/border/head_bg.png",nil,Common.heroIconImgPath(self.data.avatarInfo.Icon))
    icon:setTouchEnable(false)
    icon:setPosition(81, SCREEN_HEIGHT-65)
    self:addChild(icon, topZOrder)
    
    local head_panel = cc.Sprite:create("image/ui/img/bg/head.png")
    head_panel:setPosition(75, SCREEN_HEIGHT-80)
    self:addChild(head_panel, topZOrder)

    local str = self.data.avatarInfo.Name
    local name = Common.systemFont(str, 1, 1, 18)
    name:setPosition(66,20)
    head_panel:addChild(name)
    self.controls.avatar_name = name

    local str = self.data.avatarInfo.Level
    local level = Common.finalFont(str, 1, 1, 20, nil, 1)
    level:setPosition(25,47)
    head_panel:addChild(level)

    -- if self.data.isOwnHome then
        local sprite_vip = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
        sprite_vip:setPosition(57,130)
        head_panel:addChild(sprite_vip)

        if self.data.avatarInfo.VIP < 15 then
            head_panel:setTexture(Head_Texture_VIP[math.floor(self.data.avatarInfo.VIP/5)+1])
        else
            head_panel:setTexture("image/ui/img/bg/head4.png")
        end

        local str = self.data.avatarInfo.VIP
        local viplevel = Common.finalFont(""..str, 1, 1, 20, cc.c3b(255,201,60),1)
        viplevel:setPosition(90,130)
        head_panel:addChild(viplevel)
        self.controls.avatar_viplevel = viplevel
    -- end

    local headWidth = head_panel:getContentSize().width
    local woodNum = createMixScale9Sprite("image/ui/img/bg/bg_01.png", nil, "image/ui/img/btn/btn_1109.png", cc.size(headWidth, 40))
    woodNum:setTouchEnable(false)
    woodNum:setChildPos(0.2, 0.5)
    woodNum:setPosition(95, head_panel:getPositionY() - head_panel:getContentSize().height * 0.8)
    self:addChild(woodNum, topZOrder)
    woodNum:getChild():setScale(0.5)
    self.controls.wood = Common.finalFont(Common.numConvert(self.data.avatarInfo.Wood), 1, 1, 22, nil, 1)
    self.controls.wood:setAdditionalKerning(-2)
    self.controls.wood:setPosition(15, 0)
    woodNum:addChild(self.controls.wood)

    if self.data.isOwnHome then
        local medalNum = createMixScale9Sprite("image/ui/img/bg/bg_01.png", nil, "image/ui/img/btn/btn_1061.png", cc.size(headWidth, 40))
        medalNum:setTouchEnable(false)
        medalNum:setChildPos(0.2, 0.5)
        medalNum:setPosition(95, head_panel:getPositionY() - head_panel:getContentSize().height * 1.2)
        self:addChild(medalNum, topZOrder)
        self.controls.medal = Common.finalFont(Common.numConvert(self.data.avatarInfo.Medal), 1, 1, 22, nil, 1)
        self.controls.medal:setAdditionalKerning(-2)
        self.controls.medal:setPosition(15, 0)
        medalNum:addChild(self.controls.medal)
    else
        local pillNum = createMixScale9Sprite("image/ui/img/bg/bg_01.png", nil, "image/ui/img/btn/btn_1236.png", cc.size(headWidth, 40))
        pillNum:setTouchEnable(false)
        pillNum:setChildPos(0.2, 0.5)
        pillNum:setPosition(95, head_panel:getPositionY() - head_panel:getContentSize().height * 1.2)
        self:addChild(pillNum, topZOrder)
        self.controls.pill = Common.finalFont(Common.numConvert(self.data.avatarInfo.Pill), 1, 1, 22, nil, 1)
        self.controls.pill:setAdditionalKerning(-2)
        self.controls.pill:setPosition(15, 0)
        pillNum:getChild():setScale(0.5)
        pillNum:addChild(self.controls.pill)

        local coinNum = createMixScale9Sprite("image/ui/img/bg/bg_01.png", nil, "image/ui/img/btn/btn_035.png", cc.size(headWidth, 40))
        coinNum:setTouchEnable(false)
        coinNum:setChildPos(0.2, 0.5)
        coinNum:setPosition(95, head_panel:getPositionY() - head_panel:getContentSize().height * 1.6)
        self:addChild(coinNum, topZOrder)

        self.controls.coin = Common.finalFont(Common.numConvert(self.data.avatarInfo.Coin), 1, 1, 22, nil, 1)
        self.controls.coin:setAdditionalKerning(-2)
        self.controls.coin:setPosition(15, 0)
        coinNum:addChild(self.controls.coin)

        local soulNum = createMixScale9Sprite("image/ui/img/bg/bg_01.png", nil, "image/ui/img/btn/btn_1347.png", cc.size(headWidth, 40))
        soulNum:setTouchEnable(false)
        soulNum:setChildPos(0.2, 0.5)
        soulNum:setPosition(95, head_panel:getPositionY() - head_panel:getContentSize().height * 2)
        self:addChild(soulNum, topZOrder)
        self.controls.soulNum = Common.finalFont(self.data.avatarInfo.Soul, 1, 1, 22, nil, 1)
        self.controls.soulNum:setAdditionalKerning(-2)
        self.controls.soulNum:setPosition(15, 0)
        soulNum:getChild():setScale(0.5)
        soulNum:addChild(self.controls.soulNum)
    end
    if not self.data.isOwnHome then
        rpc:call("Home.StartLoot", self.data.avatarInfo.RID, function (event)
            if event.status == Exceptions.Nil and event.result then
                self.data.homeID = event.result
            elseif event.status == Exceptions.EHomeInLootDef then
                application:showFlashNotice(self.data.avatarInfo.Name .. "正在被掠夺中!")
                return
            end
        end)

        local nameBG = cc.Sprite:create("image/ui/img/btn/btn_1116.png")
        nameBG:setPosition(SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.9)
        self:addChild(nameBG, topZOrder)
        nameBG:setOpacity(150)

        self.data.exitTime = 5 * 60
        local exitLab = Common.finalFont("掠夺倒计时: ", 1, 1, 20, cc.c3b(255,255,140), 1)
        exitLab:setPosition(nameBG:getContentSize().width * 0.42, nameBG:getContentSize().height * 0.5)
        nameBG:addChild(exitLab)
        local timeSpri = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
        timeSpri:setPosition(nameBG:getContentSize().width * 0.1, nameBG:getContentSize().height * 0.5)
        nameBG:addChild(timeSpri)
        local timeLab = Common.finalFont("", 1, 1, 22, cc.c3b(255,255,140), 1)
        timeLab:setAnchorPoint(0, 0.5)
        timeLab:setPosition(nameBG:getContentSize().width * 0.65, nameBG:getContentSize().height * 0.5)
        nameBG:addChild(timeLab)

        self.data.exitTimeSchedule = scheduler:scheduleScriptFunc(function()
            self.data.exitTime = self.data.exitTime - 1
            timeLab:setString(Common.timeFormat(self.data.exitTime))
            if self.data.exitTime < 10 then
                timeLab:setColor(cc.c3b(255, 0, 0))
                timeLab:playChangeAction()
            end
            application:dispatchCustomEvent(AppEvent.UI.Home.CountDown, {Time = self.data.exitTime})

            if self.data.exitTime < 1 then
                scheduler:unscheduleScriptEntry(self.data.exitTimeSchedule)
                if not self.data.isLoot then
                    self:LootTimeFinish()
                end
            end
        end, 1, false)
    end
end

function HomeLayer:createBuild()
    local bgSize = self.controls.bg:getContentSize()
    local buildPosTabs = {{bgSize.width * 0.24, bgSize.height * 0.6},
                    {bgSize.width * 0.46, bgSize.height * 0.48},
                    {bgSize.width * 0.17, bgSize.height * 0.26},
                    {bgSize.width * 0.44, bgSize.height * 0.12},
                    {bgSize.width * 0.8, bgSize.height * 0.3},
                    {bgSize.width * 0.65, bgSize.height * 0.62},}
    local node = cc.Node:create()
    self.controls.bg:addChild(node, topZOrder)
    for i=1,(#buildPosTabs) do
        local delay1 = cc.DelayTime:create((i - 1) * 0.15) 
        node:runAction(cc.Sequence:create(delay1, cc.CallFunc:create(function()
            local build = require("scene.main.home.widget.BuildNode").createNode(i, self.data.homeInfoTabs, self.data.isOwnHome, node)
            build:setPosition(buildPosTabs[i][1], buildPosTabs[i][2])
            self.controls.bg:addChild(build, buildZOrder)
            self.data.buildTabs[i] = build
            if not self.data.isOwnHome then
                build:setLootEnemyInfo(self.data.avatarInfo)
                build:setLootSession(self.data.homeID)
            end

            if i == 1 then
                Common.addTopSwallowLayer()
            end
            if i == (#buildPosTabs) then
                if self.data.isOwnHome then
                    self.data.isCreateMoveHero = true
                end
                local delayNode = cc.Node:create()
                self:addChild(delayNode)
                local delay = cc.DelayTime:create(0.5)
                local removeSelf = cc.RemoveSelf:create()
                local endFunc = cc.CallFunc:create(function()
                    Common.removeTopSwallowLayer()
                end)
                delayNode:runAction(cc.Sequence:create(delay, endFunc, removeSelf))
            end
        end)))
    end
end

function HomeLayer:selectLayer()
    local node = cc.Node:create()
    cc.Director:getInstance():setNotificationNode(node)

    local cloudAction = self:cloudAction(node)
    cloudAction.joinAction(function()
        cc.Director:getInstance():popScene()
        if not self.data.isOwnHome then
            rpc:call("Home.StopLoot", self.data.homeID, function (event)
                if event.status == Exceptions.Nil and event.result then
                end
            end)
        end
        local findNode = cc.Node:create()
        findNode:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        node:addChild(findNode)

        local find = cc.Sprite:create("image/ui/img/btn/btn_1202.png")
        find:setPosition(0, 50)
        findNode:addChild(find)
        local findLab = cc.Sprite:create("image/ui/img/btn/btn_1200.png")
        findLab:setPosition(0, -120)
        findNode:addChild(findLab)
        local pointer = cc.Sprite:create("image/ui/img/btn/btn_1201.png")
        pointer:setAnchorPoint(1, 0)
        pointer:setPosition(0, 50)
        findNode:addChild(pointer)

        local rotate = cc.RotateBy:create(1, 360)
        local seq = cc.Sequence:create(rotate)
        Common.playSound("audio/effect/home_search.mp3")
        pointer:runAction(cc.RepeatForever:create(seq))
        rpc:call("Home.Search", nil, function (event)
            if event.status == Exceptions.Nil and event.result then
                findNode:removeFromParent()
                findNode = nil

                local enemyHomeInfo = event.result
                local enemyInfo = enemyHomeInfo.EnemyBase      
                application:pushScene("main.home.HomeScene", enemyHomeInfo, false, enemyInfo) 
                cloudAction.exitAction()
            else
                rpc:call("Home.Info", nil, function (event)
                    if event.status == Exceptions.Nil and event.result then
                        local homeInfo = event.result
                        application:pushScene("main.home.HomeScene", homeInfo, true, GameCache.Avatar) 
                        cloudAction.exitAction()
                    end
                end)
            end
        end)
    end)
end

function HomeLayer:backOwnHome()
    rpc:call("Home.StopLoot", self.data.homeID, function (event)
        if event.status == Exceptions.Nil and event.result then
        end
    end)

    local node = cc.Node:create()
    cc.Director:getInstance():setNotificationNode(node)

    local cloudAction = self:cloudAction(node)
    cloudAction.joinAction(function()
        cc.Director:getInstance():popScene()
        rpc:call("Home.Info", nil, function (event)
            if event.status == Exceptions.Nil and event.result then
                local homeInfo = event.result
                application:pushScene("main.home.HomeScene", homeInfo, true, GameCache.Avatar) 
                cloudAction.exitAction()
            end
        end)
    end)
end

function HomeLayer:LootTimeFinish()
    application:showFlashNotice("掠夺时间到~!")
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(swallowLayer, 100000)
    self:backOwnHome()
end

function HomeLayer:searchUI()
    local searchNode = cc.Node:create()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    searchNode:addChild(swallowLayer)
    cc.Director:getInstance():setNotificationNode(searchNode)

    local cloudAction = self:cloudAction(searchNode)
    local showNode = cc.Node:create()
    searchNode:addChild(showNode, 1)

    local function joinEnemyHome(rid)
        showNode:removeFromParent()
        showNode = nil
        cc.Director:getInstance():popScene()
        rpc:call("Home.EnemyInfo", rid, function (event)
            if event.status == Exceptions.Nil and event.result then
                cc.Director:getInstance():setNotificationNode(nil)
                local homeInfo = event.result
                local enemyInfo = homeInfo.EnemyBase
                application:pushScene("main.home.HomeScene", homeInfo, false, enemyInfo)
            end
        end)
    end

    local function selectEnemy()
        local title = cc.Sprite:create("image/ui/img/btn/btn_1189.png")
        title:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.7)
        showNode:addChild(title)

        local shuoming = Common.finalFont("请输入对手名称进行搜索", 1, 1, 25, cc.c3b(84, 84, 84))
        shuoming:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.6)
        showNode:addChild(shuoming)

        local radar = cc.Sprite:create("image/ui/img/btn/btn_1190.png")
        radar:setPosition(SCREEN_WIDTH * 0.5 + 320, SCREEN_HEIGHT * 0.7 + 50)
        showNode:addChild(radar)
        local move = cc.MoveBy:create(1, cc.p(30, 20))
        local move_reverse = move:reverse()
        local seq = cc.Sequence:create(move, move_reverse)
        radar:runAction(cc.RepeatForever:create(seq))

        local priceNum = 100
        local moveTime = 0.3
        local inputNode = cc.Node:create()
        showNode:addChild(inputNode)
        inputNode:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.4)
        local backNode = cc.Node:create()
        showNode:addChild(backNode)
        backNode:setPosition(SCREEN_WIDTH * 0.5, -SCREEN_HEIGHT * 0.2)
        local enemyListNode = cc.Node:create()
        showNode:addChild(enemyListNode)
        enemyListNode:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)

        local inputBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_969.png")
        inputBg:setPosition(-100, 0)
        inputBg:setContentSize(cc.size(354, 85))
        inputNode:addChild(inputBg)
        local eb_uname = cc.EditBox:create(cc.size(300, 50), cc.Scale9Sprite:create())
        eb_uname:setPosition(-100, -5)
        eb_uname:setMaxLength(12)
        eb_uname:setFontColor(cc.c3b(255,255,255))
        eb_uname:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
        inputNode:addChild(eb_uname)

        local btn_select = createMixSprite("image/ui/img/btn/btn_831.png",nil, "image/ui/img/btn/btn_1188.png")
        btn_select:setButtonBounce(false)
        btn_select:setPosition(150, 0)
        inputNode:addChild(btn_select)
        btn_select:addTouchEventListener(function( sender, eventType, inside )
            if (eventType == ccui.TouchEventType.ended) and inside then
                if "" ~= eb_uname:getText() then
                    if GameCache.Avatar.Gold < 100 then
                        self:goldAlertPanel(searchNode)
                        return 
                    end

                    if GameCache.Avatar.Name == string.trim(eb_uname:getText()) then
                        self:showFlashNotice(showNode, "上仙，您不能自己搜索自己哟~")
                        return 
                    end

                    rpc:call("Home.SearchEx", eb_uname:getText(), function (event)
                        if event.status == Exceptions.ESearchResultEmpty then
                            self:showFlashNotice(showNode, "上仙，没有搜索您要的结果。请重新输入关键字再试~")
                            return 
                        end
                        if event.status == Exceptions.Nil then
                            local function createEnemyList()
                                for k,v in pairs(event.result) do
                                    local bgSize = cc.size(736, 75)
                                    local bg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1186.png")
                                    bg:setContentSize(bgSize)
                                    bg:setPosition(0, 80 - 80 * (k - 1))
                                    enemyListNode:addChild(bg)
                                    if (k % 2) == 0 then
                                        bg:setOpacity(0)
                                    end

                                    local headBg = cc.Sprite:create("image/icon/border/head_bg.png")
                                    headBg:setPosition(bgSize.width * 0.2, bgSize.height * 0.5)
                                    bg:addChild(headBg)
                                    headBg:setScale(0.6)
                                    local headPath =  string.format("image/icon/head/xj_%d.png", v.Icon)
                                    local headSpri = cc.Sprite:create(headPath)
                                    headSpri:setPosition(bgSize.width * 0.2, bgSize.height * 0.5)
                                    bg:addChild(headSpri)
                                    headSpri:setScale(0.6)
                                    local headBorder = cc.Sprite:create("image/icon/border/border_star_3.png")
                                    headBorder:setPosition(bgSize.width * 0.2, bgSize.height * 0.5)
                                    bg:addChild(headBorder)
                                    headBorder:setScale(0.6)

                                    local nameLab = Common.systemFont(v.Name.."(LV."..v.Level..")", 1, 1, 22, cc.c3b(0, 26, 50))
                                    nameLab:setPosition(bgSize.width * 0.48, bgSize.height * 0.5)
                                    bg:addChild(nameLab)

                                    local loot = createMixScale9Sprite("image/ui/img/btn/btn_818.png",nil, "image/ui/img/btn/btn_670.png", cc.size(120,60))
                                    loot:setCircleFont("掠夺", 1, 1, 25, cc.c3b(223, 184, 109), 1)
                                    loot:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
                                    loot:setChildPos(0.25, 0.5)
                                    loot:setFontPos(0.65, 0.5)
                                    loot:setPosition(bgSize.width * 0.8, bgSize.height * 0.5)
                                    bg:addChild(loot)
                                    loot:addTouchEventListener(function( sender, eventType, inside )
                                        if (eventType == ccui.TouchEventType.ended) and inside then
                                            if v.IsValid then
                                                self:showFlashNotice(showNode, "上仙，你要找的对手正在和别人激战呢，请稍后再试")
                                            else
                                                rpc:call("Home.StartLoot", self.data.avatarInfo.RID, function (event)
                                                    if event.status == Exceptions.Nil and event.result then
                                                        joinEnemyHome(v.RID)
                                                    elseif event.status == Exceptions.EHomeInLootDef then
                                                        self:showFlashNotice(showNode, (v.Name.. "正在被掠夺中!"))
                                                    end
                                                end)
                                            end
                                        end
                                    end)
                                end
                            end
                            createEnemyList()
                            enemyListNode:setScaleY(0)
                            inputNode:stopAllActions()
                            title:stopAllActions()
                            shuoming:stopAllActions()
                            local move1 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.85))
                            local move11 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.75))
                            local move12 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5 + 320, SCREEN_HEIGHT * 0.8 + 50))
                            local move2 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, -SCREEN_HEIGHT * 0.2))
                            local move21 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.2))
                            local scale1 = cc.ScaleTo:create(moveTime, 1, 1)
                            title:runAction(cc.Sequence:create(move1))
                            shuoming:runAction(cc.Sequence:create(move11, cc.CallFunc:create(function()
                                shuoming:setString("搜索结果")
                            end)))
                            radar:runAction(cc.Sequence:create(move12))
                            inputNode:runAction(cc.Sequence:create(move2))
                            backNode:runAction(cc.Sequence:create(move21))
                            enemyListNode:runAction(cc.Sequence:create(scale1))
                        end
                    end)
                else
                    self:showFlashNotice(showNode, "不能为空～")
                end
            end
        end)
        
        local btn_backSelect = createMixScale9Sprite("image/ui/img/btn/btn_831.png",nil, "image/ui/img/btn/btn_1187.png", cc.size(171, 65))
        btn_backSelect:setButtonBounce(false)
        backNode:addChild(btn_backSelect)
        btn_backSelect:addTouchEventListener(function( sender, eventType, inside )
            if (eventType == ccui.TouchEventType.ended) and inside then
                inputNode:stopAllActions()
                title:stopAllActions()
                shuoming:stopAllActions()
                local move1 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.7))
                local move11 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.6))
                local move12 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5 + 320, SCREEN_HEIGHT * 0.7 + 50))
                local move2 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.4))
                local move21 = cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, -SCREEN_HEIGHT * 0.2))
                local scale1 = cc.ScaleTo:create(moveTime, 1, 0)
                title:runAction(cc.Sequence:create(move1))
                shuoming:runAction(cc.Sequence:create(move11, cc.CallFunc:create(function()
                    shuoming:setString("请输入对手名称进行搜索")
                    for k,v in pairs(enemyListNode:getChildren()) do
                        v:removeFromParent()
                        v = nil
                    end
                end)))
                radar:runAction(cc.Sequence:create(move12))
                inputNode:runAction(cc.Sequence:create(move2))
                backNode:runAction(cc.Sequence:create(move21))
                enemyListNode:runAction(cc.Sequence:create(scale1))
            end
        end)
        local backDesc = Common.finalFont("提示:确定对手并进入其家园后才收取搜索费", 1, 1, 25, cc.c3b(84, 84, 84))
        backDesc:setPosition(0, -70)
        backNode:addChild(backDesc)

        local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        goldSpri:setPosition(265, -70)
        backNode:addChild(goldSpri)
        local price = Common.finalFont(priceNum, 1, 1, 25, nil, 1)
        price:setPosition(310, -70)
        backNode:addChild(price)

        local btn_back = createMixSprite("image/ui/img/btn/btn_1183.png")
        btn_back:setSwallowTouches(true)
        btn_back:setPosition(btn_back:getContentSize().width * 0.6, btn_back:getContentSize().height * 0.6)
        showNode:addChild(btn_back)
        btn_back:addTouchEventListener(function( sender, eventType, inside )
            if (eventType == ccui.TouchEventType.ended) and inside then
                showNode:removeFromParent()
                showNode = nil
                cloudAction.exitAction()
            end
        end)
    end

    cloudAction.joinAction(function()
        selectEnemy()
    end)

    return searchNode
end

-- 统一处理遮盖云的进入和退出动作
function HomeLayer:cloudAction(node)
    local t = {}
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    node:addChild(layer)
    local rightCloud1 = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    rightCloud1:setAnchorPoint(0, 0.5)
    rightCloud1:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT * 0.5)
    node:addChild(rightCloud1)
    rightCloud1:setOpacity(120)
    rightCloud1:setScaleY(1.5)
    local rightCloud = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    rightCloud:setAnchorPoint(0, 0.5)
    rightCloud:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT * 0.5)
    node:addChild(rightCloud)
    local leftCloud1 = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    leftCloud1:setAnchorPoint(1, 0.5)
    leftCloud1:setPosition(0, SCREEN_HEIGHT * 0.5)
    node:addChild(leftCloud1)
    leftCloud1:setOpacity(120)
    leftCloud1:setScaleY(1.5)
    local leftCloud = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    leftCloud:setAnchorPoint(1, 0.5)
    leftCloud:setPosition(0, SCREEN_HEIGHT * 0.5)
    node:addChild(leftCloud)
    
    local delayTime1 = 0.8
    local delayTime2 = 0.4
    t.joinAction = function(beginFunc)
        local moveDistance = 920
        local delay = cc.DelayTime:create(delayTime1 + 0.3)
        local delay1 = cc.DelayTime:create(delayTime2)
        local move1 = cc.MoveTo:create(delayTime1, cc.p(moveDistance, SCREEN_HEIGHT * 0.5))
        local move2 = cc.MoveTo:create(delayTime1, cc.p(SCREEN_WIDTH - moveDistance, SCREEN_HEIGHT * 0.5))
        local move11 = cc.MoveTo:create(delayTime1 - delayTime2, cc.p(moveDistance, SCREEN_HEIGHT * 0.5))
        local move22 = cc.MoveTo:create(delayTime1 - delayTime2, cc.p(SCREEN_WIDTH - moveDistance, SCREEN_HEIGHT * 0.5))
        local scale1 = cc.ScaleTo:create(delayTime1, 1, 1)
        local spawn1 = cc.Spawn:create(move1, scale1)
        local spawn2 = cc.Spawn:create(move2, scale1:clone())
        leftCloud1:runAction(cc.Sequence:create(spawn1))
        rightCloud1:runAction(cc.Sequence:create(spawn2))
        leftCloud:runAction(cc.Sequence:create(delay1, move11))
        rightCloud:runAction(cc.Sequence:create(delay1:clone(), move22))
        node:runAction(cc.Sequence:create(delay, cc.CallFunc:create(beginFunc)))
    end

    t.exitAction = function(endFunc)
        local move11 = cc.MoveTo:create(delayTime2, cc.p(0, SCREEN_HEIGHT * 0.5))
        local move22 = cc.MoveTo:create(delayTime2, cc.p(SCREEN_WIDTH, SCREEN_HEIGHT * 0.5))
        local move1 = cc.MoveTo:create(delayTime1, cc.p(0, SCREEN_HEIGHT * 0.5))
        local move2 = cc.MoveTo:create(delayTime1, cc.p(SCREEN_WIDTH, SCREEN_HEIGHT * 0.5))
                
        leftCloud1:runAction(cc.Sequence:create(move1, cc.CallFunc:create(function()
            local fadeout = cc.FadeOut:create(0.5)
            layer:runAction(cc.Sequence:create(fadeout, cc.CallFunc:create(function()
                node:removeFromParent()
                node = nil
                cc.Director:getInstance():setNotificationNode(nil)
                if endFunc then
                    endFunc()
                end
            end)))
        end)))
        rightCloud1:runAction(cc.Sequence:create(move2))
        leftCloud:runAction(cc.Sequence:create(move11))
        rightCloud:runAction(cc.Sequence:create(move22))
    end

    return t
end

local flashNoticeOffsetStack = {}
function HomeLayer:showFlashNotice(bgNode, text)
    local width = math.min(math.max(50 + utf8.len(text) * (26 + 2) + 50, 350), 560)
    local height = 40

    if #flashNoticeOffsetStack == 0 then
        local stackCount = 5
        for i = 1, stackCount do
            table.insert(flashNoticeOffsetStack, {used = false, offset = (stackCount - i) * height})
        end
    end

    local node = cc.Node:create()
    node:setPosition(SCREEN_WIDTH*0.5, 50)
    node:setAnchorPoint(0.5, 0.5)
    node:setColor(cc.c3b(200, 200, 200))
    node:setOpacity(50)
    node:setContentSize(width, height)
    bgNode:addChild(node)

    local bg = ccui.ImageView:create("image/ui/img/btn/btn_1134.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(width, height))
    bg:setAnchorPoint(0.5,0.5)
    bg:setPosition(width / 2, height / 2)
    node:addChild(bg)

    local label = ccui.Text:create()
    label:setTextAreaSize(cc.size(width, height))
    label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setFontSize(22)
    label:setText(text)
    label:setColor(cc.c3b(225, 247, 255))
    label:setPosition(width / 2, height / 2)
    label:setSize(cc.size(width, height))
    label:setAnchorPoint(0.5, 0.5)
    node:addChild(label)

    local offset = 0
    local offsetIndex = 0
    for idx, data in ipairs(flashNoticeOffsetStack) do
        if data.used == false then
            offsetIndex = idx
            offset = data.offset
        end
    end

    local pushOffset = cc.CallFunc:create(function()
        if offsetIndex > 0 and offsetIndex <= #flashNoticeOffsetStack then
            flashNoticeOffsetStack[offsetIndex].used = true
        end
    end)

    local moveTime = 0.4
    local delayTime = 0.6
    local outTime = 0.3
    local move = cc.EaseExponentialOut:create(cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5 + 50 - offset)))
    local delay = cc.DelayTime:create(moveTime + delayTime + outTime)
    local moveDelay = cc.DelayTime:create(moveTime + delayTime)
    local moveOut = cc.MoveBy:create(outTime, cc.p(0, 80))
    local fadeout = cc.FadeOut:create(outTime)
    local spaOut = cc.Spawn:create(moveOut, fadeout)
    local reomve = cc.RemoveSelf:create()
    local popOffset =  cc.CallFunc:create(function()
        if offsetIndex > 0 and offsetIndex <= #flashNoticeOffsetStack then
            flashNoticeOffsetStack[offsetIndex].used = false
        end
    end)

    local action = cc.Sequence:create({pushOffset, move, delay, reomve, popOffset})
    node:runAction(action)
    local seq = cc.Sequence:create(moveDelay, spaOut)
    bg:runAction(seq)
    label:runAction(seq:clone())
end

function HomeLayer:goldAlertPanel(bgNode)
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    bgNode:addChild(panel, 2)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    local desc = Common.finalFont("亲亲,元宝不够了哟～现在就去充值吗？", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.7)
    desc:setAnchorPoint(0.5, 1)
    panel:addChild(desc)

     local function buttonFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            bgNode:removeFromParent()
            bgNode = nil
            cc.Director:getInstance():setNotificationNode(nil)
            -- application:popScene()
            application:replaceScene("main.recharge.RechargeScene") 
        end
    end

    local sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(130, 56))
    sure:setButtonBounce(false)
    sure:setCircleFont("这就去充" , 1, 1, 25, cc.c3b(248, 216, 136))
    sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    sure:setPosition(panelSize.width * 0.5,panelSize.height * 0.28)
    panel:addChild(sure)
    sure:addTouchEventListener(buttonFunc)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            panel:removeFromParent()
            panel = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function HomeLayer:getHeroMoveData()
    local bgSize = self.controls.bg:getContentSize()
    local bgWidth = bgSize.width
    local bgHeight = bgSize.height
    -- 出发点和目的地点(顺序从左到右)
    local beginPos1 = {-bgWidth * 0.08, bgHeight * 0.48}
    local beginPos2 = {-bgWidth * 0.08, bgHeight * 0.08}
    local beginPos3 = {bgWidth * 0.16, -bgHeight * 0.12}
    local beginPos4 = {bgWidth, bgHeight * 0.76}
    local beginPos5 = {bgWidth * 1.08, bgHeight * 0.15}
    -- 需要转弯的点(顺序从左到右)
    local centerPos1 = {bgWidth * 0.07, bgHeight * 0.57}
    local centerPos2 = {bgWidth * 0.46, bgHeight * 0.412}
    local centerPos3 = {bgWidth * 0.76, bgHeight * 0.28}

    -- 主要包括移动到目的地的坐标和下一次移动的方向
    local allMoveTabs = {}
    local allMoveTab = {{dest = beginPos1, dir = UpMove}, 
                        {dest = centerPos1, dir = RightMove},
                        {dest = centerPos2, dir = UpMove},
                        {dest = beginPos4, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos1, dir = UpMove}, 
                        {dest = centerPos1, dir = RightMove},
                        {dest = centerPos2, dir = DownMove},
                        {dest = beginPos2, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos1, dir = UpMove}, 
                        {dest = centerPos1, dir = RightMove},
                        {dest = centerPos2, dir = RightMove},
                        {dest = centerPos3, dir = DownMove},
                        {dest = beginPos3, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos2, dir = UpMove}, 
                        {dest = centerPos2, dir = LeftMove},
                        {dest = centerPos1, dir = DownMove},
                        {dest = beginPos1, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos2, dir = UpMove}, 
                        {dest = centerPos2, dir = RightMove},
                        {dest = centerPos3, dir = RightMove},
                        {dest = beginPos5, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos3, dir = UpMove}, 
                        {dest = centerPos3, dir = LeftMove},
                        {dest = centerPos2, dir = UpMove},
                        {dest = beginPos4, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos3, dir = UpMove}, 
                        {dest = centerPos3, dir = LeftMove},
                        {dest = centerPos2, dir = LeftMove},
                        {dest = centerPos1, dir = DownMove},
                        {dest = beginPos1, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)
    allMoveTab = {{dest = beginPos3, dir = UpMove}, 
                        {dest = centerPos3, dir = LeftMove},
                        {dest = centerPos2, dir = DownMove},
                        {dest = beginPos2, dir = StopMove}}
    table.insert(allMoveTabs, allMoveTab)

    local randomIdx = math.random(1,8)
    return allMoveTabs[randomIdx]
end

function HomeLayer:createMoveHero(heroNode)
    local node = nil
    if not heroNode then
        node = cc.Node:create()
    else
        heroNode:removeAllChildren()
        node = heroNode
    end

    local moveCount = 1
    local moveSpeed = math.random(50,100)
    local moveInfo = self:getHeroMoveData()
    node:setPosition(moveInfo[moveCount].dest[1], moveInfo[moveCount].dest[2])

    -- 移动的星将需要进行筛选，从已得星将中随机出现
    local allHero = GameCache.GetAllHero()
    local randomID = math.random(1,GameCache.getHeroTotal())
    local player = nil
    local number = 0
    for k,heroInfo in pairs(allHero) do
        number = number + 1
        if number == randomID then
            player = HeroManager.new(0, 0, k)
            break
        end
    end
    player:setScale(0.5)
    player:setTouchEnabled(false)
    player:setAnimation(0,"move",true)
    player.animation:setMix("idle", "move", 0.2)
    node:addChild(player)

    node.moveFunc = function()
        local dir = moveInfo[moveCount].dir
        if dir == StopMove then
            self:createMoveHero(node)
            return 
        elseif (dir == LeftMove) or (dir == DownMove) then
            player:setRotationSkewY(180)
        elseif (dir == RightMove) or (dir == UpMove) then
            player:setRotationSkewY(0)
        end
        moveCount = moveCount + 1

        local moveX = math.abs(moveInfo[moveCount].dest[1] - moveInfo[moveCount - 1].dest[1])
        local moveY = math.abs(moveInfo[moveCount].dest[2] - moveInfo[moveCount - 1].dest[2])
        local moveTime = (moveX + moveY) / moveSpeed
        local move = cc.MoveTo:create(moveTime, cc.p(moveInfo[moveCount].dest[1], moveInfo[moveCount].dest[2]))
        local atkIdx = math.random(1,2)
        if atkIdx == 1 then
            player:setAnimation(0,"atk1",false)
            player:addAnimation(0,"idle",true)
            local delay = cc.DelayTime:create(math.random(3,6))
            local beginMoveFunc = cc.CallFunc:create(function()
                player:addAnimation(0,"move",true)
            end)
            node:runAction(cc.Sequence:create(delay, beginMoveFunc, move, cc.CallFunc:create(node.moveFunc)))
        else
            node:runAction(cc.Sequence:create(move, cc.CallFunc:create(node.moveFunc)))
        end
    end
    node:runAction(cc.Sequence:create(cc.CallFunc:create(node.moveFunc)))

    return node
end

function HomeLayer:showTime(dt)
    if tolua.isnull(self) then
        return
    end
    
    for k,v in pairs(self.data.buildTabs) do
        v:showTime(dt)
    end

    if self.data.isCreateMoveHero then
        if (self.data.playSpeedCount % 120) == 0 then
            local heroNode = self:createMoveHero()
            self.controls.bg:addChild(heroNode, moveHeroZOrder)
            table.insert(self.data.moveHeroTab, heroNode)

            self.data.currHeroNum = self.data.currHeroNum + 1
            if self.data.currHeroNum >= self.data.totalHeroNum then
                self.data.isCreateMoveHero = false
            end
        end
        self.data.playSpeedCount = self.data.playSpeedCount + 1
    end
end

function HomeLayer:onEnterTransitionFinish( )

    Common.OpenSystemLayer({8})
    HomeLayer.super.onEnterTransitionFinish(self)
end

return HomeLayer




