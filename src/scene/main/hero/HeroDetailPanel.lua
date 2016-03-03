local DetailPanel = class("DetailPanel", function()
    local self = cc.Node:create()
    self.controls = {}
    self.data = {}
    return self
end)
local effects = require("tool.helper.Effects")

function DetailPanel:ctor()
    self:createFixedUI()
end

function DetailPanel:createFixedUI()
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(cc.size(416, 586))
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_794.png")
    detailName:setTouchEnable(false)
    detailName:setPosition(0, size.height * 0.42)
    self:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(-size.width * 0.2, size.height * 0.42)
    self:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(size.width * 0.2, size.height * 0.42)
    self:addChild(line)

    local function equipFate()
        detailName = createMixSprite("image/ui/img/btn/btn_781.png")
        detailName:setTouchEnable(false)
        detailName:setCircleFont("装备缘分", 1, 1, 20, cc.c3b(78, 160, 190))
        detailName:setPosition(0, size.height * 0.34)
        self:addChild(detailName)
        local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
        line:setPosition(-size.width * 0.3, size.height * 0.34)
        self:addChild(line)
        line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
        line:setScaleX(-1)
        line:setPosition(size.width * 0.3, size.height * 0.34)
        self:addChild(line)

        local help = cc.Sprite:create("image/ui/img/btn/btn_868.png")
        help:setPosition(size.width * 0.4, size.height * 0.34)
        help:setScale(0.7)
        self:addChild(help)

        self.data.equipFateNameTab = {}
        self.data.equipFateExtraEffectTab = {}
        self.data.equipFatePosYTab = {150, 120, 90, 60}
        local nameTab = {"武器", "头盔", "戒指", "衣服"}
        for i=1,4 do
            local name = Common.finalFont(nameTab[i], -size.width * 0.43, self.data.equipFatePosYTab[i])
            name:setAnchorPoint(0, 0)
            self:addChild(name)
            local addition = Common.finalFont("攻击+5%", size.width * 0.16, self.data.equipFatePosYTab[i])
            addition:setAnchorPoint(0, 0)
            self:addChild(addition)

            table.insert(self.data.equipFateNameTab, name)
            table.insert(self.data.equipFateExtraEffectTab, addition)
        end
    end
    
    local function heroFate()
        detailName = createMixSprite("image/ui/img/btn/btn_781.png")
        detailName:setTouchEnable(false)
        detailName:setCircleFont("星将缘分", 1, 1, 20, cc.c3b(78, 160, 190))
        detailName:setPosition(0, 20)
        self:addChild(detailName)
        local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
        line:setPosition(-size.width * 0.3, 20)
        self:addChild(line)
        line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
        line:setScaleX(-1)
        line:setPosition(size.width * 0.3, 20)
        self:addChild(line)

        self.controls.list_detail = ccui.ListView:create()
        self.controls.list_detail:setDirection(ccui.ScrollViewDir.vertical)
        self.controls.list_detail:setTouchEnabled(true)
        self.controls.list_detail:setBounceEnabled(true)
        self.controls.list_detail:setContentSize(cc.size(size.width, 164))
        self.controls.list_detail:setPosition(-size.width * 0.45, -size.height * 0.275)
        self:addChild(self.controls.list_detail)
    end
    
    local function heroBiography()
        detailName = createMixSprite("image/ui/img/btn/btn_781.png")
        detailName:setTouchEnable(false)
        detailName:setCircleFont("星将小传", 1, 1, 20, cc.c3b(78, 160, 190))
        detailName:setPosition(0, -size.height * 0.3)
        self:addChild(detailName)
        local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
        line:setPosition(-size.width * 0.3, -size.height * 0.3)
        self:addChild(line)
        line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
        line:setScaleX(-1)
        line:setPosition(size.width * 0.3, -size.height * 0.3)
        self:addChild(line)

        self.controls.heroBiography = Common.finalFont("", -size.width * 0.45, -size.height * 0.35, 20, cc.c3b(247, 240, 230))
        self.controls.heroBiography:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        self.controls.heroBiography:setAnchorPoint(0, 1)
        self:addChild(self.controls.heroBiography)
    end
    equipFate()
    heroFate()
    heroBiography()

    local layer = cc.LayerColor:create(cc.c4b(255,255,0,0), size.width, size.height * 0.32)
    layer:setPosition(0, size.height * 0.54)
    self.controls.bg:addChild(layer)
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
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then 
            local equipListLayer = self:specialEquipList(cc.size(700, 408))
            equipListLayer:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(equipListLayer)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function DetailPanel:specialEquipList(size)
    local node = cc.Node:create()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    layer:setPosition(-SCREEN_WIDTH * 0.5, -SCREEN_HEIGHT * 0.5)
    node:addChild(layer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(size)
    node:addChild(bg)
    
    local title = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_1099.png")
    title:setTouchEnable(false)
    title:setPosition(size.width * 0.5, size.height * 0.95)
    bg:addChild(title)

    local bottom = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(size.width * 0.97, 100))
    bottom:setPosition(size.width * 0.5, 62)
    bg:addChild(bottom)

    local equipNum = #self.data.equipFateIDTab
    local initPos = {}
    initPos.x = size.width * 0.3
    initPos.y = size.height * 0.68
    local space = size.width * 0.4
    if equipNum == 3 then
        initPos.x = size.width * 0.2
        space = size.width * 0.3
    elseif equipNum == 4 then
        initPos.x = size.width * 0.16
        space = size.width * 0.23
    end
    for i=1,equipNum do
        local compoundInfo = BaseConfig.GetFragToEquip(self.data.equipFateIDTab[i])
        local goodsInfo = {}
        goodsInfo.ID = compoundInfo.productID
        goodsInfo.StarLevel = compoundInfo.starLevel
        goodsInfo.Type = BaseConfig.GT_EQUIP
        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, goodsInfo)
        goodsItem:setTouchEnable(false)
        goodsItem:setGoodsName()
        goodsItem:setPosition(initPos.x, initPos.y)
        bg:addChild(goodsItem)
        local itemSize = goodsItem:getContentSize()

        local tishi = effects:CreateAnimation(goodsItem, 0, -itemSize.height * 1.2, nil, 17, true)
        tishi:setRotation(90)
        tishi:setScaleY(2)

        local way = createMixSprite("image/ui/img/btn/btn_818.png")
        way:setFont("获取" , 1, 1, 20, cc.c3b(248, 216, 136), 1)
        way:setPosition(0, -itemSize.height * 2.2)
        goodsItem:addChild(way)
        way:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local goodsList = self:getWayList(goodsInfo.Type, goodsInfo, cc.size(size.width * 0.55, size.height * 1.2))
                goodsList:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(goodsList)
            end
        end)

        local move = cc.MoveTo:create((i - 1) * 0.12, cc.p(initPos.x + (i - 1)*space, initPos.y))
        goodsItem:runAction(cc.Sequence:create(move))
    end

    local function onEnded(touch, event)
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
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
    return node
end

function DetailPanel:getWayList(goodsType, goodsInfo, size)
    local node = cc.Node:create()
    local bg = cc.LayerColor:create(cc.c4b(0,0,0,0), size.width, size.height)
    bg:setPosition(-size.width * 0.5, -size.height * 0.5)
    node:addChild(bg)

    local goodsList = require("scene.main.hero.widget.GetWayListBox").new(goodsType, goodsInfo, size)
    node:addChild(goodsList)
    
    local function onEnded(touch, event)
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
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
    return node
end

function DetailPanel:updateHeroInfo(heroInfo, configInfo)
    self.data.chooseHeroInfo = heroInfo
    self.data.chooseHeroConfigInfo = configInfo

    self:updateFateInfo(heroInfo.ID, heroInfo.Equip)
    self:updateBiography(configInfo)
end

function DetailPanel:updateFateInfo(heroID, heroEquipTab)
    local HEROFATE, EQUIPFATE = 1, 2
    for i=1,4 do
        self.data.equipFateNameTab[i]:setColor(cc.c3b(223, 255, 254))
        self.data.equipFateExtraEffectTab[i]:setColor(cc.c3b(223, 255, 254))
        self.data.equipFateNameTab[i]:setVisible(false)
        self.data.equipFateExtraEffectTab[i]:setVisible(false)
    end

    if self.controls.list_detail then
        self.controls.list_detail:removeAllItems()
    end

    local function equipFateExtraEffect(extraEffectType, extraEffectValue)
        local result = math.floor(extraEffectValue / 100)
        local descAttribute = nil
        if extraEffectType == 1 then
            descAttribute = "攻击+"
        elseif extraEffectType == 2 then
            descAttribute = "防御+"
        elseif extraEffectType == 3 then
            descAttribute = "生命+"
        elseif extraEffectType == 4 then
            descAttribute = "法力+"
        end
        local desc = descAttribute..result.."%"
        return desc
    end

    local function addDescribe(title, nameTab, extraEffectType, extraEffectValue, isHave)
        local desc = "["..title.."]"
        for k,v in pairs(nameTab) do
            if k == 1 then
                desc = desc.."与"..v
            else
                desc = desc.."、"..v
            end
        end

        local descAttribute = equipFateExtraEffect(extraEffectType, extraEffectValue)
        desc = desc.."同在，"..descAttribute

        local row,addition = Common.StringLinefeed(desc, 18)

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(self.controls.list_detail:getContentSize().width, row * 25))

        local texture = nil
        local color = nil
        if isHave then
            texture = cc.TextureCache:getInstance():addImage("image/ui/img/btn/btn_096.png")
            color = cc.c3b(254, 241, 55)
        else
            texture = cc.TextureCache:getInstance():addImage("image/ui/img/btn/btn_097.png")
            color = cc.c3b(223, 255, 254)
        end

        local spri = cc.Sprite:createWithTexture(texture)
        spri:setAnchorPoint(0, 1)
        spri:setPosition(10, layout:getContentSize().height - 5)
        layout:addChild(spri)

        local starLabel = Common.finalFont(addition, 25, spri:getContentSize().height * 1.3, 20, color)
        starLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        starLabel:setAnchorPoint(0, 1)
        spri:addChild(starLabel)

        self.controls.list_detail:pushBackCustomItem(layout)
    end

    local heroFateTabs = BaseConfig.GetFate(heroID, BaseConfig.HERO_FATE_TYPE)
    local heroFateCount = 0
    local heroFateBrightCount = 0
    for k,v in pairs(heroFateTabs) do
        heroFateCount = heroFateCount + 1
        local needPeopleNun = (#v.matchList)
        local currPeopleNum = 0
        local heroNameTab = {}
        for k1,v1 in pairs(v.matchList) do
            table.insert(heroNameTab, BaseConfig.GetHero(v1, 0).name)
            local heroValue = GameCache.GetHero(v1)
            if heroValue then
                currPeopleNum = currPeopleNum + 1
            end
        end

        local isHave = false
        if currPeopleNum == needPeopleNun then
            heroFateBrightCount = heroFateBrightCount + 1
            isHave = true
        end
        addDescribe(v.name, heroNameTab, v.extraEffectType, v.extraEffectValue, isHave)
    end
    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateFateCircle, {Count = heroFateCount, BrightCount = heroFateBrightCount})

    local posIdxY = 1
    local equipFateTabs =  BaseConfig.GetFate(heroID, BaseConfig.EQUIP_FATE_TYPE)
    self.data.equipFateIDTab = {}
    for k,v in pairs(equipFateTabs) do
        for k1,v1 in pairs(v.matchList) do
            local equipType = BaseConfig.GetEquip(v1, 0).type
            self.data.equipFateNameTab[equipType]:setString(BaseConfig.EQUIP_TYPE_NAME[equipType]..":  "..v.name)
            self.data.equipFateExtraEffectTab[equipType]:setString(equipFateExtraEffect(v.extraEffectType, v.extraEffectValue))

            local equipInfo = heroEquipTab[equipType]
            if equipInfo.ID == v1 then
                self.data.equipFateNameTab[equipType]:setColor(cc.c3b(254, 241, 55))
                self.data.equipFateExtraEffectTab[equipType]:setColor(cc.c3b(254, 241, 55))
            end
            self.data.equipFateNameTab[equipType]:setVisible(true)
            self.data.equipFateExtraEffectTab[equipType]:setVisible(true)

            self.data.equipFateNameTab[equipType]:setPositionY(self.data.equipFatePosYTab[posIdxY])
            self.data.equipFateExtraEffectTab[equipType]:setPositionY(self.data.equipFatePosYTab[posIdxY])
            posIdxY = posIdxY + 1

            table.insert(self.data.equipFateIDTab, v1)
        end
    end  
end

function DetailPanel:updateBiography(configInfo)
    local row, str = Common.StringLinefeed(configInfo.desc, 18)
    self.controls.heroBiography:setString(str)
end

return DetailPanel


