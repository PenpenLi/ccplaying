local BuildNode = class("BuildNode", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    return node
end)

-- 建筑编号
BuildNode.ExchangeBuildNumber = 1
BuildNode.DecorationBuildNumber = 2
BuildNode.PillBuildNumber = 3
BuildNode.WoodBuildNumber = 4
BuildNode.MetalBuildNumber = 5
BuildNode.HeroSoulBuildNumber = 6

local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

-- topNode (使建筑的某些节点处于UI最顶层)
function BuildNode:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildNumber = number
    self.data.buildInfo = buildInfo
    self.data.isOwnHome = isOwnHome
    self.controls.topNode = topNode

    self.data.isSettleBuildPanel = false
    self.data.isUpgradeing = false
    self.data.isCollecting = false
    self.data.isAtked = true -- 是否能被掠夺
    self:createBuild()
    self.data.firstPanelSpriTab = {{"image/ui/img/btn/btn_1223.png", "image/ui/img/btn/btn_1228.png"},
                                    {"image/ui/img/btn/btn_1224.png", "image/ui/img/btn/btn_1229.png"},
                                    {"image/ui/img/btn/btn_1222.png", "image/ui/img/btn/btn_1227.png"},
                                    {"image/ui/img/btn/btn_1221.png", "image/ui/img/btn/btn_1226.png"}}
end

function BuildNode.createNode(number, buildInfo, isOwnHome, topNode)
    if number == BuildNode.ExchangeBuildNumber then
        return require("scene.main.home.widget.ExchangeBuild").new(number, buildInfo.Decoration, isOwnHome, topNode)
    elseif number == BuildNode.DecorationBuildNumber then
        return require("scene.main.home.widget.DecorationBuild").new(number, buildInfo.Decoration, isOwnHome, topNode)
    elseif number == BuildNode.PillBuildNumber then
        return require("scene.main.home.widget.PillBuild").new(number, buildInfo.PillFactory, isOwnHome, topNode)
    elseif number == BuildNode.WoodBuildNumber then
        return require("scene.main.home.widget.WoodBuild").new(number, buildInfo.WoodFactory, isOwnHome, topNode)
    elseif number == BuildNode.MetalBuildNumber then
        return require("scene.main.home.widget.MetalBuild").new(number, buildInfo.MetalFactory, isOwnHome, topNode)
    elseif number == BuildNode.HeroSoulBuildNumber then
        return require("scene.main.home.widget.HeroSoulBuild").new(number, buildInfo.SoulFactory, isOwnHome, topNode)
    end
end

function BuildNode:createBuild()
    local path = self:changeBuildPath(self.data.buildNumber, self.data.buildInfo.Level)
    self.controls.build = createMixSprite(path)
    self.controls.build:setAnchorPoint(0.5, 0)
    self:addChild(self.controls.build)
    self.controls.build:setScale(0)
    self.controls.build:addTouchEventListener(function(sender, eventType)
        if (eventType == ccui.TouchEventType.ended) then
            application:dispatchCustomEvent(AppEvent.UI.Home.SyncHomeData, {TouchEvent = handler(self, self.buildFunc)})
        end
    end)
    self.data.buildSize = self.controls.build:getContentSize()

    local scale1 = cc.ScaleTo:create(0.1, 1.2, 0)
    local scale2 = cc.ScaleTo:create(0.2, 0.5, 1.5)
    local scale3 = cc.ScaleTo:create(0.1, 1.2, 0.8)
    local scale4 = cc.ScaleTo:create(0.08, 1, 1)
    local func = cc.CallFunc:create(function()
        self:createBuildAccessory()
        self:updateBuild()
    end)
    self.controls.build:runAction(cc.Sequence:create(scale1, scale2, scale3, scale4, func))
end

function BuildNode:changeBuildPath(buildNumber, level)
    if self.ExchangeBuildNumber == buildNumber then
        return "image/ui/img/btn/btn_1231.png"
    end
    local num = math.floor(level / 10)
    num = ((num + 1) > 3) and 3 or (num + 1)

    local path = nil
    if self.HeroSoulBuildNumber == buildNumber then
        path = string.format("image/ui/img/btn/btn_%4d.png", 1347 + num)
    else
        if num == 1 then
            path = string.format("image/ui/img/btn/btn_%4d.png", 1230 + buildNumber)
        elseif num == 2 then
            path = string.format("image/ui/img/btn/btn_%4d.png", 1299 + buildNumber)
        elseif num == 3 then
            path = string.format("image/ui/img/btn/btn_%4d.png", 1303 + buildNumber)
        end
    end
    return path
end

function BuildNode:createBuildAccessory()
    self.controls.scrollBar_capacity = require("scene.main.home.widget.ScrollLoadingBar")
                                        .new("image/ui/img/btn/btn_1114.png", "image/ui/img/btn/btn_1113.png", "image/ui/img/btn/btn_1112.png")
    self.controls.scrollBar_capacity:setPosition(-self.data.buildSize.width * 0.3, self.data.buildSize.height * 0.02)
    self:addChild(self.controls.scrollBar_capacity)
    local barSize = self.controls.scrollBar_capacity:getContentSize()
    self.controls.scrollBarBg = cc.Sprite:create("image/ui/img/btn/btn_1117.png")
    self:addChild(self.controls.scrollBarBg)
    self.controls.scrollBarBg:setPosition(-self.data.buildSize.width * 0.3 + barSize.width * 0.5, 
                                        self.data.buildSize.height * 0.02 + barSize.height * 0.5)
    local LevelBg = cc.Sprite:create("image/ui/img/btn/btn_303.png")
    LevelBg:setPosition(-60, self.data.buildSize.height * 0.26)
    self:addChild(LevelBg)
    self.controls.scrollBarCapacity = cc.Sprite:create("image/ui/img/btn/btn_1115.png")
    self.controls.scrollBarCapacity:setPosition(-self.data.buildSize.width * 0.3, 
                                            self.data.buildSize.height * 0.02 + barSize.height * 0.5)
    self:addChild(self.controls.scrollBarCapacity)

    self.controls.buildUpgradeTimebg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1120.png")
    self.controls.buildUpgradeTimebg:setContentSize(cc.size(120, 20))
    self.controls.buildUpgradeTimebg:setPosition(0, self.data.buildSize.height * 0.5)
    self:addChild(self.controls.buildUpgradeTimebg)
    self.controls.buildUpgradeTimeClock = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
    self.controls.buildUpgradeTimeClock:setPosition(-40, self.data.buildSize.height * 0.51)
    self:addChild(self.controls.buildUpgradeTimeClock)
    self.controls.buildUpgradeCD = Common.finalFont("", 0, 0, 20)
    self.controls.buildUpgradeCD:setPosition(20, self.data.buildSize.height * 0.5)
    self:addChild(self.controls.buildUpgradeCD)
    self.controls.buildUpgradeTimeHammer = cc.Sprite:create("image/ui/img/btn/btn_1124.png")
    self.controls.buildUpgradeTimeHammer:setAnchorPoint(0.5, 0)
    self.controls.buildUpgradeTimeHammer:setPosition(20, self.data.buildSize.height * 0.7)
    self:addChild(self.controls.buildUpgradeTimeHammer)
    local rotate1 = cc.RotateTo:create(0.2, -90)
    local rotate2 = cc.RotateTo:create(0.5, 0)
    local seq = cc.Sequence:create(rotate1, rotate2)
    local rep = cc.RepeatForever:create(seq)
    self.controls.buildUpgradeTimeHammer:runAction(rep)
    self:setBuildUpgradeTimeVisible(false)
    
    self.controls.buildLevel = Common.finalFont("", 1, 1, 25, cc.c3b(197,255,72), 1)
    self.controls.buildLevel:setAdditionalKerning(-2)
    LevelBg:addChild(self.controls.buildLevel)
    self.controls.buildLevel:setPosition(LevelBg:getContentSize().width* 0.5, LevelBg:getContentSize().height * 0.5)

    self.controls.buildName = Common.finalFont("", 1, 1, 20, cc.c3b(80, 253, 255), 1)
    self.controls.buildName:setAdditionalKerning(-2)
    self:addChild(self.controls.buildName)
    self.controls.buildName:setPosition(10, self.data.buildSize.height * 0.25)

    self.controls.canUpgradePanel = createMixSprite("image/ui/img/btn/btn_1062.png", nil, "image/ui/img/btn/btn_634.png")
    self.controls.canUpgradePanel:setSwallowTouches(true)
    local child = self.controls.canUpgradePanel:getChild()
    child:setScale(0.7)
    self.controls.canUpgradePanel:setChildPos(0.5, 0.55)
    self.controls.canUpgradePanel:setPosition(self:getPositionX(), self:getPositionY() + self.data.buildSize.height)
    self.controls.topNode:addChild(self.controls.canUpgradePanel)
    self.controls.canUpgradePanel:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            self:upgradePanel()
        end
    end)
    self.controls.canUpgradePanel:setVisible(false)

    self.controls.canCollect = createMixSprite("image/ui/img/btn/btn_1062.png", nil, "image/ui/img/btn/btn_1115.png")
    local child = self.controls.canCollect:getChild()
    child:setScale(0.7)
    self.controls.canCollect:setChildPos(0.5, 0.55)
    self.controls.canCollect:setPosition(self:getPositionX(), self:getPositionY() + self.data.buildSize.height)
    self.controls.topNode:addChild(self.controls.canCollect)
    self.controls.canCollect:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            self.controls.canCollect:setSwallowTouches(false)
            self.controls.canCollect:setVisible(false)
            self.controls.canCollect:setTouchEnable(false)
            self:collect()
        end
    end)
    self.controls.canCollect:setSwallowTouches(false)
    self.controls.canCollect:setVisible(false)
    self.controls.canCollect:setTouchEnable(false)

    local move = cc.MoveBy:create(1, cc.p(0, 10))
    local move_reverse = move:reverse()
    local seq = cc.Sequence:create(move, move_reverse)
    local rep = cc.RepeatForever:create(seq)
    self.controls.canUpgradePanel:runAction(rep)
    self.controls.canCollect:runAction(rep:clone())
end

-- 用于区别建筑和兑换商店
function BuildNode:buildFunc()
    if self.data.isOwnHome then
        if self.data.buildInfo.UpgradeCD > 0 then
            application:showFlashNotice("建筑正在升级中~!")
        else
            self:syncHomeData(function()
                self.data.isSettleBuildPanel = true
                self:buildFirstPanel()
            end)
        end
    else
        if self.data.isAtked then
            local choosePanel = self:enemyBuildChoosePanel()
            choosePanel:setPosition(self:getPositionX(), self:getPositionY() + self.data.buildSize.height)
            self.controls.topNode:addChild(choosePanel)
        else
            application:showFlashNotice("不能再次掠夺~!")
        end
    end
end

function BuildNode:buildFirstPanel(offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local node = cc.Node:create()
    node:setPosition(self:getPositionX() - 30, self:getPositionY() + self.data.buildSize.height * 0.8)
    self.controls.topNode:addChild(node)
    local function closePanel()
        if self.controls.panelTime then
            self.controls.panelTime:removeFromParent()
            self.controls.panelTime = nil
        end
        node:removeFromParent()
        node = nil
        self.data.isSettleBuildPanel = false
        self:syncHomeData()
    end
    local bg = cc.Sprite:create("image/ui/img/btn/btn_1090.png")
    bg:setPosition(offsetX, offsetY)
    node:addChild(bg)
    bg:setScale(0)
    local bgSize = bg:getContentSize()

    local bgbg = cc.Sprite:create("image/ui/img/btn/btn_009.png")
    bgbg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    bg:addChild(bgbg, -1)

    local centerSpri = createMixSprite("image/ui/img/btn/btn_551.png", nil, self.data.firstPanelCenterSpri)
    centerSpri:getBg():setOpacity(150)
    centerSpri:setTouchEnable(false)
    centerSpri:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    bg:addChild(centerSpri)

    self.data.firstPanelBtnTab = {}
    local posTab = {{bgSize.width * 0.1, bgSize.height * 0.8},
                        {bgSize.width * 0.85, bgSize.height * 0.8},
                        {bgSize.width * 0.85, bgSize.height * 0.2},
                        {bgSize.width * 0.1, bgSize.height * 0.2}}
    local scale1 = cc.ScaleTo:create(0.08, 1.2)
    local scale2 = cc.ScaleTo:create(0.08, 0.9)
    local scale3 = cc.ScaleTo:create(0.05, 1.1)
    local scale4 = cc.ScaleTo:create(0.05, 1)
    bg:runAction(cc.Sequence:create(scale1, scale2, scale3, scale4, cc.CallFunc:create(function()
        for k,v in pairs(self.data.firstPanelSpriTab) do
            local btn = createMixSprite(v[1], nil, v[2])
            btn:setButtonBounce(false)
            btn:setChildPos(0.5, 0)
            btn:setPosition(posTab[k][1], posTab[k][2])
            bg:addChild(btn)
            self.data.firstPanelBtnTab[k] = btn
            btn:addTouchEventListener(function(sender, eventType, inside)
                if (eventType == ccui.TouchEventType.ended) and inside then
                    closePanel()
                    if k == 1 then
                        --收获/外观/培育
                        self:firstPanelButtonFunc()
                    elseif k == 2 then
                        --详情
                        self:buildDetailPanel()
                    elseif k == 3 then
                        --防守
                        local buildNumber = self.data.buildNumber
                        local getFormCallback = function(event)
                            if event.status == Exceptions.Nil then
                                local params = {
                                    attackerForm = event.result.Form,
                                    excludeList = event.result.ExcludeList,
                                    buildNumber = buildNumber,
                                    buildName = self.data.buildName, 
                                    heroLimit = {maxNumber = self.data.buildConfig.HeroNum, enableFairy = false},
                                    map = nil,
                                    callback = handler(self, self.syncHomeData),
                                }

                                application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_HOME_DEFENSE, params)
                            end
                        end   
                        rpc:call("Home.GetDefFormation",  buildNumber, getFormCallback)
                    elseif k == 4 then
                        --升级
                        self:upgradePanel()
                    end
                end
            end)

            btn:setScale(0)
            -- 等级达到最大时，按钮置灰
            if (k == 4) and (self.data.buildInfo.Level >= self.data.maxLevel) then
                btn:setNorGLProgram(false)
                btn:setTouchEnable(false)
            end
            local delay = cc.DelayTime:create((k - 1) * 0.1)
            btn:runAction(cc.Sequence:create(delay, scale1:clone(), scale2:clone(), 
                                            scale3:clone(), scale4:clone(), cc.CallFunc:create(function()
                if k == (#self.data.firstPanelSpriTab) then
                    if self.data.buildInfo.Level < self.data.maxLevel then
                        local upgradeCostSpri = cc.Sprite:create("image/ui/img/btn/btn_1109.png")
                        upgradeCostSpri:setPosition(bgSize.width * 0.05, -bgSize.height * 0.05)
                        bg:addChild(upgradeCostSpri)
                        upgradeCostSpri:setScale(0.5)
                        local woodCost = self.data.buildConfig.UpgradeCost
                        local fontColor = cc.c3b(255, 255, 255)
                        if GameCache.Avatar.Wood < woodCost then
                            fontColor = cc.c3b(255, 0, 0)
                        end
                        local upgradeCost = Common.finalFont(woodCost, 1, 1, 20, fontColor, 1)
                        upgradeCost:setAnchorPoint(0, 0.5)
                        upgradeCost:setPosition(bgSize.width * 0.12, -bgSize.height * 0.05)
                        bg:addChild(upgradeCost)
                    else
                        local upgradeDesc = Common.finalFont("已满级", 1, 1, 20, cc.c3b(255, 255, 0), 1)
                        upgradeDesc:setAdditionalKerning(-2)
                        upgradeDesc:setPosition(bgSize.width * 0.1, -bgSize.height * 0.05)
                        bg:addChild(upgradeDesc)
                    end

                    local defTfp = require("tool.helper.CalHeroAttr").FormTFP(self.data.buildInfo.DefForm)
                    local defTfpLab = Common.finalFont(defTfp, 1, 1, 20, cc.c3b(0, 255, 0), 1)
                    defTfpLab:setPosition(bgSize.width * 0.85, -bgSize.height * 0.05)
                    bg:addChild(defTfpLab)
                end
            end)))
        end
    end)))


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            closePanel()
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    self:firstPanelCollectTime(bg, bgSize)
end

function BuildNode:firstPanelCollectTime(bg, bgSize)
    self.controls.panelTime = Common.finalFont("", bgSize.width * 0.12, bgSize.height * 0.75, 20, nil, 1)
    bg:addChild(self.controls.panelTime, 1)
end

function BuildNode:buildDetailPanel()
    local node = cc.Node:create()
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)

    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(650, 420))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(panel)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.97)
    panel:addChild(title)

    local buildName = Common.finalFont(self.data.buildName, panelSize.width * 0.5, panelSize.height * 0.97, 25, cc.c3b(248, 255, 171), 1)
    buildName:setAdditionalKerning(-2)
    panel:addChild(buildName)

    local path = self:changeBuildPath(self.data.buildNumber, self.data.buildInfo.Level)
    local buildSpri = cc.Sprite:create(path)
    buildSpri:setPosition(panelSize.width * 0.2, panelSize.height * 0.65)
    panel:addChild(buildSpri)
    local buildLevel = ColorLabel.new("[248, 255, 171]等级: [=][1, 241, 0]"..self.data.buildInfo.Level.."级[=]")
    buildLevel:setAdditionalKerning(-2)
    buildLevel:setPosition(panelSize.width * 0.18, panelSize.height * 0.4)
    panel:addChild(buildLevel)

    local descBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_811.png")
    descBg:setContentSize(cc.size(panelSize.width, 100))
    descBg:setPosition(panelSize.width * 0.5, panelSize.height * 0.155)
    panel:addChild(descBg)
    local buildDesc = ColorLabel.new("", 20, 21)
    buildDesc:setAdditionalKerning(-2)
    buildDesc:setPosition(panelSize.width * 0.5, panelSize.height * 0.155)
    panel:addChild(buildDesc)
    buildDesc:setString("[248, 255, 171]"..self.data.buildDesc.."[=]")


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            self:syncHomeData()
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

    self:buildDetailPanel2(panel, panelSize)
end

function BuildNode:buildDetailPanel2(panel, panelSize, collectTime)
    local produceHour = Common.finalFont("每小时产量:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    produceHour:setAdditionalKerning(-2)
    produceHour:setAnchorPoint(0, 0.5)
    produceHour:setPosition(panelSize.width * 0.48, panelSize.height * 0.8)
    panel:addChild(produceHour)
    local vip_privilege = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP)
    local value = math.floor(self.data.buildConfig.Produce * (vip_privilege.IncrHomeGain / 100))
    local produce = ColorLabel.new("", 22)
    produce:setAnchorPoint(0, 0.5)
    produce:setPosition(panelSize.width * 0.66, panelSize.height * 0.8)
    panel:addChild(produce)
    if value > 0 then
        produce:setString("[1, 241, 0]"..self.data.buildConfig.Produce.."[=][255,201,60]+"..value.."(VIP)[=]")
    else
        produce:setString("[1, 241, 0]"..self.data.buildConfig.Produce.."[=]")
    end

    local capacitySpri = cc.Sprite:create("image/ui/img/btn/btn_1115.png")
    capacitySpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.68)
    panel:addChild(capacitySpri)
    capacitySpri:setScale(0.9)
    local capacityBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    capacityBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.68)
    panel:addChild(capacityBg)
    local bar_capacity = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_capacity:setPosition(panelSize.width * 0.68, panelSize.height * 0.68)
    panel:addChild(bar_capacity)
    bar_capacity:setPercent((self.data.buildInfo.Capacity / self.data.buildConfig.Capacity) * 100)
    local capacityDesc = Common.finalFont("本厂容量:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    capacityDesc:setAdditionalKerning(-2)
    capacityDesc:setAnchorPoint(0, 0.5)
    capacityDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.7)
    panel:addChild(capacityDesc)
    local capacity = Common.finalFont(self.data.buildInfo.Capacity.."/"..self.data.buildConfig.Capacity, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    capacity:setAnchorPoint(0, 0.5)
    capacity:setPosition(panelSize.width * 0.64, panelSize.height * 0.7)
    panel:addChild(capacity)

    local defSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    defSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.56)
    panel:addChild(defSpri)
    defSpri:setScale(0.5)
    local defHeroNumDesc = Common.finalFont("防守星将:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defHeroNumDesc:setAdditionalKerning(-2)
    defHeroNumDesc:setAnchorPoint(0, 0.5)
    defHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.56)
    panel:addChild(defHeroNumDesc)
    local defNum = 0
    if self.data.buildInfo.DefForm.Hero then
        defNum = #self.data.buildInfo.DefForm.Hero
    end
    local defHomeNum = Common.finalFont(defNum.."/"..self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defHomeNum:setAnchorPoint(0, 0.5)
    defHomeNum:setPosition(panelSize.width * 0.61, panelSize.height * 0.56)
    panel:addChild(defHomeNum)

    local defTfpDesc = Common.finalFont("当前防御力:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defTfpDesc:setAdditionalKerning(-2)
    defTfpDesc:setAnchorPoint(0, 0.5)
    defTfpDesc:setPosition(panelSize.width * 0.68, panelSize.height * 0.56)
    panel:addChild(defTfpDesc)
    local defTfpValue = require("tool.helper.CalHeroAttr").FormTFP(self.data.buildInfo.DefForm)
    local defTfp = Common.finalFont(defTfpValue, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defTfp:setAnchorPoint(0, 0.5)
    defTfp:setPosition(panelSize.width * 0.84, panelSize.height * 0.56)
    panel:addChild(defTfp)

    local clockSpri = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
    clockSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.44)
    panel:addChild(clockSpri)
    local collectTimeLab = Common.finalFont("收获时间: "..collectTime.."小时/次" , 1, 1, 18, cc.c3b(150,150,109), 1)
    collectTimeLab:setAdditionalKerning(-2)
    collectTimeLab:setAnchorPoint(0, 0.5)
    collectTimeLab:setPosition(panelSize.width * 0.48, panelSize.height * 0.44)
    panel:addChild(collectTimeLab)
    
end

function BuildNode:upgradePanel()
    local node = cc.Node:create()
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,100), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(650, 420))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(panel)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.97)
    panel:addChild(title)
    local up = cc.Sprite:create("image/ui/img/btn/btn_634.png")
    up:setPosition(panelSize.width * 0.42, panelSize.height)
    panel:addChild(up)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.56, panelSize.height * 0.97)
    panel:addChild(dian)

    local path = self:changeBuildPath(self.data.buildNumber, self.data.buildInfo.Level)
    local buildSpri = cc.Sprite:create(path)
    buildSpri:setPosition(panelSize.width * 0.2, panelSize.height * 0.65)
    panel:addChild(buildSpri)
    local upgradeLevelLab = ColorLabel.new("", 22)
    upgradeLevelLab:setPosition(panelSize.width * 0.18, panelSize.height * 0.4)
    panel:addChild(upgradeLevelLab)
    upgradeLevelLab:setString("[255,255,255]等级:[=][0,255,0]"..self.data.buildInfo.Level.."级->"..(self.data.buildInfo.Level + 1).."级[=]")
    local upgradeSpri = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeSpri:setPosition(panelSize.width * 0.36, panelSize.height * 0.4)
    panel:addChild(upgradeSpri)

    local descBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_811.png")
    descBg:setContentSize(cc.size(panelSize.width, 100))
    descBg:setPosition(panelSize.width * 0.5, panelSize.height * 0.155)
    panel:addChild(descBg)

    local upgradeCost = self.data.buildConfig.UpgradeCost
    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_1109.png", cc.size(160, 60))
    btn_sure:getChild():setScale(0.5)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setChildPos(0.25, 0.5)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.15)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.buildInfo.UpgradeCD > 0 then
                application:showFlashNotice("建筑正在升级中~")
            else
                if GameCache.Avatar.Wood >= upgradeCost then
                    if GameCache.Avatar.Level >= self.data.buildConfig.AvtLevel then
                        self:upgradeBuild()
                        node:removeFromParent()
                        node = nil
                    else
                        application:showFlashNotice("玩家等级不够~")
                    end
                else
                    application:showFlashNotice("木料不足，请凑够了再来吧~")
                end
            end
        end
    end)

    local fontColor = cc.c3b(0, 255, 0)
    if GameCache.Avatar.Wood < upgradeCost then
        fontColor = cc.c3b(255, 0, 0)
    end
    local cost = Common.finalFont(upgradeCost, 1, 1, 22, fontColor, 1)
    cost:setPosition(15, 0)
    btn_sure:addChild(cost)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            self:syncHomeData()
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

    self:upgradeDetailPanel(panel, panelSize)
end

function BuildNode:upgradeDetailPanel(panel, panelSize, afterConfig)
    local produceBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    produceBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.78)
    panel:addChild(produceBg)
    local bar_produce = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_produce:setPosition(panelSize.width * 0.68, panelSize.height * 0.78)
    panel:addChild(bar_produce)
    bar_produce:setPercent(100)
    local produceDesc = Common.finalFont("每小时产量:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    produceDesc:setAdditionalKerning(-2)
    produceDesc:setAnchorPoint(0, 0.5)
    produceDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.8)
    panel:addChild(produceDesc)
    local produce = Common.finalFont(self.data.buildConfig.Produce, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    produce:setAnchorPoint(0, 0.5)
    produce:setPosition(panelSize.width * 0.66, panelSize.height * 0.8)
    panel:addChild(produce)
    local afterproduce = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    afterproduce:setAnchorPoint(0, 0.5)
    panel:addChild(afterproduce)
    local upgradeproduce = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeproduce:setPosition(panelSize.width * 0.92, panelSize.height * 0.8)
    panel:addChild(upgradeproduce)

    local capacitySpri = cc.Sprite:create("image/ui/img/btn/btn_1115.png")
    capacitySpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.63)
    panel:addChild(capacitySpri)
    capacitySpri:setScale(0.9)
    local capacityBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    capacityBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.63)
    panel:addChild(capacityBg)
    local bar_capacity = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_capacity:setPosition(panelSize.width * 0.68, panelSize.height * 0.63)
    panel:addChild(bar_capacity)
    bar_capacity:setPercent(100)
    local capacityDesc = Common.finalFont("容量:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    capacityDesc:setAdditionalKerning(-2)
    capacityDesc:setAnchorPoint(0, 0.5)
    capacityDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.65)
    panel:addChild(capacityDesc)
    local capacity = Common.finalFont(self.data.buildConfig.Capacity, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    capacity:setAnchorPoint(0, 0.5)
    capacity:setPosition(panelSize.width * 0.58, panelSize.height * 0.65)
    panel:addChild(capacity)
    local aftercapacity = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    aftercapacity:setAnchorPoint(0, 0.5)
    panel:addChild(aftercapacity)
    local upgradecapacity = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradecapacity:setPosition(panelSize.width * 0.92, panelSize.height * 0.65)
    panel:addChild(upgradecapacity)

    local defSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    defSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.48)
    panel:addChild(defSpri)
    defSpri:setScale(0.5)
    local defHeroNumBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    defHeroNumBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.48)
    panel:addChild(defHeroNumBg)
    local bar_defHeroNum = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_defHeroNum:setPosition(panelSize.width * 0.68, panelSize.height * 0.48)
    bar_defHeroNum:setPercent(50)
    panel:addChild(bar_defHeroNum)
    local defHeroNumDesc = Common.finalFont("防守星将:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defHeroNumDesc:setAdditionalKerning(-2)
    defHeroNumDesc:setAnchorPoint(0, 0.5)
    defHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.5)
    panel:addChild(defHeroNumDesc)
    local defHeroNum = Common.finalFont(self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defHeroNum:setAnchorPoint(0, 0.5)
    defHeroNum:setPosition(panelSize.width * 0.64, panelSize.height * 0.5)
    panel:addChild(defHeroNum)
    local afterDefHeroNum = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    afterDefHeroNum:setAnchorPoint(0, 0.5)
    panel:addChild(afterDefHeroNum)
    local upgradedef = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradedef:setPosition(panelSize.width * 0.92, panelSize.height * 0.5)
    panel:addChild(upgradedef)

    if self.data.buildInfo.Level < self.data.maxLevel then
        local currConfig = self.data.buildConfig
        bar_produce:setPercent((currConfig.Produce / afterConfig.Produce) * 100)
        produce:setString(currConfig.Produce)
        afterproduce:setString("+"..(afterConfig.Produce - currConfig.Produce))
        afterproduce:setPosition(produce:getPositionX() + produce:getContentSize().width + 10, 
                                panelSize.height * 0.8)
        if (afterConfig.Produce - currConfig.Produce) > 0 then
            upgradeproduce:setScale(1)
        else
            upgradeproduce:setScale(0)
        end

        bar_capacity:setPercent((currConfig.Capacity / afterConfig.Capacity) * 100)
        capacity:setString(currConfig.Capacity)
        aftercapacity:setString("+"..(afterConfig.Capacity - currConfig.Capacity))
        aftercapacity:setPosition(capacity:getPositionX() + capacity:getContentSize().width + 10, 
                                 panelSize.height * 0.65)
        if (afterConfig.Capacity - currConfig.Capacity) > 0 then
            upgradecapacity:setScale(1)
        else
            upgradecapacity:setScale(0)
        end

        bar_defHeroNum:setPercent((currConfig.HeroNum / afterConfig.HeroNum) * 100)
        defHeroNum:setString(currConfig.HeroNum) 
        afterDefHeroNum:setString("+"..(afterConfig.HeroNum - currConfig.HeroNum))
        afterDefHeroNum:setPosition(defHeroNum:getPositionX() + defHeroNum:getContentSize().width + 10, 
                                panelSize.height * 0.5)
        if (afterConfig.HeroNum - currConfig.HeroNum) > 0 then
            upgradedef:setScale(1)
        else
            upgradedef:setScale(0)
        end
    else
        bar_produce:setPercent(100)
        produce:setString(self.data.buildConfig.Produce)
        upgradeproduce:setScale(0)
        bar_capacity:setPercent(100)
        capacity:setString(self.data.buildConfig.Capacity)
        upgradecapacity:setScale(0)
        bar_defHeroNum:setPercent(100)
        afterDefHeroNum:setString(self.data.buildConfig.HeroNum)
        upgradedef:setScale(0)
    end
end

-- 用来区分收获和外观功能
function BuildNode:firstPanelButtonFunc()
    self:collect()
end

function BuildNode:enemyBuildChoosePanel()
    local panel = cc.Sprite:create("image/ui/img/btn/btn_1062.png")
    panel:setOpacity(0)
    local panelSize = panel:getContentSize()

    local function btnFunc(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            if GameCache.Avatar.Endurance < 2 then
                require("tool.helper.CommonLayer").NeedEndurance()
            else
                CCLog('===========掠夺=============')
                panel:removeFromParent()
                panel = nil
                
                local lootMaps = {"JY_map", "JY_2_map"}
                local lootMapID = math.random(1, 2) 
                local beforeFCallback = function(event)
                    if event.status == Exceptions.Nil then
                        local params = {
                            sessionID = event.result.SessionID,
                            attackerForm = event.result.Form,
                            turretID = GameCache.Avatar.enemyHomeInfo.turretID, 
                            turretNum = GameCache.Avatar.enemyHomeInfo.turretNum,
                            turretPower = self.data.buildInfo.Level,
                            --buildName = self.data.buildName, 
                            heroLimit = {maxNumber = GameCache.Avatar.homeInfo.atkHeroNum},
                            battleType = "PVP",
                            map = lootMaps[lootMapID],
                            callback = handler(self, self.battleEnd),
                        }
                        application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = true})
                        application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_HOME, params)
                    end
                end   
                rpc:call("Home.BeforeF",  { LootSession = self.data.lootSession, Target = self.data.buildNumber}, beforeFCallback)
            end
        end
    end

    local btn_loot = createMixSprite("image/ui/img/btn/btn_1062.png", nil, "image/ui/img/btn/btn_1065.png")
    btn_loot:setButtonBounce(false)
    btn_loot:setChildPos(0.5, 0.65)
    btn_loot:setPosition(panelSize.width * 0.5, panelSize.height * 0.5)
    panel:addChild(btn_loot)
    btn_loot:addTouchEventListener(btnFunc)
    local lootFont = cc.Sprite:create("image/ui/img/btn/btn_1257.png")
    lootFont:setPosition(0, -18)
    btn_loot:addChild(lootFont)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            panel:removeFromParent()
            panel = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    return panel
end

function BuildNode:setGetBtnIsTouchEnabled(visible)
    if self.data.firstPanelBtnTab[1] then
        self.data.firstPanelBtnTab[1]:setNorGLProgram(visible)
        self.data.firstPanelBtnTab[1]:setTouchEnable(visible)
    end
end

function BuildNode:setBuildUpgradeTimeVisible(visible)
    self.controls.buildUpgradeTimebg:setVisible(visible)
    self.controls.buildUpgradeTimeClock:setVisible(visible)
    self.controls.buildUpgradeTimeHammer:setVisible(visible)
    self.controls.buildUpgradeCD:setVisible(visible)
end

function BuildNode:syncHomeData(callFunc)
    application:dispatchCustomEvent(AppEvent.UI.Home.SyncHomeData, {IsSync = true, CallFunc = callFunc})
end

function BuildNode:updateBuildInfo(buildInfo)
    self.data.buildInfo = buildInfo
end

function BuildNode:updateBuild()
    if self.data.buildInfo.UpgradeCD > 0 then
        self.data.isUpgradeing = true
    else
        self.data.isUpgradeing = false
        self:setBuildUpgradeTimeVisible(false)
    end
    if self.data.buildInfo.CollectCD then
        self.data.isCollecting = true
    end
    self.controls.buildLevel:setString(self.data.buildInfo.Level)
    self.controls.buildName:setString(self.data.buildName)
    self.controls.canUpgradePanel:setVisible(self:isCanUpgrade())
    self.controls.canUpgradePanel:setTouchEnable(self:isCanUpgrade())
    self.controls.canUpgradePanel:setSwallowTouches(self:isCanUpgrade())
    if not self.data.isOwnHome then
        self.controls.scrollBar_capacity:setIsScroll(false) 
    end
end

function BuildNode:isCanUpgrade()
    if not self.data.isOwnHome then
        return false
    end

    if (self.data.maxLevel) and (self.data.buildInfo.Level >= self.data.maxLevel) then
        return false
    end

    local buildConfig = self.data.buildConfig
    if self.data.buildInfo.UpgradeCD <= 0 then
        if (GameCache.Avatar.Level >= buildConfig.AvtLevel) and 
            (GameCache.Avatar.Wood >= buildConfig.UpgradeCost) then
            if self:isCanCollect() then
                return false
            else
                return true
            end
        else
            return false
        end
    else
        return false
    end
end

function BuildNode:isCanCollect()
    if not self.data.isOwnHome then
        return false
    end
    if (self.data.buildInfo.Capacity > 0) and (self.data.buildInfo.CollectCD == 0) 
        and (self.data.buildInfo.UpgradeCD == 0) then
        return true
    else
        return false
    end
end

function BuildNode:isSettleBuildPanel()
    return self.data.isSettleBuildPanel
end

function BuildNode:guardHeroNum(level)
    local openNum = math.floor(level/10)
    if level >= 5 and level < 20 then openNum = 1 end
    if openNum > 5 then openNum = 5 end
    return openNum
end

function BuildNode:showTime(dt)
    if self.data.isUpgradeing then
        self.data.buildInfo.UpgradeCD = self.data.buildInfo.UpgradeCD - dt
        local time = Common.timeFormat(self.data.buildInfo.UpgradeCD)
        self.controls.buildUpgradeCD:setString(time)
        if self.data.buildInfo.UpgradeCD > 0 then
            self:setBuildUpgradeTimeVisible(true)
        else
            self:setBuildUpgradeTimeVisible(false)
            self.data.isUpgradeing = false
            self:syncHomeData(function()
                Common.playSound("audio/effect/home_levelup.mp3")
                local buildPath = self:changeBuildPath(self.data.buildNumber, self.data.buildInfo.Level)
                self.controls.build:setTexture(buildPath)
                application:showFlashNotice("升级成功~!")
                self.controls.build:setScale(0)
                local scale1 = cc.ScaleTo:create(0.1, 1.2, 0)
                local scale2 = cc.ScaleTo:create(0.2, 0.5, 1.5)
                local scale3 = cc.ScaleTo:create(0.1, 1.2, 0.8)
                local scale4 = cc.ScaleTo:create(0.08, 1, 1)
                self.controls.build:runAction(cc.Sequence:create(scale1, scale2, scale3, scale4))
            end)
        end
    end

    if self.data.isCollecting then
        if self.data.buildInfo.CollectCD > 0 then
            self.data.buildInfo.CollectCD = self.data.buildInfo.CollectCD - dt
        else
            self.data.isCollecting = false
        end
        if self:isCanCollect() then
            self.controls.canCollect:setVisible(true)
            self.controls.canCollect:setTouchEnable(true)
            self.controls.canCollect:setSwallowTouches(true)
            self.controls.canUpgradePanel:setVisible(false)
            self.controls.canUpgradePanel:setTouchEnable(false)
            self.controls.canUpgradePanel:setSwallowTouches(false)
        else
            self.controls.canCollect:setVisible(false)
            self.controls.canCollect:setTouchEnable(false)
            self.controls.canCollect:setSwallowTouches(false)
        end
    end

    if self.controls.panelTime then
        local time = Common.timeFormat(self.data.buildInfo.CollectCD)
        self.controls.panelTime:setString(time)
        self.controls.panelTime:playChangeAction()
        if self.data.buildInfo.CollectCD > 0 then
            self:setGetBtnIsTouchEnabled(false)
            self.controls.panelTime:setVisible(true)
        else
            self:setGetBtnIsTouchEnabled(true)
            self.controls.panelTime:setVisible(false)
        end
    end
end

function BuildNode:collect()
    Common.playSound("audio/effect/home_harvest.mp3")
end

function BuildNode:setLootEnemyInfo(enemyInfo)
    self.data.enemyInfo = enemyInfo
end

function BuildNode:setLootSession(session)
    self.data.lootSession = session
end

function BuildNode:setBattleTurretInfo(turretID, turretNum)
    self.data.battleTurretID = turretID
    self.data.battleTurretNum = turretNum
end

function BuildNode:battleEnd(result)
    rpc:call("Home.EndF", {SessionID = result.sessionID, IsWin = result.result == "win" }, function(event)
        -- Medal     int
        -- AwardList []Goods
        -- EnemyBase
        self.data.isAtked = false
        local enemyInfo = event.result.EnemyBase
        application:dispatchCustomEvent(AppEvent.UI.Home.UpdateAvatar, {IsAvatar = true, EnemyInfo = enemyInfo})
        local isWin = nil
        if result.result == "win" then
            isWin = true
            self.controls.build:setTexture("image/ui/img/btn/btn_1215.png")
            Common.playSound("audio/effect/map_battle_win.mp3")
        else
            isWin = false
            self.controls.build:setTexture("image/ui/img/btn/btn_1214.png")
        end
        self:battleEndPanel(isWin, event.result)
    end, {show=false, debug=false, retryOnError = true} )
end

function BuildNode:battleEndPanel(isWin, result)
    if not isWin then
        local layer = require("tool.helper.CommonLayer").BattleFailLayer(result)
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)

        local btnImage = "image/ui/img/btn/btn_553.png"
        local btn_again = createMixSprite(btnImage)
        btn_again:setCircleFont("确定" , 1 , 1, 26, cc.c3b(226,204,169))
        btn_again:setFontOutline(cc.c4b(65,26,1,255), 1)
        btn_again:setFontPos(0.5,0.5)
        btn_again:setPosition(SCREEN_WIDTH*0.85,SCREEN_HEIGHT*0.18)
        layer:addChild(btn_again)
        btn_again:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                application:popScene()
                -- application:popScene()
                application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
            end
        end) 
        return
    else
        local node = cc.Node:create()
        local runningScene = cc.Director:getInstance():getRunningScene()
        runningScene:addChild(node)
        local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
        node:addChild(bgLayer)
        local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
        node:addChild(swallowLayer)
        local bgSize = cc.size(928, 400)
        local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_163.png")
        bg:setContentSize(bgSize)
        bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.35)
        node:addChild(bg)

        local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
        light:setPosition(bgSize.width * 0.5, bgSize.height * 1.1)
        bg:addChild(light, -1)
        local rep = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
        light:runAction(rep)

        local win = createMixSprite("image/ui/img/bg/bg_160.png", nil, "image/ui/img/btn/btn_632.png")
        win:setTouchEnable(false)
        win:setChildPos(0.5, 0.95)
        win:setPosition(bgSize.width * 0.5, bgSize.height * 1.1)
        bg:addChild(win)

        local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_161.png")
        iconbg:setScale9Enabled(true)
        iconbg:setContentSize(cc.size(380,80))
        iconbg:setPosition(bgSize.width * 0.5, bgSize.height * 0.85)
        bg:addChild(iconbg)

        local medalSpri = cc.Sprite:create("image/icon/props/medal.png")
        medalSpri:setPosition(bgSize.width * 0.4, bgSize.height * 0.85)
        bg:addChild(medalSpri)
        medalSpri:setScale(0.5)
        local medal = Common.finalFont("+"..result.Medal, 1, 1, 22, nil, 1)
        medal:setAnchorPoint(0, 0.5)
        medal:setPosition(bgSize.width * 0.44, bgSize.height * 0.85)
        bg:addChild(medal)

        local expSpri = cc.Sprite:create("image/ui/img/btn/btn_671.png")
        expSpri:setPosition(bgSize.width * 0.57, bgSize.height * 0.85)
        bg:addChild(expSpri)
        local exp = Common.finalFont("+"..result.Exp, 1, 1, 22, nil, 1)
        exp:setPosition(bgSize.width * 0.64, bgSize.height * 0.85)
        bg:addChild(exp)

        local sure = createMixSprite("image/ui/img/btn/btn_593.png")
        sure:setCircleFont("确定", 1, 1, 25, cc.c3b(238, 205, 142), 1)
        sure:setFontOutline(cc.c3b(70, 50, 14), 1)
        sure:setPosition(bgSize.width * 0.5, bgSize.height * 0.2)
        bg:addChild(sure)
        sure:addTouchEventListener(function(sender, eventType, inside)
            if (eventType == ccui.TouchEventType.ended) and inside then
                application:popScene()
                -- application:popScene()
                application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
            end
        end)

        local widthSpace = 60
        local goodsTabs = result.AwardList
        if goodsTabs then
            for k,v in pairs(goodsTabs) do
                local item = Common.getGoods(v, true)
                item:setPosition(bgSize.width * 0.5 -widthSpace * ((#goodsTabs) - 1) + (k - 1) * widthSpace * 2, bgSize.height * 0.55)
                bg:addChild(item)
            end
        else
            local tishi = Common.finalFont("很遗憾,未抢到任何物品~", 1, 1, 20, cc.c3b(139, 139, 87), 1)
            tishi:setPosition(bgSize.width * 0.5, bgSize.height * 0.55)
            bg:addChild(tishi)
        end
    end
end

function BuildNode:upgradeBuild()
    rpc:call("Home.Upgrade", self.data.buildNumber, function (event)
        if event.status == Exceptions.Nil and event.result then
            Common.playSound("audio/effect/home_building.mp3")
            self:syncHomeData()
        end
    end)
end

return BuildNode




