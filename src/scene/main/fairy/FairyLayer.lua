--
-- Author: keyring
-- Date: 2014-09-18 16:03:26
--

local FairyLayer = class("FairyLayer", BaseLayer)
local scheduler = cc.Director:getInstance():getScheduler()
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

local BIGFAIRYTAG = 10
-- 仙女总数
local FairyTotal = 7
local FairyExcitieTime = 8
local bigFairyZorder = 2
local critZorder = bigFairyZorder + 1

local MaxBuyHeartCount = 160

local MAXCRITNUM_1 = nil
local MAXCRITNUM_2 = nil
local MAXCRITNUM_3 = nil
local MAXCRITNUM_4 = nil
local CRITSCORE_1 = nil
local CRITSCORE_2 = nil
local CRITSCORE_3 = nil
local CRITSCORE_4 = nil
local CRTICHANCE_1 = nil
local CRTICHANCE_2 = nil
local CRTICHANCE_3 = nil
local CRTICHANCE_4 = nil
local MAXCRITMULTIPLE_1 = nil
local MAXCRITMULTIPLE_2 = nil
local MAXCRITMULTIPLE_3 = nil
local MAXCRITMULTIPLE_4 = nil

local AttrNameTab = {Hit = "命中", Miss = "闪避", Hp = "生命", Atk = "攻击", 
                    AtkHpRecover = "吸血", Mp = "法力", Def = "防御"}

function FairyLayer:ctor(data)
    self.data.critScore = data.Score
    self.data.dailyBuySPCount = data.DailyBuySPCount
    self:critDataInit(data.CritTimes)

    self.data.fairyGiftTabs = self:getFairyGiftTab()
    self.data.allFairyConfig = BaseConfig.AllFairyConfig()

    self.data.ownFairyInfoTabs = GameCache.AllFairy
    self.data.unOwnFairyInfoTabs = {}
    self.data.fairyMaxLevel = #(BaseConfig.getFairyExpConfig()) + 1
    self.data.maxSkillLevel = 30
    self.data.currPropsID = 0
    self.data.currPropsNum = 0
    self.data.critMultipleTab = {}

    self.data.allFairyAnimInfoTabs = {}
    self.data.currFairyNumber = 1
    self.controls.beforeFairyAnim = nil
    self.controls.currFairyAnimInfo = nil
    self.controls.isCanUpgradeSkill = true

    self:filtrateFairy()
    self:createUI()
    self:updateFairyAnim(1)

    self:addListener()
    self.controls.giftView:reloadData()
end

function FairyLayer:onExit()
    FairyLayer.super.onExit(self)
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
    scheduler:unscheduleScriptEntry(self.controls.fairyAnimScheduler)
end

function FairyLayer:addListener()
    self.listeners = {}
    local listener = application:addEventListener(AppEvent.UI.Fairy.UpdateFairyInfo, function(event)
        local result = event.data
        local propsID = result.ID
        local expValue = result.Value

        local critMultiple, critScore = self:isFairyCrit()
        if 0 ~= critMultiple then
            local number = math.random(1, 2)
            local path = string.format("audio/fairy/xn_%02d.mp3", number)
            Common.playSound(path)
            self:fairyExciteAction(critMultiple)

            GameCache.Avatar.FairySkillPoint = GameCache.Avatar.FairySkillPoint + critMultiple
            self.controls.heartNum:setString(Common.numConvert(GameCache.Avatar.FairySkillPoint))

            local crit = {}
            crit[1] = critMultiple
            crit[2] = critScore
            table.insert(self.data.critMultipleTab, crit)
        end
        self.data.critScore = self.data.critScore + expValue
        self.data.currPropsID = propsID
        self.data.currPropsNum = self.data.currPropsNum + 1

        if self.data.currFairyInfo.Level < self.data.fairyMaxLevel then
            self.data.currFairyInfo.Exp = self.data.currFairyInfo.Exp + expValue    
            local fairyUpgradeExp = BaseConfig.getFairyExp(self.data.currFairyInfo.Level)
            if self.data.currFairyInfo.Exp >= fairyUpgradeExp then
                self.data.currFairyInfo.Exp = self.data.currFairyInfo.Exp - fairyUpgradeExp
                self.data.currFairyInfo.Level = self.data.currFairyInfo.Level + 1
                if self.data.currFairyInfo.Level >= self.data.fairyMaxLevel then
                    for i,item in pairs(self.data.fairyGiftItemTabs) do
                        if item:isEqualID(propsID) then
                            item:setIsContinueEat(false)
                        end
                        item:setTouchEnable(false)
                    end
                    self.data.currFairyInfo.Exp = 0
                    application:dispatchCustomEvent(AppEvent.UI.Fairy.Upgrade, {ID = self.data.currPropsID})
                end
            end
            self:updateFairyInfo(self.data.currFairyNumber)
        end
        
    end)
    table.insert(self.listeners, listener)
    local listener = application:addEventListener(AppEvent.UI.Fairy.UpdateGiftView, function(event)
        local result = event.data
        local propsID = result.ID
        for k,v in pairs(self.data.fairyGiftTabs) do
            if propsID == v.ID then
                table.remove(self.data.fairyGiftTabs, k)
                GameCache.minusProps(v.ID, 0)
                self.controls.giftView:reloadData()
            end
        end
    end)
    table.insert(self.listeners, listener)
    local listener = application:addEventListener(AppEvent.UI.Fairy.Upgrade, function(event)
        self:UpgradeFairy()
    end)
    table.insert(self.listeners, listener)
end

function FairyLayer:critDataInit(critTimes)
    local fairyCritConfig = BaseConfig.getFairyCritConfig()
    MAXCRITNUM_1 = fairyCritConfig[1].MaxCritCount
    MAXCRITNUM_2 = fairyCritConfig[2].MaxCritCount
    MAXCRITNUM_3 = fairyCritConfig[3].MaxCritCount
    MAXCRITNUM_4 = fairyCritConfig[4].MaxCritCount
    CRITSCORE_1 = fairyCritConfig[1].MaxScore
    CRITSCORE_2 = fairyCritConfig[2].MaxScore
    CRITSCORE_3 = fairyCritConfig[3].MaxScore
    CRITSCORE_4 = fairyCritConfig[4].MaxScore
    CRTICHANCE_1 = math.floor((fairyCritConfig[1].CritChance) / 100)
    CRTICHANCE_2 = math.floor((fairyCritConfig[2].CritChance) / 100)
    CRTICHANCE_3 = math.floor((fairyCritConfig[3].CritChance) / 100)
    CRTICHANCE_4 = math.floor((fairyCritConfig[4].CritChance) / 100)
    MAXCRITMULTIPLE_1 = fairyCritConfig[1].MaxCritMultiple
    MAXCRITMULTIPLE_2 = fairyCritConfig[2].MaxCritMultiple
    MAXCRITMULTIPLE_3 = fairyCritConfig[3].MaxCritMultiple
    MAXCRITMULTIPLE_4 = fairyCritConfig[4].MaxCritMultiple

    self.data.currCritNum_1 = 0
    self.data.currCritNum_2 = 0
    self.data.currCritNum_3 = 0
    self.data.currCritNum_4 = 0

    if self.data.critScore < CRITSCORE_1 then
        self.data.currCritNum_1 = critTimes
    elseif self.data.critScore < CRITSCORE_2 then
        self.data.currCritNum_2 = critTimes
    elseif self.data.critScore < CRITSCORE_3 then
        self.data.currCritNum_3 = critTimes
    elseif self.data.critScore < CRITSCORE_4 then
        self.data.currCritNum_4 = critTimes
    end
end

function FairyLayer:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_177.png")
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    local poolAnim = sp.SkeletonAnimation:create("image/spine/fairy/pool/skeleton.skel", "image/spine/fairy/pool/skeleton.atlas")
    poolAnim:setPosition(self.data.bgSize.width * 0.7, self.data.bgSize.height * 0.88)
    self.controls.bg:addChild(poolAnim)
    poolAnim:setAnimation(0, "animation", true)

    local heartBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_01.png")
    local heartSize = cc.size(200, 50)
    heartBg:setContentSize(heartSize)
    heartBg:setPosition(self.data.bgSize.width * 0.18, self.data.bgSize.height * 0.92)
    self.controls.bg:addChild(heartBg, bigFairyZorder)

    local hearSpri = cc.Sprite:create("image/ui/img/btn/btn_507.png")
    hearSpri:setPosition(heartSize.width * 0.2, heartSize.height * 0.5)
    heartBg:addChild(hearSpri, bigFairyZorder)

    self.controls.heartNum = Common.finalFont(Common.numConvert(GameCache.Avatar.FairySkillPoint), 1, 1, 25, nil, 1)
    self.controls.heartNum:setAnchorPoint(0, 0.5)
    self.controls.heartNum:setPosition(heartSize.width * 0.3, heartSize.height * 0.5)
    heartBg:addChild(self.controls.heartNum, bigFairyZorder)

    local addHeart = ccui.Button:create("image/ui/img/bg/add.png")
    addHeart:setPosition(heartSize.width * 0.9, heartSize.height * 0.5)
    heartBg:addChild(addHeart, bigFairyZorder)
    addHeart:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addHeartPanel()
        end
    end)

    local giftBg = cc.Sprite:create("image/ui/img/bg/bg_119.png")
    giftBg:setAnchorPoint(0.5, 0)
    giftBg:setPosition(self.data.bgSize.width * 0.5, -10)
    self.controls.bg:addChild(giftBg)
    local giftBgSize = giftBg:getContentSize()

    self.controls.fairyName = Common.finalFont(" " , 1, 1, 25, nil, 1)
    self.controls.fairyName:setAnchorPoint(1, 0.5)
    self.controls.fairyName:setPosition(giftBgSize.width * 0.52, giftBgSize.height * 0.89)
    giftBg:addChild(self.controls.fairyName)

    self.controls.fairyLevel = Common.finalFont(" ", 1, 1, 22, nil, 1)
    self.controls.fairyLevel:setAnchorPoint(0, 0.5)
    self.controls.fairyLevel:setAdditionalKerning(-2)
    self.controls.fairyLevel:setPosition(giftBgSize.width * 0.53, giftBgSize.height * 0.89)
    giftBg:addChild(self.controls.fairyLevel)

    self.controls.fairyAttrDesc = Common.finalFont(" ", 1, 1, 20, cc.c3b(0, 255, 0), 1)
    self.controls.fairyAttrDesc:setAdditionalKerning(-2)
    self.controls.fairyAttrDesc:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.78)
    giftBg:addChild(self.controls.fairyAttrDesc)

    self.controls.skill1 = createMixSprite("image/icon/border/border_star_3.png", nil,  "image/icon/skill/sk_1001.png")
    local skillBg = self.controls.skill1:getBg()
    skillBg:setScale(0.9)
    self.controls.skill1:setPosition(giftBgSize.width * 0.2, giftBgSize.height * 0.98)
    giftBg:addChild(self.controls.skill1)
    self.controls.skill1Name = Common.finalFont(" ", 1, 1, 25, nil, 1)
    self.controls.skill1Name:setPosition(giftBgSize.width * 0.2, giftBgSize.height * 0.73)
    giftBg:addChild(self.controls.skill1Name)
    self.controls.skill1:setButtonBounce(false)
    self.controls.skill1:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.data.currSkillIndx = 1
            local skill1ID = self.data.currFairyConfig.Skill1
            local tipsNode = self:skillInfoTips(skill1ID)
            tipsNode:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            self:addChild(tipsNode)
        end
    end)

    self.controls.skill2 = createMixSprite("image/icon/border/border_star_3.png", nil, "image/icon/skill/sk_1001.png")
    local skillBg = self.controls.skill2:getBg()
    skillBg:setScale(0.9)
    self.controls.skill2:setPosition(giftBgSize.width * 0.8, giftBgSize.height * 0.98)
    giftBg:addChild(self.controls.skill2)
    self.controls.skill2Name = Common.finalFont(" ", 1, 1, 25, nil, 1)
    self.controls.skill2Name:setPosition(giftBgSize.width * 0.8, giftBgSize.height * 0.73)
    giftBg:addChild(self.controls.skill2Name)
    self.controls.skill2:setButtonBounce(false)
    self.controls.skill2:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            Common.CloseSystemLayer({6})
            Common.OpenSystemLayer({6})
            self.data.currSkillIndx = 2
            local skill2ID = self.data.currFairyConfig.Skill2
            local tipsNode = self:skillInfoTips(skill2ID)
            tipsNode:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            self:addChild(tipsNode)
        end
    end)

    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_400.png")
    bar_BG:setScaleX(1.28)
    bar_BG:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.7)
    giftBg:addChild(bar_BG)
    self.controls.bar_rpSkillExp = ccui.LoadingBar:create("image/ui/img/btn/btn_401.png")
    self.controls.bar_rpSkillExp:setScaleX(1.5)
    self.controls.bar_rpSkillExp:setPercent(50)
    self.controls.bar_rpSkillExp:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.7)
    giftBg:addChild(self.controls.bar_rpSkillExp)

    self.controls.fairyExp = Common.finalFont("", 1, 1, 18, nil, 1)
    self.controls.fairyExp:enableOutline(cc.c4b(6,66,0,255), 2)
    self.controls.fairyExp:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.62)
    giftBg:addChild(self.controls.fairyExp)

    local left = cc.Sprite:create("image/ui/img/btn/btn_506.png")
    left:setScaleX(-1)
    left:setPosition(giftBgSize.width * 0.04, giftBgSize.height * 0.35)
    giftBg:addChild(left)
    local right = cc.Sprite:create("image/ui/img/btn/btn_506.png")
    right:setPosition(giftBgSize.width * 0.96, giftBgSize.height * 0.35)
    giftBg:addChild(right)

    self.controls.giftView = self:createGiftView(cc.size(giftBgSize.width * 0.9, 150))
    self.controls.giftView:setPosition(giftBgSize.width * 0.05, 0)
    giftBg:addChild(self.controls.giftView)

    local leftBg = cc.Sprite:create("image/ui/img/bg/bg_272.png")
    leftBg:setPosition(SCREEN_WIDTH * 0.08, SCREEN_HEIGHT * 0.5)
    self:addChild(leftBg)

    local number = 0
    for i=1,FairyTotal do
        local fairyInfo = self.data.ownFairyInfoTabs[1000 + i]
        if fairyInfo then
            number = number + 1
            local info = {}

            local skel = "image/spine/fairy/"..fairyInfo.ID.."/skeleton.skel"
            if not cc.FileUtils:getInstance():isFileExist(skel) then
                skel = "image/spine/fairy/"..fairyInfo.ID.."/skeleton.json"
            end

            info.anim = sp.SkeletonAnimation:create(skel, "image/spine/fairy/"..fairyInfo.ID.."/skeleton.atlas")
            info.anim:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.4)
            self.controls.bg:addChild(info.anim, bigFairyZorder)
            info.anim:setMix("idl_1", "atk", 0.1)
            info.anim:setMix("idl_2", "idl_1", 0.8)
            if not GameCache.isExamine then
                info.anim:setAnimation(0, "idl_1", true)
            end

            info.fairyInfo = fairyInfo
            info.isExciting = false
            info.exciteNum = 0
            info.exciteTime = FairyExcitieTime
            info.isOwn = true
            self.data.allFairyAnimInfoTabs[number] = info
            if number > 1 then
                info.anim:setOpacity(0)
            end
        end
    end
    for k,v in pairs(self.data.unOwnFairyInfoTabs) do
        number = number + 1
        local info = {}

        local skel = "image/spine/fairy/"..v.ID.."/skeleton.skel"
        if not cc.FileUtils:getInstance():isFileExist(skel) then
            skel = "image/spine/fairy/"..v.ID.."/skeleton.json"
        end

        info.anim = sp.SkeletonAnimation:create(skel, "image/spine/fairy/"..v.ID.."/skeleton.atlas")
        info.anim:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.4)
        self.controls.bg:addChild(info.anim, bigFairyZorder)
        info.anim:setAnimation(0, "idl_1", true)
        info.anim:setOpacity(0)
        info.anim:setColorFactor(cc.c4f(0, 0, 0, 1))

        info.fairyInfo = v
        self.data.allFairyAnimInfoTabs[number] = info
    end
    self.controls.fairyAnimScheduler = scheduler:scheduleScriptFunc(handler(self, self.fairyAnimScheduler), 1, false)

    local openBgSize = cc.size(400, 160)
    local openBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_250.png")
    openBg:setContentSize(openBgSize)
    openBg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.55)
    self.controls.bg:addChild(openBg, bigFairyZorder)
    openBg:setName("openBG")
    local lock = cc.Sprite:create("image/ui/img/btn/btn_258.png")
    lock:setPosition(openBgSize.width * 0.5, openBgSize.height * 0.65)
    openBg:addChild(lock)
    local openDesc = ColorLabel.new("[108,207,239]【获取条件】[=]", 20)
    openDesc:setName("openDesc")
    openDesc:setPosition(openBgSize.width * 0.5, openBgSize.height * 0.2)
    openBg:addChild(openDesc)
    self.controls.bg:getChildByName("openBG"):setLocalZOrder(-1)

    self.controls.headView = self:createFairyHeadView(cc.size(100, 420))
    self.controls.headView:setPosition(5, leftBg:getContentSize().height * 0.13)
    leftBg:addChild(self.controls.headView)

    self.controls.fairyUpgradeEff = load_animation("image/spine/skill_effect/buff/4004/", 1)
    self.controls.bg:addChild(self.controls.fairyUpgradeEff, critZorder)
    self.controls.fairyUpgradeEff:setPosition(cc.p(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.4))
    self.controls.fairyUpgradeEff:setVisible(false)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(SCREEN_WIDTH*0.95, SCREEN_HEIGHT*0.92)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
    self:addChild(btn_close)

    self:egg()
end

function FairyLayer:egg()
    local layerColor = cc.LayerColor:create(cc.c4f(0, 0, 0, 0), 50, 50)
    layerColor:setPosition(20, 20)
    self:addChild(layerColor)

    local clickNum = 0
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            clickNum = clickNum + 1
            if clickNum > 20 then
                self:fairyExciteAction(3)
            end
        end
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerColor)
end

function FairyLayer:filtrateFairy()
    local tempOwnFairy = Common.copyTab(self.data.ownFairyInfoTabs)
    
    for k,v in pairs(self.data.allFairyConfig) do
        local isOwn = false
        for k1,v1 in pairs(tempOwnFairy) do
            if v.ID == v1.ID then
                isOwn = true
                table.remove(tempOwnFairy, k1)
                break
            end
        end
        if not isOwn then
            table.insert(self.data.unOwnFairyInfoTabs, v)
        end
    end
end

function FairyLayer:createGiftView(ccSize)
    local function cellSizeForTable(table,idx) 
        local itemTotal = (#self.data.fairyGiftTabs)
        self.data.itemWidth = 105
        self.data.tabWidth = self.data.itemWidth * itemTotal

        if (self.data.tabWidth < ccSize.width) then
            table:setTouchEnabled(false)
        else
            table:setTouchEnabled(true)
        end
        return 120,self.data.tabWidth
    end

    local function tableCellAtIndex(tableView, idx)
        local cell = tableView:dequeueCell()

        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0), self.data.tabWidth, ccSize.height)
            layerColor:setAnchorPoint(0 , 0)
            layerColor:setPosition(0 , 0)

            if self.data.fairyGiftItemTabs then
                for i,item in pairs(self.data.fairyGiftItemTabs) do
                    if item then
                        item:removeFromParent()
                        item = nil
                    end
                end
            end
            self.data.fairyGiftItemTabs = {}

            for k,v in pairs(self.data.fairyGiftTabs) do
                if v.Num > 0 then
                    local item = require("scene.main.fairy.widget.FairyGiftInfo").new(v)
                    item:setPosition((k - 1) * self.data.itemWidth + item:getContentSize().width * 0.6, layerColor:getContentSize().height * 0.4)
                    layerColor:addChild(item)
                    table.insert(self.data.fairyGiftItemTabs, item)

                    if self.data.currFairyInfo then
                        if (not self.data.currFairyInfo.Level) or (self.data.currFairyInfo.Level >= self.data.fairyMaxLevel) then
                            item:setTouchEnable(false)
                            if not self.data.currFairyInfo.Level then
                                item:setFairyUnLock(false)
                            end
                        end
                    end
                end
            end
            return layerColor
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:addChild(getLayer())
        else
            cell:removeFromParent()
            cell = cc.TableViewCell:new()
            cell:addChild(getLayer())
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
       return 1
    end

    local tableView = cc.TableView:create(ccSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    tableView:setTouchEnabled(false)
    return tableView   
end

function FairyLayer:getFairyGiftTab()
    local MIN_ID = 1170
    local MAX_ID = 1175
    local propsTab = {}
    local allProps = GameCache.GetAllProps()
    for k,v in pairs(allProps) do
        local config = BaseConfig.GetProps(v.ID)
        if (config.type == 9) and ((v.ID >= MIN_ID) and (v.ID <= MAX_ID)) then
            table.insert(propsTab, v)
        end
    end

    local function propsSort(a, b)
        local aConfig = BaseConfig.GetProps(a.ID)
        local bConfig = BaseConfig.GetProps(b.ID)
        return aConfig.useValue < bConfig.useValue
    end
    table.sort(propsTab, propsSort)

    return propsTab
end

function FairyLayer:createFairyHeadView(ccSize)
    local LAYERTAG = 1
    local HEADTAG = LAYERTAG + 1
    local FAIRYBGTAG = HEADTAG + 1
    local LOGOTAG = FAIRYBGTAG + 1
    local SHADOWTAG = LOGOTAG + 1

    local function tableCellTouched(table, cell)
        print("cell touched at index: " .. cell:getIdx())
        if self.data.currFairyNumber == (cell:getIdx() + 1) then
            return 
        end

        local beforeNumberIdx = self.data.currFairyNumber - 1
        self.data.currFairyNumber = cell:getIdx() + 1
        table:updateCellAtIndex(beforeNumberIdx)
        self:updateFairyAnim(self.data.currFairyNumber)

        local layerColor = cell:getChildByTag(LAYERTAG)
        local fairyHead = layerColor:getChildByTag(HEADTAG)
        local shadow = layerColor:getChildByTag(SHADOWTAG)
        local fairyBg = layerColor:getChildByTag(FAIRYBGTAG)
        local fairyLogo = layerColor:getChildByTag(LOGOTAG)
        local fairyConfig = nil
        local openBG = self.controls.bg:getChildByName("openBG")
        if self.data.allFairyAnimInfoTabs[cell:getIdx() + 1].isOwn then
            local fairyInfo = self.data.allFairyAnimInfoTabs[cell:getIdx() + 1].fairyInfo
            fairyConfig = BaseConfig.GetFairy(fairyInfo.ID)
            openBG:setLocalZOrder(-1)
        else
            fairyConfig = self.data.allFairyAnimInfoTabs[cell:getIdx() + 1].fairyInfo

            openBG:setLocalZOrder(bigFairyZorder)
            openBG:getChildByName("openDesc"):setString("[108,207,239]【获取条件】[=][255,255,255]"..fairyConfig.Source.."[=]")
        end
        fairyBg:setTexture("image/ui/img/btn/btn_643.png")
        fairyLogo:setTexture("image/ui/img/btn/btn_1048.png")

        fairyHead:setOpacity(255)
        local time1, time2 = 0.1, 0.08
        local scale1 = cc.ScaleTo:create(time1, 1.3)
        local scale2 = cc.ScaleTo:create(time2, 1)
        fairyHead:runAction(cc.Sequence:create(scale1, scale2))

        local fadeIn = cc.FadeIn:create(time1)
        local fadeout = cc.FadeOut:create(time2 * 4)
        local scale21 = cc.ScaleTo:create(time2 * 4, 1)
        local spawn1 = cc.Spawn:create(scale1:clone(), fadeIn)
        local spawn2 = cc.Spawn:create(scale21, fadeout)
        local seq = cc.Sequence:create(spawn1, spawn2)
        shadow:runAction(seq)

        self.controls.giftView:reloadData()
    end

    local function cellSizeForTable(table,idx)
        return 140, ccSize.width
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local fairyBg = nil
        local fairyHead = nil
        local fairyLogo = nil
        local shadow = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local layerColor = cc.LayerColor:create(cc.c4b(0,0,200,0), ccSize.width, 138)
            layerColor:setTag(LAYERTAG)
            local layerSize = layerColor:getContentSize()

            fairyBg = cc.Sprite:create("image/ui/img/btn/btn_1047.png")
            fairyBg:setPosition(layerSize.width * 0.5, layerSize.height * 0.45)
            layerColor:addChild(fairyBg)
            fairyBg:setTag(FAIRYBGTAG)
            fairyHead = cc.Sprite:create("image/ui/fairy/xn_001_head.png")
            fairyHead:setAnchorPoint(0.5, 0)
            fairyHead:setPosition(layerSize.width * 0.5, layerSize.height * 0.15)
            layerColor:addChild(fairyHead)
            fairyHead:setTag(HEADTAG)
            shadow = cc.Sprite:create("image/ui/fairy/xn_001_head.png")
            shadow:setAnchorPoint(0.5, 0)
            shadow:setPosition(layerSize.width * 0.5, layerSize.height * 0.15)
            layerColor:addChild(shadow)
            shadow:setTag(SHADOWTAG)
            fairyLogo = cc.Sprite:create("image/ui/img/btn/btn_1049.png")
            fairyLogo:setPosition(layerSize.width * 0.5, layerSize.height * 0.15)
            layerColor:addChild(fairyLogo)
            fairyLogo:setTag(LOGOTAG)

            cell:addChild(layerColor)
        else
            local layerColor = cell:getChildByTag(LAYERTAG)
            fairyHead = layerColor:getChildByTag(HEADTAG)
            shadow = layerColor:getChildByTag(SHADOWTAG)
            fairyBg = layerColor:getChildByTag(FAIRYBGTAG)
            fairyLogo = layerColor:getChildByTag(LOGOTAG)
        end
        fairyHead:setScale(1)
        shadow:setScale(1)
        shadow:setOpacity(0)
        local fairyConfig = nil
        if self.data.allFairyAnimInfoTabs[idx + 1].isOwn then
            local fairyInfo = self.data.allFairyAnimInfoTabs[idx + 1].fairyInfo
            fairyConfig = BaseConfig.GetFairy(fairyInfo.ID)
            fairyHead:setColor(cc.c3b(255, 255, 255))
            shadow:setColor(cc.c3b(255, 255, 255))
        else
            fairyConfig = self.data.allFairyAnimInfoTabs[idx + 1].fairyInfo
            fairyHead:setColor(cc.c3b(0, 0, 0))
            shadow:setColor(cc.c3b(0, 0, 0))
        end
        fairyHead:setTexture("image/ui/fairy/"..fairyConfig.Res.."_head.png")
        shadow:setTexture("image/ui/fairy/"..fairyConfig.Res.."_head.png")

        if idx == (self.data.currFairyNumber - 1) then
            fairyHead:setOpacity(255)
            fairyBg:setTexture("image/ui/img/btn/btn_643.png")
            fairyLogo:setTexture("image/ui/img/btn/btn_1048.png")
        else
            fairyHead:setOpacity(100)
            fairyBg:setTexture("image/ui/img/btn/btn_1047.png")
            fairyLogo:setTexture("image/ui/img/btn/btn_1049.png")
        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        return FairyTotal
    end

    local tableView = cc.TableView:create(ccSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(10, 20))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    return tableView
end

function FairyLayer:addHeartPanel()
    local scene = cc.Director:getInstance():getRunningScene()

    local bgsize = cc.size(580,300)    
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    scene:addChild(bg)

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    layer:setLocalZOrder(-1)
    layer:setPosition(-SCREEN_WIDTH * 0.5 + bgsize.width * 0.5, -SCREEN_HEIGHT * 0.6 + bgsize.height * 0.5)
    bg:addChild(layer)

    local icon = cc.Sprite:create("image/icon/props/heart.png")
    icon:setPosition(75,bgsize.height*0.75)
    bg:addChild(icon)
    
    local label1 = ColorLabel.new("", 22)
    label1:setPosition(bgsize.width * 0.55, bgsize.height*0.75)
    bg:addChild(label1)
    label1:setString("[255,255,255]上仙,花费[=][255,207,17]元宝[=][255,255,255]获得[=][120,246,103]红心[=]")

    local costNode = cc.Node:create()
    bg:addChild(costNode, 1)
    local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    sprite:setPosition(bgsize.width*0.25, bgsize.height*0.4)
    costNode:addChild(sprite)
    sprite:setScale(0.6)
    local ssize = sprite:getContentSize()
    local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line1:setPosition(ssize.width*0.5, ssize.height)
    sprite:addChild(line1)
    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ssize.width*0.5, 0)
    sprite:addChild(line)
    icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    icon:setPosition(60,bgsize.height*0.4)
    costNode:addChild(icon)
    local costGoldLab1 = Common.finalFont("20", 1, 1, 26,cc.c3b(120,246,103))
    costGoldLab1:setPosition(115,bgsize.height*0.4)
    costNode:addChild(costGoldLab1)
    icon = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    icon:setPosition(170,bgsize.height*0.4)
    costNode:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_507.png")
    icon:setPosition(200,bgsize.height*0.4)
    costNode:addChild(icon)
    local getHeartLab1 = Common.finalFont("5", 1, 1, 26,cc.c3b(120,246,103))
    getHeartLab1:setAnchorPoint(0,0.5)
    getHeartLab1:setPosition(230,bgsize.height*0.4)
    costNode:addChild(getHeartLab1)

    local costTenNode = cc.Node:create()
    costNode:addChild(costTenNode)
    local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    sprite:setPosition(bgsize.width*0.75, bgsize.height*0.4)
    costTenNode:addChild(sprite)
    sprite:setScale(0.6)
    local ssize = sprite:getContentSize()
    local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line1:setPosition(ssize.width*0.5, ssize.height)
    sprite:addChild(line1)
    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ssize.width*0.5, 0)
    sprite:addChild(line)
    icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    icon:setPosition(350,bgsize.height*0.4)
    costTenNode:addChild(icon)
    local costGoldLab2 = Common.finalFont("20", 1, 1, 26,cc.c3b(120,246,103))
    costGoldLab2:setPosition(405,bgsize.height*0.4)
    costTenNode:addChild(costGoldLab2)
    icon = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    icon:setPosition(460,bgsize.height*0.4)
    costTenNode:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_507.png")
    icon:setPosition(490,bgsize.height*0.4)
    costTenNode:addChild(icon)
    local getHeartLab2 = Common.finalFont("10", 1, 1, 26,cc.c3b(120,246,103))
    getHeartLab2:setAnchorPoint(0,0.5)
    getHeartLab2:setPosition(520,bgsize.height*0.4)
    costTenNode:addChild(getHeartLab2)

    local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    sprite:setAnchorPoint(0.5,0)
    sprite:setPosition(bgsize.width*0.5, 10)
    bg:addChild(sprite)
    sprite:setScaleX(1.3)
    local ssize = sprite:getContentSize()
    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ssize.width*0.5, ssize.height)
    sprite:addChild(line)

    local useCountLab = Common.finalFont("", 1, 1, 20, cc.c3b(120,246,103))
    useCountLab:setPosition(bgsize.width*0.82, bgsize.height - 25)
    bg:addChild(useCountLab)

    local notice = Common.finalFont("今日次数已用完", 1, 1, 26 , nil, 1)
    notice:setPosition(bgsize.width*0.5, 45)
    bg:addChild(notice)
    notice:setVisible(false)

    local isCanClick = true
    local buyHeartFunc = function(sender, eventType, isSide)
        local count = sender:getTag()
        if (eventType == ccui.TouchEventType.ended) and isSide and isCanClick then
            local vipPrivilegeConfig = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP)
            local totalCount = vipPrivilegeConfig.BuyFairysSillpoint
            if (totalCount - self.data.dailyBuySPCount) >= count then
                local costGold = 0
                for i=self.data.dailyBuySPCount + 1,(self.data.dailyBuySPCount + count) do
                    local buyHeartConfig = BaseConfig.getFairyBuySkillpointConfig(i)
                    costGold = costGold + buyHeartConfig.Price
                end
                if Common.isCostMoney(1001, costGold) then
                    isCanClick = false
                    rpc:call("Fairy.BuyFairySkillPoint", count, function(event)
                        if (event.status == Exceptions.Nil) and (event.result) then
                            self.controls.heartNum:setString(Common.numConvert(GameCache.Avatar.FairySkillPoint))
                            self.controls.heartNum:playChangeAction()
                            self.data.dailyBuySPCount = self.data.dailyBuySPCount + count
                            useCountLab:setString("今日已用("..self.data.dailyBuySPCount.."/"..totalCount..")")

                            if self.data.dailyBuySPCount < MaxBuyHeartCount then
                                local costGold1 = 0
                                for i=self.data.dailyBuySPCount + 1,(self.data.dailyBuySPCount + 5) do
                                    local buyHeartConfig = BaseConfig.getFairyBuySkillpointConfig(i)
                                    costGold1 = costGold1 + buyHeartConfig.Price
                                end
                                costGoldLab1:setString(costGold1)
                                local costGold2 = 0
                                if (self.data.dailyBuySPCount + 10) < MaxBuyHeartCount then
                                    for i=self.data.dailyBuySPCount + 1,(self.data.dailyBuySPCount + 10) do
                                        local buyHeartConfig = BaseConfig.getFairyBuySkillpointConfig(i)
                                        costGold2 = costGold2 + buyHeartConfig.Price
                                    end
                                    costGoldLab2:setString(costGold2)
                                else
                                    costTenNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
                                end
                            else
                                costNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
                                notice:setVisible(true)
                            end
                            isCanClick = true
                        end
                    end)
                end
            else
                local layer = require("tool.helper.CommonLayer").ToBuyVIP("提升VIP可购买多次噢～", function()
                    bg:removeFromParent()
                    bg = nil
                end)
                scene:addChild(layer)
            end
        end
    end

    local btn_fiveCount = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
    btn_fiveCount:setCircleFont("买五次",1,1,26,cc.c3b(238,205,142))
    btn_fiveCount:setTag(5)
    btn_fiveCount:addTouchEventListener(buyHeartFunc)
    btn_fiveCount:setPosition(bgsize.width*0.25, 45)
    costNode:addChild(btn_fiveCount)

    local btn_tenCount = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
    btn_tenCount:setCircleFont("买十次",1,1,26,cc.c3b(238,205,142))
    btn_tenCount:setTag(10)
    btn_tenCount:addTouchEventListener(buyHeartFunc)
    btn_tenCount:setPosition(bgsize.width*0.75, 45)
    costTenNode:addChild(btn_tenCount)

    local vipPrivilegeConfig = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP)
    local totalCount = vipPrivilegeConfig.BuyFairysSillpoint
    useCountLab:setString("今日已用("..self.data.dailyBuySPCount.."/"..totalCount..")")

    if self.data.dailyBuySPCount < MaxBuyHeartCount then
        local costGold1 = 0
        for i=self.data.dailyBuySPCount + 1,(self.data.dailyBuySPCount + 5) do
            local buyHeartConfig = BaseConfig.getFairyBuySkillpointConfig(i)
            costGold1 = costGold1 + buyHeartConfig.Price
        end
        costGoldLab1:setString(costGold1)
        local costGold2 = 0
        if (self.data.dailyBuySPCount + 10) <= MaxBuyHeartCount then
            for i=self.data.dailyBuySPCount + 1,(self.data.dailyBuySPCount + 10) do
                local buyHeartConfig = BaseConfig.getFairyBuySkillpointConfig(i)
                costGold2 = costGold2 + buyHeartConfig.Price
            end
            costGoldLab2:setString(costGold2)
        else
            costTenNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
        end
    else
        costNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
        notice:setVisible(true)
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            bg:removeFromParent()
            bg = nil
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end

function FairyLayer:updateFairyAnim(pageNum)
    local palyTime = 0.2
    if not self.controls.beforeFairyAnim then
        self.controls.beforeFairyAnim = self.data.allFairyAnimInfoTabs[pageNum].anim
        palyTime = 0
    else
        self.controls.beforeFairyAnim = self.controls.currFairyAnimInfo.anim
    end
    self.controls.currFairyAnimInfo = self.data.allFairyAnimInfoTabs[pageNum]
    local fadeOut = cc.FadeOut:create(palyTime)
    local delayIn = cc.DelayTime:create(palyTime) 
    local fadeIn = cc.FadeIn:create(palyTime)
    self.controls.beforeFairyAnim:runAction(cc.Sequence:create(fadeOut))
    self.controls.currFairyAnimInfo.anim:runAction(cc.Sequence:create(delayIn, fadeIn))

    self:updateFairyInfo(pageNum)
end

function FairyLayer:updateFairyInfo(pageNum)
    local fairyAnimInfo = self.data.allFairyAnimInfoTabs[pageNum]
    local fairyInfo = fairyAnimInfo.fairyInfo
    local fairyConfig = nil
    local skill1Config = nil
    local skill2Config = nil
    local fairyAttrConfig = nil
    if fairyAnimInfo.isOwn then
        fairyConfig = BaseConfig.GetFairy(fairyInfo.ID)
        self.controls.fairyLevel:setString("Lv."..fairyInfo.Level)
        local addAttr = ""
        if fairyInfo.Level >= 30 then
            self.controls.bar_rpSkillExp:setPercent(0)
            self.controls.fairyExp:setString("已达最大值")
        else
            self.controls.bar_rpSkillExp:setPercent(fairyInfo.Exp / BaseConfig.getFairyExp(fairyInfo.Level) * 100)
            self.controls.fairyExp:setString(fairyInfo.Exp.."/"..BaseConfig.getFairyExp(fairyInfo.Level))
        
            fairyAttrConfig = BaseConfig.getFairyPropertyConfig(fairyInfo.Level + 1)
            local value = fairyAttrConfig[fairyConfig.Property]
            if fairyConfig.Property == "AtkHpRecover" then
                value = (value/100).."%"
            end
            addAttr = "(升级+"..value..")"
        end
        
        local value = 0
        for i=1,fairyInfo.Level do
            local fairyAttrConfig = BaseConfig.getFairyPropertyConfig(i)
            value = value + fairyAttrConfig[fairyConfig.Property]
        end
        if fairyConfig.Property == "AtkHpRecover" then
            value = (value/100).."%"
        end
        self.controls.fairyAttrDesc:setString("全体星将"..AttrNameTab[fairyConfig.Property].."+"..value..addAttr)
        self.controls.fairyAttrDesc:setVisible(true)

        skill1Config = BaseConfig.GetHeroSkill(fairyConfig.Skill1, fairyInfo.SkillLevel[1])
        skill2Config = BaseConfig.GetHeroSkill(fairyConfig.Skill2, fairyInfo.SkillLevel[2])
    else
        fairyConfig = fairyInfo
        self.controls.fairyLevel:setString("Lv.1")
        self.controls.bar_rpSkillExp:setPercent(0)
        self.controls.fairyExp:setString("0/"..BaseConfig.getFairyExp(1))
        skill1Config = BaseConfig.GetHeroSkill(fairyConfig.Skill1, 1)
        skill2Config = BaseConfig.GetHeroSkill(fairyConfig.Skill2, 1)

        self.controls.fairyAttrDesc:setVisible(false)
    end

    self.controls.fairyName:setString(fairyConfig.Name)
    self.controls.skill1Name:setString(skill1Config.name)
    self.controls.skill2Name:setString(skill2Config.name)
    self.controls.skill1:setChildTexture("image/icon/skill/"..skill1Config.Res..".png")
    self.controls.skill2:setChildTexture("image/icon/skill/"..skill2Config.Res..".png")

    self.data.currFairyInfo = fairyInfo
    self.data.currFairyConfig = fairyConfig
end

function FairyLayer:fairyExciteAction(critMultiple)
    local bgSize = self.controls.bg:getContentSize()
    local critSpri = cc.Sprite:create("image/ui/img/btn/btn_1059.png")
    critSpri:setPosition(bgSize.width * 0.5, bgSize.height * 0.6)
    self.controls.bg:addChild(critSpri, critZorder)
    critSpri:setScale(5)
    local multiplySpri = cc.Sprite:create("image/ui/img/btn/btn_1291.png") 
    multiplySpri:setPosition(bgSize.width * 0.548, bgSize.height * 0.6)
    self.controls.bg:addChild(multiplySpri, critZorder)
    multiplySpri:setScale(5)
    local critNum = cc.Label:createWithCharMap("image/ui/img/btn/btn_1292.png", 31, 39,  string.byte("0"))
    critNum:setString(critMultiple)
    critNum:setPosition(bgSize.width * 0.57, bgSize.height * 0.6)
    self.controls.bg:addChild(critNum, critZorder)
    critNum:setScale(5)

    local heartSpri = cc.Sprite:create("image/ui/img/btn/btn_507.png")
    heartSpri:setPosition(bgSize.width * 0.5, bgSize.height * 0.55)
    self.controls.bg:addChild(heartSpri, critZorder)
    heartSpri:setScale(0)
    local time1 = 0.15
    local scale1 = cc.ScaleTo:create(time1, 1)
    local move1 = cc.MoveBy:create(time1 * 4, cc.p(0, 200))
    local fadeOut1 = cc.FadeOut:create(time1 * 4) 
    local removeSelf = cc.RemoveSelf:create()
    local spawn1 = cc.Spawn:create(move1, fadeOut1)
    local seq1 = cc.Sequence:create(scale1, spawn1, removeSelf)
    critSpri:runAction(seq1)
    multiplySpri:runAction(seq1:clone())
    critNum:runAction(seq1:clone())

    local scale21 = cc.ScaleTo:create(time1 * 4, 3)
    local scale22 = cc.ScaleTo:create(time1 * 2, 0)
    local move2 = cc.MoveTo:create(time1 * 2, cc.p(bgSize.width * 0.13, bgSize.height * 0.92))
    local spawn2 = cc.Spawn:create(scale22, move2)
    local scale23 = cc.ScaleTo:create(time1, 2)
    local scale24 = cc.ScaleTo:create(time1, 1)
    local fadeout2 = cc.FadeOut:create(time1)
    local spawn21 = cc.Spawn:create(scale24, fadeout2)
    local seq2 = cc.Sequence:create(scale21, spawn2, scale23, spawn21, cc.CallFunc:create(function()
        self.controls.heartNum:setString(Common.numConvert(GameCache.Avatar.FairySkillPoint))
        self.controls.heartNum:playChangeAction()
    end), removeSelf:clone())
    heartSpri:runAction(seq2)

    local fairyAnimInfo = self.controls.currFairyAnimInfo
    if not fairyAnimInfo.isOwn then
        return 
    end
    if not fairyAnimInfo.isExciting then
        if fairyAnimInfo.exciteNum >= 2 then
            return 
        end
        fairyAnimInfo.isExciting = true
        fairyAnimInfo.exciteNum = fairyAnimInfo.exciteNum + 1
        fairyAnimInfo.exciteTime = FairyExcitieTime
        if fairyAnimInfo.anim and (not GameCache.isExamine) then
            fairyAnimInfo.anim:setAnimation(0, "atk", false)
            fairyAnimInfo.anim:addAnimation(0, "idl_2", true)
        end
    else
        fairyAnimInfo.exciteNum = fairyAnimInfo.exciteNum + 1
    end
end

function FairyLayer:fairyAnimScheduler()
    for k,v in pairs(self.data.allFairyAnimInfoTabs) do
        if v.isExciting then
            v.exciteTime = v.exciteTime - 1
            if v.exciteTime < 1 then
                v.isExciting = false
                if v.exciteNum < 2 then
                    v.exciteNum = v.exciteNum - 1
                    if not GameCache.isExamine then
                        v.anim:setAnimation(0, "idl_1", true)
                    end
                else
                    if not GameCache.isExamine then
                        v.anim:setAnimation(0, "idl_2", true)
                    end
                end
            end
        end
    end
end

function FairyLayer:skillInfoTips(skillID)
    local isOwnCurrFairy = nil
    if self.controls.currFairyAnimInfo.isOwn then
        isOwnCurrFairy = true
    else
        isOwnCurrFairy = false
    end

    local currSkillConfig = nil
    if isOwnCurrFairy then
        currSkillConfig = BaseConfig.GetHeroSkill(skillID, self.data.currFairyInfo.SkillLevel[self.data.currSkillIndx])
    else
        currSkillConfig = BaseConfig.GetHeroSkill(skillID, 1)
    end

    local row1, desc1 = Common.StringLinefeed(currSkillConfig.Desc, 22)
    local row2 = (#currSkillConfig.Desc2)
    local iconBgHeight = 130
    local btnBgHeight = 120
    local rowHeight1 = 50 + (row1 - 1) * (50 * 0.45)
    local rowHeight2 = 40

    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), 100, 100)
    node:addChild(bgLayer)
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_175.png")
    node:addChild(bg)

    local iconbg = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    iconbg:setAnchorPoint(0.5, 1)
    iconbg:setScaleY(iconBgHeight / iconbg:getContentSize().height)
    node:addChild(iconbg)
    local btnbg = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnbg:setAnchorPoint(0.5, 0)
    btnbg:setScaleY(btnBgHeight / iconbg:getContentSize().height)
    node:addChild(btnbg)

    local icon = createMixSprite("image/icon/skill/"..currSkillConfig.Res..".png", nil, "image/icon/border/border_star_3.png") 
    icon:getBg():setScale(1.12)
    icon:setTouchEnable(false)
    node:addChild(icon)
    local skillName = Common.finalFont(currSkillConfig.name, 1, 1, 25)
    skillName:setAnchorPoint(0, 0.5)
    node:addChild(skillName)
    local currSkillLevel = Common.finalFont("Lv.", 1, 1, 20)
    currSkillLevel:setAnchorPoint(0, 0.5)
    node:addChild(currSkillLevel)
    
    local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    node:addChild(line1)
    local line2 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    node:addChild(line2)
    local line3 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    node:addChild(line3)
    local desc1Lab = Common.finalFont(desc1, 1, 1, 20)
    desc1Lab:setAnchorPoint(0, 1)
    node:addChild(desc1Lab)
    local desc2Tab = {}
    for k,v in pairs(currSkillConfig.Desc2) do
        local lab = Common.finalFont(v, 1, 1, 20)
        node:addChild(lab)
        desc2Tab[k] = lab
    end
    
    local toSpri1 = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    node:addChild(toSpri1)
    local toSpri2 = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    node:addChild(toSpri2)
    local nextSkillLevel = Common.finalFont("", 1, 1, 25, cc.c3b(120, 246, 103))
    node:addChild(nextSkillLevel)
    local nextDesc2Tab = {}
    for k,v in pairs(currSkillConfig.Desc2) do
        local lab = Common.finalFont(v, 1, 1, 20, cc.c3b(120, 246, 103))
        lab:setAnchorPoint(0, 1)
        node:addChild(lab)
        nextDesc2Tab[k] = lab
    end
    local btn = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, nil, cc.size(145, 52))
    btn:setCircleFont("升级", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    btn:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    node:addChild(btn)
    btn:addTouchEventListener(function(sender, eventType, isInside)
        if (eventType == ccui.TouchEventType.ended) and (isOwnCurrFairy) and isInside and self.controls.isCanUpgradeSkill then
            local currFairyLevel =  self.data.currFairyInfo.Level
            local currLevel = self.data.currFairyInfo.SkillLevel[self.data.currSkillIndx]
            if currFairyLevel > currLevel then
                if GameCache.Avatar.FairySkillPoint >= BaseConfig.getFairySkillUpgradePrice(currLevel) then
                    self:UpgradeFairySkill(skillID, node.setPos)
                    Common.CloseSystemLayer({6})
                else
                    application:showFlashNotice("爱心不足,不能升级～!")
                end
            else
                application:showFlashNotice("仙女技能等级不能超过仙女自身等级")
            end
        end
    end)
    if not self.data.currFairyInfo.Level then
        btn:setTouchEnable(false)
        btn:setNorGLProgram(false)
    end

    local costLab = Common.finalFont("花费", 1, 1, 20, cc.c3b(231, 222, 128))
    node:addChild(costLab)
    costLab:setAnchorPoint(0, 0.5)
    local costSpri = cc.Sprite:create("image/ui/img/btn/btn_507.png")
    node:addChild(costSpri)
    costSpri:setAnchorPoint(0, 0.5)
    local costPrice = Common.finalFont("", 1, 1, 20, cc.c3b(231, 222, 128))
    node:addChild(costPrice)
    costPrice:setAnchorPoint(0, 0.5)

    local effectNum = 0
    local upgradeEffect = nil
    node.setPos = function()
        local size = nil
        local skillLevel = 1
        if isOwnCurrFairy then
            skillLevel = self.data.currFairyInfo.SkillLevel[self.data.currSkillIndx]
        end
        currSkillConfig = BaseConfig.GetHeroSkill(skillID, skillLevel)
        if skillLevel < self.data.maxSkillLevel then
            size = cc.size(510, iconBgHeight + btnBgHeight + rowHeight1 + rowHeight2 + (row2 - 1) * rowHeight2 * 0.85 + 5 * row2)
        else
            size = cc.size(510, iconBgHeight + rowHeight1 + rowHeight2 + (row2 - 1) * rowHeight2 * 0.85 + 10 * row2)
        end
        line1:setPosition(0, size.height * 0.5 - iconBgHeight - 5)
        line2:setPosition(0, line1:getPositionY() - rowHeight1)
        line3:setPosition(0, line2:getPositionY() - row2 * rowHeight2)
        if skillLevel < self.data.maxSkillLevel then
            toSpri1:setPosition(0, size.height * 0.5 - iconBgHeight * 0.7)
            nextSkillLevel:setString("Lv."..(skillLevel + 1))
            nextSkillLevel:setPosition(size.width * 0.15, size.height * 0.5 - iconBgHeight * 0.7)
            local nextSkillConfig = BaseConfig.GetHeroSkill(skillID, skillLevel + 1)
            for k,v in pairs(nextDesc2Tab) do
                v:setString(nextSkillConfig.Desc2[k])
                v:setPosition(size.width * 0.1, line2:getPositionY() - 10 - (k - 1) * (rowHeight2 * 0.85))
            end
            btnbg:setPosition(0, -size.height * 0.5)
            costLab:setPosition(-size.width * 0.16, -size.height * 0.5 + 35)
            costSpri:setPosition(costLab:getPositionX() + costLab:getContentSize().width, 
                                        costLab:getPositionY())
            costPrice:setPosition(costSpri:getPositionX() + costSpri:getContentSize().width, 
                                        costLab:getPositionY())
            costPrice:setString(BaseConfig.getFairySkillUpgradePrice(skillLevel))
            for k,v in pairs(desc2Tab) do
                v:setAnchorPoint(0, 1)
                v:setString(currSkillConfig.Desc2[k])
                v:setPosition(-size.width * 0.45, line2:getPositionY() - 10 - (k - 1) * (rowHeight2 * 0.85))
            end
        else
            currSkillLevel:setColor(cc.c3b(120, 246, 103))
            btnbg:setVisible(false)
            toSpri1:setVisible(false)
            nextSkillLevel:setVisible(false)
            toSpri2:setVisible(false)
            for k,v in pairs(nextDesc2Tab) do
                v:setVisible(false)
            end
            btn:setVisible(false)
            costLab:setVisible(false)
            costSpri:setVisible(false)
            costPrice:setVisible(false)

            currSkillConfig = BaseConfig.GetHeroSkill(skillID, skillLevel)
            for k,v in pairs(desc2Tab) do
                v:setAnchorPoint(0.5, 1)
                v:setColor(cc.c3b(120, 246, 103))
                v:setPosition(0, line2:getPositionY() - 10 - (k - 1) * (rowHeight2 * 0.85))
                v:setString(currSkillConfig.Desc2[k])
            end
        end
        bgLayer:changeWidth(size.width * 0.98)
        bgLayer:changeHeight(size.height * 0.98)
        bgLayer:setPosition(-size.width * 0.49, -size.height * 0.49)
        bg:setContentSize(size)
        iconbg:setPosition(0, size.height * 0.5 - 5)

        icon:setPosition(-size.width * 0.32, size.height * 0.5 - iconBgHeight * 0.5 - 5)
        skillName:setPosition(-size.width * 0.15, size.height * 0.5 - iconBgHeight * 0.4)
        currSkillLevel:setString("Lv."..skillLevel)
        currSkillLevel:setPosition(-size.width * 0.15, size.height * 0.5 - iconBgHeight * 0.7)

        desc1Lab:setPosition(-size.width * 0.45, line1:getPositionY() - 10)
        toSpri2:setPosition(0, line2:getPositionY() - (line2:getPositionY() - line3:getPositionY()) * 0.5)
        btn:setPosition(0, line3:getPositionY() - btn:getContentSize().height * 0.7)

        if effectNum > 0 then
            if nil == upgradeEffect then
                upgradeEffect = effects:CreateAnimation(node, -size.width * 0.32, size.height * 0.5 - iconBgHeight * 0.5 - 5, nil, 20, false)
                upgradeEffect:setScale(0.85)
            else
                effects:RepeatAnimation(upgradeEffect)
            end
        end
        effectNum = effectNum + 1
    end
    node.setPos()

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 1, 1.2), cc.ScaleTo:create(0.05, 1, 0), 
                cc.CallFunc:create(function()
                    node:removeFromParent()
                    node = nil
            end)))
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    return node
end

-- 第一个返回暴击倍数 
--       0表示没有暴击，其他值表示暴击倍数
-- 第二个返回暴击区间
function FairyLayer:isFairyCrit()
    local score = self.data.critScore
    local isCritRad = math.random(1, 100)

    local critMultipleReturnValue = 0
    local critScoreReturnValue = 0
    local function critMultiple(critRadValue, critNum, maxCritNum, critMultipleValue)
        if (isCritRad <= critRadValue) and (critNum < maxCritNum) then
            local critMultipleRad = math.random(1, critMultipleValue)
            critMultipleReturnValue = critMultipleRad

            if score < CRITSCORE_1 then
                self.data.currCritNum_1 = self.data.currCritNum_1 + 1
            elseif score < CRITSCORE_2 then
                self.data.currCritNum_2 = self.data.currCritNum_2 + 1
            elseif score < CRITSCORE_3 then
                self.data.currCritNum_3 = self.data.currCritNum_3 + 1
            elseif score < CRITSCORE_4 then
                self.data.currCritNum_4 = self.data.currCritNum_4 + 1
            end
        end
    end

    if score < CRITSCORE_1 then
        critScoreReturnValue = CRITSCORE_1
        critMultiple(CRTICHANCE_1, self.data.currCritNum_1, MAXCRITNUM_1, MAXCRITMULTIPLE_1)
    elseif score < CRITSCORE_2 then
        critScoreReturnValue = CRITSCORE_2
        critMultiple(CRTICHANCE_2, self.data.currCritNum_2, MAXCRITNUM_2, MAXCRITMULTIPLE_2)
    elseif score < CRITSCORE_3 then
        critScoreReturnValue = CRITSCORE_3
        critMultiple(CRTICHANCE_3, self.data.currCritNum_3, MAXCRITNUM_3, MAXCRITMULTIPLE_3)
    elseif score < CRITSCORE_4 then
        critScoreReturnValue = CRITSCORE_4
        critMultiple(CRTICHANCE_4, self.data.currCritNum_4, MAXCRITNUM_4, MAXCRITMULTIPLE_4)
    else
        local isMustCrit = false
        if 0 == self.data.currCritNum_4 then
            isMustCrit = true
        end
        self.data.currCritNum_1 = 0
        self.data.currCritNum_2 = 0
        self.data.currCritNum_3 = 0
        self.data.currCritNum_4 = 0

        self.data.critScore = score - CRITSCORE_4
        if isMustCrit then
            return MAXCRITMULTIPLE_4, CRITSCORE_4
        else
            return self:isFairyCrit()
        end
    end
    return critMultipleReturnValue, critScoreReturnValue
end

--[[
    仙女升级
]]
function FairyLayer:UpgradeFairy()
    local crits = nil
    if (0 ~= (#self.data.critMultipleTab)) then
        crits = self.data.critMultipleTab
    end

    rpc:call("Fairy.Upgrade", {FairyID = self.data.currFairyInfo.ID, Crits = crits, 
                                PropsID = self.data.currPropsID, PropsNum = self.data.currPropsNum}, function(event)
        if event.status == Exceptions.Nil then
            local value = event.result
            self.data.currPropsNum = 0
            self.data.critMultipleTab = {}
        end
    end)
end

--[[
    仙女技能升级
]]
function FairyLayer:UpgradeFairySkill(skillID, endFunc)
    self.controls.isCanUpgradeSkill = false
    rpc:call("Fairy.UpgradeSkill", {FairyID = self.data.currFairyInfo.ID, SkillID = skillID}, function(event)
        if (event.status == Exceptions.Nil) and (event.result) then
            self.controls.heartNum:setString(Common.numConvert(GameCache.Avatar.FairySkillPoint))
            self.data.currFairyInfo.SkillLevel[self.data.currSkillIndx] = self.data.currFairyInfo.SkillLevel[self.data.currSkillIndx] + 1
            endFunc()
        end
        self.controls.isCanUpgradeSkill = true
    end)
end

function FairyLayer:onEnterTransitionFinish( )
    Common.OpenSystemLayer({6})
    FairyLayer.super.onEnterTransitionFinish(self)

end

return FairyLayer
