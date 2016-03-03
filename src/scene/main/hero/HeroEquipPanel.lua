local EquipPanel = class("EquipPanel", function()
    local self = cc.Node:create()
    self.controls = {}
    self.data = {}
    return self
end)
local EquipInfo = require("scene.main.hero.widget.EquipInfo")
local EquipInfoBox = require("scene.main.hero.widget.EquipInfoBox")

local EQUIPMENT_VIEW = 1
local TRUMP_VIEW = EQUIPMENT_VIEW + 1
local SKIN_VIEW = TRUMP_VIEW + 1

function EquipPanel:ctor()
    self.data.currEquipView = EQUIPMENT_VIEW
    self:createFixedUI()
    self:createEquipmentView()
    self:createTrumpView()
    
    self:initData()
end

function EquipPanel:initData()
    self.data.currEquipTypeID = BaseConfig.ET_ARM
    self.data.currTrumpTypeID = BaseConfig.ET_MAGIC
    self.data.chooseHeroSpecialEquipID = nil

    self.controls.specailEquipItem = nil
    self.controls.commonEquipTtemTab = {}

    self.data.specialArmIDTab = {}
    self.data.specialHatIDTab = {}
    self.data.specialRingIDTab = {}
    self.data.specialCoatIDTab = {}

    self.data.commonArmIDTab = {}
    self.data.commonHatIDTab = {}
    self.data.commonRingIDTab = {}
    self.data.commonCoatIDTab = {}

    self.data.trumpIDTab = {}
    self.data.trumpItemTab = {}
    self.data.commonMagicIDTab = {}
    self.data.commonBookIDTab = {}

    for k1,equipConfigTab in pairs(BaseConfig.filtrateEquipConfigTab) do
        for k2,equipConfig in pairs(equipConfigTab) do
            local equipmentType = equipConfig.type 
            if equipmentType == BaseConfig.ET_ARM then
                if 0 == (#equipConfig.heroList) then
                    table.insert(self.data.commonArmIDTab, equipConfig.id)
                else
                    table.insert(self.data.specialArmIDTab, equipConfig.id)
                end
            elseif equipmentType == BaseConfig.ET_HAT then
                if 0 == (#equipConfig.heroList) then
                    table.insert(self.data.commonHatIDTab, equipConfig.id)
                else
                    table.insert(self.data.specialHatIDTab, equipConfig.id)
                end
            elseif equipmentType == BaseConfig.ET_RING then
                if 0 == (#equipConfig.heroList) then
                    table.insert(self.data.commonRingIDTab, equipConfig.id)
                else
                    table.insert(self.data.specialRingIDTab, equipConfig.id)
                end
            elseif equipmentType == BaseConfig.ET_COAT then
                if 0 == (#equipConfig.heroList) then
                    table.insert(self.data.commonCoatIDTab, equipConfig.id)
                else
                    table.insert(self.data.specialCoatIDTab, equipConfig.id)
                end
            elseif equipmentType == BaseConfig.ET_MAGIC then
                table.insert(self.data.commonMagicIDTab, equipConfig.id)
            elseif equipmentType == BaseConfig.ET_BOOK then
                table.insert(self.data.commonBookIDTab, equipConfig.id)
            end
        end
    end
    
end

function EquipPanel:createFixedUI()
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(416, 586))
    self:addChild(bg)
    self.data.size = bg:getContentSize()
    self.data.viewSize = cc.size(410, 410)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    self.controls.bg:setContentSize(cc.size(415, 500))
    self.controls.bg:setPosition(0, -self.data.size.height * 0.05)
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    self.controls.shuoming1 = cc.Node:create()
    self.controls.shuoming1:setPosition(0, size.height * 0.36)
    self:addChild(self.controls.shuoming1)

    local detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("提示:装备穿戴后即与星将绑定", 1, 1, 20, cc.c3b(213, 242, 255))
    self.controls.shuoming1:addChild(detailName)

    -- 屏蔽超出可视区域的装备事件
    local function swallowLayer(x, y)
        local layer = cc.LayerColor:create(cc.c4b(0,200,0,0), self.data.size.width, 200)
        layer:setPosition(x, y)
        self:addChild(layer, 1)

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    end
    swallowLayer(-self.data.size.width * 0.5, self.data.size.height * 0.26)
    swallowLayer(-self.data.size.width * 0.5, -self.data.size.height * 0.78)

    self.data.equip_chooseBtns = {}
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            if (GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.loot) and (tag == TRUMP_VIEW) then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.loot)
                return 
            end

            for k,v in pairs(self.data.equip_chooseBtns) do
                if tag == v:getTag() then
                    v:setTouchStatus()
                else
                    v:setNormalStatus()
                end
            end

            local isShowSkin = false
            if tag == EQUIPMENT_VIEW then
                self:updateEquipView(nil, self.data.chooseHeroInfo)
                isShowSkin = false
            elseif tag == TRUMP_VIEW then
                self:updateTrumpView(nil, self.data.chooseHeroInfo)
                isShowSkin = false
            elseif tag == SKIN_VIEW then
                self:updateSkinView(nil, self.data.chooseHeroInfo)
                isShowSkin = true
            end
            application:dispatchCustomEvent(AppEvent.UI.Hero.ChangeEquipOrSkin, {IsShowSkin = isShowSkin})
        end
    end

    local controls_btn_equip = createMixScale9Sprite("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png", nil, cc.size(119, 63))
    controls_btn_equip:setTouchStatus()
    controls_btn_equip:setBgTouchAnchorPoint(0.5, 0)
    controls_btn_equip:setFont("装备" , 1, 1, 25, cc.c3b(226, 230, 242))
    controls_btn_equip:setFontOutline(cc.c4b(27, 31, 49, 255), 2)
    controls_btn_equip:setFontPos(0.5, 0.8)
    controls_btn_equip:setAnchorPoint(0.5, 0)
    controls_btn_equip:setPosition(-self.data.size.width * 0.3, self.data.size.height * 0.355)
    controls_btn_equip:setTag(EQUIPMENT_VIEW)
    controls_btn_equip:addTouchEventListener(btnTouchEvent)
    self:addChild(controls_btn_equip, 1)
    table.insert(self.data.equip_chooseBtns , controls_btn_equip)

    local controls_btn_trump = createMixScale9Sprite("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png", nil, cc.size(119, 63))
    controls_btn_trump:setBgTouchAnchorPoint(0.5, 0)
    controls_btn_trump:setFont("宝物" , 1, 1, 25, cc.c3b(226, 230, 242))
    controls_btn_trump:setFontOutline(cc.c4b(27, 31, 49, 255), 2)
    controls_btn_trump:setFontPos(0.5, 0.8)
    controls_btn_trump:setAnchorPoint(0.5, 0)
    controls_btn_trump:setPosition(0, self.data.size.height * 0.355)
    controls_btn_trump:setTag(TRUMP_VIEW)
    controls_btn_trump:addTouchEventListener(btnTouchEvent)
    self:addChild(controls_btn_trump, 1)
    table.insert(self.data.equip_chooseBtns , controls_btn_trump)
    
    local controls_btn_dress = createMixScale9Sprite("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png", nil, cc.size(119, 63))
    controls_btn_dress:setBgTouchAnchorPoint(0.5, 0)
    controls_btn_dress:setFont("时装" , 1, 1, 25, cc.c3b(226, 230, 242))
    controls_btn_dress:setFontOutline(cc.c4b(27, 31, 49, 255), 2)
    controls_btn_dress:setFontPos(0.5, 0.8)
    controls_btn_dress:setAnchorPoint(0.5, 0)
    controls_btn_dress:setPosition(self.data.size.width * 0.3, self.data.size.height * 0.355)
    controls_btn_dress:setTag(SKIN_VIEW)
    controls_btn_dress:addTouchEventListener(btnTouchEvent)
    self:addChild(controls_btn_dress, 1)
    table.insert(self.data.equip_chooseBtns , controls_btn_dress)
end

function EquipPanel:createEquipmentView()
    self.controls.equipmentView = cc.Node:create()
    self.controls.equipmentView:setTag(EQUIPMENT_VIEW)
    self:addChild(self.controls.equipmentView)

    local size = self.controls.bg:getContentSize()
    local detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("专属装备", 1, 1, 20, cc.c3b(213, 242, 255))
    detailName:setPosition(0, size.height * 0.36)
    self.controls.equipmentView:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(-size.width * 0.4, size.height * 0.36)
    self.controls.equipmentView:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(size.width * 0.4, size.height * 0.36)
    self.controls.equipmentView:addChild(line)

    detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("通用武器", 1, 1, 20, cc.c3b(213, 242, 255))
    detailName:setPosition(0, size.height * 0.07)
    self.controls.equipmentView:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(-size.width * 0.4, size.height * 0.07)
    self.controls.equipmentView:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(size.width * 0.4, size.height * 0.07)
    self.controls.equipmentView:addChild(line)

    self.controls.ownSpecailNode = cc.Node:create()
    self.controls.equipmentView:addChild(self.controls.ownSpecailNode)
    self.controls.unOwnSpecailNode = cc.Node:create()
    self.controls.equipmentView:addChild(self.controls.unOwnSpecailNode)

    self.controls.equipName = Common.finalFont(" ", 1, 1, 22, nil, 1)
    self.controls.equipName:setAnchorPoint(0, 0.5)
    self.controls.equipName:setPosition(-size.width * 0.16, size.height * 0.27)
    self.controls.ownSpecailNode:addChild(self.controls.equipName)

    self.controls.specailEquipDesc = Common.finalFont("", 1, 1, 18, nil, 1)
    self.controls.specailEquipDesc:setAnchorPoint(0, 1)
    self.controls.specailEquipDesc:setPosition(-size.width * 0.16, size.height * 0.22)
    self.controls.ownSpecailNode:addChild(self.controls.specailEquipDesc)

    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    spri:setPosition(-size.width * 0.25, size.height * 0.22)
    self.controls.unOwnSpecailNode:addChild(spri)
    local desc = Common.finalFont("这个部位没有专属装备", 1, 1, 22, cc.c3b(61, 131, 172))
    desc:setPosition(size.width * 0.13, size.height * 0.22)
    self.controls.unOwnSpecailNode:addChild(desc)
    self.controls.unOwnSpecailNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)

    for i=1,6 do
        local bg = cc.Scale9Sprite:create("image/ui/img/btn/btn_412.png")   
        bg:setContentSize(cc.size(88, 88))
        bg:setPosition(-size.width * 0.3 + ((i - 1)%3) * 120 , -size.height * 0.08 - 110 * (math.floor((i - 1)/3)))
        self.controls.equipmentView:addChild(bg)
    end
end

function EquipPanel:createTrumpView()
    self.controls.trumpView = cc.Node:create()
    self.controls.trumpView:setTag(EQUIPMENT_VIEW)
    self:addChild(self.controls.trumpView)
    local size = self.controls.bg:getContentSize()

    for i=1,12 do
        local bg = cc.Scale9Sprite:create("image/ui/img/btn/btn_412.png")   
        bg:setContentSize(cc.size(88, 88))
        bg:setPosition(-size.width * 0.3 + ((i - 1)%3) * 120 , size.height * 0.22 - 105 * (math.floor((i - 1)/3)))
        self.controls.trumpView:addChild(bg)
    end
end

function EquipPanel:updateHeroInfo(heroInfo, configInfo)
    self.data.chooseHeroInfo = heroInfo
    self.data.chooseHeroConfigInfo = configInfo
    self.data.chooseHeroCommonEquipIDTab = {}

    if self.data.currEquipView == EQUIPMENT_VIEW then
        self:updateEquipView(self.data.currEquipTypeID, heroInfo)
    elseif self.data.currEquipView == TRUMP_VIEW then
        self:updateTrumpView(self.data.currTrumpTypeID, heroInfo)
    elseif self.data.currEquipView == SKIN_VIEW then
        self:updateSkinView(self.data.currEquipTypeID, heroInfo)
    end
end

function EquipPanel:updateEquipView(equipTypeID, heroInfo)
    self.data.currEquipView = EQUIPMENT_VIEW
    self.data.currEquipTypeID = equipTypeID or self.data.currEquipTypeID
    if self.data.currEquipTypeID then
        self.data.chooseHeroCommonEquipIDTab = {}
    end

    local isHaveSpecial = false
    local heroConfig = self.data.chooseHeroConfigInfo
    if self.data.currEquipTypeID == BaseConfig.ET_ARM then
        for k,armID in pairs(self.data.specialArmIDTab) do
            local equipConfig = BaseConfig.GetEquip(armID, 0)
            for k,equipID in pairs(equipConfig.heroList) do
                if heroInfo.ID == equipID then
                    self.data.chooseHeroSpecialEquipID = armID
                    isHaveSpecial = true
                    break
                end
            end
            if isHaveSpecial then
                break
            end
        end
        if not isHaveSpecial then
            self.data.chooseHeroSpecialEquipID = nil
        end

        for k,armID in pairs(self.data.commonArmIDTab) do
            local equipConfig = BaseConfig.GetEquip(armID, 0)
            if heroConfig.armType == equipConfig.subType then
                table.insert(self.data.chooseHeroCommonEquipIDTab, armID)
            end
        end
    elseif self.data.currEquipTypeID == BaseConfig.ET_HAT then
        for k,hatID in pairs(self.data.specialHatIDTab) do
            local equipConfig = BaseConfig.GetEquip(hatID, 0)
            for k,equipID in pairs(equipConfig.heroList) do
                if heroInfo.ID == equipID then
                    self.data.chooseHeroSpecialEquipID = hatID
                    isHaveSpecial = true
                    break
                end
                if isHaveSpecial then
                    break
                end
            end
            if not isHaveSpecial then
                self.data.chooseHeroSpecialEquipID = nil
            end
        end
        self.data.chooseHeroCommonEquipIDTab = self.data.commonHatIDTab
    elseif self.data.currEquipTypeID == BaseConfig.ET_RING then
        for k,ringID in pairs(self.data.specialRingIDTab) do
            local equipConfig = BaseConfig.GetEquip(ringID, 0)
            for k,equipID in pairs(equipConfig.heroList) do
                if heroInfo.ID == equipID then
                    self.data.chooseHeroSpecialEquipID = ringID
                    isHaveSpecial = true
                    break
                end
                if isHaveSpecial then
                    break
                end
            end
            if not isHaveSpecial then
                self.data.chooseHeroSpecialEquipID = nil
            end
        end
        self.data.chooseHeroCommonEquipIDTab = self.data.commonRingIDTab
    elseif self.data.currEquipTypeID == BaseConfig.ET_COAT then
        for k,coatID in pairs(self.data.specialCoatIDTab) do
            local equipConfig = BaseConfig.GetEquip(coatID, 0)
            for k,equipID in pairs(equipConfig.heroList) do
                if heroInfo.ID == equipID then
                    self.data.chooseHeroSpecialEquipID = coatID
                    isHaveSpecial = true
                    break
                end
                if isHaveSpecial then
                    break
                end
            end
            if not isHaveSpecial then
                self.data.chooseHeroSpecialEquipID = nil
            end
        end
        self.data.chooseHeroCommonEquipIDTab = self.data.commonCoatIDTab
    end

    self.controls.shuoming1:setPosition(0, -self.controls.bg:getContentSize().height * 0.45)
    self.controls.equipmentView:setScale(1)
    if self.controls.trumpView then
        self.controls.trumpView:setScale(0)
    end
    if self.controls.skinView then
        self.controls.skinView:setScale(0)
    end
    for k,v in pairs(self.data.equip_chooseBtns) do
        if v:getTag() == self.data.currEquipView then
            v:setTouchStatus()
        else
            v:setNormalStatus()
        end
    end

    self:updateSpecailEquipData()
    self:updateCommonEquipData()
end

function EquipPanel:updateSpecailEquipData()
    if self.data.chooseHeroSpecialEquipID then
        self.controls.ownSpecailNode:setPosition(0, 0)
        self.controls.unOwnSpecailNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)

        local fragToEquipConfig = BaseConfig.GetFragToEquip(self.data.chooseHeroSpecialEquipID)
        local equipStarLevel = fragToEquipConfig.starLevel
        local specailEquipInfo = {}
        specailEquipInfo.ID = self.data.chooseHeroSpecialEquipID
        specailEquipInfo.Num = 0
        specailEquipInfo.StarLevel = equipStarLevel
        specailEquipInfo.Type = BaseConfig.GT_EQUIP

        local equipConfig = BaseConfig.GetEquip(self.data.chooseHeroSpecialEquipID, equipStarLevel)
        local starDta = Common.getHeroStarLevelColor(equipStarLevel)
        self.controls.equipName:setString(equipConfig.name)
        self.controls.equipName:setColor(starDta.Color)

        local herolist = equipConfig.heroList
        local desc = ""
        for k,v in pairs(herolist) do
            local heroName = BaseConfig.GetHero(v, 0).name
            if k == (#herolist) then
                desc = desc..heroName.."的专属装备"
            else
                desc = desc..heroName.."，"
            end
        end
        local _, desc1 = Common.StringLinefeed(desc, 12)
        self.controls.specailEquipDesc:setString(desc1)

        if not self.controls.specailEquipItem then
            self.controls.specailEquipItem = EquipInfo.new(specailEquipInfo, self.data.chooseHeroInfo, BaseConfig.GOODS_MIDDLETYPE, nil, true)
            self.controls.specailEquipItem:setPosition(-self.controls.bg:getContentSize().width * 0.3, 
                                                self.controls.bg:getContentSize().height * 0.22)
            self.controls.ownSpecailNode:addChild(self.controls.specailEquipItem)
        end
        local ownEquipInfo = GameCache.GetEquip(self.data.chooseHeroSpecialEquipID, equipStarLevel)
        if ownEquipInfo then
            specailEquipInfo = ownEquipInfo
            local touchFunc = function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    Common.CloseGuideLayer({6})
                    local goodsInfo = self.controls.specailEquipItem:getGoodsInfo()
                    local boxShow = EquipInfoBox.new(self.data.chooseHeroInfo, goodsInfo, false, self.controls.specailEquipItem)
                    boxShow.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                    application:dispatchCustomEvent(AppEvent.UI.Hero.AddChildNode, {Child = boxShow})
                    Common.OpenGuideLayer({6})
                end
            end
            self.controls.specailEquipItem:addTouchEventListener(touchFunc)
        else
            local touchFunc = function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local goodsInfo = self.controls.specailEquipItem:getGoodsInfo()
                    local tips = require("scene.main.hero.widget.GetGoodsWayBox").new(BaseConfig.GOODS_EQUIP, goodsInfo, self.controls.specailEquipItem)
                    tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                    application:dispatchCustomEvent(AppEvent.UI.Hero.AddChildNode, {Child = tips})
                end
            end
            self.controls.specailEquipItem:addTouchEventListener(touchFunc)
        end
        self.controls.specailEquipItem:setGoodsInfo(specailEquipInfo, self.data.chooseHeroInfo)
        self.controls.specailEquipItem:setNum()
    else
        self.controls.unOwnSpecailNode:setPosition(0, 0)
        self.controls.ownSpecailNode:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
    end
end

function EquipPanel:updateCommonEquipData()
    table.sort(self.data.chooseHeroCommonEquipIDTab, handler(self, self.equipSort))
    local size = self.controls.bg:getContentSize()
    for i=1,6 do
        if i <= (#self.data.chooseHeroCommonEquipIDTab) then
            local equipID = self.data.chooseHeroCommonEquipIDTab[i]
            local fragToEquipConfig = BaseConfig.GetFragToEquip(equipID)
            local equipStarLevel = fragToEquipConfig.starLevel

            local ownEquipInfo = GameCache.GetEquip(equipID, equipStarLevel)
            local isHaveEquip = nil
            local commonEquipInfo = {}
            if ownEquipInfo then
                isHaveEquip = true
                commonEquipInfo = ownEquipInfo
            else
                isHaveEquip = false
                commonEquipInfo.ID = equipID
                commonEquipInfo.Num = 0
                commonEquipInfo.StarLevel = equipStarLevel
                commonEquipInfo.Type = BaseConfig.GT_EQUIP
            end

            if not self.controls.commonEquipTtemTab[i] then
                self.controls.commonEquipTtemTab[i] = EquipInfo.new(commonEquipInfo, self.data.chooseHeroInfo, BaseConfig.GOODS_MIDDLETYPE, nil, true)
                self.controls.equipmentView:addChild(self.controls.commonEquipTtemTab[i])
            else
                self.controls.commonEquipTtemTab[i]:setGoodsInfo(commonEquipInfo, self.data.chooseHeroInfo)
            end
            self.controls.commonEquipTtemTab[i]:setPosition(-size.width * 0.3 + ((i - 1)%3) * 120 , 
                                                        -size.height * 0.08 - 110 * (math.floor((i - 1)/3)))
            self.controls.commonEquipTtemTab[i]:setNum()

            self.controls.commonEquipTtemTab[i]:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if isHaveEquip then
                        Common.CloseGuideLayer({7})
                        local boxShow = EquipInfoBox.new(self.data.chooseHeroInfo, sender:getGoodsInfo(), false, sender)
                        boxShow.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                        application:dispatchCustomEvent(AppEvent.UI.Hero.AddChildNode, {Child = boxShow})
                        Common.OpenGuideLayer({7})
                    else
                        local tips = require("scene.main.hero.widget.GetGoodsWayBox").new(BaseConfig.GOODS_EQUIP, sender:getGoodsInfo(), sender)
                        tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                        application:dispatchCustomEvent(AppEvent.UI.Hero.AddChildNode, {Child = tips})
                    end
                end
            end)
        else
            if self.controls.commonEquipTtemTab[i] then
                self.controls.commonEquipTtemTab[i]:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
            end
        end

    end
end

function EquipPanel:updateTrumpView(equipTypeID, heroInfo)
    self.data.currEquipView = TRUMP_VIEW
    self.data.currTrumpTypeID = equipTypeID or self.data.currTrumpTypeID

    self.data.trumpIDTab = {}
    if BaseConfig.ET_MAGIC == self.data.currTrumpTypeID then
        self.data.trumpIDTab = self.data.commonMagicIDTab
    elseif BaseConfig.ET_BOOK == self.data.currTrumpTypeID then
        self.data.trumpIDTab = self.data.commonBookIDTab
    end

    self.controls.shuoming1:setPosition(0, self.controls.bg:getContentSize().height * 0.36)
    self.controls.trumpView:setScale(1)
    if self.controls.equipmentView then
        self.controls.equipmentView:setScale(0)
    end
    if self.controls.skinView then
        self.controls.skinView:setScale(0)
    end

    for k,v in pairs(self.data.equip_chooseBtns) do
        if v:getTag() == self.data.currEquipView then
            v:setTouchStatus()
        else
            v:setNormalStatus()
        end
    end

    self:updateTrumpData()
end

function EquipPanel:updateTrumpData()
    table.sort(self.data.trumpIDTab, handler(self, self.equipSort))
    local size = self.controls.bg:getContentSize()
    local ownTrumpInfoTabs = {}
    for k,trumpInfo in pairs(GameCache.GetTrump()) do
        ownTrumpInfoTabs[trumpInfo.ID] = trumpInfo
    end
    for i=1,12 do
        if i <= (#self.data.trumpIDTab) then
            local trumpID = self.data.trumpIDTab[i]
            local ownTrumpInfo = ownTrumpInfoTabs[trumpID]
            local isHaveTrump = false
            local trumpInfo = {}
            if ownTrumpInfo then
                isHaveTrump = true
                trumpInfo = ownTrumpInfo
            else
                isHaveTrump = false
                trumpInfo.ID = trumpID
                trumpInfo.Num = 0
                local fragToEquipConfig = BaseConfig.GetFragToEquip(trumpID)
                local equipStarLevel = fragToEquipConfig.starLevel
                trumpInfo.StarLevel = equipStarLevel
                trumpInfo.Type = BaseConfig.GT_EQUIP
            end

            if not self.data.trumpItemTab[i] then
                self.data.trumpItemTab[i] = EquipInfo.new(trumpInfo, self.data.chooseHeroInfo, BaseConfig.GOODS_MIDDLETYPE, nil, true)
                self.controls.trumpView:addChild(self.data.trumpItemTab[i])
            else
                self.data.trumpItemTab[i]:setGoodsInfo(trumpInfo, self.data.chooseHeroInfo)
            end
            self.data.trumpItemTab[i]:setNum()
            self.data.trumpItemTab[i]:setPosition(-size.width * 0.3 + ((i - 1)%3) * 120 , size.height * 0.22 - 105 * (math.floor((i - 1)/3)))

            self.data.trumpItemTab[i]:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local boxShow = EquipInfoBox.new(self.data.chooseHeroInfo, sender:getGoodsInfo(), false, sender)
                    boxShow.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                    local runningScene = cc.Director:getInstance():getRunningScene()
                    runningScene:addChild(boxShow)
                end
            end)
        else
            if self.data.trumpItemTab[i] then
                self.data.trumpItemTab[i]:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
            end
        end
    end
end

function EquipPanel:updateSkinView(equipTypeID, heroInfo)
    self.data.currEquipView = SKIN_VIEW
    self.data.currEquipTypeID = equipTypeID or self.data.currEquipTypeID

    if nil == self.controls.skinView then
        self.controls.skinView = require("scene.main.hero.widget.EquipView").new(heroInfo, false, self.data.viewSize, true)
        self.controls.skinView:setTag(SKIN_VIEW)
        self.controls.skinView:setPosition(-self.data.size.width * 0.465, -self.data.size.height * 0.45)
        self:addChild(self.controls.skinView)
    end
    self.controls.skinView:updateView(equipTypeID, heroInfo)

    self.controls.shuoming1:setPosition(0, self.controls.bg:getContentSize().height * 0.36)
    self.controls.skinView:setScale(1)
    if self.controls.equipmentView then
        self.controls.equipmentView:setScale(0)
    end
    if self.controls.trumpView then
        self.controls.trumpView:setScale(0)
    end

    for k,v in pairs(self.data.equip_chooseBtns) do
        if v:getTag() == self.data.currEquipView then
            v:setTouchStatus()
        else
            v:setNormalStatus()
        end
    end
end

function EquipPanel:equipSort(a, b)
    local a_fragToEquipConfig = BaseConfig.GetFragToEquip(a)
    local a_equipStarLevel = a_fragToEquipConfig.starLevel
    local a_equipConfig = BaseConfig.GetEquip(a, a_equipStarLevel)
    local a_talent = a_equipConfig.talent
    local a_equipInfo = GameCache.GetEquip(a, a_equipStarLevel)
    local a_num = 0
    if a_equipInfo then
        a_num = a_equipInfo.Num
    end

    local b_fragToEquipConfig = BaseConfig.GetFragToEquip(b)
    local b_equipStarLevel = b_fragToEquipConfig.starLevel
    local b_equipConfig = BaseConfig.GetEquip(b, b_equipStarLevel)
    local b_talent = b_equipConfig.talent
    local b_equipInfo = GameCache.GetEquip(b, b_equipStarLevel)
    local b_num = 0
    if b_equipInfo then
        b_num = b_equipInfo.Num
    end

    if a_equipStarLevel == b_equipStarLevel then
        if a_talent == b_talent then
            if a_num == b_num then
                return a < b
            else
                return a_num > b_num
            end
        else
            return a_talent > b_talent
        end
    else
        return a_equipStarLevel > b_equipStarLevel
    end 
end

return EquipPanel


