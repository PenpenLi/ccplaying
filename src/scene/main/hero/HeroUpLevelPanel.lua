local UpgradeLevelPanel = class("UpgradeLevelPanel", function()
    local self = cc.Node:create()
    self.controls = {}
    self.data = {}
    self.handlers = {}
    return self
end)
local CalHeroAttr = require("tool.helper.CalHeroAttr")
local ColorLabel = require("tool.helper.ColorLabel")

local scheduler = cc.Director:getInstance():getScheduler()

local bigPillID = 1159
local middlePillID = 1160
local smallPillID = 1161

function UpgradeLevelPanel:ctor()
    self.data.size = cc.size(400, 560)
    self.data.pillIDTab = {bigPillID, middlePillID, smallPillID}
    self:createFixedUI()

    self.controls.updateBar = scheduler:scheduleScriptFunc(handler(self, self.updateBarExpEvent), 0, false)
    self.controls.eatPill = scheduler:scheduleScriptFunc(handler(self, self.continuousEatPillEvent), 1/10, false)
end

function UpgradeLevelPanel:onExit()
    scheduler:unscheduleScriptEntry(self.controls.updateBar)
    scheduler:unscheduleScriptEntry(self.controls.eatPill)
    if self.scheduler_updateLongTouch then
        scheduler:unscheduleScriptEntry(self.scheduler_updateLongTouch)
    end
    self:updateHeroFinalData()
end

function UpgradeLevelPanel:createFixedUI()
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(cc.size(416, 586))
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_793.png")
    if MODE ~= PRO then
        self.controls.showHeroID = Common.finalFont("showHeroID", 1, 1, 20, nil, 1)
        self.controls.showHeroID:setPosition(0, size.height * 0.5)
        self:addChild(self.controls.showHeroID)
        self.controls.showHeroID:setVisible(false)

        detailName:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                self.controls.showHeroID:setVisible(true)
                self.controls.showHeroID:setString("星将ID："..self.data.chooseHeroInfo.ID)
            end
            if eventType == ccui.TouchEventType.ended then
                self.controls.showHeroID:setVisible(false)
            end
        end)
    else
        detailName:setTouchEnable(false)
    end
    detailName:setPosition(0, size.height * 0.42)
    self:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(-size.width * 0.2, size.height * 0.42)
    self:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(size.width * 0.2, size.height * 0.42)
    self:addChild(line)

    self.controls.heroLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    self.controls.heroLevel:setAnchorPoint(0.5, 0)
    self.controls.heroLevel:setAdditionalKerning(-10)
    self.controls.heroLevel:setPosition(-size.width * 0.02, size.height * 0.245)
    self:addChild(self.controls.heroLevel)

    self.controls.controls_ji = cc.Sprite:create("image/ui/img/btn/btn_790.png")
    self.controls.controls_ji:setAnchorPoint(0, 0)
    self.controls.controls_ji:setPosition(self.controls.heroLevel:getPositionX() + self.controls.heroLevel:getContentSize().width * 0.7, self.controls.heroLevel:getPositionY()) 
    self:addChild(self.controls.controls_ji)

    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_1016.png")
    bar_BG:setPosition(0, size.height * 0.22)
    self:addChild(bar_BG)
    self.controls.bar_heroLevel = ccui.LoadingBar:create("image/ui/img/btn/btn_1017.png")
    self.controls.bar_heroLevel:setPercent(50)
    self.controls.bar_heroLevel:setPosition(bar_BG:getContentSize().width * 0.5, bar_BG:getContentSize().height * 0.5)
    bar_BG:addChild(self.controls.bar_heroLevel)

    self.controls.heroExp = Common.finalFont("", 1, 1, 20, nil, 1)
    self.controls.heroExp:enableOutline(cc.c4b(6,66,0,255), 2)
    self.controls.heroExp:setPosition(0, size.height * 0.196)
    self.controls.heroExp:setAnchorPoint(0.5, 1)
    self:addChild(self.controls.heroExp)

    local line = cc.Scale9Sprite:create("image/ui/img/btn/btn_781.png")
    line:setContentSize(cc.size(417, 104))
    line:setPosition(0, size.height * 0.055)
    self:addChild(line)

    line = cc.Scale9Sprite:create("image/ui/img/btn/btn_781.png")
    line:setContentSize(cc.size(417, 104))
    line:setPosition(0, -size.height * 0.365)
    self:addChild(line)

    self.controls.levelAlert = cc.Node:create()
    self:addChild(self.controls.levelAlert)

    local alertBG = cc.Sprite:create("image/ui/img/bg/bg_250.png")
    alertBG:setPosition(0, size.height * 0.36)
    self.controls.levelAlert:addChild(alertBG)
    alertBG:setScaleX(0.7)
    alertBG:setScaleY(0.22)
    local alertDesc = Common.finalFont("提示:亲,长按[+]可以连续吃经验丹哦", 1, 1, 18, cc.c3b(255,227,123), 1)
    alertDesc:setPosition(0, size.height * 0.36)
    self.controls.levelAlert:addChild(alertDesc)

    local allHero = GameCache.GetAllHero()
    local maxLevel = 30
    local maxNum = 2
    local levelNum = 0
    for k,v in pairs(allHero) do
        if v.Level >= maxLevel then
            levelNum = levelNum + 1
            if levelNum >= maxNum then
                self.controls.levelAlert:setVisible(false)
                break
            end
        end
    end
    
    local function pillUI()
        local function eatExpEvent(sender, eventType, isIn)
            local function getMaxLevelNeedExp()
                local totalExp = BaseConfig.GetHeroUpgradeExp(self.data.chooseHeroConfigInfo.talent, self.data.chooseHeroInfo.Level) - self.data.chooseHeroInfo.Exp
                for i=(self.data.chooseHeroInfo.Level + 1),GameCache.Avatar.Level do
                    local exp = BaseConfig.GetHeroUpgradeExp(self.data.chooseHeroConfigInfo.talent, i)
                    totalExp = totalExp + exp
                end
                return totalExp
            end

            if eventType == ccui.TouchEventType.began then
                local name = sender:getName() 

                for k,v in pairs(self.data.pillIDTab) do
                    if tonumber(name) == v then
                        self.data.currPillId = v
                    end
                end
                self.data.currEatNum = 0
                if not self.data.isCurrHeroMaxLevel then
                    self.data.maxLevelNeedExp = getMaxLevelNeedExp()
                end

                local propsConfig = BaseConfig.GetProps(self.data.currPillId)
                local costConfig = BaseConfig.GetHeroUpgradeCost(self.data.currPillId)
                if 0 == self:getPropsNumByID(self.data.currPillId) then
                    application:showFlashNotice("经验丹不足")
                    self.data.isCanUpgrade = false
                elseif GameCache.Avatar.Coin < costConfig.Coin then
                    application:showFlashNotice("银币不足")
                    self.data.isCanUpgrade = false
                elseif self.data.maxLevelNeedExp <= 0 then
                    application:showFlashNotice("星将等级不能超过角色等级")
                    self.data.isCanUpgrade = false
                else
                    Common.addTopSwallowLayer()
                    self.data.currEatNum = self.data.currEatNum + 1
                    GameCache.Avatar.Coin = GameCache.Avatar.Coin - costConfig.Coin
                    self.data.pillImgTab[self.data.currPillId]:setNum(self:getPropsNumByID(self.data.currPillId, 1))
                    self.data.addExp = self.data.addExp + propsConfig.useValue

                    self.data.maxLevelNeedExp = self.data.maxLevelNeedExp - propsConfig.useValue
                    self.data.isTouchEatPill = true
                    self.scheduler_updateLongTouch = scheduler:scheduleScriptFunc(function()
                        if self.scheduler_updateLongTouch then
                            scheduler:unscheduleScriptEntry(self.scheduler_updateLongTouch)
                            self.scheduler_updateLongTouch = nil
                        end
                        self.data.isContinuousEat = true
                    end, 0.5, false)
                    self.data.isCanUpgrade = true
                    self:upgradeEffect()
                end
            end

            local function upgradeFunc()
                Common.removeTopSwallowLayer()
                if self.scheduler_updateLongTouch then
                    scheduler:unscheduleScriptEntry(self.scheduler_updateLongTouch)
                    self.scheduler_updateLongTouch = nil
                end
                if self.data.isContinuousEat then
                    self.data.isContinuousEat = false
                end
                if self.data.isCanUpgrade then
                    self.data.isCanUpgrade = false
                    self:UpgradeHero(self.data.chooseHeroInfo.ID, self.data.currPillId, self.data.currEatNum)
                end
            end
            if (eventType == ccui.TouchEventType.moved) then
                if not isIn then
                    upgradeFunc()
                end
            end
            if (eventType == ccui.TouchEventType.ended) then
                -- Common.CloseGuideLayer({9})
                -- if GameCache.NewbieGuide.Step == 9 then
                --     Common.SaveGuideLayer(  )

                --     local guide = self:CreateSwallowGuideLayer( 0,0,SCREEN_WIDTH,SCREEN_HEIGHT )
                --     local scene = cc.Director:getInstance():getRunningScene()
                --     scene:addChild(guide)
                -- end
                -- Common.OpenGuideLayer({9})
                upgradeFunc()
            end
            if (eventType == ccui.TouchEventType.canceled) then
                upgradeFunc()
            end
        end

        self.data.pillImgTab = {}
        self.data.upgradeBtnTab = {}
        for i=1,3 do
            local controls_img = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, {ID = self.data.pillIDTab[i]}, BaseConfig.GOODS_MIDDLETYPE)
            controls_img:setTips(true)
            controls_img:setNum(self:getPropsNumByID(self.data.pillIDTab[i]))
            controls_img:setPosition(-size.width * 0.33, size.height * 0.055 - (i - 1) * (size.height * 0.21))
            self:addChild(controls_img)
            self.data.pillImgTab[self.data.pillIDTab[i]] = controls_img

            local propsConfig = BaseConfig.GetProps(self.data.pillIDTab[i])
            local costConfig = BaseConfig.GetHeroUpgradeCost(self.data.pillIDTab[i])
            local imgSize = controls_img:getContentSize()
            local imgX, imgY = controls_img:getPosition()
            local pillName = Common.finalFont(propsConfig.name, 
                                            imgX + imgSize.width * 0.7, imgY + imgSize.height * 0.4, 20, cc.c3b(102, 252, 255), 1)
            pillName:setAnchorPoint(0, 0.5)
            self:addChild(pillName)

            self.controls.oneExp = ColorLabel.new("", 18, nil, true)
            self.controls.oneExp:setString("[243,243,201]每颗经验值[=][250,211,69]+"..propsConfig.useValue.."[=]")
            self.controls.oneExp:setPosition(imgX + imgSize.width * 0.7, imgY - 5)
            self.controls.oneExp:setAnchorPoint(0, 0.5)
            self:addChild(self.controls.oneExp)

            local Xiaohao = Common.finalFont("消耗:", imgX + imgSize.width * 0.7, imgY-imgSize.height * 0.4, 18, cc.c3b(243,243,201))
            Xiaohao:setAnchorPoint(0, 0.5)
            self:addChild(Xiaohao)

            local imgPrice = cc.Sprite:create("image/ui/img/btn/btn_035.png")
            imgPrice:setPosition(imgX + imgSize.width * 0.7 + Xiaohao:getContentSize().width, imgY-imgSize.height * 0.4)
            imgPrice:setAnchorPoint(0, 0.5)
            self:addChild(imgPrice)

            self.controls.onePrice = Common.finalFont(costConfig.Coin, 
                                        imgX + imgSize.width * 0.7 + Xiaohao:getContentSize().width + imgPrice:getContentSize().width, 
                                        imgY-imgSize.height * 0.4, 18, nil)
            self.controls.onePrice:setAnchorPoint(0, 0.5)
            self:addChild(self.controls.onePrice)

            local btn_upgrade = createMixSprite("image/ui/img/btn/btn_582.png","image/ui/img/btn/btn_784.png")
            btn_upgrade:setName(self.data.pillIDTab[i])
            btn_upgrade:setPosition(size.width * 0.35, size.height * 0.055 - (i - 1) * (size.height * 0.21))
            btn_upgrade:addTouchEventListener(eatExpEvent)
            self:addChild(btn_upgrade)
            self.data.upgradeBtnTab[self.data.pillIDTab[i]] = btn_upgrade
        end
    end
    pillUI()
end

function UpgradeLevelPanel:updateHeroInfo(heroInfo, configInfo)
    self:updateHeroFinalData()

    self.data.chooseHeroInfo = heroInfo
    self.data.chooseHeroConfigInfo = configInfo
    self.data.finalLevel = self.data.chooseHeroInfo.Level
    self.data.finalExp = self.data.chooseHeroInfo.Exp
    self.data.isCurrHeroMaxLevel = false
    self:updatePillInfo(heroInfo, configInfo)
end

function UpgradeLevelPanel:updateHeroFinalData()
    if self.data.finalLevel and self.data.finalExp then
        self.data.chooseHeroInfo.Level = self.data.finalLevel
        self.data.chooseHeroInfo.Exp = self.data.finalExp
    end
end

function UpgradeLevelPanel:updatePillInfo(heroInfo, configInfo)
    self.controls.heroLevel:setString(heroInfo.Level)
    self.controls.controls_ji:setPosition(self.controls.heroLevel:getPositionX() + self.controls.heroLevel:getContentSize().width * 0.6, self.controls.heroLevel:getPositionY()) 

    self.data.maxExp = BaseConfig.GetHeroUpgradeExp(configInfo.talent, heroInfo.Level)
    self.controls.bar_heroLevel:setPercent(heroInfo.Exp/self.data.maxExp * 100)
    self.data.addExp = heroInfo.Exp

    self.controls.heroExp:setString(heroInfo.Exp.."/"..self.data.maxExp)

    self:updateButtonTouch()
end

function UpgradeLevelPanel:updateButtonTouch()
    for k,v in pairs(self.data.pillIDTab) do
        local num = self:getPropsNumByID(v)
        self.data.pillImgTab[v]:setNum(num)
        if num > 0 then
            self.data.upgradeBtnTab[v]:setTouchEnable(true)
            self.data.upgradeBtnTab[v]:setNorGLProgram(true)
        else
            self.data.upgradeBtnTab[v]:setTouchEnable(false)
            self.data.upgradeBtnTab[v]:setNorGLProgram(false)
        end
    end
end

function UpgradeLevelPanel:continuousEatPillEvent(dt)
    if self.data.isContinuousEat then
        local propsConfig = BaseConfig.GetProps(self.data.currPillId)
        local costConfig = BaseConfig.GetHeroUpgradeCost(self.data.currPillId)
        if self:getPropsNumByID(self.data.currPillId) < 1 then
            application:showFlashNotice("经验丹不足")
            self.data.isContinuousEat = false
        elseif GameCache.Avatar.Coin < costConfig.Coin then
            application:showFlashNotice("银币不足")
            self.data.isContinuousEat = false
        elseif self.data.maxLevelNeedExp <= 0 then
            self.data.isCurrHeroMaxLevel = true
            self.data.maxLevelNeedExp = 0
            self.data.isContinuousEat = false
            application:showFlashNotice("星将等级不能超过角色等级")
        else
            GameCache.Avatar.Coin = GameCache.Avatar.Coin - costConfig.Coin
            self.data.currEatNum = self.data.currEatNum + 1
            self.data.addExp = self.data.addExp + propsConfig.useValue
            self.data.maxLevelNeedExp = self.data.maxLevelNeedExp - propsConfig.useValue
            self.data.isTouchEatPill = true
            local num = self:getPropsNumByID(self.data.currPillId, 1)
            self.data.pillImgTab[self.data.currPillId]:setNum(num)
            if num > 0 then
                self.data.upgradeBtnTab[self.data.currPillId]:setTouchEnable(true)
                self.data.upgradeBtnTab[self.data.currPillId]:setNorGLProgram(true)
            else
                self.data.upgradeBtnTab[self.data.currPillId]:setTouchEnable(false)
                self.data.upgradeBtnTab[self.data.currPillId]:setNorGLProgram(false)
            end
            self:upgradeEffect()
        end
    end
end

function UpgradeLevelPanel:updateBarExpEvent(dt)
    if self.data.isTouchEatPill then
        local maxExp = BaseConfig.GetHeroUpgradeExp(self.data.chooseHeroConfigInfo.talent, self.data.chooseHeroInfo.Level)
        self.data.chooseHeroInfo.Exp =math.floor(self.data.chooseHeroInfo.Exp + maxExp / 5)
        self.controls.heroExp:setString(self.data.chooseHeroInfo.Exp.."/"..self.data.maxExp)
        self.controls.bar_heroLevel:setPercent(self.data.chooseHeroInfo.Exp/self.data.maxExp * 100)
        application:dispatchCustomEvent(AppEvent.UI.Hero.UpgradeLevelAndStar, {Exp = self.data.chooseHeroInfo.Exp})
        
        if self.data.chooseHeroInfo.Exp > self.data.addExp then
            self.data.isTouchEatPill = false
            self.data.chooseHeroInfo.Exp = self.data.addExp
            self.controls.heroExp:setString(self.data.chooseHeroInfo.Exp.."/"..self.data.maxExp)
            self.controls.bar_heroLevel:setPercent(self.data.chooseHeroInfo.Exp/self.data.maxExp * 100)
            application:dispatchCustomEvent(AppEvent.UI.Hero.UpgradeLevelAndStar, {Exp = self.data.chooseHeroInfo.Exp})
        end

        if self.data.chooseHeroInfo.Exp > self.data.maxExp then
            self.data.isTouchEatPill = true
            self.data.chooseHeroInfo.Exp = self.data.maxExp
            self.controls.heroExp:setString(self.data.chooseHeroInfo.Exp.."/"..self.data.maxExp)
            self.controls.bar_heroLevel:setPercent(100)
            
            local beforeHeroInfo = Common.copyTab(self.data.chooseHeroInfo)
            self.data.chooseHeroInfo.Level = self.data.chooseHeroInfo.Level + 1
            if self.data.chooseHeroInfo.Level > GameCache.Avatar.Level then
                self.data.isTouchEatPill = false
                self.data.chooseHeroInfo.Level = GameCache.Avatar.Level
                self.data.addExp = self.data.chooseHeroInfo.Exp
            else
                self.data.chooseHeroInfo.Exp = 0
                self.data.addExp = self.data.addExp - self.data.maxExp
                self.data.maxExp = BaseConfig.GetHeroUpgradeExp(self.data.chooseHeroConfigInfo.talent, self.data.chooseHeroInfo.Level)
                self.controls.heroLevel:setString(self.data.chooseHeroInfo.Level)
                self.controls.controls_ji:setPosition(self.controls.heroLevel:getPositionX() + self.controls.heroLevel:getContentSize().width * 0.6, self.controls.heroLevel:getPositionY()) 

                application:dispatchCustomEvent(AppEvent.UI.Hero.UpgradeEffect, {})
            end
            -- 星将列表和头像列表中的等级要改变，星将表也要改变
            application:dispatchCustomEvent(AppEvent.UI.Hero.UpgradeLevelAndStar, {Level = self.data.chooseHeroInfo.Level, 
                                                                                    Exp = self.data.chooseHeroInfo.Exp})
            application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                                {BeforeHero = beforeHeroInfo, CurrHero = self.data.chooseHeroInfo})
            self.controls.heroLevel:setString(self.data.chooseHeroInfo.Level)
            self.controls.controls_ji:setPosition(self.controls.heroLevel:getPositionX() + self.controls.heroLevel:getContentSize().width * 0.6, self.controls.heroLevel:getPositionY()) 
        end
    end
end

function UpgradeLevelPanel:getPropsNumByID(id, minusNum)
    local propsInfo = GameCache.GetProps(id)
    if propsInfo then
        if minusNum then
            GameCache.minusProps(id, minusNum)
        end
        return propsInfo.Num
    else
        return 0
    end
end

function UpgradeLevelPanel:upgradeEffect()
    local size = self.controls.bg:getContentSize()
    Common.eatPillEffect(self, -size.width * 0.33, 
                size.height * 0.055 - (self.data.currPillId - bigPillID) * (size.height * 0.21))
end

--[[
    星将升级
]]
function UpgradeLevelPanel:UpgradeHero(heroId, expId, expNum)
    rpc:call("Hero.UpgradeHero", {ID = heroId, PropsID = expId, PropsNum = expNum}, function(event)
        self.data.finalLevel = event.result.Level
        self.data.finalExp = event.result.Exp
        local tfp = event.result.TFP
        if event.status == Exceptions.Nil then
            self:updateButtonTouch()
            self.data.upgradeBtnTab[self.data.currPillId]:setScale(1)
        end
    end)
end

function UpgradeLevelPanel:CreateSwallowGuideLayer( posx,posy,width,height )
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), width, height)
    layer:setPosition(posx, posy)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function() return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function ( ) 
        Common.CloseGuideLayer({9})
        Common.OpenGuideLayer({9})
        layer:removeFromParent() 
        layer = nil 
    end,   cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    return layer
end

return UpgradeLevelPanel


