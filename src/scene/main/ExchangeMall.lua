local ExchangeMall = class("ExchangeMall", BaseLayer)
local CurrencyIcon = require("tool.helper.CurrencyIcon")
local ColorLabel = require("tool.helper.ColorLabel")
local scheduler = cc.Director:getInstance():getScheduler()

local Shop_type_store = BaseConfig.MALL_TYPE_STORE
local Shop_type_arena = BaseConfig.MALL_TYPE_ARENA
local Shop_type_equip_recycle = BaseConfig.MALL_TYPE_EQUIP_RECYCLE
local Shop_type_home = BaseConfig.MALL_TYPE_HOME
local Shop_type_consume = BaseConfig.MALL_TYPE_CONSUME
local Shop_type_league_devote = BaseConfig.MALL_TYPE_LEAGUE_DEVOTE

local EQUIPTYPE = 1

local SALEPROPSTYPE = 13

local OPENLEVEL_ARENA = 14
local OPENLEVEL_HOME = 18

local storeSpriTab = {[1001] = "image/ui/img/btn/btn_060.png", [1002] = "image/ui/img/btn/btn_035.png"}
local scoreSpriTab = {"image/ui/img/btn/btn_035.png", "image/ui/img/btn/btn_217.png", 
                        "image/ui/img/btn/btn_1121.png", "image/ui/img/btn/btn_1061.png", "image/ui/img/btn/btn_1373.png"}

local MoneyTypeGold = 1001
local MoneyTypeCoin = 1002

local RefreshPillID = 1168

local LayerTag = 1 
local LeftPanelTag = LayerTag + 1
local CenterPanelTag = LeftPanelTag + 1
local RightPanelTag = CenterPanelTag + 1
local ItemTag = RightPanelTag + 1
local NameTag = ItemTag + 1
local ScoreSpriTag = NameTag + 1
local ScoreTag = ScoreSpriTag + 1
local ButtonTag = ScoreTag + 1

local viewCellHeight = 230

function ExchangeMall:ctor(typeID, func, appointID)
    self.data.shopType = typeID
    self.data.func = func
    self.data.appointID = appointID
    self.data.subType = 1
    self.data.scoreName = ""
    self.data.allGoodsTabs = {}
    self.data.equipShopGoodsTabs = {}
    self.data.allViewTab = {}
    self.data.nextRefreshPriceTab = {}
    self.data.priceTypeTab = {}   

    self:updateCurrShopData(typeID)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(layer)

    local bgsize = cc.size(930,570)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setAnchorPoint(0.5,0)
    bg:setPosition(SCREEN_WIDTH*0.5, 20)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)
    self.controls.bg = bg

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(bgsize.width*0.6, bgsize.height*0.46)
    bg:addChild(huawen)

    local image_list = cc.Sprite:create("image/ui/img/bg/bg_236.png")
    image_list:setAnchorPoint(0.5,1)
    image_list:setPosition(bgsize.width*0.5, bgsize.height-14)
    bg:addChild(image_list)  

    local image_title = cc.Sprite:create("image/ui/img/bg/bg_234.png")
    image_title:setPosition(bgsize.width*0.5, bgsize.height)
    bg:addChild(image_title)

    local title = cc.Sprite:create("image/ui/img/btn/btn_1213.png")
    title:setPosition(bgsize.width*0.5+15, bgsize.height-5)
    bg:addChild(title)

    self.controls.refreshTimeLab = Common.finalFont("刷新时间:", 1, 1, 20)
    self.controls.refreshTimeLab:setPosition(360, 30)
    image_list:addChild(self.controls.refreshTimeLab)

    self.controls.refreshTime = Common.finalFont("",1,1,20,cc.c3b(151,255,74))
    self.controls.refreshTime:setPosition(450, 30)
    image_list:addChild(self.controls.refreshTime)

    self.controls.noticeLab = ColorLabel.new("", 20)
    self.controls.noticeLab:setPosition(430, 30)
    image_list:addChild(self.controls.noticeLab)
    self.controls.noticeLab:setString("[255,255,255]每消费[=][255,197,59]1元宝[=][255,255,255]获得[=][140,255,57]1消费积分[=]")
    self.controls.noticeLab:setVisible(false)

    local image_popular = cc.Scale9Sprite:create("image/ui/img/bg/bg_239.png")
    image_popular:setContentSize(cc.size(150, 50))
    image_popular:setPosition(140, 35)
    image_list:addChild(image_popular)

    self.controls.logo = cc.Sprite:create(scoreSpriTab[self.data.shopType])
    self.controls.logo:setPosition(40, 35)
    image_list:addChild(self.controls.logo)

    self.controls.num = Common.finalFont(Common.numConvert(self.data.score),1,1,26,cc.c3b(151,255,74))
    self.controls.num:setPosition(140, 35)
    image_list:addChild(self.controls.num)

    local line = cc.Sprite:create("image/ui/img/bg/bg_304.png")
    line:setPosition(230, 245)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/bg/bg_304.png")
    line:setPosition(864, 245)
    bg:addChild(line)

    self:receiveExchangeInfo()

    local clickLayer = Common.createClickLayer(SCREEN_WIDTH, bgsize.height * 0.8, 0, 20)
    bg:addChild(clickLayer, 1)

    local buttonList = self:createButtonList()
    buttonList:setPosition(-15, 28)
    bg:addChild(buttonList, 1)

    self:equipShopFiltrateNode()

    local updateProps = Common.finalFont("刷新券:",1,1,20)
    updateProps:setAdditionalKerning(-2)
    updateProps:setPosition(bgsize.width*0.66, bgsize.height * 0.9)
    bg:addChild(updateProps)
    self.controls.updatePropsNum = Common.finalFont("",1,1,20,cc.c3b(151,255,74))
    self.controls.updatePropsNum:setPosition(bgsize.width*0.72, bgsize.height * 0.9)
    bg:addChild(self.controls.updatePropsNum)

    self.controls.btn_refresh = createMixScale9Sprite("image/ui/img/btn/btn_818.png",nil, "image/ui/img/btn/btn_830.png", cc.size(140,60))  
    self.controls.btn_refresh:setPosition(bgsize.width*0.87, bgsize.height * 0.91)
    self.controls.btn_refresh:setCircleFont("刷新" , 1 , 1, 24, cc.c3b(223,183,109))
    self.controls.btn_refresh:setFontOutline(cc.c4b(70,50,14,255), 2)
    self.controls.btn_refresh:setChildPos(0.25, 0.5)
    self.controls.btn_refresh:setFontPos(0.65,0.5)
    bg:addChild(self.controls.btn_refresh, 1)  
    self.controls.btn_refresh:addTouchEventListener(function(sender, eventType, inside)
        local priceType = nil
        local refreshPrice = self:getRefreshPrice()

        if Shop_type_equip_recycle == self.data.shopType then
            priceType = self.data.priceTypeTab[self.data.shopType][self.data.subType]
        else
            priceType = self.data.priceTypeTab[self.data.shopType][1]
        end
        
        if eventType == ccui.TouchEventType.ended and inside then
            local refreshPill = GameCache.GetProps(RefreshPillID)
            if refreshPill then
                self:Refresh() 
            else
                if Common.isCostMoney(priceType, refreshPrice) then
                    self:alertPanel()
                else
                    local scoreName = self:getCurrScoreName(priceType)
                    application:showFlashNotice("亲,"..scoreName.."不足。需要"..refreshPrice..scoreName.."才能刷新哦~")
                end
            end
        end
    end)

    local btn_add = createMixSprite("image/ui/img/bg/add.png")
    btn_add:setButtonBounce(false)
    btn_add:setPosition(bgsize.width*0.28, bgsize.height * 0.91)
    bg:addChild(btn_add, 1)  
    btn_add:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended and inside then
            if Shop_type_store == self.data.shopType then
                local coinTree = require("scene.main.CoinTreeLayer").new(nil, function()
                    self.data.score = GameCache.Avatar.Coin
                    self.controls.num:setString(Common.numConvert(self.data.score))
                    self.data.allViewTab[self.data.shopType]:reloadData()
                end)
                coinTree:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(coinTree)
            else
                cc.Director:getInstance():popToRootScene()
                if Shop_type_arena == self.data.shopType then
                    if GameCache.Avatar.Level < OPENLEVEL_ARENA then
                        Common.openLevelDesc(OPENLEVEL_ARENA)
                        return
                    end
                    rpc:call("Arena.Info", nil, function (event)
                        if event.status == Exceptions.Nil and event.result ~= nil then
                            table.sort(event.result.List, function (a,b) return a.Rank < b.Rank end)
                            application:pushScene("main.coliseum.ColiseumScene", event.result)
                        end
                    end)
                elseif Shop_type_equip_recycle == self.data.shopType then
                    application:pushScene("main.equipRecycle.EquipRecycleScene")
                elseif Shop_type_home == self.data.shopType then
                    if GameCache.Avatar.Level < OPENLEVEL_HOME then
                        Common.openLevelDesc(OPENLEVEL_HOME)
                        return
                    end
                    rpc:call("Home.Info", nil, function (event)
                        if event.status == Exceptions.Nil and event.result ~= nil then
                            local homeInfo = event.result
                            application:pushScene("main.home.HomeScene", homeInfo, true, GameCache.Avatar) 
                        end
                    end) 
                elseif Shop_type_consume == self.data.shopType then
                    application:pushScene("main.recharge.RechargeScene") 
                end
                if self.data.func then
                    self.data.func()
                end
                self:removeFromParent()
                self = nil
            end
        end
    end)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width * 0.98, bgsize.height)
    bg:addChild(btn_close, 1)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.func then
                self.data.func()
            end
            self:removeFromParent()
            self = nil
        end
    end)  

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local startpos = bg:convertToNodeSpace(touch:getStartLocationInView())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        -- if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
        --     if self.data.func then
        --         self.data.func()
        --     end
        --     self:removeFromParent()
        --     self = nil
        -- end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function ExchangeMall:onEnter()
    for k,propsInfo in pairs(GameCache.GetAllProps()) do
        local config = BaseConfig.GetProps(propsInfo.ID)
        if 13 == config.type then
            self:salePanel()
            break
         end 
    end
end

function ExchangeMall:updateCurrShopData(typeID)
    self.data.shopType = typeID
    if typeID == Shop_type_arena then
        self.data.score = GameCache.Avatar.ArenaCredits
        self.data.scoreName = "竞技场积分"
    elseif typeID == Shop_type_equip_recycle then
        self.data.score = GameCache.Avatar.EquipToken
        self.data.scoreName = "魂玉"
    elseif typeID == Shop_type_home then
        self.data.score = GameCache.Avatar.Medal
        self.data.scoreName = "勋章"
    elseif typeID == Shop_type_league_devote then
        self.data.score = GameCache.Avatar.LeagueDevote
    elseif typeID == Shop_type_store then
        self.data.score = GameCache.Avatar.Coin
        self.data.scoreName = "银币"
    elseif typeID == Shop_type_consume then
        self.data.score = GameCache.Avatar.CostCredits
        self.data.scoreName = "消费积分"
    end

    if self.controls.logo then
        self.controls.logo:setTexture(scoreSpriTab[self.data.shopType])
    end
    if self.controls.num then
        self.controls.num:setString(Common.numConvert(self.data.score))
    end
end

function ExchangeMall:getCurrScore(moneyType)
    if Shop_type_store == self.data.shopType then
        if MoneyTypeGold == moneyType then
            return GameCache.Avatar.Gold
        elseif MoneyTypeCoin == moneyType then
            return GameCache.Avatar.Coin
        end
    else
        return self.data.score
    end
end

function ExchangeMall:getCurrScoreName(moneyType)
    if Shop_type_store == self.data.shopType then
        if MoneyTypeGold == moneyType then
            return "元宝"
        elseif MoneyTypeCoin == moneyType then
            return "银币"
        end
    else
        return self.data.scoreName
    end
end

function ExchangeMall:filtrateEquipButton(tag)
    self.data.subType = tag
    for k,v in pairs(self.data.equipShopBtnTab) do
        if tag == v:getTag() then
            v:setTouchStatus()
            v:setFontColor(cc.c3b(253, 230, 154))
            v:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
        else
            v:setNormalStatus()
            v:setFontColor(cc.c3b(177, 174, 170))
            v:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
        end
    end

    self.data.equipShopGoodsTabs = {}
    for k,goodsInfo in pairs(self.data.allGoodsTabs[self.data.shopType]) do
        local equipConfig = BaseConfig.GetEquip(goodsInfo.ID, goodsInfo.StarLevel)
        if equipConfig and tag == equipConfig.type then
            table.insert(self.data.equipShopGoodsTabs, goodsInfo)
        end
    end
    for k,goodsInfo in pairs(self.data.equipShopGoodsTabs) do
        goodsInfo.Idx = k - 1
    end
    self.data.allViewTab[self.data.shopType]:reloadData()
end

function ExchangeMall:equipShopFiltrateNode()
    self.controls.equipShopNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.equipShopNode)
    local bgSize = self.controls.bg:getContentSize()

    local function btnTouchEvent(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended and inside then
            local tag = sender:getTag()
            self:filtrateEquipButton(tag)
        end
    end

    self.data.equipShopBtnTab = {}
    local titleTab = {"武\n器", "头\n盔", "戒\n指", "衣\n服"}
    for i=1,4 do
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png",nil, cc.size(100, 60))
        btn:setRotation(90)
        btn:setAnchorPoint(0.5, 0)
        btn:setBgTouchAnchorPoint(0.5, 0)
        btn:setCircleFont(titleTab[i], 1, 1, 25, cc.c3b(177, 174, 170))
        btn:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
        btn:setFontPos(0.5, 0.9)
        btn:getFont():setRotation(-90)
        btn:setPosition(bgSize.width * 0.935, bgSize.height * 0.72 - (i - 1) * 100)
        btn:setTag(i)
        btn:addTouchEventListener(btnTouchEvent)
        self.controls.equipShopNode:addChild(btn)
        table.insert(self.data.equipShopBtnTab , btn)
    end

    if Shop_type_equip_recycle == self.data.shopType then
        self.controls.equipShopNode:setPosition(0, 0)
        for k,v in pairs(self.data.equipShopBtnTab) do
            v:setNormalStatus()
            v:setFontColor(cc.c3b(177, 174, 170))
            v:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
        end
    else
        self.controls.equipShopNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
    end
end

function ExchangeMall:createButtonList()
    local viewSize = cc.size(260, 440)
    local layoutHeight = viewSize.height + 50
    local function cellSizeForTable(table,idx) 
        return layoutHeight,viewSize.width
    end
    local function tableCellAtIndex(tableView, idx)
        local cell = tableView:dequeueCell()
        
        local bgSize = self.data.bgSize

        self.data.btnIconTab = {}
        local nameTab = {"便利店", "装备商店", "竞技场商店", "功勋商店", "消费积分"}
        local logoInfo = {{ID = 1002}, {ID = 1006}, {ID = 1003}, {ID = 1010}, {ID = 1012}}

        local function getLayer()
            local function iconTouchEvent(sender, eventType)
                if (eventType == ccui.TouchEventType.ended) and (not tableView:isTouchMoved()) then
                    local tag = sender:getTag()
                    if self.data.shopType == tag then
                        return
                    end

                    if Shop_type_arena == tag then
                        if GameCache.Avatar.Level < OPENLEVEL_ARENA then
                            Common.openLevelDesc(OPENLEVEL_ARENA)
                            return
                        end
                    elseif Shop_type_home == tag then
                        if GameCache.Avatar.Level < OPENLEVEL_HOME then
                            Common.openLevelDesc(OPENLEVEL_HOME)
                            return
                        end
                    end

                    for k,v in pairs(self.data.btnIconTab) do
                        v:setNormalStatus()
                        v:setFontColor(cc.c3b(177, 174, 170))
                        v:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
                    end
                    for k,v in pairs(self.data.allViewTab) do
                        v:setScale(0)
                    end

                    self.controls.refreshTimeLab:setVisible(true)
                    self.controls.refreshTime:setVisible(true)
                    self.controls.noticeLab:setVisible(false)
                    self.controls.btn_refresh:setVisible(true)
                    self.controls.btn_refresh:setTouchEnable(true)
                    if Shop_type_consume == tag then
                        self.controls.refreshTimeLab:setVisible(false)
                        self.controls.refreshTime:setVisible(false)
                        self.controls.noticeLab:setVisible(true)
                        self.controls.btn_refresh:setVisible(false)
                        self.controls.btn_refresh:setTouchEnable(false)
                    end
                    
                    for k,v in pairs(self.data.btnIconTab) do
                        if tag == v:getTag() then
                            v:setTouchStatus()
                            v:setFontColor(cc.c3b(253, 230, 154))
                            v:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
                            
                            self:updateCurrShopData(tag)

                            if not self.data.allViewTab[self.data.shopType] then
                                self:receiveExchangeInfo()
                            else
                                self.data.allViewTab[self.data.shopType]:setScale(1)
                                self.data.equipShopGoodsTabs = {}
                                if Shop_type_equip_recycle == self.data.shopType then
                                    for k,goodsInfo in pairs(self.data.allGoodsTabs[self.data.shopType]) do
                                        local equipConfig = BaseConfig.GetEquip(goodsInfo.ID, goodsInfo.StarLevel)
                                        if equipConfig and EQUIPTYPE == equipConfig.type then
                                            table.insert(self.data.equipShopGoodsTabs, goodsInfo)
                                        end
                                    end
                                    for k,v in pairs(self.data.equipShopBtnTab) do
                                        v:setNormalStatus()
                                        v:setFontColor(cc.c3b(177, 174, 170))
                                        v:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
                                        if 1 == k then
                                            v:setTouchStatus()
                                            v:setFontColor(cc.c3b(253, 230, 154))
                                            v:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
                                        end
                                    end
                                end
                                self.data.allViewTab[self.data.shopType]:reloadData()
                            end
                            
                        end
                    end

                    if Shop_type_equip_recycle == self.data.shopType then
                        self.controls.equipShopNode:setPosition(0, 0)
                    else
                        self.controls.equipShopNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                    end
                end
            end
            
            local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), viewSize.width, viewSize.height)
            for i=1,5 do
                local btn = createMixSprite("image/ui/img/btn/btn_1283.png", "image/ui/img/btn/btn_1284.png")
                btn:setBgTouchAnchorPoint(0.48, 0.5)
                btn:setPosition(viewSize.width * 0.5, layoutHeight - 45 - (i - 1) * 100)
                layerColor:addChild(btn)
                btn:setTag(i)
                btn:setButtonBounce(false)
                btn:setFont(nameTab[i], 1, 1, 25, cc.c3b(177, 174, 170), 1)
                btn:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
                btn:setFontPos(0.64, 0.5)
                btn:getFont():setAdditionalKerning(-2)
                table.insert(self.data.btnIconTab, btn)
                btn:addTouchEventListener(iconTouchEvent)

                local logo = CurrencyIcon.new(logoInfo[i], BaseConfig.GOODS_SMALLTYPE)
                logo:setPosition(-72, 0)
                btn:addChild(logo)

                if i == self.data.shopType then
                    btn:setTouchStatus()
                    btn:setFontColor(cc.c3b(253, 230, 154))
                    btn:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
                end
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
    -- tableView:setTouchEnabled(false)
    return tableView  
end

function ExchangeMall:updatePanel(panel, goodsInfo)
    if not goodsInfo.IsFixed then
        panel:setTexture("image/ui/img/bg/bg_237.png")
    else
        panel:setTexture("image/ui/img/bg/bg_238.png")
    end

    local panelSize = panel:getContentSize()
    local icon = panel:getChildByTag(ItemTag)
    if icon then
        icon:removeFromParent()
        icon = nil
    end
    icon = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_MIDDLETYPE)
    icon:setTag(ItemTag)
    icon:setPosition(panelSize.width * 0.5, panelSize.height*0.61)
    panel:addChild(icon)

    local str = Common.getGoodsDesc({goodsInfo},"")
    local _1, _2 = string.find(str, "%l") 
    str = string.sub(str, 1, _1 - 2)
    panel:getChildByTag(NameTag):setString(str)

    local scoreSpri = panel:getChildByTag(ScoreSpriTag)
    if Shop_type_store == self.data.shopType then
        if MoneyTypeGold == goodsInfo.MoneyType then
            scoreSpri:setTexture("image/ui/img/btn/btn_060.png")
        elseif  MoneyTypeCoin == goodsInfo.MoneyType then
            scoreSpri:setTexture("image/ui/img/btn/btn_035.png")
        end
    end

    local score = panel:getChildByTag(ScoreTag)
    score:setString(goodsInfo.Price * goodsInfo.Num)

    local currScore = self:getCurrScore(goodsInfo.MoneyType)
    local btn = panel:getChildByTag(ButtonTag)
    btn:setScale(1)
    if goodsInfo.IsExchanged then
        btn:setNorGLProgram(false)
    elseif (currScore < (goodsInfo.Price * goodsInfo.Num)) then
        btn:setNorGLProgram(false)
    else
        btn:setNorGLProgram(true)
    end
    btn:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            currScore = self:getCurrScore(goodsInfo.MoneyType)
            if currScore >= (goodsInfo.Price * goodsInfo.Num) then
                if not goodsInfo.IsExchanged then
                    self:Exchange(panel, goodsInfo)
                else
                    application:showFlashNotice("该物品已兑换~")
                end
            else
                local scoreName = self:getCurrScoreName(goodsInfo.MoneyType)
                application:showFlashNotice("亲,"..scoreName.."不足。需要"..(goodsInfo.Price * goodsInfo.Num)..scoreName.."才能兑换哦~")
            end
        end
    end)
end

function ExchangeMall:createExchangeList()
    local bgSize = self.controls.bg:getContentSize()
    local ccSize = cc.size(bgSize.width * 0.66, bgSize.height * 0.8)
    
    local function scrollViewDidScroll(view)
    end
    local function scrollViewDidZoom(view)
    end
    local function tableCellTouched(table,cell)
        CCLog("cell touched at index: ",cell:getIdx())
    end
    local function cellSizeForTable(table,idx) 
        return viewCellHeight,ccSize.width
    end

    local function tableCellAtIndex(table, idx)
        
        local cell = table:dequeueCell()

        local function createPanel(panel)
            local panelSize = panel:getContentSize()
            local name = Common.finalFont("",1,1, 20)
            name:setTag(NameTag)
            name:setPosition(panelSize.width * 0.5, panelSize.height * 0.32)
            panel:addChild(name)

            local costpopu = cc.Sprite:create(scoreSpriTab[self.data.shopType])
            costpopu:setTag(ScoreSpriTag)
            costpopu:setPosition(panelSize.width * 0.34, panelSize.height * 0.9)
            panel:addChild(costpopu)
            if self.data.shopType == Shop_type_equip_recycle then
                costpopu:setScale(0.75)
            end

            local costpopu = Common.finalFont("999", 1, 1, 18, cc.c3b(151,255,74))
            costpopu:setTag(ScoreTag)
            costpopu:setPosition(panelSize.width * 0.59, panelSize.height * 0.91)
            panel:addChild(costpopu)

            local btn_exchange = createMixSprite("image/ui/img/btn/btn_818.png")
            btn_exchange:setTag(ButtonTag)
            btn_exchange:setButtonBounce(false)
            btn_exchange:setCircleFont("兑换", 1, 1, 26, cc.c3b(223,184,109))
            btn_exchange:setPosition(panelSize.width * 0.5, panelSize.height * 0.09)
            panel:addChild(btn_exchange)

        end

        local function getLayout()
            local layerColor = cc.LayerColor:create(cc.c4b(255,0,0,0), ccSize.width, viewCellHeight)
            layerColor:setTag(LayerTag)
            local layerSize = layerColor:getContentSize()

            local leftPanel = cc.Sprite:create("image/ui/img/bg/bg_237.png")
            leftPanel:setTag(LeftPanelTag)
            layerColor:addChild(leftPanel)
            leftPanel:setPosition(layerSize.width * 0.16, layerSize.height * 0.5)
            createPanel(leftPanel)
            local centerPanel = cc.Sprite:create("image/ui/img/bg/bg_237.png")
            centerPanel:setTag(CenterPanelTag)
            layerColor:addChild(centerPanel)
            centerPanel:setPosition(layerSize.width * 0.5, layerSize.height * 0.5)
            createPanel(centerPanel)
            local rightPanel = cc.Sprite:create("image/ui/img/bg/bg_238.png")
            rightPanel:setTag(RightPanelTag)
            layerColor:addChild(rightPanel)
            rightPanel:setPosition(layerSize.width * 0.84, layerSize.height * 0.5)
            createPanel(rightPanel)
            
            return layerColor
        end

        local layerColor = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            layerColor = getLayout()
            cell:addChild(layerColor)
        else
            layerColor = cell:getChildByTag(LayerTag)
        end

        local goodsTabs = nil
        if Shop_type_equip_recycle == self.data.shopType then
            goodsTabs = self.data.equipShopGoodsTabs
        else
            goodsTabs = self.data.allGoodsTabs[self.data.shopType]
        end
        for i= 3 * idx + 1, 3 * (idx + 1) do
            if i <= (#goodsTabs) then
                local panel = nil
                if (i%3) == 1 then
                    panel = layerColor:getChildByTag(LeftPanelTag)
                elseif (i%3) == 2 then
                    panel = layerColor:getChildByTag(CenterPanelTag)
                elseif (i%3) == 0 then
                    panel = layerColor:getChildByTag(RightPanelTag)
                end
                panel:setScale(1)
                self:updatePanel(panel, goodsTabs[i])
            else
                local panel = nil
                if (i%3) == 2 then
                    panel = layerColor:getChildByTag(CenterPanelTag)
                elseif (i%3) == 0 then
                    panel = layerColor:getChildByTag(RightPanelTag)
                end
                panel:setScale(0)
            end
        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        if Shop_type_equip_recycle == self.data.shopType then
            return math.ceil((#self.data.equipShopGoodsTabs) / 3)
        else
            return math.ceil((#self.data.allGoodsTabs[self.data.shopType]) / 3)
        end
    end

    local exchangeList = cc.TableView:create(ccSize)
    exchangeList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    exchangeList:setDelegate()
    exchangeList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    exchangeList:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    exchangeList:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    exchangeList:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    exchangeList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    exchangeList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    exchangeList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    exchangeList:reloadData()
    self.controls.bg:addChild(exchangeList)
    exchangeList:setPosition(245, 22)

    return exchangeList
end

function ExchangeMall:alertPanel()
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 300))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/btn/btn_608.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.92)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    dian:setPosition(panelSize.width * 0.3, panelSize.height * 0.92)
    panel:addChild(dian)
    dian = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    dian:setPosition(panelSize.width * 0.7, panelSize.height * 0.92)
    panel:addChild(dian)
    dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.92)
    panel:addChild(dian)

    local desc = Common.finalFont("你是否花费以下".."元宝".."进行刷新?", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.75)
    desc:setAnchorPoint(0.5, 1)
    panel:addChild(desc)

    -- local scorePath = nil
    -- if Shop_type_store == self.data.shopType then
    --     scorePath = storeSpriTab[self.data.priceTypeTab[self.data.shopType][1]]
    -- else
    --     scorePath = scoreSpriTab[self.data.shopType]
    -- end

    local priceSpri = createMixSprite("image/ui/img/btn/btn_060.png")
    priceSpri:setTouchEnable(false)
    priceSpri:setCircleFont(self:getRefreshPrice(), 1, 1, 18, nil, 1)
    priceSpri:setFontPos(1.8, 0.5)
    priceSpri:setPosition(panelSize.width * 0.45, panelSize.height * 0.55)
    panel:addChild(priceSpri)

    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.28)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:Refresh() 
            panel:removeFromParent()
            panel = nil
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
            panel:removeFromParent()
            panel = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(panel)
end

function ExchangeMall:salePanel()
    local saleNode = cc.Node:create()

    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 200), SCREEN_WIDTH, SCREEN_HEIGHT)
    saleNode:addChild(layer)

    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 400))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    saleNode:addChild(panel)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/btn/btn_608.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.92)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    dian:setPosition(panelSize.width * 0.3, panelSize.height * 0.92)
    panel:addChild(dian)
    dian = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    dian:setPosition(panelSize.width * 0.7, panelSize.height * 0.92)
    panel:addChild(dian)
    dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.92)
    panel:addChild(dian)

    local desc1 = Common.finalFont("亲,是否将下面这些卖钱道具卖给商人?", 1, 1, 20, nil, 1)
    desc1:setPosition(panelSize.width * 0.5, panelSize.height * 0.78)
    panel:addChild(desc1)

    local itemBg = cc.Sprite:create("image/ui/img/bg/bg_261.png")
    itemBg:setPosition(panelSize.width * 0.5, panelSize.height * 0.55)
    panel:addChild(itemBg)

    local desc2 = Common.finalFont("预计可获得", 1, 1, 20, nil, 1)
    desc2:setPosition(panelSize.width * 0.35, panelSize.height * 0.32)
    panel:addChild(desc2)
    local coinSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    coinSpri:setPosition(panelSize.width * 0.5, panelSize.height * 0.32)
    panel:addChild(coinSpri)
    coinSpri:setState(2)
    local coin = Common.finalFont("", 1, 1, 20, nil, 1)
    coin:setPosition(panelSize.width * 0.66, panelSize.height * 0.32)
    panel:addChild(coin)

    local saleCoin = 0
    local salePropsTabs = {}
    for k,propsInfo in pairs(GameCache.GetAllProps()) do
        local config = BaseConfig.GetProps(propsInfo.ID)
        if SALEPROPSTYPE == config.type then
            saleCoin = saleCoin + config.price * propsInfo.Num
            table.insert(salePropsTabs, propsInfo)
         end 
    end
    coin:setString(Common.numConvert(saleCoin))

    table.sort(salePropsTabs, function(a, b)
        if a.Num == b.Num then
            return a.ID > b.ID
        else
            return a.Num > b.Num
        end
    end)

    local goodsTotal = (#salePropsTabs > 3) and 3 or (#salePropsTabs)
    local itemWidth = 60
    local initWidth = panelSize.width * 0.5 - itemWidth * (goodsTotal - 1)
    for k,propsInfo in pairs(salePropsTabs) do
        if k <= 3 then
            local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, propsInfo, BaseConfig.GOODS_MIDDLETYPE)
            goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2, panelSize.height * 0.55)
            goodsItem:setTips(true)
            goodsItem:setNum()
            panel:addChild(goodsItem)
        end
    end

    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.18)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType, isIn)
        if eventType == ccui.TouchEventType.ended and isIn then
            rpc:call("Props.SaleAllStuff", nil, function(event)
                if event.status == Exceptions.Nil then
                    for k,propsInfo in pairs(salePropsTabs) do
                        GameCache.minusProps(propsInfo.ID, propsInfo.Num)
                    end
                    saleNode:removeFromParent()
                    saleNode = nil

                    local coinGoods = {}
                    coinGoods.ID = 1002
                    coinGoods.Type = BaseConfig.GT_MONEY 
                    coinGoods.Num = saleCoin
                    application:showIconNotice({coinGoods})

                    self:updateCurrShopData(self.data.shopType)
                end
            end)
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
            saleNode:removeFromParent()
            saleNode = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

    self:addChild(saleNode, 1)
end

function ExchangeMall:getRefreshPrice()
    local refreshPrice = nil
    if Shop_type_equip_recycle == self.data.shopType then
        refreshPrice = self.data.nextRefreshPriceTab[self.data.shopType][self.data.subType]
    else
        refreshPrice = self.data.nextRefreshPriceTab[self.data.shopType][1]
    end
    return refreshPrice
end

--[[
    获取物品信息
]]
function ExchangeMall:receiveExchangeInfo()
    Common.addTopSwallowLayer()
    rpc:call("Shop.Info", self.data.shopType, function(event)
        if event.status == Exceptions.Nil then
            self.controls.refreshTime:setString("" .. event.result.NextAutoRefreshTime)
            local refreshPill = GameCache.GetProps(RefreshPillID)
            if refreshPill then
                self.controls.updatePropsNum:setString(refreshPill.Num)
            else
                self.controls.updatePropsNum:setString(0)
            end
            self.data.priceTypeTab[self.data.shopType] = event.result.NextRefreshMoneyType
            self.data.nextRefreshPriceTab[self.data.shopType] = event.result.NextRefreshPrice
            self.data.allGoodsTabs[self.data.shopType] = event.result.List
            for k,goodsInfo in pairs(self.data.allGoodsTabs[self.data.shopType]) do
                goodsInfo.Idx = k - 1
            end
            self.data.equipShopGoodsTabs = {}
            if Shop_type_equip_recycle == self.data.shopType then
                for k,goodsInfo in pairs(self.data.allGoodsTabs[self.data.shopType]) do
                    local equipConfig = BaseConfig.GetEquip(goodsInfo.ID, goodsInfo.StarLevel)
                    if equipConfig and EQUIPTYPE == equipConfig.type then
                        table.insert(self.data.equipShopGoodsTabs, goodsInfo)
                    end
                end
                for k,goodsInfo in pairs(self.data.equipShopGoodsTabs) do
                    goodsInfo.Idx = k - 1
                end
                for k,v in pairs(self.data.equipShopBtnTab) do
                    v:setNormalStatus()
                    v:setFontColor(cc.c3b(177, 174, 170))
                    v:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
                    if 1 == k then
                        v:setTouchStatus()
                        v:setFontColor(cc.c3b(253, 230, 154))
                        v:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
                    end
                end
            end
            self.data.allViewTab[self.data.shopType] = self:createExchangeList()

            if not self.data.isFirstJoin then
                self.data.isFirstJoin = true
                if Shop_type_equip_recycle == self.data.shopType and self.data.appointID then
                    local equipConfig = BaseConfig.GetEquip(self.data.appointID, 1)
                    self:filtrateEquipButton(equipConfig.type)
                    
                    local sortNumber = 1
                    for k,goodsInfo in pairs(self.data.equipShopGoodsTabs) do
                        if goodsInfo.ID == self.data.appointID then
                            sortNumber = k
                            break
                        end
                    end

                    local moveHeight = (math.ceil(sortNumber/3) - 1) * viewCellHeight
                    local minOffsetY = self.data.allViewTab[self.data.shopType]:minContainerOffset().y
                    local maxOffsetY = self.data.allViewTab[self.data.shopType]:maxContainerOffset().y

                    local viewOffsetY = minOffsetY + moveHeight
                    viewOffsetY = (viewOffsetY > maxOffsetY) and maxOffsetY or viewOffsetY
                    self.data.allViewTab[self.data.shopType]:setContentOffset(cc.p(0, viewOffsetY))
                end
            end
        end
        Common.removeTopSwallowLayer()
    end)
end

--[[
    刷新
]]
function ExchangeMall:Refresh()
    local subType = nil
    if self.data.shopType == Shop_type_equip_recycle then
        subType = self.data.subType
    else
        subType = 0
    end
    rpc:call("Shop.Refresh", {ShopType = self.data.shopType, SubType = subType}, function(event)
        if event.status == Exceptions.Nil then

            local refreshPill = GameCache.GetProps(RefreshPillID)
            if refreshPill then
                GameCache.minusProps(RefreshPillID, 1)
            else
                local refreshPrice = self:getRefreshPrice()
                if Shop_type_store == self.data.shopType then
                    if MoneyTypeCoin == self.data.priceTypeTab[self.data.shopType][1] then
                        self.data.score = self.data.score - refreshPrice
                    end
                else
                    self.data.score = self.data.score - refreshPrice
                end
                -- self.controls.num:setString(Common.numConvert(self.data.score))
            end
            
            self.data.nextRefreshPriceTab[self.data.shopType] = event.result.NextRefreshPrice
            self.data.allGoodsTabs[self.data.shopType] = event.result.List
            for k,goodsInfo in pairs(self.data.allGoodsTabs[self.data.shopType]) do
                goodsInfo.Idx = k - 1
            end
            self.controls.refreshTime:setString("" .. event.result.NextAutoRefreshTime)
            local refreshPill = GameCache.GetProps(RefreshPillID)
            if refreshPill then
                self.controls.updatePropsNum:setString(refreshPill.Num)
            else
                self.controls.updatePropsNum:setString(0)
            end
            self.data.equipShopGoodsTabs = {}
            if Shop_type_equip_recycle == self.data.shopType then
                for k,goodsInfo in pairs(self.data.allGoodsTabs[self.data.shopType]) do
                    local equipConfig = BaseConfig.GetEquip(goodsInfo.ID, goodsInfo.StarLevel)
                    if equipConfig and EQUIPTYPE == equipConfig.type then
                        table.insert(self.data.equipShopGoodsTabs, goodsInfo)
                    end
                end
                for k,goodsInfo in pairs(self.data.equipShopGoodsTabs) do
                    goodsInfo.Idx = k - 1
                end
                for k,v in pairs(self.data.equipShopBtnTab) do
                    v:setNormalStatus()
                    v:setFontColor(cc.c3b(177, 174, 170))
                    v:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
                    if 1 == k then
                        v:setTouchStatus()
                        v:setFontColor(cc.c3b(253, 230, 154))
                        v:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
                    end
                end
            end
            self.data.allViewTab[self.data.shopType]:reloadData()
        end
    end) 
end

--[[
    兑换
]]
function ExchangeMall:Exchange(panel, goodsInfo)
    local subType = nil
    if self.data.shopType == Shop_type_equip_recycle then
        subType = self.data.subType
    else
        subType = 0
    end
    rpc:call("Shop.Exchange", {ShopType = self.data.shopType, SubType = subType, Idx = goodsInfo.Idx}, function(event)
        if (event.status == Exceptions.Nil) and (event.result) then
            if Shop_type_store == self.data.shopType then
                if MoneyTypeCoin == goodsInfo.MoneyType then
                    self.data.score = self.data.score - (goodsInfo.Price * goodsInfo.Num)
                end
            else
                self.data.score = self.data.score - (goodsInfo.Price * goodsInfo.Num)
            end
            self.controls.num:setString(Common.numConvert(self.data.score))
            goodsInfo.IsExchanged = event.result.IsExchanged
            self:updatePanel(panel, goodsInfo)
            application:showIconNotice({event.result.Goods})

            local offsetX = self.data.allViewTab[self.data.shopType]:getContentOffset().x
            local offsetY = self.data.allViewTab[self.data.shopType]:getContentOffset().y
            self.data.allViewTab[self.data.shopType]:reloadData()
            -- self.data.allViewTab[self.data.shopType]:setContentOffsetInDuration(cc.p(offsetX, offsetY), 0)
            self.data.allViewTab[self.data.shopType]:setContentOffset(cc.p(offsetX, offsetY))
        end
    end)
end

return ExchangeMall