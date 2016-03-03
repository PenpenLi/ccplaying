local HeroPanel = class("HeroPanel", function()
    local node = cc.Node:create()
    node.data = {}
    node.controls = {}
    return node
end)
local effects = require("tool.helper.Effects")

local ZORDER = 1

local appointHeroID = 1027

function HeroPanel:ctor(info, isOwn)
    self.data.heroInfo = info
    self.data.isOwn = isOwn
    self.data.heroConfigInfo = BaseConfig.GetHero(self.data.heroInfo.ID, 0)

    self:createUI()
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

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            if GameCache.NewbieGuide.State then
                if GameCache.OpenSystem.State and self.func then
                    self.func(self)
                elseif (self.data.heroInfo.ID == appointHeroID) and self.func then
                    self.func(self)
                end
            else
                if self.func then
                    self.func(self)
                end
            end
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.controls.bg)
end

function HeroPanel:createUI()
    local size = cc.size(374, 122)
    self.size = size
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_144.png")
    self.controls.bg:setContentSize(size)
    self:addChild(self.controls.bg)

    self.controls.headBorder = GoodsInfoNode.new(BaseConfig.GOODS_HERO, self.data.heroInfo)
    self.controls.headBorder:setTouchEnable(false)
    self.controls.headBorder:setPosition(-size.width * 0.5 + self.controls.headBorder:getContentSize().width * 0.5 + 8, 0)
    self:addChild(self.controls.headBorder)
    self.controls.headBorder:setWx()

    if self.data.isOwn then
        self.controls.headBorder:setLevel("center")
        local starData = Common.getHeroStarLevelColor(self.data.heroInfo.StarLevel)

        self.controls.name = Common.finalFont(starData.Additional..self.data.heroConfigInfo.name, 1, 1, 25, cc.c3b(9, 51, 98))
        self.controls.name:setPosition(-size.width * 0.15, size.height * 0.18)
        self.controls.name:setAdditionalKerning(-2)
        self.controls.name:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.name)
        
        self.controls.starLevel = cc.LabelAtlas:_create("1", "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
        self.controls.starLevel:setAnchorPoint(1, 0.5)
        self.controls.starLevel:setPosition(size.width * 0.33, size.height * 0.18)
        self:addChild(self.controls.starLevel)
        self.controls.starLevel:setString(starData.StarNum)

        self.controls.alert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
        self.controls.alert:setPosition(size.width * 0.48, size.height * 0.2)
        self:addChild(self.controls.alert)
        self.controls.alert:setVisible(false)
        self:playAlertAction()

        local controls_talent = Common.finalFont("类型", 1, 1, 20, cc.c3b(70, 106, 166))
        controls_talent:setPosition(-size.width * 0.15, -size.height * 0.2)
        controls_talent:setAnchorPoint(0, 0.5)
        self:addChild(controls_talent)

        self.controls.talent = Common.finalFont(BaseConfig.BATTLE_TYPE_NAME[(self.data.heroConfigInfo.atkSkill - 1000)], 1, 1, 20, cc.c3b(243, 118, 54))
        self.controls.talent:setPosition(-size.width * 0.02, -size.height * 0.2)
        self.controls.talent:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.talent)

        local controls_tfp = Common.finalFont("战力", 1, 1, 20, cc.c3b(70, 106, 166))
        controls_tfp:setPosition(size.width * 0.14, -size.height * 0.2)
        controls_tfp:setAnchorPoint(0, 0.5)
        self:addChild(controls_tfp)

        self.controls.tfp = Common.finalFont(self.data.heroInfo.TFP, 1, 1, 20, cc.c3b(243, 118, 54))
        self.controls.tfp:setPosition(size.width * 0.35, -size.height * 0.2)
        self:addChild(self.controls.tfp)
    else
        self.controls.name = Common.finalFont(self.data.heroConfigInfo.name, 1, 1, 25, cc.c3b(9, 51, 98))
        self.controls.name:setPosition(-size.width * 0.15, size.height * 0.18)
        self.controls.name:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.name)

        self.controls.btn_add = cc.Sprite:create("image/ui/img/btn/btn_582.png")
        self.controls.btn_add:setPosition(size.width * 0.4, size.height * 0.18)
        self:addChild(self.controls.btn_add)

        local controls_bar_bg = cc.Sprite:create("image/ui/img/btn/btn_400.png")
        controls_bar_bg:setScale(0.84)
        controls_bar_bg:setPosition(size.width * 0.04, -size.height * 0.2)
        self:addChild(controls_bar_bg)

        local needSoulNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(self.data.heroInfo.ID).starLevel)
        self.controls.collect_bar = ccui.LoadingBar:create()
        self.controls.collect_bar:loadTexture("image/ui/img/btn/btn_401.png")
        self.controls.collect_bar:setPosition(size.width * 0.04, -size.height * 0.2)
        local num = (self.data.heroInfo.Num / needSoulNum) * 100
        self.controls.collect_bar:setPercent(num)
        self:addChild(self.controls.collect_bar)

        self.controls.percentage = Common.finalFont(self.data.heroInfo.Num .. "/" .. needSoulNum, 1, 1, nil, cc.c3b(0, 0, 0))
        self.controls.percentage:setPosition(size.width * 0.34, -size.height * 0.2)
        self:addChild(self.controls.percentage)

        self.controls.canSummonHero = effects:CreateAnimation(self, 0, 0, nil, 14, true)
    end
end

function HeroPanel:updateHeroInfo(heroInfo)
    self.data.heroInfo = heroInfo
    self.data.heroConfigInfo = BaseConfig.GetHero(self.data.heroInfo.ID, 0)
    self.controls.headBorder:setGoodsInfo(self.data.heroInfo)
    self.controls.headBorder:setWx()
    if self.data.isOwn then
        self.controls.headBorder:setLevel("center", self.data.heroInfo.Level)
        local starData = Common.getHeroStarLevelColor(self.data.heroInfo.StarLevel)
        self.controls.name:setString(self.data.heroConfigInfo.name..starData.Additional)
        self.controls.starLevel:setString(starData.StarNum)
        self.controls.talent:setString(BaseConfig.BATTLE_TYPE_NAME[(self.data.heroConfigInfo.atkSkill - 1000)])
        self.controls.tfp:setString(self.data.heroInfo.TFP)
    else
        self.controls.name:setString(self.data.heroConfigInfo.name)
        local needSoulNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(self.data.heroInfo.ID).starLevel)
        local num = (self.data.heroInfo.Num / needSoulNum) * 100
        num = (num >= 100) and 100 or num
        self.controls.collect_bar:setPercent(num)
        self.controls.percentage:setString(self.data.heroInfo.Num .. "/" .. needSoulNum)
        if (self:isCanCompoundHero()) then
            self.controls.canSummonHero:setVisible(true)
        else
            self.controls.canSummonHero:setVisible(false)
        end
    end
end

function HeroPanel:playAction(time)
    self:setVisible(false)
    local delay = cc.DelayTime:create(time)
    local scale1 = cc.ScaleTo:create(1/60, 0)
    local scale2 = cc.ScaleTo:create(0.15, 1.3)
    local scale3 = cc.ScaleTo:create(0.08, 0.5)
    local scale4 = cc.ScaleTo:create(0.08, 1.1)
    local scale5 = cc.ScaleTo:create(0.04, 1)
    local callFunc = cc.CallFunc:create(function()
        self:setVisible(true)
    end)
    self:runAction(cc.Sequence:create(scale1, delay, callFunc, scale2, scale3, scale4, scale5))
end

function HeroPanel:playAlertAction()
    self.controls.alert:stopAllActions()
    self.controls.alert:setPosition(self.size.width * 0.48, self.size.height * 0.42)
    local move1 = cc.MoveBy:create(0.08, cc.p(-8, 10))
    local move2 = cc.MoveBy:create(0.08, cc.p(14, -18))
    local move3 = cc.MoveBy:create(0.1, cc.p(-10, 14))
    local move4 = cc.MoveBy:create(0.1, cc.p(6, -8))
    local move5 = cc.MoveBy:create(0.1, cc.p(-2, 2))
    local delay = cc.DelayTime:create(3)
    self.controls.alert:runAction(cc.RepeatForever:create(cc.Sequence:create(delay, move1, move2, move3, move4, move5)))
end

function HeroPanel:setLevel(level)
    self.controls.headBorder:setLevel("right", level)
end

function HeroPanel:setTFP(tfp)
    self.data.heroInfo.TFP = tfp or self.data.heroInfo.TFP
    self.controls.tfp:setString(self.data.heroInfo.TFP)
end

function HeroPanel:setBorderTexture(heroInfo)
    self.controls.headBorder:setGoodsInfo(heroInfo)
    local starData = Common.getHeroStarLevelColor(heroInfo.StarLevel)
    self.controls.name:setString(starData.Additional..self.data.heroConfigInfo.name)
    self.controls.starLevel:setString(starData.StarNum)
end

function HeroPanel:setCanUpgradeStar(value)
    self.controls.alert:setVisible(value)
    if value then
        self:playAlertAction()
    end
end

function HeroPanel:addTouchEventListener(event)
    self.func = event
end

function HeroPanel:getHeroInfo()
    return self.data.heroInfo
end

function HeroPanel:isCanCompoundHero()
    local needSoulNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(self.data.heroInfo.ID).starLevel)
    return (self.data.heroInfo.Num >= needSoulNum)
end

return HeroPanel

