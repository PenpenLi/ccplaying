local DecorationBuild = class("DecorationBuild", require("scene.main.home.widget.BuildNode"))
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

local figureIconTab = {"image/ui/img/btn/btn_1048.png", "image/ui/img/btn/btn_1048.png", "image/ui/img/btn/btn_1048.png"}
local mapBgIconTab = {"image/ui/img/btn/btn_1029.png", "image/ui/img/btn/btn_1030.png", "image/ui/img/btn/btn_1031.png"}
local flagsSpriTab = {"image/ui/img/btn/btn_1193.png", "image/ui/img/btn/btn_1194.png", 
                        "image/ui/img/btn/btn_1195.png", "image/ui/img/btn/btn_1196.png"}
local flagAnimTab = {"image/spine/ui_effect/39/", "image/spine/ui_effect/40/", 
                    "image/spine/ui_effect/41/", "image/spine/ui_effect/42/"}

local flagPosTabs = {{x = -150, y = 40}, {x = -40, y = 80}, {x = 90, y = 60}}

function DecorationBuild:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildConfig = BaseConfig.getHomeDecoration(buildInfo.Level)
    self.data.maxLevel = BaseConfig.homeDecorationMaxLevel
    self.data.buildName = "CEO总部"
    self.data.buildDesc = "CEO总部能对企业建筑提供炮台防御，能控制掠夺上阵星将数。还可以打造家园的个性形象，提升逼格"
    DecorationBuild.super.ctor(self, number, buildInfo, isOwnHome, topNode)

    self.data.firstPanelSpriTab = {{"image/ui/img/btn/btn_1225.png", "image/ui/img/btn/btn_1230.png"},
                                    {"image/ui/img/btn/btn_1224.png", "image/ui/img/btn/btn_1229.png"},
                                    {"image/ui/img/btn/btn_1222.png", "image/ui/img/btn/btn_1227.png"},
                                    {"image/ui/img/btn/btn_1221.png", "image/ui/img/btn/btn_1226.png"}}
    self.data.firstPanelCenterSpri = "image/ui/img/btn/btn_1179.png"
end

function DecorationBuild:createBuildAccessory()
    local nameBG = cc.Sprite:create("image/ui/img/btn/btn_1117.png")
    self:addChild(nameBG)
    nameBG:setPosition(10, self.data.buildSize.height * 0.25)

    DecorationBuild.super.createBuildAccessory(self)
    self.data.flagsTab = {}
    for i=1,3 do
        self.data.flagsTab[i] = {}
        local flagsAnim = sp.SkeletonAnimation:create(flagAnimTab[i].."skeleton.skel", flagAnimTab[i].."skeleton.atlas")
        flagsAnim:setPosition(flagPosTabs[i].x, flagPosTabs[i].y)
        self.controls.build:addChild(flagsAnim)
        self.data.flagsTab[i].flagsAnim = flagsAnim
        self.data.flagsTab[i].flagsAnim:setAnimation(0, "animation", true)
        self.data.flagsTab[i].flagsAnim:setVisible(false)
        local flagsName = Common.systemFont("变换雕像", 1, 1, 18, nil, 1)
        flagsName:setPosition(flagPosTabs[i].x, flagPosTabs[i].y)
        self.controls.build:addChild(flagsName, 1)
        flagsName:setVisible(false)
        self.data.flagsTab[i].Lab = flagsName
    end
end

function DecorationBuild:firstPanelCollectTime()
    -- body
end

function DecorationBuild:firstPanelButtonFunc()
    application:showFlashNotice("暂未开放～")
end

function DecorationBuild:buildDetailPanel2(panel, panelSize)
    local turrNumSpri = cc.Sprite:create("image/ui/img/btn/btn_1237.png")
    turrNumSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.83)
    panel:addChild(turrNumSpri)
    turrNumSpri:setScale(0.5)
    local turretNumDesc = Common.finalFont("所有建筑的炮台数量:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    turretNumDesc:setAdditionalKerning(-2)
    turretNumDesc:setAnchorPoint(0, 0.5)
    turretNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.8)
    panel:addChild(turretNumDesc)
    local turretNum = Common.finalFont(self.data.buildConfig.TurretNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    turretNum:setAnchorPoint(0, 0.5)
    turretNum:setPosition(panelSize.width * 0.78, panelSize.height * 0.8)
    panel:addChild(turretNum)

    local turretPowerSpri = cc.Sprite:create("image/ui/img/btn/btn_1238.png")
    turretPowerSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.7)
    panel:addChild(turretPowerSpri)
    turretPowerSpri:setScale(0.5)
    local turretPowerDesc = Common.finalFont("炮台的威力系数:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    turretPowerDesc:setAdditionalKerning(-2)
    turretPowerDesc:setAnchorPoint(0, 0.5)
    turretPowerDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.68)
    panel:addChild(turretPowerDesc)
    local turretPower = Common.finalFont(self.data.buildInfo.Level, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    turretPower:setPosition(panelSize.width * 0.73, panelSize.height * 0.68)
    panel:addChild(turretPower)

    local atkSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    atkSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.57)
    panel:addChild(atkSpri)
    atkSpri:setScale(0.5)
    local atkHeroNumDesc = Common.finalFont("我方掠夺时的上阵人数:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    atkHeroNumDesc:setAdditionalKerning(-2)
    atkHeroNumDesc:setAnchorPoint(0, 0.5)
    atkHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.56)
    panel:addChild(atkHeroNumDesc)
    local atkHeroNum = Common.finalFont(self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    atkHeroNum:setAnchorPoint(0, 0.5)
    atkHeroNum:setPosition(panelSize.width * 0.81, panelSize.height * 0.56)
    panel:addChild(atkHeroNum)

    local defSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    defSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.44)
    panel:addChild(defSpri)
    defSpri:setScale(0.5)
    local defHeroNumDesc = Common.finalFont("防守星将:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defHeroNumDesc:setAdditionalKerning(-2)
    defHeroNumDesc:setAnchorPoint(0, 0.5)
    defHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.44)
    panel:addChild(defHeroNumDesc)
    local defNum = 0
    if self.data.buildInfo.DefForm.Hero then
        defNum = #self.data.buildInfo.DefForm.Hero
    end
    local defHeroNum = Common.finalFont(defNum.."/"..self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defHeroNum:setAnchorPoint(0, 0.5)
    defHeroNum:setPosition(panelSize.width * 0.63, panelSize.height * 0.44)
    panel:addChild(defHeroNum)
end

function DecorationBuild:upgradeDetailPanel(panel, panelSize)
    local turretNumBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    turretNumBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.83)
    panel:addChild(turretNumBg)
    local bar_turrNum = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_turrNum:setPosition(panelSize.width * 0.68, panelSize.height * 0.83)
    panel:addChild(bar_turrNum)
    local turretNumDesc = Common.finalFont("所有建筑的炮台数量:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    turretNumDesc:setAdditionalKerning(-2)
    turretNumDesc:setAnchorPoint(0, 0.5)
    turretNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.85)
    panel:addChild(turretNumDesc)
    local turretNum = Common.finalFont(self.data.buildConfig.TurretNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    turretNum:setAnchorPoint(0, 0.5)
    turretNum:setPosition(panelSize.width * 0.78, panelSize.height * 0.85)
    panel:addChild(turretNum)
    local afterTurretNum = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    afterTurretNum:setAnchorPoint(0, 0.5)
    panel:addChild(afterTurretNum)
    local turrNumSpri = cc.Sprite:create("image/ui/img/btn/btn_1237.png")
    turrNumSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.83)
    panel:addChild(turrNumSpri)
    turrNumSpri:setScale(0.5)
    local upgradeTurretNum = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeTurretNum:setPosition(panelSize.width * 0.92, panelSize.height * 0.85)
    panel:addChild(upgradeTurretNum)

    local turretPowerBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    turretPowerBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.7)
    panel:addChild(turretPowerBg)
    local bar_turretPower = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_turretPower:setPosition(panelSize.width * 0.68, panelSize.height * 0.7)
    bar_turretPower:setPercent(50)
    panel:addChild(bar_turretPower)
    local turretPowerDesc = Common.finalFont("炮台的威力系数:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    turretPowerDesc:setAdditionalKerning(-2)
    turretPowerDesc:setAnchorPoint(0, 0.5)
    turretPowerDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.72)
    panel:addChild(turretPowerDesc)
    local turretPower = Common.finalFont(self.data.buildInfo.Level, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    turretPower:setPosition(panelSize.width * 0.73, panelSize.height * 0.72)
    panel:addChild(turretPower)
    local afterTurretPower = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    panel:addChild(afterTurretPower)
    local turretPowerSpri = cc.Sprite:create("image/ui/img/btn/btn_1238.png")
    turretPowerSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.7)
    panel:addChild(turretPowerSpri)
    turretPowerSpri:setScale(0.5)
    local upgradeTurretPower = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeTurretPower:setPosition(panelSize.width * 0.92, panelSize.height * 0.72)
    panel:addChild(upgradeTurretPower)

    local atkHeroNumBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    atkHeroNumBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.57)
    panel:addChild(atkHeroNumBg)
    local bar_atkHeroNum = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_atkHeroNum:setPosition(panelSize.width * 0.68, panelSize.height * 0.57)
    bar_atkHeroNum:setPercent(50)
    panel:addChild(bar_atkHeroNum)
    local atkHeroNumDesc = Common.finalFont("我方掠夺时的上阵人数:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    atkHeroNumDesc:setAdditionalKerning(-2)
    atkHeroNumDesc:setAnchorPoint(0, 0.5)
    atkHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.59)
    panel:addChild(atkHeroNumDesc)
    local atkHeroNum = Common.finalFont(self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    atkHeroNum:setAnchorPoint(0, 0.5)
    atkHeroNum:setPosition(panelSize.width * 0.81, panelSize.height * 0.59)
    panel:addChild(atkHeroNum)
    local afterAtkHeroNum = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    afterAtkHeroNum:setAnchorPoint(0, 0.5)
    panel:addChild(afterAtkHeroNum)
    local atkSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    atkSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.57)
    panel:addChild(atkSpri)
    atkSpri:setScale(0.5)
    local upgradeAtkHero = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeAtkHero:setPosition(panelSize.width * 0.92, panelSize.height * 0.59)
    panel:addChild(upgradeAtkHero)

    local defHeroNumBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    defHeroNumBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.44)
    panel:addChild(defHeroNumBg)
    local bar_defHeroNum = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_defHeroNum:setPosition(panelSize.width * 0.68, panelSize.height * 0.44)
    bar_defHeroNum:setPercent(50)
    panel:addChild(bar_defHeroNum)
    local defHeroNumDesc = Common.finalFont("防守星将:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defHeroNumDesc:setAdditionalKerning(-2)
    defHeroNumDesc:setAnchorPoint(0, 0.5)
    defHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.46)
    panel:addChild(defHeroNumDesc)
    local defHeroNum = Common.finalFont(self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defHeroNum:setAnchorPoint(0, 0.5)
    defHeroNum:setPosition(panelSize.width * 0.64, panelSize.height * 0.46)
    panel:addChild(defHeroNum)
    local afterDefHeroNum = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    afterDefHeroNum:setAnchorPoint(0, 0.5)
    panel:addChild(afterDefHeroNum)
    local defSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    defSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.44)
    panel:addChild(defSpri)
    defSpri:setScale(0.5)
    local upgradeDefHero = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeDefHero:setPosition(panelSize.width * 0.92, panelSize.height * 0.46)
    panel:addChild(upgradeDefHero)

    if self.data.buildInfo.Level < self.data.maxLevel then
        local currConfig = self.data.buildConfig
        local afterConfig = BaseConfig.getHomeDecoration(self.data.buildInfo.Level + 1)
        bar_turrNum:setPercent((currConfig.TurretNum / afterConfig.TurretNum) * 100)
        turretNum:setString(currConfig.TurretNum)
        afterTurretNum:setString("+"..(afterConfig.TurretNum - currConfig.TurretNum))
        afterTurretNum:setPosition(turretNum:getPositionX() + turretNum:getContentSize().width + 10, 
                                panelSize.height * 0.85)
        if (afterConfig.TurretNum - currConfig.TurretNum) > 0 then
            upgradeTurretNum:setScale(1)
        else
            upgradeTurretNum:setScale(0)
        end

        bar_turretPower:setPercent((currConfig.Level / afterConfig.Level) * 100)
        turretPower:setString(currConfig.Level)
        afterTurretPower:setString("+"..(afterConfig.Level - currConfig.Level))
        afterTurretPower:setPosition(turretPower:getPositionX() + turretPower:getContentSize().width + 10, 
                                 panelSize.height * 0.72)
        if (afterConfig.Level - currConfig.Level) > 0 then
            upgradeTurretPower:setScale(1)
        else
            upgradeTurretPower:setScale(0)
        end

        bar_atkHeroNum:setPercent((currConfig.HeroNum / afterConfig.HeroNum) * 100)
        atkHeroNum:setString(currConfig.HeroNum)
        afterAtkHeroNum:setString("+"..(afterConfig.HeroNum - currConfig.HeroNum))
        afterAtkHeroNum:setPosition(atkHeroNum:getPositionX() + atkHeroNum:getContentSize().width + 10, 
                                panelSize.height * 0.59)
        if (afterConfig.HeroNum - currConfig.HeroNum) > 0 then
            upgradeAtkHero:setScale(1)
        else
            upgradeAtkHero:setScale(0)
        end

        bar_defHeroNum:setPercent((currConfig.HeroNum / afterConfig.HeroNum) * 100)
        defHeroNum:setString(currConfig.HeroNum) 
        afterDefHeroNum:setString("+"..(afterConfig.HeroNum - currConfig.HeroNum))
        afterDefHeroNum:setPosition(defHeroNum:getPositionX() + defHeroNum:getContentSize().width + 10, 
                                panelSize.height * 0.46)
        if (afterConfig.HeroNum - currConfig.HeroNum) > 0 then
            upgradeDefHero:setScale(1)
        else
            upgradeDefHero:setScale(0)
        end
    else
        bar_turrNum:setPercent(100)
        turretNum:setString(self.data.buildConfig.TurretNum)
        upgradeTurretNum:setScale(0)

        bar_turretPower:setPercent(100)
        turretPower:setString(self.data.buildConfig.Level)
        upgradeTurretPower:setScale(0)

        bar_atkHeroNum:setPercent(100)
        atkHeroNum:setString(self.data.buildConfig.HeroNum)
        upgradeAtkHero:setScale(0)

        bar_defHeroNum:setPercent(100)
        defHomeNum:setString(self.data.buildConfig.HeroNum)
        upgradeDefHero:setScale(0)
    end

end

function DecorationBuild:updateBuild()
    self.data.buildConfig = BaseConfig.getHomeDecoration(self.data.buildInfo.Level)
    DecorationBuild.super.updateBuild(self)
    
    self.controls.scrollBarBg:setScale(0)
    self.controls.scrollBarCapacity:setScale(0)
    self.controls.scrollBar_capacity:setScale(0)

    if self.data.buildInfo.Flags then
        for k,v in pairs(self.data.buildInfo.Flags) do
            local posX, posY = self.data.flagsTab[k].flagsAnim:getPositionX(), self.data.flagsTab[k].flagsAnim:getPositionY()
            self.data.flagsTab[k].flagsAnim:removeFromParent()
            self.data.flagsTab[k].flagsAnim = nil
            local flagsAnim = sp.SkeletonAnimation:create(flagAnimTab[v.ID].."skeleton.skel", flagAnimTab[v.ID].."skeleton.atlas")
            flagsAnim:setPosition(posX, posY)
            self.controls.build:addChild(flagsAnim)
            flagsAnim:setAnimation(0, "animation", true)
            self.data.flagsTab[k].flagsAnim = flagsAnim

            self.data.flagsTab[k].Lab:setVisible(true)
            self.data.flagsTab[k].Lab:setString(v.Name)
        end
    end
end

function DecorationBuild:isCanCollect()
    return false
end

function DecorationBuild:setExchangeBuild(figureID)
    rpc:call("Home.SetFigure", figureID, function (event)
        if event.status == Exceptions.Nil and event.result then
            self.controls.build:setTexture(self.data.buildPathTab[figureID])
        end
    end) 
end

function DecorationBuild:battleEnd(result)
    DecorationBuild.super.battleEnd(self, result)
end

function DecorationBuild:setLootEnemyInfo(enemyInfo)
    self.data.enemyInfo = enemyInfo
end

function DecorationBuild:battleEndPanel(isWin, result)
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
    end
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

    local shuoming = Common.finalFont("恭喜上仙战无不胜,是否留下你胜利的标帜", 1, 1, 22, cc.c3b(255,255,140), 1)
    shuoming:setPosition(bgSize.width * 0.5, bgSize.height * 0.7)
    bg:addChild(shuoming)

    local isChooseFlags = false
    local flagsNumber = 0
    local priceTab = {10000, 20000, 30000, 40000}
    local flagsCost = nil
    local flagsBtnTab = {}
    for i=1,4 do
        local btn_flags = createMixSprite(flagsSpriTab[i], nil, "image/ui/img/btn/btn_502.png")
        btn_flags:setButtonBounce(false)
        btn_flags:setChildTextureVisible(false)
        btn_flags:setScale(0.8)
        btn_flags:setPosition(bgSize.width * 0.32 + (i - 1) * 120, bgSize.height * 0.52)
        bg:addChild(btn_flags)
        flagsBtnTab[i] = btn_flags

        local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        priceSpri:setPosition(bgSize.width * 0.32 + (i - 1) * 120 - 30, bgSize.height * 0.37)
        bg:addChild(priceSpri)
        local priceLab = Common.finalFont(priceTab[i], 1, 1, 18, nil, 1)
        priceLab:setAnchorPoint(0, 0.5)
        priceLab:setPosition(bgSize.width * 0.32 + (i - 1) * 120 - 10, bgSize.height * 0.37)
        bg:addChild(priceLab)
        
        btn_flags:addTouchEventListener(function(sender, eventType, inside)
            if (eventType == ccui.TouchEventType.ended) and inside then
                local function chooseFlags()
                    isChooseFlags = true
                    for k,v in pairs(flagsBtnTab) do
                        v:setChildTextureVisible(false)
                    end
                    btn_flags:setChildTextureVisible(true)
                    flagsNumber = i
                    flagsCost = priceTab[i]
                end
                if i == 3 then
                    if GameCache.Avatar.VIP >= 4 then
                        chooseFlags()
                    else
                        application:showFlashNotice("VIP4专享")
                    end
                elseif i == 4 then
                    if GameCache.Avatar.VIP >= 6 then
                        chooseFlags()
                    else
                        application:showFlashNotice("VIP6专享")
                    end
                else
                    chooseFlags()
                end
            end
        end)
    end
    local cancel = createMixSprite("image/ui/img/btn/btn_593.png")
    cancel:setCircleFont("取消", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    cancel:setFontOutline(cc.c3b(70, 50, 14), 1)
    cancel:setPosition(bgSize.width * 0.3, bgSize.height * 0.2)
    bg:addChild(cancel)
    cancel:addTouchEventListener(function(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            node:removeFromParent()
            node = nil
            application:popScene()
            -- application:popScene()
            application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
        end
    end)

    local sure = createMixSprite("image/ui/img/btn/btn_593.png")
    sure:setCircleFont("确定", 1, 1, 25, cc.c3b(238, 205, 142), 1)
    sure:setFontOutline(cc.c3b(70, 50, 14), 1)
    sure:setPosition(bgSize.width * 0.7, bgSize.height * 0.2)
    bg:addChild(sure)
    sure:addTouchEventListener(function(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            if isChooseFlags then
                if Common.isCostMoney(1002, flagsCost) then
                    if (not self.data.buildInfo.Flags) or (#self.data.buildInfo.Flags) < 3 then
                        rpc:call("Home.PlugWhiteFlag", {LootSession = self.data.lootSession, ID = flagsNumber}, function (event)
                            if event.status == Exceptions.Nil and event.result then
                                node:removeFromParent()
                                node = nil
                                application:popScene()
                                -- application:popScene()
                                self.data.buildInfo.Flags = event.result
                                self:updateBuild()
                                application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
                            end
                        end) 
                    else
                        self:HintPanel(self.data.enemyInfo.Name, function()
                            if Common.isCostMoney(1001, 20) then
                                rpc:call("Home.PlugWhiteFlag", {LootSession = self.data.lootSession, ID = flagsNumber}, function (event)
                                    if event.status == Exceptions.Nil and event.result then
                                        node:removeFromParent()
                                        node = nil
                                        self.data.buildInfo.Flags = event.result
                                        self:updateBuild()

                                        application:popScene()
                                        -- application:popScene()
                                        application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
                                    end
                                end) 
                            end
                        end)
                    end
                end
            else
                application:showFlashNotice("上仙，请先选择一种旗帜")
            end
        end
    end)
end

function DecorationBuild:HintPanel(name, callFunc)
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    local desc = Common.finalFont("上仙,"..name.."已经被人插满了白旗,你是否花费", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.08, panelSize.height * 0.72)
    desc:setAnchorPoint(0, 0.5)
    panel:addChild(desc)
    
    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(panelSize.width * 0.08, panelSize.height * 0.58)
    goldSpri:setAnchorPoint(0, 0.5)
    panel:addChild(goldSpri)
    local yuanbao = Common.finalFont("20", 1, 1, 20, cc.c3b(253, 233, 95), 1)
    yuanbao:setPosition(panelSize.width * 0.18, panelSize.height * 0.58)
    panel:addChild(yuanbao)

    desc = Common.finalFont("拔掉一根,插上咱们的旗帜?", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.22, panelSize.height * 0.58)
    desc:setAnchorPoint(0, 0.5)
    panel:addChild(desc)

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btnBG)
    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if callFunc then
                callFunc()
            end
            panel:removeFromParent()
            panel = nil
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
            panel:removeFromParent()
            panel = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(panel)
end

return DecorationBuild




