local NewHeroLayer = class("NewHeroLayer", BaseLayer)
local effects = require("tool.helper.Effects")
local CalHeroAttr = require("tool.helper.CalHeroAttr")

local requireDigestPanel = require("scene.main.hero.HeroDigestPanel")
local requireDetailPanel = require("scene.main.hero.HeroDetailPanel")
local requireUpgradeStarPanel = require("scene.main.hero.HeroUpStarPanel")
local requireSkillPanel = require("scene.main.hero.HeroSkillPanel")
local requireEquipPanel = require("scene.main.hero.HeroEquipPanel")
local requireUpgradeLevelPanel = require("scene.main.hero.HeroUpLevelPanel")
local EquipInfo = require("scene.main.hero.widget.EquipInfo")
local EquipInfoBox = require("scene.main.hero.widget.EquipInfoBox")
local EquipSkinBox = require("scene.main.hero.widget.EquipSkinBox")

local DETAIL_PANEL = 1
local UPGRADESTAR_PANEL = DETAIL_PANEL + 1
local SKILL_PANEL = UPGRADESTAR_PANEL + 1
local EQUIP_PANEL = SKILL_PANEL + 1
local UPGRADELEVEL_PANEL = EQUIP_PANEL + 1

local bgZOrder = 2
local digestPanelZOrder = bgZOrder + 1
local rightPanelZOrder = digestPanelZOrder + 1
local leftPanelZOrder = rightPanelZOrder + 1
local starZOrder = leftPanelZOrder + 1
local btnZOrder = starZOrder + 1

--装备栏数据
local equipModelLogoTAG = 1
local specialEquipAlertTAG = equipModelLogoTAG + 1
local commonEquipAlertTAG = specialEquipAlertTAG + 1
local compoundEquipAlertTAG = commonEquipAlertTAG + 1
local wearEquipTAG = compoundEquipAlertTAG + 1

--可穿戴装备类型
local WEAREQUIP_NO = 0
local WEAREQUIP_SPECAIL = 1
local WEAREQUIP_COMMON = 2
local WEAREQUIP_COMPOUND = 3

function NewHeroLayer:ctor(sortId, allHero)
    self.data.heroSortId = sortId
    self.data.allHero = allHero
    self.data.heroTotalNum = #self.data.allHero
    self.data.allPanelTab = {}
    self.data.currPanel = UPGRADELEVEL_PANEL
    self.data.isShowSkin = false
    self.listeners = {}
    self:addListener()
    self:createFixedUI()
    
    self.controls.digestPanel = requireDigestPanel.new(self.data.heroSortId, self.data.allHero)
    self.controls.digestPanel:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.54)
    self.controls.bg:addChild(self.controls.digestPanel, digestPanelZOrder)

    self.controls.detailPanel = requireDetailPanel.new()
    self.controls.detailPanel.pos = cc.p(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
    self.controls.detailPanel:setPosition(self.controls.detailPanel.pos)
    self.controls.bg:addChild(self.controls.detailPanel, rightPanelZOrder)
    self.data.allPanelTab[DETAIL_PANEL] = self.controls.detailPanel

    self.data.chooseHeroInfo = self.data.allHero[sortId]
    self.data.chooseHeroConfigInfo = BaseConfig.GetHero(self.data.chooseHeroInfo.ID, self.data.chooseHeroInfo.StarLevel)
    self.controls.detailPanel:updateHeroInfo(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)

    Common.removeTopSwallowLayer()

    -- CCLog("dumpCachedTextureInfo=", cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo())
end

function NewHeroLayer:onEnter()
    self:updateChooseHero(self.data.heroSortId, self.data.currPanel)
end

function NewHeroLayer:onEnterTransitionFinish()
    Common.OpenGuideLayer({6,7})
    Common.OpenSystemLayer({2})
    NewHeroLayer.super.onEnterTransitionFinish(self)
    
end

function NewHeroLayer:onCleanup()
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
    for k,v in pairs(self.data.allPanelTab) do
        if v.onExit then
            v:onExit()
        end
    end
end

function NewHeroLayer:addListener()
    local listener = application:addEventListener(AppEvent.UI.Hero.UpdateHeroInfo, function(event)
        local result = event.data
        local sortID = result.SortID
        if sortID then
            self.data.heroSortId = sortID
        end
        self:updateChooseHero(self.data.heroSortId, self.data.currPanel)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpgradeLevelAndStar, function(event)
        local result = event.data
        local level = result.Level or self.data.chooseHeroInfo.Level
        local starLevel = result.StarLevel or self.data.chooseHeroInfo.StarLevel
        local exp = result.Exp or self.data.chooseHeroInfo.Exp
        self:updateLevelInfo(starLevel, level, exp)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpdateAttribute, function(event)
        local result = event.data
        local beforeHero = result.BeforeHero
        local currHero = result.CurrHero

        local beforeHeroAttr = CalHeroAttr.calHeroAttr(beforeHero)
        local currHeroAttr = CalHeroAttr.calHeroAttr(currHero)

        local beforeHP = beforeHeroAttr.HP
        local beforeDef = beforeHeroAttr.Def 
        local beforeAtk = beforeHeroAttr.Atk
        local beforeMP = beforeHeroAttr.MP
        local beforeHit = beforeHeroAttr.Hit
        local beforeMiss = beforeHeroAttr.Miss
        local beforeCrit = beforeHeroAttr.Crit
        local beforeTen = beforeHeroAttr.Ten
        local beforeTFP = beforeHeroAttr.TFP

        local currHP = currHeroAttr.HP
        local currDef = currHeroAttr.Def
        local currAtk = currHeroAttr.Atk
        local currMP = currHeroAttr.MP
        local currHit = currHeroAttr.Hit
        local currMiss = currHeroAttr.Miss
        local currCrit = currHeroAttr.Crit
        local currTen = currHeroAttr.Ten
        local currTFP = currHeroAttr.TFP
        local addDesc = {"生命+", "防御+", "攻击+", "法力+", "命中+", "闪避+", "暴击+", "韧性+", "战斗力+"}
        local addValue = {currHP - beforeHP, currDef - beforeDef, currAtk - beforeAtk, currMP - beforeMP, 
                            currHit - beforeHit, currMiss - beforeMiss, currCrit - beforeCrit, currTen - beforeTen, 
                            currTFP - beforeTFP}

        local sort = 0
        for k=1,9 do
            local size = self.controls.bg:getContentSize()
            if addValue[k] > 0 then
                sort = sort + 1
                local fly = Common.flyFont(addDesc[k]..addValue[k], 
                        SCREEN_WIDTH * 0.5 - size.width * 0.22, SCREEN_HEIGHT * 0.5 + size.height * 0.1, sort * 0.3)
                self:addChild(fly, btnZOrder)
            end
        end
        self.controls.digestPanel:updateAttribute(currHP, currDef, currAtk, currMP, 
                                                currHit, currMiss, currCrit, currTen, currTFP)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.ChangeSkin, function(event)
        local result = event.data
        local equipType = result.EquipType
        local equipID = result.SkinID 
        if self.controls.digestPanel then
            self.controls.digestPanel:changeSkin(equipType, equipID)
        end
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpdateWearEquip, function(event)
        local result = event.data
        local equipType = result.EquipType
        local equipTabs = result.EquipTabs 
        local isPlay = result.IsPlay
        self:updateEquipWear(equipType, equipTabs, isPlay)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpdateWearSkin, function(event)
        local result = event.data
        local skinType = result.SkinType
        local skinInfo = result.SkinInfo
        self:updateSkinWear(skinType, skinInfo)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpdateFateCircle, function(event)
        local result = event.data
        local total = result.Count
        local brightCount = result.BrightCount
        self:updateHeroFateCircle(total, brightCount)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.ChangeEquipOrSkin, function(event)
        local result = event.data
        self.data.isShowSkin = result.IsShowSkin
        for k,v in pairs(self.controls.equipWearBgTab) do
            v:setVisible(not self.data.isShowSkin)
        end
        for k,v in pairs(self.controls.skinWearBgTab) do
            v:setVisible(self.data.isShowSkin)
        end
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpgradeEffect, function(event)
        local size = self.controls.bg:getContentSize()
        local effect = effects:CreateAnimation(self.controls.bg, size.width * 0.28, size.height * 0.58, nil, 19)
        effect:setLocalZOrder(btnZOrder)
        effect:setScale(1.5)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.UpdateEquipListView, function(event)
        if self.controls.equipPanel then
            self.controls.equipPanel:updateHeroInfo(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)
        end
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.IsShowAlert, function(event)
        local result = event.data
        local heroInfo = result.HeroInfo
        local isShowUpgradeStar = result.IsUpgradeStar
        local isShowSkill = result.IsSkill
        local isShowEquip = result.IsEquip

        for k,v in pairs(self.controls.chooseBtns) do
            local name = v:getTag()
            if name == UPGRADESTAR_PANEL then
                if isShowUpgradeStar then
                    local isAlert = Common.isHeroCanUpgradeStar(heroInfo)
                    v:setChildTextureVisible(isAlert)
                end
            end
            if name == SKILL_PANEL then
                if isShowSkill then
                    local isAlert = Common.isCanUpgradeSkill(heroInfo)
                    v:setChildTextureVisible(isAlert)
                end
            end
            if name == EQUIP_PANEL then
                if isShowEquip then
                    local isAlert = Common.isWearSpecialEquip(heroInfo)
                    v:setChildTextureVisible(isAlert)
                    self.data.isNoticeSpecialEquip = isAlert
                end
            end
        end

    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.RefreshEquipMent, function(event)
        local result = event.data
        local equipType = result.EquipType
        if self.controls.equipPanel then
            self.controls.equipPanel:updateEquipView(equipType, self.data.chooseHeroInfo)
        end
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.RefreshTrump, function(event)
        local result = event.data
        local equipType = result.EquipType
        if self.controls.equipPanel then
            self.controls.equipPanel:updateTrumpView(equipType)
        end
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.RefreshSkin, function(event)
        local result = event.data
        local skinType = result.SkinType
        if self.controls.equipPanel then
            self.controls.equipPanel:updateSkinView(skinType)
        end
    end)

    listener = application:addEventListener(AppEvent.UI.Hero.AddChildNode, function(event)
        local result = event.data
        local child = result.Child
        self:addChild(child, btnZOrder)
    end)
    table.insert(self.listeners, listener)

    listener = application:addEventListener(AppEvent.UI.Hero.CloseEquipTips, function(event)
        -- 变为非选中状态
        for k,bgSpri in pairs(self.controls.equipWearBgTab) do
            local goodsItem = bgSpri:getChildByTag(equipModelLogoTAG)
            if goodsItem then
                goodsItem:setChooseBorderVisible(false)
            end
        end
    end)
    table.insert(self.listeners, listener)
end

function NewHeroLayer:createFixedUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.data.bgSize = cc.size(955, 605)
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(self.data.bgSize)
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)

    local fringe = cc.Scale9Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setContentSize(self.data.bgSize)
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height)
    self.controls.bg:addChild(fringe, bgZOrder)

    local leftPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    leftPanel:setContentSize(cc.size(528, 586))
    leftPanel:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(leftPanel, bgZOrder)

    local bottomPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_185.png")
    bottomPanel:setContentSize(cc.size(505, 178))
    bottomPanel:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.18)
    self.controls.bg:addChild(bottomPanel, bgZOrder)

    -- local rightPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    -- rightPanel:setContentSize(cc.size(416, 586))
    -- rightPanel:setPosition(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
    -- self.controls.bg:addChild(rightPanel, bgZOrder)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.97, self.data.bgSize.height * 0.97)
    self.controls.bg:addChild(btn_close, btnZOrder)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            Common.CloseGuideLayer({7})
            application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateHeroList, {})
            self:removeFromParent()
            self = nil
        end
    end)

    local function getSpecialEquipType(heroInfo)
        local heroConfigInfo = BaseConfig.GetHero(heroInfo.ID, heroInfo.StarLevel)
        local allEquip = GameCache.GetAllEquip()
        for k,v in pairs(allEquip) do
            local equipConfig = BaseConfig.GetEquip(v.ID, v.StarLevel)
            if 0 ~= (#equipConfig.heroList) then
                local isHave = false
                for k1,v1 in pairs(equipConfig.heroList) do
                    if v1 == heroInfo.ID then
                        isHave = true
                    end
                end
                if isHave then
                    if equipConfig.type == BaseConfig.ET_ARM then
                        if heroConfigInfo.armType ~= equipConfig.subType then
                            break
                        end
                    end
                    if heroInfo.Equip[equipConfig.type].ID ~= v.ID then
                        return equipConfig.type
                    end
                end
            end
        end
        return BaseConfig.ET_ARM
    end

    local function createChooseBtns()
        local function btnTouchEvent(sender, eventType, isIn)
            if (eventType == ccui.TouchEventType.ended) and isIn then
                Common.CloseSystemLayer({2})
                Common.OpenSystemLayer({2})
                local name = sender:getTag()
                for k,v in pairs(self.controls.chooseBtns) do
                    if name == v:getTag() then
                        v:setTouchStatus()
                    else
                        v:setNormalStatus()
                    end
                end
                local beforePanel = self.data.currPanel
                if name == DETAIL_PANEL then
                    self.data.currPanel = DETAIL_PANEL
                elseif name == UPGRADESTAR_PANEL then
                    self.data.currPanel = UPGRADESTAR_PANEL
                elseif name == SKILL_PANEL then
                    self.data.currPanel = SKILL_PANEL
                elseif name == EQUIP_PANEL then
                    self.data.currPanel = EQUIP_PANEL
                end

                if (beforePanel ~= EQUIP_PANEL) or (self.data.currPanel ~= EQUIP_PANEL) then
                    self:updatePanel(self.data.currPanel)
                end

                if (name == EQUIP_PANEL) and self.data.isNoticeSpecialEquip then
                    local specialEquipType = getSpecialEquipType(self.data.chooseHeroInfo)
                    self.controls.equipPanel:updateEquipView(specialEquipType, self.data.chooseHeroInfo)
                end
            end
        end

        self.controls.chooseBtns = {}
        local btnNameTab = {DETAIL_PANEL, UPGRADESTAR_PANEL, SKILL_PANEL, EQUIP_PANEL}
        local nameTab = {"缘分", "升星", "技能", "装备"}
        for i=1,4 do
            local btn = createMixScale9Sprite("image/ui/img/btn/btn_593.png", "image/ui/img/btn/btn_801.png", 
                                        "image/ui/img/btn/btn_398.png", cc.size(109, 62))
            btn:setChildPos(0.92, 0.92)
            btn:setChildTextureVisible(false)
            btn:setCircleFont(nameTab[i] , 1, 1, 25, cc.c3b(248, 216, 136), 1)
            btn:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
            btn:setTag(btnNameTab[i])
            btn:setPosition((i - 1) * 120 + 90, self.data.bgSize.height * 0.12)
            btn:addTouchEventListener(btnTouchEvent)
            self.controls.bg:addChild(btn, leftPanelZOrder)
            table.insert(self.controls.chooseBtns, btn)
        end
    end
    createChooseBtns()

    local function createArrowBtns()
        self.controls.left_btn = ccui.Button:create("image/ui/img/btn/btn_1005.png", "image/ui/img/btn/btn_1005.png")
        self.controls.left_btn:setName("left")
        self.controls.left_btn:setPosition(SCREEN_WIDTH * 0.5 - self.data.bgSize.width * 0.32, 
                                            SCREEN_HEIGHT * 0.5 - self.data.bgSize.height * 0.07)
        self:addChild(self.controls.left_btn, btnZOrder)

        self.controls.right_btn = ccui.Button:create("image/ui/img/btn/btn_1005.png", "image/ui/img/btn/btn_1005.png")
        self.controls.right_btn:setName("right")
        self.controls.right_btn:setRotation(180)
        self.controls.right_btn:setPosition(SCREEN_WIDTH * 0.5 - self.data.bgSize.width * 0.113, 
                                            SCREEN_HEIGHT * 0.5 - self.data.bgSize.height * 0.07)
        self:addChild(self.controls.right_btn, btnZOrder)
        
        if self.data.heroSortId <= 1 then
            self.controls.left_btn:setVisible(false)
        end
        if self.data.heroSortId >= self.data.heroTotalNum then
            self.controls.right_btn:setVisible(false)
        end

        local move1 = cc.MoveBy:create(1, cc.p(-10, 0))
        local move1_reverse = move1:reverse()
        local move2 = cc.MoveBy:create(1, cc.p(10, 0))
        local move2_reverse = move2:reverse()
        self.controls.left_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move1_reverse)))
        self.controls.right_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(move2, move2_reverse)))
    end
    createArrowBtns()

    local size = self.data.bgSize
    local function createHeroLevel()
        self.controls.heroStarLevelBg = cc.Sprite:create("image/icon/border/panel_border_star_0.png")
        self.controls.heroStarLevelBg:setPosition(size.width * 0.242, size.height * 0.885)
        self.controls.bg:addChild(self.controls.heroStarLevelBg, bgZOrder)

        local controls_btn_upgrade = createMixSprite("image/ui/img/btn/btn_785.png")
        controls_btn_upgrade:setPosition(size.width * 0.385, size.height * 0.885)
        self.controls.bg:addChild(controls_btn_upgrade, leftPanelZOrder)
        controls_btn_upgrade:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                -- Common.CloseGuideLayer({9})
                self:hideChooseBtns()
                self.data.currPanel = UPGRADELEVEL_PANEL
                self:updatePanel(self.data.currPanel)
                -- Common.OpenGuideLayer({9})
            end
        end)

        local bgSize = self.controls.heroStarLevelBg:getContentSize()
        self.controls.heroName = Common.finalFont("", bgSize.width * 0.52, bgSize.height * 0.68, 25, nil, 1)
        self.controls.heroName:setAdditionalKerning(-2)
        self.controls.heroStarLevelBg:addChild(self.controls.heroName)

        self.controls.heroLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
        self.controls.heroLevel:setPosition(bgSize.width * 0.84, bgSize.height * 0.12)
        self.controls.heroLevel:setAnchorPoint(1, 0)
        self.controls.heroLevel:setScale(0.45)
        self.controls.heroLevel:setAdditionalKerning(-10)
        self.controls.heroStarLevelBg:addChild(self.controls.heroLevel)

        local ji = cc.Sprite:create("image/ui/img/btn/btn_790.png")
        ji:setAnchorPoint(0, 0)
        ji:setPosition(bgSize.width * 0.82, bgSize.height * 0.12)
        self.controls.heroStarLevelBg:addChild(ji)
        
        local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_436.png")
        bar_BG:setPosition(bgSize.width * 0.4, bgSize.height * 0.3)
        self.controls.heroStarLevelBg:addChild(bar_BG)

        self.controls.bar_heroLevel = ccui.LoadingBar:create("image/ui/img/btn/btn_789.png")
        self.controls.bar_heroLevel:setPercent(50)
        self.controls.bar_heroLevel:setPosition(bgSize.width * 0.395, bgSize.height * 0.3)
        self.controls.heroStarLevelBg:addChild(self.controls.bar_heroLevel)

        local animBG = cc.Sprite:create("image/ui/img/bg/bg_184.png")
        animBG:setPosition(size.width * 0.283, size.height * 0.58)
        self.controls.bg:addChild(animBG, bgZOrder)

        local ftpDesc = Common.finalFont("战力", size.width * 0.235, size.height * 0.37, 25, cc.c3b(184, 255, 107), 1)
        ftpDesc:setAdditionalKerning(-2)
        self.controls.bg:addChild(ftpDesc, bgZOrder)

        self.data.heroStarTab = {}
        for i=1,6 do
            local star = createMixSprite("image/ui/img/btn/btn_399.png", "image/ui/img/btn/btn_439.png")
            star:setTouchEnable(false)
            local starBg = star:getBg()
            starBg:setScale(0.58)
            star:setPosition(size.width * 0.18, size.height * 0.56 + 20 * i)
            self.controls.bg:addChild(star, starZOrder)
            self.data.heroStarTab[i] = star
        end

        self.data.fateCircleTab = {}

        self.controls.wx = cc.Label:createWithCharMap("image/ui/img/btn/btn_410.png", 31, 31,  string.byte("1"))
        self.controls.wx:setAnchorPoint(0.5, 0.5)
        self.controls.wx:setPosition(size.width * 0.38, size.height * 0.77)
        self.controls.bg:addChild(self.controls.wx, starZOrder)
    end
    createHeroLevel()

    local function equipWear()
        self.controls.equipWearBgTab = {}
        local nameTab = {"arm", "hat", "ring", "coat", "magic", "book"}
        local pathTab = {"btn_106.png", "btn_105.png", "btn_107.png", "btn_104.png", "btn_108.png", "btn_109.png"}

        local eventDispatcher = self:getEventDispatcher()
        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if self.data.isShowSkin then
                return false
            end
            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end

        local function onTouchEnd(touch, event)
            Common.CloseGuideLayer({6,7})
            Common.OpenGuideLayer({6,7})
            local target = event:getCurrentTarget()
            local name = target:getName()
            local equipID = nil
            for k,v in pairs(nameTab) do
                if name == v then
                    equipID = k
                end
            end

            if (GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.loot) and (equipID >= BaseConfig.ET_MAGIC) then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.loot)
                return 
            end

            CCLog("======equipID======", equipID)
            if EQUIP_PANEL ~= self.data.currPanel then
                self.data.currPanel = EQUIP_PANEL
                self:updatePanel(self.data.currPanel)
            end
            for k,v in pairs(self.controls.chooseBtns) do
                if EQUIP_PANEL == v:getTag() then
                    v:setTouchStatus()
                else
                    v:setNormalStatus()
                end
            end
            
            -- 按类型更新装备视图
            if equipID > 4 then
                self.controls.equipPanel:updateTrumpView(equipID, self.data.chooseHeroInfo)
            else
                self.controls.equipPanel:updateEquipView(equipID, self.data.chooseHeroInfo)
            end
            -- 先判断是否有武器
            if self.data.chooseHeroInfo.Equip[equipID].ID ~= 0 then
                local goodsItem = self.controls.equipWearBgTab[equipID]:getChildByTag(equipModelLogoTAG)
                goodsItem:setChooseBorderVisible(true)

                local equipInfoShow = EquipInfoBox.new(self.data.chooseHeroInfo, self.data.chooseHeroInfo.Equip[equipID], true, goodsItem)
                local size = self.data.bgSize
                local viewSize = equipInfoShow:getContentSize()
                local fixHeight = SCREEN_HEIGHT * 0.5 + size.height * 0.01 + viewSize.height * 0.4
                if equipID%2 == 1 then
                    equipInfoShow:setBgPosition(SCREEN_WIDTH * 0.5 - size.width * 0.28, fixHeight - (math.floor(equipID / 2)) * size.height * 0.2)
                else
                    equipInfoShow:setBgPosition(SCREEN_WIDTH * 0.5 - size.width * 0.15, fixHeight - (math.floor(equipID / 2) - 1) * size.height * 0.2)
                end
                self:addChild(equipInfoShow, btnZOrder)
            end
        end

        for i=1,6 do
            local posX = ((i - 1) % 2) * (size.width * 0.395) + size.width * 0.085
            local posY = size.height * 0.85 - math.floor((i - 1) / 2) * (size.height * 0.19)
            local path = "image/ui/img/btn/"..pathTab[i]
            
            local bg = cc.Sprite:create("image/icon/border/head_bg.png")
            bg:setPosition(posX,  posY)
            bg:setName(nameTab[i])
            self.controls.bg:addChild(bg, leftPanelZOrder)
            self.controls.equipWearBgTab[i] = bg
            local bgSize = bg:getContentSize()
            local logo = cc.Sprite:create(path)
            logo:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(logo)
            local border = cc.Sprite:create("image/icon/border/border_star_0.png")
            border:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(border)

            local specialEquipAlertNode = cc.Node:create()
            specialEquipAlertNode:setTag(specialEquipAlertTAG)
            specialEquipAlertNode:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(specialEquipAlertNode)
            local specialEquipAdd = effects:CreateAnimation(specialEquipAlertNode, 0, 0, nil, 16, true)
            specialEquipAdd:setPosition(0, 10)
            local specialEquipDesc = Common.finalFont("专属装", 1, -20, 18, cc.c3b(255,255,0), 1)
            specialEquipAlertNode:addChild(specialEquipDesc)

            local commonEquipAlertNode = cc.Node:create()
            commonEquipAlertNode:setTag(commonEquipAlertTAG)
            commonEquipAlertNode:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(commonEquipAlertNode)
            local commonEquipAdd = cc.Sprite:create("image/ui/img/btn/btn_1285.png")
            commonEquipAdd:setPosition(0, 10)
            commonEquipAlertNode:addChild(commonEquipAdd)
            local commonEquipDesc = Common.finalFont("可装备", 1, -20, 18, cc.c3b(0,255,0), 1)
            commonEquipAlertNode:addChild(commonEquipDesc)

            local compoundEquipAlertNode = cc.Node:create()
            compoundEquipAlertNode:setTag(compoundEquipAlertTAG)
            compoundEquipAlertNode:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(compoundEquipAlertNode)
            local compoundEquipAdd = cc.Sprite:create("image/ui/img/btn/btn_1285.png")
            compoundEquipAdd:setState(1)
            compoundEquipAdd:setPosition(0, 10)
            compoundEquipAlertNode:addChild(compoundEquipAdd)
            local compoundEquipDesc = Common.finalFont("可合成", 1, -20, 18, cc.c3b(0,255,0), 1)
            compoundEquipAlertNode:addChild(compoundEquipDesc)

            local wearEquip = load_animation("image/spine/skill_effect/rageactive", 1)
            wearEquip:setLocalZOrder(1)
            wearEquip:setTimeScale(2)
            wearEquip:setTag(wearEquipTAG)
            bg:addChild(wearEquip)
            wearEquip:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            wearEquip:setVisible(false)

            if (GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.loot) and ((i == 5) or (i == 6)) then
                local clock = cc.Sprite:create("image/ui/img/btn/btn_258.png")
                clock:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
                clock:setScale(0.8)
                bg:addChild(clock)
            end

            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
        end
    end
    equipWear()

    local function skinWear()
        self.controls.skinWearBgTab = {}
        local nameTab = {"hat", "coat"}
        local pathTab = {"btn_105.png", "btn_104.png"}

        local eventDispatcher = self:getEventDispatcher()
        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if not self.data.isShowSkin then
                return false
            end
            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end

        local function onTouchEnd(touch, event)
            local target = event:getCurrentTarget()
            local name = target:getName()
            local skinID = nil
            for k,v in pairs(nameTab) do
                if name == v then
                    skinID = k
                end
            end
            CCLog("======skinID======", skinID)
            self.data.currPanel = EQUIP_PANEL
            self:updatePanel(self.data.currPanel)
            for k,v in pairs(self.controls.chooseBtns) do
                if EQUIP_PANEL == v:getTag() then
                    v:setTouchStatus()
                else
                    v:setNormalStatus()
                end
            end

            -- 按类型更新时装视图
            self.controls.equipPanel:updateSkinView(skinID, self.data.chooseHeroInfo)
            -- 判断是否有时装
            -- local skinInfoTab = self.data.chooseHeroInfo.Skin[skinID]
            -- if (#skinInfoTab ~= 0) then
            --     local currSkinInfo = nil
            --     for k,v in pairs(skinInfoTab) do
            --         if v.IsWear then
            --             currSkinInfo = v
            --             break
            --         end
            --     end
            --     local skinShow = EquipSkinBox.new(self.data.chooseHeroInfo, currSkinInfo, true)
            --     if skinID == 1 then
            --         skinShow:setPosition(SCREEN_WIDTH * 0.5 - size.width * 0.28, 
            --                                 SCREEN_HEIGHT * 0.5 + self.data.bgSize.height * 0.05)
            --     else
            --         skinShow:setPosition(SCREEN_WIDTH * 0.5 - size.width * 0.15, 
            --                                 SCREEN_HEIGHT * 0.5 + self.data.bgSize.height * 0.05)
            --     end
            --     self:addChild(skinShow, btnZOrder)
            -- end
        end
        for i=1,2 do
            local posX = ((i - 1) % 2) * (size.width * 0.395) + size.width * 0.085
            local posY = size.height * 0.65
            local path = "image/ui/img/btn/"..pathTab[i]
            local bg = cc.Sprite:create("image/icon/border/head_bg.png")
            bg:setPosition(posX,  posY)
            bg:setName(nameTab[i])
            self.controls.bg:addChild(bg, leftPanelZOrder)
            self.controls.skinWearBgTab[i] = bg
            bg:setVisible(false)
            local bgSize = bg:getContentSize()
            local logo = cc.Sprite:create(path)
            logo:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(logo)
            local border = cc.Sprite:create("image/icon/border/border_star_0.png")
            border:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            bg:addChild(border)

            local function selectedEvent(sender,eventType)
                local child = bg:getChildByTag(1)
                local heroSkinInfo = self.data.chooseHeroInfo.SkinStatus
                if eventType == ccui.CheckBoxEventType.selected then
                    CCLog("========isCheck===========")
                    self:ShowSkin(self.data.chooseHeroInfo.ID, heroSkinInfo[i].ID, i, true)
                elseif eventType == ccui.CheckBoxEventType.unselected then
                    CCLog("========notCheck===========")
                    self:ShowSkin(self.data.chooseHeroInfo.ID, heroSkinInfo[i].ID, i, false)
                end
            end  
            local bgSize = bg:getContentSize()
            local checkBox = ccui.CheckBox:create()
            checkBox:setTouchEnabled(true)
            checkBox:loadTextures("image/ui/img/btn/btn_877.png",
                                       "image/ui/img/btn/btn_877.png",
                                       "image/ui/img/btn/btn_878.png",
                                       "image/ui/img/btn/btn_877.png",
                                       "image/ui/img/btn/btn_878.png")
            checkBox:setPosition(bgSize.width * 0.3, -bgSize.height * 0.5)
            checkBox:addEventListener(selectedEvent)  
            checkBox:setTag(2)
            bg:addChild(checkBox)
            checkBox:setSelectedState(true)

            local label = Common.finalFont("显示" , 1, 1, 20)
            label:setPosition(checkBox:getContentSize().width * 1.6, checkBox:getContentSize().height * 0.5)
            checkBox:addChild(label)

            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
        end
    end
    skinWear()    
end

function NewHeroLayer:hideChooseBtns()
    for k,v in pairs(self.controls.chooseBtns) do
        v:setNormalStatus()
    end
end

function NewHeroLayer:getPropsNumByID(id, propsType)
    if propsType == 1 then
        local soulInfo = GameCache.GetSoul(id)
        if soulInfo then
            return soulInfo.Num
        else
            return 0
        end
    elseif propsType == 2 then
        local propsInfo = GameCache.GetProps(id)
        if propsInfo then
            return propsInfo.Num
        else
            return 0
        end
    end
end

-- 某个部位是否有未穿戴的装备(专属、通用、可合成、没有)
function NewHeroLayer:isUnWearEquipByType(heroInfo, equipType)
    if equipType >= 5 then
        local equipTabs = GameCache.GetEquipTabsByType(equipType)
        for k,v in pairs(equipTabs) do
            return WEAREQUIP_COMMON
        end
        return false
    end
    local isNotHaveSpecial = nil
    local isHaveCommon = false
    local isCanCompound = false
    local equipConfigTab = BaseConfig.filtrateEquipConfigTab[equipType]
    for k,equipConfig in pairs(equipConfigTab) do
        local heroList = equipConfig.heroList
        if 0 ~= (#heroList) then
            for k,heroID in pairs(heroList) do
                if heroID == self.data.chooseHeroInfo.ID then
                    local fragToEquipConfig = BaseConfig.GetFragToEquip(equipConfig.id)
                    local equipStarLevel = fragToEquipConfig.starLevel
                    local ownEquipInfo = GameCache.GetEquip(equipConfig.id, equipStarLevel)
                    if ownEquipInfo then
                        return WEAREQUIP_SPECAIL
                    else
                        isNotHaveSpecial = true
                        if self:isFragCompound(equipConfig.id) then
                            isCanCompound = true
                        end
                    end
                    break
                end
            end
        else
            local fragToEquipConfig = BaseConfig.GetFragToEquip(equipConfig.id)
            local equipStarLevel = fragToEquipConfig.starLevel
            local ownEquipInfo = GameCache.GetEquip(equipConfig.id, equipStarLevel)
            if ownEquipInfo then
                if equipType == BaseConfig.ET_ARM then
                    if self.data.chooseHeroConfigInfo.armType == equipConfig.subType then
                        if isNotHaveSpecial then
                            return WEAREQUIP_COMMON
                        else
                            isHaveCommon = true
                        end
                    end
                else
                    if isNotHaveSpecial then
                        return WEAREQUIP_COMMON
                    else
                        isHaveCommon = true
                    end
                end
            else
                if equipType == BaseConfig.ET_ARM then
                    if self.data.chooseHeroConfigInfo.armType == equipConfig.subType then
                        if self:isFragCompound(equipConfig.id) then
                            isCanCompound = true
                        end
                    end
                else
                    if self:isFragCompound(equipConfig.id) then
                        isCanCompound = true
                    end
                end
            end
        end
    end
    if isHaveCommon then
        return WEAREQUIP_COMMON
    end
    if isCanCompound then
        return WEAREQUIP_COMPOUND
    end
    return WEAREQUIP_NO
end

function NewHeroLayer:isFragCompound(id)
    local propsInfo = GameCache.GetFrag(id)
    if propsInfo then
        local compoundId = BaseConfig.GetProps(id).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local compoundNum = fragToEquipConfig.num

        if propsInfo.Num >= compoundNum then
            return true
        else
            return false
        end
    else
        return false
    end
end

function NewHeroLayer:jumpToAppointButton(name)
    if 0 == name then
        return 
    end
    for k,v in pairs(self.controls.chooseBtns) do
        if name == v:getTag() then
            v:setTouchStatus()
        else
            v:setNormalStatus()
        end
    end
    local beforePanel = self.data.currPanel
    if name == DETAIL_PANEL then
        self.data.currPanel = DETAIL_PANEL
    elseif name == UPGRADESTAR_PANEL then
        self.data.currPanel = UPGRADESTAR_PANEL
    elseif name == SKILL_PANEL then
        self.data.currPanel = SKILL_PANEL
    elseif name == EQUIP_PANEL then
        self.data.currPanel = EQUIP_PANEL
    end

    if (beforePanel ~= EQUIP_PANEL) or (self.data.currPanel ~= EQUIP_PANEL) then
        self:updatePanel(self.data.currPanel)
    end
end

------------------------------------------------
-------------------update-----------------------
function NewHeroLayer:updateChooseHero(sortId, panel)
    if sortId <= 1 then
        self.controls.left_btn:setVisible(false)
    else
        self.controls.left_btn:setVisible(true)
    end
    if sortId >= self.data.heroTotalNum then
        self.controls.right_btn:setVisible(false)
    else
        self.controls.right_btn:setVisible(true)
    end
    
    self.data.chooseHeroInfo = self.data.allHero[sortId]
    self.data.chooseHeroConfigInfo = BaseConfig.GetHero(self.data.chooseHeroInfo.ID, self.data.chooseHeroInfo.StarLevel)

    self:updateLevelInfo(self.data.chooseHeroInfo.StarLevel, self.data.chooseHeroInfo.Level, self.data.chooseHeroInfo.Exp)
    for i=1,6 do
        self:updateEquipWear(i, self.data.chooseHeroInfo.Equip)
    end
    for i=1,2 do
        local skinInfoTab = self.data.chooseHeroInfo.SkinStatus[i]
        if 0 ~= skinInfoTab.ID then
            self:updateSkinWear(i, skinInfoTab)
        else
            self:updateSkinWear(i, nil)
        end
    end
    self.controls.digestPanel:updateHeroInfo(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)
    application:dispatchCustomEvent(AppEvent.UI.Hero.IsShowAlert, {HeroInfo = self.data.chooseHeroInfo,
                                                                IsUpgradeStar = true, IsSkill = true, IsEquip = true})
    self:updatePanel(panel)
end

function NewHeroLayer:updatePanel(panel)
    if panel == UPGRADESTAR_PANEL then
        if nil == self.controls.upgradeStarPanel then
            self.controls.upgradeStarPanel = requireUpgradeStarPanel.new()
            self.controls.upgradeStarPanel.pos = cc.p(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
            self.controls.upgradeStarPanel:setPosition(self.controls.upgradeStarPanel.pos)
            self.controls.bg:addChild(self.controls.upgradeStarPanel, rightPanelZOrder)
            self.data.allPanelTab[UPGRADESTAR_PANEL] = self.controls.upgradeStarPanel
            self.controls.upgradeStarPanel.isNeedPlayAction = true
        end
    elseif panel == SKILL_PANEL then
        if nil == self.controls.skillPanel then
            self.controls.skillPanel = requireSkillPanel.new()
            self.controls.skillPanel.pos = cc.p(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
            self.controls.skillPanel:setPosition(self.controls.skillPanel.pos)
            self.controls.bg:addChild(self.controls.skillPanel, rightPanelZOrder)
            self.data.allPanelTab[SKILL_PANEL] = self.controls.skillPanel
            self.controls.skillPanel.isNeedPlayAction = true
        end
    elseif panel == EQUIP_PANEL then
        if nil == self.controls.equipPanel then
            self.controls.equipPanel = requireEquipPanel.new()
            self.controls.equipPanel.pos = cc.p(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
            self.controls.equipPanel:setPosition(self.controls.equipPanel.pos)
            self.controls.bg:addChild(self.controls.equipPanel, rightPanelZOrder)
            self.data.allPanelTab[EQUIP_PANEL] = self.controls.equipPanel
            self.controls.equipPanel.isNeedPlayAction = true
        end
    elseif panel == UPGRADELEVEL_PANEL then
        if nil == self.controls.upgradeLevelPanel then
            self.controls.upgradeLevelPanel = requireUpgradeLevelPanel.new()
            self.controls.upgradeLevelPanel.pos = cc.p(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
            self.controls.upgradeLevelPanel:setPosition(self.controls.upgradeLevelPanel.pos)
            self.controls.bg:addChild(self.controls.upgradeLevelPanel, rightPanelZOrder)
            self.data.allPanelTab[UPGRADELEVEL_PANEL] = self.controls.upgradeLevelPanel
            self.controls.upgradeLevelPanel.isNeedPlayAction = true
        end
    end

    local function playAction(node)
        if node.isNeedPlayAction then
            node:stopAllActions()
            node:setScale(0.3)
            local actionTime = 0.3
            local jump = cc.JumpTo:create(actionTime, node.pos, 150, 1)
            local scale = cc.ScaleTo:create(actionTime, 1)
            local move1 = cc.MoveBy:create(0.05, cc.p(0, -50))
            local move2 = cc.MoveBy:create(0.08, cc.p(0, 50))
            local move3 = cc.MoveBy:create(0.03, cc.p(0, -20))
            local move4 = cc.MoveBy:create(0.05, cc.p(0, 20))
            node:runAction(cc.Sequence:create(cc.Spawn:create(jump, scale), move1, move2, move3, move4))
        end
        node.isNeedPlayAction = false
    end

    for k,v in pairs(self.data.allPanelTab) do
        if panel == k then
            v:setPosition(v.pos)
            v:setLocalZOrder(rightPanelZOrder)
            v:updateHeroInfo(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)
            -- playAction(v)
        else
            v.isNeedPlayAction = true
            v:setLocalZOrder(-1)
            v:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
        end
    end
    self.data.allPanelTab[DETAIL_PANEL]:updateHeroInfo(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)

end

function NewHeroLayer:updateLevelInfo(star, level, exp)
    local starAttr = Common.getHeroStarLevelColor(star)
    local nameColor = starAttr.Color
    local starNum = starAttr.StarNum
    local starDesc = starAttr.Additional

    local borderPath = string.format("image/icon/border/panel_border_star_%d.png", star)
    local libpath = require("tool.lib.path")
    local _, name = libpath.split(borderPath)
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name)
    if spriteFrame then
        self.controls.heroStarLevelBg:setSpriteFrame(spriteFrame)
    else
        self.controls.heroStarLevelBg:setTexture(borderPath)
    end  

    self.controls.heroName:setColor(nameColor)
    self.controls.heroName:setString(self.data.chooseHeroConfigInfo.name..starDesc)
    self.controls.heroLevel:setString(level)
    
    self.data.maxExp = BaseConfig.GetHeroUpgradeExp(self.data.chooseHeroConfigInfo.talent, level)
    self.controls.bar_heroLevel:setPercent(exp/self.data.maxExp * 100) 

    local starCount = 6
    for i=1,starCount do
        if i > starNum then
            self.data.heroStarTab[i]:setTouchStatus()
        else
            self.data.heroStarTab[i]:setNormalStatus()
        end
    end
    self.controls.wx:setString(self.data.chooseHeroConfigInfo.wx)
end

function NewHeroLayer:updateEquipWear(equipType, equipTabs, isPlayWearAnim)
    local size = self.controls.equipWearBgTab[equipType]:getContentSize()
    local specialEquipAlert = self.controls.equipWearBgTab[equipType]:getChildByTag(specialEquipAlertTAG)
    local commonEquipAlert = self.controls.equipWearBgTab[equipType]:getChildByTag(commonEquipAlertTAG)
    local compoundEquipAlert = self.controls.equipWearBgTab[equipType]:getChildByTag(compoundEquipAlertTAG)
    specialEquipAlert:setVisible(false)
    commonEquipAlert:setVisible(false)
    compoundEquipAlert:setVisible(false)

    if equipTabs[equipType].ID ~= 0 then
        local equipInfo = equipTabs[equipType]
        local child = self.controls.equipWearBgTab[equipType]:getChildByTag(equipModelLogoTAG)
        if child then   
            child:setScale(1)
            child:setGoodsInfo(equipInfo, self.data.chooseHeroInfo)
            child:setLevel("center", equipInfo.Level)
        else
            local info = EquipInfo.new(equipInfo, self.data.chooseHeroInfo)
            info:setLevel("center", equipInfo.Level)
            info:setTag(equipModelLogoTAG)
            info:setPosition(size.width * 0.5, size.height * 0.5)
            self.controls.equipWearBgTab[equipType]:addChild(info)
        end
    else
        local child = self.controls.equipWearBgTab[equipType]:getChildByTag(equipModelLogoTAG)
        if child then   
            child:setScale(0)
        end

        local isUnWearEquip = self:isUnWearEquipByType(self.data.chooseHeroInfo, equipType)
        if WEAREQUIP_SPECAIL == isUnWearEquip then
            specialEquipAlert:setVisible(true)
        elseif WEAREQUIP_COMMON == isUnWearEquip then
            commonEquipAlert:setVisible(true)
        elseif WEAREQUIP_COMPOUND == isUnWearEquip then
            compoundEquipAlert:setVisible(true)
        end
    end

    if isPlayWearAnim then
        local wearEquipAnim = self.controls.equipWearBgTab[equipType]:getChildByTag(wearEquipTAG)
        wearEquipAnim:setVisible(true)
        wearEquipAnim:setAnimation(0, "animation", false)
        wearEquipAnim:registerSpineEventHandler(function(event)
            wearEquipAnim:setVisible(false)
        end, sp.EventType.ANIMATION_END)

        local equipInfo = equipTabs[equipType]
        if equipInfo then
            local equipConfig = BaseConfig.GetEquip(equipInfo.ID, equipInfo.StarLevel)
            if (BaseConfig.ET_HAT == equipConfig.type) or (BaseConfig.ET_COAT == equipConfig.type) then
                local skinListTab = self.data.chooseHeroInfo.SkinList
                local heroSkinInfo = self.data.chooseHeroInfo.SkinStatus[(equipConfig.type / 2)]
                -- 除了判断SkinList中有没相同的时装，还要判断当前SkinStatus中的时装信息是否相同
                local isHave = false
                for k,skinInfo in pairs(skinListTab) do
                    if equipInfo.ID == skinInfo.ID then
                        isHave = true
                        break
                    end
                end
                if not isHave then
                    if (0 ~= heroSkinInfo.ID) and (heroSkinInfo.ID == equipInfo.ID) then
                        return 
                    end

                    local skinInfo = {}
                    skinInfo.ID = equipInfo.ID
                    skinInfo.IsActive = false
                    table.insert(skinListTab, skinInfo)
                    self.data.chooseHeroInfo.SkinList = skinListTab
                end
            end
        end
    end
end

function NewHeroLayer:updateSkinWear(skinType, skinInfo)
    local size = self.controls.skinWearBgTab[skinType]:getContentSize()
    local skinBg = self.controls.skinWearBgTab[skinType]
    local goodsItem = skinBg:getChildByTag(equipModelLogoTAG)
    local checkBtn = skinBg:getChildByTag(2)

    if skinInfo then    
        if goodsItem then   
            goodsItem:setScale(1)
            goodsItem:setGoodsInfo(skinInfo)
        else
            goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, skinInfo, BaseConfig.GOODS_MIDDLETYPE)
            goodsItem:setTag(equipModelLogoTAG)
            goodsItem:setPosition(size.width * 0.5, size.height * 0.5)
            self.controls.skinWearBgTab[skinType]:addChild(goodsItem)
        end

        local skinInfo = self.data.chooseHeroInfo.SkinStatus[skinType]
        if skinInfo.IsShow then
            checkBtn:setSelectedState(true)
        else
            checkBtn:setSelectedState(false)
        end
        checkBtn:setVisible(true)
    else
        if goodsItem then   
            goodsItem:setScale(0)
        end
        checkBtn:setVisible(false)
    end
end

function NewHeroLayer:updateHeroFateCircle(total, brightCount)
    local function createCircle(i)
        local circle = createMixSprite("image/ui/img/btn/btn_097.png", "image/ui/img/btn/btn_096.png")
        circle:setTouchEnable(false)
        circle:setPosition(self.data.bgSize.width * 0.38, self.data.bgSize.height * 0.75 - 16 * i)
        self.controls.bg:addChild(circle, starZOrder)
        self.data.fateCircleTab[i] = circle
        return circle
    end

    for i=1,total do
        local circle = self.data.fateCircleTab[i]
        if not circle then
            circle = createCircle(i)
        end
        circle:setVisible(true)
        if i <= brightCount then
            circle:setTouchStatus()
        else
            circle:setNormalStatus()
        end
    end

    local fateTabTotal = #self.data.fateCircleTab
    if total < fateTabTotal then
        for i=1,fateTabTotal do
            if i > total then
                self.data.fateCircleTab[i]:setVisible(false)
            end
        end
    end
end
-------------------update-----------------------
------------------------------------------------

-- 显示时装
function NewHeroLayer:ShowSkin(_heroID, _skinID, _type, _isShow)
    local p = {
        HeroID = _heroID,
        SkinID = _skinID,
        IsShow = _isShow
    }
    rpc:call("Hero.ShowSkin", p, function(event)
        if event.status == Exceptions.Nil then
            local skinStatusInfo = self.data.chooseHeroInfo.SkinStatus[_type]
            skinStatusInfo.IsShow = p.IsShow
            local equipInfo = self.data.chooseHeroInfo.Equip[(_type * 2)]
            if skinStatusInfo.IsShow then
                equipInfo.SkinID = skinStatusInfo.ID
            else
                equipInfo.SkinID = equipInfo.ID
            end

            local skinData = {
                EquipType = (_type * 2),
                SkinID = equipInfo.SkinID
            }
            application:dispatchCustomEvent(AppEvent.UI.Hero.ChangeSkin, skinData)
        end
    end)
end

return NewHeroLayer