local SkillPanel = class("SkillPanel", function()
    local self = cc.Node:create()
    self.controls = {}
    self.data = {}
    self.handlers = {}
    return self
end)
local effects = require("tool.helper.Effects")
local scheduler = cc.Director:getInstance():getScheduler()
local CalHeroAttr = require("tool.helper.CalHeroAttr")
local SkillIcon = require("scene.main.hero.widget.SkillIcon")
local ColorLabel = require("tool.helper.ColorLabel")

function SkillPanel:ctor()
    self.data.size = cc.size(400, 560)
    self:createFixedUI()

    self.controls.updatePillBar = scheduler:scheduleScriptFunc(handler(self, self.updateBarExpEvent), 1/60, false)
    self.controls.continuousEatPill = scheduler:scheduleScriptFunc(handler(self, self.continuousEatPillEvent), 0.05, false)
end

function SkillPanel:onExit()
    scheduler:unscheduleScriptEntry(self.controls.updatePillBar)
    scheduler:unscheduleScriptEntry(self.controls.continuousEatPill)
end

function SkillPanel:createFixedUI()
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(cc.size(416, 586))
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_792.png")
    detailName:setTouchEnable(false)
    detailName:setPosition(0, size.height * 0.42)
    self:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(-size.width * 0.2, size.height * 0.42)
    self:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(size.width * 0.2, size.height * 0.42)
    self:addChild(line)

    self.controls.skillNum = createMixSprite("image/ui/img/btn/btn_781.png")
    self.controls.skillNum:setTouchEnable(false)
    self.controls.skillNum:setCircleFont("技能点:"..GameCache.Avatar.SkillPoint, 1, 1, 20, cc.c3b(78, 160, 190))
    self.controls.skillNum:setPosition(0, size.height * 0.34)
    self:addChild(self.controls.skillNum)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(-size.width * 0.3, size.height * 0.34)
    self:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(size.width * 0.3, size.height * 0.34)
    self:addChild(line)
    
    local function rpSkillUI()
        self.controls.rpSkillSpri = SkillIcon.new("image/icon/border/border_star_3.png")
        self.controls.rpSkillSpri:setPosition(-size.width * 0.32, size.height * 0.22)
        self:addChild(self.controls.rpSkillSpri)

        self.controls.rpSkillName = Common.finalFont("怒技 - ", -size.width * 0.18, size.height * 0.27, 20, nil)
        self.controls.rpSkillName:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.rpSkillName)

        self.controls.rpSkillLevel = ColorLabel.new("", 20)
        self.controls.rpSkillLevel:setPosition(-size.width * 0.18, size.height * 0.21)
        self.controls.rpSkillLevel:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.rpSkillLevel)

        local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_782.png")
        bar_BG:setPosition(10, size.height * 0.16)
        self:addChild(bar_BG)
        self.controls.bar_rpSkillExp = ccui.LoadingBar:create("image/ui/img/btn/btn_789.png")
        self.controls.bar_rpSkillExp:setScaleX(1.65)
        self.controls.bar_rpSkillExp:setPercent(50)
        self.controls.bar_rpSkillExp:setPosition(bar_BG:getContentSize().width * 0.5, bar_BG:getContentSize().height * 0.5)
        bar_BG:addChild(self.controls.bar_rpSkillExp)

        self.controls.rpSkillExp = Common.finalFont("100/200", 10, size.height * 0.21, 20)
        self.controls.rpSkillExp:enableOutline(cc.c4b(6,66,0,255), 2)
        self.controls.rpSkillExp:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.rpSkillExp)

        self.controls.maxLevel = Common.finalFont("当前上限:X级", 0, size.height * 0.11, 16)
        self.controls.maxLevel:enableOutline(cc.c4b(6,66,0,255), 2)
        self.controls.maxLevel:setAdditionalKerning(-2)
        self:addChild(self.controls.maxLevel)

        self.controls.skillBtn = createMixSprite("image/ui/img/btn/btn_582.png","image/ui/img/btn/btn_784.png")
        self.controls.skillBtn:setPosition(size.width * 0.36, size.height * 0.22)
        self:addChild(self.controls.skillBtn)
        self.controls.skillBtn:addTouchEventListener(function(sender, eventType, isIn)
            local function longTouchEvent(dt)
                if self.scheduler_updateLongTouch_skill then
                    scheduler:unscheduleScriptEntry(self.scheduler_updateLongTouch_skill)
                    self.scheduler_updateLongTouch_skill = nil
                end
                self.data.isContinuousEat = true
            end

            if eventType == ccui.TouchEventType.began then
                if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.heroSkill then
                    Common.openLevelDesc(BaseConfig.OpenSystemLevel.heroSkill)
                    return 
                end

                self.data.currEatSkillNum = 0
                if 0 == GameCache.Avatar.SkillPoint then
                    application:showFlashNotice("技能点不足")
                    self.data.isCanUpgrade = false
                elseif self.data.needMaxSkillExp <= 0 then
                    application:showFlashNotice("法术等级已达当前上限")
                    self.data.isCanUpgrade = false
                else
                    Common.addTopSwallowLayer()
                    self.data.currEatSkillNum = self.data.currEatSkillNum + 1
                    GameCache.Avatar.SkillPoint = GameCache.Avatar.SkillPoint - 1
                    self.controls.skillNum:setString("技能点:"..GameCache.Avatar.SkillPoint)
                    self.data.needAddSkillExp = self.data.needAddSkillExp + 1
                    self.data.needMaxSkillExp = self.data.needMaxSkillExp - 1
                    self.scheduler_updateLongTouch_skill = scheduler:scheduleScriptFunc(longTouchEvent, 1, false)
                    self.data.isTouchEatPill = true
                    self.data.isCanUpgrade = true
                end
            end

            local function upgradeFunc()
                Common.removeTopSwallowLayer()
                if self.scheduler_updateLongTouch_skill then
                    scheduler:unscheduleScriptEntry(self.scheduler_updateLongTouch_skill)
                    self.scheduler_updateLongTouch_skill = nil
                end
                if self.data.isContinuousEat then
                    self.data.isContinuousEat = false
                end
                if self.data.isCanUpgrade then
                    self.data.isCanUpgrade = false
                    self:UpgradeRPSkill(self.data.chooseHeroInfo.ID, self.data.currEatSkillNum)
                end
            end
            if (eventType == ccui.TouchEventType.moved) then
                if not isIn then
                    upgradeFunc()
                end
            end
            if (eventType == ccui.TouchEventType.ended) then
                Common.CloseSystemLayer({2})
                Common.OpenSystemLayer({2})
                -- if GameCache.NewbieGuide.Step == 8 then
                --     Common.SaveGuideLayer(  )

                --     local guide = self:CreateSwallowGuideLayer( 0,0,SCREEN_WIDTH,SCREEN_HEIGHT )
                --     local scene = cc.Director:getInstance():getRunningScene()
                --     scene:addChild(guide)
                -- end
                

                upgradeFunc()
            end
            if (eventType == ccui.TouchEventType.canceled) then
                upgradeFunc()
            end
        end)
    end

    self.controls.skillPointTips = require("tool.helper.CurrencyIcon").new({Type = 4, ID = 1008})
    self.controls.skillPointTips:setPosition(size.width * 0.36, size.height * 0.22)
    self:addChild(self.controls.skillPointTips)
    self.controls.skillPointTips:getIconSpri():setOpacity(0)
    self.controls.skillPointTips:setGetWay(true)

    local detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("星将升星能提升以下法术技能", 1, 1, 20, cc.c3b(78, 160, 190))
    detailName:setPosition(0, size.height * 0.02)
    self:addChild(detailName)
    local function norSkillUI()
        self.controls.norSkillSpri = SkillIcon.new("image/icon/border/border_star_3.png")
        self.controls.norSkillSpri:setPosition(-size.width * 0.32, -size.height * 0.11)
        self:addChild(self.controls.norSkillSpri)

        self.controls.norSkillName = Common.finalFont("普技 - ", -size.width * 0.18, -size.height * 0.08, 20, nil)
        self.controls.norSkillName:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.norSkillName)

        self.controls.norSkillLevel = ColorLabel.new("", 20)
        self.controls.norSkillLevel:setPosition(-size.width * 0.18, -size.height * 0.16)
        self.controls.norSkillLevel:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.norSkillLevel)
    end
    local function tfSkillUI()
        self.controls.tfSkillSpri = SkillIcon.new("image/icon/border/border_star_3.png")
        self.controls.tfSkillSpri:setPosition(-size.width * 0.32, -size.height * 0.295)
        self:addChild(self.controls.tfSkillSpri)

        self.controls.tfSkillName = Common.finalFont("天赋 - ", -size.width * 0.18, -size.height * 0.265, 20, nil)
        self.controls.tfSkillName:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.tfSkillName)

        self.controls.tfSkillLevel = ColorLabel.new("", 20)
        self.controls.tfSkillLevel:setPosition(-size.width * 0.18, -size.height * 0.345)
        self.controls.tfSkillLevel:setAnchorPoint(0, 0.5)
        self:addChild(self.controls.tfSkillLevel)
    end
    rpSkillUI()
    norSkillUI()
    tfSkillUI()

    local line = cc.Sprite:create("image/ui/img/btn/btn_783.png")
    line:setPosition(0, -size.height * 0.2)
    self:addChild(line)
    
    -- local detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    -- detailName:setTouchEnable(false)
    -- detailName:setCircleFont("装备穿戴后即与星将绑定", 1, 1, 20, cc.c3b(78, 160, 190))
    -- detailName:setPosition(0, -size.height * 0.348)
    -- self:addChild(detailName)
    -- local function emotionSkill()
    --     self.controls.emotionSkill = Common.finalFont("", -size.width * 0.4, -size.height * 0.39, 20, cc.c3b(139, 207, 231))
    --     self.controls.emotionSkill:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    --     self.controls.emotionSkill:setAnchorPoint(0, 1)
    --     self:addChild(self.controls.emotionSkill)
    -- end
    -- emotionSkill()
end

function SkillPanel:updateHeroInfo(heroInfo, configInfo)
    self.data.chooseHeroInfo = heroInfo
    self.data.chooseHeroConfigInfo = configInfo
    
    self.data.isCurrHeroMaxLevel = false
    self.data.needAddSkillExp = heroInfo.RPSkillExp
    self.data.needMaxSkillExp = self:getMaxLevelNeedSkillExp(heroInfo)
    self:updateSkill(heroInfo, configInfo)
    -- self:updateEmotionSkill(configInfo)
end

function SkillPanel:updateSkill(heroInfo, configInfo)
    local addRpSkillUp = CalHeroAttr.HeroAddRPSkillLevel(heroInfo)
    local addNorSkillUp = 0
    local addTfSkillUp = 0
    local rpSkillStr = ""
    local norSkillStr = ""
    local tfSkillStr = ""
    for k,equip in pairs(heroInfo.Equip) do
        if 0 ~= equip.ID then
            local equipConfig = BaseConfig.GetEquip(equip.ID, equip.StarLevel)
            addNorSkillUp = addNorSkillUp + equipConfig.norSkillUp
            addTfSkillUp = addTfSkillUp + equipConfig.tfSkillUp
        end
    end
    addNorSkillUp = addNorSkillUp + GameCache.Avatar.EnergeAttrTab[BaseConfig.ENERGYATTR_TYPE_ADDNORSKILLLEVEL]
    addTfSkillUp = addTfSkillUp + GameCache.Avatar.EnergeAttrTab[BaseConfig.ENERGYATTR_TYPE_ADDTFSKILLLEVEL]

    if 0 == addRpSkillUp then
        rpSkillStr = ""
    else
        rpSkillStr = "+"..addRpSkillUp
    end
    if 0 == addNorSkillUp then
        norSkillStr = ""
    else
        norSkillStr = "+"..addNorSkillUp
    end
    if 0 == addTfSkillUp then
        tfSkillStr = ""
    else
        tfSkillStr = "+"..addTfSkillUp
    end

    self.controls.skillNum:setString("技能点:"..GameCache.Avatar.SkillPoint)
    self.controls.maxLevel:setString("当前上限:"..heroInfo.MaxRPSkillLevel.."级")
    local rpSkillID = configInfo.rpSkill
    local rpSkillLevel = heroInfo.RPSkillLevel
    local rpConfig = BaseConfig.GetHeroSkill(rpSkillID, rpSkillLevel)
    self.controls.rpSkillName:setString("怒技 - ".. rpConfig.name)
    self.controls.rpSkillLevel:setString("[255,247,174]"..rpSkillLevel.."[=][0,255,0]"..rpSkillStr.."[=][255,247,174]级[=]")
    self.controls.rpSkillExp:setString(heroInfo.RPSkillExp.."/"..BaseConfig.GetHeroRPSkillExp(rpSkillLevel))
    self.controls.bar_rpSkillExp:setPercent(heroInfo.RPSkillExp / BaseConfig.GetHeroRPSkillExp(rpSkillLevel) * 100)
    self.controls.rpSkillSpri:setChildTexture("image/icon/skill/"..rpConfig.Res..".png")
    local skillInfo = {}
    skillInfo.config = rpConfig
    skillInfo.Level = rpSkillLevel + addRpSkillUp
    self.controls.rpSkillSpri:setSkillInfo(skillInfo)

    local  norSkillID = configInfo.norSkill
    local  norSkillLevel = heroInfo.NorSkillLevel
    local  norConfig = BaseConfig.GetHeroSkill(norSkillID, norSkillLevel)
    self.controls.norSkillName:setString("普技 - ".. norConfig.name)
    self.controls.norSkillLevel:setString("[255,247,174]"..(norSkillLevel - addNorSkillUp).."[=][0,255,0]"..norSkillStr.."[=][255,247,174]级[=]")
    self.controls.norSkillSpri:setChildTexture("image/icon/skill/".. norConfig.Res .. ".png")
    local skillInfo = {}
    skillInfo.config = norConfig
    skillInfo.Level = norSkillLevel
    self.controls.norSkillSpri:setSkillInfo(skillInfo)

    local  tfSkillID = configInfo.tfSkill
    local  tfSkillLevel = heroInfo.TFSkillLevel
    local  tfConfig = BaseConfig.GetHeroSkill(tfSkillID, tfSkillLevel)
    self.controls.tfSkillName:setString("天赋 - "..tfConfig.name)
    self.controls.tfSkillLevel:setString("[255,247,174]"..(tfSkillLevel - addTfSkillUp).."[=][0,255,0]"..tfSkillStr.."[=][255,247,174]级[=]")
    self.controls.tfSkillSpri:setChildTexture("image/icon/skill/"..tfConfig.Res..".png")
    local skillInfo = {}
    skillInfo.config = tfConfig
    skillInfo.Level = tfSkillLevel
    self.controls.tfSkillSpri:setSkillInfo(skillInfo)

    if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.heroSkill then
        self.controls.skillBtn:setNorGLProgram(false)
    end
    if 0 == GameCache.Avatar.SkillPoint then
        self.controls.skillPointTips:setTouchEnable(true)
        self.controls.skillBtn:setTouchEnable(false)
    else
        self.controls.skillPointTips:setTouchEnable(false)
        self.controls.skillBtn:setTouchEnable(true)
    end
end

function SkillPanel:updateEmotionSkill(configInfo)
    if configInfo.mood[1] > 0 then
        self.controls.emotionSkill:setVisible(true)
        local name = BaseConfig.GetHero(configInfo.mood[1], 0).name
        local row, str = Common.StringLinefeed("当自身情绪达到亢奋时，对"..name.."的伤害增加50%。", 16)
        self.controls.emotionSkill:setString(str)
    else
        self.controls.emotionSkill:setVisible(false)
    end
end

function SkillPanel:getMaxLevelNeedSkillExp(heroInfo)
    local rpSkill = heroInfo.RPSkillLevel
    local maxRPSkill = heroInfo.MaxRPSkillLevel
    if rpSkill == maxRPSkill then
        return 0
    end
    local rpSkillExp = heroInfo.RPSkillExp
    local totalSkill = BaseConfig.GetHeroRPSkillExp(rpSkill) - rpSkillExp
    for i=(rpSkill + 1),(maxRPSkill - 1) do
        local exp = BaseConfig.GetHeroRPSkillExp(i)
        totalSkill = totalSkill + exp
    end
    return totalSkill
end

function SkillPanel:getPropsNumByID(id, minusNum)
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

function SkillPanel:continuousEatPillEvent(dt)
    if self.data.isContinuousEat then 
        if GameCache.Avatar.SkillPoint < 1 then
            self.data.isContinuousEat = false
            application:showFlashNotice("技能点不足")
            application:dispatchCustomEvent(AppEvent.UI.Hero.IsShowAlert, {HeroInfo = self.data.chooseHeroInfo, IsSkill = true})
        elseif self.data.needMaxSkillExp <= 0 then
            self.data.isContinuousEat = false
            self.data.needMaxSkillExp = 0
            application:showFlashNotice("法术等级已达当前上限")
            application:dispatchCustomEvent(AppEvent.UI.Hero.IsShowAlert, {HeroInfo = self.data.chooseHeroInfo, IsSkill = true})
        else
            self.data.currEatSkillNum = self.data.currEatSkillNum + 1
            GameCache.Avatar.SkillPoint = GameCache.Avatar.SkillPoint - 1
            self.controls.skillNum:setString("技能点:"..GameCache.Avatar.SkillPoint)
            self.data.needAddSkillExp = self.data.needAddSkillExp + 1
            self.data.needMaxSkillExp = self.data.needMaxSkillExp - 1
            self.data.isTouchEatPill = true
        end
    end
end

function SkillPanel:updateBarExpEvent(dt)
    if self.data.isTouchEatPill then
        local skillLevel = self.data.chooseHeroInfo.RPSkillLevel
        if skillLevel < 8 then
            self.data.chooseHeroInfo.RPSkillExp = self.data.chooseHeroInfo.RPSkillExp + BaseConfig.GetHeroRPSkillExp(skillLevel)
        else
            self.data.chooseHeroInfo.RPSkillExp = math.floor(self.data.chooseHeroInfo.RPSkillExp + BaseConfig.GetHeroRPSkillExp(skillLevel) / 10)
        end
        self.controls.rpSkillExp:setString(self.data.chooseHeroInfo.RPSkillExp.."/"..BaseConfig.GetHeroRPSkillExp(skillLevel))
        self.controls.bar_rpSkillExp:setPercent(self.data.chooseHeroInfo.RPSkillExp / BaseConfig.GetHeroRPSkillExp(skillLevel) * 100)

        if self.data.chooseHeroInfo.RPSkillExp > self.data.needAddSkillExp then
            self.data.isTouchEatPill = false
            self.data.chooseHeroInfo.RPSkillExp = self.data.needAddSkillExp
            self.controls.rpSkillExp:setString(self.data.chooseHeroInfo.RPSkillExp.."/"..BaseConfig.GetHeroRPSkillExp(skillLevel))
            self.controls.bar_rpSkillExp:setPercent(self.data.chooseHeroInfo.RPSkillExp / BaseConfig.GetHeroRPSkillExp(skillLevel) * 100)
        end

        if self.data.chooseHeroInfo.RPSkillExp >= BaseConfig.GetHeroRPSkillExp(skillLevel) then
            local beforeHeroInfo = Common.copyTab(self.data.chooseHeroInfo)
            self.data.isTouchEatPill = true
            self.data.chooseHeroInfo.RPSkillLevel = self.data.chooseHeroInfo.RPSkillLevel + 1
            self.data.chooseHeroInfo.RPSkillExp = 0
            self.controls.rpSkillExp:setString(self.data.chooseHeroInfo.RPSkillExp.."/"..BaseConfig.GetHeroRPSkillExp(skillLevel))
            self.controls.bar_rpSkillExp:setPercent(0)

            if self.data.chooseHeroInfo.RPSkillLevel >= self.data.chooseHeroInfo.MaxRPSkillLevel then
                self.data.isTouchEatPill = false
                self.data.chooseHeroInfo.RPSkillLevel = self.data.chooseHeroInfo.MaxRPSkillLevel
                self.data.needAddSkillExp = self.data.chooseHeroInfo.RPSkillExp
            else
                self.data.needAddSkillExp = self.data.needAddSkillExp - BaseConfig.GetHeroRPSkillExp(skillLevel)

                if nil == self.controls.upgradeEffect then
                    local bgSize = self.controls.bg:getContentSize()
                    self.controls.upgradeEffect = effects:CreateAnimation(self, -bgSize.width * 0.32, bgSize.height * 0.2, nil, 30, false)
                else
                    effects:RepeatAnimation(self.controls.upgradeEffect)
                end
            end
            self:updateSkill(self.data.chooseHeroInfo, self.data.chooseHeroConfigInfo)
            application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateAttribute, 
                                                {BeforeHero = beforeHeroInfo, CurrHero = self.data.chooseHeroInfo})
        end
    end
end

--[[
    技能升级
]]
function SkillPanel:UpgradeRPSkill(heroID, skillNum)
    rpc:call("Hero.UpgradeRPSkill", {ID = heroID, SkillPoint = skillNum}, function(event)
        application:dispatchCustomEvent(AppEvent.UI.Hero.IsShowAlert, {HeroInfo = self.data.chooseHeroInfo, IsSkill = true})
        if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.heroSkill then
            self.controls.skillBtn:setNorGLProgram(false)
        end
        if 0 == GameCache.Avatar.SkillPoint then
            self.controls.skillPointTips:setTouchEnable(true)
            self.controls.skillBtn:setTouchEnable(false)
        else
            self.controls.skillPointTips:setTouchEnable(false)
            self.controls.skillBtn:setTouchEnable(true)
        end
    end)
end

function SkillPanel:CreateSwallowGuideLayer( posx,posy,width,height )
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), width, height)
    layer:setPosition(posx, posy)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function() return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function ( ) 
        Common.CloseGuideLayer({8})
        Common.ResetGuideLayer({big = 9, small = 3})
        Common.OpenGuideLayer({9})
        layer:removeFromParent() 
        layer = nil 
    end,   cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    return layer
end

return SkillPanel
