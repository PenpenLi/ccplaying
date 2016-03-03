local EquipInfoBox = class("EquipInfoBox", require("tool.helper.CommonTips"))
local ColorLabel = require("tool.helper.ColorLabel")

local EQUIPMENT_VIEW, TRUMP_VIEW = 1, 2

--[[
    isWear -- 是否已经穿戴 (判断装备等级是否为1)
    isPlayer -- 显示自己还是玩家的装备Tips
]] 
function EquipInfoBox:ctor(heroInfo, equipInfo, isWear, goodsItem, isPlayer)
    EquipInfoBox.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, goodsItem)
    self.data.heroInfo = heroInfo
    self.data.isWear = isWear
    self.data.goodsItem = goodsItem
    self.data.isPlayer = isPlayer

    self:createUI()
end

function EquipInfoBox:onExit()
    EquipInfoBox.super.onExit(self)
    application:dispatchCustomEvent(AppEvent.UI.Hero.CloseEquipTips, {})
end

function EquipInfoBox:createUI()
    self.data.currHeroEquipTabInfo = self.data.heroInfo.Equip
    local equipInfo = self.data.currHeroEquipTabInfo[self.data.goodsConfigInfo.type]
    local tishiHeight = 50
    if equipInfo.ID ~= 0 then
        if self.data.goodsConfigInfo.type < 5 then
            tishiHeight = 120
        else
            tishiHeight = 140
        end
    end

    if self.data.isWear then
        self:updateGoods(self.data.goodsInfo, 50)
    else
        self:updateGoods(self.data.goodsInfo, tishiHeight)
    end

    if self.data.isPlayer then
        return 
    end

    if self.data.isWear then
        local btn_intensify = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 62))
        btn_intensify:setCircleFont("强化", 1, 1, 25, cc.c3b(226, 204, 169))
        btn_intensify:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
        btn_intensify:setPosition(self.data.size.width * 0.5, 60)
        self.controls.bg:addChild(btn_intensify)
        btn_intensify:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                application:pushScene("main.hero.EquipIntensifyScene", self.data.heroInfo, self.data.goodsInfo)
                self:onExit()
            end
        end)
    else
        local btn_wear = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 62))
        btn_wear:setCircleFont("装上", 1, 1, 25, cc.c3b(251, 202, 118), 1)
        btn_wear:setFontOutline(cc.c4b(77, 36, 0, 255), 2)
        btn_wear:setPosition(self.data.size.width * 0.5, 60)
        self.controls.bg:addChild(btn_wear)
        btn_wear:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if 0 == self.data.goodsInfo.Num then
                    self:onExit()

                    local treasureTabs = nil
                    local winInfo = nil

                    rpc:call("Loot.Init", nil, function(event)
                        if event.status == Exceptions.Nil then
                            treasureTabs = event.result.FragList or {}
                            winInfo = event.result.WinInfo or {}
                            local currScene = require("scene.main.loot.LootScene").new(treasureTabs, winInfo)
                            cc.Director:getInstance():pushScene(currScene)
                            -- local child = currScene:getChildren()
                        end
                    end)
                    return
                end

                if equipInfo.ID ~= 0 then
                    local alertShow = self:lowAlert(equipInfo)
                    alertShow:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
                    local scene = cc.Director:getInstance():getRunningScene()
                    scene:addChild(alertShow)
                else
                    self:installEquip()
                end
            end
        end)
        if 0 == self.data.goodsInfo.Num then
            btn_wear:setString("获取途径")
        end

        if equipInfo.ID ~= 0 then
            local heroEquipConfig = BaseConfig.GetEquip(equipInfo.ID, equipInfo.StarLevel)
            local currTalent = heroEquipConfig.talent
            local spriPath = nil
            if (self.data.goodsConfigInfo.talent) > currTalent then
                spriPath = "image/ui/img/btn/btn_277.png"
            elseif (self.data.goodsConfigInfo.talent) < currTalent then
                spriPath = "image/ui/img/btn/btn_276.png"
            end
            if spriPath then
                local compareSpri = cc.Sprite:create(spriPath)
                compareSpri:setAnchorPoint(0, 0.5)
                local talentX, talentY = self.controls.talent:getPosition()
                compareSpri:setPosition(talentX + self.controls.talent:getContentSize().width * 0.55, 
                                    talentY - self.controls.talent:getContentSize().height * 0.5)
                self.controls.bg:addChild(compareSpri)
            end

            if heroEquipConfig.type < 5 then
                local labels = self:getEquipCompareDesc(equipInfo)
                local tishi = labels.tishiLabel
                local compareDesc = labels.compareLabel
                local compareSpri = labels.compareSpri

                tishi:setPosition(self.data.size.width * 0.5, tishiHeight + 20)
                self.controls.bg:addChild(tishi)

                compareDesc:setPosition(self.data.size.width * 0.5, tishi:getPositionY() - 25)
                self.controls.bg:addChild(compareDesc)

                if compareSpri then
                    compareSpri:setPosition(compareDesc:getPositionX() + compareDesc:getContentSize().width * 0.55, tishi:getPositionY() - 25)
                    self.controls.bg:addChild(compareSpri)
                end
            else
                local labels = self:getTrumpCompareDesc(equipInfo)
                local tishi = labels.tishiLabel
                local compareDesc1 = labels.compareLabel1
                local compareDesc2 = labels.compareLabel2
                local spriPath = labels.spriPath

                tishi:setPosition(self.data.size.width * 0.5, tishiHeight + 20)
                self.controls.bg:addChild(tishi)

                local desc2PosY = tishi:getPositionY() - 50
                compareDesc1:setPosition(self.data.size.width * 0.5, tishi:getPositionY() - 25)
                self.controls.bg:addChild(compareDesc1)
                compareDesc2:setPosition(self.data.size.width * 0.5, desc2PosY)
                self.controls.bg:addChild(compareDesc2)

                if spriPath then
                    local compareSpri = cc.Sprite:create(spriPath)
                    compareSpri:setAnchorPoint(0, 0.5)
                    compareSpri:setPosition(compareDesc1:getPositionX() + compareDesc1:getContentSize().width * 0.55, tishi:getPositionY() - 25)
                    self.controls.bg:addChild(compareSpri)

                    compareSpri = cc.Sprite:create(spriPath)
                    compareSpri:setAnchorPoint(0, 0.5)
                    compareSpri:setPosition(compareDesc2:getPositionX() + compareDesc2:getContentSize().width * 0.55, desc2PosY)
                    self.controls.bg:addChild(compareSpri)
                end
            end
        end
    end
end

function EquipInfoBox:getAttributeValue(config, level)
    if config.type == BaseConfig.ET_ARM then
        return config.atk + math.floor(((level - 1) * config.atkGrow)/10000)
    elseif config.type == BaseConfig.ET_HAT then
        return config.def + math.floor(((level - 1) * config.defGrow)/10000)
    elseif config.type == BaseConfig.ET_RING then
        return config.mp + math.floor(((level - 1) * config.mpGrow)/10000)
    elseif config.type == BaseConfig.ET_COAT then
        return config.hp + math.floor(((level - 1) * config.hpGrow)/10000)
    end
end

function EquipInfoBox:getEquipCompareDesc(heroEquipInfo)
    local heroEquipConfig = BaseConfig.GetEquip(heroEquipInfo.ID, heroEquipInfo.StarLevel)
    local currEquipConfig = self.data.goodsConfigInfo
    local heroEquipValue = self:getAttributeValue(heroEquipConfig, heroEquipInfo.Level)
    local currEquipValue = self:getAttributeValue(currEquipConfig, heroEquipInfo.Level)

    local compareDesc = nil
    local compareValue = currEquipValue - heroEquipValue
    local descColor = nil
    local spriPath = nil
    if compareValue > 0 then
        compareDesc = "升"
        descColor = "[0,255,50]"
        spriPath = "image/ui/img/btn/btn_277.png"
    elseif compareValue < 0 then
        compareDesc = "降"
        descColor = "[255,0,0]"
        spriPath = "image/ui/img/btn/btn_276.png"
        self.isLowCurrEquip = true
    else
        compareDesc = ""
        descColor = "[255,255,255]"
    end

    local attribute = nil
    if heroEquipConfig.type == BaseConfig.ET_ARM then
        attribute = descColor.."攻击将"..compareDesc.."为:[=]".."[255,220,20]"..currEquipValue.."[=]"
    elseif heroEquipConfig.type == BaseConfig.ET_HAT then
        attribute = descColor.."防御将"..compareDesc.."为:[=]".."[255,220,20]"..currEquipValue.."[=]"
    elseif heroEquipConfig.type == BaseConfig.ET_RING then
        attribute = descColor.."法力将"..compareDesc.."为:[=]".."[255,220,20]"..currEquipValue.."[=]"
    elseif heroEquipConfig.type == BaseConfig.ET_COAT then
        attribute = descColor.."生命将"..compareDesc.."为:[=]".."[255,220,20]"..currEquipValue.."[=]"
    end

    local tishi = ColorLabel.new(descColor.."装备后可继承<"..heroEquipConfig.name..">的等级[=]", 18)
    local compareDesc = ColorLabel.new(attribute, 18)

    return {tishiLabel = tishi, compareLabel = compareDesc, spriPath = spriPath}
end

function EquipInfoBox:getTrumpCompareDesc(heroEquipInfo)
    local function getAttributeValue(config, level)
        if config.type == BaseConfig.ET_MAGIC then
            local result1 = (config.atkRatio + config.atkRatioGrow * (level - 1)) / 100
            result1 = string.format("%.1f", result1)
            local result2 = (config.mpRatio + config.mpRatioGrow * (level - 1)) / 100
            result2 = string.format("%.1f", result2)
            return {Result1 = result1, Result2 = result2}
        elseif config.type == BaseConfig.ET_BOOK then
            local result1 = (config.defRatio + config.defRatioGrow * (level - 1)) / 100
            result1 = string.format("%.1f", result1)
            local result2 = (config.hpRatio + config.hpRatioGrow * (level - 1)) / 100
            result2 = string.format("%.1f", result2)
            return {Result1 = result1, Result2 = result2}
        end
    end
    local heroTrumpConfig = BaseConfig.GetEquip(heroEquipInfo.ID, heroEquipInfo.StarLevel)
    local currEquipConfig = self.data.goodsConfigInfo

    local heroResultTab = getAttributeValue(heroTrumpConfig, heroEquipInfo.Level)
    local currResultTab = getAttributeValue(currEquipConfig, heroEquipInfo.Level)

    local compareDesc = nil
    local compareValue = currResultTab.Result1 - heroResultTab.Result1
    local descColor = nil
    local spriPath = nil
    if compareValue > 0 then
        compareDesc = "升"
        descColor = "[0,255,50]"
        spriPath = "image/ui/img/btn/btn_277.png"
    elseif compareValue < 0 then
        compareDesc = "降"
        descColor = "[255,0,0]"
        spriPath = "image/ui/img/btn/btn_276.png"
        self.isLowCurrEquip = true
    else
        compareDesc = ""
        descColor = "[255,255,255]"
    end

    local compareSpri = nil
    if spriPath then
        compareSpri = cc.Sprite:create(spriPath)
        compareSpri:setAnchorPoint(0, 0.5)
    end

    local attributeTab = {}
    local result1 = currResultTab.Result1
    local result2 = currResultTab.Result2
    if heroTrumpConfig.type == BaseConfig.ET_MAGIC then
        attributeTab[1] = descColor.."攻击将"..compareDesc.."为:[=]".."[255,220,20]"..result1.."%[=]"
        attributeTab[2] = descColor.."法力将"..compareDesc.."为:[=]".."[255,220,20]"..result2.."%[=]"
    elseif heroTrumpConfig.type == BaseConfig.ET_BOOK then
        attributeTab[1] = descColor.."防御将"..compareDesc.."为:[=]".."[255,220,20]"..result1.."%[=]"
        attributeTab[2] = descColor.."生命将"..compareDesc.."为:[=]".."[255,220,20]"..result2.."%[=]"
    end

    local tishi = ColorLabel.new(descColor.."装备后可继承<"..heroTrumpConfig.name..">的等级[=]", 18)
    local compareDesc1 = ColorLabel.new(attributeTab[1], 18)
    local compareDesc2 = ColorLabel.new(attributeTab[2], 18)

    return {tishiLabel = tishi, compareLabel1 = compareDesc1, compareLabel2 = compareDesc2, compareSpri = compareSpri}
end

function EquipInfoBox:lowAlert(heroEquipInfo)
    local node = cc.Node:create()
    local size = cc.size(600, 300)

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(-SCREEN_WIDTH * 0.5, -SCREEN_HEIGHT * 0.5)
    node:addChild(bgLayer)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bgLayer)

    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(size)
    node:addChild(bg)

    local label = Common.finalFont("上仙,更换装备后")
    label:setPosition(size.width * 0.35, size.height * 0.7)
    bg:addChild(label)

    local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, heroEquipInfo, BaseConfig.GOODS_SMALLTYPE)
    goodsItem:setPosition(label:getPositionX() + label:getContentSize().width * 0.5 + goodsItem:getContentSize().width * 0.6, label:getPositionY())
    bg:addChild(goodsItem)

    label = Common.finalFont("将被覆盖!")
    label:setPosition(goodsItem:getPositionX() + goodsItem:getContentSize().width * 0.5 + label:getContentSize().width * 0.6, goodsItem:getPositionY())
    bg:addChild(label)

    label = Common.finalFont("若装备后,将返回50%的升星花费,你确定要装上吗?")
    label:setPosition(size.width * 0.5, size.height * 0.5)
    bg:addChild(label)

    local btn_wear = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 62))
    btn_wear:setCircleFont("装上", 1, 1, 25, cc.c3b(226, 204, 169))
    btn_wear:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    btn_wear:setPosition(size.width * 0.3, 60)
    bg:addChild(btn_wear)
    btn_wear:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            node:removeFromParent()
            node = nil
            self:installEquip()
        end
    end)

    local btn_quxiao = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 62))
    btn_quxiao:setCircleFont("不装了", 1, 1, 25, cc.c3b(226, 204, 169))
    btn_quxiao:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    btn_quxiao:setPosition(size.width * 0.7, 60)
    bg:addChild(btn_quxiao)
    btn_quxiao:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            node:removeFromParent()
            node = nil
            self:onExit()
        end
    end)

    return node
end

function EquipInfoBox:setBgPosition(x, y)
    self.controls.bg:setPosition(x, y)
end

function EquipInfoBox:getContentSize()
    return self.data.size
end

function EquipInfoBox:installEquip()
    local heroEquip = self.data.currHeroEquipTabInfo[self.data.goodsConfigInfo.type]
    if heroEquip.ID == self.data.goodsInfo.ID then
        if heroEquip.StarLevel >= self.data.goodsInfo.StarLevel then
            application:showFlashNotice("不能穿戴低星级的相同装备～！")
            return
        end
    end

    local id = self.data.goodsInfo.ID
    local starLevel = self.data.goodsInfo.StarLevel
    self:install(self.data.heroInfo.ID, self.data.goodsConfigInfo.type, id, starLevel)

    if GameCache.NewbieGuide.Step == 6 then
        Common.CloseGuideLayer({6})
        Common.ResetGuideLayer({big = 7, small = 3})
     
    elseif GameCache.NewbieGuide.Step == 7 then
        Common.CloseGuideLayer({7})
        Common.SaveGuideLayer()
        local guide = self:CreateSwallowGuideLayer( 0,0,SCREEN_WIDTH,SCREEN_HEIGHT,GameCache.NewbieGuide.Step )
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(guide)
    end
    Common.OpenGuideLayer({7})
end

-- 装上装备
function EquipInfoBox:install(_heroID, _equipType, _equipID, _equipStarLevel)
    local p = {
        ID = _heroID,
        EquipID = _equipID,
        -- EquipStarLevel = _equipStarLevel
    }
    
    rpc:call("Hero.InstallEquip", p, function(event)
        if event.status == Exceptions.Nil then
            local beforeHeroInfo = Common.copyTab(self.data.heroInfo)
            self.data.goodsInfo.Num = self.data.goodsInfo.Num - 1
            if self.data.goodsInfo.Num ~= 0 then
                self.data.goodsItem:setNum(self.data.goodsInfo.Num)
            else
                GameCache.minusEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel, 0)
            end

            local heroValue = GameCache.GetHero(self.data.heroInfo.ID)
            if heroValue then
                local heroEquipInfo = heroValue.Equip[_equipType]
                heroEquipInfo.ID = p.EquipID
                if (BaseConfig.ET_HAT == _equipType) or (BaseConfig.ET_COAT == _equipType) then
                    local skinStatusInfo = heroValue.SkinStatus[(_equipType / 2)]
                    if 0 ~= skinStatusInfo.ID then
                        if not skinStatusInfo.IsShow then
                            heroEquipInfo.SkinID = p.EquipID
                        end
                    else
                        heroEquipInfo.SkinID = p.EquipID
                    end
                else
                    heroEquipInfo.SkinID = p.EquipID
                end
                local tempData = {
                    EquipType = _equipType,
                    SkinID = p.EquipID
                }
                application:dispatchCustomEvent(AppEvent.UI.Hero.ChangeSkin, tempData)

                if heroEquipInfo.Level == 0 then
                    heroEquipInfo.Level = 1
                end
                heroEquipInfo.StarLevel = p.EquipStarLevel
                
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateWearEquip, {EquipType = _equipType, EquipTabs = heroValue.Equip, IsPlay = true})
                application:dispatchCustomEvent(AppEvent.UI.Hero.IsShowAlert, {HeroInfo = self.data.heroInfo, IsEquip = true})
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                            {BeforeHero = beforeHeroInfo, CurrHero = self.data.heroInfo})
                if _equipType < 5 then
                    application:dispatchCustomEvent(AppEvent.UI.Hero.RefreshEquipMent, {EquipType = _equipType})
                else
                    application:dispatchCustomEvent(AppEvent.UI.Hero.RefreshTrump, {EquipType = _equipType})
                end
            end
            -- 返还物品
            local goodsTabs = event.result
            if type(goodsTabs) == "table" then
                application:showIconNotice(goodsTabs)
            end

            self:onExit()
        end
    end)
end

function EquipInfoBox:CreateSwallowGuideLayer( posx,posy,width,height, step )
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), width, height)
    layer:setPosition(posx, posy)


    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function() return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function ( ) 
        -- Common.CloseGuideLayer({6,7})

        Common.CloseGuideLayer({7})
        Common.OpenGuideLayer({7})
        layer:removeFromParent() 
        layer = nil 
    end,   cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    return layer
end

return EquipInfoBox

