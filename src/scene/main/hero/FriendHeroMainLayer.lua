local FriendHeroLayer = class("FriendHeroLayer", BaseLayer)
local effects = require("tool.helper.Effects")
local CalHeroAttr = require("tool.helper.CalHeroAttr")
local EquipInfo = require("scene.main.hero.widget.EquipInfo")
local EquipInfoBox = require("scene.main.hero.widget.EquipInfoBox")
local EquipSkinBox = require("scene.main.hero.widget.EquipSkinBox")

local bgZOrder = 2
local rightPanelZOrder = bgZOrder + 1
local leftPanelZOrder = rightPanelZOrder + 1
local starZOrder = leftPanelZOrder + 1
local btnZOrder = starZOrder + 1

local equipModelLogoTAG = 1

function FriendHeroLayer:ctor(sortId, allHero)
    self.data.heroSortId = sortId
    self.data.allHero = allHero
    self.data.heroTotalNum = #self.data.allHero
    self.data.isShowSkin = false
    self:createFixedUI()
    self:addListener()

    self.controls.digestPanel = require("scene.main.hero.HeroDigestPanel").new(self.data.heroSortId, self.data.allHero)
    self.controls.digestPanel:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.54)
    self.controls.bg:addChild(self.controls.digestPanel, leftPanelZOrder)
    self.controls.digestPanel:setBottomPanelPos(5, -self.data.bgSize.height * 0.35)

    self:updateChooseHero(self.data.heroSortId)
end

function FriendHeroLayer:addListener()
    self.listener = application:addEventListener(AppEvent.UI.Hero.UpdateHeroInfo, function(event)
        local result = event.data
        local sortID = result.SortID
        self.data.heroSortId = sortID
        self:updateChooseHero(self.data.heroSortId)
    end)
end

function FriendHeroLayer:onClose()
    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateHeroList, {})
    application:removeEventListener(self.listener)
    self:removeFromParent()
    self = nil
end

function FriendHeroLayer:createFixedUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.data.bgSize = cc.size(560, 586)
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(self.data.bgSize)
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)

    local bottomPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_185.png")
    bottomPanel:setContentSize(cc.size(540, 170))
    bottomPanel:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.17)
    self.controls.bg:addChild(bottomPanel, bgZOrder)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 1.1, self.data.bgSize.height * 0.97)
    self.controls.bg:addChild(btn_close, btnZOrder)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onClose()
        end
    end)

    local function createArrowBtns()
        self.controls.left_btn = ccui.Button:create("image/ui/img/btn/btn_1005.png", "image/ui/img/btn/btn_1005.png")
        self.controls.left_btn:setName("left")
        self.controls.left_btn:setScale(0.8)
        self.controls.left_btn:setPosition(SCREEN_WIDTH * 0.5 - self.data.bgSize.width * 0.18, 
                                            SCREEN_HEIGHT * 0.5 - self.data.bgSize.height * 0.07)
        self:addChild(self.controls.left_btn, btnZOrder)

        self.controls.right_btn = ccui.Button:create("image/ui/img/btn/btn_1005.png", "image/ui/img/btn/btn_1005.png")
        self.controls.right_btn:setName("right")
        self.controls.right_btn:setScale(0.8)
        self.controls.right_btn:setRotation(180)
        self.controls.right_btn:setPosition(SCREEN_WIDTH * 0.5 + self.data.bgSize.width * 0.18, 
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
        self.controls.heroStarLevelBg:setPosition(size.width * 0.5, size.height * 0.9)
        self.controls.bg:addChild(self.controls.heroStarLevelBg, bgZOrder)

        local bgSize = self.controls.heroStarLevelBg:getContentSize()
        self.controls.heroName = Common.finalFont("", bgSize.width * 0.55, bgSize.height * 0.7, 25, nil, 1)
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
        animBG:setPosition(size.width * 0.5, size.height * 0.58)
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
            star:setPosition(size.width * 0.32, size.height * 0.56 + 20 * i)
            self.controls.bg:addChild(star, starZOrder)
            self.data.heroStarTab[i] = star
        end

        self.data.fateCircleTab = {}

        self.controls.wx = cc.Label:createWithCharMap("image/ui/img/btn/btn_410.png", 31, 31,  string.byte("1"))
        self.controls.wx:setAnchorPoint(0.5, 0.5)
        self.controls.wx:setPosition(size.width * 0.68, size.height * 0.77)
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
            local target = event:getCurrentTarget()
            local name = target:getName()
            local equipID = nil
            for k,v in pairs(nameTab) do
                if name == v then
                    equipID = k
                end
            end

            -- 先判断是否有武器
            if self.data.chooseHeroInfo.Equip[equipID].ID ~= 0 then
                local goodsItem = self.controls.equipWearBgTab[equipID]:getChildByTag(1)
                local equipInfoShow = EquipInfoBox.new(self.data.chooseHeroInfo, self.data.chooseHeroInfo.Equip[equipID], true, goodsItem, true)
                local size = self.data.bgSize
                local viewSize = equipInfoShow:getContentSize()
                local fixHeight = SCREEN_HEIGHT * 0.5 + size.height * 0.01 + viewSize.height * 0.4
                equipInfoShow:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + size.height * 0.1)
                self:addChild(equipInfoShow, btnZOrder)
            end
        end

        for i=1,6 do
            local posX = ((i - 1) % 2) * (size.width * 0.72) + size.width * 0.14
            local posY = size.height * 0.85 - math.floor((i - 1) / 2) * (size.height * 0.21)
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
            local skinInfoTab = self.data.chooseHeroInfo.Skin[skinID]
            if (#skinInfoTab ~= 0) then
                local currSkinInfo = nil
                for k,v in pairs(skinInfoTab) do
                    if v.IsWear then
                        currSkinInfo = v
                        break
                    end
                end
                local skinShow = EquipSkinBox.new(self.data.chooseHeroInfo, currSkinInfo, true)
                if skinID == 1 then
                    skinShow:setPosition(SCREEN_WIDTH * 0.5 - size.width * 0.28, 
                                            SCREEN_HEIGHT * 0.5 + self.data.bgSize.height * 0.05)
                else
                    skinShow:setPosition(SCREEN_WIDTH * 0.5 - size.width * 0.15, 
                                            SCREEN_HEIGHT * 0.5 + self.data.bgSize.height * 0.05)
                end
                self:addChild(skinShow, btnZOrder)
            end
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
                if eventType == ccui.CheckBoxEventType.selected then
                    CCLog("========isCheck===========")
                    self:ShowSkin(self.data.chooseHeroInfo.ID, i, true)
                elseif eventType == ccui.CheckBoxEventType.unselected then
                    CCLog("========notCheck===========")
                    self:ShowSkin(self.data.chooseHeroInfo.ID, i, false)
                end
            end  
            local bgSize = bg:getContentSize()
            local checkBox = ccui.CheckBox:create()
            checkBox:setTouchEnabled(true)
            checkBox:loadTextures("image/ui/img/btn/btn_221.png",
                                       "image/ui/img/btn/btn_221.png",
                                       "image/ui/img/btn/btn_878.png",
                                       "image/ui/img/btn/btn_221.png",
                                       "image/ui/img/btn/btn_878.png")
            checkBox:setPosition(bgSize.width * 0.3, -bgSize.height * 0.5)
            checkBox:addEventListener(selectedEvent)  
            checkBox:setTag(2)
            bg:addChild(checkBox)
            checkBox:setSelectedState(true)

            local label = Common.finalFont("显示" , 1, 1, 20, cc.c3b(0, 0, 0))
            label:setPosition(checkBox:getContentSize().width * 1.8, checkBox:getContentSize().height * 0.5)
            checkBox:addChild(label)

            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
        end
    end
    skinWear()    
end

function FriendHeroLayer:hideChooseBtns()
    for k,v in pairs(self.controls.chooseBtns) do
        v:setNormalStatus()
    end
end

------------------------------------------------
-------------------update-----------------------
function FriendHeroLayer:updateChooseHero(sortId)
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
end

function FriendHeroLayer:updateLevelInfo(star, level, exp)
    local starAttr = Common.getHeroStarLevelColor(star)
    local nameColor = starAttr.Color
    local starNum = starAttr.StarNum
    local starDesc = starAttr.Additional

    local starLevelPath = string.format("image/icon/border/panel_border_star_%d.png", star)
    self.controls.heroStarLevelBg:setTexture(starLevelPath)

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

function FriendHeroLayer:updateEquipWear(equipType, equipTabs)
    local size = self.controls.equipWearBgTab[equipType]:getContentSize()
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
    end
end

function FriendHeroLayer:updateSkinWear(skinType, skinInfo)
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

        --是否勾选显示选项
        local equipInfo = nil
        if skinType == 1 then
            equipInfo = self.data.chooseHeroInfo.Equip[2]
        elseif skinType == 2 then
            equipInfo = self.data.chooseHeroInfo.Equip[4]
        end
        local equipID = equipInfo.ID
        local equipSkinID = equipInfo.SkinID
        -- 通过equipID与equipSkinID值是否相等来判断是否勾选了显示
        if equipID == equipSkinID then
            checkBtn:setSelectedState(false)
        else
            checkBtn:setSelectedState(true)
        end
        checkBtn:setVisible(true)
    else
        if goodsItem then   
            goodsItem:setScale(0)
        end
        checkBtn:setVisible(false)
    end
end

function FriendHeroLayer:updateHeroFateCircle(total, brightCount)
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
return FriendHeroLayer