local EnergyLayer = class("EnergyLayer", BaseLayer)
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

local bgZOrder = 2
local topZOrder = bgZOrder + 1

local ENERGYBALLNODETAG = 100
local ENERGYLIGHTTAG = ENERGYBALLNODETAG * 10
local ENERGYBALLTAG = ENERGYLIGHTTAG * 10
local ENERGYLOGOTAG = ENERGYBALLTAG * 10
local ENERGYBGTAG = ENERGYLOGOTAG * 10
local ENERGYVALUETAG = ENERGYBGTAG * 10

local ENERGY_PRICE = 10000
local ENERGY_MAXSTEP = 40

local CONDITIONDESCTAG = 1
local CONDITIONBARBGTAG = CONDITIONDESCTAG + 1
local CONDITIONBARTAG = CONDITIONBARBGTAG + 1
local CONDITIONVALUETAG = CONDITIONBARTAG + 1

local energyPosTabs = nil
-- local attrDescTab = {"攻击", "防御", "生命", "法力", "精准", "闪避", "暴击", "韧性", "体力上限", "耐力上限"}
local attrDescTab = {"攻击", "防御", "生命", "法力", "精准", "闪避", "暴击", "韧性", "体力上限", "耐力上限", "天赋技能等级", "普通技能等级", "怒气技能等级", "被治疗效果"}

-- 以下条件类型需特殊处理
local SIMPLEMAPTYPE = 2
local DIFFICULTYMAPTYPE = 3
local WEAREQUIPTYPE = 21

function EnergyLayer:ctor(upgradeInfo)
    self.data.upgradeConditionInfo = upgradeInfo
    self.data.costScore = 50
    self.data.addAttrLabTab = {} -- 增加的属性描述
    self.data.lightPointTab = {} -- 人身上的发光点
    self.data.lightLineTab = {} -- 连接发光点的线段
    self.data.isShowAddAttrAction = false 
    self.data.isCanUpgrade = true -- 是否可以升学
    self.data.isCanClick = true

    self:createUI()
    self:updateUpgradeCondition()
    self:updateEnergyBall()

end

function EnergyLayer:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(cc.size(925, 536))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    local fringe = cc.Sprite:create("image/ui/img/bg/bg_133.png")
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height)
    self.controls.bg:addChild(fringe, bgZOrder)

    local heartBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_131.png")
    local heartSize = cc.size(624, 495)
    heartBg:setContentSize(heartSize)
    heartBg:setAnchorPoint(0, 0.5)
    heartBg:setPosition(self.data.bgSize.width * 0.016, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(heartBg, bgZOrder)

    local attrPanel = cc.Sprite:create("image/ui/img/bg/bg_132.png")
    attrPanel:setAnchorPoint(0, 0.5)
    attrPanel:setPosition(self.data.bgSize.width * 0.68, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(attrPanel, bgZOrder)

    local attrSize = attrPanel:getContentSize()
    local attrtishi = cc.Sprite:create("image/ui/img/btn/btn_556.png")
    attrtishi:setPosition(attrSize.width * 0.5, attrSize.height * 0.9)
    attrPanel:addChild(attrtishi)
    local addName = Common.finalFont("全局加成" , 1, 1, 25, nil, 1)
    addName:setPosition(attrSize.width * 0.5, attrSize.height * 0.9)
    attrPanel:addChild(addName)

    -- for i=1,10 do
    --     self.data.addAttrLabTab[i] = Common.finalFont(i, 1, 1, 25, cc.c3b(54, 87, 154))
    --     self.data.addAttrLabTab[i]:setAnchorPoint(0, 0.5)
    --     self.data.addAttrLabTab[i]:setPosition(attrSize.width * 0.26, attrSize.height * 0.8 - (attrSize.height * 0.073 * (i - 1)))
    --     attrPanel:addChild(self.data.addAttrLabTab[i])
    -- end

    local function lightFade()
        local lightBg1 = cc.Sprite:create("image/ui/img/bg/bg_134.png")
        lightBg1:setPosition(self.data.bgSize.width * 0.353, self.data.bgSize.height * 0.615)
        self.controls.bg:addChild(lightBg1, bgZOrder)
        local playTime = 2
        local delay = cc.DelayTime:create(playTime)
        local halfDelay = cc.DelayTime:create(playTime / 2)
        local fadeout = cc.FadeOut:create(playTime)
        local fadeIn = cc.FadeIn:create(playTime)
        lightBg1:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeout:clone(), delay:clone(), fadeIn, delay:clone())))

        local lightBg2 = cc.Sprite:create("image/ui/img/bg/bg_135.png")
        lightBg2:setOpacity(0)
        lightBg2:setPosition(self.data.bgSize.width * 0.353, self.data.bgSize.height * 0.615)
        self.controls.bg:addChild(lightBg2, bgZOrder)
        lightBg2:runAction(cc.RepeatForever:create(cc.Sequence:create(halfDelay:clone(), fadeIn:clone(), fadeout:clone(), halfDelay:clone(), delay:clone())))

        local lightBg3 = cc.Sprite:create("image/ui/img/bg/bg_136.png")
        lightBg3:setOpacity(0)
        lightBg3:setPosition(self.data.bgSize.width * 0.353, self.data.bgSize.height * 0.615)
        self.controls.bg:addChild(lightBg3, bgZOrder)
        lightBg3:runAction(cc.RepeatForever:create(cc.Sequence:create(halfDelay:clone(), delay:clone(), halfDelay:clone(), fadeIn:clone(), fadeout:clone())))
    end
    lightFade()
    
    local floor = cc.Sprite:create("image/ui/img/btn/btn_558.png")
    floor:setPosition(self.data.bgSize.width * 0.355, self.data.bgSize.height * 0.35)
    self.controls.bg:addChild(floor, bgZOrder)

    self.controls.people = cc.Sprite:create("image/ui/img/btn/btn_557.png")
    self.controls.people:setPosition(self.data.bgSize.width * 0.355, self.data.bgSize.height * 0.58)
    self.controls.bg:addChild(self.controls.people, bgZOrder)

    for i=1,6 do
        self.data.lightPointTab[i] = cc.Sprite:create("image/ui/img/btn/btn_549.png")
        self.data.lightPointTab[i]:setPosition(100, 100)
        self.controls.people:addChild(self.data.lightPointTab[i])
        self.data.lightPointTab[i]:setVisible(false)

        self.data.lightLineTab[i] = cc.Scale9Sprite:create("image/ui/img/btn/btn_550.png")
        self.data.lightLineTab[i]:setAnchorPoint(0.5, 0)
        self.controls.people:addChild(self.data.lightLineTab[i])
        self.data.lightLineTab[i]:setVisible(false)
    end

    local nameTiao = cc.Sprite:create("image/ui/img/btn/btn_588.png")
    nameTiao:setPosition(self.data.bgSize.width * 0.355, self.data.bgSize.height * 0.4)
    self.controls.bg:addChild(nameTiao, bgZOrder)    
    self.controls.stepName = Common.finalFont("" , 1, 1, 25, cc.c3b(255, 126, 56), 1)
    self.controls.stepName:setPosition(self.data.bgSize.width * 0.355, self.data.bgSize.height * 0.4)
    self.controls.bg:addChild(self.controls.stepName, bgZOrder)

    local bottomPanel = cc.Sprite:create("image/ui/img/btn/btn_554.png")
    bottomPanel:setPosition(self.data.bgSize.width * 0.25, self.data.bgSize.height * 0.125)
    self.controls.bg:addChild(bottomPanel, bgZOrder)
    local bottomSize = bottomPanel:getContentSize()
    local tishi = Common.finalFont("冒险剧场积分:" , 1, 1, 25, nil, 1)
    tishi:setPosition(bottomSize.width * 0.28, bottomSize.height * 0.5)
    bottomPanel:addChild(tishi)
    self.controls.instanceScore = Common.finalFont(Common.numConvert(GameCache.Avatar.InstanceScore), 1, 1, 22, cc.c3b(255, 220, 20), 1)
    self.controls.instanceScore:setPosition(bottomSize.width * 0.68, bottomSize.height * 0.5)
    bottomPanel:addChild(self.controls.instanceScore)
    self.controls.costScore = ColorLabel.new("[255,255,255]修炼1次消耗[=][255,220,20]50[=][255,255,255]积分[=]", 20, nil, false)
    self.controls.costScore:setPosition(self.data.bgSize.width * 0.55, self.data.bgSize.height * 0.2)
    self.controls.bg:addChild(self.controls.costScore, bgZOrder)
    local btn_add = createMixSprite("image/ui/img/bg/add.png")
    btn_add:setPosition(bottomSize.width * 0.95, bottomSize.height * 0.5)
    bottomPanel:addChild(btn_add)
    btn_add:addTouchEventListener(function(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            -- application:popScene()
            application:replaceScene("main.mapinstance.MapInstanceScene")
        end
    end)

    self.controls.btn_upgrade = createMixSprite("image/ui/img/btn/btn_553.png")
    self.controls.btn_upgrade:setCircleFont("好好学习", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.controls.btn_upgrade:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    self.controls.btn_upgrade:setPosition(self.data.bgSize.width * 0.55, self.data.bgSize.height * 0.125)
    self.controls.bg:addChild(self.controls.btn_upgrade, bgZOrder)
    self.controls.btn_upgrade:addTouchEventListener(function (sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside and (self.data.isCanClick) then
            if GameCache.Avatar.EnergyAttrNum == 6 then
                if GameCache.Avatar.EnergyStep == ENERGY_MAXSTEP then
                    application:showFlashNotice("已达到顶级")
                    return 
                end

                if GameCache.Avatar.Coin >= ENERGY_PRICE then
                    self:UpgradeEnergy()
                else
                    application:showFlashNotice("银币不足")
                end
            else
                if GameCache.Avatar.InstanceScore >= self.data.costScore then
                    self:UpgradeEnergy()
                else
                    application:showFlashNotice("积分不足")
                end
            end
        end
    end)

    local currPageName = createMixSprite("image/ui/img/bg/bg_142.png", nil, "image/ui/img/btn/btn_559.png")
    currPageName:setTouchEnable(false)
    currPageName:setChildPos(0.52, 0.55)
    currPageName:setPosition(self.data.bgSize.width * 0.1, self.data.bgSize.height)
    self.controls.bg:addChild(currPageName, bgZOrder)

    local btn_close = ccui.Button:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.98)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
    self.controls.bg:addChild(btn_close, topZOrder)

    local function createEnergyBall()
        energyPosTabs = {{self.data.bgSize.width * 0.15, self.data.bgSize.height * 0.48},
                        {self.data.bgSize.width * 0.17, self.data.bgSize.height * 0.73},
                        {self.data.bgSize.width * 0.27, self.data.bgSize.height * 0.92},
                        {self.data.bgSize.width * 0.44, self.data.bgSize.height * 0.92},
                        {self.data.bgSize.width * 0.54, self.data.bgSize.height * 0.73},
                        {self.data.bgSize.width * 0.56, self.data.bgSize.height * 0.48},
                        }
        for k,v in pairs(energyPosTabs) do
            local energyConfig = BaseConfig.getEnergyInfo(k)

            local node = cc.Node:create()
            node:setTag(ENERGYBALLNODETAG + k)
            node:setPosition(v[1], v[2])
            self.controls.bg:addChild(node, topZOrder)
            local energyLight = effects:CreateAnimation(node, 0, 0, nil, 25, true)
            energyLight:setScale(0.8)
            energyLight:setTag(ENERGYLIGHTTAG + k) 
            energyLight:setVisible(false)
            local energyBall = cc.Sprite:create("image/ui/img/btn/btn_548.png")
            energyBall:setTag(ENERGYBALLTAG + k) 
            node:addChild(energyBall)
            local energyLogo = cc.Sprite:create(self:getAttrSpriPath(false, energyConfig.PropertyType))
            energyLogo:setTag(ENERGYLOGOTAG + k)
            node:addChild(energyLogo)
            local tiao1 = cc.Sprite:create("image/ui/img/btn/btn_588.png")
            tiao1:setTag(ENERGYBGTAG + k) 
            tiao1:setPosition(v[1], v[2] - energyBall:getContentSize().height * 0.75)
            self.controls.bg:addChild(tiao1, topZOrder)
            local addEnergyValue = ColorLabel.new("[255,255,255]".."攻击".."[=][0,255,0]".."+5".."[=]", 20, nil, false)
            addEnergyValue:setPosition(v[1], v[2] - energyBall:getContentSize().height * 0.75)
            addEnergyValue:setTag(ENERGYVALUETAG + k)
            self.controls.bg:addChild(addEnergyValue, topZOrder)
        end
    end
    createEnergyBall()

    self:rightAttrUI()
end

function EnergyLayer:rightAttrUI()
    local attrPanel = cc.Sprite:create("image/ui/img/bg/bg_132.png")
    attrPanel:setAnchorPoint(0, 0.5)
    attrPanel:setPosition(self.data.bgSize.width * 0.68, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(attrPanel, bgZOrder)
    local attrSize = attrPanel:getContentSize()

    local circlePointSpriTab = {}
    for i=1,2 do
        local circlePoint = createMixSprite("image/ui/img/btn/btn_097.png", "image/ui/img/btn/btn_096.png")
        circlePoint:setPosition(attrSize.width * 0.45 + (i - 1) * 30, attrSize.height * 0.06)
        circlePoint:setTouchEnable(false)
        attrPanel:addChild(circlePoint)
        table.insert(circlePointSpriTab, circlePoint)
        if i == 1 then
            circlePoint:setTouchStatus()
        end
    end

    local viewSize = cc.size(attrSize.width * 0.9, attrSize.height)
    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setSize(viewSize)
    pageView:setPosition(14, 0)
    attrPanel:addChild(pageView)
    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageIdx = sender:getCurPageIndex()
            for k,spri in pairs(circlePointSpriTab) do
                if (k == (pageIdx + 1)) then
                    spri:setTouchStatus()
                else
                    spri:setNormalStatus()
                end
            end
        end
    end 
    pageView:addEventListenerPageView(pageViewEvent)
    for i = 1, 2 do
        local layout = ccui.Layout:create()
        layout:setSize(viewSize)

        local imageView = ccui.ImageView:create()
        imageView:setScale9Enabled(true)
        imageView:loadTexture("image/ui/img/bg/bg_132.png")
        imageView:setSize(viewSize)
        imageView:setPosition(viewSize.width * 0.5, viewSize.height * 0.5)
        layout:addChild(imageView)
        imageView:setOpacity(0)
        pageView:addPage(layout)

        if i == 1 then
            layout:addChild(self:rightFirstPanel(viewSize))
        elseif i == 2 then
            layout:addChild(self:rightSecondPanel(viewSize))
        end
    end

    self.data.rightPanelSize = viewSize
end

function EnergyLayer:rightFirstPanel(panelSize)
    local node = cc.Node:create()
    local title = createMixSprite("image/ui/img/btn/btn_781.png")
    title:setTouchEnable(false)
    title:setCircleFont("升学条件", 1, 1, 20, cc.c3b(191,233,249))
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.93)
    node:addChild(title)
    title:getBg():setScaleX(0.65)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(panelSize.width * 0.15, panelSize.height * 0.93)
    node:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(panelSize.width * 0.85, panelSize.height * 0.93)
    node:addChild(line)

    title = createMixSprite("image/ui/img/btn/btn_781.png")
    title:setTouchEnable(false)
    title:setCircleFont("升学奖励", 1, 1, 20, cc.c3b(191,233,249))
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.36)
    node:addChild(title)
    title:getBg():setScaleX(0.65)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(panelSize.width * 0.15, panelSize.height * 0.36)
    node:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(panelSize.width * 0.85, panelSize.height * 0.36)
    node:addChild(line)

    self.data.upgradeConditionNodeTab = {}
    for k = 1, 4 do
        local descNode = cc.Node:create()
        node:addChild(descNode)
        self.data.upgradeConditionNodeTab[k] = descNode

        local desc = Common.finalFont("", 1, 1, 18, cc.c3b(23, 56, 76))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(panelSize.width * 0.08, panelSize.height - 70 - (k - 1) * 60)
        descNode:addChild(desc)
        desc:setTag(CONDITIONDESCTAG)

        local barWidth = 176
        local bar_bg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1378.png")
        bar_bg:setContentSize(cc.size(barWidth, 25))
        bar_bg:setAnchorPoint(0, 0.5)
        bar_bg:setPosition(panelSize.width * 0.17, panelSize.height - 100 - (k - 1) * 60)
        descNode:addChild(bar_bg)
        bar_bg:setTag(CONDITIONBARBGTAG)

        local bar = cc.Scale9Sprite:create("image/ui/img/bg/line_04.png")
        bar:setContentSize(cc.size(barWidth, 23))
        bar:setAnchorPoint(0, 0.5)
        bar:setPosition(panelSize.width * 0.17, panelSize.height - 100 - (k - 1) * 60)
        descNode:addChild(bar)
        bar:setTag(CONDITIONBARTAG)

        local percentDesc = ColorLabel.new("", 15)
        percentDesc:setPosition(panelSize.width * 0.5, panelSize.height - 100 - (k - 1) * 60)
        descNode:addChild(percentDesc)
        percentDesc:setTag(CONDITIONVALUETAG)
    end

    self.data.upgradeAwardItemTab = {}

    self.controls.addAttrDesc = Common.finalFont("", 1, 1, 18, cc.c3b(255, 255, 0), 1)
    self.controls.addAttrDesc:setPosition(panelSize.width * 0.5, panelSize.height - 425)
    node:addChild(self.controls.addAttrDesc)

    self.controls.openDesc = Common.finalFont("", 1, 1, 18, cc.c3b(255, 255, 0), 1)
    self.controls.openDesc:setPosition(panelSize.width * 0.5, panelSize.height - 455)
    node:addChild(self.controls.openDesc)
    return node
end

function EnergyLayer:rightSecondPanel(panelSize)
    local node = cc.Node:create()

    local attrtishi = cc.Sprite:create("image/ui/img/btn/btn_556.png")
    attrtishi:setPosition(panelSize.width * 0.5, panelSize.height * 0.9)
    node:addChild(attrtishi)
    local addName = Common.finalFont("全局加成" , 1, 1, 20, nil, 1)
    addName:setPosition(panelSize.width * 0.5, panelSize.height * 0.9)
    node:addChild(addName)

    for i=1,#attrDescTab do
        self.data.addAttrLabTab[i] = Common.finalFont(attrDescTab[i], 1, 1, 18, cc.c3b(54, 87, 154))
        self.data.addAttrLabTab[i]:setAnchorPoint(0, 0.5)
        self.data.addAttrLabTab[i]:setPosition(panelSize.width * 0.2, panelSize.height - 100 - (i - 1) * 26)
        node:addChild(self.data.addAttrLabTab[i])

        local line = cc.Sprite:create("image/ui/img/btn/btn_1383.png")
        line:setPosition(panelSize.width * 0.5, panelSize.height - 112 - (i - 1) * 26)
        node:addChild(line)
        line:setScaleX(6.5)
    end
    
    return node
end

function EnergyLayer:updateUpgradeCondition()
    local upgradeConfig = BaseConfig.getEnergyUpgrade(GameCache.Avatar.EnergyStep)

    self.data.isCanUpgrade = true
    for k,conditionNode in pairs(self.data.upgradeConditionNodeTab) do
        local conditionDesc = conditionNode:getChildByTag(CONDITIONDESCTAG)
        local conditionBarBg = conditionNode:getChildByTag(CONDITIONBARBGTAG)
        local conditionBar = conditionNode:getChildByTag(CONDITIONBARTAG)
        local conditionValue = conditionNode:getChildByTag(CONDITIONVALUETAG)
        if k > (#self.data.upgradeConditionInfo) then
            conditionDesc:setVisible(false)
            conditionBarBg:setVisible(false)
            conditionBar:setVisible(false) 
            conditionValue:setVisible(false)
        else
            conditionDesc:setVisible(true)
            conditionBarBg:setVisible(true)
            conditionBar:setVisible(true) 
            conditionValue:setVisible(true)

            conditionDesc:setString(upgradeConfig.ConditionDesc[k])

            local ownNum = self.data.upgradeConditionInfo[k]
            local totalNum = upgradeConfig.Condition[k][(#upgradeConfig.Condition[k])]
            local conditionType = upgradeConfig.Condition[k][1]
            if (conditionType == SIMPLEMAPTYPE) or (conditionType == DIFFICULTYMAPTYPE) then
                if ownNum < totalNum then
                    ownNum = 0
                    totalNum = 1
                else
                    ownNum = 1
                    totalNum = 1
                end
            elseif conditionType == WEAREQUIPTYPE then
                totalNum = 1
            end
            local barWidth = 176
            local percent = ((ownNum / totalNum) > 1) and 1 or (ownNum / totalNum)
            if ownNum == 0 then
                conditionBar:setVisible(false)
            else
                conditionBar:setContentSize(cc.size(barWidth * percent, 23))
            end
            conditionValue:setString("[249,222,22]"..ownNum.."[=][255,255,255]/"..totalNum.."[=]")

            if self.data.isCanUpgrade then
                if percent < 1 then
                    self.data.isCanUpgrade = false
                end
            end
        end
    end

    if self.data.upgradeAwardItemTab then
        for k,item in pairs(self.data.upgradeAwardItemTab) do
            item:removeFromParent()
            item = nil
        end
    end
    self.data.upgradeAwardItemTab = {}

    -- 获取父节点layout
    local parent = self.controls.addAttrDesc:getParent()

    local itemWidth = 40
    local initWidth = self.data.rightPanelSize.width * 0.5 - itemWidth * (#upgradeConfig.Award - 1)
    for k,awardInfo in pairs(upgradeConfig.Award) do
        local goodsInfo = {}
        goodsInfo.ID = awardInfo.GoodsID
        goodsInfo.Type = awardInfo.GoodsType
        goodsInfo.Num = awardInfo.Num

        local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_SMALLTYPE)
        goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2, self.data.rightPanelSize.height - 375)
        parent:addChild(goodsItem)

        self.data.upgradeAwardItemTab[k] = goodsItem
    end

    local addAttrDesc = attrDescTab[upgradeConfig.PropertyType]
    local addAttrValue = "+"..upgradeConfig.PropertyValue
    self.controls.addAttrDesc:setString(addAttrDesc..addAttrValue)
    self.controls.openDesc:setString(upgradeConfig.OpenDesc)
end

function EnergyLayer:updateEnergyBall()
    for k,v in pairs(energyPosTabs) do
        local id = (GameCache.Avatar.EnergyStep - 1) * (#energyPosTabs) + k
        local energyConfig = BaseConfig.getEnergyInfo(id)
        local node = self.controls.bg:getChildByTag(ENERGYBALLNODETAG + k)
        node:stopAllActions()
        node:setPosition(v[1], v[2])
        local energyLight = node:getChildByTag(ENERGYLIGHTTAG + k)
        local energyBall = node:getChildByTag(ENERGYBALLTAG + k)
        local energyLogo = node:getChildByTag(ENERGYLOGOTAG + k)
        local addEnergyValueLabel = self.controls.bg:getChildByTag(ENERGYVALUETAG + k)
        local energyValue = self:getEnergyValue(energyConfig)
        
        local move = cc.MoveBy:create(1, cc.p(0, 8))
        local move_reverse = move:reverse()
        if k > GameCache.Avatar.EnergyAttrNum then
            energyLight:setVisible(false)
            energyBall:setTexture("image/ui/img/btn/btn_548.png")
            energyLogo:setTexture(self:getAttrSpriPath(false, energyConfig.PropertyType))
        else
            energyLight:setVisible(true)
            energyBall:setTexture("image/ui/img/btn/btn_551.png")
            energyLogo:setTexture(self:getAttrSpriPath(true, energyConfig.PropertyType))
            node:runAction(cc.RepeatForever:create(cc.Sequence:create(move:clone(), move_reverse:clone())))
        end

        addEnergyValueLabel:setString("[255,255,255]"..energyValue.Desc.."[=][0,255,0]+"..energyValue.Value.."[=]")
        self.data.costScore = energyConfig.Score
        self.controls.stepName:setString(energyConfig.StepName)
    end

    if GameCache.Avatar.EnergyAttrNum == (#energyPosTabs) then
        self.controls.btn_upgrade:setString("升学")
        self.controls.costScore:setString("[255,255,255]升学花费[=][255,220,20]"..ENERGY_PRICE.."[=][255,255,255]银币[=]")
        if GameCache.Avatar.EnergyStep == ENERGY_MAXSTEP then
            self.controls.costScore:setVisible(false)
        end
    else
        self.controls.btn_upgrade:setString("好好学习")
        self.controls.costScore:setString("[255,255,255]修炼1次消耗[=][255,220,20]"..self.data.costScore.."[=][255,255,255]积分[=]")
    end
    self.controls.instanceScore:setString(Common.numConvert(GameCache.Avatar.InstanceScore))

    self:updateAddAttrValue()
end

function EnergyLayer:updateAddAttrValue()
    for k,v in pairs(self.data.addAttrLabTab) do
        v:setScale(1)
    end
    if self.data.scaleLabIdx and (not self.data.isShowAddAttrAction) then
        local scale1 = cc.ScaleTo:create(0.2, 2)
        local scale2 = cc.ScaleTo:create(0.05, 1)
        self.data.addAttrLabTab[self.data.scaleLabIdx]:setColor(cc.c3b(255,168,0))
        self.data.addAttrLabTab[self.data.scaleLabIdx]:runAction(cc.Sequence:create(scale1, scale2, cc.CallFunc:create(function(sender)
            sender:setColor(cc.c3b(54, 87, 154))
        end)))
    end

    for i=1,(#attrDescTab) do
        self.data.addAttrLabTab[i]:setString(attrDescTab[i].." +"..(GameCache.Avatar.EnergeAttrTab[i] or 0))
    end


end

function EnergyLayer:updateLightPoint()
    local function drawLightLine(firstIdx, secondIdx)
        local firstPoint = self.data.lightPointTab[firstIdx]
        local secondPoint = self.data.lightPointTab[secondIdx]
        local line = self.data.lightLineTab[firstIdx]

        firstPoint:setVisible(true)
        line:setVisible(true)
        local x1, y1 = firstPoint:getPosition()
        local x2, y2 = secondPoint:getPosition()

        local a = x1 - x2
        local b = y1 - y2
        local c = math.sqrt(math.pow(a,2) + math.pow(b,2)) 
        local angle = math.deg(math.asin(a / c))

        line:setContentSize(cc.size(10, c))
        line:setPosition(x1, y1)

        -- 分别在1、2、3、4象限的角度
        if (a < 0) and (b < 0) then
            line:setRotation(-angle)
        elseif (a >= 0) and (b < 0) then
            line:setRotation(-angle)
        elseif (a >= 0) and (b >= 0) then
            line:setRotation(180 + angle)
        elseif (a < 0) and (b >= 0) then
            line:setRotation(180 + angle)
        end
        
        local function callFunc()
            secondPoint:setScale(0)
            secondPoint:setVisible(true)
            local scale1 = cc.ScaleTo:create(0.08, 2)
            local scale2 = cc.ScaleTo:create(0.05, 1)
            secondPoint:runAction(cc.Sequence:create(scale1, scale2))
            
            if secondIdx < 6 then
                drawLightLine(secondIdx, secondIdx + 1)
            end
        end
        line:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1, 1), cc.CallFunc:create(callFunc)))
    end

    local tempPos = {{130, 210}, {140, 150}, {100, 130}, {120, 80}, {80, 60}, {170, 50}}
    for i=1,6 do
        self.data.lightPointTab[i]:setPosition(tempPos[i][1], tempPos[i][2])
        self.data.lightPointTab[i]:setVisible(false)
        self.data.lightLineTab[i]:setScaleY(0)
        self.data.lightLineTab[i]:setVisible(false)
    end
    drawLightLine(1, 2)
end

function EnergyLayer:upgradeAction()
    for k,v in pairs(energyPosTabs) do
        local currStepID = ((GameCache.Avatar.EnergyStep - 1) - 1) * (#energyPosTabs) + k -- 当前EnergyStep值已经+1，-1返回上层
        local nextStepID = (GameCache.Avatar.EnergyStep - 1) * (#energyPosTabs) + k
        local currStepConfig = BaseConfig.getEnergyInfo(currStepID)
        local nextStepConfig = BaseConfig.getEnergyInfo(nextStepID)

        local node = self.controls.bg:getChildByTag(ENERGYBALLNODETAG + k)
        node:stopAllActions()
        node:setPosition(v[1], v[2])
        local energyLight = node:getChildByTag(ENERGYLIGHTTAG + k)
        local energyBall = node:getChildByTag(ENERGYBALLTAG + k)
        local energyLogo = node:getChildByTag(ENERGYLOGOTAG + k)
        local tiaoBg = self.controls.bg:getChildByTag(ENERGYBGTAG + k)
        local addEnergyValueLabel = self.controls.bg:getChildByTag(ENERGYVALUETAG + k)
        
        energyLight:setVisible(true)
        energyBall:setTexture("image/ui/img/btn/btn_551.png")
        energyLogo:setTexture(self:getAttrSpriPath(true, currStepConfig.PropertyType))
        tiaoBg:setVisible(false)
        addEnergyValueLabel:setVisible(false)

        local function firstFunc()
            node:setScale(0)
            energyLight:setVisible(false)
            energyBall:setTexture("image/ui/img/btn/btn_548.png")
            energyLogo:setTexture(self:getAttrSpriPath(false, nextStepConfig.PropertyType))
            if k == (#energyPosTabs) then
                self.controls.people:setTexture("image/ui/img/btn/btn_581.png")
                self:updateLightPoint()
            end
        end
        local function secondFunc()
            if k == (#energyPosTabs) then
                self:updateEnergyBall()
                self.controls.people:setTexture("image/ui/img/btn/btn_557.png")
                for i=1,6 do
                    self.data.lightPointTab[i]:setVisible(false)
                    self.data.lightLineTab[i]:setVisible(false)
                end
                application:showFlashNotice("恭喜上仙，升学成功!")
                self.data.isCanClick = true
            end
            tiaoBg:setVisible(true)
            addEnergyValueLabel:setVisible(true)
        end

        local firstTime = 0.3
        local secondTime = 0.5
        local move1 = cc.MoveTo:create(firstTime, cc.p(self.data.bgSize.width * 0.355, self.data.bgSize.height * 0.6))
        local scale1 = cc.ScaleTo:create(firstTime, 0.5)
        local spawn1 = cc.Spawn:create(move1, scale1) 
        local lightDelay = cc.DelayTime:create(0.4 + (k - 1) * 0.05)
        local move2 = cc.EaseBounceOut:create(cc.MoveTo:create(secondTime, cc.p(v[1], v[2])))
        local scale2 = cc.ScaleTo:create(secondTime, 1)
        local spawn2 = cc.Spawn:create(move2, scale2)  
        node:runAction(cc.Sequence:create(spawn1, cc.CallFunc:create(firstFunc), lightDelay, spawn2, cc.CallFunc:create(secondFunc)))
    end
end

-- 1、攻击
-- 2、防御
-- 3、生命
-- 4、法力
-- 5、精准
-- 6、闪避
-- 7、暴击
-- 8、韧性
-- 9、体力上限
-- 10、耐力上限
function EnergyLayer:getAttrSpriPath(isOpen, propertyType)
    local path = nil
    if isOpen then
        if propertyType == 1 then
            path = "image/ui/img/btn/btn_568.png"
        elseif propertyType == 2 then
            path = "image/ui/img/btn/btn_567.png"
        elseif propertyType == 3 then
            path = "image/ui/img/btn/btn_565.png"
        elseif propertyType == 4 then
            path = "image/ui/img/btn/btn_566.png"
        elseif propertyType == 5 then
            path = "image/ui/img/btn/btn_569.png"
        elseif propertyType == 6 then
            path = "image/ui/img/btn/btn_563.png"
        elseif propertyType == 7 then
            path = "image/ui/img/btn/btn_564.png"
        elseif propertyType == 8 then
            path = "image/ui/img/btn/btn_562.png"
        elseif propertyType == 9 then
            path = "image/ui/img/btn/btn_561.png"
        elseif propertyType == 10 then
            path = "image/ui/img/btn/btn_560.png"
        end
    else
        if propertyType == 1 then
            path = "image/ui/img/btn/btn_577.png"
        elseif propertyType == 2 then
            path = "image/ui/img/btn/btn_576.png"
        elseif propertyType == 3 then
            path = "image/ui/img/btn/btn_574.png"
        elseif propertyType == 4 then
            path = "image/ui/img/btn/btn_575.png"
        elseif propertyType == 5 then
            path = "image/ui/img/btn/btn_579.png"
        elseif propertyType == 6 then
            path = "image/ui/img/btn/btn_572.png"
        elseif propertyType == 7 then
            path = "image/ui/img/btn/btn_573.png"
        elseif propertyType == 8 then
            path = "image/ui/img/btn/btn_571.png"
        elseif propertyType == 9 then
            path = "image/ui/img/btn/btn_570.png"
        elseif propertyType == 10 then
            path = "image/ui/img/btn/btn_578.png"
        end
    end
    return path
end

function EnergyLayer:getEnergyValue(energyConfig, isAddAvatar)
    local energyType = energyConfig.PropertyType
    local energyValue = energyConfig.PropertyValue
    local desc = attrDescTab[energyType]
    if isAddAvatar then
        self.data.scaleLabIdx = energyType
        GameCache.Avatar.EnergeAttrTab[energyType] = GameCache.Avatar.EnergeAttrTab[energyType] + energyValue
    end
    return {Desc = desc, Value = energyValue}
end

--[[
    元神提升
]]
function EnergyLayer:UpgradeEnergy()
    if GameCache.Avatar.EnergyAttrNum == 6 then
        if not self.data.isCanUpgrade then
            application:showFlashNotice("条件未满足～")
            return
        end
    end

    rpc:call("Avatar.UpgradeEnergy", nil, function(event)
        if event.status == Exceptions.Nil then
            self.data.isCanClick = false
            if GameCache.Avatar.EnergyAttrNum == 0 then
                self.data.isShowAddAttrAction = false
                self:upgradeAction()

                local energyConfig = BaseConfig.getEnergyUpgrade(GameCache.Avatar.EnergyStep - 1)
                local energyValue = self:getEnergyValue(energyConfig, true)

                self.data.upgradeConditionInfo = event.result.Energy
                self:updateUpgradeCondition()
                application:showIconNotice(event.result.Goods)
            else
                self.data.isCanClick = true
                self.data.isShowAddAttrAction = false
                local id = (GameCache.Avatar.EnergyStep - 1) * 6 + GameCache.Avatar.EnergyAttrNum
                local energyConfig = BaseConfig.getEnergyInfo(id)
                local energyValue = self:getEnergyValue(energyConfig, true)
                self:updateEnergyBall()
                application:showFlashNotice("修炼成功!"..energyValue.Desc.."+"..energyValue.Value)
            end
        end
    end)
end

function EnergyLayer:onEnterTransitionFinish( )
    Common.OpenSystemLayer({4})
    EnergyLayer.super.onEnterTransitionFinish(self)
end

return EnergyLayer