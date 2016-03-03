local UpgradeStarPanel = class("UpgradeStarPanel", function()
    local self = cc.Node:create()
    self.controls = {}
    self.data = {}
    self.handlers = {}
    return self
end)
local effects = require("tool.helper.Effects")
local CalHeroAttr = require("tool.helper.CalHeroAttr")
local ColorLabel = require("tool.helper.ColorLabel")

function UpgradeStarPanel:ctor()
    self.data.size = cc.size(400, 560)
    self:getStarPillID()
    self:createFixedUI()
end

function UpgradeStarPanel:createFixedUI()
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(cc.size(416, 586))
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_791.png")
    detailName:setTouchEnable(false)
    detailName:setPosition(0, size.height * 0.42)
    self:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(-size.width * 0.2, size.height * 0.42)
    self:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(size.width * 0.2, size.height * 0.42)
    self:addChild(line)
    detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("需要的材料", 1, 1, 20, cc.c3b(78, 160, 190))
    detailName:setPosition(0, size.height * 0.29)
    self:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(-size.width * 0.3, size.height * 0.29)
    self:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(size.width * 0.3, size.height * 0.29)
    self:addChild(line)

    local btn_look = createMixSprite("image/ui/img/btn/btn_1004.png")
    btn_look:setPosition(size.width * 0.3, size.height * 0.35)
    self:addChild(btn_look)
    btn_look:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local starDesc = self:upgradeStarDescUI()
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(starDesc)
        end
    end)

    self.controls.maxStarLevel = Common.finalFont("已达到最大星级", 0, 0, 30, cc.c3b(255, 255, 0), 1)
    self:addChild(self.controls.maxStarLevel)

    self.data.pillImgTab = {}
    local imgZOrder = 2
    for i=1,3 do
        local s = cc.Node:create()
        s:setPosition(-size.width * 0.4, size.height * 0.1 - (i - 1) * size.height * 0.2)
        self:addChild(s)
        table.insert(self.data.pillImgTab, s)
    end
    local pillSize = cc.size(88, 88)

    local iconBg = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    iconBg:setPosition(-30, pillSize.height * 0.5)
    iconBg:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[1]:addChild(iconBg, imgZOrder)
    iconBg:setScaleX(0.95)
    iconBg:setScaleY(3.8)
    self.controls.soulImg = GoodsInfoNode.new(BaseConfig.GOODS_SOUL, {ID = 1001}, BaseConfig.GOODS_MIDDLETYPE)
    self.controls.soulImg:setTips(true)
    self.controls.soulImg:setTipsBox(true)
    self.controls.soulImg:setPosition(pillSize.width * 0.5, pillSize.height * 0.5)
    self.data.pillImgTab[1]:addChild(self.controls.soulImg, imgZOrder)
    self.controls.SoulNum = ColorLabel.new("", 20)
    self.controls.SoulNum:setPosition(pillSize.width * 1.2, pillSize.height * 0.53)
    self.controls.SoulNum:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[1]:addChild(self.controls.SoulNum, imgZOrder)
    self.controls.soulName = Common.finalFont("", pillSize.width * 1.2, pillSize.height * 0.85, 20, nil, 1)
    self.controls.soulName:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[1]:addChild(self.controls.soulName, imgZOrder)
    self.controls.soulAdd = createMixSprite("image/ui/img/btn/btn_582.png")
    self.controls.soulAdd:setButtonBounce(false)
    self.controls.soulAdd:setPosition(pillSize.width * 3.6, pillSize.height * 0.5)
    self.data.pillImgTab[1]:addChild(self.controls.soulAdd, imgZOrder)
    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_1016.png")
    bar_BG:setAnchorPoint(0, 0.5)
    bar_BG:setPosition(pillSize.width * 1.2, pillSize.height * 0.22)
    self.data.pillImgTab[1]:addChild(bar_BG, imgZOrder)
    self.controls.bar_soul = ccui.LoadingBar:create("image/ui/img/btn/btn_1017.png")
    self.controls.bar_soul:setPosition(bar_BG:getContentSize().width * 0.5, bar_BG:getContentSize().height * 0.5)
    bar_BG:addChild(self.controls.bar_soul)

    local tempPillInfo = {Type = 6, ID = self.data.currUpStarPillID}
    self.controls.upStarPillImg = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, tempPillInfo, BaseConfig.GOODS_MIDDLETYPE)
    self.controls.upStarPillImg:setTips(true)
    self.controls.upStarPillImg:setTipsBox(true)
    self.controls.upStarPillImg:setPosition(pillSize.width * 0.5, pillSize.height * 0.5)
    self.data.pillImgTab[2]:addChild(self.controls.upStarPillImg, imgZOrder)
    self.controls.UpStarPillNum = ColorLabel.new("", 20)
    self.controls.UpStarPillNum:setPosition(pillSize.width * 1.2, pillSize.height * 0.53)
    self.controls.UpStarPillNum:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[2]:addChild(self.controls.UpStarPillNum, imgZOrder)
    local upgradePill = Common.finalFont("升星丹", pillSize.width * 1.2, pillSize.height * 0.85, 20, nil, 1)
    upgradePill:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[2]:addChild(upgradePill, imgZOrder)
    self.controls.starPillAdd = createMixSprite("image/ui/img/btn/btn_582.png")
    self.controls.starPillAdd:setButtonBounce(false)
    self.controls.starPillAdd:setPosition(pillSize.width * 3.6, pillSize.height * 0.5)
    self.data.pillImgTab[2]:addChild(self.controls.starPillAdd, imgZOrder)
    self.controls.starPillAdd:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.controls.tips = require("scene.main.hero.widget.GetGoodsWayBox").new(BaseConfig.GOODS_PROPS, 
                                                            tempPillInfo,
                                                            sender)
            self.controls.tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(self.controls.tips)
        end
    end)
    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_1016.png")
    bar_BG:setAnchorPoint(0, 0.5)
    bar_BG:setPosition(pillSize.width * 1.2, pillSize.height * 0.22)
    self.data.pillImgTab[2]:addChild(bar_BG, imgZOrder)
    self.controls.bar_pill = ccui.LoadingBar:create("image/ui/img/btn/btn_1017.png")
    self.controls.bar_pill:setPosition(bar_BG:getContentSize().width * 0.5, bar_BG:getContentSize().height * 0.5)
    bar_BG:addChild(self.controls.bar_pill)

    local iconBg = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    iconBg:setPosition(-30, pillSize.height * 0.5)
    iconBg:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[3]:addChild(iconBg, imgZOrder)
    iconBg:setScaleX(0.95)
    iconBg:setScaleY(3.8)
    local controls_priceImg = cc.Sprite:create("image/icon/props/coin.png")
    controls_priceImg:setScale(0.88)
    controls_priceImg:setPosition(pillSize.width * 0.5, pillSize.height * 0.5)
    self.data.pillImgTab[3]:addChild(controls_priceImg, imgZOrder)
    self.controls.price = ColorLabel.new("", 20)
    self.controls.price:setPosition(pillSize.width * 1.2, pillSize.height * 0.53)
    self.controls.price:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[3]:addChild(self.controls.price, imgZOrder)
    local upgradePill = Common.finalFont("银币", pillSize.width * 1.2, pillSize.height * 0.85, 20, nil, 1)
    upgradePill:setAnchorPoint(0, 0.5)
    self.data.pillImgTab[3]:addChild(upgradePill, imgZOrder)
    self.controls.priceAdd = createMixSprite("image/ui/img/btn/btn_582.png")
    self.controls.priceAdd:setButtonBounce(false)
    self.controls.priceAdd:setPosition(pillSize.width * 3.6, pillSize.height * 0.5)
    self.data.pillImgTab[3]:addChild(self.controls.priceAdd, imgZOrder)
    self.controls.priceAdd:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local coinTree = require("scene.main.CoinTreeLayer").new(nil, function()
                self.data.needPrice = BaseConfig.GetHeroUpstar(self.data.chooseHeroInfo.StarLevel + 1).Coin
                self.controls.price:setString("[239,239,168]"..Common.numConvert(GameCache.Avatar.Coin).."[=][255,255,255]/"..Common.numConvert(self.data.needPrice).."[=]")
                local bar_price = (GameCache.Avatar.Coin / self.data.needPrice > 1) and 1 or (GameCache.Avatar.Coin / self.data.needPrice)
                self.controls.bar_price:setPercent(bar_price * 100)
            end)
            coinTree:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(coinTree)
        end
    end)
    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_1016.png")
    bar_BG:setAnchorPoint(0, 0.5)
    bar_BG:setPosition(pillSize.width * 1.2, pillSize.height * 0.22)
    self.data.pillImgTab[3]:addChild(bar_BG, imgZOrder)
    self.controls.bar_price = ccui.LoadingBar:create("image/ui/img/btn/btn_1017.png")
    self.controls.bar_price:setPosition(bar_BG:getContentSize().width * 0.5, bar_BG:getContentSize().height * 0.5)
    bar_BG:addChild(self.controls.bar_price)
    
    self.controls.btn_upgradeStar = createMixSprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_787.png")
    self.controls.btn_upgradeStar:setCircleFont("开始升星", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.controls.btn_upgradeStar:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.controls.btn_upgradeStar:setChildPos(0.2, 0.5)
    self.controls.btn_upgradeStar:setFontPos(0.6, 0.5)
    self.controls.btn_upgradeStar:setPosition(0, -size.height * 0.4)
    self:addChild(self.controls.btn_upgradeStar)
    self.controls.btn_upgradeStar:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if GameCache.Avatar.Coin < self.data.needPrice then
                application:showFlashNotice("银币不足")
            elseif self:getSoulNumByID(self.data.chooseHeroInfo.ID) < self.data.needSoulNum then
                application:showFlashNotice("魂魄不足")
            elseif self:getPropsNumByID(self.data.currUpStarPillID) < self.data.needUpStarPillNum then
                application:showFlashNotice("升星石不足")
            else
                self:UpstarHero(self.data.chooseHeroInfo.ID, self.data.chooseHeroInfo.ID, 
                                self.data.needSoulNum, self.data.currUpStarPillID, self.data.needUpStarPillNum, self.data.needPrice)
            end
        end
    end)
    
end

function UpgradeStarPanel:updateHeroInfo(heroInfo, configInfo)
    self.data.chooseHeroInfo = heroInfo
    self.data.chooseHeroConfigInfo = configInfo
    
    -- self:updateDesc(heroInfo.StarLevel)
    self:updatePillInfo(heroInfo.ID, heroInfo.StarLevel)
end

function UpgradeStarPanel:upgradeStarDescUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(400, 450))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local desc_rowHeight = 26
    local desc_layerHeight = 0
    local function createDescView()
        local ccSize = cc.size(bgSize.width, bgSize.height * 0.84)
        local function cellSizeForTable(table,idx) 
            for i=1,12 do
                local row,addition = Common.StringLinefeed(BaseConfig.GetHeroUpstar(i).Desc, 16)
                desc_layerHeight = desc_layerHeight + row * desc_rowHeight
            end
            return desc_layerHeight,180
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()

            local function getLayer()
                local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), ccSize.width, desc_layerHeight)
                layerColor:setAnchorPoint(0 , 0)
                layerColor:setPosition(0 , desc_layerHeight)

                local totalHeight = {}
                for i=1,12 do
                    local row,addition = Common.StringLinefeed(BaseConfig.GetHeroUpstar(i).Desc, 16)
                    if i == 1 then
                        totalHeight[1] = row * desc_rowHeight
                    else
                        totalHeight[i] = totalHeight[i - 1] + row * desc_rowHeight
                    end
                    local descHeight = desc_layerHeight - (totalHeight[i - 1] or 0)
                    local starData = Common.getHeroStarLevelColor(i)
                    local starNum = starData.StarNum
                    local additionalDesc = starData.Additional
                    
                    local bg = cc.Sprite:create("image/ui/img/bg/bg_186.png")
                    bg:setAnchorPoint(0.5, 1)
                    bg:setPosition(ccSize.width * 0.455, descHeight + 5)
                    layerColor:addChild(bg)
                    local starSpri = cc.Sprite:create("image/ui/img/btn/btn_638.png")
                    starSpri:setScale(0.58)
                    starSpri:setPosition(45, descHeight)
                    starSpri:setAnchorPoint(1, 1)
                    layerColor:addChild(starSpri)
                    local starLabel = cc.LabelAtlas:_create(starNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
                    starLabel:setScale(0.8)
                    starLabel:setTag(i)
                    starLabel:setAnchorPoint(1, 1)
                    starLabel:setPosition(starSpri:getPositionX() - starSpri:getContentSize().width * 0.5, descHeight)
                    layerColor:addChild(starLabel)
                    if "" ~= additionalDesc then
                        local additional = string.sub(additionalDesc, 2, 2)
                        local addSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
                        addSpri:setAnchorPoint(0, 1)
                        addSpri:setPosition(5, descHeight - starSpri:getContentSize().height * 0.5)
                        layerColor:addChild(addSpri)

                        local starAdd = cc.Label:createWithCharMap("image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
                        starAdd:setScale(0.8)
                        starAdd:setPosition(45, descHeight - starSpri:getContentSize().height * 0.5)
                        starAdd:setTag(i * 100)
                        starAdd:setAnchorPoint(1, 1)
                        layerColor:addChild(starAdd)
                        starAdd:setString(additional)
                    end

                    local additionLabel = Common.finalFont(addition, 50, descHeight, 20, cc.c3b(254, 241, 55))
                    additionLabel:setTag(i * 10000)
                    additionLabel:setAnchorPoint(0, 1)
                    additionLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                    layerColor:addChild(additionLabel)
                end
                layerColor:setTag(1)
                return layerColor
            end

            if nil == cell then
                cell = cc.TableViewCell:new()
                cell:addChild(getLayer())
            end
            local layerColor = cell:getChildByTag(1)
            for i=1,12 do
                local starLabel = layerColor:getChildByTag(i)
                local starAdd = layerColor:getChildByTag(i * 100)
                local additionLabel = layerColor:getChildByTag(i * 10000)
                if i <= self.data.chooseHeroInfo.StarLevel then
                    additionLabel:setColor(cc.c3b(254, 241, 55))
                else
                    additionLabel:setColor(cc.c3b(154, 171, 172))
                end
            end
            return cell
        end

        local function numberOfCellsInTableView(table)
           return 1
        end
        
        local list_upgradeDesc = cc.TableView:create(ccSize)
        list_upgradeDesc:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        list_upgradeDesc:setPosition(cc.p(12, 35))
        list_upgradeDesc:setDelegate()
        list_upgradeDesc:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        list_upgradeDesc:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        list_upgradeDesc:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        list_upgradeDesc:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        list_upgradeDesc:reloadData()  

        return list_upgradeDesc
    end
    local list = createDescView()
    bg:addChild(list, 2)
    local descHeightTab = {}
    for i=1,12 do
        local row,addition = Common.StringLinefeed(BaseConfig.GetHeroUpstar(i).Desc, 16)
        descHeightTab[i - 1] = descHeightTab[i - 1] or 0
        descHeightTab[i] = descHeightTab[i] or 0
        descHeightTab[i] = descHeightTab[i - 1] + row * desc_rowHeight
    end
    local h = descHeightTab[self.data.chooseHeroInfo.StarLevel - 1] or 0
    local moveY = -list:getContentSize().height + bgSize.height * 0.83 + h
    if moveY > 0 then
        moveY = 0
    end
    list:setContentOffset(cc.p(0, moveY), true)

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

function UpgradeStarPanel:updateDesc(starLevel)
    local descHeight = {}
    for i=1,12 do
        local row,addition = Common.StringLinefeed(BaseConfig.GetHeroUpstar(i).Desc, 15)
        descHeight[i - 1] = descHeight[i - 1] or 0
        descHeight[i] = descHeight[i] or 0
        descHeight[i] = descHeight[i - 1] + row * desc_rowHeight
    end
    if self.data.isShowUpgradeStar then
        self.data.isShowUpgradeStar = false

        desc_layerHeight = 0
        self.controls.list_upgradeDesc:reloadData()
        local h = descHeight[starLevel - 2] or 0
        local moveY = -self.controls.list_upgradeDesc:getContentSize().height + self.data.size.height * 0.42 + h
        if moveY > 0 then
            moveY = 0
        end
        self.controls.list_upgradeDesc:setContentOffset(cc.p(0, moveY), false)

        local h = descHeight[starLevel - 1]
        local moveY = -self.controls.list_upgradeDesc:getContentSize().height + self.data.size.height * 0.42 + h
        if moveY > 0 then
            moveY = 0
        end
        self.controls.list_upgradeDesc:setContentOffset(cc.p(0, moveY), true)
    else
        desc_layerHeight = 0
        self.controls.list_upgradeDesc:reloadData()
        local h = descHeight[starLevel - 1] or 0
        local moveY = -self.controls.list_upgradeDesc:getContentSize().height + self.data.size.height * 0.42 + h
        if moveY > 0 then
            moveY = 0
        end
        self.controls.list_upgradeDesc:setContentOffset(cc.p(0, moveY), false)
    end
end

function UpgradeStarPanel:updatePillInfo(heroID, starLevel)
    if starLevel < 12 then
        for k,v in pairs(self.data.pillImgTab) do
            v:setScale(1)
        end
        self.controls.btn_upgradeStar:setScale(1)
        self.controls.maxStarLevel:setScale(0)

        self.data.needSoulNum = BaseConfig.GetHeroUpstar(starLevel + 1).SoulNum
        self.data.needUpStarPillNum = BaseConfig.GetHeroUpstar(starLevel + 1).PropsNum
        self.data.needPrice = BaseConfig.GetHeroUpstar(starLevel + 1).Coin
        self.controls.soulName:setString(self.data.chooseHeroConfigInfo.name.."(魂魄)")
        self.controls.SoulNum:setString("[239,239,168]"..self:getSoulNumByID(heroID).."[=][255,255,255]/"..self.data.needSoulNum.."[=]")
        local bar_soul = (self:getSoulNumByID(heroID) / self.data.needSoulNum > 1) and 1 or (self:getSoulNumByID(heroID) / self.data.needSoulNum)
        self.controls.bar_soul:setPercent(bar_soul * 100)
        self.controls.UpStarPillNum:setString("[239,239,168]"..Common.numConvert(self:getPropsNumByID(self.data.currUpStarPillID)).."[=][255,255,255]/"..Common.numConvert(self.data.needUpStarPillNum).."[=]")
        local bar_pill = (self:getPropsNumByID(self.data.currUpStarPillID) / self.data.needUpStarPillNum > 1) and 1 or (self:getPropsNumByID(self.data.currUpStarPillID) / self.data.needUpStarPillNum)
        self.controls.bar_pill:setPercent(bar_pill * 100)
        self.controls.price:setString("[239,239,168]"..Common.numConvert(GameCache.Avatar.Coin).."[=][255,255,255]/"..Common.numConvert(self.data.needPrice).."[=]")
        local bar_price = (GameCache.Avatar.Coin / self.data.needPrice > 1) and 1 or (GameCache.Avatar.Coin / self.data.needPrice)
        self.controls.bar_price:setPercent(bar_price * 100)

        if (GameCache.Avatar.Coin >= self.data.needPrice) and 
            (self:getSoulNumByID(heroID) >= self.data.needSoulNum) and 
            (self:getPropsNumByID(self.data.currUpStarPillID) >= self.data.needUpStarPillNum) then
            if nil == self.controls.starEffect then
                local size = self.controls.btn_upgradeStar:getContentSize()
                self.controls.starEffect = effects:CreateAnimation(self.controls.btn_upgradeStar, 0, -size.height * 0.04, nil, 21, true)
                self.controls.starEffect:setScaleX(0.98)
            end
            self.controls.btn_upgradeStar:setNorGLProgram(true)
            self.controls.btn_upgradeStar:setTouchEnable(true)
        else
            if self.controls.starEffect then
                effects:DeleteAnimation(self.controls.starEffect)
                self.controls.starEffect = nil
            end
            if (self:getSoulNumByID(heroID) < self.data.needSoulNum) then
                self.controls.SoulNum:setString("[249,24,24]"..self:getSoulNumByID(heroID).."/"..self.data.needSoulNum.."[=]")
            end
            if (self:getPropsNumByID(self.data.currUpStarPillID) < self.data.needUpStarPillNum) then
                self.controls.UpStarPillNum:setString("[249,24,24]"..Common.numConvert(self:getPropsNumByID(self.data.currUpStarPillID)).."/"..Common.numConvert(self.data.needUpStarPillNum).."[=]")
            end
            if (GameCache.Avatar.Coin < self.data.needPrice) then
                self.controls.price:setString("[249,24,24]"..Common.numConvert(GameCache.Avatar.Coin).."/"..Common.numConvert(self.data.needPrice).."[=]")
            end

            self.controls.btn_upgradeStar:setNorGLProgram(false)
            self.controls.btn_upgradeStar:setTouchEnable(false)
        end
        local soulHeroInfo = {Type = BaseConfig.GOODS_MIDDLETYPE, ID = heroID}
        self.controls.soulImg:setGoodsInfo(soulHeroInfo)
        self.controls.soulImg:updateGetSource()
        self.controls.soulAdd:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.controls.tips = require("scene.main.hero.widget.GetGoodsWayBox").new(BaseConfig.GOODS_SOUL, 
                                                            soulHeroInfo,
                                                            sender)
                self.controls.tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(self.controls.tips)
            end
        end)
        self.controls.upStarPillImg:updateGetSource()
    else
        for k,v in pairs(self.data.pillImgTab) do
            v:setScale(0)
        end
        self.controls.btn_upgradeStar:setScale(0)
        self.controls.maxStarLevel:setScale(1)
    end
end

function UpgradeStarPanel:getStarPillID()
    self.data.currUpStarPillID = BaseConfig.upgradeStarPillID
end

function UpgradeStarPanel:getPropsNumByID(id, minusNum)
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

function UpgradeStarPanel:getSoulNumByID(id, minusNum)
    local soulInfo = GameCache.GetSoul(id)
    if soulInfo then
        if minusNum then
            GameCache.minusSoul(id, minusNum)
        end
        return soulInfo.Num
    else
        return 0
    end
end

--[[
    升星
]]
function UpgradeStarPanel:UpstarHero(heroID, soulID, soulNum, pillID, pillNum, price)
    rpc:call("Hero.UpstarHero", {ID = heroID, SoulID = soulID, SoulNum = soulNum,
                                PropsID = pillID, PropsNum = pillNum, Coin = price}, function(event)
        if event.status == Exceptions.Nil then
            local starLevel = event.result
            local beforeHeroInfo = Common.copyTab(self.data.chooseHeroInfo)
            self.data.chooseHeroInfo.StarLevel = starLevel
            self:getSoulNumByID(self.data.chooseHeroInfo.ID, self.data.needSoulNum)
            self:getPropsNumByID(self.data.currUpStarPillID, self.data.needUpStarPillNum)

            local upstarConfig = BaseConfig.GetHeroUpstar(self.data.chooseHeroInfo.StarLevel)
            self.data.chooseHeroInfo.TFSkillLevel = upstarConfig.TfSkill
            self.data.chooseHeroInfo.NorSkillLevel = upstarConfig.NorSkill
            self.data.chooseHeroInfo.MaxRPSkillLevel = upstarConfig.MaxRPSkill

            local tfp = (CalHeroAttr.calHeroAttr(self.data.chooseHeroInfo)).TFP
            self.data.chooseHeroInfo.TFP = beforeHeroInfo.TFP
            local function endFunc()
                Common.playSound("audio/effect/upgradeStar_success.mp3")
                application:showFlashNotice("升星成功～！")
                self.data.isShowUpgradeStar = true
                
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                                {BeforeHero = beforeHeroInfo, CurrHero = self.data.chooseHeroInfo})
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpgradeLevelAndStar, {StarLevel = self.data.chooseHeroInfo.StarLevel})
                application:dispatchCustomEvent(AppEvent.UI.Hero.IsShowAlert, {HeroInfo = self.data.chooseHeroInfo, IsUpgradeStar = true})
                self:updateHeroInfo(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)
            end

            local panel = require("scene.main.hero.widget.UpgradeSuccess").new(self.data.chooseHeroInfo, tfp, endFunc)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(panel)

        end
    end)
end
return UpgradeStarPanel


