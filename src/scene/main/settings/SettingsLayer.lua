
local SettingsLayer = class("SettingsLayer", BaseLayer)

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

local BASICPANEL = 1
local MESSAGEPANEL = BASICPANEL + 1

local firstPowerOption = 1
local secondPowerOption = firstPowerOption + 1
local maxPowerOption = secondPowerOption + 1
local maxEnduranceOption = maxPowerOption + 1
local failJJCOption = maxEnduranceOption + 1
local failYBOption = failJJCOption + 1

function SettingsLayer:ctor()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    self:addChild(bgLayer)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(cc.size(576, 420))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    local bgSize = self.controls.bg:getContentSize()

    local timuBg = createMixScale9Sprite("image/ui/img/btn/btn_811.png", nil, "image/ui/img/btn/btn_810.png", cc.size(570, 50)) 
    timuBg:setTouchEnable(false)
    timuBg:setChildPos(0.5, 0)
    local child = timuBg:getChild()
    child:setScaleX(1.3)
    timuBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.9)
    self.controls.bg:addChild(timuBg, bgZOrder)

    local title = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_876.png")
    title:setTouchEnable(false)
    title:setPosition(bgSize.width * 0.5, bgSize.height * 0.98)
    self.controls.bg:addChild(title, bgZOrder)

    local huaBg = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huaBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    self.controls.bg:addChild(huaBg, bgZOrder)

    self.controls.tabBtns = {}
    function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.controls.tabBtns) do
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
            if name ==  "basic" then
                if self.data.currPanel ~= BASICPANEL then
                    self.controls.basicNode:setPosition(0, 0)
                    self.controls.messageNode:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)
                end
                self.data.currPanel = BASICPANEL
            elseif name == "message" then
                if self.data.currPanel ~= MESSAGEPANEL then
                    self.controls.messageNode:setPosition(0, 0)
                    self.controls.basicNode:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)
                end
                self.data.currPanel = MESSAGEPANEL
            end
        end
    end

    local btn_basic = createMixSprite("image/ui/img/btn/btn_642.png", "image/ui/img/btn/btn_641.png")
    btn_basic:setAnchorPoint(1, 0.5)
    btn_basic:setBgTouchAnchorPoint(1, 0.5)
    btn_basic:setTouchStatus()
    btn_basic:setCircleFont("基\n本" , 1, 1, 30, cc.c3b(253, 230, 154))
    btn_basic:setFontPos(0.2, 0.5)
    btn_basic:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
    btn_basic:setPosition(bgSize.width * 0.01, bgSize.height * 0.75)
    btn_basic:setName("basic")
    btn_basic:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_basic, btnZOrder)
    table.insert(self.controls.tabBtns , btn_basic)

    -- local btn_message = createMixSprite("image/ui/img/btn/btn_642.png", "image/ui/img/btn/btn_641.png")
    -- btn_message:setAnchorPoint(1, 0.5)
    -- btn_message:setBgTouchAnchorPoint(1, 0.5)
    -- btn_message:setCircleFont("推\n送" , 1, 1, 30, cc.c3b(177, 174, 170))
    -- btn_message:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
    -- btn_message:setFontPos(0.2, 0.5)
    -- btn_message:setPosition(bgSize.width * 0.01, bgSize.height * 0.45)
    -- btn_message:setName("message")
    -- btn_message:addTouchEventListener(btnTouchEvent)
    -- self.controls.bg:addChild(btn_message, btnZOrder)
    -- table.insert(self.controls.tabBtns , btn_message)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bgLayer)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgSize.width * 0.98, bgSize.height * 0.98)
    self.controls.bg:addChild(btn_close, btnZOrder)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
            self = nil
        end
    end)

    self:basic()
    self:message()
    self:initSettings()
end

function SettingsLayer:basic()
    local bgSize = self.controls.bg:getContentSize()
    self.controls.basicNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.basicNode, bgZOrder)

    local timuBg = createMixScale9Sprite("image/ui/img/btn/btn_811.png", nil, "image/ui/img/btn/btn_810.png", cc.size(570, 80)) 
    timuBg:setTouchEnable(false)
    timuBg:setChildPos(0.5, 1)
    local child = timuBg:getChild()
    child:setScaleX(1.3)
    timuBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.12)
    self.controls.basicNode:addChild(timuBg)

    if not GameCache.isExamine then
        btn_gift = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
        btn_gift:setCircleFont("礼包兑换", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        btn_gift:setFontOutline(cc.c3b(70, 50, 14), 1)
        btn_gift:setPosition(bgSize.width * 0.3, bgSize.height * 0.13)
        self.controls.basicNode:addChild(btn_gift)
        btn_gift:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local exchangeNode = self:exchangeUI()
                self:addChild(exchangeNode)
            end
        end)
    end

    btn_login = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
    btn_login:setCircleFont("注销登录", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_login:setFontOutline(cc.c3b(70, 50, 14), 1)
    btn_login:setPosition(bgSize.width * 0.7, bgSize.height * 0.13)
    self.controls.basicNode:addChild(btn_login)
    btn_login:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            RestartGame()
        end
    end)

    if GameCache.isExamine then
        btn_login:setPosition(bgSize.width * 0.5, bgSize.height * 0.13)
    end

    local viewSize = cc.size(520, 240)
    local layerSize = cc.size(viewSize.width, 390)
    local function cellSizeForTable(table,idx) 
        return layerSize.height,viewSize.width
    end
    local function tableCellAtIndex(tableView, idx)
        local cell = tableView:dequeueCell()
        
        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0), layerSize.width, layerSize.height)
            
            for i=1,3 do
                local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
                line:setPosition(layerSize.width * 0.5, layerSize.height - i * 95)
                layerColor:addChild(line)
            end

            local font = Common.finalFont("背景音乐", layerSize.width * 0.5, layerSize.height - 50, 25, nil, 1)
            layerColor:addChild(font)
            font = Common.finalFont("游戏音效", layerSize.width * 0.5, layerSize.height - 140, 25, nil, 1)
            layerColor:addChild(font)

            self.controls.musicIcon = createMixSprite("image/ui/img/btn/btn_879.png", nil, "image/ui/img/btn/btn_881.png")
            self.controls.musicIcon:setChildPos(1.5, 0.5)
            self.controls.musicIcon:setPosition(layerSize.width * 0.25, layerSize.height - 50)
            layerColor:addChild(self.controls.musicIcon)

            self.controls.soundIcon = createMixSprite("image/ui/img/btn/btn_880.png", nil, "image/ui/img/btn/btn_881.png")
            self.controls.soundIcon:setChildPos(1.5, 0.5)
            self.controls.soundIcon:setPosition(layerSize.width * 0.25, layerSize.height - 140)
            layerColor:addChild(self.controls.soundIcon)

            self.controls.musicOption = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
            self.controls.musicOption:setPosition(layerSize.width * 0.7, layerSize.height - 50)
            layerColor:addChild(self.controls.musicOption)
            self.controls.musicOption:setButtonBounce(false)
            self.controls.musicOption:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    BaseConfig.isPlayMusic = not BaseConfig.isPlayMusic
                    self:changeMusic(BaseConfig.isPlayMusic)
                end
            end)

            self.controls.soundOption = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
            self.controls.soundOption:setPosition(layerSize.width * 0.7, layerSize.height - 140)
            layerColor:addChild(self.controls.soundOption)
            self.controls.soundOption:setButtonBounce(false)
            self.controls.soundOption:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    BaseConfig.isPlaySound = not BaseConfig.isPlaySound
                    self:changeSound(BaseConfig.isPlaySound)
                end
            end)

            local cityPeopleDesc = Common.finalFont("主城人数", layerSize.width * 0.32, layerSize.height - 240, 25, nil, 1)
            layerColor:addChild(cityPeopleDesc)
            local performanceDesc = Common.finalFont("画面效果", layerSize.width * 0.32, layerSize.height - 330, 25, nil, 1)
            layerColor:addChild(performanceDesc)

            local function peopleTouchEvent(sender, eventType, isIn)
                if (eventType == ccui.TouchEventType.ended) and isIn and (not tableView:isTouchMoved()) then
                    local isMorePeople = cc.UserDefault:getInstance():getBoolForKey("morePeople")
                    local name = sender:getName()
                    if name == "多" then
                        if isMorePeople then
                            return
                        end
                    elseif not isMorePeople then
                        return
                    end

                    if isMorePeople then
                        self.controls.cityPeopleMore:setChildTextureVisible(false)
                        self.controls.cityPeopleLess:setChildTextureVisible(true)
                        cc.UserDefault:getInstance():setBoolForKey("morePeople", false)
                        BaseConfig.isShowOthers = false
                    else
                        self.controls.cityPeopleMore:setChildTextureVisible(true)
                        self.controls.cityPeopleLess:setChildTextureVisible(false)
                        cc.UserDefault:getInstance():setBoolForKey("morePeople", true)
                        BaseConfig.isShowOthers = true
                    end
                    application:dispatchCustomEvent(AppEvent.UI.MainLayer.RefreshOthers)
                    cc.UserDefault:getInstance():flush()
                end
            end

            self.controls.cityPeopleMore = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
            self.controls.cityPeopleMore:setPosition(layerSize.width * 0.5, layerSize.height - 240)
            self.controls.cityPeopleMore:setFont("多", 1, 1, 25, nil, 1)
            self.controls.cityPeopleMore:setFontPos(1.5, 0.5)
            layerColor:addChild(self.controls.cityPeopleMore)
            self.controls.cityPeopleMore:setButtonBounce(false)
            self.controls.cityPeopleMore:setName("多")
            self.controls.cityPeopleMore:addTouchEventListener(peopleTouchEvent)

            self.controls.cityPeopleLess = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
            self.controls.cityPeopleLess:setPosition(layerSize.width * 0.7, layerSize.height - 240)
            self.controls.cityPeopleLess:setFont("少", 1, 1, 25, nil, 1)
            self.controls.cityPeopleLess:setFontPos(1.5, 0.5)
            layerColor:addChild(self.controls.cityPeopleLess)
            self.controls.cityPeopleLess:setButtonBounce(false)
            self.controls.cityPeopleLess:setName("少")
            self.controls.cityPeopleLess:addTouchEventListener(peopleTouchEvent)

            local function performanceTouchEvent(sender, eventType, isIn)
                if (eventType == ccui.TouchEventType.ended) and isIn and (not tableView:isTouchMoved()) then
                    local isMorePerformance = cc.UserDefault:getInstance():getBoolForKey("morePerformance")
                    local name = sender:getName()
                    if name == "高" then
                        if isMorePerformance then
                            return
                        end
                    elseif not isMorePerformance then
                        return
                    end
                    if isMorePerformance then
                        self.controls.gamePerformanceMore:setChildTextureVisible(false)
                        self.controls.gamePerformanceLess:setChildTextureVisible(true)
                        cc.UserDefault:getInstance():setBoolForKey("morePerformance", false)
                    else
                        self.controls.gamePerformanceMore:setChildTextureVisible(true)
                        self.controls.gamePerformanceLess:setChildTextureVisible(false)
                        cc.UserDefault:getInstance():setBoolForKey("morePerformance", true)
                    end
                    cc.UserDefault:getInstance():flush()
                end
            end

            self.controls.gamePerformanceMore = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
            self.controls.gamePerformanceMore:setPosition(layerSize.width * 0.5, layerSize.height - 330)
            self.controls.gamePerformanceMore:setFont("高", 1, 1, 25, nil, 1)
            self.controls.gamePerformanceMore:setFontPos(1.5, 0.5)
            layerColor:addChild(self.controls.gamePerformanceMore)
            self.controls.gamePerformanceMore:setButtonBounce(false)
            self.controls.gamePerformanceMore:setName("高")
            self.controls.gamePerformanceMore:addTouchEventListener(performanceTouchEvent)

            self.controls.gamePerformanceLess = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
            self.controls.gamePerformanceLess:setPosition(layerSize.width * 0.7, layerSize.height - 330)
            self.controls.gamePerformanceLess:setFont("低", 1, 1, 25, nil, 1)
            self.controls.gamePerformanceLess:setFontPos(1.5, 0.5)
            layerColor:addChild(self.controls.gamePerformanceLess)
            self.controls.gamePerformanceLess:setButtonBounce(false)
            self.controls.gamePerformanceLess:setName("低")
            self.controls.gamePerformanceLess:addTouchEventListener(performanceTouchEvent)

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
    tableView:setPosition(28, 105)
    self.controls.basicNode:addChild(tableView)
end

function SettingsLayer:message()
    local bgSize = self.controls.bg:getContentSize()
    self.controls.messageNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.messageNode, bgZOrder)
    self.controls.messageNode:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)

    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(bgSize.width * 0.5, bgSize.height * 0.6)
    self.controls.messageNode:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(bgSize.width * 0.5, bgSize.height * 0.3)
    self.controls.messageNode:addChild(line)

    self.data.messageAllOptionTan = {}
    local fontDesc = {"12:00领体力", "18:00领体力", "体力恢复满", "耐力恢复满", "竞技场被击败", "取经被劫"}
    local function createOption(num, x, y)
        local font = Common.finalFont(fontDesc[num], x, y, 25, nil, 1)
        font:setAnchorPoint(0, 0.5)
        self.controls.messageNode:addChild(font)

        local option = createMixSprite("image/ui/img/btn/btn_877.png", nil, "image/ui/img/btn/btn_878.png")
        option.isShowChild = true
        option:setPosition(x + 200, y)
        self.controls.messageNode:addChild(option)
        option:setButtonBounce(false)
        option:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                sender.isShowChild = not sender.isShowChild
                sender:setChildTextureVisible(sender.isShowChild)
            end
        end)
    end

    for i=1,6 do
        createOption(i, bgSize.width * 0.08 + ((i - 1) % 2) * 270, bgSize.height * 0.7 - (math.floor((i - 1) / 2)) * 100)
    end
end

function SettingsLayer:initSettings()
    self:changeMusic(BaseConfig.isPlayMusic)
    self:changeSound(BaseConfig.isPlaySound)

    local isMorePeople = cc.UserDefault:getInstance():getBoolForKey("morePeople")
    if isMorePeople then
        self.controls.cityPeopleMore:setChildTextureVisible(true)
        self.controls.cityPeopleLess:setChildTextureVisible(false)
    else
        self.controls.cityPeopleMore:setChildTextureVisible(false)
        self.controls.cityPeopleLess:setChildTextureVisible(true)
    end

    local isMorePerformance = cc.UserDefault:getInstance():getBoolForKey("morePerformance")
    if isMorePerformance then
        self.controls.gamePerformanceMore:setChildTextureVisible(true)
        self.controls.gamePerformanceLess:setChildTextureVisible(false)
    else
        self.controls.gamePerformanceMore:setChildTextureVisible(false)
        self.controls.gamePerformanceLess:setChildTextureVisible(true)
    end
end

function SettingsLayer:changeMusic(isMusic)
    if isMusic then
        self.controls.musicIcon:setChildTexture("image/ui/img/btn/btn_881.png")
        self.controls.musicOption:setChildTextureVisible(true)
        if not AudioEngine.isMusicPlaying() then
            Common.playMusic("audio/music/background.mp3", true)
        end
    else
        self.controls.musicIcon:setChildTexture("image/ui/img/btn/btn_882.png")
        self.controls.musicOption:setChildTextureVisible(false)
        Common.stopBackgroundMusic("audio/music/background.mp3")
    end
    cc.UserDefault:getInstance():setBoolForKey("music", isMusic)
    cc.UserDefault:getInstance():flush()
end

function SettingsLayer:changeSound(isSound)
    if isSound then
        self.controls.soundIcon:setChildTexture("image/ui/img/btn/btn_881.png")
        self.controls.soundOption:setChildTextureVisible(true)
    else
        self.controls.soundIcon:setChildTexture("image/ui/img/btn/btn_882.png")
        self.controls.soundOption:setChildTextureVisible(false)
    end
    cc.UserDefault:getInstance():setBoolForKey("sound", isSound)
    cc.UserDefault:getInstance():flush()
end

function SettingsLayer:exchangeUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_175.png")
    bg:setContentSize(cc.size(600, 220))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local tishi = Common.finalFont("请输入礼包码:", 1, 1, 25, nil, 1)
    tishi:setAnchorPoint(0, 0.5)
    tishi:setPosition(bgSize.width * 0.05, bgSize.height * 0.8)
    bg:addChild(tishi, bgZOrder)

    local eb_exchange = cc.EditBox:create(cc.size(550, 40), cc.Scale9Sprite:create("image/ui/img/bg/bg_226.png"))
    eb_exchange:setPosition(bgSize.width * 0.5, bgSize.height * 0.6)
    eb_exchange:setFontSize(15)
    eb_exchange:setMaxLength(20)
    eb_exchange:setFontColor(cc.c3b(152, 165, 185))
    eb_exchange:setPlaceHolder("请输入礼包码进行验证")
    eb_exchange:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    bg:addChild(eb_exchange, bgZOrder)

    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, nil, cc.size(140, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(255, 219, 92), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(bgSize.width * 0.5, bgSize.height * 0.3)
    bg:addChild(btn_sure, bgZOrder)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local content = eb_exchange:getText()
            CCLog("============content===============", content)
        end
    end)

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

return SettingsLayer
