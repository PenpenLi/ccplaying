local TowerLayer = class("TowerLayer", BaseLayer)

local HeroAction = require("tool.helper.HeroAction")
local effects = require("tool.helper.Effects")
local scheduler = cc.Director:getInstance():getScheduler()

local bg1PanelTag = 10
local bg2PanelTag = 20
local bg3PanelTag = 30

local BOX_TAG = 10
local EFF_TAG = BOX_TAG + 1
local BOX_TYPEBG_TAG = EFF_TAG + 1
local BOX_TYPE_TAG = BOX_TYPEBG_TAG + 1

local BOX_TYPE_SOUL = 1
local BOX_TYPE_UPGRADEPILL = 2
local BOX_TYPE_TOKRN = 3
local BOX_TYPE_STONE = 4

local boxTypePathTab = {"image/ui/img/btn/btn_1347.png", "image/ui/img/btn/btn_1236.png",
                        "image/ui/img/btn/btn_218.png","image/ui/img/btn/btn_219.png"}

function TowerLayer:ctor(towerInfo)
    self.wxTexture = {
        "image/ui/img/btn/btn_385.png",
        "image/ui/img/btn/btn_383.png",
        "image/ui/img/btn/btn_386.png",
        "image/ui/img/btn/btn_384.png",
        "image/ui/img/btn/btn_387.png",
    }
    self.atkAttr = {
        "image/ui/img/btn/btn_650.png",
        "image/ui/img/btn/btn_649.png",
        "image/ui/img/btn/btn_648.png",
    }

    TowerLayer.super.ctor(self)
    self.data.halfScreenWidth = SCREEN_WIDTH * 0.5
    self.data.halfScreenHeight = SCREEN_HEIGHT * 0.5
    self.data.isCanClickEnemy = false
    self.data.isCanClickBox = false 
    self.data.enemyHeroItemTab = {}

    self.data.floor = towerInfo.CurFloor
    self.data.climbTimes = towerInfo.TotalResetCount - towerInfo.DailyResetCount
    self.data.totalClimbTimes = towerInfo.TotalResetCount
    self.data.towerEnemyAnimIDTab = towerInfo.Boss
    self.data.chestTypeTab = towerInfo.Chest
    self:createFixedUI()
    self:getTowerInfo()

    if 0 ~= (#towerInfo.DrawList) then
        local node = cc.Node:create()
        self:addChild(node)
        node:runAction(cc.Sequence:create({cc.DelayTime:create(1), cc.CallFunc:create(function()
            local drawLayer = require("scene.main.tower.widget.DrawGoods").new(towerInfo.DrawList)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(drawLayer, 1)
        end)}))
    end
end

function TowerLayer:createFixedUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)
    
    local textureBG = cc.TextureCache:getInstance():addImage("image/ui/img/bg/bg_255.png")
    self.controls.bg1 = cc.Sprite:createWithTexture(textureBG)
    self.data.bgSize = self.controls.bg1:getContentSize()

    self.controls.sky = cc.Sprite:create("dummy/yunbiao.jpg")
    self.controls.sky:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.sky)

    local elevator = cc.Sprite:create("image/ui/img/btn/btn_980.png")
    elevator:setPosition(self.data.halfScreenWidth - self.data.bgSize.width * 0.25, self.data.halfScreenHeight + self.data.bgSize.height)
    self:addChild(elevator)
    local move = cc.MoveBy:create(5, cc.p(0, -self.data.bgSize.height * 2.5))
    local move_reverse = move:reverse()
    elevator:runAction(cc.RepeatForever:create(cc.Sequence:create(move, move_reverse)))
    elevator = cc.Sprite:create("image/ui/img/btn/btn_980.png")
    elevator:setPosition(self.data.halfScreenWidth + self.data.bgSize.width * 0.25, self.data.halfScreenHeight + self.data.bgSize.height)
    self:addChild(elevator)
    move = cc.MoveBy:create(2, cc.p(0, -self.data.bgSize.height * 2.5))
    move_reverse = move:reverse()
    elevator:runAction(cc.RepeatForever:create(cc.Sequence:create(move:clone(), move_reverse:clone())))

    self.data.bgTab = {}
    self.controls.bg1:setAnchorPoint(0.5,0)
    self.controls.bg1:setPosition(self.data.halfScreenWidth, self.data.bgSize.height - SCREEN_HEIGHT)
    self:addChild(self.controls.bg1)
    self.controls.bg1:setTag(bg1PanelTag)
    table.insert(self.data.bgTab, self.controls.bg1)

    self.controls.bg2 = cc.Sprite:createWithTexture(textureBG)
    self.controls.bg2:setAnchorPoint(0.5,0)
    self.controls.bg2:setPosition(self.data.halfScreenWidth, self.data.bgSize.height + self.controls.bg1:getPositionY())
    self:addChild(self.controls.bg2)
    self.controls.bg2:setTag(bg2PanelTag)
    table.insert(self.data.bgTab, self.controls.bg2)

    self.controls.bg3 = cc.Sprite:createWithTexture(textureBG)
    self.controls.bg3:setAnchorPoint(0.5,0)
    self.controls.bg3:setPosition(self.data.halfScreenWidth, self.data.bgSize.height + self.controls.bg2:getPositionY())
    self:addChild(self.controls.bg3)
    self.controls.bg3:setTag(bg3PanelTag)
    table.insert(self.data.bgTab, self.controls.bg3)

    for k,v in pairs(self.data.bgTab) do
        local enemyAnimID = nil
        if self.data.floor > 40 then
            enemyAnimID = self.data.towerEnemyAnimIDTab[1]
        else
            enemyAnimID = self.data.towerEnemyAnimIDTab[math.ceil(self.data.floor / 2)]
        end
        local scaleConfig = BaseConfig.GetHeroScale(enemyAnimID)
        local heroScale = scaleConfig.ShowScale / 10000
        local enemyAnim = HeroAction.new(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.59, enemyAnimID)
        enemyAnim:setScale(heroScale)
        enemyAnim:addTouchEvent(function()
            if self.data.isCanClickEnemy then
                self.data.isCanClickEnemy = false
                self.data.currClickEnemyPanel = v
                self:ClickEnemy()
                self.data.currCombatEnemy = enemyAnim
            end
        end)
        enemyAnim:setName("anim")
        v:addChild(enemyAnim)

        local box = createMixSprite("image/ui/img/bg/box_1_0.png")
        box:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.18)
        box:setCircleFont("", 1, 1, 50, cc.c3b(255, 0, 0), 1)
        box:setTag(BOX_TAG)
        v:addChild(box)
        box:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.data.isCanClickBox then
                    self:ClickChest(box)
                end
            end
        end)
        local move = cc.MoveBy:create(1, cc.p(0, 30))
        local move_reverse = move:reverse()
        box:runAction(cc.RepeatForever:create(cc.Sequence:create(move, move_reverse)))
        local effect = effects:CreateAnimation(v, self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.08, nil, 22, true)
        effect:setTag(EFF_TAG)
        local qipaoBg = cc.Sprite:create("image/ui/img/btn/btn_1062.png")
        qipaoBg:setTag(BOX_TYPEBG_TAG)
        qipaoBg:setPosition(0, 80)
        box:addChild(qipaoBg)
        local boxType = cc.Sprite:create("image/ui/img/btn/btn_1347.png")
        boxType:setTag(BOX_TYPE_TAG)
        boxType:setPosition(0, 85)
        box:addChild(boxType)
        if self.data.floor > 40 then
            effect:setVisible(false)
            qipaoBg:setVisible(false)
            boxType:setVisible(false)
        else
            local boxTypeIdx = self.data.chestTypeTab[math.ceil(self.data.floor / 2)]
            self:updateBoxType(box, boxTypeIdx)
        end

        local floor1 = Common.finalFont(k, 1, 1, 35, cc.c3b(0, 0, 0))
        floor1:setPosition(self.data.bgSize.width * 0.12, self.data.bgSize.height * 0.26)
        floor1:setTag(1)
        v:addChild(floor1)

        local floor2 = Common.finalFont(k, 1, 1, 35, cc.c3b(0, 0, 0))
        floor2:setPosition(self.data.bgSize.width * 0.12, self.data.bgSize.height * 0.82)
        floor2:setTag(2)
        v:addChild(floor2)
    end

    self.controls.jiantou = cc.Sprite:create("image/ui/img/btn/btn_834.png")
    self.controls.jiantou:setPosition(self.data.halfScreenWidth, self.data.halfScreenHeight + self.data.bgSize.height * 0.06)
    self:addChild(self.controls.jiantou)
    local move = cc.MoveBy:create(0.2, cc.p(0, 10))
    local move_reverse = move:reverse()
    self.controls.jiantou:runAction(cc.RepeatForever:create(cc.Sequence:create(move, move_reverse)))

    local payBg = cc.Sprite:create("image/ui/img/bg/bg_196.png")
    payBg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT - payBg:getContentSize().height * 0.5)
    self:addChild(payBg)
    payBg = cc.Sprite:create("image/ui/img/bg/bg_196.png")
    payBg:setScaleY(-1)
    payBg:setPosition(SCREEN_WIDTH*0.5, payBg:getContentSize().height * 0.5)
    self:addChild(payBg)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH*0.5 - size.width * 0.5, SCREEN_HEIGHT - 50)
    self:addChild(pay)

    local function swallowLayer()
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), self.data.bgSize.width, self.data.bgSize.height * 0.3)
        layer:setPosition(self.data.halfScreenWidth-self.data.bgSize.width * 0.5, 0)
        self:addChild(layer)

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
    swallowLayer()

    local addBlood = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, "image/ui/img/btn/btn_919.png", cc.size(130, 60))
    addBlood:setCircleFont("医务室", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    addBlood:setFontOutline(cc.c3b(70, 50, 14), 1)
    addBlood:setChildPos(0.2, 0.5)
    addBlood:setFontPos(0.63, 0.5)
    addBlood:setPosition(SCREEN_WIDTH * 0.35, SCREEN_HEIGHT * 0.06)
    self:addChild(addBlood)
    addBlood:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:EnterClinic()
        end
    end)

    self.controls.reset = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(130, 60))
    self.controls.reset:setCircleFont("重置", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    self.controls.reset:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.controls.reset:setPosition(SCREEN_WIDTH * 0.65, SCREEN_HEIGHT * 0.06)
    self:addChild(self.controls.reset)
    self.controls.reset:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.climbTimes > 0 then
                -- 第1次免费, 第2次开始200元宝
                local resetCount = self.data.totalClimbTimes - self.data.climbTimes
                if resetCount > 0 then
                    if GameCache.Avatar.Gold < 200 then
                        application:showFlashNotice("元宝不足200，无法重置！")
                        return
                    end
                end
                self:resetAlert(resetCount)
            end
        end
    end)

    local btn_help = createMixSprite("image/ui/img/btn/btn_868.png")
    btn_help:setPosition(SCREEN_WIDTH*0.95, SCREEN_HEIGHT*0.8)
    self:addChild(btn_help)
    btn_help:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local node = self:helpUI()
            self:addChild(node)
        end
    end)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(SCREEN_WIDTH*0.95, SCREEN_HEIGHT*0.94)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
    self:addChild(btn_close)

    local animation = HeroAction.new(0, -20, GameCache.Avatar.Figure)
    animation:setName("anim")
    animation:setScale(0.8)
    self.controls.animation = cc.Sprite:create("image/ui/img/btn/btn_1005.png")
    self.controls.animation:setOpacity(0)
    self.controls.animation:addChild(animation)
    self.controls.animation:setPosition(self.data.halfScreenWidth + self.data.bgSize.width * 0.2, 
                                        self.data.halfScreenHeight)
    self:addChild(self.controls.animation)
    animation:addTouchEvent(function()
        CCLog("=============hero===========")
    end)

    self.controls.enemtyPanel = self:EnemtyHeroUI()
    self:addChild(self.controls.enemtyPanel)
    self.controls.enemtyPanel:setLocalZOrder(-1)
end

function TowerLayer:getTowerInfo()
    CCLog("TowerLayer:getTowerInfo")
    self.controls.reset:setString("重置("..self.data.climbTimes..")")
    if self.data.climbTimes > 0 then
        self.controls.reset:setNorGLProgram(true)
        self.controls.reset:setTouchEnable(true)
    else
        self.controls.reset:setNorGLProgram(false)
        self.controls.reset:setTouchEnable(false)
    end

    local beforePanel = self.controls.bg1
    local afterbgPanel = self.controls.bg2

    if (self.data.floor % 2) == 0 then
        self.controls.animation:setPosition(self.data.halfScreenWidth - self.data.bgSize.width * 0.13, self.data.halfScreenHeight - self.data.bgSize.height * 0.2)
        self.data.isCanClickBox = true
        self:bgMoveAction(0, 0)

        beforePanel:getChildByName("anim"):setVisible(false)
        if self.data.floor >= 40 then
            afterbgPanel:getChildByName("anim"):setVisible(false)
            local box = afterbgPanel:getChildByTag(BOX_TAG)
            local path = "image/ui/img/bg/"..(BaseConfig.getTower(self.data.floor).Res).."_0.png"
            box:setTexture(path)
            level1 = afterbgPanel:getChildByTag(1)
            level2 = afterbgPanel:getChildByTag(2)
            level1:setString(self.data.floor.."层")
            level2:setString("顶层")
            beforePanel:getChildByTag(2):setString((self.data.floor - 1).."层")
            return
        end

        local enemyAnimID = self.data.towerEnemyAnimIDTab[1 + math.ceil(self.data.floor / 2)]
        self:createTowerEnemyAnim(enemyAnimID, afterbgPanel)
    else
        if self.data.floor > 40 then
            self.controls.animation:setPosition(self.data.halfScreenWidth - self.data.bgSize.width * 0.13, self.data.halfScreenHeight - self.data.bgSize.height * 0.2)
            self:bgMoveAction(0, 0)

            afterbgPanel:getChildByName("anim"):setVisible(false)
            local box = afterbgPanel:getChildByTag(BOX_TAG)
            local path = "image/ui/img/bg/"..(BaseConfig.getTower(self.data.floor - 1).Res).."_1.png"
            box:setTexture(path)
            level1 = afterbgPanel:getChildByTag(1)
            level2 = afterbgPanel:getChildByTag(2)
            level1:setString((self.data.floor - 1).."层")
            level2:setString("顶层")
            beforePanel:getChildByTag(2):setString((self.data.floor - 2).."层")

            for k,v in pairs(self.data.bgTab) do
                local anim = v:getChildByName("anim")
                anim:setVisible(false)
            end
            return
        end

        self.controls.animation:setPosition(self.data.halfScreenWidth + self.data.bgSize.width * 0.2, self.data.halfScreenHeight - self.data.bgSize.height * 0.2)
        self.controls.animation:setScaleX(-1)
        self:moveToEnemyAction()
    end
    self:updateFloorInfo(self.controls.bg1, self.data.floor)
end

function TowerLayer:helpUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(600, 240))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local lab = Common.finalFont("活动规则：", bgSize.width * 0.05, bgSize.height * 0.85, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("1.每日可免费重置一次爬塔机会，一共有20个关卡。", bgSize.width * 0.05, bgSize.height * 0.72, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("2.每次爬塔只能上阵30级以上的星将，每次战斗结束后星将\n不会回血但要保留上次战斗的怒气值。", bgSize.width * 0.05, bgSize.height * 0.55, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("3.每战胜一个关卡，可以获得一个宝箱。领取宝箱后可以获得\n一次翻牌机会。", bgSize.width * 0.05, bgSize.height * 0.35, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("4.可将受伤的星将放入医务室，每过一关医务室中的星将会\n回复一定血量。", bgSize.width * 0.05, bgSize.height * 0.16, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)

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

function TowerLayer:resetAlert(resetCount)
    local node = cc.Node:create()
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(panel)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    if resetCount > 0 then
        local desc = Common.finalFont("是否花费", 1, 1, 20, nil, 1)
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(panelSize.width * 0.2, panelSize.height * 0.65)
        panel:addChild(desc)
        desc = Common.finalFont("进行重置?", 1, 1, 20, nil, 1)
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(panelSize.width * 0.6, panelSize.height * 0.65)
        panel:addChild(desc)
        local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png") 
        goldSpri:setPosition(panelSize.width * 0.45, panelSize.height * 0.65)
        panel:addChild(goldSpri)
        local goldCost = Common.finalFont("200", panelSize.width * 0.49,panelSize.height * 0.65, 25, cc.c3b(255, 246, 0))
        goldCost:setAnchorPoint(0, 0.5)
        panel:addChild(goldCost)
    else
        local desc = Common.finalFont("是否确定重置?", 1, 1, 20, nil, 1)
        desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.65)
        panel:addChild(desc)
    end

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.28)
    panel:addChild(btnBG)
    local sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 56))
    sure:setButtonBounce(false)
    sure:setFont("确定" , 1, 1, 25, cc.c3b(238, 205, 142))
    sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    sure:setPosition(panelSize.width * 0.5,panelSize.height * 0.28)
    panel:addChild(sure)
    sure:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended then
            self:Reset()
            node:removeFromParent()
            node = nil
        end
    end)

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
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function TowerLayer:EnemtyHeroUI()
    local node = cc.Node:create()

    local bgZOrder = 2
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(self.data.halfScreenWidth, self.data.halfScreenHeight)
    bg:setContentSize(cc.size(604,560))
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(-self.data.halfScreenWidth + bgSize.width * 0.5, 
                        -self.data.halfScreenHeight + bgSize.height * 0.5)
    bg:addChild(bgLayer, -1)

    local energyBg = cc.Sprite:create("image/ui/img/bg/bg_291.png")
    energyBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    bg:addChild(energyBg, bgZOrder)

    local leftBG = createMixSprite("image/ui/img/btn/btn_1182.png", nil, "image/ui/img/bg/bg_171.png")
    leftBG:setChildPos(0.6, 0.5)
    local bgbg = leftBG:getChild()
    bgbg:setRotation(-90)
    bgbg:setScaleX(0.82)
    bgbg:setScaleY(0.95)
    leftBG:setTouchEnable(false)
    leftBG:setPosition(-bgSize.width * 0.048, bgSize.height * 0.5)
    bg:addChild(leftBG, bgZOrder)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setRotation(90)
    line:setPosition(-bgSize.width * 0.043, bgSize.height * 0.8)
    bg:addChild(line, bgZOrder)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setRotation(-90)
    line:setPosition(-bgSize.width * 0.043, bgSize.height * 0.2)
    bg:addChild(line, bgZOrder)

    local rightBG = createMixSprite("image/ui/img/btn/btn_1182.png", nil, "image/ui/img/bg/bg_171.png")
    rightBG:setScaleX(-1)
    rightBG:setChildPos(0.6, 0.5)
    local bgbg = rightBG:getChild()
    bgbg:setRotation(-90)
    bgbg:setScaleX(0.82)
    bgbg:setScaleY(0.95)
    rightBG:setTouchEnable(false)
    rightBG:setPosition(bgSize.width * 1.048, bgSize.height * 0.5)
    bg:addChild(rightBG, bgZOrder)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setRotation(90)
    line:setPosition(bgSize.width * 1.043, bgSize.height * 0.8)
    bg:addChild(line, bgZOrder)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setRotation(-90)
    line:setPosition(bgSize.width * 1.043, bgSize.height * 0.2)
    bg:addChild(line, bgZOrder)
    local enemyForm = Common.finalFont("对\n手\n阵\n容", 1, 1, 30, cc.c3b(173, 154, 164), 1)
    enemyForm:setPosition(bgSize.width * 1.043, bgSize.height * 0.5)
    bg:addChild(enemyForm, bgZOrder)

    local detailName = Common.finalFont("第\n\n\n层", 1, 1, 30, cc.c3b(213, 242, 255))
    detailName:setPosition(-bgSize.width * 0.043, bgSize.height * 0.5)
    bg:addChild(detailName, bgZOrder)

    self.controls.floorNum = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    self.controls.floorNum:setAdditionalKerning(-8)
    self.controls.floorNum:setPosition(-bgSize.width * 0.043, bgSize.height * 0.5)
    bg:addChild(self.controls.floorNum, bgZOrder)
    self.controls.floorNum:setScale(0.7)

    local nameBg = cc.Sprite:create("image/ui/img/bg/bg_276.png")
    nameBg:setPosition(bgSize.width * 0.45, bgSize.height * 0.9)
    bg:addChild(nameBg, bgZOrder)

    self.controls.teamName = Common.finalFont("逗逼", 1, 1, 25, cc.c3b(238, 205, 142))
    self.controls.teamName:setPosition(bgSize.width * 0.18, bgSize.height * 0.9)
    bg:addChild(self.controls.teamName, bgZOrder)

    local tfp = Common.finalFont("战力:", 1, 1, 25, nil, 1)
    tfp:setPosition(bgSize.width * 0.58, bgSize.height * 0.9)
    bg:addChild(tfp, bgZOrder)

    self.controls.ftp = Common.finalFont("0", 1, 1, 30, cc.c3b(151, 255, 74), 1)
    self.controls.ftp:setAdditionalKerning(-2)
    self.controls.ftp:setAnchorPoint(0, 0.4)
    self.controls.ftp:setPosition(bgSize.width * 0.64, bgSize.height * 0.9)
    bg:addChild(self.controls.ftp, bgZOrder)

    self.controls.level = Common.finalFont("Lv10", 1, 1, 25)
    self.controls.level:setPosition(bgSize.width * 0.38, bgSize.height * 0.9)
    bg:addChild(self.controls.level, bgZOrder)

    local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(585,85))
    bottom:setAnchorPoint(0.5,0)
    bottom:setPosition(bgSize.width*0.5, 15)
    bg:addChild(bottom, bgZOrder)

    local battle = createMixSprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_670.png")
    battle:setCircleFont("挑战", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    battle:setFontOutline(cc.c3b(70, 50, 14), 1)
    battle:setChildPos(0.3, 0.5)
    battle:setFontPos(0.6, 0.5)
    battle:setPosition(bgSize.width * 0.5, bgSize.height * 0.1)
    bg:addChild(battle, bgZOrder)
    battle:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.floor <= 40 then
                --self:GetTowerHeroInfo()
                self:BeforeF()
            end
        end
    end)

    local fairyBg = cc.Sprite:create("image/ui/img/btn/btn_643.png")
    fairyBg:setPosition(bgSize.width-35, bgSize.height-25)
    bg:addChild(fairyBg, bgZOrder)
    self.controls.fairy = cc.Sprite:create("image/ui/img/btn/btn_643.png")
    self.controls.fairy:setPosition(bgSize.width-35, bgSize.height-25)
    bg:addChild(self.controls.fairy, bgZOrder)
    local fairyBefore = cc.Sprite:create("image/ui/img/btn/btn_647.png")
    fairyBefore:setPosition(bgSize.width-35, bgSize.height-65)
    bg:addChild(fairyBefore, bgZOrder)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if not cc.rectContainsPoint(rect, locationInNode) then
            self.controls.enemtyPanel:setLocalZOrder(-1)
            self.data.isCanClickEnemy = true
            return true
        end
        return false
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    self.controls.team_Bg = bg
    return node
end

function TowerLayer:updateEnemyHero()
    self.controls.floorNum:setString(self.data.floor)
    self.controls.teamName:setString(self.data.floorInfo.Name)
    self.controls.level:setString("Lv."..self.data.floorInfo.Level)
    self.controls.ftp:setString(self.data.floorInfo.TFP)

    local remainHPList = self.data.floorInfo.RemainHP
    for k,v in pairs(self.data.enemyHeroItemTab) do
        v.shadow:removeFromParent()
        v.hero:removeFromParent()
        v.icon:removeFromParent()
        v = nil
    end
    self.data.enemyHeroItemTab = {}

    local form = self.data.floorInfo.Form.Hero
    local herolist = self.data.floorInfo.HeroList
    if self.data.floorInfo.Form.Fairy ~= 0 then
        local path = "image/ui/fairy/xn_"..string.sub(self.data.floorInfo.Form.Fairy,2).."_head.png"
        self.controls.fairy:setTexture(path)
        self.controls.fairy:setScale(1)
    else
        self.controls.fairy:setScale(0)
    end
    local bgSize = self.controls.team_Bg:getContentSize()
    for i = #form, 1, -1 do
        local x = form[i].X*(-0.25)*bgSize.width+bgSize.width  
        local y = 50+form[i].Y*0.14*bgSize.height

        local wx = BaseConfig.GetHero(form[i].ID,0).wx
        local texture = self.wxTexture[wx]

        local shadow = cc.Sprite:create(texture)
        shadow:setPosition(x, y)
        self.controls.team_Bg:addChild(shadow, 2)
       
        local hero = HeroAction.new(x, y, form[i].ID, herolist[i])
        hero:setTouchEnabled(false)
        hero:setAnimation(0,"idle",true)
        hero:setRotationSkewY(180)
        hero:setScale(0.8)
        self.controls.team_Bg:addChild(hero, 2)

        local attr = BaseConfig.GetHero(form[i].ID,0).atkSkill - 1000
        local tex = self.atkAttr[attr]
        local icon = cc.Sprite:create(tex)
        icon:setPosition(x,y)
        self.controls.team_Bg:addChild(icon, 2)

        self.data.enemyHeroItemTab[i] = {}
        self.data.enemyHeroItemTab[i].shadow = shadow
        self.data.enemyHeroItemTab[i].hero = hero
        self.data.enemyHeroItemTab[i].icon = icon
    end
end

function TowerLayer:moveToEnemyAction()
    self.controls.animation:getChildByName("anim"):action_move()
    local move = cc.MoveBy:create(0.5, cc.p(-self.data.bgSize.width * 0.1, 0))
    local func = cc.CallFunc:create(function()
        self.data.isCanClickEnemy = true
        self.controls.animation:getChildByName("anim"):action_idle()
    end)
    self.controls.animation:runAction(cc.Sequence:create(move, func))

end

function TowerLayer:heroLeftClimbTowerAction()
    self.controls.jiantou:setVisible(false)
    self.controls.animation:getChildByName("anim"):action_move()
    local moveLeftTime = 1
    local climbTime = 2

    local moveLeft = cc.MoveBy:create(moveLeftTime, cc.p(-self.data.bgSize.width * 0.21, 0))
    local climb = cc.MoveBy:create(climbTime, cc.p(-self.data.bgSize.width * 0.18, 0))
    local moveRight = cc.MoveBy:create(0.5, cc.p(self.data.bgSize.width * 0.14, 0))
    local func2 = cc.CallFunc:create(function()
        self.controls.animation:setRotation(0)
        self.controls.animation:setScaleX(1)
    end)
    local func3 = cc.CallFunc:create(function()
        self.data.isCanClickBox = true
        self.controls.animation:getChildByName("anim"):action_idle()
        self.controls.jiantou:setVisible(true)
    end)

    self.controls.animation:runAction(cc.Sequence:create(moveLeft, climb, func2, moveRight, func3))
    self:bgMoveAction(moveLeftTime, climbTime)
end

function TowerLayer:heroRightClimbTowerAction()
    self.controls.jiantou:setVisible(false)
    self.controls.animation:getChildByName("anim"):action_move()
    local moveRightTime = 1
    local climbTime = 2

    local moveRight = cc.MoveBy:create(moveRightTime, cc.p(self.data.bgSize.width * 0.25, 0))
    local climb = cc.MoveBy:create(climbTime, cc.p(self.data.bgSize.width * 0.16, 0))
    local moveLeft = cc.MoveBy:create(0.5, cc.p(-self.data.bgSize.width * 0.15, 0))

    local func2 = cc.CallFunc:create(function()
        self.controls.animation:setRotation(0)
        self.controls.animation:setScaleX(-1)
    end)
    local func3 = cc.CallFunc:create(function()
        self.data.isCanClickEnemy = true
        self.controls.animation:getChildByName("anim"):action_idle()
        self.controls.jiantou:setVisible(true)
    end)

    self.controls.animation:runAction(cc.Sequence:create(moveRight, climb, func2, moveLeft, func3))
    self:bgMoveAction(moveRightTime, climbTime)
end

function TowerLayer:bgMoveAction(_delayTime, _climbTime)
    local delayTime = cc.DelayTime:create(_delayTime)
    local func = cc.CallFunc:create(function()
        for k,v in pairs(self.data.bgTab) do
            local y = v:getPositionY()
            if y < -self.data.bgSize.height then
                local currTag = v:getTag()
                local beforeTag = currTag - 10
                local beforebg = nil
                if beforeTag < 1 then
                    beforebg = self:getChildByTag(bg3PanelTag)
                else
                    beforebg = self:getChildByTag(beforeTag)
                end
                v:setPositionY(beforebg:getPositionY() + self.data.bgSize.height)
                v:getChildByName("anim"):setVisible(true)
                break
            end
        end
    end)

    local bgMove = cc.MoveBy:create(_climbTime, cc.p(0, -self.data.bgSize.height * 0.5))
    self.controls.bg1:runAction(cc.Sequence:create(delayTime:clone(), bgMove:clone()))
    self.controls.bg2:runAction(cc.Sequence:create(delayTime:clone(), bgMove:clone()))
    self.controls.bg3:runAction(cc.Sequence:create(delayTime:clone(), bgMove:clone()))
    local node = cc.Node:create()
    local nodeDelayTime = cc.DelayTime:create(_delayTime + _climbTime)
    node:runAction(cc.Sequence:create(nodeDelayTime, func))
    self:addChild(node)
end

-- 更新楼层数、宝箱图
function TowerLayer:updateFloorInfo(_bg, _floor)
    local bgPanel = _bg
    local box = bgPanel:getChildByTag(BOX_TAG)
    local eff = bgPanel:getChildByTag(EFF_TAG)
    local boxTypeBg = box:getChildByTag(BOX_TYPEBG_TAG)
    local boxTypeSpri = box:getChildByTag(BOX_TYPE_TAG)

    local prevChestRes = ""
    local chestRes = ""
    local isTop = false

    if _floor > 40 then
        isTop = true
    end
    -- 始终保持_floor为奇数
    if (_floor % 2) == 0 then
        _floor = _floor - 1
    end
    if _floor > 39 then
        _floor = 39
    end

    chestRes = BaseConfig.getTower(_floor + 1).Res
    if _floor > 2 then
        prevChestRes = BaseConfig.getTower(_floor - 1).Res
    end

    -- 宝箱状态更新
    if isTop then
        local level1 = bgPanel:getChildByTag(1)
        local level2 = bgPanel:getChildByTag(2)
        level1:setString("40层")
        level2:setString("顶层")
        local path = "image/ui/img/bg/"..chestRes.."_1.png"
        box:setTexture(path)
        eff:setScale(0)
        boxTypeBg:setScale(0)
        boxTypeSpri:setScale(0)
        return
    else
        if "" == prevChestRes then
            box:setScale(0)
            eff:setScale(0)
            boxTypeBg:setScale(0)
            boxTypeSpri:setScale(0)
        else
            box:setScale(1)
            eff:setScale(0)
            boxTypeBg:setScale(0)
            boxTypeSpri:setScale(0)
            local path = "image/ui/img/bg/"..prevChestRes.."_1.png"
            box:setTexture(path)

            box.boxType = prevChestRes
        end
    end
    
    -- level1宝箱(双数)、level2怪(单数)

    -- 楼层号更新
    local level1 = bgPanel:getChildByTag(1)
    local level2 = bgPanel:getChildByTag(2)
    level1:setString((_floor - 1).."层")
    level2:setString(_floor.."层")
    --------------------------------- split line ---------------------------------
    -- 改变下一个背景的层数、宝箱
    local afterTag = bgPanel:getTag() + 10
    local afterbgPanel = self:getChildByTag(afterTag)
    if afterTag > 30 then
        afterbgPanel = self:getChildByTag(BOX_TAG)
    end
    box = afterbgPanel:getChildByTag(BOX_TAG)
    eff = afterbgPanel:getChildByTag(EFF_TAG)
    boxTypeBg = box:getChildByTag(BOX_TYPEBG_TAG)
    boxTypeSpri = box:getChildByTag(BOX_TYPE_TAG)
    box:setScale(1)
    eff:setScale(1)
    boxTypeBg:setScale(1)
    boxTypeSpri:setScale(1)
    local path = "image/ui/img/bg/"..chestRes.."_0.png"
    box:setTexture(path)

    self:updateBoxType(box, self.data.chestTypeTab[math.ceil(_floor / 2)])

    level1 = afterbgPanel:getChildByTag(1)
    level2 = afterbgPanel:getChildByTag(2)
    level1:setString((_floor + 1).."层")
    level2:setString((_floor + 2).."层")
    if (_floor + 2) > 40 then
        afterbgPanel:getChildByName("anim"):setVisible(false)
        level2:setString("顶层")
    end
end

function TowerLayer:createTowerEnemyAnim(enemyID, panel)
    local beforeAnim = panel:getChildByName("anim")
    beforeAnim:removeFromParent()
    beforeAnim = nil
    local scaleConfig = BaseConfig.GetHeroScale(enemyID)
    local heroScale = scaleConfig.ShowScale / 10000
    local enemyAnim = HeroAction.new(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.59, enemyID)
    enemyAnim:setScale(heroScale)
    enemyAnim:addTouchEvent(function()
        if self.data.isCanClickEnemy then
            self.data.isCanClickEnemy = false
            self.data.currClickEnemyPanel = panel
            self:ClickEnemy()
            self.data.currCombatEnemy = enemyAnim
        end
    end)
    enemyAnim:setName("anim")
    panel:addChild(enemyAnim)
end

function TowerLayer:updateBoxType(box, boxType)
    local boxTypeBg = box:getChildByTag(BOX_TYPEBG_TAG)
    local boxTypeSpri = box:getChildByTag(BOX_TYPE_TAG)
    boxTypeSpri:setTexture(boxTypePathTab[boxType])

    boxTypeBg:setScale(1)
    boxTypeSpri:setScale(1)
end

function TowerLayer:battleEndUI(data)
    local sessionID = data.sessionID
    local winHeroList = {}
    local isWin = false

    if data.result == "win" then
        winHeroList = data.climbHero
        --application:showFlashNotice("战斗成功～！！！")
        isWin = true
        Common.playSound("audio/effect/map_battle_win.mp3")
    else
        winHeroList = data.climbEnemy
        --application:showFlashNotice("战斗失败～！！！")
    end

    rpc:call("Tower.EndF", {SessionID = sessionID, IsWin = isWin, RP = data.heroRP, EnemyRP = data.enemyRP, HeroList = winHeroList}, function(event)
        if event.status == Exceptions.Nil then
            self.data.floor = event.result.CurFloor
            self.data.climbTimes = event.result.TotalResetCount - event.result.DailyResetCount
            self.controls.reset:setString("重置("..self.data.climbTimes..")")
        end
    end, {show=false, debug=false, retryOnError = true} )


    local scene = cc.Director:getInstance():getRunningScene()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    scene:addChild(swallowLayer)
    if isWin then
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
        scene:addChild(layer)
        local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
        light:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.73)
        layer:addChild(light)
        local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
        light:runAction(rep)
    
        local sidai = cc.Sprite:create("image/ui/img/bg/bg_160.png")
        sidai:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.73)
        layer:addChild(sidai)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_632.png")
        icon:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8)
        icon:setScale(0.1)
        icon:runAction(cc.Sequence:create({cc.ScaleTo:create(0.2, 1.2),cc.ScaleTo:create(0.05, 1.0)}))
        layer:addChild(icon)

        local bg = cc.Sprite:create("image/ui/img/bg/bg_163.png")
        bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.4)
        layer:addChild(bg)

        local btn = createMixSprite("image/ui/img/btn/btn_553.png")
        btn:setCircleFont("确定", 1, 1, 25, cc.c3b(226,204,169), 1)
        btn:setFontOutline(cc.c4b(65,26,1, 255), 1)
        btn:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.4)
        btn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:EndF(isWin)
            end
        end)
        layer:addChild(btn)
    else
        local layer = require("tool.helper.CommonLayer").BattleFailLayer()
        local btn_back = createMixSprite("image/ui/img/btn/btn_553.png")
        btn_back:setCircleFont("确定", 1, 1, 25, cc.c3b(238, 205, 142), 1)
        btn_back:setFontOutline(cc.c3b(70, 50, 14), 1)
        btn_back:setPosition(SCREEN_WIDTH * 0.85, SCREEN_HEIGHT * 0.3)
        layer:addChild(btn_back)
        btn_back:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:EndF(isWin)
            end
        end)
        scene:addChild(layer)
    end
end

--[[
    对战敌人
]]
function TowerLayer:ClickEnemy()
    rpc:call("Tower.GetFloorInfo", nil, function(event)
        if event.status == Exceptions.Nil then
            self.controls.enemtyPanel:setLocalZOrder(1)
            self.data.floorInfo = event.result
            self:updateEnemyHero()
        end
    end)
end

--[[
    开启箱子
]]
function TowerLayer:ClickChest(box)
    rpc:call("Tower.OpenChest", nil, function(event)
        if event.status == Exceptions.Nil then
            self.data.isCanClickBox = false
            self.data.floor = event.result.CurFloor
            self.data.climbTimes = event.result.TotalResetCount - event.result.DailyResetCount

            local bgPanel = box:getParent()
            self:updateFloorInfo(bgPanel, self.data.floor)

            local function endFunc()
                CCLog("self.data.floor = ", self.data.floor, " isReachTop= ", isReachTop)
                if self.data.floor > 40 then
                    CCLog("================最高层")
                else
                    self:heroRightClimbTowerAction()
                end
            end
            local openList = event.result.OpenList
            local drawList = event.result.DrawList

            local titlePath = nil
            if self.data.floor > 40 then
                titlePath = "image/ui/img/btn/btn_943.png"
            else
                local nplatinaBoxType = 1
                local goldBoxType = nplatinaBoxType + 1
                local boxType = tonumber(string.sub(box.boxType, string.len(box.boxType), string.len(box.boxType)))
                if boxType == nplatinaBoxType then
                    titlePath = "image/ui/img/btn/btn_942.png"
                elseif boxType == goldBoxType then
                    titlePath = "image/ui/img/btn/btn_943.png"
                end
            end
            local alertShow = require("scene.main.ReceiveGoods").new(openList, titlePath, function()
                local drawLayer = require("scene.main.tower.widget.DrawGoods").new(drawList, endFunc)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(drawLayer)
            end)
            self:addChild(alertShow)
        end
    end)
end

function TowerLayer:BeforeF()
    rpc:call("Tower.BeforeF",  { Floor = self.data.floor }, function(event)
        if event.status == Exceptions.Nil then

            local param = {}
            param.sessionID    = event.result.SessionID
            param.attackerForm = event.result.Form

            param.climbHero   = event.result.HeroStatus

            param.battleType   = "Tower"
            param.map          = "TV_map"
            param.callback     = handler(self, self.battleEndUI)
            application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_TOWER, param)
        end
    end)
end

--[[
    医务室信息
]]
function TowerLayer:EnterClinic()
    rpc:call("Tower.Init", nil, function(event)
        if event.status == Exceptions.Nil then
            self.data.clinic = event.result.ClinicSlots or {}
            self.data.RP = event.result.HeroInfo.RP
            self.data.towerHeroList = event.result.HeroInfo.HeroList or {}

            local addBlood = require("scene.main.tower.AddBloodHouse").new(self.data.clinic, self.data.towerHeroList, handler(self, self.ClickSlot))
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(addBlood)
        end
    end)
end

--[[
    重置
]]
function TowerLayer:Reset()
    rpc:call("Tower.Reset", nil, function(event)
        if event.status == Exceptions.Nil then
            self.controls.animation:stopAllActions()
            self.controls.sky:stopAllActions()
            self.controls.bg1:stopAllActions()
            self.controls.bg2:stopAllActions()
            self.controls.bg3:stopAllActions()

            self.controls.enemtyPanel:setLocalZOrder(-1)
            self.data.floor = event.result.CurFloor
            self.data.climbTimes = event.result.TotalResetCount - event.result.DailyResetCount
            self.controls.reset:setString("重置("..self.data.climbTimes..")")
            self.data.towerEnemyAnimIDTab = event.result.Boss
            self.data.chestTypeTab = event.result.Chest

            if self.data.climbTimes > 0 then
                self.controls.reset:setNorGLProgram(true)
                self.controls.reset:setTouchEnable(true)
            else
                self.controls.reset:setNorGLProgram(false)
                self.controls.reset:setTouchEnable(false)
            end

            self.data.isCanClickEnemy = false
            self.data.isCanClickBox = false
            for k,v in pairs(self.data.bgTab) do
                local anim = v:getChildByName("anim")
                anim:setVisible(true)

                v:getChildByTag(EFF_TAG):setScale(1)
                self:updateBoxType(v:getChildByTag(BOX_TAG), self.data.chestTypeTab[math.ceil(self.data.floor / 2)])
            end
            self.controls.bg1:setPosition(self.data.halfScreenWidth, self.data.bgSize.height - SCREEN_HEIGHT)
            self.controls.bg2:setPosition(self.data.halfScreenWidth, self.data.bgSize.height + self.controls.bg1:getPositionY())
            self.controls.bg3:setPosition(self.data.halfScreenWidth, self.data.bgSize.height + self.controls.bg2:getPositionY())

            local enemyAnimID = self.data.towerEnemyAnimIDTab[math.ceil(self.data.floor / 2)]
            self:createTowerEnemyAnim(enemyAnimID, self.controls.bg1)

            self.controls.animation:setPosition(self.data.halfScreenWidth + self.data.bgSize.width * 0.2, self.data.halfScreenHeight - self.data.bgSize.height * 0.2)
            self.controls.animation:setScaleX(-1)
            self:moveToEnemyAction()
            self:updateFloorInfo(self.controls.bg1, self.data.floor)

            application:showFlashNotice("重置成功")
        end
    end)
end

--[[
    移除医疗槽中的星将
]]
function TowerLayer:ClickSlot(slotID, removeFunc)
    rpc:call("Tower.RemoveHeroFromClinic", slotID, function(event)
        if event.result == true then
            removeFunc(slotID)
        end
    end)
end

--[[
    战斗结束
]]
function TowerLayer:EndF(isWin)
    application:popScene()

    if self.data.climbTimes > 0 then
        self.controls.reset:setNorGLProgram(true)
        self.controls.reset:setTouchEnable(true)
    else
        self.controls.reset:setNorGLProgram(false)
        self.controls.reset:setTouchEnable(false)
    end

    self.controls.enemtyPanel:setLocalZOrder(-1)
    if isWin then
        self.data.currCombatEnemy:setVisible(false)
        self.data.isCanClickEnemy = false
        self.data.isCanClickBox = false
        self.controls.animation:setPositionX(self.data.halfScreenWidth + self.data.bgSize.width * 0.12)
        self:heroLeftClimbTowerAction()

        if self.data.floor == 40 then
            for k,v in pairs(self.data.bgTab) do
                local anim = v:getChildByName("anim")
                anim:setVisible(false)
            end
            return 
        end

        local currBgTag = self.data.currClickEnemyPanel:getTag()
        local nextBgTag = currBgTag + 10
        local bgPanel = nil
        if nextBgTag > 30 then
            bgPanel = self:getChildByTag(bg1PanelTag)
        else
            bgPanel = self:getChildByTag(nextBgTag)
        end

        local enemyAnimID = self.data.towerEnemyAnimIDTab[1 + math.ceil(self.data.floor / 2)]
        self:createTowerEnemyAnim(enemyAnimID, bgPanel)
    else
        self.data.isCanClickEnemy = true
    end
end

function TowerLayer:receiveGoodsPanel()
    local node = require("scene.main.ReceiveGoods")


    return node
end

function TowerLayer:onEnterTransitionFinish( )
    Common.OpenSystemLayer({11})
    TowerLayer.super.onEnterTransitionFinish(self)
    
end

return TowerLayer
