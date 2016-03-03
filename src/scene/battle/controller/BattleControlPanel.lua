--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-7
-- Time: 上午10:32
-- To change this template use File | Settings | File Templates.
--

-- TODO: 准备把怒气按钮等单独出来
local CommonTool = require("tool.helper.Common")
local ElemType = require("config.ElemType")
-------------------------------------------------------------------------------

local BattleControlPanel = class("BattleControlPanel", function() return cc.Node:create() end)

function BattleControlPanel:ctor(battleModel, controller, heroModels)
    self.battleModel = battleModel
    self.controller = controller
    self.heroModels = heroModels

    self.rageLabel = nil
    self.controlsMap = {}
    for _, hero in ipairs(heroModels) do
       self.controlsMap[hero] = {}
    end

    self:setupUI()

    self:registerClickHandler()
end

function BattleControlPanel:registerClickHandler()
    -- 在有英雄需要复活，且点击对象不为英雄头像是激活
    local leftTeam = self.battleModel.leftTeam

    local function onTouchBegan(touch, event)
        if leftTeam:getResurrectionData() == nil then
            return false
        end

        local location = touch:getLocation()
        for hero, controls in pairs(self.controlsMap) do
            local button = controls.Button
            local rect = button:getBoundingBox()
            if cc.rectContainsPoint(rect, location) then
                CCLog("复活点击:", hero:getName())
                return false
            end
        end

        return true
    end

    local function onTouchEnded(touch, event)
        CCLog("取消复活")
        leftTeam:resetResurrectionData()
        self:refresh()
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function BattleControlPanel:setHeroRageButton(heroModel, button)
    self.controlsMap[heroModel].Button = button
end

function BattleControlPanel:getHeroRageButton(heroModel)
    return self.controlsMap[heroModel].Button
end

function BattleControlPanel:showHeroDieIcon(heroModel)
    local icon = self.controlsMap[heroModel].DieIcon
    if icon == nil then
        --icon = cc.Sprite:create("image/spine/skill_effect/die.png")
        icon = cc.Sprite:createWithSpriteFrameName("die.png")        
        local button = self:getHeroRageButton(heroModel)
        icon:setPosition(cc.p(52, 47))
        button:addChild(icon)
        self.controlsMap[heroModel].DieIcon = icon
        icon:setVisible(false)
    end

    if not icon:isVisible() then
        icon:setScale(1.5)
        icon:runAction(cc.Sequence:create({
            cc.Show:create(),
            cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1)),
        }))
    end
end

function BattleControlPanel:getHeroDieIcon(heroModel)
    return self.controlsMap[heroModel].DieIcon
end

function BattleControlPanel:hideHeroDieIcon(heroModel)
    local icon = self.controlsMap[heroModel].DieIcon
    if icon then
        icon:setVisible(false)
    end
end

function BattleControlPanel:setHeroHPBar(heroModel, HPBar)
    self.controlsMap[heroModel].HPBar = HPBar
end

function BattleControlPanel:getHeroHPBar(heroModel)
    return self.controlsMap[heroModel].HPBar
end

function BattleControlPanel:setHeroCDBar(heroModel, CDBar)
    self.controlsMap[heroModel].CDBar = CDBar
end

function BattleControlPanel:getHeroCDBar(heroModel)
    return self.controlsMap[heroModel].CDBar
end

function BattleControlPanel:setHeroRageAni(heroModel, ani)
    self.controlsMap[heroModel].RageAni = ani
end

function BattleControlPanel:getHeroRageAni(heroModel)
    return self.controlsMap[heroModel].RageAni
end

function BattleControlPanel:setHeroReliveAni(heroModel, ani)
    self.controlsMap[heroModel].ReliveAni = ani
end

function BattleControlPanel:getHeroReliveAni(heroModel)
    return self.controlsMap[heroModel].ReliveAni
end

function BattleControlPanel:setHeroComboAni(heroModel, ani)
    self.controlsMap[heroModel].ComboAni = ani
end

function BattleControlPanel:getHeroComboAni(heroModel)
    return self.controlsMap[heroModel].ComboAni
end

function BattleControlPanel:setHeroComboHint(heroModel, ani)
    self.controlsMap[heroModel].ComboHint = ani
end

function BattleControlPanel:getHeroComboHint(heroModel)
    return self.controlsMap[heroModel].ComboHint
end

function BattleControlPanel:setHeroClickAni(heroModel, ani)
    self.controlsMap[heroModel].ClickAni = ani
end

function BattleControlPanel:getHeroClickAni(heroModel)
    return self.controlsMap[heroModel].ClickAni
end

function BattleControlPanel:setupUI()
    local PANEL_WIDTH = nil

    --local panelBg = cc.Sprite:create("image/ui/img/bg/bg_266.png")
    local panelBg = cc.Sprite:createWithSpriteFrameName("bg_266.png")    
    panelBg:setAnchorPoint(cc.p(0.5, 0.5))
    panelBg:setPosition(cc.p(SCREEN_WIDTH - 350, 38))
    self:addChild(panelBg)

    PANEL_WIDTH = panelBg:getContentSize().width

    local buttonPanel = cc.Node:create()
    buttonPanel:setAnchorPoint(cc.p(0.5, 0.5))
    buttonPanel:setContentSize(cc.size(PANEL_WIDTH, 150))
    buttonPanel:setPosition(cc.p(SCREEN_WIDTH - 350, 75))
    self:addChild(buttonPanel)

    --local spirteRage = cc.Sprite:create("image/ui/img/btn/btn_public_rage.png")
    local spirteRage = cc.Sprite:createWithSpriteFrameName("btn_public_rage.png")
    spirteRage:setPosition(cc.p(80, 25))
    buttonPanel:addChild(spirteRage, 999)

    -- local teamRageBg = cc.Sprite:create("image/spine/skill_effect/nuqi/NQkuang.png")
    local teamRageBg = cc.Sprite:createWithSpriteFrameName("NQkuang.png")
    teamRageBg:setPosition(cc.p(80, 95))
    teamRageBg:setScale(1)
    buttonPanel:addChild(teamRageBg)

    -- local teamRageImge = "image/spine/skill_effect/nuqi/NQhexin.png"
    -- local teamRageBar = cc.ProgressTimer:create(cc.Sprite:create(teamRageImge))
    local teamRageBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("NQhexin.png"))
    teamRageBar:setName("teamRageBar")
    teamRageBar:setScale(1)
    teamRageBar:setPosition(cc.p(80, 95))
    teamRageBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    teamRageBar:setMidpoint(cc.p(1, 0))
    teamRageBar:setBarChangeRate(cc.p(0, 1))
    teamRageBar:setPercentage(0)
    buttonPanel:addChild(teamRageBar)
    self.teamRageBar = teamRageBar

    local aniPath = "image/spine/skill_effect/nuqi/"
    local teamRageAni = load_animation(aniPath)
    teamRageAni:setAnimation(0, "animation", true)
    teamRageAni:setPosition(cc.p(80, 95))
    buttonPanel:addChild(teamRageAni)

    local rageLabel = CommonTool.finalFont("0", 0 , 0 , 35, cc.c3b(255, 255, 0), 1) 
    rageLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rageLabel:setPosition(cc.p(80, 95))
    buttonPanel:addChild(rageLabel, 999)
    self.rageLabel = rageLabel

    -- local rageIcon = cc.Sprite:create("image/ui/img/btn/btn_236.png")
    local rageIcon = cc.Sprite:createWithSpriteFrameName("btn_236.png")    
    rageIcon:setPosition(cc.p(100, 20))
    rageIcon:setScale(1.4)
    buttonPanel:addChild(rageIcon)

    if self.controller:needShowFingerAnimation() then
        local fingerAni = load_animation("res/image/spine/ui_effect/1")
        buttonPanel:addChild(fingerAni, 1)
        fingerAni:setVisible(false)
        fingerAni:setAnimation(0, "animation", true)
        self.fingerAni = fingerAni
    end

--    local rageNeedTitleLabel = CommonTool.finalFont("消耗", 0 , 0 , 18, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("消耗", "Arial", 18)
--    rageNeedTitleLabel:setColor(cc.c3b(255, 255, 0))
--    rageNeedTitleLabel:setPosition(cc.p(120, 15))
--    buttonPanel:addChild(rageNeedTitleLabel, 999)

    local width = PANEL_WIDTH / 6.5
    local heroModels = self.heroModels
    local centerPosX = PANEL_WIDTH / 2 + 50
    local heroCount = #heroModels
    local centerIndex = heroCount / 2
    for i = 1, 5 do
        local heroModel = heroModels[i]

        if heroModel then
            CCLog("初始化怒气按钮", heroModel:getName())
            local posX = centerPosX + (centerIndex - i + 0.5) * width
            -- local borderIcon = heroModel:getBorderIcon()
            -- local heroRageButton = ccui.Button:create(borderIcon)
            local borderIconName = heroModel:getBorderIconName()
            local heroRageButton = ccui.Button:create(borderIconName, borderIconName, borderIconName, ccui.TextureResType.plistType)
            
            heroRageButton:setTitleText(heroModel:getName())
            heroRageButton:setPosition(posX, 65)
            heroRageButton:setTitleFontSize(18)
            heroRageButton:addTouchEventListener(function ( sender, eventType )
                if eventType == ccui.TouchEventType.began then
                    self.controller:clearHeroRageScopeHighlight()
                elseif eventType == ccui.TouchEventType.ended then
                    if self.fingerAni then
                        self.fingerAni:setVisible(false)
                    end

                    CCLog("怒气按钮 按下", heroModel:getName())

                     if not self.controller:enableRageSkill(heroModel) then
                        CCLog("正在新手引导")
                        if heroModel:isInRageScopeSelecting() then
                            -- 再次点击头像，直接释放范围选择怒气技能
                            self.controller:doneRegionSelection(heroModel)
                        end
                        return
                    end

                    if self.controller:isInRageAttacking() then
                        CCLog("正在释放怒气技能")
                        return
                    end

                    if heroModel then
                        if heroModel:isAlive() then
                            if heroModel:isInRageScopeSelecting() then
                                -- 再次点击头像，直接释放范围选择怒气技能
                                self.controller:doneRegionSelection(heroModel)
                            else
                                CCLog(heroModel:getName(), "释放怒气技能")
                                heroModel:performRageSkill()
                                

                                local clickAni = self:getHeroClickAni(heroModel)
                                clickAni:setAnimation(0, "animation", false)
                                clickAni:setVisible(true)
                            end
                        else
                            local team = self.battleModel:getTeam(heroModel:getTeamSide())
                            if team:heroCanResurrect(heroModel) then
                                team:resurrectHero(heroModel, self.battleModel)
                            else
                                CCLog("dead hero can't use skill")
                            end
                        end
                    end
                end
            end)

            local btnSize = heroRageButton:getContentSize()
            heroRageButton:setTouchEnabled(false)
            heroRageButton:setScale(0.825)
            local heroIcon = heroModel:isMonster() and cc.Sprite:createWithSpriteFrameName(heroModel:getHeroImageName()) or GoodsInfoNode.new(BaseConfig.GOODS_HERO, heroModel._heroData)
            heroIcon:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            heroRageButton:addChild(heroIcon)
            buttonPanel:addChild(heroRageButton)
            self:setHeroRageButton(heroModel, heroRageButton)
            CCLog(vardump(buttonPanel:convertToWorldSpace(cc.p(heroRageButton:getPosition())), "rage button pos" .. i))

            local btnSize = heroRageButton:getContentSize()
            local aniRageActive = load_animation("image/spine/skill_effect/ragebox/blue/", 1)
            heroRageButton:addChild(aniRageActive)
            aniRageActive:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            aniRageActive:setAnimation(0, "animation", true)
            aniRageActive:setVisible(false)
            self:setHeroRageAni(heroModel, aniRageActive)

            local aniReliveActive = load_animation("image/spine/skill_effect/ragebox/pink/", 1)
            heroRageButton:addChild(aniReliveActive)
            aniReliveActive:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            aniReliveActive:setAnimation(0, "animation", true)
            aniReliveActive:setVisible(false)
            self:setHeroReliveAni(heroModel, aniReliveActive)

            local aniRageClick = load_animation("image/spine/skill_effect/rageclick/", 1)
            aniRageClick:setScale(1.25)
            heroRageButton:addChild(aniRageClick)
            aniRageClick:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            aniRageClick:setVisible(false)
            aniRageClick:registerSpineEventHandler(function(event)
                aniRageClick:setVisible(false)
            end, sp.EventType.ANIMATION_END)
            self:setHeroClickAni(heroModel, aniRageClick)

            local aniComboHit = load_animation("image/spine/skill_effect/ragebox/green/", 0.75)
            aniComboHit:setScale(1.25)
            heroRageButton:addChild(aniComboHit)
            aniComboHit:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            aniComboHit:setAnimation(0, "animation", true)
            aniComboHit:setVisible(false)
            self:setHeroComboAni(heroModel, aniComboHit)

            --local rageComboHint = cc.LabelTTF:create("五行相生加成", "Arial", 22, cc.size(200, 28), cc.TEXT_ALIGNMENT_CENTER)
            local rageComboHint = CommonTool.finalFont("五行相生加成", 0 , 0 , 28, cc.c3b(255, 255, 255), 1)
            rageComboHint:setColor(cc.c3b(0, 255, 0))
            rageComboHint:setPosition(cc.p(50, 50))
            heroRageButton:addChild(rageComboHint)
            rageComboHint:setAnchorPoint(cc.p(0.5, 0.5))
            rageComboHint:setVisible(false)
            self:setHeroComboHint(heroModel, rageComboHint)

            -- local rageSkillCDImge = "image/ui/img/btn/btn_252.png"
            -- local rageCDBar = cc.ProgressTimer:create(cc.Sprite:create(rageSkillCDImge))
            local rageCDBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("btn_252.png"))
            rageCDBar:setScale(0.7 * 1.5)
            rageCDBar:setOpacity(150)
            rageCDBar:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            rageCDBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            --rageCDBar:setMidpoint(cc.p(0, 1))
            rageCDBar:setMidpoint(cc.p(0.5, 0.5))
            rageCDBar:setBarChangeRate(cc.p(0, 1))
            rageCDBar:setPercentage(0)
            heroRageButton:addChild(rageCDBar)
            self:setHeroCDBar(heroModel, rageCDBar)

--            local rageIcon = cc.Sprite:create("image/ui/img/btn/btn_236.png")
--            rageIcon:setPosition(cc.p(posX - width * 0.15, 15))
--            buttonPanel:addChild(rageIcon)

            -- local rageHeader = cc.Sprite:create("image/ui/img/bg/bg_rage_top.png")
            local rageHeader = cc.Sprite:createWithSpriteFrameName("bg_rage_top.png")            
            rageHeader:setPosition(cc.p(posX, 113))
            buttonPanel:addChild(rageHeader)

            local power = heroModel:rageConsumeRage() or ""
            local rageNeedLabel = CommonTool.finalFont("" .. power, 0 , 0 , 18, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("" .. power, "Arial", 18)
            rageNeedLabel:setColor(cc.c3b(255, 255, 0))
            rageNeedLabel:setPosition(cc.p(posX + 1, 112))
            buttonPanel:addChild(rageNeedLabel, 999)

            local wxBgSprite = cc.Sprite:create(heroModel:getElemTypeIcon())
            wxBgSprite:setPosition(cc.p(posX + width * 0.3, 33))
            buttonPanel:addChild(wxBgSprite)

            -- local hpBgSprite = cc.Sprite:create("image/ui/img/btn/btn_1021.png")
            local hpBgSprite = cc.Sprite:createWithSpriteFrameName("btn_1021.png")            
            hpBgSprite:setPosition(posX, 18)
            buttonPanel:addChild(hpBgSprite)

            local bgImage = "image/ui/img/btn/btn_234.png"
            local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
            hpBar:setPosition(posX, 18)
            hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            hpBar:setMidpoint(cc.p(0, 1))
            hpBar:setBarChangeRate(cc.p(1, 0))
            hpBar:setPercentage(100)
            buttonPanel:addChild(hpBar)
            self:setHeroHPBar(heroModel, hpBar)
        end
    end
end

function BattleControlPanel:updateCDBar()
    for _, hero in ipairs(self.heroModels) do
        if hero:isAlive() then
            if hero:rageSkillInCooling() then
                local ragePercent = 0
                local leftTime = hero:rageSkillCoolLeftTime()
                local CD = hero:rageSkillCoolTime()
                ragePercent = math.floor(leftTime / CD * 100)
                local rageCDBar = self:getHeroCDBar(hero)
                rageCDBar:setPercentage(ragePercent)
            else
                local rageCDBar = self:getHeroCDBar(hero)
                rageCDBar:setPercentage(0)
            end
        end
    end
end

function BattleControlPanel:updateHPBar()
    --CCLog("BattleControlPanel:updateHPBar()", #self.heroModels)
    for _, hero in ipairs(self.heroModels) do
        local hpBar = self:getHeroHPBar(hero)
        local hp = hero:getHP()
        local total = hero:getFullHP()

        --CCLog("BattleControlPanel:updateHPBar()", hero:getName(), hp, total)
        local percent = math.floor(hp * 100 / total)
        hpBar:setPercentage(percent)
    end
end

function BattleControlPanel:onTeamRageChanged(name, data)
    local leftTeam = self.battleModel.leftTeam
    local rage = leftTeam:getRage()
    self.rageLabel:setString("" .. rage)

    self.teamRageBar:setPercentage(rage)

    self:refresh()
end

function BattleControlPanel:onTeamComboHit(name, data)
    for _, hero in ipairs(self.heroModels) do
        local leftTeam = self.battleModel.leftTeam

        local buffElemType = leftTeam:getBuffElemType()
        local heroElemType = hero:getElemType()

        local rageComboHint = self:getHeroComboHint(hero)
        local comboTimes = leftTeam:getBuffComboHitTimes()

        if ElemType.generate(buffElemType, heroElemType) and hero:isAlive() then
            rageComboHint:setString(string.format("攻+%2d%%", comboTimes * 10))
            rageComboHint:setVisible(true)
        elseif (buffElemType == heroElemType) and hero:isAlive() then
            local percentAddition = (comboTimes - 1)* 10
            if percentAddition > 0 then
                rageComboHint:setString(string.format("攻+%2d%%", percentAddition))
                rageComboHint:setVisible(true)
            else
                rageComboHint:setVisible(false)
            end
        else
            rageComboHint:setVisible(false)
        end
    end
end

function BattleControlPanel:playRageActivation(heroRageButton)
    if heroRageButton:getChildByName("rage_skill_activation") then
        return
    end
    
    local btnSize = heroRageButton:getContentSize()
    local aniRageActivation = load_animation("image/spine/skill_effect/rageactive", 1)
    heroRageButton:addChild(aniRageActivation)
    aniRageActivation:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
    aniRageActivation:setAnimation(0, "animation", false)
    aniRageActivation:setName("rage_skill_activation")
    
    aniRageActivation:registerSpineEventHandler(function(event)
        aniRageActivation:setVisible(false)
        aniRageActivation:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.01),
            cc.RemoveSelf:create(),
        }))
    end, sp.EventType.ANIMATION_END)
end

function BattleControlPanel:refresh()
    local leftTeam = self.battleModel.leftTeam

    if leftTeam:getResurrectionData() ~= nil then
        CCLog("进入复活选择模式")
        for _, hero in pairs(self.heroModels) do
            local rageButton = self:getHeroRageButton(hero)
            local aniActive = self:getHeroRageAni(hero)
            local aniRelive = self:getHeroReliveAni(hero)
            local aniTeamRageCombo = self:getHeroComboAni(hero)

            if hero:isAlive() then
                rageButton:setTouchEnabled(false)
                aniActive:setVisible(false)
                aniRelive:setVisible(false)
                aniTeamRageCombo:setVisible(false)
                rageButton:setOpacity(150)
            else
                if not hero:isStucked() then
                    rageButton:setTouchEnabled(true)
                    aniRelive:setVisible(true)
                    aniActive:setVisible(false)
                    aniTeamRageCombo:setVisible(false)
                    rageButton:setOpacity(255)
                else
                    rageButton:setOpacity(80)
                    CCLog("被悬崖卡死的不能复活", hero:getName())
                end
            end
        end
    else
        local hasEnabled = false
        local inRegionRageSelecting = false
        for _, hero in pairs(self.heroModels) do
            if hero:isInRageScopeSelecting() then
                inRegionRageSelecting = true
            end

            local enabled, reason = hero:canReleaseRageSkill()

            local rageButton = self:getHeroRageButton(hero)

            if enabled and self.fingerAni then
                if not self.fingerAni:isVisible() and leftTeam:canAutoReleaseRageSkill(hero) then
                    self.fingerAni:setPosition(rageButton:getPosition())
                    self.fingerAni:setVisible(true)
                end
            end

            local aniActive = self:getHeroRageAni(hero)
            local aniTeamRageCombo = self:getHeroComboAni(hero)
            local aniRelive = self:getHeroReliveAni(hero)

            aniRelive:setVisible(false)
            if enabled then
                hasEnabled = true
                rageButton:setTouchEnabled(true)

                if leftTeam:hasElemBuff() then
                    local teamElemType = leftTeam:getBuffElemType()
                    local heroElemType = hero:getElemType()
                    if ElemType.generate(teamElemType, heroElemType) then
                        aniTeamRageCombo:setVisible(true)
                    end
                end

                local preEnabled = aniActive:isVisible() or aniTeamRageCombo:isVisible()
                if not preEnabled then
                    self:playRageActivation(rageButton)
                end

                aniActive:setVisible(enabled)
                if aniTeamRageCombo:isVisible() then
                    aniActive:setVisible(false)
                end
            else
                CCLog(hero:getName(), "不能释放怒气技能", reason)
                if hero:isInRageScopeSelecting() then
                    rageButton:setTouchEnabled(true)
                else
                    rageButton:setTouchEnabled(false)
                end

                aniActive:setVisible(false)
                aniTeamRageCombo:setVisible(false)
            end

            if not hero:isAlive() then                
                if not hero:isStucked() then
                    rageButton:setOpacity(150)
                    self:showHeroDieIcon(hero)
                else
                    rageButton:setOpacity(80)
                    local rageCDBar = self:getHeroCDBar(hero)
                    rageCDBar:setPercentage(100)
                end
            else
                rageButton:setOpacity(255)
                self:hideHeroDieIcon(hero)
            end
        end
        if self.fingerAni and (not hasEnabled or inRegionRageSelecting) then
            self.fingerAni:setVisible(false)
        end
    end

    self:updateHPBar()
end

return BattleControlPanel
