local EquipIntensify = class("EquipIntensify", BaseLayer)
local effects = require("tool.helper.Effects")
local EquipInfo = require("scene.main.hero.widget.EquipInfo")
local ColorLabel = require("tool.helper.ColorLabel")
local CalHeroAttr = require("tool.helper.CalHeroAttr")

local EQUIPMENT_VIEW = 1
local TRUMP_VIEW = 2

local EQUIPUPGRADE_VIEW = 1
local EQUIPSTAR_VIEW = EQUIPUPGRADE_VIEW + 1
local TEN_THOUSAND = 10000

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

local equipModelLogoTAG = 1

local scheduler = cc.Director:getInstance():getScheduler()

function EquipIntensify:ctor(heroInfo, equipInfo)
    self.data.heroInfo = heroInfo
    self.data.equipInfo = equipInfo
    if self.data.heroInfo then
        self.data.isFromHeroLayer = true
    else
        self.data.isFromHeroLayer = false
    end
    
    self.data.heroSortId = 1
    self.data.currPanel = EQUIPMENT_VIEW
    self.data.currEquipPanel = EQUIPUPGRADE_VIEW
    self.controls.equipWearTabs = {}
    self.data.isUpgrade = false
    self.data.isPlayStarAnim = false
    self.data.playLightNum = 3
    self.data.isCanUpgrade = true
    self.data.isCanUpgradeStar = true
    self.listeners = {}

    scheduler_updateLevelBar = scheduler:scheduleScriptFunc(handler(self, self.setLevelBar), 1/60, false)

    self:selectHeroList()
    local listener = application:addEventListener(AppEvent.UI.Hero.UpdateEquipIntensify, function(event)
        self:setShowUI()
    end)
    table.insert(self.listeners, listener)

    if self.data.isFromHeroLayer then
        local equipConfig = BaseConfig.GetEquip(equipInfo.ID, equipInfo.StarLevel)
        if equipConfig.type < 5 then
            self:setShowUI(EQUIPMENT_VIEW, self.data.heroInfo, equipInfo)
        else
            self:setShowUI(TRUMP_VIEW, self.data.heroInfo, equipInfo)
        end
    end
end

function EquipIntensify:onEnter()
    if self.data.isAgainJoin then
        self:setShowUI()
    end
    self.data.isAgainJoin = true
end

function EquipIntensify:onCleanup()
    if scheduler_updateLevelBar then
        scheduler:unscheduleScriptEntry(scheduler_updateLevelBar)
    end
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
end

function EquipIntensify:selectHeroList()
    self.data.allHero = {}
    local allHero = GameCache.GetAllHero()
    for k,v in pairs(allHero) do
        table.insert(self.data.allHero, v)
    end
    table.sort(self.data.allHero, Common.heroSort)
    
    self.data.heroTabs = {}
    for k,v in pairs(self.data.allHero) do
        local isHaveEquip = false
        for i=1,6 do
            local equipInfo = v.Equip[i]
            if equipInfo.ID ~= 0 then
                isHaveEquip = true
                break
            end
        end

        if isHaveEquip then
            table.insert(self.data.heroTabs, v)
        end
    end

    if self.data.heroInfo then
        for k,v in pairs(self.data.heroTabs) do
            if v == self.data.heroInfo then
                self.data.heroSortId = k
                break
            end
        end
    else
        self.data.heroSortId = 1
        self.data.heroInfo = self.data.heroTabs[1]
        local tempTab = {
            Exp = 1,
            ID = 1001,
            Level = 1,
            SkinID = 1001,
            StarLevel = 0
        }
        self.data.equipInfo = tempTab
    end

    self:createUI()
end

function EquipIntensify:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(cc.size(944, 619))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    local fringe = cc.Scale9Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setContentSize(self.data.bgSize)
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height)
    self.controls.bg:addChild(fringe, bgZOrder)

    local headBg = cc.Sprite:create("image/ui/img/bg/bg_263.png")
    headBg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.89)
    self.controls.bg:addChild(headBg, bgZOrder)

    self.controls.attrPanel_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.attrPanel_bg:setContentSize(cc.size(320, 485))
    self.controls.attrPanel_bg:setPosition(self.data.bgSize.width * 0.18, self.data.bgSize.height * 0.4)
    self.controls.bg:addChild(self.controls.attrPanel_bg, bgZOrder)
    local quan = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    quan:setPosition(self.controls.attrPanel_bg:getContentSize().width * 0.5, 
                    self.controls.attrPanel_bg:getContentSize().height * 0.5)
    self.controls.attrPanel_bg:addChild(quan, bgZOrder)

    -- self.controls.equipPanel_bg = cc.Sprite:create("image/ui/img/bg/bg_108.png")
    -- self.controls.equipPanel_bg:setPosition(self.data.bgSize.width * 0.635, self.data.bgSize.height * 0.4)
    -- self.controls.bg:addChild(self.controls.equipPanel_bg, bgZOrder)
    -- local newBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    -- newBg:setContentSize(cc.size(540, 485))
    -- newBg:setPosition(self.controls.equipPanel_bg:getContentSize().width * 0.5, 
    --                     self.controls.equipPanel_bg:getContentSize().height * 0.5)
    -- self.controls.equipPanel_bg:addChild(newBg)

    self.controls.equipPanel_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.equipPanel_bg:setContentSize(cc.size(540, 485))
    self.controls.equipPanel_bg:setPosition(self.data.bgSize.width * 0.635, self.data.bgSize.height * 0.4)
    self.controls.bg:addChild(self.controls.equipPanel_bg, bgZOrder)

    self.controls.equipUpgradeNode = cc.Node:create()
    self.controls.equipPanel_bg:addChild(self.controls.equipUpgradeNode, bgZOrder)
    self.controls.equipStarNode = cc.Node:create()
    self.controls.equipPanel_bg:addChild(self.controls.equipStarNode, bgZOrder)
    self.controls.trumpUpgradeNode = cc.Node:create()
    self.controls.equipPanel_bg:addChild(self.controls.trumpUpgradeNode, bgZOrder)

    self:heroDetailUI()
    self:equipMentUI()
    self:trumpUI()

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.97, self.data.bgSize.height * 0.97)
    self.controls.bg:addChild(btn_close, bgZOrder)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            for i=1,6 do
                self:removeGoodsFromShow(i, true)
            end
            cc.Director:getInstance():popScene()
        end
    end)

    local function equipWear()
        local nameTab = {"arm", "hat", "ring", "coat", "magic", "book"}
        local pathTab = {"btn_106.png", "btn_105.png", "btn_107.png", "btn_104.png", "btn_108.png", "btn_109.png"}
        local eventDispatcher = self:getEventDispatcher()
        
        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            
            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end

        local function onTouchEnd(touch, event)
            local target = event:getCurrentTarget()
            local name = target:getName()
            local equipID = nil
            for k,v in pairs(nameTab) do
                if name == v then
                    equipID = k
                end
            end
            CCLog("====================", equipID)
            if self.data.heroInfo.Equip[equipID].ID ~= 0 then
                if equipID < 5 then
                    self:setShowUI(EQUIPMENT_VIEW, self.data.heroInfo, self.data.heroInfo.Equip[equipID])
                else
                    self:setShowUI(TRUMP_VIEW, self.data.heroInfo, self.data.heroInfo.Equip[equipID])
                end
            end
        end
        
        local size = self.controls.attrPanel_bg:getContentSize()
        for i=1,6 do
            local posX = ((i - 1) % 2) * (size.width * 0.395) + size.width * 0.3
            local posY = size.height * 0.65 - math.floor((i - 1) / 2) * (size.height * 0.25)
            local path = "image/ui/img/btn/"..pathTab[i]

            local bg = cc.Sprite:create("image/icon/border/head_bg.png")
            bg:setPosition(posX,  posY)
            bg:setName(nameTab[i])
            self.controls.attrPanel_bg:addChild(bg, bgZOrder)
            self.controls.equipWearTabs[i] = bg
            local bgSize = bg:getContentSize()
            local logo = cc.Sprite:create(path)
            logo:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(logo)
            local border = cc.Sprite:create("image/icon/border/border_star_0.png")
            border:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(border)

            listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
        end
    end
    equipWear()

    local function scrollPanel()
        local size = self.data.bgSize
        self.data.titleHeadWidth = 860

        local function heroList()
            local function createTableView()
                local function cellSizeForTable(table,idx) 
                    local itemTotal = (#self.data.heroTabs)
                    self.data.itemWidth = 122
                    self.data.tabWidth = self.data.itemWidth * itemTotal
                    return self.data.itemWidth,self.data.tabWidth
                end

                local function tableCellAtIndex(viewTable, idx)
                    local cell = viewTable:dequeueCell()

                    local function getLayer()
                        local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), self.data.tabWidth, 105)
                        layerColor:setAnchorPoint(0 , 0)
                        layerColor:setPosition(0 , 0)

                        self.data.heroHeadItemTabs = {}
                        for k,v in pairs(self.data.heroTabs) do
                            local item = GoodsInfoNode.new(BaseConfig.GOODS_HERO, v)
                            item:setLevel()
                            item:setWx()
                            item:setPosition((k - 1) * self.data.itemWidth + item:getContentSize().width * 0.7, layerColor:getContentSize().height/2)
                            item:setChooseBorderVisible(false)
                            item:addTouchEventListener(function(sender, eventType)
                                if not viewTable:isTouchMoved() then
                                    if eventType == ccui.TouchEventType.ended then
                                        self.data.heroSortId = k
                                        item:setChooseBorderVisible(true)
                                        if self.data.previousHeroItem then
                                            if self.data.previousHeroItem ~= item then
                                                self.data.previousHeroItem:setChooseBorderVisible(false)
                                            end
                                        end
                                        self.data.previousHeroItem = item
                                        self:updateHero(v, v.Equip)
                                    end
                                end
                            end)
                            if k == self.data.heroSortId then
                                item:setChooseBorderVisible(true)
                                self.data.previousHeroItem = item
                                self:updateHero(v, v.Equip)
                            end
                            layerColor:addChild(item)
                            table.insert(self.data.heroHeadItemTabs, item)
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

                ccSize = cc.size(self.data.titleHeadWidth, 130)
                local tableView = cc.TableView:create(ccSize)
                tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
                tableView:setPosition(cc.p(size.width * 0.022, size.height * 0.79))
                tableView:setDelegate()
                tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
                tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
                tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
                tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
                tableView:reloadData()
                return tableView    
            end

            self.controls.tableView = createTableView()
            self.controls.bg:addChild(self.controls.tableView, bgZOrder)

            if ((#self.data.heroTabs) * self.data.itemWidth < self.data.titleHeadWidth) then
                self.controls.tableView:setTouchEnabled(false)
            end
        end
        heroList()
    end
    scrollPanel()
    self:scrollToCurrHero(self.data.heroSortId)
end

function EquipIntensify:heroDetailUI()
    local heroConfigInfo = BaseConfig.GetHero(self.data.heroInfo.ID, self.data.heroInfo.StarLevel)
    local size = self.controls.attrPanel_bg:getContentSize()
    self.controls.heroStarLevelBg = cc.Sprite:create("image/icon/border/panel_border_star_0.png")
    self.controls.heroStarLevelBg:setPosition(size.width * 0.5, size.height * 0.87)
    self.controls.attrPanel_bg:addChild(self.controls.heroStarLevelBg, bgZOrder)

    local levelBgSize = self.controls.heroStarLevelBg:getContentSize()
    self.controls.heroName = Common.finalFont("xxxx", levelBgSize.width * 0.55, levelBgSize.height * 0.7, 22, nil, 1)
    self.controls.heroName:setAdditionalKerning(-2)
    self.controls.heroStarLevelBg:addChild(self.controls.heroName)

    self.controls.heroLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    self.controls.heroLevel:setPosition(levelBgSize.width * 0.84, levelBgSize.height * 0.12)
    self.controls.heroLevel:setAnchorPoint(1, 0)
    self.controls.heroLevel:setScale(0.45)
    self.controls.heroLevel:setAdditionalKerning(-10)
    self.controls.heroStarLevelBg:addChild(self.controls.heroLevel)

    local ji = cc.Sprite:create("image/ui/img/btn/btn_790.png")
    ji:setAnchorPoint(0, 0)
    ji:setPosition(levelBgSize.width * 0.82, levelBgSize.height * 0.12)
    self.controls.heroStarLevelBg:addChild(ji)

    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_436.png")
    bar_BG:setPosition(levelBgSize.width * 0.4, levelBgSize.height * 0.3)
    self.controls.heroStarLevelBg:addChild(bar_BG)

    self.controls.bar_heroLevel = ccui.LoadingBar:create("image/ui/img/btn/btn_789.png")
    self.controls.bar_heroLevel:setPercent(50)
    self.controls.bar_heroLevel:setPosition(levelBgSize.width * 0.395, levelBgSize.height * 0.3)
    self.controls.heroStarLevelBg:addChild(self.controls.bar_heroLevel)

    local function moveTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender.name
            if name == "before" then
                if self.data.heroSortId > 1 then
                    self.data.heroSortId = self.data.heroSortId - 1
                end
            elseif name == "after" then
                if self.data.heroSortId < (#self.data.heroTabs) then
                    self.data.heroSortId = self.data.heroSortId + 1
                end
            end
            self.controls.tableView:reloadData()
            self:scrollToCurrHero(self.data.heroSortId)
        end
    end

    self.controls.btn_bgforeHero = createMixSprite("image/ui/img/btn/btn_1005.png")
    self.controls.btn_bgforeHero:setPosition(size.width * 0.14, size.height * 0.87)
    self.controls.attrPanel_bg:addChild(self.controls.btn_bgforeHero, bgZOrder)
    self.controls.btn_bgforeHero.name = "before"
    self.controls.btn_bgforeHero:addTouchEventListener(moveTouchEvent)

    self.controls.btn_afterHero = createMixSprite("image/ui/img/btn/btn_1005.png", nil, "image/ui/img/btn/btn_1005.png")
    self.controls.btn_afterHero:getBg():setVisible(false)
    local child = self.controls.btn_afterHero:getChild()
    child:setScaleX(-1)
    self.controls.btn_afterHero:setPosition(size.width * 0.86, size.height * 0.87)
    self.controls.attrPanel_bg:addChild(self.controls.btn_afterHero, bgZOrder)
    self.controls.btn_afterHero.name = "after"
    self.controls.btn_afterHero:addTouchEventListener(moveTouchEvent)

    if self.data.heroSortId <= 1 then
        self.controls.btn_bgforeHero:setVisible(false)
        self.controls.btn_bgforeHero:setTouchEnable(false)
    end
    if self.data.heroSortId >= (#self.data.heroTabs) then
        self.controls.btn_afterHero:setVisible(false)
        self.controls.btn_afterHero:setTouchEnable(false)
    end
end

function EquipIntensify:scrollToHeroByID(heroID, equipType)
    local sortID = nil
    local heroInfo = nil
    for k,v in pairs(self.data.heroTabs) do
        if v.ID == heroID then
            sortID = k
            heroInfo = v
            break
        end
    end
    if sortID then
        self.data.heroSortId = sortID
        self:scrollToCurrHero(self.data.heroSortId)
        local headItem = nil
        for k,v in pairs(self.data.heroHeadItemTabs) do
            local info = v:getGoodsInfo()
            if info.ID == heroID then
                headItem = v
                break
            end
        end
        headItem:setChooseBorderVisible(true)
        if self.data.previousHeroItem then
            if self.data.previousHeroItem ~= headItem then
                self.data.previousHeroItem:setChooseBorderVisible(false)
            end
        end
        self.data.previousHeroItem = headItem
        if 0 == equipType then
            self:updateHero(heroInfo, heroInfo.Equip)
            return
        end

        self:updateDirection()
        local appointEquipInfo = heroInfo.Equip[equipType]
        if appointEquipInfo.ID ~= 0 then
            local currPanel = TRUMP_VIEW
            if equipType < 5 then
                currPanel = EQUIPMENT_VIEW
            end
            self:setShowUI(currPanel, heroInfo, appointEquipInfo)
        else
            local equipInfo = nil
            local currPanel = TRUMP_VIEW
            for i=1,6 do
                local info = heroInfo.Equip[i]
                if info.ID ~= 0 then
                    equipInfo = info
                    if i < 5 then
                        currPanel = EQUIPMENT_VIEW
                    end
                    break
                end
            end
            self:setShowUI(currPanel, heroInfo, equipInfo)
        end
    end
end

function EquipIntensify:scrollToCurrHero(sortId)
    if ((#self.data.heroTabs) * 122 > self.data.titleHeadWidth) then
        local currHeroPos = -(sortId - 1) * 122
        if (currHeroPos - self.data.titleHeadWidth) < (-self.controls.tableView:getContentSize().width) then
            currHeroPos = -self.controls.tableView:getContentSize().width + self.data.titleHeadWidth
        end
        self.controls.tableView:setContentOffset(cc.p(currHeroPos, 0), false)
    end
end

function EquipIntensify:equipMentUI()
    self.controls.equipMentBtns = {}

    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.controls.equipMentBtns) do
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

            if name ==  "upgrade" then
                if self.data.currPanel == EQUIPMENT_VIEW then
                    self.data.currEquipPanel = EQUIPUPGRADE_VIEW
                    self.controls.equipUpgradeNode:setScale(1)
                    self.controls.equipUpgrade.btn_upgrade:setTouchEnable(true)
                    self.controls.equipUpgrade.btn_quickUpgrade:setTouchEnable(true)

                    self.controls.equipStarNode:setScale(0)
                    self.controls.equipStar.btn_upgrade:setTouchEnable(false)

                    self:updateEquipUpgrade()
                end
            elseif name == "star" then
                self.data.currEquipPanel = EQUIPSTAR_VIEW
                self.controls.equipUpgradeNode:setScale(0)
                self.controls.equipUpgrade.btn_upgrade:setTouchEnable(false)
                self.controls.equipUpgrade.btn_quickUpgrade:setTouchEnable(false)

                self.controls.equipStarNode:setScale(1)
                self.controls.equipStar.btn_upgrade:setTouchEnable(true)
            end
        end
    end

    local size = self.controls.equipPanel_bg:getContentSize()
    self.controls.btn_equipUpgrade = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
    self.controls.btn_equipUpgrade:setRotation(90)
    self.controls.btn_equipUpgrade:setCircleFont("升\n级" , 1, 1, 30, cc.c3b(253, 230, 154))
    self.controls.btn_equipUpgrade:setFontOutline(cc.c4b(27, 31, 49, 255), 2)
    self.controls.btn_equipUpgrade:setFontPos(0.5, 0.9)
    self.controls.btn_equipUpgrade:getFont():setRotation(-90)
    self.controls.btn_equipUpgrade:setAnchorPoint(0.5, 0)
    self.controls.btn_equipUpgrade:setBgTouchAnchorPoint(0.5, 0)
    self.controls.btn_equipUpgrade:setPosition(size.width * 0.986, size.height * 0.76)
    self.controls.btn_equipUpgrade:setName("upgrade")
    self.controls.btn_equipUpgrade:addTouchEventListener(btnTouchEvent)
    self.controls.equipPanel_bg:addChild(self.controls.btn_equipUpgrade)
    table.insert(self.controls.equipMentBtns , self.controls.btn_equipUpgrade)

    self.controls.btn_equipStar = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
    self.controls.btn_equipStar:setRotation(90)
    self.controls.btn_equipStar:setCircleFont("升\n星" , 1, 1, 30, cc.c3b(177, 174, 170))
    self.controls.btn_equipStar:setFontOutline(cc.c4b(27, 31, 49, 255), 2)
    self.controls.btn_equipStar:setFontPos(0.5, 0.9)
    self.controls.btn_equipStar:getFont():setRotation(-90)
    self.controls.btn_equipStar:setAnchorPoint(0.5, 0)
    self.controls.btn_equipStar:setBgTouchAnchorPoint(0.5, 0)
    self.controls.btn_equipStar:setPosition(size.width * 0.986, size.height * 0.4)
    self.controls.btn_equipStar:setName("star")
    self.controls.btn_equipStar:addTouchEventListener(btnTouchEvent)
    self.controls.equipPanel_bg:addChild(self.controls.btn_equipStar)
    table.insert(self.controls.equipMentBtns , self.controls.btn_equipStar)

    local function equipUpgradeUI()
        local equipTab = self.data.heroInfo.Equip
        local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, 0)
        local equipUpgradeConfig = BaseConfig.GetEquipUpgrade(equipTab[equipConfigInfo.type].Level + 1)
        self.controls.equipUpgrade = {}
        self.data.equipUpgrade = {}

        local bgSize = self.controls.equipPanel_bg:getContentSize()
        local bg = cc.Sprite:create("image/ui/img/bg/bg_262.png")
        bg:setPosition(bgSize.width * 0.5, bgSize.height * 0.58)
        self.controls.equipUpgradeNode:addChild(bg)
        local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_1011.png")
        detailName:setTouchEnable(false)
        detailName:setPosition(bgSize.width * 0.5, bgSize.height * 0.96)
        self.controls.equipUpgradeNode:addChild(detailName)
        local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        line:setPosition(bgSize.width * 0.3, bgSize.height * 0.96)
        self.controls.equipUpgradeNode:addChild(line)
        line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        line:setPosition(bgSize.width * 0.7, bgSize.height * 0.96)
        self.controls.equipUpgradeNode:addChild(line)
        
        self.controls.equipUpgrade.chooseEquip = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipUpgrade.chooseEquip:setPosition(bgSize.width * 0.5, bgSize.height * 0.79)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.chooseEquip)
        self.controls.equipUpgrade.img_pill = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipUpgrade.img_pill:setPosition(bgSize.width * 0.28, bgSize.height * 0.4)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.img_pill)
        self.controls.equipUpgrade.img_price = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipUpgrade.img_price:setPosition(bgSize.width * 0.72, bgSize.height * 0.4)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.img_price)
        local attrBg = cc.Sprite:create("image/ui/img/btn/btn_1322.png")
        attrBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.56)
        self.controls.equipUpgradeNode:addChild(attrBg)
        local size = self.controls.equipUpgrade.chooseEquip:getContentSize()

        self.controls.equipUpgrade.propsImg = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, {Type = 6, ID = equipUpgradeConfig.ArmPropsID}, BaseConfig.GOODS_MIDDLETYPE)
        self.controls.equipUpgrade.propsImg:setTips(true)
        self.controls.equipUpgrade.propsImg:setTipsBox(true)
        self.controls.equipUpgrade.propsImg:setTag(1)
        self.controls.equipUpgrade.propsImg:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipUpgrade.img_pill:addChild(self.controls.equipUpgrade.propsImg, bgZOrder)
        self.controls.equipUpgrade.priceImg = cc.Sprite:create("image/icon/props/coin.png")
        self.controls.equipUpgrade.priceImg:setTag(1)
        self.controls.equipUpgrade.priceImg:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipUpgrade.img_price:addChild(self.controls.equipUpgrade.priceImg, bgZOrder)
        self.controls.equipUpgrade.propsNum = ColorLabel.new("", 20, nil, true)
        self.controls.equipUpgrade.propsNum:setPosition(size.width * 0.5, -15)
        self.controls.equipUpgrade.img_pill:addChild(self.controls.equipUpgrade.propsNum, bgZOrder)
        self.controls.equipUpgrade.price = ColorLabel.new("", 20, nil, true)
        self.controls.equipUpgrade.price:setPosition(size.width * 0.5, -15)
        self.controls.equipUpgrade.img_price:addChild(self.controls.equipUpgrade.price, bgZOrder)

        bgSize = self.controls.equipPanel_bg:getContentSize()
        self.controls.equipUpgrade.name = Common.finalFont("", bgSize.width * 0.5, bgSize.height * 0.65, 25, nil, 1)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.name)
        self.controls.equipUpgrade.level = Common.finalFont("", bgSize.width * 0.14, bgSize.height * 0.56, 20)
        self.controls.equipUpgrade.level:setAnchorPoint(0, 0.5)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.level)
        self.controls.equipUpgrade.addlevel = Common.finalFont("", 0, bgSize.height * 0.56, 20,cc.c3b(78,255,0))
        self.controls.equipUpgrade.addlevel:setAnchorPoint(0, 0.5)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.addlevel)
        self.controls.equipUpgrade.atk = Common.finalFont("", bgSize.width * 0.54, bgSize.height * 0.56, 20)
        self.controls.equipUpgrade.atk:setAnchorPoint(0, 0.5)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.atk)
        self.controls.equipUpgrade.addatk = Common.finalFont("", 0, bgSize.height * 0.56, 20, cc.c3b(78,255,0))
        self.controls.equipUpgrade.addatk:setAnchorPoint(0, 0.5)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.addatk)
        self.controls.equipUpgrade.toLevel = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        self.controls.equipUpgrade.toLevel:setPosition(0, bgSize.height * 0.56)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.toLevel)
        self.controls.equipUpgrade.toAtk = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        self.controls.equipUpgrade.toAtk:setPosition(0, bgSize.height * 0.56)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.toAtk)

        local btn_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
        btn_bg:setContentSize(cc.size(bgSize.width * 0.962, 100))
        btn_bg:setPosition(bgSize.width * 0.5, 62)
        self.controls.equipUpgradeNode:addChild(btn_bg)
        self.controls.equipUpgrade.btn_upgrade = createMixScale9Sprite("image/ui/img/btn/btn_593.png")
        self.controls.equipUpgrade.btn_upgrade:setButtonBounce(false)
        self.controls.equipUpgrade.btn_upgrade:setCircleFont("升级1次", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        self.controls.equipUpgrade.btn_upgrade:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        self.controls.equipUpgrade.btn_upgrade:setPosition(bgSize.width * 0.25, 62)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.btn_upgrade)
        self.controls.equipUpgrade.btn_upgrade:addTouchEventListener(function(sender, eventType, isInside)
            if eventType == ccui.TouchEventType.ended and isInside and self.data.isCanUpgrade then
                local equipTab = self.data.heroInfo.Equip
                local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)

                if equipTab[equipConfigInfo.type].Level >= (GameCache.Avatar.Level * 3) then
                    application:showFlashNotice("已达当前等级上限,请继续提升主角等级")
                elseif GameCache.Avatar.Coin < self.data.equipUpgrade.needEquipCoin then
                    application:showFlashNotice("银币不足")
                elseif (0 == self:getPropsNumByID(self.data.equipUpgrade.needPropsID)) or
                    (self:getPropsNumByID(self.data.equipUpgrade.needPropsID) < self.data.equipUpgrade.needPorpsNum) then
                    application:showFlashNotice("锻造石不足")
                else
                    self:upgradeEquip(self.data.heroInfo.ID, equipConfigInfo.type, 
                                    self.data.equipUpgrade.needEquipCoin, self.data.equipUpgrade.needPropsID, self.data.equipUpgrade.needPorpsNum)
                end
            end
        end)

        self.controls.equipUpgrade.btn_quickUpgrade = createMixScale9Sprite("image/ui/img/btn/btn_593.png")
        self.controls.equipUpgrade.btn_quickUpgrade:setButtonBounce(false)
        self.controls.equipUpgrade.btn_quickUpgrade:setCircleFont("一键升级", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        self.controls.equipUpgrade.btn_quickUpgrade:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        self.controls.equipUpgrade.btn_quickUpgrade:setPosition(bgSize.width * 0.75, 60)
        self.controls.equipUpgradeNode:addChild(self.controls.equipUpgrade.btn_quickUpgrade)
        self.controls.equipUpgrade.btn_quickUpgrade:addTouchEventListener(function(sender, eventType, isInside)
            if eventType == ccui.TouchEventType.ended and isInside and self.data.isCanUpgrade then
                local equipTab = self.data.heroInfo.Equip
                local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
                local needData = self:quickUpgradeNeedData()

                if equipTab[equipConfigInfo.type].Level >= (GameCache.Avatar.Level * 3) then
                    application:showFlashNotice("已达当前等级上限,请继续提升主角等级")
                elseif (needData.NeedCoin < 1) or (needData.NeedPorpsNum < 1) then
                    if GameCache.Avatar.Coin < self.data.equipUpgrade.needEquipCoin then
                        application:showFlashNotice("银币不足")
                    elseif (self:getPropsNumByID(self.data.equipUpgrade.needPropsID) < self.data.equipUpgrade.needPorpsNum) then
                        application:showFlashNotice("锻造石不足")
                    end
                else
                    self:upgradeEquip(self.data.heroInfo.ID, equipConfigInfo.type, 
                                    needData.NeedCoin, self.data.equipUpgrade.needPropsID, needData.NeedPorpsNum, needData.Level)
                end
            end
        end)
    end
    equipUpgradeUI()

    local function equipStarUI()
        local equipTab = self.data.heroInfo.Equip
        local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, 0)
        local equipStarConfig = BaseConfig.GetEquipUpstarCommon(1)
        self.controls.equipStar = {}
        self.data.equipStar = {}

        local bgSize = self.controls.equipPanel_bg:getContentSize()
        local bg = cc.Sprite:create("image/ui/img/bg/bg_262.png")
        bg:setPosition(bgSize.width * 0.5, bgSize.height * 0.58)
        self.controls.equipStarNode:addChild(bg)
        local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_1012.png")
        detailName:setTouchEnable(false)
        detailName:setPosition(bgSize.width * 0.5, bgSize.height * 0.96)
        self.controls.equipStarNode:addChild(detailName)
        local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        line:setPosition(bgSize.width * 0.3, bgSize.height * 0.96)
        self.controls.equipStarNode:addChild(line)
        line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        line:setPosition(bgSize.width * 0.7, bgSize.height * 0.96)
        self.controls.equipStarNode:addChild(line)

        self.controls.equipStar.chooseEquip = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipStar.chooseEquip:setPosition(bgSize.width * 0.5, bgSize.height * 0.79)
        self.controls.equipStarNode:addChild(self.controls.equipStar.chooseEquip)
        self.controls.equipStar.equipName = Common.finalFont("", 1, 1, 25, nil, 1)
        self.controls.equipStar.equipName:setPosition(bgSize.width * 0.5, bgSize.height * 0.65)
        self.controls.equipStarNode:addChild(self.controls.equipStar.equipName)
        self.data.equipStar.starTab = {}
        for i=1,6 do
            local star = createMixSprite("image/ui/img/btn/btn_638.png", "image/ui/img/btn/btn_439.png")
            star:setTouchEnable(false)
            local starBg = star:getBg()
            starBg:setScale(0.58)
            star:setPosition(bgSize.width * 0.34 + 25 * i, bgSize.height * 0.58)
            self.controls.equipStarNode:addChild(star)
            self.data.equipStar.starTab[i] = star
        end
        local btn_look = createMixScale9Sprite("image/ui/img/btn/btn_1004.png")
        btn_look:setPosition(bgSize.width * 0.86, bgSize.height * 0.84)
        self.controls.equipStarNode:addChild(btn_look)
        btn_look:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local starDesc = self:upgradeStarDescUI()
                self:addChild(starDesc)
            end
        end)

        self.controls.equipStar.img_stone1 = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipStar.img_stone1:setPosition(bgSize.width * 0.14, bgSize.height * 0.42)
        self.controls.equipStarNode:addChild(self.controls.equipStar.img_stone1)
        self.controls.equipStar.img_stone2 = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipStar.img_stone2:setPosition(bgSize.width * 0.38, bgSize.height * 0.42)
        self.controls.equipStarNode:addChild(self.controls.equipStar.img_stone2)
        self.controls.equipStar.img_price = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipStar.img_price:setPosition(bgSize.width * 0.62, bgSize.height * 0.42)
        self.controls.equipStarNode:addChild(self.controls.equipStar.img_price)
        self.controls.equipStar.img_equip = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
        self.controls.equipStar.img_equip:setPosition(bgSize.width * 0.86, bgSize.height * 0.42)
        self.controls.equipStarNode:addChild(self.controls.equipStar.img_equip)
        self.data.equipStar.addSpriTab = {}
        for i=1,3 do
            local addSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
            addSpri:setPosition(bgSize.width * 0.26 + (i - 1) * bgSize.width * 0.24, bgSize.height * 0.42)
            self.controls.equipStarNode:addChild(addSpri)
            self.data.equipStar.addSpriTab[i] = addSpri
        end
        self.data.equipStar.lightTab = {}
        for i=1,4 do
            local light = effects:CreateAnimation(self.controls.equipStarNode, bgSize.width * 0.14 + (i - 1) * bgSize.width * 0.24, size.height * 0.42, nil, 29, true)
            light:setScale(0)
            self.data.equipStar.lightTab[i] = light
        end

        local size = self.controls.equipStar.img_stone1:getContentSize()
        self.controls.equipStar.propsImg1 = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, {Type = 6, ID = equipStarConfig.PropsID}, BaseConfig.GOODS_MIDDLETYPE)
        self.controls.equipStar.propsImg1:setTips(true)
        self.controls.equipStar.propsImg1:setTipsBox(true)
        self.controls.equipStar.propsImg1:setTag(1)
        self.controls.equipStar.propsImg1:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipStar.img_stone1:addChild(self.controls.equipStar.propsImg1, bgZOrder)
        self.controls.equipStar.propsImg2 = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, {Type = 6, ID = equipStarConfig.PropsID}, BaseConfig.GOODS_MIDDLETYPE)
        self.controls.equipStar.propsImg2:setTips(true)
        self.controls.equipStar.propsImg2:setTipsBox(true)
        self.controls.equipStar.propsImg2:setTag(1)
        self.controls.equipStar.propsImg2:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipStar.img_stone2:addChild(self.controls.equipStar.propsImg2, bgZOrder)
        self.controls.equipStar.equipImg = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, {Type = BaseConfig.GT_PROPS, ID = self.data.equipInfo.ID}, BaseConfig.GOODS_MIDDLETYPE)
        self.controls.equipStar.equipImg:setTips(true)
        self.controls.equipStar.equipImg:setTipsBox(true)
        self.controls.equipStar.equipImg:setTag(1)
        self.controls.equipStar.equipImg:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipStar.img_equip:addChild(self.controls.equipStar.equipImg, bgZOrder)
        self.controls.equipStar.priceImg = cc.Sprite:create("image/icon/props/coin.png")
        self.controls.equipStar.priceImg:setTag(1)
        self.controls.equipStar.priceImg:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipStar.img_price:addChild(self.controls.equipStar.priceImg, bgZOrder)

        self.controls.equipStar.propsNum1 = ColorLabel.new("", 20, nil, true)
        self.controls.equipStar.propsNum1:setPosition(size.width * 0.5, -15)
        self.controls.equipStar.img_stone1:addChild(self.controls.equipStar.propsNum1, bgZOrder)
        self.controls.equipStar.propsNum2 = ColorLabel.new("", 20, nil, true)
        self.controls.equipStar.propsNum2:setPosition(size.width * 0.5, -15)
        self.controls.equipStar.img_stone2:addChild(self.controls.equipStar.propsNum2, bgZOrder)
        self.controls.equipStar.equipNum = ColorLabel.new("", 20, nil, true)
        self.controls.equipStar.equipNum:setPosition(size.width * 0.5, -15)
        self.controls.equipStar.img_equip:addChild(self.controls.equipStar.equipNum, bgZOrder)
        self.controls.equipStar.price = ColorLabel.new("", 20, nil, true)
        self.controls.equipStar.price:setPosition(size.width * 0.5, -15)
        self.controls.equipStar.img_price:addChild(self.controls.equipStar.price, bgZOrder)

        local btn_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
        btn_bg:setContentSize(cc.size(bgSize.width * 0.962, 100))
        btn_bg:setPosition(bgSize.width * 0.5, 62)
        self.controls.equipStarNode:addChild(btn_bg)
        self.controls.equipStar.btn_upgrade = createMixSprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_787.png")
        self.controls.equipStar.btn_upgrade:setButtonBounce(false)
        self.controls.equipStar.btn_upgrade:setCircleFont("开始升星", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        self.controls.equipStar.btn_upgrade:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        self.controls.equipStar.btn_upgrade:setChildPos(0.2, 0.5)
        self.controls.equipStar.btn_upgrade:setFontPos(0.6, 0.5)
        self.controls.equipStar.btn_upgrade:setPosition(bgSize.width * 0.5, 62)
        self.controls.equipStarNode:addChild(self.controls.equipStar.btn_upgrade)
        self.controls.equipStar.btn_upgrade:addTouchEventListener(function(sender, eventType, isInside)
            if (eventType == ccui.TouchEventType.ended) and isInside and (self.data.isCanUpgradeStar) then
                local equipTab = self.data.heroInfo.Equip
                local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)

                if GameCache.Avatar.Level < self.data.equipStar.needLevel then
                    local desc = "人物等级达到"..self.data.equipStar.needLevel.."级才能升星"
                    application:showFlashNotice(desc)
                elseif GameCache.Avatar.Coin < self.data.equipStar.needPrice then
                    application:showFlashNotice("银币不足")
                elseif (0 == self:getPropsNumByID(self.data.equipStar.needStone1ID)) or
                    (self:getPropsNumByID(self.data.equipStar.needStone1ID) < self.data.equipStar.needStone1Num) then
                    application:showFlashNotice("升星丹不足")
                elseif (0 == self:getPropsNumByID(self.data.equipStar.needStone2ID)) or
                    (self:getPropsNumByID(self.data.equipStar.needStone2ID) < self.data.equipStar.needStone2Num) then
                    application:showFlashNotice("玄精不足")
                elseif (self.data.equipStar.needFragNum > 0) and 
                    (self.data.equipStar.totalPropsNum < self.data.equipStar.needFragNum) then
                     -- 先判断是否大于0需不需要装备材料, 再判断是否足够
                    application:showFlashNotice("装备不足")
                else
                    self.data.isCanUpgradeStar = false
                    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
                    self:upstarEquip(self.data.heroInfo.ID, equipConfigInfo.type)

                    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
                    swallowLayer:setName("swallowLayer")
                    self:addChild(swallowLayer, btnZOrder)
                end
            end
        end)

        self.controls.equipStar.maxStarLevel = Common.finalFont("已达到最大星级", bgSize.width * 0.5, 62, 30, cc.c3b(255, 255, 0))
        self.controls.equipStarNode:addChild(self.controls.equipStar.maxStarLevel)
    end
    equipStarUI()
end

function EquipIntensify:upgradeStarDescUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(500, 300))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local listDesc = ccui.ListView:create()
    listDesc:setDirection(ccui.ScrollViewDir.vertical)
    listDesc:setTouchEnabled(true)
    listDesc:setBounceEnabled(true)
    listDesc:setContentSize(cc.size(bgSize.width * 0.9, bgSize.height * 0.78))
    listDesc:setPosition(bgSize.width * 0.03, bgSize.height * 0.1)
    bg:addChild(listDesc, bgZOrder)

    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
    local heroEquipInfo = self.data.heroInfo.Equip[equipConfigInfo.type]
    local equipStarLevel = heroEquipInfo.StarLevel
    for i=1,12 do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(listDesc:getContentSize().width, 30))

        local starData = Common.getHeroStarLevelColor(i)
        local spri = cc.Sprite:create("image/ui/img/btn/btn_638.png")
        spri:setScale(0.58)
        spri:setPosition(50, layout:getContentSize().height * 0.5)
        layout:addChild(spri)
        local starLabel = cc.Label:createWithCharMap("image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
        starLabel:setScale(0.8)
        starLabel:setAnchorPoint(1, 0.5)
        starLabel:setPosition(spri:getPositionX() - spri:getContentSize().width * 0.2, spri:getContentSize().height * 0.4)
        layout:addChild(starLabel)
        starLabel:setString(starData.StarNum)
        if "" ~= starData.Additional then
            local additional = string.sub(starData.Additional, 2, 2)
            local addSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
            addSpri:setAnchorPoint(0, 0.5)
            addSpri:setPosition(spri:getPositionX() + spri:getContentSize().width * 0.2, spri:getContentSize().height * 0.4)
            layout:addChild(addSpri)
            local starAdd = cc.Label:createWithCharMap("image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
            starAdd:setScale(0.8)
            starAdd:setPosition(spri:getPositionX() + spri:getContentSize().width * 0.6, spri:getContentSize().height * 0.4)
            starAdd:setAnchorPoint(0, 0.5)
            layout:addChild(starAdd)
            starAdd:setString(additional)
        end

        local addition = nil
        local desc = nil
        if equipConfigInfo.type == 1 then
            desc = BaseConfig.GetEquipUpstarCommon(i).ArmUpStarDesc
        elseif equipConfigInfo.type == 2 then
            desc = BaseConfig.GetEquipUpstarCommon(i).HatUpStarDesc
        elseif equipConfigInfo.type == 3 then
            desc = BaseConfig.GetEquipUpstarCommon(i).RingUpStarDesc
        elseif equipConfigInfo.type == 4 then
            desc = BaseConfig.GetEquipUpstarCommon(i).CoatUpStarDesc
        else
            return 
        end
        if i <= equipStarLevel then
            addition = Common.finalFont(desc, 1, 1, 20, cc.c3b(239,239,168))
        else
            addition = Common.finalFont(desc, 1, 1, 20, cc.c3b(255,255,255))
        end
        addition:setPosition(110, spri:getContentSize().height * 0.5)
        addition:setAnchorPoint(0, 0.5)
        layout:addChild(addition)
        listDesc:pushBackCustomItem(layout)
    end
    local container = listDesc:getInnerContainer()
    local moveAction = nil
    local moveMaxStarlevel = 5
    if equipStarLevel < 1 then
        moveAction = cc.MoveTo:create(0.1, cc.p(0, 0))
    elseif equipStarLevel < moveMaxStarlevel then
        moveAction = cc.MoveTo:create(0.1, cc.p(0, 30 * (equipStarLevel - 1)))
    else
        moveAction = cc.MoveTo:create(0.1, cc.p(0, 30 * (moveMaxStarlevel - 1)))
    end
    container:runAction(cc.Sequence:create(moveAction))

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

function EquipIntensify:quickUpgradeNeedData()
    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
    local equipType = equipConfigInfo.type
    local currLevel = self.data.equipInfo.Level
    local maxLevel = GameCache.Avatar.Level * 3
    local currHaveCoin = GameCache.Avatar.Coin 
    local currHavePropsNum = self:getPropsNumByID(self.data.equipUpgrade.needPropsID)

    local totalNeedCoin = 0
    local totalNeedPorpsNum = 0
    local lastLevel = currLevel
    for i=currLevel,(maxLevel - 1) do
        local equipUpgradeConfig = BaseConfig.GetEquipUpgrade(i)
        local needEquipCoin = nil
        local needPorpsNum = nil
        if equipType == 1 then
            needEquipCoin = equipUpgradeConfig.ArmCoin
            needPorpsNum = equipUpgradeConfig.ArmPropsNum
        elseif equipType == 2 then
            needEquipCoin = equipUpgradeConfig.HatCoin
            needPorpsNum = equipUpgradeConfig.HatPropsNum
        elseif equipType == 3 then
            needEquipCoin = equipUpgradeConfig.RingCoin
            needPorpsNum = equipUpgradeConfig.RingPropsNum
        elseif equipType == 4 then
            needEquipCoin = equipUpgradeConfig.CoatCoin
            needPorpsNum = equipUpgradeConfig.CoatPropsNum
        end
        totalNeedCoin = totalNeedCoin + needEquipCoin
        totalNeedPorpsNum = totalNeedPorpsNum + needPorpsNum
        lastLevel = i + 1
        if (totalNeedCoin > currHaveCoin) or (totalNeedPorpsNum > currHavePropsNum) then
            totalNeedCoin = totalNeedCoin - needEquipCoin
            totalNeedPorpsNum = totalNeedPorpsNum - needPorpsNum
            lastLevel = lastLevel - 1
            break
        end
    end
    return {NeedCoin = totalNeedCoin, NeedPorpsNum = totalNeedPorpsNum, Level = lastLevel}
end

function EquipIntensify:trumpUI()
    local equipTab = self.data.heroInfo.Equip
    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, 0)
    
    self.controls.trumpUpgrade = {}
    self.data.trumpUpgrade = {}
    self.data.trumpUpgrade.goodsImgTabs = {}
    self.data.trumpUpgrade.chooseNum = 0
    self.data.trumpUpgrade.currPrice = 0
    self.data.trumpUpgrade.currExp = 0

    local bgSize = self.controls.equipPanel_bg:getContentSize()
    local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_1011.png")
    detailName:setTouchEnable(false)
    detailName:setPosition(bgSize.width * 0.5, bgSize.height * 0.96)
    self.controls.trumpUpgradeNode:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(bgSize.width * 0.3, bgSize.height * 0.96)
    self.controls.trumpUpgradeNode:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(bgSize.width * 0.7, bgSize.height * 0.96)
    self.controls.trumpUpgradeNode:addChild(line)
    local equipBg = cc.Sprite:create("image/ui/img/bg/bg_265.png")
    equipBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.73)
    self.controls.trumpUpgradeNode:addChild(equipBg)

    local img_trump = cc.Sprite:create("image/ui/img/btn/btn_1006.png")
    img_trump:setPosition(bgSize.width * 0.2, bgSize.height * 0.73)
    self.controls.trumpUpgradeNode:addChild(img_trump)
    local size = img_trump:getContentSize()
    self.controls.trumpUpgrade.img_trump = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, self.data.equipInfo)
    self.controls.trumpUpgrade.img_trump:setTouchEnable(false)
    self.controls.trumpUpgrade.img_trump:setPosition(size.width * 0.5, size.height * 0.5)
    img_trump:addChild(self.controls.trumpUpgrade.img_trump)

    self.controls.trumpUpgrade.name = Common.finalFont("", bgSize.width * 0.35, bgSize.height * 0.83, 25,nil, 1)
    self.controls.trumpUpgrade.name:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.name)

    self.controls.trumpUpgrade.bar_BG = cc.Sprite:create("image/ui/img/btn/btn_1019.png")
    self.controls.trumpUpgrade.bar_BG:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgrade.bar_BG:setPosition(bgSize.width * 0.35, bgSize.height * 0.77)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.bar_BG)

    self.controls.trumpUpgrade.bar_heroLevel = ccui.LoadingBar:create("image/ui/img/btn/btn_1018.png")
    local maxLevel = nil
    if self.data.equipInfo.Level >= BaseConfig.MAX_TREASURE_LEVEL then
        maxLevel = BaseConfig.GetTrumpUpgrade(BaseConfig.MAX_TREASURE_LEVEL - 1).exp
    else
        maxLevel = BaseConfig.GetTrumpUpgrade(self.data.equipInfo.Level).exp
    end
    self.controls.trumpUpgrade.bar_heroLevel:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgrade.bar_heroLevel:setPosition(bgSize.width * 0.355, bgSize.height * 0.77)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.bar_heroLevel)

    self.controls.trumpUpgrade.level = Common.finalFont("level", bgSize.width * 0.64, bgSize.height * 0.83, 20)
    self.controls.trumpUpgrade.level:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.level)
    self.controls.trumpUpgrade.addlevel = Common.finalFont("addLevel", 0, bgSize.height * 0.83, 20,cc.c3b(78,255,0))
    self.controls.trumpUpgrade.addlevel:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.addlevel)
    self.controls.trumpUpgrade.toLevel = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    self.controls.trumpUpgrade.toLevel:setPosition(0, bgSize.height * 0.83)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.toLevel)

    self.controls.trumpUpgrade.atk = ColorLabel.new("", 20, nil, true)
    self.controls.trumpUpgrade.atk:setPosition(bgSize.width * 0.35, bgSize.height * 0.7)
    self.controls.trumpUpgrade.atk:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.atk)
    self.controls.trumpUpgrade.addatk = ColorLabel.new("", 20, nil, true)
    self.controls.trumpUpgrade.addatk:setPosition(0, bgSize.height * 0.7)
    self.controls.trumpUpgrade.addatk:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.addatk)
    self.controls.trumpUpgrade.toAtk = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    self.controls.trumpUpgrade.toAtk:setPosition(0, bgSize.height * 0.7)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.toAtk)

    self.controls.trumpUpgrade.def = ColorLabel.new("", 20, nil, true)
    self.controls.trumpUpgrade.def:setPosition(bgSize.width * 0.35, bgSize.height * 0.62)
    self.controls.trumpUpgrade.def:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.def)
    self.controls.trumpUpgrade.adddef = ColorLabel.new("", 20, nil, true)
    self.controls.trumpUpgrade.adddef:setPosition(0, bgSize.height * 0.62)
    self.controls.trumpUpgrade.adddef:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.adddef)
    self.controls.trumpUpgrade.toDef = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    self.controls.trumpUpgrade.toDef:setPosition(0, bgSize.height * 0.62)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.toDef)

    local attrBg = cc.Sprite:create("image/ui/img/btn/btn_1322.png")
    attrBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.49)
    self.controls.trumpUpgradeNode:addChild(attrBg)

    local exp = Common.finalFont("获得经验:", bgSize.width * 0.21, bgSize.height * 0.49, 20)
    self.controls.trumpUpgradeNode:addChild(exp)
    self.controls.trumpUpgrade.exp = Common.finalFont("0",exp:getPositionX() + exp:getContentSize().width * 0.5 + 10, 
                                                            bgSize.height * 0.49, 20, cc.c3b(255, 255, 0),1)
    self.controls.trumpUpgrade.exp:setAnchorPoint(0, 0.5)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.exp)

    local price = Common.finalFont("升级花费:", bgSize.width * 0.6, bgSize.height * 0.49, 20, nil, 1)
    self.controls.trumpUpgradeNode:addChild(price)
    local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    priceSpri:setPosition(bgSize.width * 0.72, bgSize.height * 0.49)
    self.controls.trumpUpgradeNode:addChild(priceSpri)
    self.controls.trumpUpgrade.price = Common.finalFont("",bgSize.width * 0.81, bgSize.height * 0.49, 20, nil, 1)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.price)

    local eventDispatcher = self:getEventDispatcher()
    for i=1,6 do
        local goodsTab = {}
        local goodsImg = cc.Sprite:create("image/icon/border/head_bg.png")
        goodsImg:setScale(0.68)
        goodsImg:setPosition(bgSize.width * 0.1 + (i - 1) * bgSize.width * 0.16, bgSize.height * 0.34)
        goodsImg:setTag(i)
        self.controls.trumpUpgradeNode:addChild(goodsImg)
        goodsTab.isHaveEquip = false
        goodsTab.img = goodsImg
        table.insert(self.data.trumpUpgrade.goodsImgTabs, goodsTab)

        local size = goodsImg:getContentSize()
        local border = cc.Sprite:create("image/icon/border/border_star_0.png")
        border:setPosition(size.width * 0.5, size.height * 0.5)
        goodsImg:addChild(border)
        local add = cc.Sprite:create("image/ui/img/btn/btn_1009.png")
        add:setScale(1.5)
        add:setTag(1)
        add:setPosition(size.width * 0.5, size.height * 0.5)
        goodsImg:addChild(add)

        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if self.data.currPanel == EQUIPMENT_VIEW then
                return false
            end

            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end

        local function onTouchEnd(touch, event)
            local target = event:getCurrentTarget()
            local tag = target:getTag()

            -- 判断该位置是否已有装备
            if self.data.trumpUpgrade.goodsImgTabs[tag].isHaveEquip then
                self:removeGoodsFromShow(tag, true)
            else
                local trumpInfoTab = GameCache.GetTrump()
                if 0 == (#trumpInfoTab) then
                    application:showFlashNotice("装备不足～")
                    return
                end

                local scene = cc.Director:getInstance():getRunningScene()
                local view = require("scene.main.hero.widget.SwallowTrumpView").new(trumpInfoTab, self.data.trumpUpgrade.chooseNum, handler(self, self.showChooseGoods))
                scene:addChild(view)
            end
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, goodsImg)
    end

    local btn_bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    btn_bg:setContentSize(cc.size(bgSize.width * 0.962, 100))
    btn_bg:setPosition(bgSize.width * 0.5, 62)
    self.controls.trumpUpgradeNode:addChild(btn_bg)
    self.controls.trumpUpgrade.btn_upgrade = createMixScale9Sprite("image/ui/img/btn/btn_593.png")
    self.controls.trumpUpgrade.btn_upgrade:setButtonBounce(false)
    self.controls.trumpUpgrade.btn_upgrade:setCircleFont("开始升级", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.controls.trumpUpgrade.btn_upgrade:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.controls.trumpUpgrade.btn_upgrade:setPosition(bgSize.width * 0.25, 62)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.btn_upgrade)
    self.controls.trumpUpgrade.btn_upgrade:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside and self.data.isCanUpgrade then
            if GameCache.Avatar.Coin < self.data.trumpUpgrade.currPrice then
                application:showFlashNotice("银币不足")
            else
                local equipConfig = BaseConfig.GetEquip(self.data.equipInfo.ID ,0)
                self.data.addTrumpExp = self.data.trumpUpgrade.currExp

                local trumpList = {}
                for i=1,6 do
                    if self.data.trumpUpgrade.goodsImgTabs[i].isHaveEquip then
                        local imgChild = self.data.trumpUpgrade.goodsImgTabs[i].img:getChildByTag(2)
                        if imgChild then
                            local goodsInfo = imgChild:getGoodsInfo()
                            table.insert(trumpList, goodsInfo)
                        end
                    end
                end
                if 0 == #trumpList then
                    application:showFlashNotice("请放入升级材料")
                    return
                end
                self:UpgradeTrump(self.data.heroInfo.ID, equipConfig.type, trumpList, self.data.trumpUpgrade.currPrice)
            end
        end
    end)

    self.controls.trumpUpgrade.btn_auto = createMixScale9Sprite("image/ui/img/btn/btn_593.png")
    self.controls.trumpUpgrade.btn_auto:setButtonBounce(false)
    self.controls.trumpUpgrade.btn_auto:setCircleFont("自动添加", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.controls.trumpUpgrade.btn_auto:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.controls.trumpUpgrade.btn_auto:setPosition(bgSize.width * 0.75, 62)
    self.controls.trumpUpgradeNode:addChild(self.controls.trumpUpgrade.btn_auto)
    self.controls.trumpUpgrade.btn_auto:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            local equipInfoTab = {}
            equipInfoTab = GameCache.GetTrump()
            table.sort(equipInfoTab, handler(self, self.trumpSort))

            for i=1,6 do
                local goodsImgTab = self.data.trumpUpgrade.goodsImgTabs[i]
                -- 先判断是否包裹里是否有装备，再判断该位置是否已有装备
                local equipInfo = equipInfoTab[1]
                if equipInfo then
                    if not goodsImgTab.isHaveEquip then
                        goodsImgTab.isHaveEquip = true
                        self.data.trumpUpgrade.chooseNum = self.data.trumpUpgrade.chooseNum + 1
                        self:addGoodsToShow(goodsImgTab.img, equipInfo)
                        equipInfoTab = self:removeGoodsFromEquipList(equipInfo, equipInfoTab)
                    end
                else
                    application:showFlashNotice("装备不足～")
                    break
                end
            end
        end
    end)
end

function EquipIntensify:trumpSort(a, b)
    local aConfig = BaseConfig.GetEquip(a.ID, a.StarLevel)
    local bConfig = BaseConfig.GetEquip(b.ID, b.StarLevel)
    if aConfig.type == bConfig.type then
        if aConfig.starLevel == bConfig.starLevel then
            if aConfig.talent == bConfig.talent then
                return a.ID < b.ID
            else
                return aConfig.talent < bConfig.talent
            end
        else
            return aConfig.starLevel < bConfig.starLevel
        end
    else
        return aConfig.type < bConfig.type
    end
end

function EquipIntensify:showChooseGoods(num, chooseGoodsTabs)
    self.data.trumpUpgrade.chooseNum = num
    for k,v in pairs(chooseGoodsTabs) do
        for k1,v1 in pairs(self.data.trumpUpgrade.goodsImgTabs) do
            if not v1.isHaveEquip then
                v1.isHaveEquip = true
                local addSpriChild = self.data.trumpUpgrade.goodsImgTabs[k].img:getChildByTag(1)
                addSpriChild:setScale(0)

                self:addGoodsToShow(v1.img, v)
                break
            end
        end
    end
end

function EquipIntensify:removeGoodsFromEquipList(goodsInfo, equipInfoTab)
    for k,v in pairs(equipInfoTab) do
        if v.ID == goodsInfo.ID then
            v.Num = v.Num - 1
            if v.Num < 1 then
                table.remove(equipInfoTab, k)
                break
            end
        end
    end

    GameCache.minusEquip(goodsInfo.ID, goodsInfo.StarLevel, 0)
    return equipInfoTab
end

function EquipIntensify:addGoodsToShow(img_bg, equipInfo)
    local imgChild = img_bg:getChildByTag(2)
    if imgChild then
        imgChild:setGoodsInfo(equipInfo)
        imgChild:setScale(1)
    else
        local equipItem = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, equipInfo, BaseConfig.GOODS_MIDDLETYPE)
        equipItem:setTouchEnable(false)
        equipItem:setPosition(img_bg:getContentSize().width * 0.5, img_bg:getContentSize().height * 0.5)
        equipItem:setTag(2)
        equipItem:setScale(1)
        img_bg:addChild(equipItem)
    end

    local config = BaseConfig.GetEquip(equipInfo.ID, 0)
    local value = BaseConfig.GetConsumeTrumpGainExp(config.talent)
    self.data.trumpUpgrade.currPrice = self.data.trumpUpgrade.currPrice + value
    self.data.trumpUpgrade.currExp = self.data.trumpUpgrade.currExp + value
    self.controls.trumpUpgrade.price:setString(self.data.trumpUpgrade.currPrice)
    self.controls.trumpUpgrade.exp:setString(self.data.trumpUpgrade.currExp)
end

function EquipIntensify:removeGoodsFromShow(slotID, isAddEquipList)
    if self.data.trumpUpgrade.goodsImgTabs[slotID].isHaveEquip then
        self.data.trumpUpgrade.goodsImgTabs[slotID].isHaveEquip = false
        local addSpriChild = self.data.trumpUpgrade.goodsImgTabs[slotID].img:getChildByTag(1)
        addSpriChild:setScale(1.5)

        self.data.trumpUpgrade.chooseNum = self.data.trumpUpgrade.chooseNum - 1
        local imgChild = self.data.trumpUpgrade.goodsImgTabs[slotID].img:getChildByTag(2)
        if imgChild then
            local goodsInfo = imgChild:getGoodsInfo()
            if isAddEquipList then
                GameCache.addEquip(goodsInfo.ID, goodsInfo.StarLevel, 1)
            end
            imgChild:setScale(0)

            local config = BaseConfig.GetEquip(goodsInfo.ID, 0)
            local value = BaseConfig.GetConsumeTrumpGainExp(config.talent)
            self.data.trumpUpgrade.currPrice = self.data.trumpUpgrade.currPrice - value
            self.data.trumpUpgrade.currExp = self.data.trumpUpgrade.currExp - value
            self.controls.trumpUpgrade.price:setString(self.data.trumpUpgrade.currPrice)
            self.controls.trumpUpgrade.exp:setString(self.data.trumpUpgrade.currExp)
        end
    end
end

function EquipIntensify:setLevelBar(dt)
    if self.data.isUpgrade then
        local equipTab = self.data.heroInfo.Equip
        local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)

        local maxLevelExp = BaseConfig.GetTrumpUpgrade(equipTab[equipConfigInfo.type].Level).exp
        local needAddExp = math.floor(maxLevelExp / 10)
        self.data.addTrumpExp = self.data.addTrumpExp - needAddExp
        self.data.equipInfo.Exp = self.data.equipInfo.Exp + needAddExp
        self.controls.trumpUpgrade.bar_heroLevel:setPercent(self.data.equipInfo.Exp / maxLevelExp * 100)

        if self.data.addTrumpExp <= 0 then
            self.data.isUpgrade = false
            self.data.equipInfo.Exp = self.data.equipInfo.Exp + self.data.addTrumpExp
            self.controls.trumpUpgrade.bar_heroLevel:setPercent(self.data.equipInfo.Exp / maxLevelExp * 100)
        end
        if self.data.equipInfo.Exp >= maxLevelExp then
            equipTab[equipConfigInfo.type].Level = equipTab[equipConfigInfo.type].Level + 1
            self:updateEquipWear(equipConfigInfo.type, equipTab[equipConfigInfo.type])
            local heroValue = GameCache.GetHero(self.data.heroInfo.ID)
            if heroValue then
                heroValue.Equip[equipConfigInfo.type].Level = equipTab[equipConfigInfo.type].Level
                if self.data.isFromHeroLayer then
                    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateWearEquip, {EquipType = equipConfigInfo.type, EquipTabs = heroValue.Equip})
                end
            end
            
            if equipTab[equipConfigInfo.type].Level >= 20 then
                self.data.isUpgrade = false
            else
                self.data.equipInfo.Exp = self.data.equipInfo.Exp - maxLevelExp
            end
            if nil == self.controls.trumpUpgrade.upgradeEffect then
                local size = self.controls.equipUpgrade.chooseEquip:getContentSize()
                self.controls.trumpUpgrade.upgradeEffect = effects:CreateAnimation(self.controls.trumpUpgrade.img_trump, 0, 0, nil, 20, false)
                self.controls.trumpUpgrade.upgradeEffect:setScale(0.85)
                self.controls.trumpUpgrade.upgradeEffect:setLocalZOrder(10)
            else
                effects:RepeatAnimation(self.controls.trumpUpgrade.upgradeEffect)
            end
            self:updateTrumpUpgrade()
        end
    end
end

--[[
    currPanel
        -- 1表示equip界面，2表示trump界面
]]--
function EquipIntensify:setShowUI(currPanel, heroInfo, equipInfo)
    local panel = currPanel or self.data.currPanel
    self.data.heroInfo = heroInfo or self.data.heroInfo
    self.data.equipInfo = equipInfo or self.data.equipInfo

    self:updateHeroDetail()
    for i=1,6 do
        self:updateEquipWear(i, self.data.heroInfo.Equip[i])
    end
    if panel == EQUIPMENT_VIEW then
        self.data.currPanel = EQUIPMENT_VIEW
        if self.data.currEquipPanel == EQUIPUPGRADE_VIEW then
            self.controls.equipUpgradeNode:setScale(1)
            self.controls.equipUpgrade.btn_upgrade:setTouchEnable(true)
            self.controls.equipUpgrade.btn_quickUpgrade:setTouchEnable(true)

            self.controls.equipStarNode:setScale(0)
            self.controls.equipStar.btn_upgrade:setTouchEnable(false)
            self.controls.btn_equipUpgrade:setTouchStatus()
            self.controls.btn_equipStar:setNormalStatus()
        elseif self.data.currEquipPanel == EQUIPSTAR_VIEW then
            self.controls.equipUpgradeNode:setScale(0)
            self.controls.equipUpgrade.btn_upgrade:setTouchEnable(false)
            self.controls.equipUpgrade.btn_quickUpgrade:setTouchEnable(false)

            self.controls.equipStarNode:setScale(1)
            self.controls.equipStar.btn_upgrade:setTouchEnable(true)
            self.controls.btn_equipUpgrade:setNormalStatus()
            self.controls.btn_equipStar:setTouchStatus()
        end
        self.controls.trumpUpgradeNode:setScale(0)
        self.controls.btn_equipStar:setScale(1)

        self:updateEquipUpgrade()
        self:updateEquipStar()
    elseif panel == TRUMP_VIEW then
        self.data.currPanel = TRUMP_VIEW
        self.controls.equipUpgradeNode:setScale(0)
        self.controls.equipUpgrade.btn_upgrade:setTouchEnable(false)
        self.controls.equipUpgrade.btn_quickUpgrade:setTouchEnable(false)
        self.controls.equipStarNode:setScale(0)
        self.controls.equipStar.btn_upgrade:setTouchEnable(false)

        self.controls.trumpUpgradeNode:setScale(1)
        self.controls.btn_equipStar:setScale(0)
        self.controls.btn_equipStar:setNormalStatus()
        self.controls.btn_equipUpgrade:setTouchStatus()
        self:updateTrumpUpgrade()
    end
end

function EquipIntensify:updateHero(heroInfo, equipTabs)
    self:updateDirection()

    local equipInfo = nil
    local currPanel = nil
    for i=1,6 do
        local info = equipTabs[i]
        if info.ID ~= 0 then
            equipInfo = info
            if i < 5 then
                currPanel = 1
            else
                currPanel = 2
            end
            break
        end
    end
    self:setShowUI(currPanel, heroInfo, equipInfo)
end

function EquipIntensify:updateDirection()
    if self.data.heroSortId <= 1 then
        self.controls.btn_bgforeHero:setVisible(false)
        self.controls.btn_bgforeHero:setTouchEnable(false)
    else
        self.controls.btn_bgforeHero:setVisible(true)
        self.controls.btn_bgforeHero:setTouchEnable(true)
    end
    if self.data.heroSortId >= (#self.data.heroTabs) then
        self.controls.btn_afterHero:setVisible(false)
        self.controls.btn_afterHero:setTouchEnable(false)
    else
        self.controls.btn_afterHero:setVisible(true)
        self.controls.btn_afterHero:setTouchEnable(true)
    end
end

function EquipIntensify:updateHeroDetail()
    local heroConfigInfo = BaseConfig.GetHero(self.data.heroInfo.ID, self.data.heroInfo.StarLevel)
    local starAttr = Common.getHeroStarLevelColor(self.data.heroInfo.StarLevel)
    local nameColor = starAttr.Color
    local starNum = starAttr.StarNum
    local starDesc = starAttr.Additional

    local starLevelPath = string.format("image/icon/border/panel_border_star_%d.png", self.data.heroInfo.StarLevel)
    self.controls.heroStarLevelBg:setTexture(starLevelPath)

    self.controls.heroName:setColor(nameColor)
    self.controls.heroName:setString(heroConfigInfo.name..starDesc)
    self.controls.heroLevel:setString(self.data.heroInfo.Level)
    
    self.data.maxExp = BaseConfig.GetHeroUpgradeExp(heroConfigInfo.talent, self.data.heroInfo.Level)
    self.controls.bar_heroLevel:setPercent(self.data.heroInfo.Exp/self.data.maxExp * 100) 
end

function EquipIntensify:updateEquipWear(equipType, equipTab)
    local size = self.controls.equipWearTabs[equipType]:getContentSize()
    if equipTab.ID ~= 0 then
        local child = self.controls.equipWearTabs[equipType]:getChildByTag(equipModelLogoTAG)
        if child then   
            child:setScale(1)
            child:setGoodsInfo(equipTab, self.data.heroInfo)
        else
            child = EquipInfo.new(equipTab, self.data.heroInfo)
            child:setTag(equipModelLogoTAG)
            child:setPosition(size.width * 0.5, size.height * 0.5)
            self.controls.equipWearTabs[equipType]:addChild(child)
        end
        child:setLevel("center", equipTab.Level)

        local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
        if equipConfigInfo.type == equipType then
            child:setChooseBorderVisible(true)
        else
            child:setChooseBorderVisible(false)
        end
    else
        local child = self.controls.equipWearTabs[equipType]:getChildByTag(equipModelLogoTAG)
        if child then   
            child:setScale(0)
        end
    end
end

function EquipIntensify:updateEquipUpgrade()
    local equipTab = self.data.heroInfo.Equip
    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
    local equipUpgradeConfig = BaseConfig.GetEquipUpgrade(equipTab[equipConfigInfo.type].Level)
    local size = self.controls.equipUpgrade.chooseEquip:getContentSize()

    local function setAllScale(scale)
        local child = self.controls.equipUpgrade.chooseEquip:getChildByTag(1)
        if child then
            self.controls.equipUpgrade.chooseEquip:getChildByTag(1):setScale(scale)
        end
        self.controls.equipUpgrade.propsImg:setScale(scale)
        self.controls.equipUpgrade.priceImg:setScale(scale * 0.85)
        self.controls.equipUpgrade.propsNum:setScale(scale)
        self.controls.equipUpgrade.price:setScale(scale)
        self.controls.equipUpgrade.name:setScale(scale)
        self.controls.equipUpgrade.level:setScale(scale)
        self.controls.equipUpgrade.addlevel:setScale(scale)
        self.controls.equipUpgrade.atk:setScale(scale)
        self.controls.equipUpgrade.addatk:setScale(scale)
        self.controls.equipUpgrade.btn_upgrade:setScale(scale)
    end

    if equipTab[equipConfigInfo.type].ID ~= 0 then
        setAllScale(1)

        local child = self.controls.equipUpgrade.chooseEquip:getChildByTag(1)
        if child then
            child:setGoodsInfo(equipTab[equipConfigInfo.type])
        else
            local info = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, equipTab[equipConfigInfo.type])
            info:setTouchEnable(false)
            info:setTag(1)
            info:setPosition(size.width * 0.5, size.height * 0.5)
            self.controls.equipUpgrade.chooseEquip:addChild(info, bgZOrder)
        end

        if equipConfigInfo.type == 1 then
            self.data.equipUpgrade.needEquipCoin = equipUpgradeConfig.ArmCoin
            self.data.equipUpgrade.needPropsID = equipUpgradeConfig.ArmPropsID
            self.data.equipUpgrade.needPorpsNum = equipUpgradeConfig.ArmPropsNum
        elseif equipConfigInfo.type == 2 then
            self.data.equipUpgrade.needEquipCoin = equipUpgradeConfig.HatCoin
            self.data.equipUpgrade.needPropsID = equipUpgradeConfig.HatPropsID
            self.data.equipUpgrade.needPorpsNum = equipUpgradeConfig.HatPropsNum
        elseif equipConfigInfo.type == 3 then
            self.data.equipUpgrade.needEquipCoin = equipUpgradeConfig.RingCoin
            self.data.equipUpgrade.needPropsID = equipUpgradeConfig.RingPropsID
            self.data.equipUpgrade.needPorpsNum = equipUpgradeConfig.RingPropsNum
        elseif equipConfigInfo.type == 4 then
            self.data.equipUpgrade.needEquipCoin = equipUpgradeConfig.CoatCoin
            self.data.equipUpgrade.needPropsID = equipUpgradeConfig.CoatPropsID
            self.data.equipUpgrade.needPorpsNum = equipUpgradeConfig.CoatPropsNum
        else
            return
        end

        self.controls.equipUpgrade.propsImg:setGoodsInfo({Type = 6, ID = self.data.equipUpgrade.needPropsID})

        local starAttr = Common.getHeroStarLevelColor(self.data.equipInfo.StarLevel)
        local nameColor = starAttr.Color
        self.controls.equipUpgrade.name:setString(equipConfigInfo.name..starAttr.Additional)
        self.controls.equipUpgrade.name:setColor(nameColor)
        self.controls.equipUpgrade.level:setString("(Lv."..equipTab[equipConfigInfo.type].Level..")")
        self.controls.equipUpgrade.addlevel:setString("(Lv."..(equipTab[equipConfigInfo.type].Level + 1)..")")
        self.controls.equipUpgrade.toLevel:setPositionX(self.controls.equipUpgrade.level:getPositionX() +
                                                     self.controls.equipUpgrade.level:getContentSize().width + 20)
        self.controls.equipUpgrade.addlevel:setPositionX(self.controls.equipUpgrade.toLevel:getPositionX() +
                                                     self.controls.equipUpgrade.toLevel:getContentSize().width)
        self.controls.equipUpgrade.propsNum:setString("[239,239,168]"..Common.numConvert(self:getPropsNumByID(self.data.equipUpgrade.needPropsID)).."[=][255,255,255]/"..self.data.equipUpgrade.needPorpsNum.."[=]")
            self.controls.equipUpgrade.price:setString("[239,239,168]"..Common.numConvert(GameCache.Avatar.Coin).."[=][255,255,255]/"..Common.numConvert(self.data.equipUpgrade.needEquipCoin).."[=]")
            
        if (self:getPropsNumByID(self.data.equipUpgrade.needPropsID) >= self.data.equipUpgrade.needPorpsNum) and
            (GameCache.Avatar.Coin >= self.data.equipUpgrade.needEquipCoin) then
            
        else
            if self:getPropsNumByID(self.data.equipUpgrade.needPropsID) < self.data.equipUpgrade.needPorpsNum then
                self.controls.equipUpgrade.propsNum:setString("[249,24,24]"..Common.numConvert(self:getPropsNumByID(self.data.equipUpgrade.needPropsID)).."/"..self.data.equipUpgrade.needPorpsNum.."[=]")
            end
            if GameCache.Avatar.Coin < self.data.equipUpgrade.needEquipCoin then
                self.controls.equipUpgrade.price:setString("[249,24,24]"..Common.numConvert(GameCache.Avatar.Coin).."/"..Common.numConvert(self.data.equipUpgrade.needEquipCoin).."[=]")
            end
        end

        local equipID = equipTab[equipConfigInfo.type].ID
        local equipLevel = equipTab[equipConfigInfo.type].Level
        local equipStarLevel = equipTab[equipConfigInfo.type].StarLevel
        if equipConfigInfo.type == 1 then
            local v1 = CalHeroAttr.CalEquipAtk(equipID, equipLevel, equipStarLevel)
            local v2 = CalHeroAttr.CalEquipAtk(equipID, equipLevel+1, equipStarLevel)
            self.controls.equipUpgrade.atk:setString("攻击:".. v1)
            self.controls.equipUpgrade.addatk:setString("" .. v2)
        elseif equipConfigInfo.type == 2 then
            local v1 = CalHeroAttr.CalEquipDef(equipID, equipLevel, equipStarLevel)
            local v2 = CalHeroAttr.CalEquipDef(equipID, equipLevel+1, equipStarLevel)
            self.controls.equipUpgrade.atk:setString("防御:" .. v1)
            self.controls.equipUpgrade.addatk:setString("" .. v2)
        elseif equipConfigInfo.type == 3 then
            local v1 = CalHeroAttr.CalEquipMP(equipID, equipLevel, equipStarLevel)
            local v2 = CalHeroAttr.CalEquipMP(equipID, equipLevel+1, equipStarLevel)
            self.controls.equipUpgrade.atk:setString("法力:" .. v1)
            self.controls.equipUpgrade.addatk:setString("" .. v2)
        elseif equipConfigInfo.type == 4 then
            local v1 = CalHeroAttr.CalEquipHP(equipID, equipLevel, equipStarLevel)
            local v2 = CalHeroAttr.CalEquipHP(equipID, equipLevel+1, equipStarLevel)
            self.controls.equipUpgrade.atk:setString("生命:" .. v1)
            self.controls.equipUpgrade.addatk:setString("" .. v2)
        end
        self.controls.equipUpgrade.toAtk:setPositionX(self.controls.equipUpgrade.atk:getPositionX() +
                                                     self.controls.equipUpgrade.atk:getContentSize().width + 20)
        self.controls.equipUpgrade.addatk:setPositionX(self.controls.equipUpgrade.toAtk:getPositionX() +
                                                     self.controls.equipUpgrade.toAtk:getContentSize().width)
    else
        setAllScale(0)
    end
end

function EquipIntensify:updateEquipStar()
    local equipTab = self.data.heroInfo.Equip
    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)
    local heroEquipInfo = self.data.heroInfo.Equip[equipConfigInfo.type]
    local equipStarLevel = heroEquipInfo.StarLevel

    local function setAllScale(scale)
        self.controls.equipStar.img_stone1:setScale(scale)
        self.controls.equipStar.img_stone2:setScale(scale)
        self.controls.equipStar.img_equip:setScale(scale)
        self.controls.equipStar.img_price:setScale(scale)
        self.controls.equipStar.propsImg1:setScale(scale)
        self.controls.equipStar.propsImg2:setScale(scale)
        self.controls.equipStar.equipImg:setScale(scale)
        self.controls.equipStar.priceImg:setScale(scale * 0.85)
        self.controls.equipStar.propsNum1:setScale(scale)
        self.controls.equipStar.propsNum2:setScale(scale)
        self.controls.equipStar.equipNum:setScale(scale)
        self.controls.equipStar.price:setScale(scale)
        for i,v in ipairs(self.data.equipStar.addSpriTab) do
            v:setScale(scale)
        end
        if scale == 1 then
            self.controls.equipStar.maxStarLevel:setScale(0)
            self.controls.equipStar.btn_upgrade:setVisible(true)
            self.controls.equipStar.btn_upgrade:setTouchEnable(true)
        else
            self.controls.equipStar.btn_upgrade:setVisible(false)
            self.controls.equipStar.btn_upgrade:setTouchEnable(false)
            if self.data.equipInfo.StarLevel >= 12 then
                self.controls.equipStar.maxStarLevel:setScale(1)
            end
        end
    end

    local child = self.controls.equipStar.chooseEquip:getChildByTag(1)
    if child then
        child:setGoodsInfo(equipTab[equipConfigInfo.type])
        local equipUpgradeChild = self.controls.equipUpgrade.chooseEquip:getChildByTag(1)
        if equipUpgradeChild then
            equipUpgradeChild:setGoodsInfo(equipTab[equipConfigInfo.type])
        end
    else
        local size = self.controls.equipStar.chooseEquip:getContentSize()
        local info = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, equipTab[equipConfigInfo.type])
        info:setTouchEnable(false)
        info:setTag(1)
        info:setPosition(size.width * 0.5, size.height * 0.5)
        self.controls.equipStar.chooseEquip:addChild(info, bgZOrder)
    end
    local starData = Common.getHeroStarLevelColor(equipTab[equipConfigInfo.type].StarLevel)
    self.controls.equipStar.equipName:setString(equipConfigInfo.name..starData.Additional)
    self.controls.equipStar.equipName:setColor(starData.Color)
    local starZOrder = 1
    for i=1,(#self.data.equipStar.starTab) do
        self.data.equipStar.starTab[i]:setLocalZOrder(starZOrder)
        if i > starData.StarNum then
            self.data.equipStar.starTab[i]:setTouchStatus()
        else
            self.data.equipStar.starTab[i]:setNormalStatus()
            if (i == starData.StarNum) and self.data.isPlayStarAnim then
                self.data.equipStar.starTab[i]:setLocalZOrder(starZOrder + 1)
                self.data.isPlayStarAnim = false
                self.data.equipStar.starTab[i]:setScale(5)
                local scale1 = cc.ScaleTo:create(0.2, 1)
                local scale2 = cc.ScaleTo:create(0.1, 1.3)
                local scale3 = cc.ScaleTo:create(0.05, 1)
                self.data.equipStar.starTab[i]:runAction(cc.Sequence:create(scale1, scale2, scale3))
            end
        end
    end
    if (heroEquipInfo.ID ~= 0) and (equipStarLevel < 12) then
        setAllScale(1)
        local equipStarCommonConfig = BaseConfig.GetEquipUpstarCommon(equipStarLevel + 1)
        local equipStarSpecialConfig = BaseConfig.GetEquipUpstarSpecial(heroEquipInfo.ID, equipStarLevel + 1)
        
        self.data.equipStar.needLevel = equipStarCommonConfig.Level
        self.data.equipStar.needStone1ID = equipStarCommonConfig.PropsID
        self.data.equipStar.needStone1Num = equipStarCommonConfig.PropsNum
        self.data.equipStar.needStone2ID = equipStarSpecialConfig.PropsID
        self.data.equipStar.needStone2Num = equipStarSpecialConfig.PropsNum
        self.data.equipStar.needPrice = equipStarCommonConfig.Coin
        self.data.equipStar.needFragID = equipStarSpecialConfig.FragID
        self.data.equipStar.needFragNum = equipStarSpecialConfig.FragNum

        self.controls.equipStar.propsImg1:setGoodsInfo({Type = 6, ID = self.data.equipStar.needStone1ID})
        self.controls.equipStar.propsImg2:setGoodsInfo({Type = 6, ID = self.data.equipStar.needStone2ID})

        local allStone1Num = self:getPropsNumByID(self.data.equipStar.needStone1ID)
        self.controls.equipStar.propsNum1:setString("[239,239,168]"..Common.numConvert(allStone1Num).."[=][255,255,255]/"..self.data.equipStar.needStone1Num.."[=]")
        local allStone2Num = self:getPropsNumByID(self.data.equipStar.needStone2ID)
        self.controls.equipStar.propsNum2:setString("[239,239,168]"..Common.numConvert(allStone2Num).."[=][255,255,255]/"..self.data.equipStar.needStone2Num.."[=]")
        self.controls.equipStar.price:setString("[239,239,168]"..Common.numConvert(GameCache.Avatar.Coin).."[=][255,255,255]/"..Common.numConvert(self.data.equipStar.needPrice).."[=]")

        self.data.equipStar.totalPropsNum = 0
        if self.data.equipStar.needFragNum == 0 then
            self.data.playLightNum = 3
            self.controls.equipStar.equipImg:setScale(0)
            self.controls.equipStar.equipNum:setScale(0)
        else
            self.data.playLightNum = 4
            local propsInfoTemp = GameCache.GetFrag(self.data.equipStar.needFragID)
            if propsInfoTemp then
                self.data.equipStar.totalPropsNum = propsInfoTemp.Num
            end
            self.controls.equipStar.equipNum:setString("[239,239,168]"..Common.numConvert(self.data.equipStar.totalPropsNum).."[=][255,255,255]/"..self.data.equipStar.needFragNum.."[=]")

            local propsInfo = {}
            propsInfo.Type = BaseConfig.GT_PROPS
            propsInfo.ID = self.data.equipStar.needFragID
            self.controls.equipStar.equipImg:setGoodsInfo(propsInfo)
        end

        if (GameCache.Avatar.Coin >= self.data.equipStar.needPrice) and
            (self:getPropsNumByID(self.data.equipStar.needStone1ID) >= self.data.equipStar.needStone1Num) and
            (self:getPropsNumByID(self.data.equipStar.needStone2ID) >= self.data.equipStar.needStone2Num) and
            (self.data.equipStar.totalPropsNum >= self.data.equipStar.needFragNum) then

        else
            if GameCache.Avatar.Coin < self.data.equipStar.needPrice then
                self.controls.equipStar.price:setString("[249,24,24]"..Common.numConvert(GameCache.Avatar.Coin).."/"..Common.numConvert(self.data.equipStar.needPrice).."[=]")
            end
            if self:getPropsNumByID(self.data.equipStar.needStone1ID) < self.data.equipStar.needStone1Num then
                self.controls.equipStar.propsNum1:setString("[249,24,24]"..Common.numConvert(allStone1Num).."/"..self.data.equipStar.needStone1Num.."[=]")
            end
            if self:getPropsNumByID(self.data.equipStar.needStone2ID) < self.data.equipStar.needStone2Num then
                self.controls.equipStar.propsNum2:setString("[249,24,24]"..Common.numConvert(allStone2Num).."/"..self.data.equipStar.needStone2Num.."[=]")
            end
            if self.data.equipStar.totalPropsNum < self.data.equipStar.needFragNum then
                self.controls.equipStar.equipNum:setString("[249,24,24]"..Common.numConvert(self.data.equipStar.totalPropsNum).."/"..self.data.equipStar.needFragNum.."[=]")
            end
        end
    else
        setAllScale(0)
    end
end

function EquipIntensify:updateTrumpUpgrade()
    local equipTab = self.data.heroInfo.Equip
    local equipConfigInfo = BaseConfig.GetEquip(self.data.equipInfo.ID, self.data.equipInfo.StarLevel)

    local currLevel = equipTab[equipConfigInfo.type].Level
    if currLevel >= 20 then
        self.controls.trumpUpgrade.btn_upgrade:setScale(0)
        self.controls.trumpUpgrade.btn_auto:setScale(0)
        self.controls.trumpUpgrade.bar_BG:setScale(0)
        self.controls.trumpUpgrade.bar_heroLevel:setScale(0)
        self.controls.trumpUpgrade.addlevel:setScale(0)
        self.controls.trumpUpgrade.addatk:setScale(0)
        self.controls.trumpUpgrade.adddef:setScale(0)
        self.controls.trumpUpgrade.toLevel:setScale(0)
        self.controls.trumpUpgrade.toAtk:setScale(0)
        self.controls.trumpUpgrade.toDef:setScale(0)
    else
        self.controls.trumpUpgrade.btn_upgrade:setScale(1)
        self.controls.trumpUpgrade.btn_auto:setScale(1)
        self.controls.trumpUpgrade.bar_BG:setScale(1)
        self.controls.trumpUpgrade.bar_heroLevel:setScale(1)
        self.controls.trumpUpgrade.addlevel:setScale(1)
        self.controls.trumpUpgrade.addatk:setScale(1)
        self.controls.trumpUpgrade.adddef:setScale(1)
        self.controls.trumpUpgrade.toLevel:setScale(1)
        self.controls.trumpUpgrade.toAtk:setScale(1)
        self.controls.trumpUpgrade.toDef:setScale(1)
    end

    self.controls.trumpUpgrade.img_trump:setGoodsInfo(self.data.equipInfo)
    local starData = Common.getHeroStarLevelColor(self.data.equipInfo.StarLevel)
    self.controls.trumpUpgrade.name:setString(equipConfigInfo.name..starData.Additional)
    self.controls.trumpUpgrade.name:setColor(starData.Color)
    if currLevel >= 20 then
        self.controls.trumpUpgrade.level:setString("(Lv."..(equipTab[equipConfigInfo.type].Level)..")")
        local currDesc = Common.getEquipExtraDesc(equipConfigInfo, currLevel, "[255,255,255]", "[255,255,255]")
        self.controls.trumpUpgrade.atk:setString(currDesc[1])
        self.controls.trumpUpgrade.def:setString(currDesc[2])
        return
    end
    local maxExp = BaseConfig.GetTrumpUpgrade(currLevel).exp
    self.controls.trumpUpgrade.bar_heroLevel:setPercent(self.data.equipInfo.Exp / maxExp * 100)
    self.controls.trumpUpgrade.level:setString("(Lv."..(equipTab[equipConfigInfo.type].Level)..")")
    self.controls.trumpUpgrade.addlevel:setString("(Lv."..(currLevel + 1)..")")
    self.controls.trumpUpgrade.toLevel:setPositionX(self.controls.trumpUpgrade.level:getPositionX() +
                                                     self.controls.trumpUpgrade.level:getContentSize().width + 15)
    self.controls.trumpUpgrade.addlevel:setPositionX(self.controls.trumpUpgrade.toLevel:getPositionX() +
                                                     self.controls.trumpUpgrade.toLevel:getContentSize().width)
    local currDesc = Common.getEquipExtraDesc(equipConfigInfo, currLevel, "[255,255,255]", "[255,255,255]")
    local nextDesc = Common.getEquipExtraDesc(equipConfigInfo, currLevel + 1, "[78,255,0]", "[78,255,0]")
    self.controls.trumpUpgrade.atk:setString(currDesc[1])
    self.controls.trumpUpgrade.addatk:setString(nextDesc[1])
    self.controls.trumpUpgrade.toAtk:setPositionX(self.controls.trumpUpgrade.atk:getPositionX() +
                                                     self.controls.trumpUpgrade.atk:getContentSize().width + 15)
    self.controls.trumpUpgrade.addatk:setPositionX(self.controls.trumpUpgrade.toAtk:getPositionX() +
                                                     self.controls.trumpUpgrade.toAtk:getContentSize().width)
    self.controls.trumpUpgrade.def:setString(currDesc[2])
    self.controls.trumpUpgrade.adddef:setString(nextDesc[2])
    self.controls.trumpUpgrade.toDef:setPositionX(self.controls.trumpUpgrade.def:getPositionX() +
                                                     self.controls.trumpUpgrade.def:getContentSize().width + 15)
    self.controls.trumpUpgrade.adddef:setPositionX(self.controls.trumpUpgrade.toDef:getPositionX() +
                                                     self.controls.trumpUpgrade.toDef:getContentSize().width)
    self.controls.trumpUpgrade.price:setString(self.data.trumpUpgrade.currPrice)
    self.controls.trumpUpgrade.exp:setString(self.data.trumpUpgrade.currExp)
end

function EquipIntensify:getPropsNumByID(id, minusNum)
    local propsInfo = GameCache.GetProps(id)
    if propsInfo then
        if minusNum then
            GameCache.minusProps(id, minusNum)
        end
        return propsInfo.Num
    else
        return 0
    end
end

--[[ 
    升级装备
]]
function EquipIntensify:upgradeEquip(_heroID, _equipType, _coin, _propsID, _propsNum, _quickUpgradeLevel) 
    local p = {
        ID = _heroID,
        EquipType = _equipType,
        Coin = _coin,
        PropsID = _propsID,
        PropsNum = _propsNum
    }

    self.data.isCanUpgrade = false
    rpc:call("Hero.UpgradeEquip", p, function(event)
        if event.status == Exceptions.Nil then
            local beforeHeroInfo = Common.copyTab(self.data.heroInfo)
            -- 强化界面等级增加、星将界面武器等级增加、更新ownhero里面的武器等级数据再刷新武器
            self:getPropsNumByID(p.PropsID, p.PropsNum)
        
            local heroValue = GameCache.GetHero(self.data.heroInfo.ID)
            if heroValue then
                if _quickUpgradeLevel then
                    heroValue.Equip[p.EquipType].Level = _quickUpgradeLevel
                else
                    heroValue.Equip[p.EquipType].Level = heroValue.Equip[p.EquipType].Level + 1
                end
                self:updateEquipWear(p.EquipType, heroValue.Equip[p.EquipType])
                local tfp = (CalHeroAttr.calHeroAttr(self.data.heroInfo)).TFP
                if self.data.isFromHeroLayer then
                    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateWearEquip, {EquipType = p.EquipType, EquipTabs = heroValue.Equip})
                end
            end

            self:updateEquipUpgrade()
            if nil == self.controls.upgradeEffect then
                local size = self.controls.equipUpgrade.chooseEquip:getContentSize()
                self.controls.upgradeEffect = effects:CreateAnimation(self.controls.equipUpgrade.chooseEquip, size.width * 0.5, size.height * 0.5, nil, 20, false)
                self.controls.upgradeEffect:setScale(0.85)
                self.controls.upgradeEffect:setLocalZOrder(10)
            else
                effects:RepeatAnimation(self.controls.upgradeEffect)
            end

            if self.data.isFromHeroLayer then
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                            {BeforeHero = beforeHeroInfo, CurrHero = self.data.heroInfo})
            end

            if self.data.intensifySound then
                Common.stopSound(self.data.intensifySound)
                self.data.intensifySound = Common.playSound("audio/effect/intensify_success.mp3")
            else
                self.data.intensifySound = Common.playSound("audio/effect/intensify_success.mp3")
            end
        end
        self.data.isCanUpgrade = true
    end)
end

--[[
    法宝升级
]]
function EquipIntensify:UpgradeTrump(heroId, trumpType, trumpList, coin)
    local idList = {}
    for i, v in ipairs(trumpList) do
        table.insert(idList, v.ID)
    end

    local p = {
        ID = heroId, 
        EquipType = trumpType, 
        List = idList,
        Coin = coin
    }

    self.data.isCanUpgrade = false
    rpc:call("Hero.UpgradeTrump", p, function(event)
        if event.status == Exceptions.Nil then
            local beforeHeroInfo = Common.copyTab(self.data.heroInfo)
            self.data.isUpgrade = true
            for i=1,6 do
                self:removeGoodsFromShow(i, false)
            end

            -- 暂时注释掉，法宝等级目前以客户端计算为主。
            -- 如果这时恰好法宝升级了，会对后面进度条计算当前法宝最大经验值造成错误
            -- local heroValue = GameCache.GetHero(self.data.heroInfo.ID)
            -- if heroValue then
            --     heroValue.Equip[p.EquipType].Level = event.result.Level
            -- end

            if self.data.isFromHeroLayer then
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                            {BeforeHero = beforeHeroInfo, CurrHero = self.data.heroInfo})
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateEquipListView, {})
            end
        end
        self.data.isCanUpgrade = true
    end)
end

-- 升星装备
function EquipIntensify:upstarEquip(_heroID, _equipType)
    local p = {
        ID = _heroID,
        EquipType = _equipType,
    }

    rpc:call("Hero.UpstarEquip", p, function(event)
        if event.status == Exceptions.Nil then
            local beforeHeroInfo = Common.copyTab(self.data.heroInfo)

            if 0 ~= self.data.equipStar.needFragNum then
                GameCache.minusFrag(self.data.equipStar.needFragID, self.data.equipStar.needFragNum)
            end

            self:getPropsNumByID(self.data.equipStar.needStone1ID, self.data.equipStar.needStone1Num)
            self:getPropsNumByID(self.data.equipStar.needStone2ID, self.data.equipStar.needStone2Num)

            local bgSize = self.controls.equipPanel_bg:getContentSize()
            local delay = cc.DelayTime:create(0.5)
            local move = cc.MoveTo:create(0.2, cc.p(bgSize.width * 0.5, bgSize.height * 0.82))
            for i=1, #self.data.equipStar.lightTab do
                self.data.equipStar.lightTab[i]:setPosition(bgSize.width * 0.14 + (i - 1) * bgSize.width * 0.24, bgSize.height * 0.42)
                if i <= self.data.playLightNum then
                    self.data.equipStar.lightTab[i]:setScale(1)
                    self.data.equipStar.lightTab[i]:runAction(cc.Sequence:create(delay:clone(), move:clone(), cc.CallFunc:create(function()
                        if i == self.data.playLightNum then
                            if nil == self.controls.equipStar.upgradeEffect then
                                self.controls.equipStar.upgradeEffect = effects:CreateAnimation(self.controls.equipStarNode, bgSize.width * 0.5, bgSize.height * 0.8, nil, 30, false)
                            else
                                effects:RepeatAnimation(self.controls.equipStar.upgradeEffect)
                            end

                            for i,v in ipairs(self.data.equipStar.lightTab) do
                                v:setScale(0)
                            end
                            local heroValue = GameCache.GetHero(self.data.heroInfo.ID)
                            if heroValue then
                                local beforeData = Common.getHeroStarLevelColor(heroValue.Equip[p.EquipType].StarLevel)
                                local afterData = Common.getHeroStarLevelColor(heroValue.Equip[p.EquipType].StarLevel + 1)
                                if afterData.StarNum > beforeData.StarNum then
                                    self.data.isPlayStarAnim = true
                                else
                                    self.data.isPlayStarAnim = false
                                end

                                heroValue.Equip[p.EquipType].StarLevel = heroValue.Equip[p.EquipType].StarLevel + 1
                                self:updateEquipWear(p.EquipType, heroValue.Equip[p.EquipType])
                                if self.data.isFromHeroLayer then
                                    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateWearEquip, {EquipType = p.EquipType, EquipTabs = heroValue.Equip})
                                end
                            end

                            self:updateEquipStar()
                            if self.data.isFromHeroLayer then
                                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                                            {BeforeHero = beforeHeroInfo, CurrHero = self.data.heroInfo})
                                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateEquipListView, {})
                            end
                            self.data.isCanUpgradeStar = true
                            self:getChildByName("swallowLayer"):removeFromParent()
                            Common.playSound("audio/effect/intensify_success.mp3")
                        end
                    end)))
                end
            end
        else
            self.data.isCanUpgradeStar = true
            self:getChildByName("swallowLayer"):removeFromParent()
        end
    end)
end

return EquipIntensify