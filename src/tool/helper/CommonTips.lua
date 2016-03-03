local CommonTips = class("CommonTips", function()
    local self = cc.Node:create()
    self.controls = {}
    self.handlers = {}
    self.data = {}
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return self
end)
local ColorLabel = require("tool.helper.ColorLabel")

local HEROTYPE = BaseConfig.GOODS_HERO
local EQUIPTYPE = BaseConfig.GOODS_EQUIP
local PROPSTYPE = BaseConfig.GOODS_PROPS
local FRAGTYPE = BaseConfig.GOODS_FRAG
local SKILLTYPE = BaseConfig.GOODS_SKILL
local SOULTYPE = BaseConfig.GOODS_SOUL

--[[
    goodsType -- 用在区分星将[头像]、[魂魄]、[装备]、[道具]、[碎片]、[技能]
]]
function CommonTips:ctor(goodsType, goodsInfo, node)
    self.data.goodsType = goodsType
    self.data.goodsInfo = goodsInfo 
    self.data.goodsInfo.Level = self.data.goodsInfo.Level or 1

    if not self.data.goodsInfo.StarLevel then
        if self.data.goodsType == EQUIPTYPE then
            local fragToEquipConfig = BaseConfig.GetFragToEquip(self.data.goodsInfo.ID)
            self.data.goodsInfo.StarLevel = fragToEquipConfig.starLevel
        else
            self.data.goodsInfo.StarLevel = 0
        end
    end

    self.controls.bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setScale9Enabled(true)
    if self.data.goodsType ~= SKILLTYPE then
        local size = nil
        local configInfo = nil
        if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == SOULTYPE) then
            configInfo = BaseConfig.GetHero(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
            local row, desc = Common.StringLinefeed(configInfo.desc, 13)
            size = cc.size(350, 140 + row * 20)
            self.controls.bg:setContentSize(size)

            if self.data.goodsType == HEROTYPE then
                self.controls.starLabel = cc.LabelAtlas:_create(starNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
                self.controls.starLabel:setScale(0.7)
                self.controls.starLabel:setAnchorPoint(0, 0.5)
                self.controls.bg:addChild(self.controls.starLabel)

                self.controls.starAddSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
                self.controls.starAddSpri:setAnchorPoint(0, 0.5)
                self.controls.bg:addChild(self.controls.starAddSpri)

                self.controls.starAttrLabel = cc.LabelAtlas:_create(starNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
                self.controls.starAttrLabel:setScale(0.7)
                self.controls.starAttrLabel:setAnchorPoint(0, 0.5)
                self.controls.bg:addChild(self.controls.starAttrLabel)

                self.controls.starSpri = cc.Sprite:create("image/ui/img/btn/btn_638.png")
                self.controls.starSpri:setAnchorPoint(0, 0.5)
                self.controls.bg:addChild(self.controls.starSpri)
            elseif self.data.goodsType == SOULTYPE then
                self.controls.soulLabel = ColorLabel.new("", 18)
                self.controls.bg:addChild(self.controls.soulLabel)
            end

            self.controls.wx = ColorLabel.new("", 18)
            self.controls.wx:setAnchorPoint(0.5, 1)
            self.controls.bg:addChild(self.controls.wx)

            self.controls.type = ColorLabel.new("", 18)
            self.controls.type:setAnchorPoint(0.5, 1)
            self.controls.bg:addChild(self.controls.type)

            self.controls.arm = ColorLabel.new("", 18)
            self.controls.arm:setAnchorPoint(0.5, 1)
            self.controls.bg:addChild(self.controls.arm)

            self.controls.desc = Common.finalFont("", 1, 1, 18, nil, 1)
            self.controls.desc:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            self.controls.desc:setAnchorPoint(0, 1)
            self.controls.bg:addChild(self.controls.desc)
        elseif self.data.goodsType == EQUIPTYPE then
            configInfo = BaseConfig.GetEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
            -- 获取专属武器描述所占的行数
            local herolist = configInfo.heroList
            local desc = ""
            for k,v in pairs(herolist) do
                local heroName = BaseConfig.GetHero(v, 0).name
                if k == (#herolist) then
                    desc = desc..heroName.."的专属装备"
                else
                    desc = desc..heroName.."，"
                end
            end
            local row1, desc1 = Common.StringLinefeed(desc, 13)
            -- 获得额外属性集合
            local extraDesc = Common.getEquipExtraDesc(configInfo, self.data.goodsInfo.Level)
            size = cc.size(390, 140 + row1 * 20 + (#extraDesc) * 20)
            self.controls.bg:setContentSize(size)

            self.controls.starLabel = cc.LabelAtlas:_create(starNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
            self.controls.starLabel:setScale(0.7)
            self.controls.starLabel:setAnchorPoint(0, 0.5)
            self.controls.bg:addChild(self.controls.starLabel)

            self.controls.starSpri = cc.Sprite:create("image/ui/img/btn/btn_638.png")
            self.controls.starSpri:setScale(0.8)
            self.controls.starSpri:setAnchorPoint(0, 0.5)
            self.controls.bg:addChild(self.controls.starSpri)

            self.controls.starAddSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
            self.controls.starAddSpri:setAnchorPoint(0, 0.5)
            self.controls.bg:addChild(self.controls.starAddSpri)

            self.controls.starAttrLabel = cc.LabelAtlas:_create(starNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
            self.controls.starAttrLabel:setScale(0.7)
            self.controls.starAttrLabel:setAnchorPoint(0, 0.5)
            self.controls.bg:addChild(self.controls.starAttrLabel)

            self.controls.equipType = Common.finalFont("", size.width * 0.5, nil, 20, nil, 1)
            self.controls.bg:addChild(self.controls.equipType)

            self.controls.specialDesc = Common.finalFont(desc1, size.width * 0.5, nil, 18, nil, 1)
            self.controls.specialDesc:setAnchorPoint(0.5, 1)
            self.controls.specialDesc:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            self.controls.bg:addChild(self.controls.specialDesc)

            if configInfo.type < 5 then
                self.controls.talent = ColorLabel.new("", 18)
                self.controls.talent:setAnchorPoint(0.5, 1)
                self.controls.bg:addChild(self.controls.talent)

                self.controls.attribute = ColorLabel.new("", 18)
                self.controls.attribute:setAnchorPoint(0.5, 1)
                self.controls.bg:addChild(self.controls.attribute)
            else
                self.controls.talent = ColorLabel.new("", 18)
                self.controls.talent:setAnchorPoint(0.5, 1)
                self.controls.bg:addChild(self.controls.talent)
            end

            self.data.extraDescTab = {}
        elseif (self.data.goodsType == PROPSTYPE) or (self.data.goodsType == FRAGTYPE) then
            configInfo = BaseConfig.GetProps(self.data.goodsInfo.ID)
            local desc1Row, desc1 = Common.StringLinefeed(configInfo.desc, 13)
            local desc2Row, desc2 = Common.StringLinefeed(configInfo.desc2, 13)
            size = cc.size(350, 130 + desc1Row * 20)
            self.controls.bg:setContentSize(size)

            self.controls.desc1 = Common.finalFont(desc1, 1, 1, 18, nil, 1)
            self.controls.desc1:setAnchorPoint(0, 1)
            self.controls.desc1:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            self.controls.bg:addChild(self.controls.desc1)

            self.controls.desc2 = Common.finalFont(desc2, 1, 1, 18, cc.c3b(255, 220, 20), 1)
            self.controls.desc2:setAnchorPoint(0, 0.5)
            self.controls.desc2:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            self.controls.bg:addChild(self.controls.desc2)

            self.controls.price = Common.finalFont(configInfo.price, size.width * 0.9, 30, 18)
            self.controls.price:setAnchorPoint(1, 0.5)
            self.controls.bg:addChild(self.controls.price)

            self.controls.priceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
            self.controls.priceSpri:setAnchorPoint(1, 0.5)
            self.controls.bg:addChild(self.controls.priceSpri)
        end
        self.data.size = size
        self.data.goodsConfigInfo = configInfo

        self.controls.goodsItem = GoodsInfoNode.new(self.data.goodsType, self.data.goodsInfo, 3)
        self.controls.goodsItem:setPosition(self.data.size.width * 0.18, self.data.size.height - 50)
        self.controls.goodsItem:setTouchEnable(false)
        self.controls.bg:addChild(self.controls.goodsItem)

        self.controls.name = Common.finalFont(self.data.goodsConfigInfo.name, 1, 1, 22, nil, 1)
        self.controls.bg:addChild(self.controls.name)

        self.controls.ownNum = Common.finalFont("", 1, 1, 15, nil, 1)
        self.controls.ownNum:setAnchorPoint(1, 0.5)
        self.controls.bg:addChild(self.controls.ownNum)
    else
        -- 技能goodsInfo数据特殊处理包含字段{config, Level}
        local configInfo = self.data.goodsInfo.config
        local row1, desc1 = Common.StringLinefeed(configInfo.Desc, 18)
        local desc2Tab = configInfo.Desc2
        local row2 = #desc2Tab
        local size = cc.size(420, 200 + (row1 + row2) * 20)
        self.controls.bg:setContentSize(size)

        self.controls.goodsItem = createMixSprite("image/icon/border/border_star_3.png", nil, "image/icon/skill/"..configInfo.Res..".png")
        local skillBg = self.controls.goodsItem:getBg()
        skillBg:setScale(0.92)
        self.controls.goodsItem:setPosition(size.width * 0.18, size.height - 65)
        self.controls.goodsItem:setTouchEnable(false)
        self.controls.bg:addChild(self.controls.goodsItem)

        self.controls.name = Common.finalFont("", 1, 1, 20, cc.c3b(200, 200, 0), 1)
        self.controls.bg:addChild(self.controls.name)

        self.controls.Level = Common.finalFont("", 1, 1, 20, cc.c3b(200, 200, 0), 1)
        self.controls.bg:addChild(self.controls.Level)

        self.controls.desc1 = Common.finalFont(desc1, 1, 1, 18, nil, 1)
        self.controls.desc1:setAnchorPoint(0, 1)
        self.controls.desc1:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        self.controls.bg:addChild(self.controls.desc1)

        self.data.extraDescTab = {}
        
        self.data.size = size
        self.data.goodsConfigInfo = configInfo
    end
    self:show(node, goodsInfo)
    self:addChild(self.controls.bg)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            self:hide()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.bg)

    self.data.updateListener = application:addEventListener(AppEvent.UI.Tips.UpdateInfo, function(event)
        self:onEnter()
    end)
end

function CommonTips:onEnter()
    self:updateGoods()
end

function CommonTips:onCleanup()
    application:removeEventListener(self.data.updateListener)
end

function CommonTips:onExit()
    self:removeFromParent()
    self = nil
end

function CommonTips:show(node, goodsInfo, extraHeight)
    extraHeight = extraHeight or 0
    self:updateGoods(goodsInfo, extraHeight)
    self:setVisible(true)
    self:setWorldPos(node)

    self.controls.bg:stopAllActions()
    if self.data.goodsType ~= SKILLTYPE then
        self.controls.bg:setScaleY(0)
        self.controls.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.06, 1, 1.2), cc.ScaleTo:create(0.1, 1, 1)))
    else
        self.controls.bg:setScaleX(0)
        self.controls.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.1, 1), cc.ScaleTo:create(0.08, 1, 1)))
    end
end

function CommonTips:hide()
    if not tolua.isnull(self.controls.bg) then
        self.controls.bg:stopAllActions()
        if self.data.goodsType ~= SKILLTYPE then
            self.controls.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 1, 1.2), cc.ScaleTo:create(0.05, 1, 0), 
                cc.CallFunc:create(function()
                self:setVisible(false)
                self:onExit()
            end)))
        else
            self.controls.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 1.1, 1), cc.ScaleTo:create(0.05, 0, 1), 
                cc.CallFunc:create(function()
                self:setVisible(false)
                self:onExit()
            end)))
        end
    end
end

function CommonTips:setWorldPos(node)
    local worldPos = node:convertToWorldSpace(cc.p(0, 0))
    local size = self.controls.bg:getContentSize()
    local newPos = nil
    if self.data.goodsType ~= SKILLTYPE then
        local fixPos = {x = worldPos.x + self.data.size.width * 0.5, y = worldPos.y + self.data.size.height * 0.5}-- 保证背景图左下在worldPos点上
        newPos = fixPos
        -- 判断上右越屏情况
        if (worldPos.y + size.height) > SCREEN_HEIGHT then
            newPos.y = newPos.y - size.height
        end
        if (worldPos.x + size.width) > SCREEN_WIDTH then
            newPos.x = newPos.x - size.width 
        end
        self.controls.bg:setAnchorPoint(0.5, 0.5)
    else
        local nodeSize = node:getContentSize()
        local fixPos = {x = worldPos.x - nodeSize.width * 0.6, y = worldPos.y}-- 保证背景图在node左边
        newPos = fixPos
        -- 判断上下左越屏情况
        if (worldPos.y + size.height * 0.5) > SCREEN_HEIGHT then
            newPos.y = newPos.y - size.height * 0.5
        end
        if (worldPos.y - size.height * 0.5) < 0 then
            newPos.y = newPos.y + size.height * 0.5
        end
        self.controls.bg:setAnchorPoint(1, 0.5)
        if (worldPos.x - size.width) < 0 then
            newPos.x = newPos.x + nodeSize.width * 1.2
            self.controls.bg:setAnchorPoint(0, 0.5)
        end
    end
    self.controls.bg:setPosition(newPos.x, newPos.y)
end

function CommonTips:updateGoods(goodsInfo, extraHeight)
    extraHeight = extraHeight or 0
    if nil == goodsInfo then
        return
    end
    self.data.goodsInfo = goodsInfo or self.data.goodsInfo
    self.data.goodsInfo.Level = self.data.goodsInfo.Level or 1
    if not self.data.goodsInfo.StarLevel then
        if self.data.goodsType == EQUIPTYPE then
            local fragToEquipConfig = BaseConfig.GetFragToEquip(self.data.goodsInfo.ID)
            self.data.goodsInfo.StarLevel = fragToEquipConfig.starLevel
        else
            self.data.goodsInfo.StarLevel = 0
        end
    end

    if self.data.goodsType ~= SKILLTYPE then
        if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == SOULTYPE) then
            self:updateHero(extraHeight)
        elseif self.data.goodsType == EQUIPTYPE then
            self:updateEquip(extraHeight)
        elseif (self.data.goodsType == PROPSTYPE) or (self.data.goodsType == FRAGTYPE) then
            self:updateProps(extraHeight)
        end
        self.controls.goodsItem:setGoodsInfo(self.data.goodsInfo)
        self.controls.goodsItem:setPosition(self.data.size.width * 0.15, self.data.size.height - 60)
        self.controls.name:setString(self.data.goodsConfigInfo.name)
        self.controls.name:setPosition(self.data.size.width * 0.5, self.data.size.height - 50)

        if self.controls.ownNum then
            self:showOwnNum()
        end
    else
        self:updateSkill()
    end
end

function CommonTips:updateHero(extraHeight)
    local configInfo = BaseConfig.GetHero(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
    local starDta = Common.getHeroStarLevelColor(self.data.goodsInfo.StarLevel)
    self.controls.desc:setDimensions(0, 0)
    self.controls.desc:setString(configInfo.desc)
    local fontContentSize = self.controls.desc:getContentSize()
    local showFontWidth = self.data.size.width * 0.88
    local row = math.ceil(fontContentSize.width / showFontWidth)
    local size = cc.size(370, 180 + row * 20 + extraHeight)
    self.controls.bg:setContentSize(size)

    if self.data.goodsType == HEROTYPE then
        self.controls.starLabel:setString(starDta.StarNum)
        self.controls.starLabel:setPosition(size.width * 0.72, size.height - 50)
        self.controls.starSpri:setPosition(self.controls.starLabel:getPositionX() + self.controls.starLabel:getContentSize().width * 0.5, size.height - 50)
    
        if "" ~= starDta.Additional then
            self.controls.starAddSpri:setVisible(true)
            self.controls.starAttrLabel:setVisible(true)
            local additional = string.sub(starDta.Additional, 2, 2)
            self.controls.starAddSpri:setPosition(self.controls.starSpri:getPositionX() + self.controls.starSpri:getContentSize().width * 0.7, size.height - 60)
            self.controls.starAttrLabel:setString(additional)
            self.controls.starAttrLabel:setPosition(self.controls.starSpri:getPositionX() + self.controls.starSpri:getContentSize().width * 1.1, size.height - 60)
        else
            self.controls.starAddSpri:setVisible(false)
            self.controls.starAttrLabel:setVisible(false)
        end
    elseif self.data.goodsType == SOULTYPE then
        local heroStarLevel = BaseConfig.GetSoul(self.data.goodsInfo.ID).starLevel
        starDta = Common.getHeroStarLevelColor(heroStarLevel)

        local ownNum = 0
        local goodsInfo = GameCache.GetSoul(self.data.goodsInfo.ID)
        if goodsInfo then
            ownNum = goodsInfo.Num
        end
        local soulConfig = BaseConfig.GetSoul(self.data.goodsInfo.ID)
        local needNum = BaseConfig.GetHeroNeedSoulCount(soulConfig.starLevel)
        local ownColor = "[255,255,255]"
        if ownNum < needNum then
            ownColor = "[255,0,0]"
        end
        self.controls.soulLabel:setString("[255,255,255]魂魄([=]"..ownColor..ownNum.."[=][255,255,255]/"..needNum..")[=]")
        self.controls.soulLabel:setPosition(size.width * 0.5, size.height - 75)
    end

    local colorTab = {"[255,206,0]", "[9,255,15]", "[22,170,255]", "[255,0,0]", "[206,190,180]"}
    self.controls.wx:setString("[255,255,255]五行:[=]"..colorTab[configInfo.wx]..BaseConfig.WX_NAME[configInfo.wx].."[=]")
    self.controls.wx:setPosition(size.width * 0.5, 
                                    size.height - 60 - self.controls.goodsItem:getContentSize().height * 0.6)

    local intervalHeight = 25
    local wxPosX, wxPosY = self.controls.wx:getPosition()
    local value = BaseConfig.BATTLE_TYPE_NAME[(configInfo.atkSkill - 1000)]
    self.controls.type:setString("[255,255,255]类型:[=]".."[240,230,155]"..value.."[=]")
    self.controls.type:setPosition(size.width * 0.3, wxPosY - intervalHeight)

    local talentPosX, talentPosY = size.width * 0.7,
                                    size.height - 60 - self.controls.goodsItem:getContentSize().height * 0.6
    self.controls.arm:setString("[255,255,255]武器:[=]".."[240,230,155]"..BaseConfig.ARM_TYPE_NAME[configInfo.armType].."[=]")
    self.controls.arm:setPosition(talentPosX, talentPosY - intervalHeight)

    self.controls.desc:setDimensions(showFontWidth, fontContentSize.height * row)
    self.controls.desc:setPosition(size.width * 0.08, talentPosY - intervalHeight * 2.2)

    self.controls.name:setColor(starDta.Color)

    self.data.size = size
    self.data.goodsConfigInfo = configInfo
end

function CommonTips:updateEquip(extraHeight)
    local configInfo = BaseConfig.GetEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
    local starDta = Common.getHeroStarLevelColor(self.data.goodsInfo.StarLevel)
    local herolist = configInfo.heroList
    local desc = ""
    for k,v in pairs(herolist) do
        local heroName = BaseConfig.GetHero(v, 0).name
        if k == (#herolist) then
            desc = desc..heroName.."的专属装备"
        else
            desc = desc..heroName.."，"
        end
    end
    local row1, desc1 = Common.StringLinefeed(desc, 14)
    -- 获得额外属性集合
    local extraDesc = Common.getEquipExtraDesc(configInfo, self.data.goodsInfo.Level)
    local row2 = #extraDesc
    local fontHeight = 25
    local size = cc.size(400, 170 + (row1 + row2) * fontHeight + extraHeight)
    self.controls.bg:setContentSize(size)

    self.controls.starLabel:setString(starDta.StarNum)
    self.controls.starLabel:setPosition(size.width * 0.7, size.height - 60)

    self.controls.starSpri:setPosition(self.controls.starLabel:getPositionX() + self.controls.starLabel:getContentSize().width * 0.5, size.height - 60)
    
    if "" ~= starDta.Additional then
        self.controls.starAddSpri:setVisible(true)
        self.controls.starAttrLabel:setVisible(true)
        local additional = string.sub(starDta.Additional, 2, 2)
        self.controls.starAddSpri:setPosition(self.controls.starSpri:getPositionX() + self.controls.starSpri:getContentSize().width * 0.7, size.height - 60)
        self.controls.starAttrLabel:setString(additional)
        self.controls.starAttrLabel:setPosition(self.controls.starSpri:getPositionX() + self.controls.starSpri:getContentSize().width * 1.1, size.height - 60)
    else
        self.controls.starAddSpri:setVisible(false)
        self.controls.starAttrLabel:setVisible(false)
    end

    self.controls.equipType:setString("("..BaseConfig.EQUIP_TYPE_NAME[configInfo.type]..")")
    self.controls.equipType:setPositionY(size.height - 75)  
    self.controls.specialDesc:setString(desc1)
    self.controls.specialDesc:setPositionY(size.height - 60 - self.controls.goodsItem:getContentSize().height * 0.6)

    if configInfo.type < 5 then
        self.controls.talent:setString("[255,255,255]资质[=]".."[255,220,20]"..configInfo.talent.."[=]")
        self.controls.talent:setPosition(size.width * 0.3, self.controls.specialDesc:getPositionY() - row1 * fontHeight)
        if self.controls.attribute then
            self.controls.attribute:setVisible(true)
        else
            self.controls.attribute = Common.finalFont("", nil, nil, 18, nil, 1)
            self.controls.attribute:setAnchorPoint(0.5, 1)
            self.controls.bg:addChild(self.controls.attribute)
        end
        self.controls.attribute:setString(self:getAttribute(configInfo, self.data.goodsInfo.Level))
        self.controls.attribute:setPosition(size.width * 0.65, self.controls.specialDesc:getPositionY() - row1 * fontHeight)
    else
        self.controls.talent:setString("[255,255,255]资质[=]".."[255,220,20]"..configInfo.talent.."[=]")
        self.controls.talent:setPosition(size.width * 0.5, 
                                        size.height - 60 - self.controls.goodsItem:getContentSize().height * 0.6)
         if self.controls.attribute then
            self.controls.attribute:setVisible(false)
        end
    end
    
    for k,v in pairs(self.data.extraDescTab) do
        v:removeFromParent()
        v = nil
    end
    self.data.extraDescTab = {}
    for k,v in pairs(extraDesc) do
        local desc = ColorLabel.new(v, 18)
        desc:setPosition(size.width * 0.5, self.controls.talent:getPositionY() - k * fontHeight)
        desc:setAnchorPoint(0.5, 1)
        self.controls.bg:addChild(desc)
        table.insert(self.data.extraDescTab, desc)
    end
    self.controls.name:setColor(starDta.Color)

    self.data.size = size
    self.data.goodsConfigInfo = configInfo
end

function CommonTips:updateProps(extraHeight)
    local configInfo = BaseConfig.GetProps(self.data.goodsInfo.ID)
    local desc1Row, desc1 = Common.StringLinefeed(configInfo.desc, 17)
    local desc2Row, desc2 = Common.StringLinefeed(configInfo.desc2, 17)
    local size = cc.size(400, 160 + desc1Row * 25 + extraHeight)
    self.controls.bg:setContentSize(size)
    local fontHeight = 30

    self.controls.desc1:setString(desc1)
    self.controls.desc1:setPosition(size.width * 0.08, size.height - 60 - self.controls.goodsItem:getContentSize().height * 0.6)
    self.controls.desc2:setString(desc2)
    self.controls.desc2:setPosition(size.width * 0.08, self.controls.desc1:getPositionY() - desc1Row * fontHeight - 10)
    self.controls.price:setString(configInfo.price)
    self.controls.price:setPosition(size.width * 0.92, self.controls.desc1:getPositionY() - desc1Row * fontHeight - 10)
    self.controls.priceSpri:setPosition(self.controls.price:getPositionX() - self.controls.price:getContentSize().width, 
                                    self.controls.desc1:getPositionY() - desc1Row * fontHeight - 10)
    local nameColorTab = {cc.c3b(217,217,217), cc.c3b(0,255,50), cc.c3b(0,162,255), 
                    cc.c3b(255,0,200), cc.c3b(255,0,0), cc.c3b(255,102,0)} -- 灰、绿、蓝、紫、红、橙
    local colorNum = configInfo.quality
    self.controls.name:setColor(nameColorTab[colorNum])

    self.data.size = size
    self.data.goodsConfigInfo = configInfo
end

function CommonTips:updateSkill()
    local configInfo = self.data.goodsInfo.config
    self.controls.desc1:setDimensions(0, 0)
    self.controls.desc1:setString(configInfo.Desc)
    local fontContentSize = self.controls.desc1:getContentSize()
    local showFontWidth = self.data.size.width * 0.92
    local row1 = math.ceil(fontContentSize.width / showFontWidth)

    local desc2Tab = configInfo.Desc2
    local row2 = #desc2Tab
    local size = cc.size(450, 180 + (row1 + row2) * 20)
    self.controls.bg:setContentSize(size)

    self.controls.goodsItem:setChildTexture("image/icon/skill/"..configInfo.Res..".png")
    self.controls.goodsItem:setPosition(size.width * 0.18, size.height - 75)

    self.controls.name:setString("【"..configInfo.name.."】")
    self.controls.name:setPosition(size.width * 0.5, size.height - 70)

    self.controls.Level:setString("LV."..self.data.goodsInfo.Level)
    self.controls.Level:setPosition(size.width * 0.8, size.height - 70)

    self.controls.desc1:setDimensions(showFontWidth, fontContentSize.height * row1)
    self.controls.desc1:setPosition(size.width * 0.06, size.height - 60 - self.controls.goodsItem:getContentSize().height * 0.6)

    for k,v in pairs(self.data.extraDescTab) do
        v:removeFromParent()
        v = nil
    end
    self.data.extraDescTab = {}
    for k,v in pairs(desc2Tab) do
        local desc = Common.finalFont(v, size.width * 0.06, 
                                    self.controls.desc1:getPositionY() + 10 - (row1 + k) * 20, 18, cc.c3b(255, 126, 56), 1)
        desc:setAnchorPoint(0, 1)
        self.controls.bg:addChild(desc)
        table.insert(self.data.extraDescTab, desc)
    end

    self.data.size = size
    self.data.goodsConfigInfo = configInfo
end

function CommonTips:getAttribute(config, level)
    local attribute = nil
    if config.type == 1 then
        local lastAtk = config.atk + math.floor(((level - 1) * config.atkGrow)/10000)
        attribute = "[255,255,255]攻击[=]".."[255,220,20]"..lastAtk.."[=]"
    elseif config.type == 2 then
        local lastDef = config.def + math.floor(((level - 1) * config.defGrow)/10000)
        attribute = "[255,255,255]防御[=]".."[255,220,20]"..lastDef.."[=]"
    elseif config.type == 3 then
        local lastMp = config.mp + math.floor(((level - 1) * config.mpGrow)/10000)
        attribute = "[255,255,255]法力[=]".."[255,220,20]"..lastMp.."[=]"
    elseif config.type == 4 then
        local lastHp = config.hp + math.floor(((level - 1) * config.hpGrow)/10000)
        attribute = "[255,255,255]生命[=]".."[255,220,20]"..lastHp.."[=]"
    end
    return attribute
end

function CommonTips:showOwnNum()
    local goodsType = self.data.goodsInfo.Type
    local ownNum = 0
    local isShow = false
    if goodsType == 2 then
        local goodsInfo = GameCache.GetSoul(self.data.goodsInfo.ID)
        if goodsInfo then
            ownNum = goodsInfo.Num
        end
        isShow = true
    elseif goodsType == 5 then
        local goodsInfo = GameCache.GetEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
        if goodsInfo then
            ownNum = goodsInfo.Num
        end
        isShow = true
    elseif goodsType == 6 then
        local propsConfigInfo = BaseConfig.GetProps(self.data.goodsInfo.ID)
        if (propsConfigInfo.type == 1) or (propsConfigInfo.type == 4) then
            local goodsInfo = GameCache.GetFrag(self.data.goodsInfo.ID)
            if goodsInfo then
                ownNum = goodsInfo.Num
            end
        elseif (propsConfigInfo.type ~= 2) then
            local goodsInfo = GameCache.GetProps(self.data.goodsInfo.ID)
            if goodsInfo then
                ownNum = goodsInfo.Num
            end
        end
        isShow = true
    end
    
    if isShow then
        self.controls.ownNum:setVisible(true)
        self.controls.ownNum:setString("(拥有"..Common.numConvert(ownNum)..")")
        self.controls.ownNum:setPosition(self.data.size.width * 0.96, self.data.size.height - 35)
    else
        self.controls.ownNum:setVisible(false)
    end
end

return CommonTips

