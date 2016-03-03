--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-9
-- Time: 下午9:03
-- To change this template use File | Settings | File Templates.
--
local BattleMapNode = require("scene.battle.view.BattleMapNode")
local GridLayer = require("scene.battle.helper.GridLayer")
--local FormationManager = require("data.FormationManager")
--local HeroDataManager = require("data.HeroDataManager")
local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
local BattleHeroView = require("scene.battle.view.BattleHeroView")
local BattleModel = require("scene.battle.model.BattleModel")
local ScopeGridNode = require("scene.battle.helper.ScopeGridNode")
local ScopeDragNode = require("scene.battle.helper.ScopeDragNode")
local BHT = require("tool.lib.BehaviourTree")
local BattleHelper = require("scene.battle.helper.BattleHelper")
local ElemType = require("config.ElemType")
local Effects = require("tool.helper.Effects")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
local BuffModel = require("scene.battle.model.skill.BuffModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterModel = require("scene.battle.model.fighter.FighterModel")
-------------------------------------------------------------------------------

local BattleRecordPlayer = class("BattleRecordPlayer", function() return cc.Node:create() end)

function BattleRecordPlayer:ctor(recordData)
    self.recordData = recordData

    self.dispatcher = nil     -- event dispatcher
    self.scheduleEntryID = nil -- update scheduler
    self.mapNode = nil

    self.paused = false
    self.heroControlsMap = {}
    self.heroRawCellMap = {}
    self.heroModelViewMap = {}

    self.battleModel = BattleModel.new(nil)

    self.backgroupNode = cc.Node:create()
    self:addChild(self.backgroupNode, 1)
    self.backgroupNode:setLocalZOrder(-9999)
    self.foregroundNode = cc.Node:create()
    self:addChild(self.foregroundNode, 2)

    self:createMap()

    self:initControlls()

    self:drawAttackScope()

    self:initControlPanel()

    self:registerNodeHandler()
    self:initDispatcher()
    self:registerBattleHandler()
end

function BattleRecordPlayer:initDispatcher()
    local dispatcher = cc.EventDispatcher:new()
    dispatcher:retain()
    dispatcher:setEnabled(true)
    self.dispatcher = dispatcher
end

function BattleRecordPlayer:registerNodeHandler()
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        elseif event == "cleanup" then
            self:onCleanup()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function BattleRecordPlayer:onEnter()
end

function BattleRecordPlayer:onExit()
end

function BattleRecordPlayer:onCleanup()
    self.dispatcher:release()

    if self.scheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end
end

function BattleRecordPlayer:onEnterTransitionFinish()

end

function BattleRecordPlayer:onExitTransitionStart()

end

-- 通过HeroModel获取HeroView
function BattleRecordPlayer:getHeroViewByModel(heroModel)
    local teamSide = heroModel:getTeamSide()
    if teamSide == "left" then
        return self.battleModel.leftTeam:getHeroView(heroModel)
    elseif teamSide == "right" then
        return self.battleModel.rightTeam:getHeroView(heroModel)
    else
        assert(0, "heroModel invalid")
    end
end

function BattleRecordPlayer:schudleUpdate()
    local scheduler = cc.Director:getInstance():getScheduler()

    if self.scheduleEntryID ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end

    local scheduleEntryID = scheduler:scheduleScriptFunc(handler(self, self.onUpdate), self.battleModel:getTimeUnit(), false)
    self.scheduleEntryID = scheduleEntryID
end

function BattleRecordPlayer:initControlls()
    local scopeGridNode = ScopeGridNode.new(assert(self.battleModel))
    self.backgroupNode:addChild(scopeGridNode)
    self.scopeGridNode = scopeGridNode

    --    local button = ccui.Button:create("dummy/GUI/button.png")
    --    button:setPosition(display.cx - 100,display.cy + 250)
    --    button:setTitleFontSize(18)
    --    button:setTitleText("1X")
    --    button:addTouchEventListener(widget_click_listener(function(sender)
    --        self.battleMode:setTimeUnit(0.1)
    --        self:schudleUpdate()
    --    end))
    --    self.foregroundNode:addChild(button)
    --
    --    local button = ccui.Button:create("dummy/GUI/button.png")
    --    button:setPosition(display.cx,display.cy + 250)
    --    button:setTitleFontSize(18)
    --    button:setTitleText("2X")
    --    button:addTouchEventListener(widget_click_listener(function(sender)
    --        self.battleMode:setTimeUnit(0.2)
    --        self:schudleUpdate()
    --    end))
    --    self.foregroundNode:addChild(button)

    --    local button = ccui.Button:create("dummy/GUI/button.png")
    --    button:setPosition(display.cx + 150,display.cy + 250)
    --    button:setTitleFontSize(18)
    --    button:setTitleText("刷新")
    --    button:addTouchEventListener(widget_click_listener(function(sender)
    --        application:enterScene("battle.BattleScene")
    --    end))
    --    self.foregroundNode:addChild(button)

    --    local button = ccui.Button:create("dummy/GUI/button.png")
    --    button:setPosition(display.cx + 260,display.cy + 250)
    --    button:setTitleFontSize(18)
    --    button:setTitleText("暂停")
    --    button:addTouchEventListener(widget_click_listener(function(sender)
    --        self.paused = not self.paused
    --        sender:setTitleText(self.paused and "继续" or "暂停")
    --    end))
    --    self.foregroundNode:addChild(button)

    --    local button = ccui.Button:create("dummy/GUI/button.png")
    --    button:setPosition(display.right - 100,display.cy + 100)
    --    button:setTitleFontSize(18)
    --    button:setTitleText("网格")
    --    button:addTouchEventListener(widget_click_listener(function(sender)
    --        local gridLayer = self.backgroupNode:getChildByName("gridLayer")
    --        local visible = not gridLayer:isVisible()
    --        gridLayer:setVisible(visible)
    --    end))
    --    self.foregroundNode:addChild(button)

    local button = ccui.Button:create("image/ui/img/btn/btn_278.png")
    button:setPosition(display.width - 100,display.cy)
    button:setTitleFontSize(24)
    button:addTouchEventListener(widget_click_listener(function(sender)
        self:startNextBattleRound()
    end))
    button:setVisible(false)
    button:setLocalZOrder(99999)
    self:addChild(button)
    self.forwordButton = button

    local roundLabel = cc.LabelTTF:create(string.format("%d/%d", self.battleModel.roundIndex, self.battleModel:getRoundCount()), "Arial", 24)
    roundLabel:setColor(cc.c3b(255, 255, 0))
    roundLabel:setPosition(cc.p(display.right - 250, display.top - 43))
    self.foregroundNode:addChild(roundLabel, 999)
    self.roundLabel = roundLabel

    -- local timeBgSprite = cc.Sprite:create("image/ui/img/btn/btn_219.png")
    -- timeBgSprite:setPosition(cc.p(display.right - 150, display.top - 43))
    -- self.foregroundNode:addChild(timeBgSprite)

    -- local timeLabel = cc.LabelTTF:create("00:00", "Arial", 24)
    -- timeLabel:setColor(cc.c3b(255, 255, 255))
    -- local size = timeBgSprite:getContentSize()
    -- timeLabel:setPosition(cc.p(size.width / 2, size.height / 2))
    -- timeBgSprite:addChild(timeLabel, 999)
    -- self.timeLabel = timeLabel

    self.drawScopeNodeList = {}
    --self.drawScopeNodeList = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true}
    --    for i = 1, 10 do
    --        local function selectedEvent(sender,eventType)
    --            if eventType == ccui.CheckBoxEventType.selected then
    --                self.drawScopeNodeList[i] = true
    --            elseif eventType == ccui.CheckBoxEventType.unselected then
    --                self.drawScopeNodeList[i] = false
    --            end
    --            self:drawAttackScope()
    --        end
    --
    --        local checkBox = ccui.CheckBox:create()
    --        checkBox:setTouchEnabled(true)
    --        checkBox:loadTextures("dummy/images/common/check_btn_off.png",
    --            "dummy/images/common/check_btn_on.png",
    --            "dummy/images/common/check_btn_on.png",
    --            "dummy/images/common/check_btn_off.png",
    --            "dummy/images/common/check_btn_off.png")
    --        checkBox:setPosition(cc.p(display.width / 12 * i, display.top - 20))
    --        checkBox:addEventListenerCheckBox(selectedEvent)
    --        self.foregroundNode:addChild(checkBox)
    --    end

    local btn_close = ccui.Button:create("image/ui/img/btn/btn_270.png", "image/ui/img/btn/btn_270.png")
    btn_close:setPosition(display.right - 74 / 2 - 10, display.top - 74 / 2 - 10)
    self.foregroundNode:addChild(btn_close)

    btn_close:addTouchEventListener(widget_click_listener(function(sender)
        application:popScene()
    end))
end

function BattleRecordPlayer:initControlPanel()
    local PANEL_WIDTH = 620

    local controlPanel = cc.Node:create()
    controlPanel:setPosition(cc.p((SCREEN_WIDTH - 960) / 2, 0))
    self.foregroundNode:addChild(controlPanel)
    self.controlPanel = controlPanel

    local label = cc.LabelTTF:create("无(0)", "Arial", 32)
    label:setColor(cc.c3b(255, 255, 0))
    label:setPosition(cc.p(50, 80))
    label:setVisible(false)
    controlPanel:addChild(label, 999)
    self.elemBuffLabel = label

    local rageIcon = cc.Sprite:create("image/ui/img/btn/btn_236.png")
    rageIcon:setPosition(cc.p(65, 20))
    rageIcon:setScale(1.4)
    controlPanel:addChild(rageIcon)

    local label = cc.LabelTTF:create("公共怒气", "Arial", 22)
    label:setColor(cc.c3b(255, 255, 0))
    label:setPosition(cc.p(120, 20))
    controlPanel:addChild(label, 999)

    --    local width = display.width * 0.8
    --    local height = display.height * 0.2
    --    local color = cc.c4f(0.2, 0.2, 0.8, 0.3)
    --    local gridNode = cc.DrawNode:create()
    --    gridNode:drawPolygon({cc.p(0, 0), cc.p(0, height), cc.p(width, height), cc.p(width, 0)}, 4, color, 0, color)
    --    self.controlPanel:addChild(gridNode)

    local panelBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_049.png")
    panelBg:setAnchorPoint(cc.p(0.5, 0.5))
    panelBg:setContentSize(cc.size(PANEL_WIDTH, 140))
    panelBg:setPosition(cc.p(480, 70))
    controlPanel:addChild(panelBg)

    local ani = "image/spine/skill_effect/nuqi/skeleton.json"
    local atlas = "image/spine/skill_effect/nuqi/skeleton.atlas"
    local teamRageBar = sp.SkeletonAnimation:create(ani, atlas, 0.75)
    teamRageBar:setAnimation(0, "animation", true)
    teamRageBar:setPosition(cc.p(125, 80))
    controlPanel:addChild(teamRageBar)

    local rageLabel = cc.LabelAtlas:_create("0", "image/atlas/numred.png", 30, 39,  string.byte("0"))
    rageLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rageLabel:setPosition(cc.p(125, 80))
    controlPanel:addChild(rageLabel, 999)
    self.rageLabel = rageLabel

    local rageNeedTitleLabel = cc.LabelTTF:create("消耗", "Arial", 18)
    rageNeedTitleLabel:setColor(cc.c3b(255, 255, 0))
    rageNeedTitleLabel:setPosition(cc.p(192, 15))
    controlPanel:addChild(rageNeedTitleLabel, 999)

    local wxBorderIcons = {
        [2] = "image/ui/img/btn/btn_171.png",
        [3] = "image/ui/img/btn/btn_172.png",
        [4] = "image/ui/img/btn/btn_173.png",
        [1] = "image/ui/img/btn/btn_174.png",
        [5] = "image/ui/img/btn/btn_175.png",
    }

    local width = PANEL_WIDTH / 5
    local heroModels = self.battleModel.leftTeam:getAllHeroModels()
    for i = 1, 5 do
        local heroModel = heroModels[i]

        if heroModel then
            local elemType = heroModel:getElemType()
            local borderIcon = wxBorderIcons[elemType]
            CCLog(string.format("elemType:%s, border:%s", elemType, borderIcon))

            local heroRageButton = ccui.Button:create(borderIcon)
            heroRageButton:setTitleText(heroModel:getName())
            heroRageButton:setPosition(180 + width * i - width * 0.5, 72)
            heroRageButton:setTitleFontSize(18)
            heroRageButton:addTouchEventListener(widget_click_listener(function(sender)
                if heroModel then
                    if heroModel:isAlive() then
                        heroModel:performRageSkill()
                    else
                        CCLog("dead hero can't use skill")
                    end
                end
            end))

            self.heroControlsMap[heroModel] = self.heroControlsMap[heroModel] or {}
            self.heroControlsMap[heroModel].rageButton = heroRageButton

            heroRageButton:setTouchEnabled(false)
            --heroRageButton:setOpacity(220)

            local heroIcon = cc.Sprite:create(heroModel:getHeroImage())
            heroIcon:setPosition(cc.p(52, 47))

            heroRageButton:setScale(0.825)
            heroRageButton:addChild(heroIcon)

            controlPanel:addChild(heroRageButton)

            local btnSize = heroRageButton:getContentSize()
            local spriteActive = load_animation("image/spine/skill_effect/ragebox/yellow/", 0.75)
            -- sp.SkeletonAnimation:create("image/spine/skill_effect/huangsekuang/skeleton.json", "image/spine/skill_effect/huangsekuang/skeleton.atlas", 0.75)
            spriteActive:setScale(1.25)
            heroRageButton:addChild(spriteActive, 0, "rageActive")
            spriteActive:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            spriteActive:setAnimation(0, "animation", true)
            spriteActive:setVisible(false)

            --            local spriteActive = cc.Sprite:create("image/ui/img/btn/btn_238.png")
            --            spriteActive:setScale(1.25)
            --            heroRageButton:addChild(spriteActive, 0, "rageActive")
            --            spriteActive:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            --            spriteActive:runAction(cc.RepeatForever:create(cc.Sequence:create({
            --                cc.FadeTo:create(0.4, 80),
            --                cc.FadeTo:create(0.4, 250),
            --            })))
            --            spriteActive:setVisible(false)

            --            local spriteCombo = cc.Sprite:create("image/ui/img/btn/btn_239.png")
            --            spriteCombo:setScale(1.25)
            --            heroRageButton:addChild(spriteCombo, 0, "rageCombo")
            --            spriteCombo:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            --            spriteCombo:runAction(cc.RepeatForever:create(cc.Sequence:create({
            --                cc.FadeTo:create(0.4, 80),
            --                cc.FadeTo:create(0.4, 250),
            --            })))
            --            spriteCombo:setVisible(false)

            local spriteCombo = load_animation("image/spine/skill_effect/ragebox/green/", 0.75)
            -- sp.SkeletonAnimation:create("image/spine/skill_effect/lvsekuang/skeleton.json", "image/spine/skill_effect/lvsekuang/skeleton.atlas", 0.75)
            spriteCombo:setScale(1.25)
            heroRageButton:addChild(spriteCombo, 0, "rageCombo")
            spriteCombo:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            spriteCombo:setAnimation(0, "animation", true)
            spriteCombo:setVisible(false)

            local rageSkillCDImge = "image/ui/img/btn/btn_252.png"
            local rageCDBar = cc.ProgressTimer:create(cc.Sprite:create(rageSkillCDImge))
            rageCDBar:setScale(0.7)
            rageCDBar:setOpacity(100)
            rageCDBar:setPosition(cc.p(btnSize.width / 2, btnSize.height / 2))
            rageCDBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            --rageCDBar:setReverseDirection(true)
            rageCDBar:setMidpoint(cc.p(0, 1))
            rageCDBar:setBarChangeRate(cc.p(0, 1))
            rageCDBar:setPercentage(150)
            heroRageButton:addChild(rageCDBar)

            self.heroControlsMap[heroModel] = self.heroControlsMap[heroModel] or {}
            self.heroControlsMap[heroModel].rageCDBar = rageCDBar

            local rageIcon = cc.Sprite:create("image/ui/img/btn/btn_236.png")
            rageIcon:setPosition(cc.p(160 + width * i - width * 0.5, 15))
            controlPanel:addChild(rageIcon)

            local power = heroModel:rageConsumeRage()
            local rageNeedLabel = cc.LabelTTF:create("" .. power, "Arial", 18)
            rageNeedLabel:setColor(cc.c3b(255, 255, 0))
            rageNeedLabel:setPosition(cc.p(185 + width * i - width * 0.5, 15))
            controlPanel:addChild(rageNeedLabel, 999)

            local wxBgSprite = cc.Sprite:create(heroModel:getElemTypeIcon())
            wxBgSprite:setPosition(cc.p(140 + width * i - width * 0.5, 33))
            controlPanel:addChild(wxBgSprite)

            --            local wxLabel = cc.LabelTTF:create(heroModel:getElemTypeName(), "Arial", 18)
            --            wxLabel:setColor(cc.c3b(255, 255, 0))
            --            wxLabel:setPosition(cc.p(140 + width * i - width * 0.5, 33))
            --            wxLabel:setColor(heroModel:getElemTypeColor())
            --            controlPanel:addChild(wxLabel, 999)

            local hpBgSprite = cc.Sprite:create("image/ui/img/btn/btn_235.png")
            hpBgSprite:setPosition(180 + width * i - width * 0.5, 125)
            controlPanel:addChild(hpBgSprite)

            local bgImage = "image/ui/img/btn/btn_234.png"
            local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
            hpBar:setPosition(180 + width * i - width * 0.5, 125)
            hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            --hpBar:setReverseDirection(true)
            hpBar:setMidpoint(cc.p(0, 1))
            hpBar:setBarChangeRate(cc.p(1, 0))
            hpBar:setPercentage(100)
            controlPanel:addChild(hpBar)

            self.heroControlsMap[heroModel] = self.heroControlsMap[heroModel] or {}
            self.heroControlsMap[heroModel].hpBar = hpBar
        end
    end

    local btnAutoBattle = ccui.Button:create("image/ui/img/btn/btn_280.png")
    btnAutoBattle:setPosition(display.width - 65, 50)
    btnAutoBattle:addTouchEventListener(widget_click_listener(function(sender)
        if self.autoBattle then
            btnAutoBattle:loadTextures("image/ui/img/btn/btn_280.png", "image/ui/img/btn/btn_280.png")
        else
            btnAutoBattle:loadTextures("image/ui/img/btn/btn_281.png", "image/ui/img/btn/btn_281.png")
        end
        self.autoBattle = not self.autoBattle
    end))
    self.foregroundNode:addChild(btnAutoBattle)
end

function BattleRecordPlayer:updateControlPanel()
    local leftTeam = self.battleModel.leftTeam
    local rage = leftTeam:getRage()
    -- self.rageBar:setPercent(math.floor(rage * 100 / 1000))
    self.rageLabel:setString("" .. rage)

    for hero, heroControls in pairs(self.heroControlsMap) do
        local enabled = true

        local rageButton = heroControls.rageButton
        if self.battleModel:getState() ~= "fight" then
            enabled = false
        end

        if enabled and not (hero:isAlive() and hero:isReady()) then
            enabled = false
        end

        if enabled and hero:rageSkillInCooling() then
            enabled = false
        end

        if enabled and leftTeam:getRage() < hero:rageSkillPower() then
            enabled = false
        end

        local spriteActive = assert(rageButton:getChildByName("rageActive"), "rageActive sprite not exists")
        local spriteTeamRageCombo = assert(rageButton:getChildByName("rageCombo"), "rageCombo sprite not exists")
        if enabled then
            rageButton:setTouchEnabled(true)

            if leftTeam:hasElemBuff() then
                local elemType = leftTeam:getBuffElemType()
                local heroElemType = hero:getElemType()
                if ElemType.generate(elemType, heroElemType) then
                    spriteTeamRageCombo:setVisible(true)
                end
            end

            spriteActive:setVisible(enabled)
            if spriteTeamRageCombo:isVisible() then
                spriteActive:setVisible(false)
            end
        else
            rageButton:setTouchEnabled(false)
            spriteActive:setVisible(false)
            spriteTeamRageCombo:setVisible(false)
        end

        -- TODO:复活
        if not hero:isAlive() then
            local team = self.battleModel:getTeam(hero:getTeamSide())
            if team:heroCanResurrect(hero) then
                enabled = true
            end
        end

        if not hero:isAlive() then
            rageButton:setOpacity(150)
        end
    end
end

function BattleRecordPlayer:calcAbsScope(region, direction, heroCell)
    local attackScope = {}
    if direction == "right" then
        for y, xrange in pairs(region) do
            local absY = y + heroCell.y

            if absY >= 1 and absY <= BattleConfig.Y_CELL_COUNT then
                attackScope[y + heroCell.y] = {start = heroCell.x + xrange.start, len = xrange.len }
            end
        end
    else
        for y, xrange in pairs(region) do
            local absY = y + heroCell.y
            if absY >= 1 and absY <= BattleConfig.Y_CELL_COUNT then
                attackScope[y + heroCell.y] = {start = heroCell.x - xrange.start - xrange.len + 1, len = xrange.len }
            end
        end
    end
    CCLog(vardump(attackScope, "region"))

    return attackScope
end

local DRAW_MATH_LINE = false -- 画配对线
function BattleRecordPlayer:drawAttackScope()
    local scopeGridNode = self.scopeGridNode
    scopeGridNode:clear()

    if self.regionRageSkill ~= nil then
        local rageSkillInfo = self.regionRageSkill
        local attackData = rageSkillInfo.attackData

        local heroModel = attackData:getHeroModel()
        if heroModel:isAlive() then
            local battleModel = self.battleModel

            local cell = heroModel:getCell()
            local pos = BattleConfig.getCellPos(cell.x, cell.y)

            local skillConfig = BaseConfig.GetHeroSkill(attackData:getSkillID(), attackData:getSkillLevel())

            local scope = nil
            BattleConfig.cellsToRanges(skillConfig.scope)
            if #skillConfig.scope == 0 then
                scope = {
                    [1] = {start = 1, len = 20},
                    [2] = {start = 1, len = 20},
                    [3] = {start = 1, len = 20},
                    [4] = {start = 1, len = 20},
                    [5] = {start = 1, len = 20 }
                }
            else
                scope = BattleConfig.cellsToRanges(skillConfig.scope)
                scope = self:calcAbsScope(scope, heroModel:getDirection(), cell)
            end
            scopeGridNode:drawScope(scope, cc.c4f(0, 1, 0, 0.7))

            if rageSkillInfo.dragScopeNode == nil then
                local enemy = heroModel:getMatchedEnemy()
                local area = BattleConfig.cellsToRanges(skillConfig.area)
                local scopeDragNode = ScopeDragNode.new(attackData:getRegionCenterCell(), heroModel:getDirection(), area, scope, battleModel)
                scopeDragNode:setCallback(handler(self, self.onRegionRageSkillDragDrop), handler(self, self.onRegionRageSkillDragCancel), attackData)
                self.foregroundNode:addChild(scopeDragNode)
                rageSkillInfo.dragScopeNode = scopeDragNode

                CCLog(vardump({cell = cell, pos = cc.p(scopeDragNode:getPosition()), opos = pos}, "dragNode"))
            end
        else
            self:clearRegionRageSkill()
        end
    end

    for idx, hero in ipairs(self.battleModel.leftTeam:getAliveHeroModels()) do
        local scope = hero:getAttackScope()
        -- TODO:
        if self.drawScopeNodeList[idx] then
            scopeGridNode:drawScope(scope, scope_1_colors[idx])
        end

        if DRAW_MATH_LINE then
            local enemy = hero:getMatchedEnemy()
            if enemy then
                local scell = hero:getCell()
                local dcell = enemy:getCell()

                local spos = BattleConfig.getCellPos(scell.x, scell.y)
                local dpos = BattleConfig.getCellPos(dcell.x, dcell.y)

                scopeGridNode:drawSegment(spos, dpos, 1, line_1_colors[idx])
                --                scopeGridNode:drawDot(spos, 25, cc.c4f(0, 0, 1, 1))
                --                local nextCell = hero:getNextCell()
                --                if nextCell then
                --                    local nextPos = BattleConfig.getCellPos(nextCell.x, nextCell.y)
                --                    scopeGridNode:drawDot(nextPos, 25, cc.c4f(1, 0, 0, 1))
                --                end
            end
        end
    end

    for idx, hero in ipairs(self.battleModel.rightTeam:getAliveHeroModels()) do
        local scope = hero:getAttackScope()
        -- TODO:
        if self.drawScopeNodeList[idx + 5] then
            scopeGridNode:drawScope(scope, scope_2_colors[idx])
        end

        if DRAW_MATH_LINE then
            local enemy = hero:getMatchedEnemy()
            if enemy then
                local scell = hero:getCell()
                local dcell = enemy:getCell()

                local spos = BattleConfig.getCellPos(scell.x, scell.y)
                local dpos = BattleConfig.getCellPos(dcell.x, dcell.y)

                scopeGridNode:drawSegment(spos, dpos, 1, line_2_colors[idx])
            end
        end
    end
end

function BattleRecordPlayer:moveToBattleground()
    local useTime = BattleConfig.ENTRANCE_TIME

    local function heroWalk()
        for idx, heroModel in ipairs(self.battleModel.leftTeam:getAliveHeroModels()) do
            local heroView = self:getHeroViewByModel(heroModel)
            heroView:walk(true)
        end
    end

    --    local function heroReady()
    --        for idx, heroModel in ipairs(self.battleModel.leftTeam:getAliveHeroModels()) do
    --            local heroView = self:getHeroViewByModel(heroModel)
    --            heroModel:onBattleRoundStart()
    --            --heroView:ready()
    --        end
    --    end

    local mapScrollView = self.mapNode:getScrollView()
    local size = mapScrollView:getInnerContainerSize()
    local pos = mapScrollView:getPosition()

    heroWalk()
    CCLog("moveToBattleground", vardump({size=size, pos = pos, round = self.battleModel.roundIndex, time = useTime}))
    mapScrollView:scrollToPercentHorizontal(self.battleModel.roundIndex * 33, useTime, false)
    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(useTime),
        cc.CallFunc:create(function()
            --self:lineupEnemy(self.battleModel.roundIndex)
        end),
        cc.DelayTime:create(BattleConfig.TIME_UNIT),
        cc.CallFunc:create(function()
            --self.battleModel:onBattleRoundStart()
        end),
    }))
end

function BattleRecordPlayer:updateLocalZOrder()
    -- 更新ZOrder

    local heroViews = self.battleModel.leftTeam:getHeroViews()
    for i, view in ipairs(heroViews) do
        local cell = view._model:getCell()
        view:setLocalZOrder((5 - cell.y) * 100 + cell.x)
    end

    local enemyViews = self.battleModel.rightTeam:getHeroViews()
    for i, view in ipairs(enemyViews) do
        if tolua.isnull(view) then
            CCLog("view is null")
        else
            local cell = view._model:getCell()
            view:setLocalZOrder((5 - cell.y) * 100 + cell.x)
        end
    end
end

function BattleRecordPlayer:updateHPBar()
    for hero, heroControls in pairs(self.heroControlsMap) do
        local hpBar = heroControls.hpBar
        local hp = hero:getHP()
        local total = hero:getFullHP()

        local percent = math.ceil(hp * 100 / total)
        hpBar:setPercentage(percent)
    end
end

function BattleRecordPlayer:updateRoundLabel()
    local roundLabel = self.roundLabel
    roundLabel:setString(string.format("%d/%d", self.battleModel.roundIndex, self.battleModel:getRoundCount()))
end

function BattleRecordPlayer:updateTimeLabel()
    self.timeLabel:setString(string.format(self.battleModel:getTimeLeftStr()))
end

function BattleRecordPlayer:clearRegionRageSkill()
    if self.regionRageSkill ~= nil then
        local rageSkillInfo = self.regionRageSkill
        if rageSkillInfo.dragScopeNode ~= nil and not tolua.isnull(rageSkillInfo.dragScopeNode) then
            rageSkillInfo.dragScopeNode:removeFromParent()
            rageSkillInfo.dragScopeNode = nil
        end
    end

    self.regionRageSkill = nil
end

-- 注册事件监听接口
function BattleRecordPlayer:addEventListener(name, callback)
    local listener = cc.EventListenerCustom:create(name, callback)
    self.dispatcher:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

-- 分发事件
function BattleRecordPlayer:dispatchEvent(eventName, data)
    local event = cc.EventCustom:new(eventName)
    event.data = data
    CCLog("dispatchEvent(" .. eventName ..")")
    self.dispatcher:dispatchEvent(event)
end

function BattleRecordPlayer:onBattleEvent(event)
    CCLog(vardump({name = event:getEventName(), data = event.data}, "BattleRecordPlayer:onBattleEvent"))
    local name = event:getEventName()
    local data = event.data
end

function BattleRecordPlayer:onEvent(method, event)
    self:onBattleEvent(event)
    method(self, event)
end

function BattleRecordPlayer:registerBattleHandler()
    self:addEventListener(AppEvent.UI.Battle.Wait,                 handler(self, self.onEvent, self.onWait))
    self:addEventListener(AppEvent.UI.Battle.Match,                handler(self, self.onEvent, self.onMatch))
    self:addEventListener(AppEvent.UI.Battle.MoveBy,               handler(self, self.onEvent, self.onMoveBy))
    self:addEventListener(AppEvent.UI.Battle.AttackScopeChange,    handler(self, self.onEvent, self.onAttackScopeChange))
    self:addEventListener(AppEvent.UI.Battle.AttackBegin,          handler(self, self.onEvent, self.onAttackBegin))
    self:addEventListener(AppEvent.UI.Battle.AttackComplete,       handler(self, self.onEvent, self.onAttackComplete))
    self:addEventListener(AppEvent.UI.Battle.AttackBreakOff,       handler(self, self.onEvent, self.onAttackBreakOff))
    self:addEventListener(AppEvent.UI.Battle.Hit,                  handler(self, self.onEvent, self.onHit))
    self:addEventListener(AppEvent.UI.Battle.MISS,                 handler(self, self.onEvent, self.onHeroMiss))
    self:addEventListener(AppEvent.UI.Battle.RegionRageSkill,      handler(self, self.onEvent, self.onRegionRageSkill))
    self:addEventListener(AppEvent.UI.Battle.HPChange,             handler(self, self.onEvent, self.onHPChange))
    self:addEventListener(AppEvent.UI.Battle.FighterDie,              handler(self, self.onEvent, self.onHeroDie))
    self:addEventListener(AppEvent.UI.Battle.Ready,                handler(self, self.onEvent, self.onReady))
    self:addEventListener(AppEvent.UI.Battle.Walk,                 handler(self, self.onEvent, self.onWalk))
    self:addEventListener(AppEvent.UI.Battle.BattleStateChange,    handler(self, self.onEvent, self.onBattleStateChange))
    self:addEventListener(AppEvent.UI.Battle.HeroDirectionChange,  handler(self, self.onEvent, self.onHeroDirectionChange))
    self:addEventListener(AppEvent.UI.Battle.BuffAdded,            handler(self, self.onEvent, self.onHeroBuffAdded))
    self:addEventListener(AppEvent.UI.Battle.BuffRemoved,          handler(self, self.onEvent, self.onHeroBuffRemoved))
    self:addEventListener(AppEvent.UI.Battle.BuffReplaced,         handler(self, self.onEvent, self.onHeroBuffReplaced))
    self:addEventListener(AppEvent.UI.Battle.RageChanged,          handler(self, self.onEvent, self.onTeamRageChanged))
    self:addEventListener(AppEvent.UI.Battle.RageComboHit,         handler(self, self.onEvent, self.onTeamComboHit))
    self:addEventListener(AppEvent.UI.Battle.TeamLineup,           handler(self, self.onEvent, self.onTeamLineup))
    self:addEventListener(AppEvent.UI.Battle.HeroLineup,           handler(self, self.onEvent, self.onHeroLineup))
    self:addEventListener(AppEvent.UI.Battle.TeamRelineup,         handler(self, self.onEvent, self.onTeamRelineup))
    self:addEventListener(AppEvent.UI.Battle.HeroRelineup,         handler(self, self.onEvent, self.onHeroRelineup))
    self:addEventListener(AppEvent.UI.Battle.RegionRageSkillDrop,  handler(self, self.onEvent, self.onRegionRageSkillDrop))
    self:addEventListener(AppEvent.UI.Battle.RegionRageSkillCancel,handler(self, self.onEvent, self.onRegionRageSkillCancel))
end

function BattleRecordPlayer:onWait(event)
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local heroView = self:getHeroViewByModel(heroModel)
    heroView:ready()
end

function BattleRecordPlayer:onMatch(event)
    local fighterID = event.data.fighterID
    local enemyFighterID = event.data.enemyFighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local enemyModel = enemyFighterID and FighterModel.getFighter(enemyFighterID) or nil

    heroModel:setMatchedEnemy(enemyModel)
end

function BattleRecordPlayer:onRegionRageSkillDrop(event)
    self:clearRegionRageSkill()
    self:drawAttackScope()
end

function BattleRecordPlayer:onRegionRageSkillCancel(event)
    self:clearRegionRageSkill()
    self:drawAttackScope()
end

function BattleRecordPlayer:onMoveBy(event)
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local offset = event.data.offset
    local useTime = event.data.useTime

    CCLog("on event:", vardump({name = event:getEventName(), offset = offset, hero = heroModel:getHeroID(), side = heroModel:getTeamSide() }))

    local heroView = assert(self:getHeroViewByModel(heroModel))
    heroView:moveBy(offset, useTime, self.battleModel)
end

function BattleRecordPlayer:onAttackScopeChange(event)
    self:drawAttackScope()
end

function BattleRecordPlayer:onAttackBegin(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local attackData = AttackDataModel.decode(event.data, self.battleModel)

    local heroModel = attackData:getHeroModel()

    local heroView = self:getHeroViewByModel(heroModel)
    heroView:attackBegin(attackData)

    self:updateControlPanel()
end

function BattleRecordPlayer:onAttackComplete(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local attackData = AttackDataModel.decode(event.data, self.battleModel)

    local heroModel = attackData:getHeroModel()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local heroView = self:getHeroViewByModel(heroModel)
    heroView:attackComplete(attackData)

    local function do_attack()
        self:updateControlPanel()
    end

    local skillMoveTime = 0.0
    local fireBallSpeed = 15 -- 远程轨迹速度 15个格子每秒

    local skillID = attackData.skillData.id
    if skillID == 1002 or skillID == 1003 then
        local aniPath = "image/spine/skill_effect/jinqiu/skeleton.json"
        local atlasPath = "image/spine/skill_effect/jinqiu/skeleton.atlas"
        local aniNode = sp.SkeletonAnimation:create(aniPath, atlasPath, 0.75)
        self.foregroundNode:addChild(aniNode)
        aniNode:addAnimation(0, "animation", true)
        aniNode:setVisible(false)

        local heroModel = attackData:getHeroModel()

        local offset = heroModel:getDirection() == "right" and 50 or -50

        local cell = heroModel:getCell()
        local pos = BattleConfig.getCellPos(cell.x, cell.y)
        pos = cc.pAdd(pos, cc.p(offset, 80))

        aniNode:setPosition(pos)

        local enemyModel = heroModel:getMatchedEnemy()
        if enemyModel == nil then
            CCLog("普攻没有切配对的敌人，已经被打死了？")
            return
        end

        local enemyView = self:getHeroViewByModel(enemyModel)
        aniNode:setLocalZOrder(enemyView:getLocalZOrder() + 1)

        local dstCell = enemyModel:getCell()
        local dstPos = BattleConfig.getCellPos(dstCell.x, dstCell.y)
        dstPos = cc.pAdd(dstPos, cc.p(0, 80))
        local distance = cc.pGetDistance(cell, dstCell)
        skillMoveTime = distance / fireBallSpeed
        CCLog(vardump({skillMoveTime = skillMoveTime, cell = cell, dstCell = dstCell, distance = distance, fireBallSpeed = fireBallSpeed}, "attack speed"))
        aniNode:runAction(cc.Sequence:create({
            cc.Show:create(),
            cc.MoveTo:create(skillMoveTime, dstPos),
            cc.RemoveSelf:create(),
        }))
    end

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(skillMoveTime),
        cc.CallFunc:create(do_attack),
    }))
end

function BattleRecordPlayer:onAttackBreakOff(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local attackData = AttackDataModel.decode(event.data, self.battleModel)

    local heroModel = attackData:getHeroModel()

    local heroView = self:getHeroViewByModel(heroModel)
    heroView:attackBreakOff(attackData)
end

function BattleRecordPlayer:onHit(event)
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local damage = event.data.damage

    local heroView = assert(self:getHeroViewByModel(heroModel))

    if tolua.isnull(heroView) then
        CCLog(vardump(heroModel), "heroView of hero is not exists")
        return
    end

    heroView:hit(damage)
    self.battleModel:onHit(heroModel, damage)

    self:updateControlPanel()
end

function BattleRecordPlayer:onHeroMiss(event)
    CCLog("BattleController:onHeroMiss")

    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = assert(self:getHeroViewByModel(heroModel))

    if tolua.isnull(heroView) then
        CCLog(vardump(heroModel), "heroView of hero is not exists")
        return
    end

    heroView:miss()

    self:updateControlPanel()
end

function BattleRecordPlayer:onRegionRageSkill(event)
    if self.regionRageSkill == nil then
        local attackData = AttackDataModel.decode(event.data, self.battleModel)

        self.regionRageSkill = {attackData = attackData}
        self:drawAttackScope()
    end
end

function BattleRecordPlayer:onHPChange(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local chgValue = event.data.value
    local curHP = event.data.curHP
    heroModel:setHP(curHP)

    local heroView = self:getHeroViewByModel(heroModel)
    if heroView and not tolua.isnull(heroView) then
        heroView:hpChange(chgValue)
        heroView:updateHPBar()
    end

    self:updateHPBar()
end

function BattleRecordPlayer:onHeroDie(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = self:getHeroViewByModel(heroModel)
    --    table.removeItem(self.heroViews, heroView)
    --    table.removeItem(self.enemyViews, heroView)
    --
    --    table.removeItem(self.heroModels, hero)
    --    table.removeItem(self.enemyModels, hero)
    self.battleModel:heroDie(heroModel)

    heroModel:setHP(0)
    if heroView and not tolua.isnull(heroView) then
        heroView:die()
    end

    -- TODO:调度使用
    self:drawAttackScope()
end

function BattleRecordPlayer:onReady(event)
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local heroView = assert(self:getHeroViewByModel(heroModel))
    heroView:ready()
end

function BattleRecordPlayer:onWalk(event)
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local heroView = assert(self:getHeroViewByModel(heroModel))
    heroView:walk()
end

function BattleRecordPlayer:onBattleStateChange(event)
    local data = event.data

    local old = data.old
    local new = data.new
    local time = data.useTime

    self:clearRegionRageSkill()
    self:drawAttackScope()
    
    self.battleModel:setState(new)

    if new == "start" then
        self.forwordButton:setVisible(false)

        self.battleModel.roundIndex = self.battleModel.roundIndex + 1
        
        self:updateRoundLabel()
        self:initEnemyModels(self.battleModel.roundIndex)
        self:moveToBattleground(time)
    elseif new == "win" then
        if self.battleModel.roundIndex >= self.battleModel:getRoundCount() then
            --            local label = cc.LabelTTF:create("你赢了", "Arial", 35)
            --            self:addChild(label, 999)
            --            label:setColor(cc.c3b(255, 255, 0))
            --            label:setPosition(cc.p(display.cx, display.cy))
            local successNode = BattleVictoryNode.new({})
            successNode:setPosition(cc.p(display.width / 2, display.height / 2))
            cc.Director:getInstance():getRunningScene():addChild(successNode)
        else
            self.forwordButton:setVisible(true)

            self.enemyModelList = nil
            self.battleModel.rightTeam:setHeroModels({})

            local action = cc.RepeatForever:create(cc.Sequence:create({
                cc.EaseSineInOut:create(cc.MoveBy:create(0.8, cc.p(30, 0))),
                cc.EaseSineInOut:create(cc.MoveBy:create(0.8, cc.p(-30, 0))),
                cc.CallFunc:create(function()
                    if self.autoBattle then
                        self:startNextBattleRound()
                    end
                end),
            }))
            self.forwordButton:runAction(action)
        end

        local heroViews = self.battleModel.leftTeam:getHeroViews()
        for _, heroView in ipairs(heroViews) do
            heroView:idle()
        end
    elseif new == "fail" then
        --        local label = cc.LabelTTF:create("你输了", "Arial", 35)
        --        self:addChild(label, 999)
        --        label:setColor(cc.c3b(255, 255, 0))
        --        label:setPosition(cc.p(display.cx, display.cy))

        local successNode = BattleFailureNode.new({})
        successNode:setPosition(cc.p(display.width / 2, display.height / 2))
        cc.Director:getInstance():getRunningScene():addChild(successNode)

        self.battleModel:onBattleRoundEnd()
        local enemyViews = self.battleModel.rightTeam:getHeroViews()
        for _, heroView in ipairs(enemyViews) do
            heroView:idle()
        end
    end

    self:updateControlPanel()
end

function BattleRecordPlayer:onHeroDirectionChange(event)
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local direction = event.data.direction

    local heroView = self:getHeroViewByModel(heroModel)
    if heroView then
        heroView:setDirection(direction)
    end
end

function BattleRecordPlayer:onHeroBuffAdded(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local buff = BuffModel.decode(event.data.buff, self.battleModel)
    local heroView = self:getHeroViewByModel(heroModel)

    heroModel:addRawBuff(buff)
    if heroView and not tolua.isnull(heroView) then
        heroView:buffAdded(buff)
    end
end

function BattleRecordPlayer:onHeroBuffRemoved(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local buff = BuffModel.decode(event.data.buff, self.battleModel)

    if heroModel then
        heroModel:removeRawBuff(buff)
        local heroView = self:getHeroViewByModel(heroModel)
        if heroView and not tolua.isnull(heroView) then
            heroView:buffRemoved(buff)
        end
    else
        CCLog(fighterID .. ":hero not exists")
    end
end

function BattleRecordPlayer:onHeroBuffReplaced(event)
    CCLog("on event:", vardump({name = event:getEventName()}))
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local newBuff = BuffModel.decode(event.data.newBuff, self.battleModel)
    local oldBuff = BuffModel.decode(event.data.oldBuff, self.battleModel)
    local heroView = self:getHeroViewByModel(heroModel)
    if heroView and not tolua.isnull(heroView) then
        heroView:buffReplaced(oldBuff, newBuff)
    end
end

function BattleRecordPlayer:onTeamRageChanged(event)
    CCLog("on event:", vardump({name = event:getEventName(), data = event.data}))
    local data = event.data
    local teamSide = data.teamSide
    local old = data.old
    local new = data.new

    if teamSide == "left" then
        self:updateControlPanel()
    end
end

function BattleRecordPlayer:onTeamComboHit(event)
    CCLog("on event:", vardump({name = event:getEventName(), data = event.data}))
    local data = event.data
    local teamSide = data.teamSide
    local elemType = data.elemType

    if teamSide == "left" then
        for hero, heroControls in pairs(self.heroControlsMap) do
            self:updateControlPanel()
        end
    end

end

function BattleRecordPlayer:onTeamLineup(event)
    local eventData = event.data
    local teamSide = eventData.teamSide

    CCLog(vardump(eventData, "BattleRecordPlayer:onTeamLineup(event)"))

    if teamSide == "left" then
        self:initControlPanel()
    end
end

function BattleRecordPlayer:onHeroLineup(event)
    local eventData = event.data
    local teamSide = eventData.teamSide
    local fighterID = event.data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    CCLog(vardump(eventData, "BattleRecordPlayer:onHeroLineup(event)"))

    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    else
        team = self.battleModel.rightTeam
    end

    local cell = heroModel:getCell()
    local pos = BattleConfig.getCellPos(cell.x, cell.y)
    local heroView = BattleHeroView.new(heroModel)
    self:addChild(heroView)
    heroView:setEventDispatcher(self.dispatcher)
    heroView:setPosition(pos)
    heroView:ready()

    heroView:setAutoHideHPBar(teamSide == "left" )

    team:setHeroView(heroModel, heroView)
end

function BattleRecordPlayer:onHeroRelineup(event)
    local eventData = event.data
    local teamSide = eventData.teamSide
    local fighterID = eventData.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local cell = eventData.cell

    CCLog(vardump(eventData, "BattleRecordPlayer:onHeroLineup(event)"))

    heroModel:setCell(cell)
    local heroView = assert(self:getHeroViewByModel(heroModel))

    local pos = BattleConfig.getCellPos(cell.x, cell.y)
    heroView:stopAllActions()
    heroView:setDirection(heroModel:getDirection())
    heroView:runAction(cc.JumpTo:create(2, pos, 100, 1))
    heroView:ready()
end

function BattleRecordPlayer:onTeamRelineup(event)
--    local eventData = event.data
--    local teamSide = eventData.teamSide
--
--    CCLog(vardump(eventData, "BattleController:onTeamRelineup(event)"))
--
--    local team = nil
--    if teamSide == "left" then
--        team = self.battleModel.leftTeam
--    else
--        team = self.battleModel.rightTeam
--    end
--
--    local heroModels = team:getAliveHeroModels()
--
--    for _, heroModel in ipairs(heroModels) do
--        local cell = heroModel:getCell()
--
--        local heroView = assert(self:getHeroViewByModel(heroModel))
--
--        local pos = BattleConfig.getCellPos(cell.x, cell.y)
--        heroView:stopAllActions()
--        heroView:setDirection(heroModel:getDirection())
--        heroView:runAction(cc.JumpTo:create(2, pos, 100, 1))
--        heroView:ready()
--    end
end

function BattleRecordPlayer:initHeroModels()
    local form = self.recordData.attackerForm
    CCLog(vardump(form, "Hero Form"))

    assert(form and #form > 0, "form can't be empty")
    local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")

    local teamSide = "left"
    local direction = "right"

    local heroList = {}
    for index, unit in ipairs(form) do
        CCLog(vardump(unit, "Unit"))
        local cell = unit.cell

        local heroData = unit.heroData

        local heroID = heroData.ID

        local heroModel = BattleHeroModel.new(heroID, heroData, self.battleModel, teamSide)
        heroModel:setDirection(direction)
        heroModel:setCell(cell)
        heroModel:setEventDispatcher(nil)
        table.insert(heroList, heroModel)
    end

    self.heroModelList = heroList

    self.battleModel.leftTeam:setHeroModels(heroList)
end

-- 敌军布阵
function BattleRecordPlayer:initEnemyModels(roundIndex)
    local battleCount = self.battleModel:getRoundCount()

    local heroCount = 0

    if roundIndex <= battleCount then
        local form = self.battleModel:getRoundForm(roundIndex)

        assert(form and #form > 0, "form can't be empty")

        local teamSide = "right"
        local direction = "left"

        local heroList = {}
        for index, unit in ipairs(form) do
            local cell = unit.cell

            cell = BattleConfig.getFlipCell(cell)
            local heroData = unit.heroData
            local heroID = heroData.ID

            local heroModel = BattleHeroModel.new(heroID, heroData, self.battleModel, teamSide)
            heroModel:setDirection(direction)
            heroModel:setCell(cell)
            heroModel:setEventDispatcher(nil)

            self.heroRawCellMap[heroModel] = cell

            table.insert(heroList, heroModel)
        end
        self.enemyModelList = heroList

        self.battleModel.rightTeam:setHeroModels(heroList)
    end
    return 0
end

function BattleRecordPlayer:play()
    self.recordData:load(cc.FileUtils:getInstance():getWritablePath() .. "record.json")
    self:initHeroModels()

    self:schudleUpdate()
end

function BattleRecordPlayer:pause()
    self.paused = true
end

function BattleRecordPlayer:resume()
    self.paused = false
end

function BattleRecordPlayer:createMap()
    local map = BattleMapNode.new(self.recordData.map or {})
    self.backgroupNode:addChild(map)
    self.mapNode = map

    -- TODO:调试用
    local controllsBarHeight = display.height * 0.2
    local gridHeight = display.height * 0.3

    local WHITE = cc.c4f(1.0, 1.0, 1.0, 0.1)
    local GREEN = cc.c4f(0.0, 1.0, 0.0, 0.1)
    local gridLayer = GridLayer.new(cc.rect(0, controllsBarHeight, display.width, gridHeight), 20, 5, WHITE, GREEN)

    CCLog("not a error, don't care")
    self.backgroupNode:addChild(gridLayer, 0, "gridLayer")
    gridLayer:setVisible(false)
end

function BattleRecordPlayer:onUpdate(delta)
    if self.paused then
        return
    end

    self.battleModel:update(self)
    self.recordData:update(self.dispatcher)
    self:updateTimeLabel()
    self:updateLocalZOrder()
end

return BattleRecordPlayer

