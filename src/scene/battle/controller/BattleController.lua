--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-5
-- Time: 下午2:43
-- 战斗控制器
--

local BattleMapManager = require("scene.battle.view.BattleMapManager")
local GridLayer = require("scene.battle.helper.GridLayer")
local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
local BattleHeroView = require("scene.battle.view.BattleHeroView")
local BattleModel = require("scene.battle.model.BattleModel")
local SkillRegionNode = require("scene.battle.helper.SkillRegionNode")
local ScopeDragNode = require("scene.battle.helper.ScopeDragNode")
local SkillAreaNode = require("scene.battle.helper.SkillAreaNode")
local BHT = require("tool.lib.BehaviourTree")
local BattleHelper = require("scene.battle.helper.BattleHelper")
local ElemType = require("config.ElemType")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
local BuffModel = require("scene.battle.model.skill.BuffModel")
local BattleObstacleView = require("scene.battle.view.BattleObstacleView")
local BattleTrapView = require("scene.battle.view.BattleTrapView")
local CommonTool = require("tool.helper.Common")
local BattleControlPanel = require("scene.battle.controller.BattleControlPanel")
local FixedMagicCircleView = require("scene.battle.view.FixedMagicCircleView")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleUtils = require("scene.battle.helper.Utils")
local BattleFairyView = require("scene.battle.view.BattleFairyView")
local FighterModel = require("scene.battle.model.fighter.FighterModel")
local BattlePlayer = require("scene.battle.controller.BattlePlayer")
--local Profiler = require("tool.lib.ProFi")

local POS_RATIO_X = BattleConfig.POS_RATIO_X
local POS_RATIO_Y = BattleConfig.POS_RATIO_Y

local _PPOS = BattleConfig.PPOS

local map_inc_percent = 33 / (BattleConfig.ENTRANCE_TIME / BattleConfig.TIME_UNIT)
-------------------------------------------------------------------------------
local BattleController = class("BattleController", function() return cc.Node:create() end)

function BattleController:ctor(params, attackerFormInfo, progressFunc)
    --Profiler:start()
    cc.FileUtils:getInstance():enableCacheFileData(true)

    self.params = params

    attackerFormInfo = attackerFormInfo or {}
    self.attackerForm = attackerFormInfo.form

    self._mapLoading = 0
    self._preloadLoading = 0
    self._controllsLoading = 0

    self.progressFunc = progressFunc

    -- 暂停/恢复使用
    self.bulletList = {}

    self.threadList = {}

    self.rageAttackDataList = {}
    self.inRageAttacking = false

    --self.regionRageSkill = nil -- 释放中的区域范围的怒气技能
    self.dispatcher = nil     -- event dispatcher
    self.scheduleEntryID = nil -- update scheduler
    self.scheduleTick = 0
    self.battleSpeedX2 = false

    self.mapMgr = nil
    self.controlPanel = nil
    self.rageMaskLayer = nil -- 怒气技能蒙板（释放怒气技能时黑屏）
    self:initDispatcher()
    self:registerNodeHandler()
    self.handlers = {}
    self:registerBattleHandler()

    self.battleModel = BattleModel.new(self.dispatcher, params, attackerFormInfo, self)

    local function calc_preload_res(battleModel)
        local resList = {}

        local function get_skin_info(heroInfo)
            if heroInfo.type == "hero" then
                local equipInfo = heroInfo.data.Equip 

                if equipInfo then
                    local SkinType = {["ARM"] = 1, ["HAT"] = 2, ["COAT"] = 4}

                    local skinInfo = { 
                        ["Arm"]  = equipInfo[SkinType.ARM].SkinID, 
                        ["Hat"]  = equipInfo[SkinType.HAT].SkinID, 
                        ["Coat"] = equipInfo[SkinType.COAT].SkinID,
                    }

                    return skinInfo
                else
                    return { 
                        ["Arm"]  = 0, 
                        ["Hat"]  = 0, 
                        ["Coat"] = 0,
                    }
                end
            else
                local equipInfo = heroInfo.data.equip or {}

                local skinInfo = { 
                    ["Arm"]  = equipInfo[1], 
                    ["Hat"]  = equipInfo[2], 
                    ["Coat"] = equipInfo[3],
                }

                return skinInfo
            end   
        end

        local function get_skin_res(heroInfo, skinInfo)
            local heroRes = heroInfo.data.Res
            if heroInfo.type == "hero" then
                local heroCfg = BaseConfig.GetHero(heroInfo.data.ID, 1)
                heroRes = heroCfg.res
            end            

            if heroRes ~= "xj_1000" and string.sub(heroRes, 1, 2) == "xj" then
                local res = string.format("res/image/spine/hero/%s", heroRes)
                --table.insert(resList, {res = res, type = "ani"})

                if skinInfo.Arm == 0 or skinInfo.Arm == nil then
                    local res = string.format("res/image/spine/hero/%s/arm/0/skeleton.png", heroRes)
                    table.insert(resList, {res = res, type = "image"})
                else
                    local res = string.format("res/image/spine/hero/arm/%s/skeleton.pvr.ccz", heroRes)
                    table.insert(resList, {res = res, type = "image"})
                end

                local coat = skinInfo.Coat or 0
                local res = string.format("res/image/spine/hero/%s/coat/%s/skeleton.png", heroRes, coat)
                table.insert(resList, {res = res, type = "image"})

                local hat = skinInfo.Hat or 0
                local res = string.format("res/image/spine/hero/%s/hat/%s/skeleton.png", heroRes, hat)
                table.insert(resList, {res = res, type = "image"})
            else
                local res = string.format("res/image/spine/monster/%s", heroRes)
                table.insert(resList, {res = res, type = "ani"})
            end
        end

        local function get_skills(heroInfo)
            if heroInfo.type == "monster" then
                local monster = heroInfo.data
                return {monster.AtkSkill, monster.NorSkill, monster.TfSkill, monster.RpSkill}
            else
                local heroCfg = BaseConfig.GetHero(heroInfo.data.ID, 1)
                return {heroCfg.atkSkill, heroCfg.norSkill, heroCfg.tfSkill, heroCfg.rpSkill}
            end
        end

        local function get_skill_res(skillID)
            local skillData = BaseConfig.GetHeroSkill(skillID, 1)
            local res

            res = "res/image/spine/skill_effect/skill/" .. skillData.Res
            table.insert(resList, {res = res, type = "ani"})

            res = "res/image/spine/skill_effect/skill/" .. skillData.Res .. "/top"
            table.insert(resList, {res = res, type = "ani"})

            res = "res/image/spine/skill_effect/skill/" .. skillData.Res .. "/bottom"
            table.insert(resList, {res = res, type = "ani"})

            res = "res/image/spine/skill_effect/hit/" .. skillID
            table.insert(resList, {res = res, type = "ani"})

            local buffList = skillData.buf
            for _, buf in ipairs(buffList or {}) do

                local bufRes = buf.res 

                if buffRes ~= 0 then 
                    res = "res/image/spine/skill_effect/buff/" .. bufRes
                    table.insert(resList, {res = res, type = "ani"})

                    res = "res/image/spine/skill_effect/buff/top/" .. bufRes
                    table.insert(resList, {res = res, type = "ani"})

                    res = "res/image/spine/skill_effect/buff/bottom/" .. bufRes
                    table.insert(resList, {res = res, type = "ani"})

                    res = "res/image/spine/skill_effect/buffadd/" .. bufRes
                    table.insert(resList, {res = res, type = "ani"})

                    res = "res/image/spine/skill_effect/buffadd/top/" .. bufRes
                    table.insert(resList, {res = res, type = "ani"})

                    res = "res/image/spine/skill_effect/buffadd/bottom/" .. bufRes
                    table.insert(resList, {res = res, type = "ani"})
                end
            end
        end

        table.insert(resList, {res = "res/image/spine/skill_effect/cloud/", type = "ani"})
        table.insert(resList, {res = "res/image/spine/skill_effect/death/", type = "ani"})
        table.insert(resList, {res = "res/image/spine/skill_effect/die/", type = "ani"})
        table.insert(resList, {res = "res/image/spine/skill_effect/treated/top/", type = "ani"})
        table.insert(resList, {res = "res/image/spine/skill_effect/treated/bottom/", type = "ani"})

        if PRELOAD_SKILL_RES then
            for _, heroInfo in ipairs(battleModel.ATKForm) do
                local heroData = heroInfo.data
                local res = heroData.Res
                local skin = get_skin_info(heroInfo)
                get_skin_res(heroInfo, skin)
                local skills = get_skills(heroInfo)

                CCLog(vardump(skills, "skills"))
                for _, skill in ipairs(skills) do
                    if skill ~= nil and skill ~= 0 then
                        get_skill_res(skill)
                    end
                end
            end

            for _, form in ipairs(battleModel.DEFFormList) do
                for _, heroInfo in ipairs(form) do
                    local heroData = heroInfo.data
                    local res = heroData.Res
                    local skin = get_skin_info(heroInfo)
                    get_skin_res(heroInfo, skin)

                    local skills = get_skills(heroInfo)
                    CCLog(vardump(skills, "skills"))

                    for _, skill in ipairs(skills) do
                        if skill ~= nil and skill ~= 0 then
                            get_skill_res(skill)
                        end
                    end
                end
            end
        end
        
        CCLog(vardump({resList = resList}, "battle res")) 
        CCLog(vardump({battleModel.ATKForm, battleModel.DEFFormList}, "battle units"))

        return resList
    end    

    self.backgroupNode = cc.Node:create()
    self:addChild(self.backgroupNode, 1)

    self.farMapNode = cc.Node:create()
    self.backgroupNode:addChild(self.farMapNode, -1)

    self.middleNode = cc.Node:create()
    self:addChild(self.middleNode, 2)

    self.middleMapNode = cc.Node:create()
    self.middleNode:addChild(self.middleMapNode, -1)

    self.battleNode = cc.Node:create() -- cc.LayerColor:create(cc.c4b(100, 0, 0, 100))
    self.middleMapNode:addChild(self.battleNode, 1)
    self.battleNode:setRotationSkewX(BattleConfig.BEVEL_ANGLE)
    self.battleNode:setPosition(BattleConfig.BATTLE_POS)
    self.battleNode:setContentSize(BattleConfig.BATTLE_SIZE)

    self.regionSkillShadow = cc.LayerColor:create(cc.c4b(0, 0, 0, 220))
    self.middleMapNode:addChild(self.regionSkillShadow, 0)
    self.regionSkillShadow:setVisible(false)

    local battleTopPos = self.battleNode:convertToWorldSpace(cc.p(0, BattleConfig.BATTLE_SIZE.height))
    local battleBottomPos = self.battleNode:convertToWorldSpace(cc.p(0, 0))
    local battleHeight = battleTopPos.y - battleBottomPos.y
    local battleScaleY = BattleConfig.BATTLE_SIZE.height / battleHeight

    self.battleNode:setScaleY(battleScaleY)

    -- 调试用的网络
    if false then
        -- 网络显示调度用
        local gridRect = cc.rect(0, 0, BattleConfig.BATTLE_SIZE.width, BattleConfig.BATTLE_SIZE.height)
        local color1 = cc.c4f(1.0, 1.0, 0.0, 0.2)
        local color2 = cc.c4f(0.0, 1.0, 1.0, 0.2)
        local gridLayer = GridLayer.new(gridRect, BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT, color1, color2, 0)
        self.battleNode:addChild(gridLayer)
    end

    self.foregroundNode = cc.Node:create()
    self:addChild(self.foregroundNode, 3)

    self.nearMapNode = cc.Node:create()
    self.foregroundNode:addChild(self.nearMapNode, -1)

--    local player = BattlePlayer.new()
--    self:addChild(player)
--    self.player = player

    local LoadingLayer = nil 

    if (params.battleType == "PVE" or params.battleType == "GUIDE") and params.nodeInfo ~= nil then
        LoadingLayer = require("scene.battle.InstanceLoadingLayer")        
    else
        LoadingLayer = require("tool.helper.BattleLoadingLayer")
    end

    if LoadingLayer then
        local loadingLayer = LoadingLayer.new(params.nodeInfo)
        self:addChild(loadingLayer, 9999)
        self:setLoadingCallback(handler(loadingLayer, loadingLayer.setProgress))
    else
        self:setLoadingCallback(function(progress) CCLog("Loading:", progress) end)
    end

    local on_init_complete = function() 
        if GameCache.AutoBattle then
            self:onAutoBattleClick()

            if GameCache.Avatar.VIP >= 5 and thenGameCache.BattleSpeedX2 then
                self:onAutoBattleClick()
            end
        end
        --self:drawAttackScope()

        self._totalLoading = 95
        self:loadingProgress()
        self:start()
    end

    local function preload()
        local frameTime = 1.0 / 60 * 0.95
        local st = os.clock()
        local preloadResList = calc_preload_res(self.battleModel)
        local textureCache = cc.Director:getInstance():getTextureCache()

        local resCount = #preloadResList
        for idx, res in ipairs(preloadResList) do
            if res.type == "ani" then
                preload_animation(res.res)      
            elseif res.type == "image" then
                textureCache:addImage(res.res)
            elseif res.type == "plist" then
                cc.SpriteFrameCache:getInstance():addSpriteFrames(res.res)
            end      

            local resLoadPercent = idx * 100 / resCount
            self._preloadLoading = resLoadPercent
            self:loadingProgress()

            local ct = os.clock()

            if ct - st > frameTime then
                coroutine.yield()
            end
        end

        local et = os.clock()
        print("preload use time:", et - st)
        self:unschedulePreload()
        on_init_complete()
    end

    local function start_preload()
        self._preload_thread = coroutine.create(preload)
        coroutine.resume(self._preload_thread)
        self:schedulePreload()
    end

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            self.mapPercentPos = 0
            self:loadMap(function() 
                self:runAction(cc.CallFunc:create(function()
                    print("begin init controlls")
                    self:loadingProgress()
                    self:initControlls(start_preload)
                end))
            end)
        end),
    }))

    self.fighterViewMap = {}    -- fighterID:fighterView
    self.magicCircleVewMap = {} -- magicCircleSerialID:magicCiricleView
    self.fighterRegionNodeMap = {} -- fighterID:regionNode
    self.fighterAreaNodeMap = {} -- fighterID:areaNode

    self.bossHPBarMap = {}

--    self:loadMap()
--
--    self._loading = self._loading + 5
--    self:loadingProgress()
--
--
--    self.mapPercentPos = 0
--    self:initControlls()
--
--    --self:drawAttackScope()
--
--    self._loading = self._loading + 10
--    self:loadingProgress()
--
--    self:start()

    if params.nodeID == 2 then
        self:createDamageIconNode()
        self.isCoinsMonster = true
    end
end

function BattleController:battleBreakOff()
    if self.params.battleFormType == GameCache.FORM_TYPE_HOME then
        application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
    end
end

function BattleController:needShowFingerAnimation()
    if (self.params.battleType == "PVE" or self.params.battleType == "GUIDE") and self.params.nodeInfo ~= nil then
        if self.params.battleType == "GUIDE" and GameCache.NewbieGuide.Step == 1 then
            return false
        end

        if self.params.nodeInfo.chapterID == 1 then
            return true
        end
    end
    return false
end

function BattleController:checkViewMap()
    local fighterIDList = table.keys(self.fighterViewMap)
    for _, id in ipairs(fighterIDList) do
        if tolua.isnull(self.fighterViewMap[id]) then
            self.fighterViewMap[id] = nil
        end
    end

    local magicIdList = table.keys(self.magicCircleVewMap)
    for _, id in ipairs(magicIdList) do
        if tolua.isnull(self.magicCircleVewMap[id]) then
            self.magicCircleVewMap[id] = nil
        end
    end
end

function BattleController:setFighterView(fighterID, fighterVew)
    assert(fighterID and type(fighterID) == "string", tostring(fighterID))
    self.fighterViewMap[fighterID] = fighterVew
end

function BattleController:getFighterView(fighterID)
    local fighterVew = self.fighterViewMap[fighterID]

    if fighterVew and tolua.isnull(fighterVew) then
        self.fighterViewMap[fighterID] = nil
        fighterVew = nil
    end

    return fighterVew
end

function BattleController:setMagicCircleView(serialID, magicCircleView)
    self.magicCircleVewMap[serialID] = magicCircleView
end

function BattleController:getMagicCircleView(serialID)
    local magicCircleView = self.magicCircleVewMap[serialID]

    if magicCircleView and tolua.isnull(magicCircleView) then
        self.magicCircleVewMap[serialID] = nil
        magicCircleView = nil
    end

    return magicCircleView
end

function BattleController:getAliveHeroViews(teamSide, includeSummoning)
    local views = {}
    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    elseif teamSide == "right" then
        team = self.battleModel.rightTeam
    end

    local modelCount = 0
    if team then
        local heroModels = team:getAliveHeroModels(includeSummoning)
        modelCount = #heroModels
        for _, heroModel in ipairs(heroModels) do
           local view = self:getFighterView(heroModel:getFighterID())
            if view and not tolua.isnull(view) then
                table.insert(views, view)
            end
        end
    end

    CCLog(vardump({teamSide, includeSummoning, modelCount, #views}, "BattleController:getAliveHeroViews"))
    return views
end

function BattleController:setLoadingCallback(callback)
    self.progressFunc = callback
end

function BattleController:loadingProgress(loading)
    if loading == nil then
        loading = self._mapLoading * 0.25 + self._preloadLoading * 0.45 + self._controllsLoading * 0.3
    end
    CCLog("Loading:", loading)
    if self.progressFunc then
        self.progressFunc(loading)
    end
end

function BattleController:initDispatcher()
    local dispatcher = cc.EventDispatcher:new()
    dispatcher:retain()
    CCLog("dispatcher::getReferenceCount", dispatcher:getReferenceCount())
    dispatcher:setEnabled(true) 
    self.dispatcher = dispatcher
end

function BattleController:registerNodeHandler()
    local function onNodeEvent(event)
        CCLog("BattleController::onNodeEvent(" .. event .. ")")
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

function BattleController:updateAcceleration(times)
    BattleConfig.SPEED_RATIO = times
    self:unscheduleUpdate()
    self:scheduleUpdate()

    for id, view in pairs(self.fighterViewMap) do
        if view and not tolua.isnull(view) then
            xpcall(function() view:setTimeScale(times) end, __G__TRACKBACK__)
        end
    end
end

function BattleController:isAutoBattle()
    return self.battleModel:isAutoBattle()
end

function BattleController:setAutoBattle(val)
    GameCache.AutoBattle = val
    if val then
        self:updateAcceleration(1.5)
        GameCache.BattleSpeedX2 = true
    else
        self:updateAcceleration(1)
        GameCache.BattleSpeedX2 = false
    end

    self.battleModel:setAutoBattle(val)

    if val then
        self:checkAutoBattle("left")
    end
end

function BattleController:loadMap(callback)
    self:loadingProgress()

    --self.player:doCommand("loadMap", self.params.map)
    local map = BattleMapManager.new(self.params.map, self.nearMapNode, self.middleMapNode, self.farMapNode)
    self.mapMgr = map

    map:setLoadingCallback(function(percent)
        CCLog("map loading:", percent)
        self._mapLoading = percent
        self:loadingProgress()
    end)

    map:loadMap(function() 
        print("load map callback")
        if self.params.battleFormType == GameCache.FORM_TYPE_LOOT or self.params.battleFormType == GameCache.FORM_TYPE_TOWER then
            map:setRoundOffsetPercent(1, 0.0)
        elseif self.params.battleType == "PVP" then
            map:setRoundOffsetPercent(1, 1.0)
        end

        callback()
    end)
end

function BattleController:startNextBattleRound()
    if self.startingNextBattleRound then
        CCLog("已经点击了开始")
        return
    end

    if self.battleModel.state ~= "none" then
        CCLog("battleModel.state", self.battleModel.state)
        return
    end

    self.startingNextBattleRound = true
    self.forwordButton:setEnabled(false)
    self.forwordButton:setVisible(false)
    self.battleModel:start()
    self.forwordButton:stopAllActions()
    self.startingNextBattleRound = false
end

function BattleController:initControlls(completeCallback)
    local coro = coroutine.create(function()
        self._controllsLoading = 1

        -- cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/zd.plist", coroutine.yield("res/image/zd.png"))
        -- self._controllsLoading = 9

        -- cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/border.plist", coroutine.yield("image/icon/border.png"))
        -- self._controllsLoading = 18

        -- cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/head.plist", coroutine.yield("image/icon/head.png"))
        -- self._controllsLoading = 27


        cc.SpriteFrameCache:getInstance():addSpriteFrames("image/zd.plist")
        self._controllsLoading = 9

        cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/border.plist")
        self._controllsLoading = 18

        cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/head.plist")
        self._controllsLoading = 27

        --local btn_nextRound = ccui.Button:create("image/ui/img/btn/btn_278.png")
        local btn_nextRound = ccui.Button:create("btn_278.png", "btn_278.png", "btn_278.png", ccui.TextureResType.plistType)
        btn_nextRound:setPosition(display.width - 100,display.cy)
        btn_nextRound:setTitleFontSize(24)
        btn_nextRound:addTouchEventListener(widget_click_listener(function(sender)
            self:startNextBattleRound()
        end))
        btn_nextRound:setVisible(false)
        btn_nextRound:setLocalZOrder(99999)
        btn_nextRound:setScale(1.5)
        self.foregroundNode:addChild(btn_nextRound)
        self.forwordButton = btn_nextRound

        --local roundBg = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1027.png"))
        local roundBg = cc.Sprite:createWithSpriteFrameName("btn_1027.png")
        roundBg:setPosition(cc.p(display.right - 450, display.top - 43))
        self.foregroundNode:addChild(roundBg)

        local roundLabel = CommonTool.finalFont(string.format("%d/%d", self.battleModel.roundIndex, self.battleModel:getRoundCount()) , 0 , 0 , 30, cc.c3b(252, 211, 159), 1)
        roundLabel:setColor(cc.c3b(252, 211, 159))
        local roundSize = roundBg:getContentSize()
        roundLabel:setPosition(cc.p(roundSize.width / 2, roundSize.height / 2))
        roundBg:addChild(roundLabel, 999)
        self.roundLabel = roundLabel

        local timePanel = cc.Node:create()
        timePanel:setAnchorPoint(cc.p(0.5, 0.5))
        timePanel:setContentSize(cc.size(116 + 40, 61))
        timePanel:setPosition(cc.p(display.right - 300, display.top - 43))
        self.foregroundNode:addChild(timePanel)

        local timePanelSize = timePanel:getContentSize()
        --local timeBg = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1027.png"))
        local timeBg = cc.Sprite:createWithSpriteFrameName("btn_1027.png")
        timeBg:setPosition(cc.p(timePanelSize.width / 2, timePanelSize.height / 2))
        timePanel:addChild(timeBg)

        -- local timeIcon = cc.Sprite:createWithTexture(coroutine.yield("image/spine/skill_effect/time.png"))
        local timeIcon = cc.Sprite:createWithSpriteFrameName("time.png")
        timeIcon:setPosition(cc.p(28, timePanelSize.height / 2))
        timePanel:addChild(timeIcon)

        local timeLabel = CommonTool.finalFont("00:00", 0 , 0 , 25, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("00:00", "Arial", 24)
        timeLabel:setColor(cc.c3b(252, 211, 159))
        local size = timeBg:getContentSize()
        timeLabel:setPosition(cc.p(timePanelSize.width / 2 + 20, timePanelSize.height / 2))
        timePanel:addChild(timeLabel, 999)
        self.timeLabel = timeLabel

        local timerPanel = cc.Node:create()
        timerPanel:setAnchorPoint(cc.p(0.5, 0.5))
        timerPanel:setContentSize(cc.size(116 + 40, 61))
        timerPanel:setPosition(cc.p(display.cx, display.top - 100))
        self.foregroundNode:addChild(timerPanel)

        local timerPanelSize = timerPanel:getContentSize()
        -- local timerBg = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1027.png"))
        local timerBg = cc.Sprite:createWithSpriteFrameName("btn_1027.png")
        timerBg:setPosition(cc.p(timerPanelSize.width / 2, timerPanelSize.height / 2))
        timerPanel:addChild(timerBg)

        local timerNameLabel = CommonTool.finalFont("仙友护卫时间:", 0 , 0 , 25, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("00:00", "Arial", 24)
        timerNameLabel:setAnchorPoint(cc.p(1, 0.5))
        timerNameLabel:setDimensions(250, 28)
        timerNameLabel:setColor(cc.c3b(252, 211, 159))
        timerNameLabel:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        local size = timerBg:getContentSize()
        timerNameLabel:setPosition(cc.p(timerPanelSize.width / 2 - 5, timerPanelSize.height / 2))
        timerPanel:addChild(timerNameLabel, 999)

        local timerLabel = CommonTool.finalFont("00:00", 0 , 0 , 24, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("00:00", "Arial", 24)
        timerLabel:setAnchorPoint(cc.p(0, 0.5))
        timerLabel:setDimensions(250, 28)
        timerLabel:setColor(cc.c3b(252, 211, 159))
        timerLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        local size = timerBg:getContentSize()
        timerLabel:setPosition(cc.p(timerPanelSize.width / 2 + 5, timerPanelSize.height / 2))
        timerPanel:addChild(timerLabel, 999)

        timerPanel:setVisible(false)
        self.timerPanel = timerPanel
        self.timerNameLabel = timerNameLabel
        self.timerLabel = timerLabel

        -- local dropBoxBg = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1027.png"))
        local dropBoxBg = cc.Sprite:createWithSpriteFrameName("btn_1027.png")
        dropBoxBg:setPosition(cc.p(display.right - 150, display.top - 43))
        self.foregroundNode:addChild(dropBoxBg)

        local dropBoxSize = dropBoxBg:getContentSize()
        -- local dropBoxIcon = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_445.png"))
        local dropBoxIcon = cc.Sprite:createWithSpriteFrameName("btn_445.png")
        dropBoxIcon:setScale(0.6)
        dropBoxIcon:setPosition(cc.p(0, dropBoxSize.height / 2))
        dropBoxBg:addChild(dropBoxIcon)
        self.dropBoxIcon = dropBoxIcon

        local dropBoxLabel = CommonTool.finalFont("0", 0 , 0 , 25, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("00:00", "Arial", 24)
        dropBoxLabel:setColor(cc.c3b(252, 211, 159))
        local size = timeBg:getContentSize()
        dropBoxLabel:setPosition(cc.p(dropBoxSize.width / 2 + 5, dropBoxSize.height / 2))
        dropBoxBg:addChild(dropBoxLabel, 999)
        self.dropBoxLabel = dropBoxLabel

        local stateLabel = CommonTool.finalFont("none", 0 , 0 , 25, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("00:00", "Arial", 24)
        stateLabel:setColor(cc.c3b(255, 255, 255))
        stateLabel:setPosition(cc.p(display.cx, display.top - 45))
        self.foregroundNode:addChild(stateLabel, 999)
        self.stateLabel = stateLabel
        self.stateLabel:setVisible(false) -- TODO:调度用

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
    --        checkBox:loadTextures("images/common/check_btn_off.png",
    --            "images/common/check_btn_on.png",
    --            "images/common/check_btn_on.png",
    --            "images/common/check_btn_off.png",
    --            "images/common/check_btn_off.png")
    --        checkBox:setPosition(cc.p(display.width / 12 * i, display.top - 20))
    --        checkBox:addEventListenerCheckBox(selectedEvent)
    --        self.foregroundNode:addChild(checkBox)
    --    end

        -- local btn_pause = ccui.Button:create("image/ui/img/btn/btn_805.png", "image/ui/img/btn/btn_805.png")
        local btn_pause = ccui.Button:create("btn_805.png", "btn_805.png", "btn_805.png", ccui.TextureResType.plistType)
        btn_pause:setPosition(display.right - 74 / 2 - 10, display.top - 74 / 2 - 10)
        btn_pause:setName("btn_pause")
        self.foregroundNode:addChild(btn_pause)

        btn_pause:addTouchEventListener(widget_click_listener(function(sender)
            local BattlePauseLayer = require("scene.battle.player.BattlePauseLayer")
            local pauseLayer = BattlePauseLayer.new(self)
            self:addChild(pauseLayer, 99999)

            self:pauseBattle()

            FighterModel.traceAllFighters()
        end))

        -- local btn_playback = ccui.Button:create("image/ui/img/btn/btn_270.png", "image/ui/img/btn/btn_270.png")
        -- --local btn_playback = ccui.Button:create("btn_270.png", "btn_270.png", "btn_270.png", ccui.TextureResType.plistType)
        -- btn_playback:setPosition(display.right - 74 / 2 - 100, display.top - 74 / 2 - 10)
        -- self.foregroundNode:addChild(btn_playback)

        -- btn_playback:addTouchEventListener(widget_click_listener(function(sender)
        --     application:popScene()
        --     application:pushScene("battle.BattlePlayerScene", self.battleModel.battleRecordData)

        --     CCLog("回放")
        -- end))
        -- -- TODO:测试用的
        -- btn_playback:setVisible(false)

        --local btn_autoBattle = ccui.Button:create("image/ui/img/btn/btn_010.png", "image/ui/img/btn/btn_010.png")
        local btn_autoBattle = ccui.Button:create("btn_010.png", "btn_010.png", "btn_010.png", ccui.TextureResType.plistType)
        self.foregroundNode:addChild(btn_autoBattle)

        -- local icon_autoBattle_x2 = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1320.png"))
        local icon_autoBattle_x2 = cc.Sprite:createWithSpriteFrameName("btn_1320.png")        

        btn_autoBattle:setPosition(display.left + 20, display.top - 10)
        btn_autoBattle:setAnchorPoint(cc.p(0, 1))
        local btnSize = btn_autoBattle:getContentSize()
        icon_autoBattle_x2:setPosition(cc.p(175, 40))
        icon_autoBattle_x2:setVisible(false)
        btn_autoBattle:addChild(icon_autoBattle_x2)

        btn_autoBattle:addTouchEventListener(widget_click_listener(function(sender)
            self:onAutoBattleClick()
        end))        

        if self.params.battleType == 'GUIDE' then
            btn_autoBattle:setVisible(false)
            btn_pause:setVisible(false)
        end

        self.btn_autoBattle = btn_autoBattle
        self.icon_autoBattle_x2 = icon_autoBattle_x2

        self._controllsLoading = 30

        completeCallback()
    end)

    start_texture_coroutine(coro)
end

function BattleController:onAutoBattleClick()
    local btn_autoBattle = self.btn_autoBattle
    local icon_autoBattle_x2 = self.icon_autoBattle_x2

    if self.battleModel:isAutoBattle() then
        if self.battleSpeedX2 then
            self:setAutoBattle(false)
            self.battleSpeedX2 = false
            self:updateAcceleration(1)  
            GameCache.BattleSpeedX2 = false               

            -- btn_autoBattle:loadTextures("image/ui/img/btn/btn_010.png", "image/ui/img/btn/btn_010.png")
            -- icon_autoBattle_x2:setTexture("image/ui/img/btn/btn_012.png")
            btn_autoBattle:loadTextures("btn_010.png", "btn_010.png", "btn_010.png", ccui.TextureResType.plistType)
            icon_autoBattle_x2:setSpriteFrame("btn_012.png")
            
            icon_autoBattle_x2:setVisible(false)
        else
            self.battleSpeedX2 = true

            if GameCache.Avatar.VIP >= 5 then
                self:updateAcceleration(1.5)
                GameCache.BattleSpeedX2 = true

                -- btn_autoBattle:loadTextures("image/ui/img/btn/btn_011.png", "image/ui/img/btn/btn_011.png")
                -- icon_autoBattle_x2:setTexture("image/ui/img/btn/btn_013.png")
                btn_autoBattle:loadTextures("btn_011.png", "btn_011.png", "btn_011.png", ccui.TextureResType.plistType)
                icon_autoBattle_x2:setTexture("btn_013.png", ccui.TextureResType.plistType)

                icon_autoBattle_x2:setVisible(true)
            else
                -- btn_autoBattle:loadTextures("image/ui/img/btn/btn_011.png", "image/ui/img/btn/btn_011.png")
                -- icon_autoBattle_x2:setTexture("image/ui/img/btn/btn_012.png")
                btn_autoBattle:loadTextures("btn_011.png", "btn_011.png", "btn_011.png", ccui.TextureResType.plistType)
                icon_autoBattle_x2:setSpriteFrame("btn_012.png")

                icon_autoBattle_x2:setVisible(true)

                application:showFlashNotice(string.format("VIP%d 开启战斗速度X2", 5))
            end 
        end
    else            
        self:setAutoBattle(true)
        self.battleSpeedX2 = false
        self:updateAcceleration(1) 

        -- btn_autoBattle:loadTextures("image/ui/img/btn/btn_011.png", "image/ui/img/btn/btn_011.png")
        -- icon_autoBattle_x2:setTexture("image/ui/img/btn/btn_012.png")
        btn_autoBattle:loadTextures("btn_011.png", "btn_011.png", "btn_011.png", ccui.TextureResType.plistType)
        icon_autoBattle_x2:setSpriteFrame("btn_012.png")

        icon_autoBattle_x2:setVisible(true)
    end

    -- self:setAutoBattle(not self.battleModel:isAutoBattle())
    -- if self.battleModel:isAutoBattle() then
    --     btn_autoBattle:loadTextures("image/ui/img/btn/btn_1315.png", "image/ui/img/btn/btn_1315.png")
    --     icon_autoBattle_active:setTexture("image/ui/img/btn/btn_1317.png")
    --     icon_autoBattle_x2:setTexture("image/ui/img/btn/btn_1318.png")
    --     autoBattleLabel:setColor(cc.c3b(255, 255, 0))
    -- else
    --     btn_autoBattle:loadTextures("image/ui/img/btn/btn_1316.png", "image/ui/img/btn/btn_1316.png")
    --     --autoBattleLabel:setString("自动")
    --     icon_autoBattle_active:setTexture("image/ui/img/btn/btn_1319.png")
    --     icon_autoBattle_x2:setTexture("image/ui/img/btn/btn_1320.png")
    --     --autoBattleLabel:setColor(cc.c3b(252, 221, 159))
    -- end

    if GameCache.NewbieGuide.Step == 3 and GameCache.NewbieGuide.SStep == 5 then
        Common.CloseGuideLayer({3})
        self:resumeBattle()
    end
end

function BattleController:isInRageAttacking()
    return #self.rageAttackDataList > 0 or self.inRageAttacking
end

function BattleController:rageAttackBegin(attackerHeroView)
    CCLog("BattleController:rageAttackBegin:", attackerHeroView:getName())
    if self.inRageAttacking then
        CCLog("already has hero in rage attacking")
        return
    end

    self.inRageAttacking = true

    if BattleConfig.RAGE_SKILL_PAUSE then
        self:pauseBattle()
    end
    attackerHeroView:resumeBattle()

    local maskLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 240))
    maskLayer:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.battleNode:addChild(maskLayer, 999999)
    maskLayer:setContentSize(cc.size(display.width * 2, display.height * 2))
    maskLayer:setPosition(cc.p(-display.width, -display.height))
    attackerHeroView:setLocalZOrder(999999 + 1)
    self.rageMaskLayer = maskLayer

    maskLayer:runAction(cc.FadeOut:create(3))
end

function BattleController:rageAttackHint(attackData)
    local coro = coroutine.create(function()
        local heroModel = attackData:getHeroModel()
        local wx = heroModel:getElemType()
        local skillID = attackData:getSkillID()

        local skillNamePath = string.format("image/skill/%d.png", skillID)
        if not cc.FileUtils:getInstance():isFileExist(skillNamePath) then
            skillNamePath = "image/skill/1301.png"
        end

        local spriteSkillName = cc.Sprite:createWithTexture(coroutine.yield(skillNamePath))
        spriteSkillName:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT * 0.7)
        self:addChild(spriteSkillName, 1000)

        local wxBgPath = string.format("image/skill/skill_bg_clore_%d.png", wx)
        local spriteBg = cc.Sprite:createWithTexture(coroutine.yield(wxBgPath))
        spriteBg:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.7)
        self:addChild(spriteBg, 999)

        local moveTime = 0.4
        local move1 = cc.EaseBounceOut:create(cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.6, SCREEN_HEIGHT * 0.7)))
        local move2 = cc.EaseBounceOut:create(cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.7)))

        local scale1 = cc.ScaleTo:create(0.02, 1.6)
        local rotate1 = cc.RotateTo:create(0.03, -0.4)
        local rotate2 = cc.RotateTo:create(0.03, 0.2)
        local rotate3 = cc.RotateTo:create(0.03, -0.1)
        local rotate5 = cc.RotateTo:create(0.03, 0)
        local delay1 = cc.DelayTime:create(0.4)
        local delay2 = cc.DelayTime:create(0.54)
        local removeSelf = cc.RemoveSelf:create()
        local scaleClose = cc.ScaleTo:create(0.2, 1, 0)
        spriteSkillName:runAction(cc.Sequence:create(move1, scale1,
            rotate1, rotate2, rotate3, rotate5, delay1, scaleClose, removeSelf:clone()))
        spriteBg:runAction(cc.Sequence:create(move2, delay2, scaleClose:clone(), removeSelf:clone()))
    end)

    start_texture_coroutine(coro)
end

function BattleController:shake(duration, strength)
    local d = duration or 0.1
    local s = strength or 10

    local action = cc.Sequence:create({cc.Shake:create(d, s), cc.CallFunc:create(function() self:setPosition(cc.p(0, 0))  end)})
    self:runAction(action)
end

function BattleController:rageAttackEnd(attackerHeroModel)
    if self.params.battleType == 'GUIDE' and attackerHeroModel and attackerHeroModel:getTeamSide() == "left" then
        --self.battleModel.paused = false
        self.battleModel:decPausedCount()
    end

    if self.params.battleType == "GUIDE" then        
        if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
            Common.CloseGuideLayer({1})
            self.battleModel.guideStepInfo.step = 2
            CCLog("GUIDE: 猪八戒释放技能")
        elseif self.battleModel.guideStepInfo.step == 2  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 and 10000004 == attackerHeroModel:getHeroID() then
            Common.CloseGuideLayer({1})
            self.battleModel.guideStepInfo.step = 3
            CCLog("GUIDE: 沙僧释放技能")
        elseif self.battleModel.guideStepInfo.step == 3  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 and 10000001 == attackerHeroModel:getHeroID() then
            Common.CloseGuideLayer({1})
            self.battleModel.guideStepInfo.step = 4
            CCLog("GUIDE: 唐僧释放技能")
        elseif self.battleModel.guideStepInfo.step == 4  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 and 10000002 == attackerHeroModel:getHeroID() then
            Common.CloseGuideLayer({1})
            self.battleModel.guideStepInfo.step = 5
            CCLog("GUIDE: 孙悟空释放技能")            
        else
            CCLog(vardump({bstep = self.battleModel.guideStepInfo.step, step = GameCache.NewbieGuide.Step, r = self.battleModel.roundIndex}, "GUIDE 释放"))
        end

        if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 1 then
            Common.CloseGuideLayer({2})
            self.battleModel.guideStepInfo.step = 2
            CCLog("GUIDE: 猪八戒释放技能")
        end

        -- if self.battleModel.guideStepInfo.step == 2 and self.battleModel.guideStepInfo.open[2] and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 2 then
        --     Common.CloseGuideLayer({2})
        --     self.battleModel.guideStepInfo.step = 3
        --     CCLog("GUIDE: 猪八戒释放技能")
        -- end

        -- if self.battleModel.guideStepInfo.step == 3 and self.battleModel.guideStepInfo.open[3] and GameCache.NewbieGuide.Step == 3 and self.battleModel.roundIndex == 2 then
        --     Common.CloseGuideLayer({0})
        --     self.battleModel.guideStepInfo.step = 4
        --     CCLog("GUIDE: 吕洞宾释放技能")

        --     self:resumeBattle()
        -- end
    end

    self.inRageAttacking = false

    self:resumeBattle()

    local maskLayer = self.rageMaskLayer
    self.rageMaskLayer = nil
    if maskLayer and not tolua.isnull(maskLayer) then
        maskLayer:removeFromParent()
    end

    self:updateZOrder()
end

function BattleController:pauseAnimation()
    self:checkViewMap()

    for _, fighterView in pairs(self.fighterViewMap) do
        fighterView:pauseBattle()
    end

    for _, magicView in pairs(self.magicCircleVewMap) do
        magicView:pauseBattle()
    end

    for _, aniNode in ipairs(self.bulletList) do
        aniNode:pause()
    end
end

function BattleController:resumeAnimation()
    self:checkViewMap()

    for _, fighterView in pairs(self.fighterViewMap) do
        fighterView:resumeBattle()
    end

    for _, magicView in pairs(self.magicCircleVewMap) do
        magicView:resumeBattle()
    end

    for _, aniNode in ipairs(self.bulletList) do
        aniNode:resume()
    end
end


function BattleController:pauseBattle()
    --CCLog("BattleController:pauseBattle", debug.traceback())
    --self.battleModel.paused = true    
    if self.battleModel.pausedCount == 0 then
        self:pauseAnimation()
    else
        CCLog("BattleController:pauseBattle(", self.battleModel.pausedCount, ")")
    end

    self.battleModel:incPausedCount()
end

function BattleController:resumeBattle()
    --CCLog("BattleController:resumeBattle", debug.traceback())
    --self.battleModel.paused = false
    self.battleModel:decPausedCount()

    if self.battleModel.pausedCount == 0 then
        self:resumeAnimation()
    end
end

-- function BattleController:pauseBattleAnimation()
--     --CCLog("BattleController:pauseBattleAnimation", debug.traceback())
--     --self.battleModel.aniPaused = true
--     self.battleModel:incPausedCount()

--     self:pauseAnimation()
-- end

-- function BattleController:resumeBattleAnimation()
--     --CCLog("BattleController:resumeBattleAnimation", debug.traceback())
--     --self.battleModel.aniPaused = false
--     self.battleModel:decPausedCount()

--     if self.battleModel.pausedCount == 0 then
--         self:resumeAnimation()
--     end
-- end

function BattleController:initControlPanel()
    if self.controlPanel then
        self.controlPanel:removeFromParent()
    end

    local controlPanel = BattleControlPanel.new(self.battleModel, self, self.battleModel.leftTeam:getAliveHeroModels())
    assert(controlPanel)
    self.foregroundNode:addChild(controlPanel)
    self.controlPanel = controlPanel
end

function BattleController:enableRageSkill(heroModel)
    if self.params.battleType == "GUIDE" then
        if GameCache.NewbieGuide.Step == 1 then
            if GameCache.NewbieGuide.SStep >= 14 then
                return true
            end

            local heroID = heroModel:getHeroID()
            if heroID == 10000002 or heroID == 10000001 or heroID == 10000004 or heroID == 1027 then
                return Common._isGuideOpen
            end
        end
    end
    return true
end

function BattleController:onTeamRageChanged(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local teamSide = data.teamSide

    if teamSide == "left" then
        self.controlPanel:onTeamRageChanged(name, data)

        if self.params.battleType == "GUIDE" then
            local leftTeam = self.battleModel.leftTeam
            local rage = leftTeam:getRage()

            CCLog(vardump({guideStep = GameCache.NewbieGuide.Step, bstep = self.battleModel.guideStepInfo.step, sstep =GameCache.NewbieGuide.SStep, round = self.battleModel.roundIndex, rage = rage}, "GUIDE"))

 
            if GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1  then

                if self.battleModel.guideStepInfo.step == 1 and rage >= 12 then
                    self:pauseBattle()
                    Common.OpenGuideLayer({1})
                    CCLog("GUIDE: 猪八戒可点")
                elseif  self.battleModel.guideStepInfo.step == 2 and rage >= 14 then
                    self:pauseBattle()
                    Common.OpenGuideLayer({1})
                    CCLog("GUIDE: 沙僧可点")
                elseif rage >= 14 and self.battleModel.guideStepInfo.step == 3 then
                    self:pauseBattle()
                    Common.OpenGuideLayer({1})
                    CCLog("GUIDE: 唐僧可点")
                elseif rage >= 16 and self.battleModel.guideStepInfo.step == 4 then
                    self:pauseBattle()
                    Common.OpenGuideLayer({1})
                    CCLog("GUIDE: 孙悟空可点")
                end
            end

            if GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 1 and rage >= 12 then
                if self.battleModel.guideStepInfo.step == 1 then
                    self:pauseBattle()
                    Common.OpenGuideLayer({2})
                    CCLog("GUIDE: 猪八戒可点")
                end
            end

            -- if not self.battleModel.guideStepInfo.open[2] and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 2 and rage >= 12 then
            --     if self.battleModel.guideStepInfo.step == 2 then
            --         self.battleModel.guideStepInfo.open[2] = true
            --         self:pauseBattle()
            --         Common.OpenGuideLayer({2})
            --         CCLog("GUIDE: 猪八戒可点")
            --     end
            -- end

            -- if not self.battleModel.guideStepInfo.open[3] and GameCache.NewbieGuide.Step == 0 and self.battleModel.roundIndex == 2 and rage >= 16 then
            --     if self.battleModel.guideStepInfo.step == 3 then                    
            --         self.battleModel.guideStepInfo.open[3] = true
            --         self:pauseBattle()
            --         Common.OpenGuideLayer({0})
            --         CCLog("GUIDE: 吕洞宾可点")
            --     end
            -- end
        end
    end

    self:checkAutoBattle(teamSide)
end

function BattleController:checkAutoBattle(teamSide)
    --CCLog("BattleController:checkAutoBattle(", teamSide, ")")
    local state = self.battleModel:getState()

    if state == "fight" then
        if teamSide == "right" or (teamSide == "left" and self:isAutoBattle())  then
            local team = teamSide == "left" and self.battleModel.leftTeam or self.battleModel.rightTeam

            if team:getResurrectionData() == nil then
                local includeSummoning = teamSide == "right" and self.params.battleType ~= "PVP" 

                local heroModelList = team:getAliveHeroModels(includeSummoning)
                for idx, heroModel in ipairs(heroModelList) do
                    if team:canAutoReleaseRageSkill(heroModel) then
                        heroModel:performRageSkill()
                        return
                    end
                end
            else
                local heroModelList = team:getDeadHeroModels()
                for idx, heroModel in ipairs(heroModelList) do
                    if team:heroCanResurrect(heroModel) then
                        team:resurrectHero(heroModel, self.battleModel)
                        break
                    end
                end
                team:resetResurrectionData()
            end

            local fairyModel = team:getFairyModel()
            if fairyModel and not fairyModel:isInCooling() then
                fairyModel:autoReleaseSkill()
            end
        end
    end
end

function BattleController:loadWxBg(callback)
    local coro = coroutine.create(function()
        self.wxBG = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_367.png"))
        self.wxBG:setLocalZOrder(9999999)
        self.wxBG.wx1Pos = {140, 40}
        self.wxBG.sheng = {200, 35}
        self.wxBG.wx2Pos = {260, 40}
        local wxGrid1 = cc.NodeGrid:create()
        wxGrid1:setPosition(self.wxBG.wx1Pos[1], self.wxBG.wx1Pos[2])
        wxGrid1:setName("wxBG1")
        self.wxBG:addChild(wxGrid1)
        local labelWx1 = cc.LabelAtlas:_create("1", "image/ui/img/btn/btn_372.png", 88, 88,  string.byte("1"))
        labelWx1:setAnchorPoint(0.5, 0.5)
        labelWx1:setName("wx")
        wxGrid1:addChild(labelWx1)
        local sheng = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_371.png"))
        sheng:setPosition(self.wxBG.sheng[1], self.wxBG.sheng[2])
        sheng:setName("sheng")
        self.wxBG:addChild(sheng)
        local wxGrid2 = cc.NodeGrid:create()
        wxGrid2:setPosition(self.wxBG.wx2Pos[1], self.wxBG.wx2Pos[2])
        wxGrid2:setName("wxBG2")
        self.wxBG:addChild(wxGrid2)
        local labelWx2 = cc.LabelAtlas:_create("1", "image/ui/img/btn/btn_372.png", 88, 88,  string.byte("1"))
        labelWx2:setAnchorPoint(0.5, 0.5)
        labelWx2:setName("wx")
        wxGrid2:addChild(labelWx2)

        self.comboBG = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_366.png"))
        local spriteComboHit = cc.Sprite:create(coroutine.yield("image/ui/img/btn/btn_368.png"))
        spriteComboHit:setPosition(cc.p(200, 50))
        self.comboBG:addChild(spriteComboHit)
        local labelAdd = Common.finalFont("0", 1, 1, 25, nil, 1)
        labelAdd:setPosition(cc.p(310, 70))
        labelAdd:setName("add")
        self.comboBG:addChild(labelAdd)
        local labelTimes = cc.LabelAtlas:_create("1", "image/ui/img/btn/btn_370.png", 111, 132,  string.byte("0"))
        labelTimes:setPosition(cc.p(35, -20))
        labelTimes:setName("comboNum")
        self.comboBG:addChild(labelTimes)
        self.wxBG:setPosition(-SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.85)
        self.comboBG:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.75)
        self:addChild(self.wxBG, 4)
        self:addChild(self.comboBG, 5)

        callback()
    end)

    start_texture_coroutine(coro)
end

function BattleController:comboAction(buffElemType, comboTimes)
    local function callback()
        local function flyOut()
            local delayTime = 0.2
            local moveTime = 0.2
            local delay = cc.DelayTime:create(delayTime)
            local fadeOut = cc.FadeOut:create(moveTime)
            local wxMove = cc.EaseElasticIn:create((cc.MoveTo:create(moveTime, cc.p(-SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.85))))
            local comboMove = cc.EaseElasticIn:create((cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.75))))
            self.wxBG:runAction(cc.Spawn:create(wxMove, fadeOut:clone()))
            self.comboBG:runAction(cc.Spawn:create(comboMove, fadeOut:clone()))
        end
        
        -- 五行相生动作
        local function wxShengWx(wxBG1, wxBG2, sheng, wxType)
            local rotateTime = 0.1
            local shengBlinkTime = 0.1
            local rotateDelay = cc.DelayTime:create(rotateTime)
            local shengDelay = cc.DelayTime:create(shengBlinkTime)
            local rotate = cc.RotateBy:create(rotateTime, 360)
            local scale1 = cc.ScaleTo:create(0.04, 1.5)
            local scale2 = cc.ScaleTo:create(0.02, 1)
            wxBG1:runAction(cc.Sequence:create(rotate, scale1, scale2, shengDelay, cc.CallFunc:create(function()
                wxBG1:setGrid(nil)
                local func11 = cc.CallFunc:create(function()
                    wxBG2:setGrid(nil)
                end)
                wxBG2:setScale(1)
                local move = cc.MoveTo:create(0.2, cc.p(self.wxBG.wx2Pos[1], self.wxBG.wx2Pos[2]))
                local waves = cc.Waves3D:create(0.2, cc.size(15,10), 4, 30)
                local spawn = cc.Spawn:create(move, waves)
                local delayOut = cc.DelayTime:create(3)
                local outFunc = cc.CallFunc:create(function()
                    flyOut()
                end)
                wxBG2:runAction(cc.Sequence:create(spawn, func11, delayOut, outFunc))
            end)))
            local shengScale = cc.ScaleTo:create(rotateTime, 1)
            sheng:runAction(cc.Sequence:create(shengScale))
        end

        -- 刚入场时的五行动作
        local function firstWxAction(wxBG1, wxBG2, sheng, wxType)
            wxBG1:stopAllActions()
            wxBG2:stopAllActions()
            sheng:stopAllActions()
            wxBG2:setPosition(self.wxBG.wx1Pos[1], self.wxBG.wx1Pos[2])
            wxShengWx(wxBG1, wxBG2, sheng, wxType)
        end

        -- 连击时五行的动作
        local function comboWxAction(wxBG1, wxBG2, sheng, wx1Value, wx2Value)
            -- 将所有用到的动作都重置
            wxBG1:stopAllActions()
            wxBG2:stopAllActions()
            sheng:stopAllActions()
            wxBG1:setRotation(0)
            wxBG1:setScale(1)
            wxBG1:setPosition(self.wxBG.wx1Pos[1], self.wxBG.wx1Pos[2])
            wxBG2:setGrid(nil)
            wxBG2:setScale(1)
            wxBG2:setPosition(self.wxBG.wx2Pos[1], self.wxBG.wx2Pos[2])
            sheng:setScale(0)

            local leftMoveTime = 0.04
            local wxBG2_leftMove = cc.MoveTo:create(leftMoveTime, cc.p(self.wxBG.wx1Pos[1], self.wxBG.wx1Pos[2]))
            local wxBG2_leftRotate = cc.RotateBy:create(leftMoveTime, 360)
            local leftMoveSpawn = cc.Spawn:create(wxBG2_leftMove, wxBG2_leftRotate)
            local func1 = cc.CallFunc:create(function()
                local wx1 = wxBG1:getChildByName("wx")
                local wx2 = wxBG2:getChildByName("wx")
                wx1:setString(wx1Value)
                wx2:setString(wx2Value)
                wxBG2:setScale(0)
            end)
            local delay = cc.DelayTime:create(0.02)
            local func2 = cc.CallFunc:create(function()
                wxShengWx(wxBG1, wxBG2, sheng, wx2Value)
            end)
            wxBG2:runAction(cc.Sequence:create(leftMoveSpawn, func1, delay, func2))
        end

        local function flyIn(wxBG1, wxBG2, sheng, wxType)
            local moveTime = 0.6
            local fadeIn = cc.FadeIn:create(moveTime)
            local wxMove = cc.EaseBounceOut:create((cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.56, SCREEN_HEIGHT * 0.85))))
            local comboMove = cc.EaseBounceOut:create((cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH * 0.68, SCREEN_HEIGHT * 0.75))))
            local wxSpawn = cc.Spawn:create(wxMove, fadeIn:clone())
            local comboSpawn = cc.Spawn:create(comboMove, fadeIn:clone())
            local func = cc.CallFunc:create(function()
                firstWxAction(wxBG1, wxBG2, sheng, wxType)
            end)
            self.wxBG:runAction(cc.Sequence:create(wxSpawn, func))
            self.comboBG:runAction(comboSpawn)
        end

        -- 连击数字变化和背景抖动
        local function comboCountAction(comboLabel)
            local moveTime = 0.02
            local wxBG = cc.MoveBy:create(moveTime, cc.p(15, 0))
            local wxBG_reverse = wxBG:reverse()
            local comboBG = cc.MoveBy:create(moveTime, cc.p(-15, 0))
            local comboBG_reverse = comboBG:reverse()
            self.wxBG:runAction(cc.Sequence:create(wxBG, wxBG_reverse))
            self.comboBG:runAction(cc.Sequence:create(comboBG, comboBG_reverse))

            comboLabel:stopAllActions()
            comboLabel:setScale(1)
            local scale1 = cc.ScaleTo:create(0.1, 1.6)
            local scale2 = cc.ScaleTo:create(0.02, 1)
            comboLabel:runAction(cc.Sequence:create(scale1, scale2))
        end

        if buffElemType ~= nil and comboTimes > 1 then
            local genElemType
            for wx = 1, 5 do
                if ElemType.generate(wx, buffElemType) then
                    genElemType = wx
                    break
                end
            end

            local wxBG1 = self.wxBG:getChildByName("wxBG1")
            local wx1 = wxBG1:getChildByName("wx")
            local sheng = self.wxBG:getChildByName("sheng")
            local wxBG2 = self.wxBG:getChildByName("wxBG2")
            local wx2 = wxBG2:getChildByName("wx")

            local comboLabel = self.comboBG:getChildByName("comboNum")
            local addLabel = self.comboBG:getChildByName("add")

            comboLabel:setString(comboTimes)
            addLabel:setString(string.format("+%02d%%", 10 * (comboTimes - 1)))
            self.wxBG:stopAllActions()
            self.comboBG:stopAllActions()
            if self.isComboing then
                self.wxBG:setOpacity(255)
                self.comboBG:setOpacity(255)
                self.wxBG:setPosition(SCREEN_WIDTH * 0.56, SCREEN_HEIGHT * 0.85)
                self.comboBG:setPosition(SCREEN_WIDTH * 0.68, SCREEN_HEIGHT * 0.75)

                comboCountAction(comboLabel)
                comboWxAction(wxBG1, wxBG2, sheng, genElemType, buffElemType)
            else
                wx1:setString(genElemType)
                wx2:setString(buffElemType)

                self.isComboing = true
                self.wxBG:setOpacity(0)
                self.comboBG:setOpacity(0)
                sheng:setScale(0)
                wxBG2:setScale(0)
                self.wxBG:setPosition(-SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.85)
                self.comboBG:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.75)

                flyIn(wxBG1, wxBG2, sheng, buffElemType)
            end
        else
            self.isComboing = false
            flyOut()
        end
    end

    if self.wxBG == nil then
        self:loadWxBg(callback)
    end
end

function BattleController:onTeamComboHit(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local teamSide = data.teamSide
    local buffElemType = data.elemType

    if teamSide == "left" then
        self.controlPanel:onTeamComboHit(name, data)

        local leftTeam = self.battleModel.leftTeam
        local comboTimes = leftTeam:getBuffComboHitTimes()

        CCLog("连击:", comboTimes)
        self:comboAction(buffElemType, comboTimes)
    end
end

function BattleController:onTeamLineup(name, data)
    local eventData = data
    local teamSide = eventData.teamSide

    CCLog(vardump(eventData, "BattleController:onTeamLineup(event)"))
    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    else
        team = self.battleModel.rightTeam
    end

    local heroViews = self:getAliveHeroViews(teamSide)
    for _, heroView in ipairs(heroViews) do
        heroView:setVisible(true)
    end

--    local obstacleViews = self.battleModel.gameObstacle:getObstacleViews()
--    for _, obstacleView in ipairs(obstacleViews) do
--        obstacleView:setVisible(true)
--    end

    if self.battleModel.roundIndex == 1 then
        local fairyModel = team:getFairyModel()
        -- 只显示攻击方仙女
        if fairyModel and teamSide == "left" then
            local headIconPath = fairyModel:getHeadIconPath()
            local skillID1 = fairyModel:getSkill(1)
            local skillID2 = fairyModel:getSkill(2)

            local fairyView = BattleFairyView.new(self, teamSide, skillID1, skillID2, headIconPath)
            self:setFighterView(fairyModel:getFighterID(), fairyView)

            CCLog("create fairyView")
            self:addChild(fairyView, 3)

            if teamSide == "left" then
                fairyView:setPosition(cc.p(100, 90))
            else
                fairyView:setPosition(cc.p(960 - 100, 90))
            end
        end
    end

--    local heroModels = team:getAliveHeroModels()
--
--    for _, heroModel in ipairs(heroModels) do
--        local cell = heroModel:getCell()
--
--        local pos = BattleConfig.getCellPos(cell.x, cell.y)
--        local heroView = BattleHeroView.new(heroModel)
--        self:addChild(heroView)
--        heroView:setEventDispatcher(self.dispatcher)
--        heroView:setPosition(pos)
--        heroView:ready()
--
--        heroView:setAutoHideHPBar(teamSide == "left" )
--
--        team:setHeroView(heroModel, heroView)
--    end

    if teamSide == "left" then
       self:initControlPanel()
    end

    if teamSide == "left" and self.battleModel.roundIndex == 1 then
        self._controllsLoading = 100
        self:loadingProgress(100)
    end

    if teamSide == "left" and self.battleModel.roundIndex > 1 then
       --self.battleModel.paused = true
       self.battleModel:incPausedCount()

       CCLog("team lineup, battleModel sleep")
        self:runAction(cc.Sequence:create({
            cc.DelayTime:create(1.5),
            cc.CallFunc:create(function() 
                --self.battleModel.paused = false
                self:resumeBattle()
            end)
        }))
    end

    self:updateZOrder()
end

function BattleController:onHeroLineup(name, data)
    local teamSide = data.teamSide
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    FighterModel.traceAllFighters()

    CCLog(vardump(data, "BattleController:onHeroLineup(event)"))

    if self.battleModel.roundIndex == 1 then
        self._controllsLoading = self._controllsLoading + 5
        self:loadingProgress()
    end
    
    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    else
        team = self.battleModel.rightTeam
    end

    local cell = heroModel:getCell()
    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)

    local st = os.clock()
    local heroView = BattleHeroView.new(data.modelAttr)
    self:setFighterView(fighterID, heroView)

    heroView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    local et = os.clock()
    CCLog("创建英雄使用时间:", et - st)

    heroView:setVisible(false)
    self.battleNode:addChild(heroView)
    heroView:setGlobalZOrder(100)
    heroView:setEventDispatcher(self.dispatcher)
    heroView:setPosition(_PPOS(pos))
    heroView:ready()

    heroView:setAutoHideHPBar(teamSide == "left" )

    heroModel:setView(heroView)

    if data.modelAttr.isBoss then
        local bossModel = heroModel
        local bossHPBar = require("scene.battle.controller.BossHPBar").new(data.modelAttr)
        self.foregroundNode:addChild(bossHPBar)
        bossHPBar:setVisible(false)
       
        self.bossHPBarMap[bossModel] = bossHPBar
    end
end

-- 召唤怪物
function BattleController:onSummoning(name, data)
    local teamSide = data.teamSide
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    FighterModel.traceAllFighters()

    CCLog(vardump(data, "BattleController:onSummoning(event)"))

    local team = nil
    local enemyTeam = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        team = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    enemyTeam:onEnemyChanged()

    local cell = heroModel:getCell()
    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)

    local st = os.clock()
    local heroView = BattleHeroView.new(data.modelAttr)
    self:setFighterView(fighterID, heroView)

    heroView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    local et = os.clock()
    CCLog("创建英雄使用时间:", et - st)


    self.battleNode:addChild(heroView)
    heroView:setGlobalZOrder(100)
    heroView:setEventDispatcher(self.dispatcher)
    heroView:setPosition(_PPOS(pos))
    heroView:ready()
    heroView:setAutoHideHPBar(teamSide == "left" )
    heroView:setVisible(false)
    heroModel:setView(heroView)

    local path = string.format("image/spine/skill_effect/summon/")
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)

        skillAni:setPosition(_PPOS(pos))
        skillAni:setLocalZOrder(heroView:getLocalZOrder())

        self.battleNode:addChild(skillAni)
        skillAni:setVisible(false)
        skillAni:runAction(cc.Sequence:create({
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
            end),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                heroView:setVisible(true),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)

        skillAni:registerSpineEventHandler(function(event)
            heroView:runAction(cc.FadeOut:create(0.5))
        end, sp.EventType.ANIMATION_EVENT)

    else
        CCLog("load animation fail:", path, "not found")
    end

    self:updateZOrder()

    if data.modelAttr.isBoss then
        local bossModel = heroModel
        local bossHPBar = require("scene.battle.controller.BossHPBar").new(data.modelAttr)
        self.foregroundNode:addChild(bossHPBar)
        bossHPBar:setVisible(false)
       
        self.bossHPBarMap[bossModel] = bossHPBar

        self:showBossHPBar()
    end
end

function BattleController:onSummonTarget(name, data)
    local HatredTargetView = require("scene.battle.view.HatredTargetView")

    local teamSide = data.teamSide
    local fighterID = data.fighterID
    local res = data.res
    local cell = data.cell
    local direction = data.direction
    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)

    local fighterView = HatredTargetView.new(res, true)
    self.battleNode:addChild(fighterView)
    fighterView:setPosition(_PPOS(pos))
    fighterView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self:setFighterView(fighterID, fighterView)

    local team = nil
    local enemyTeam = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        team = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    enemyTeam:onEnemyChanged()

    self:updateZOrder()
end

-- 召唤怪物
function BattleController:onReplication(name, data)
    CCLog(vardump(data, "BattleController:onReplication(event)"))

    local teamSide = data.teamSide
    local fighterIDList = {data.fighterID1, data.fighterID2}

    for _, fighterInfo in ipairs(data.fighterList) do
        local fighterID = fighterInfo.fighterID
        local modelAttr = fighterInfo.modelAttr

        local heroModel = FighterModel.getFighter(fighterID)
        FighterModel.traceAllFighters()

        local cell = heroModel:getCell()
        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)

        local st = os.clock()
        local heroView = BattleHeroView.new(modelAttr)
        self:setFighterView(fighterID, heroView)

        heroView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        local et = os.clock()
        CCLog("创建英雄使用时间:", et - st)

        self.battleNode:addChild(heroView)
        heroView:setGlobalZOrder(100)
        heroView:setEventDispatcher(self.dispatcher)
        heroView:setPosition(_PPOS(pos))
        heroView:ready()

        heroView:setAutoHideHPBar(teamSide == "left" )

        heroModel:setView(heroView)
        heroView:playReplicationAnimation()
    end

    local team = nil
    local enemyTeam = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        team = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    enemyTeam:onEnemyChanged()

    self:updateZOrder()
end

function BattleController:onTurnIntoEgg(name, data)
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local view = self:getFighterView(fighterID)
    if view then
       view:turnIntoEgg()
    else
        local heroView = BattleHeroView.new(data.modelAttr)
        self:setFighterView(fighterID, heroView)

        heroView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)

        local cell = heroModel:getCell()
        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)

        self.battleNode:addChild(heroView)
        heroView:setGlobalZOrder(100)
        heroView:setEventDispatcher(self.dispatcher)
        heroView:setPosition(_PPOS(pos))
        heroView:ready()
        heroView:turnIntoEgg()

        local teamSide = heroModel:getTeamSide()
        heroView:setAutoHideHPBar(teamSide == "left" )

        heroModel:setView(heroView)
    end

    local teamSide = heroModel:getTeamSide()
    local team = nil
    local enemyTeam = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
        enemyTeam = self.battleModel.rightTeam
    else
        team = self.battleModel.rightTeam
        enemyTeam = self.battleModel.leftTeam
    end

    enemyTeam:onEnemyChanged()
end

function BattleController:onEggExpired(name, data)
    local teamSide = data.teamSide
    local fighterID = data.fighterID
    local eggModel = FighterModel.getFighter(fighterID)
    local orignHeroModel = eggModel:getOriginHeroModel()
    orignHeroModel:resurrect(nil, orignHeroModel:getRawFullHP())
end

-- 复活
function BattleController:onResurrection(name, data)
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local teamSide = heroModel:getTeamSide()

    local cell = heroModel:getCell()

    local oldHeroView = self:getFighterView(fighterID)
    if oldHeroView then
        oldHeroView:removeFromParent()
    end

    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
    local heroView = BattleHeroView.new(data.modelAttr)
    self:setFighterView(fighterID, heroView)

    heroView:setGlobalZOrder(100)
    heroView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)

    self.battleNode:addChild(heroView)
    heroView:setEventDispatcher(self.dispatcher)
    heroView:setPosition(_PPOS(pos))
    heroView:ready()
    heroView:updateHPPercent(data.hpPercent)

    heroView:setAutoHideHPBar(teamSide == "left" )

    heroModel:setView(heroView)
    heroView:resurrect()
    self:updateZOrder()

    self.battleModel.leftTeam:onEnemyChanged()
    self.battleModel.rightTeam:onEnemyChanged()
    
    self.controlPanel:refresh()

    self:updateZOrder()
end

--function BattleController:onResurrecting(name, data)
--    local teamSide = data.teamSide
--
--    if teamSide == "right" or (teamSide == "left" and self:isAutoBattle())  then
--        local team = teamSide == "left" and self.battleModel.leftTeam or self.battleModel.rightTeam
--
--        -- 复活
--        local deadHeroModels = team:getDeadHeroModels()
--        for idx, heroModel in ipairs(deadHeroModels) do
--            if team:heroCanResurrect(heroModel) then
--                team:resurrectHero(heroModel, self.battleModel)
--                return
--            end
--        end
--    end
--end

function BattleController:onHeroRelineup(name, data)
    local teamSide = data.teamSide
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local cell = data.cell

    CCLog(vardump(data, "BattleController:onHeroLineup(event)"))

    local heroView = self:getFighterView(fighterID)

--    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
--    heroView:stopAllActions()
--    heroView:setDirection(heroModel:getDirection())
--    heroView:relineup(pos)

    heroView:ready()
end

function BattleController:onTeamRelineup(name, data)
    local teamSide = data.teamSide

    CCLog(vardump(data, "BattleController:onTeamRelineup(event)"))

    self:updateZOrder()
end

function BattleController:updateControlPanel()
    self.controlPanel:refresh()
end

function BattleController:updateCDBar()
    if self.controlPanel then
        self.controlPanel:updateCDBar()
    end
    
--    local fairyModel = self.battleModel.leftTeam:getFairyModel()
--    if fairyModel then
--        local fairyView = self:getFighterView(fairyModel:getFighterID())
--        if fairyView and not tolua.isnull(fairyView) then
--            fairyView:update()
--        end
--    end
--
--    local fairyModel = self.battleModel.rightTeam:getFairyModel()
--    if fairyModel then
--        local fairyView = self:getFighterView(fairyModel:getFighterID())
--        if fairyView and not tolua.isnull(fairyView) then
--            fairyView:update()
--        end
--    end
end

function BattleController:updateHPBar()
    self.controlPanel:updateHPBar()
end

function BattleController:updateRoundLabel()
    local roundLabel = self.roundLabel
    roundLabel:setString(string.format("%d/%d", self.battleModel.roundIndex, self.battleModel:getRoundCount()))
end

function BattleController:updateTimeLabel()
    self.timeLabel:setString(self.battleModel:getTimeLeftStr())
end

function BattleController:updateTimerLabel()
    if self.battleModel.timer then
        self.timerNameLabel:setString(self.battleModel:getTimerName())
        self.timerLabel:setString(self.battleModel:getTimerLeftStr())
    end
end

-- 注册事件监听接口
function BattleController:addEventListener(name, callback)
    local listener = cc.EventListenerCustom:create(name, callback)
    self.dispatcher:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

-- 分发事件
function BattleController:dispatchEvent(eventName, data)
    local event = cc.EventCustom:new(eventName)
    event.data = data
    CCLog("dispatchEvent(" .. eventName ..")")
    self.dispatcher:dispatchEvent(event)
end

function BattleController:onHeroStateChange(name, data)
    local new = data.new

    local old = data.old
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = self:getFighterView(fighterID)
    if heroView and not tolua.isnull(heroView) then
        heroView:stateChanged(old, new)
    end

    self:updateControlPanel()
end

function BattleController:onHeroCellChanged(name, data)
    -- local fighterID = data.fighterID
    -- local heroModel = FighterModel.getFighter(fighterID)
    -- local heroView = self:getFighterView(fighterID)
    -- heroView:setLabel(json.encode(data.new))

    self:updateZOrder()
end

function BattleController:onWait(name, data)
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local heroView = self:getFighterView(fighterID)
    heroView:ready()
end

function BattleController:onMatch(name, data)
    -- 回放使用
end

function BattleController:onRegionRageSkillDrop(name, data)
    -- 回放使用
end

function BattleController:onRegionRageSkillCancel(name, data)
    -- 回放使用
end

function BattleController:onMoveBy(name, data)
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local offset = data.offset
    local useTime = data.useTime

    CCLog("on event:", vardump({name = name, offset = offset, hero = heroModel:getHeroID(), side = heroModel:getTeamSide() }))

    local heroView = self:getFighterView(fighterID)
    heroView:moveBy(offset, useTime, self.battleModel)
end

function BattleController:onAttackScopeChange(name, data)
    --self:drawAttackScope()
end

-- 多段攻击事件
function BattleController:onSubHitEvent(attackData)
    CCLog("BattleController:onSubHitEvent(attackData)")
    local attacker = attackData.attacker
    local skillData = attackData.skillData
    local heroID = nil
    local skillID = skillData.id

    if attacker:getFighterType() == "hero" then
        heroID = attacker:getHeroID()
    end

    if not BattleConfig.heroSkillIsBulletAttack(heroID, skillID) then
        if skillData.durationType == enums.SkillDurationMode.Instant and
                skillData.affect == enums.SkillAffectType.Damage and
                skillData.type == enums.SkillType.RageSkill
        then
            local targetHeroList = attackData:getTargetFighterList()
            local skillID = attackData.skillData.id

            CCLog(attackData.skillData.name, "目标数:", #targetHeroList)

            for _, heroModel in ipairs(targetHeroList) do
                local view = self:getFighterView(heroModel:getFighterID())
                if view and not tolua.isnull(view) then
                   view:playHitAnimation(skillID)
                   CCLog(attackData.attacker:getName(), "sub hit:", heroModel:getName())
                end
            end
        end
    end
end

function BattleController:playRageEffectHeroMoveToTarget(attackData)
    local heroModel = attackData:getHeroModel()
    local heroView = self:getFighterView(heroModel:getFighterID())
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local destCell = attackData:getDestCell()
    local pos = cc.p(heroView:getPosition())
    local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
    local moveOffset = cc.pSub(destPos, pos)
    local rageAttackAniConfig = BattleConfig.getRageAniConfig(heroID)
    local delay = rageAttackAniConfig.delay

    CCLog(vardump({destCell = destCell, pos = pos, destPos = destPos, moveOffset = moveOffset}, "BattleController:playRageEffectHeroMoveToTarget"))
    -- 1027 猪八戒
    heroView:runAction(cc.Sequence:create({
        cc.DelayTime:create(delay),
        cc.MoveBy:create(0.2, moveOffset),
        cc.DelayTime:create(0.65),
        cc.Place:create(pos),
    }))
end

function BattleController:playRageEffectOnHero(attackData)
    local heroModel = attackData:getHeroModel()
    local heroView = self:getFighterView(heroModel:getFighterID())
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()
    local rageAttackAniConfig = BattleConfig.getRageAniConfig(heroID)
    local delay = rageAttackAniConfig.delay
    local offset = rageAttackAniConfig.offset

    local srcCell = heroModel:getCell()
    local srcPos = BattleConfig.getCellPos(srcCell.x, srcCell.y)
    local direction = heroModel:getDirection()

    local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni == nil then
        path = string.format("image/spine/skill_effect/skill/%d/", skillID)
        skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    end
    if skillAni then
        if direction == "left" then
            skillAni:setRotationSkewY(180)
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        else
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        end
        
        skillAni:setPosition(_PPOS(cc.pAdd(srcPos, direction == "right" and offset or cc.p(-offset.x, offset.y) )))
        skillAni:setLocalZOrder(BattleUtils.getCellZOrder(srcPos, direction) + 1)
        skillAni:setGlobalZOrder(101)

        self.battleNode:addChild(skillAni)
        skillAni:setVisible(false)
        skillAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)

        skillAni:registerSpineEventHandler(function(event)
            self:onSubHitEvent(attackData)
        end, sp.EventType.ANIMATION_EVENT)
    else
        local destCell = attackData:getDestCell()
        local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
        local direction = heroModel:getDirection()

        local topAni = load_animation(string.format("image/spine/skill_effect/skill/%d_%d/top/", heroID, skillID), 1, BattleConfig.SPEED_RATIO)
        if topAni == nil then
            topAni = load_animation(string.format("image/spine/skill_effect/skill/%d/top/", skillID), 1, BattleConfig.SPEED_RATIO)
        end
        if topAni then

            if direction == "left" then
                topAni:setRotationSkewY(180)
                topAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            else
                topAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            end


            topAni:setPosition(_PPOS(cc.pAdd(destPos, direction == "right" and offset or cc.p(-offset.x, offset.y))))
            CCLog(vardump({destPos, {topAni:getPosition()}}, "ani pos"))
            topAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
            topAni:setGlobalZOrder(101)
            self.battleNode:addChild(topAni)
            topAni:setVisible(false)


            topAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(delay),
                cc.Show:create(),
                cc.CallFunc:create(function()
                    topAni:setAnimation(0, "animation", false)
                end),
            }))
    
            topAni:registerSpineEventHandler(function(event)
                topAni:setVisible(false)
                topAni:runAction(cc.Sequence:create({
                    cc.DelayTime:create(0.01),
                    cc.RemoveSelf:create(),
                }))
            end, sp.EventType.ANIMATION_END)
    
            topAni:registerSpineEventHandler(function(event)
                self:onSubHitEvent(attackData)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end, sp.EventType.ANIMATION_EVENT)
        end

        local bottomAni = load_animation(string.format("image/spine/skill_effect/skill/%d_%d/bottom/", heroID, skillID), 1, BattleConfig.SPEED_RATIO)
        if bottomAni == nil then
            bottomAni = load_animation(string.format("image/spine/skill_effect/skill/%d/bottom/", skillID), 1, BattleConfig.SPEED_RATIO)
        end
        if bottomAni then

            if direction == "left" then
                bottomAni:setRotationSkewY(180)
                bottomAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            else
                bottomAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            end

            bottomAni:setPosition(_PPOS(cc.pAdd(destPos, direction == "right" and offset or cc.p(-offset.x, offset.y))))
            CCLog(vardump({destPos, {bottomAni:getPosition()}}, "ani pos"))
            -- bottomAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) - 1)
            -- bottomAni:setGlobalZOrder(100)
            self.battleNode:addChild(bottomAni)
            bottomAni:setVisible(false)

            bottomAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(delay),
                cc.Show:create(),
                cc.CallFunc:create(function()
                    bottomAni:setAnimation(0, "animation", false)
                end),
            }))
    
            bottomAni:registerSpineEventHandler(function(event)
                bottomAni:setVisible(false)
                bottomAni:runAction(cc.Sequence:create({
                    cc.DelayTime:create(0.01),
                    cc.RemoveSelf:create(),
                }))
            end, sp.EventType.ANIMATION_END)
    
            bottomAni:registerSpineEventHandler(function(event)
                self:onSubHitEvent(attackData)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end, sp.EventType.ANIMATION_EVENT)
        end
    end
end

function BattleController:playRageEffectOnHeroAndMove(attackData)
    local heroModel = attackData:getHeroModel()
    local heroView = self:getFighterView(heroModel:getFighterID())
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()
    local rageAttackAniConfig = BattleConfig.getRageAniConfig(heroID)
    local delay = rageAttackAniConfig.delay
    local offset = rageAttackAniConfig.offset
    local moveTime = rageAttackAniConfig.moveTime

    local srcCell = heroModel:getCell()
    local srcPos = BattleConfig.getCellPos(srcCell.x, srcCell.y)
    local direction = heroModel:getDirection()

    local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni == nil then
        path = string.format("image/spine/skill_effect/skill/%d/", skillID)
        skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    end
    if skillAni then
        if direction == "left" then
            skillAni:setRotationSkewY(180)
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        else
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        end

        local moveOffset = cc.p(960, 0)
        if direction == "left" then
            moveOffset = cc.p(-960, 0)
        end
        skillAni:setPosition(_PPOS(cc.pAdd(srcPos, direction == "right" and offset or cc.p(-offset.x, offset.y) )))
        skillAni:setLocalZOrder(BattleUtils.getCellZOrder(srcPos, direction) + 1)
        skillAni:setGlobalZOrder(101)
        self.battleNode:addChild(skillAni)
        skillAni:setVisible(false)
        skillAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end),
            cc.MoveBy:create(moveTime, moveOffset),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)

        skillAni:registerSpineEventHandler(function(event)
            self:onSubHitEvent(attackData)
        end, sp.EventType.ANIMATION_EVENT)
    else
        CCLog("error: animation", path, "not found")
    end
end

function BattleController:playRageEffectOnTarget(attackData)
    local heroModel = attackData:getHeroModel()
    local heroView = self:getFighterView(heroModel:getFighterID())
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()
    local rageAttackAniConfig = BattleConfig.getRageAniConfig(heroID)
    local delay = rageAttackAniConfig.delay
    local offset = rageAttackAniConfig.offset

    local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni == nil then
        path = string.format("image/spine/skill_effect/skill/%d/", skillID)
        skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    end
    if skillAni then
        local destCell = attackData:getDestCell()
        local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
        local direction = heroModel:getDirection()

        if direction == "left" then
            skillAni:setRotationSkewY(180)
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        else
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        end

        skillAni:setPosition(_PPOS(cc.pAdd(destPos, direction == "right" and offset or cc.p(-offset.x, offset.y))))
        CCLog(vardump({destPos, {skillAni:getPosition()}}, "ani pos"))
        skillAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
        skillAni:setGlobalZOrder(101)
        self.battleNode:addChild(skillAni)
        skillAni:setVisible(false)

        skillAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
            end),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)

        skillAni:registerSpineEventHandler(function(event)
            self:onSubHitEvent(attackData)
            if rageAttackAniConfig.shake then
                self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
            end
        end, sp.EventType.ANIMATION_EVENT)
    else
        -- CCLog("error: animation", path, "not found")
        local destCell = attackData:getDestCell()
        local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
        local direction = heroModel:getDirection()

        local topAni = load_animation(string.format("image/spine/skill_effect/skill/%d_%d/top/", heroID, skillID), 1, BattleConfig.SPEED_RATIO)
        if topAni == nil then
            topAni = load_animation(string.format("image/spine/skill_effect/skill/%d/top/", skillID), 1, BattleConfig.SPEED_RATIO)
        end
        if topAni then

            if direction == "left" then
                topAni:setRotationSkewY(180)
                topAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            else
                topAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            end


            topAni:setPosition(_PPOS(cc.pAdd(destPos, direction == "right" and offset or cc.p(-offset.x, offset.y))))
            CCLog(vardump({destPos, {topAni:getPosition()}}, "ani pos"))
            topAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
            topAni:setGlobalZOrder(101)
            self.battleNode:addChild(topAni)
            topAni:setVisible(false)


            topAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(delay),
                cc.Show:create(),
                cc.CallFunc:create(function()
                    topAni:setAnimation(0, "animation", false)
                end),
            }))
    
            topAni:registerSpineEventHandler(function(event)
                topAni:setVisible(false)
                topAni:runAction(cc.Sequence:create({
                    cc.DelayTime:create(0.01),
                    cc.RemoveSelf:create(),
                }))
            end, sp.EventType.ANIMATION_END)
    
            topAni:registerSpineEventHandler(function(event)
                self:onSubHitEvent(attackData)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end, sp.EventType.ANIMATION_EVENT)
        end

        local bottomAni = load_animation(string.format("image/spine/skill_effect/skill/%d_%d/bottom/", heroID, skillID), 1, BattleConfig.SPEED_RATIO)
        if bottomAni == nil then
            bottomAni = load_animation(string.format("image/spine/skill_effect/skill/%d/bottom/", skillID), 1, BattleConfig.SPEED_RATIO)
        end
        if bottomAni then

            if direction == "left" then
                bottomAni:setRotationSkewY(180)
                bottomAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            else
                bottomAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            end

            bottomAni:setPosition(_PPOS(cc.pAdd(destPos, direction == "right" and offset or cc.p(-offset.x, offset.y))))
            CCLog(vardump({destPos, {bottomAni:getPosition()}}, "ani pos"))
            -- bottomAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) - 1)
            -- bottomAni:setGlobalZOrder(100)
            self.battleNode:addChild(bottomAni)
            bottomAni:setVisible(false)

            bottomAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(delay),
                cc.Show:create(),
                cc.CallFunc:create(function()
                    bottomAni:setAnimation(0, "animation", false)
                end),
            }))
    
            bottomAni:registerSpineEventHandler(function(event)
                bottomAni:setVisible(false)
                bottomAni:runAction(cc.Sequence:create({
                    cc.DelayTime:create(0.01),
                    cc.RemoveSelf:create(),
                }))
            end, sp.EventType.ANIMATION_END)
    
            bottomAni:registerSpineEventHandler(function(event)
                self:onSubHitEvent(attackData)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end, sp.EventType.ANIMATION_EVENT)
        end

    end
end

function BattleController:playRageEffectOnTargetAndMove(attackData)
    local heroModel = attackData:getHeroModel()
    local heroView = self:getFighterView(heroModel:getFighterID())
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()
    local rageAttackAniConfig = BattleConfig.getRageAniConfig(heroID)
    local delay = rageAttackAniConfig.delay
    local offset = rageAttackAniConfig.offset
    local moveTime = rageAttackAniConfig.moveTime

    local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni == nil then
        path = string.format("image/spine/skill_effect/skill/%d/", skillID)
        skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    end
    if skillAni then
        local pos = cc.p(heroView:getPosition())
        local destCell = attackData:getDestCell()
        local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
        local direction = heroModel:getDirection()
        local moveOffset = cc.p(960, 0)
        if direction == "left" then
            moveOffset = cc.p(-960, 0)
        end

        if direction == "left" then
            skillAni:setRotationSkewY(180)
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        else
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        end

        skillAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
        skillAni:setGlobalZOrder(101)
        skillAni:setVisible(false)
        self.battleNode:addChild(skillAni)
        skillAni:setPosition(_PPOS(cc.p(pos.x, destPos.y)))
        skillAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
            end),
            cc.MoveBy:create(moveTime, moveOffset),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)

        skillAni:registerSpineEventHandler(function(event)
            self:onSubHitEvent(attackData)
        end, sp.EventType.ANIMATION_EVENT)
    else
        CCLog("error: animation", path, "not found")
    end
end

function BattleController:playRageEffectOnCenter(attackData)
    local heroModel = attackData:getHeroModel()
    local heroView = self:getFighterView(heroModel:getFighterID())
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()
    local rageAttackAniConfig = BattleConfig.getRageAniConfig(heroID)
    local delay = rageAttackAniConfig.delay
    local offset = rageAttackAniConfig.offset

    local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni == nil then
        path = string.format("image/spine/skill_effect/skill/%d/", skillID)
        skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    end

    if skillAni then
        local destCell = attackData:getDestCell()
        local destPos = BattleConfig.getCellPos(10, 5)
        local direction = heroModel:getDirection()

        if direction == "left" then
            skillAni:setRotationSkewY(180)
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        else
            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        end

        skillAni:setPosition(_PPOS(destPos))
        skillAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
        skillAni:setGlobalZOrder(101)
        self.battleNode:addChild(skillAni)
        skillAni:setVisible(false)
        skillAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
                if rageAttackAniConfig.shake then
                    self:shake(rageAttackAniConfig.shake_time, rageAttackAniConfig.shake_strength)
                end
            end),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)

        skillAni:registerSpineEventHandler(function(event)
            self:onSubHitEvent(attackData)
        end, sp.EventType.ANIMATION_EVENT)
    else
        CCLog("error: animation", path, "not found")
    end
end

function BattleController:onRageAttackBegin(attackData)
    local heroModel = attackData:getHeroModel()
    local heroID = heroModel:getHeroID()
    local rageAniType = BattleConfig.getRageAniType(heroID)

    local handlerFuncMap = {
        -- 英雄移动到目标位置
        HeroMove = BattleController.playRageEffectHeroMoveToTarget,
        -- 在英雄上直接播放特效
        HeroEffect = BattleController.playRageEffectOnHero,
        -- 在英雄上播放特效，并向远方移动
        HeroEffectMove = BattleController.playRageEffectOnHeroAndMove,
        -- 直接在目标位置播放特效
        TargetEffect = BattleController.playRageEffectOnTarget,
        -- 在目标位置播放特效并向远方移动
        TargetEffectMove = BattleController.playRageEffectOnTargetAndMove,
        -- 在屏幕中心播放特效
        Center = BattleController.playRageEffectOnCenter,
    }
    local handlerFunc = assert(handlerFuncMap[rageAniType], rageAniType)


    local heroView = self:getFighterView(heroModel:getFighterID())
    local teamSide = heroModel:getTeamSide()
    local team = self.battleModel:getTeam(teamSide)

    --        if teamSide == "left" then
    --            local heroControls = self.heroControlsMap[heroModel]
    --            local rageButton = heroControls.rageButton
    --            local rageClick = assert(rageButton:getChildByName("rageClick"), "rageClick sprite not exists")
    --            rageClick:setAnimation(0, "dianji", false)
    --            rageClick:setVisible(true)
    --        end

    if not attackData.isComboHit then
        local skillData = attackData:getSkillData()
        team:onRageSkill(heroModel, skillData)
        self:rageAttackHint(attackData)

        self:rageAttackBegin(heroView, attackData.isComboHit)
        heroView:attackBegin(attackData, handler(self, self.rageAttackEnd, heroModel), self.battleModel)

        handlerFunc(self, attackData)
    else
        heroView:attackBegin(attackData, function()  end, self.battleModel)
        handlerFunc(self, attackData)
    end
end

--function BattleController:__onRageAttackBegin(attackData)
--    local heroModel = attackData:getHeroModel()
--    local skillID = attackData:getSkillID()
--    local skillLevel = attackData:getSkillLevel()
--    local skillData = attackData:getSkillData()
--
--    local Conditions = BattleHelper.Conditions
--
--    local heroView = self:getFighterView(heroModel:getFighterID())
--    local teamSide = heroModel:getTeamSide()
--    local team = self.battleModel:getTeam(teamSide)
--
--    --        if teamSide == "left" then
--    --            local heroControls = self.heroControlsMap[heroModel]
--    --            local rageButton = heroControls.rageButton
--    --            local rageClick = assert(rageButton:getChildByName("rageClick"), "rageClick sprite not exists")
--    --            rageClick:setAnimation(0, "dianji", false)
--    --            rageClick:setVisible(true)
--    --        end
--
--    if not attackData.isComboHit then
--        team:onRageSkill(heroModel, skillData)
--        self:rageAttackHint(attackData)
--    end
--
--    self:rageAttackBegin(heroView)
--    heroView:attackBegin(attackData, handler(self, self.rageAttackEnd), self.battleModel)
--
--    local heroID = heroModel:getHeroID()
--    if heroID == 1027 then
--        -- 动作描述：移动到目标位置，并瞬间返回
--
--        -- 猪八戒
--        local delayMap = {
--            [1027] = 0.8,
--        }
--        local delay = delayMap[heroID]
--
--        local destCell = attackData:getDestCell()
--        local pos = cc.p(heroView:getPosition())
--        local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
--        local moveOffset = cc.pSub(destPos, pos)
--        heroView:runAction(cc.Sequence:create({
--            cc.DelayTime:create(delay),
--            cc.MoveBy:create(0.6, moveOffset),
--            cc.Place:create(pos),
--        }))
--    elseif heroID == 1046 or heroID == 1044  then
--        local delayMap = {
--            [1046] = 0.2, -- 红孩儿
--            [1044] = 0.8, -- 小青
--        }
--        local delay = delayMap[heroID]
--
--        local posOffset = {
--            [1046] = { ["right"] = cc.p(30, 90), ["left"] = cc.p(-30, 90) },
--            [1044] = { ["right"] = cc.p(30, 90), ["left"] = cc.p(-30, 90) }
--        }
--        -- 紫霞
--        local srcCell = heroModel:getCell()
--        local srcPos = BattleConfig.getCellPos(srcCell.x, srcCell.y)
--        local direction = heroModel:getDirection()
--
--        local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
--        local skillAni = assert(load_animation(path, 1), "load skill animation")
--        if direction == "left" then
--            skillAni:setRotationSkewY(180)
--        end
--        skillAni:setPosition(cc.pAdd(srcPos, posOffset[heroID][direction]))
--        skillAni:setLocalZOrder(BattleUtils.getCellZOrder(srcPos, direction) + 1)
--        skillAni:setGlobalZOrder(101)
--        skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
--        self.battleNode:addChild(skillAni)
--        skillAni:setVisible(false)
--        skillAni:runAction(cc.Sequence:create({
--            cc.DelayTime:create(delay),
--            cc.Show:create(),
--            cc.CallFunc:create(function()
--                skillAni:setAnimation(0, "animation", false)
--                if heroID == 1016 then
--                    self:shake()
--                end
--            end),
--        }))
--
--        skillAni:registerSpineEventHandler(function(event)
--            if event.type == "end" then
--                skillAni:setVisible(false)
--                skillAni:runAction(cc.Sequence:create({
--                    cc.DelayTime:create(0.01),
--                    cc.RemoveSelf:create(),
--                }))
--            end
--        end)
--    elseif heroID == 1033 or heroID == 1016 or heroID == 1046 or heroID == 1020 or heroID == 1006 or heroID == 1010 or heroID == 1014 or heroID == 1051 or heroID == 1013 then
--        -- 动作描述：
--
--        local delayMap = {
--            [1033] = 0.4, -- 紫霞仙子
--            [1016] = 0.8, -- 牛魔王
--            [1046] = 0.8, -- 红孩儿
--            [1020] = 0.5, -- 白蛇
--            [1006] = 0.5, -- 女娲
--            [1010] = 0.3, -- 菩提
--            [1014] = 0.3, -- 大鹏
--            [1051] = 0.3, -- 地涌夫人
--            [1013] = 0.3, -- 地涌夫人
--        }
--        local delay = delayMap[heroID] or 0
--
--        -- 紫霞
--        local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
--        local skillAni = load_animation(path)
--        if skillAni then
--            local destCell = attackData:getDestCell()
--            local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
--            local direction = heroModel:getDirection()
--
--            if direction == "left" then
--                skillAni:setRotationSkewY(180)
--            end
--            skillAni:setPosition(destPos)
--            skillAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
--            skillAni:setGlobalZOrder(101)
--            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
--            self.battleNode:addChild(skillAni)
--            skillAni:setPosition(destPos)
--            skillAni:setVisible(false)
--            skillAni:runAction(cc.Sequence:create({
--                cc.DelayTime:create(delay),
--                cc.Show:create(),
--                cc.CallFunc:create(function()
--                    skillAni:setAnimation(0, "animation", false)
--                    if heroID == 1016 then
--                        self:shake()
--                    end
--                end),
--            }))
--
--            skillAni:registerSpineEventHandler(function(event)
--                if event.type == "end" then
--                    skillAni:setVisible(false)
--                    skillAni:runAction(cc.Sequence:create({
--                        cc.DelayTime:create(0.01),
--                        cc.RemoveSelf:create(),
--                    }))
--                end
--            end)
--        else
--            CCLog("error: animation", path, "not found")
--        end
--    elseif heroID == 1042 or heroID == 1039 then
--        local delayMap = {
--            [1042] = 1.6, -- 铁扇公主
--            [1039] = 0.9, -- 哪吒
--        }
--        local delay = delayMap[heroID]
--
--        local moveTimeMap = {
--            [1042] = 0.5,
--            [1039] = 0.6,
--        }
--        local moveTime = moveTimeMap[heroID]
--
--        -- 铁扇公主
--        local path = string.format("image/spine/skill_effect/skill/%d_%d/", heroID, skillID)
--        local skillAni = load_animation(path)
--        if skillAni then
--            local pos = cc.p(heroView:getPosition())
--            local destCell = attackData:getDestCell()
--            local destPos = BattleConfig.getCellPos(destCell.x, destCell.y)
--            local direction = heroModel:getDirection()
--            local moveOffset = cc.p(960, 0)
--            if direction == "left" then
--                local moveOffset = cc.p(-960, 0)
--            end
--
--            if direction == "left" then
--                skillAni:setRotationSkewY(180)
--            end
--            skillAni:setLocalZOrder(BattleUtils.getCellZOrder(destCell, direction) + 1)
--            skillAni:setGlobalZOrder(101)
--            skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
--            skillAni:setVisible(false)
--            self.battleNode:addChild(skillAni)
--            skillAni:setPosition(cc.p(pos.x, destPos.y))
--            skillAni:runAction(cc.Sequence:create({
--                cc.DelayTime:create(delay),
--                cc.Show:create(),
--                cc.CallFunc:create(function()
--                    skillAni:setAnimation(0, "animation", false)
--                end),
--                cc.MoveBy:create(moveTime, moveOffset),
--            }))
--
--            skillAni:registerSpineEventHandler(function(event)
--                if event.type == "end" then
--                    skillAni:setVisible(false)
--                    skillAni:runAction(cc.Sequence:create({
--                        cc.DelayTime:create(0.01),
--                        cc.RemoveSelf:create(),
--                    }))
--                end
--            end)
--        else
--            CCLog("error: animation", path, "not found")
--        end
--    end
--end

function BattleController:onAttackBegin(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

    local heroModel = attackData:getHeroModel()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local Conditions = BattleHelper.Conditions

    local heroView = self:getFighterView(heroModel:getFighterID())
    if Conditions.Skill.Type.isRageSkill(attackData) then
        table.insert(self.rageAttackDataList, attackData)

        self:clearRegionRageSkill()
    else
        if heroView and not tolua.isnull(heroView) then
            heroView:attackBegin(attackData)
        end
    end

    self:updateControlPanel()
end

function BattleController:doAttack(attackData)
    self.battleModel:onAttack(attackData)
    self:updateControlPanel()
end

function BattleController:onAttackComplete(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)
    local attackerType = attackData:getAttackerType()

    if attackerType == "hero" then
        self:onHeroAttackComplete(name, data)
    elseif attackerType == "instance" then
        self:onInstanceAttackComplete(name, data)
    elseif attackerType == "trap" then
        self:onTrapAttackComplete(name, data)
    elseif attackerType == "fairy" then
        self:onFairyAttackComplete(name, data)
    elseif attackerType == "obstacle" then
        self:onObstacleAttackComplete(name, data)
    elseif attackerType == "turret" then
        self:onTurretAttackComplete(name, data)
    elseif attackerType == "hatredTarget" then
        self:onHatredTargetAttackComplete(name, data)
    else
        CCLog("未处理的攻击者类型:", attackerType)
    end
end

function BattleController:onAttackEnd(name, data)

end

function BattleController:createBullet(heroRes, skillID)
    --local normAttackImg = BattleConfig.getAttackImg(heroRes, skillID)
    local normAttackImg = BattleConfig.getAttackImgName(heroRes, skillID)

    if normAttackImg then
        local aniNode = cc.Sprite:createWithSpriteFrameName(normAttackImg)
        return aniNode
    else
        local aniPath = BattleConfig.getAttackAniPath(heroRes, skillID)
        local aniNode = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
        aniNode:setAnimation(0, "animation", true)
        return aniNode
    end
end

function BattleController:onHeroAttackComplete(name, data)
    CCLog("onHeroAttackComplete")
    local attackData = AttackDataModel.decode(data, self.battleModel)

    local heroModel = attackData:getHeroModel()
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView == nil or tolua.isnull(heroView) then
        if heroModel:isAlive() then
            CCLog("error: 英雄没有死，却没有HeroView")
        end
    end

    local skillMoveTime = 0.0
    local skillID = attackData.skillData.id

    CCLog(heroModel:getName(), skillID)
    if BattleConfig.heroSkillIsBulletAttack(heroID, skillID) then
        local dstCell = attackData:getDestCell()
        local enemyView = nil

        local enemyModel = attackData:getOriginTargetFighter()
        if enemyModel ~= nil then
            dstCell = enemyModel:getCell()
            if enemyModel:getFighterType() == "obstacle" then
                local cell = heroModel:getCell()
                dstCell.y = cell.y
            end

            enemyView = self:getFighterView(enemyModel:getFighterID())
        end

        skillMoveTime = self:playBulletTrajectory(heroModel, skillID, dstCell, enemyView)

        CCLog("技能为子弹攻击", heroModel:getName(), skillID)
    else
        CCLog("技能为非子弹攻击", heroModel:getName(), skillID)
    end

    -- 远程普攻
--    if skillID == 1002 or skillID == 1003 then
--        local aniNode = self:createBullet(heroModel:getHeroID(), skillID)
--
--        aniNode:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
--        self.battleNode:addChild(aniNode)
--        aniNode:setVisible(false)
--
--        local heroModel = attackData:getHeroModel()
--
--        local offset = heroModel:getDirection() == "right" and 50 or -50
--
--        local cell = heroModel:getCell()
--        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
--        pos = cc.pAdd(pos, cc.p(offset, 80))
--
--        aniNode:setPosition(pos)

--        local dstCell = attackData:getDestCell()
--        local enemyView = nil
--
--        local obstacleModel = heroModel:getMatchedObstacle()
--        if obstacleModel ~= nil then
--            dstCell = obstacleModel:getCell()
--            local cell = heroModel:getCell()
--            dstCell.y = cell.y
--
--            enemyView = self:getFighterView(obstacleModel:getFighterID())
--        else
--            local enemyModel = attackData:getOriginTargetFighter()
--            if enemyModel == nil then
--                CCLog("普攻没有切配对的敌人，已经被打死了？")
--                return
--            end
--            local dstCell = enemyModel:getCell()
--
--            enemyView = self:getFighterView(enemyModel:getFighterID())
--        end

--        if obstacleModel ~= nil then
--            local dstCell = obstacleModel:getCell()
--            local obstacleView = self:getFighterView(obstacleModel:getFighterID())
--            dstCell.y = cell.y
--
--            aniNode:setLocalZOrder(obstacleView:getLocalZOrder() + 1)
--
--            local dstPos = BattleConfig.getHeroCellPos(dstCell.x, dstCell.y)
--            dstPos = cc.pAdd(dstPos, cc.p(0, 80))
--            local distance = cc.pGetDistance(cell, dstCell)
--            local diff = cc.pSub(dstPos, pos)
--            local angle = math.deg(math.atan2(diff.y, diff.x))
--            CCLog(vardump({angle = angle, pos = pos, dstPos = dstPos}, "angle"))
--            aniNode:setRotation(-angle)
--            skillMoveTime = distance / fireBallSpeed
--            --CCLog(vardump({skillMoveTime = skillMoveTime, cell = cell, dstCell = dstCell, distance = distance, fireBallSpeed = fireBallSpeed}, "attack speed"))
--
--            table.insert(self.bulletList, aniNode)
--
--            aniNode:runAction(cc.Sequence:create({
--                cc.Show:create(),
--                cc.MoveTo:create(skillMoveTime, dstPos),
--                cc.CallFunc:create(function()
--                    table.removeItem(self.bulletList, aniNode)
--                end),
--                cc.RemoveSelf:create(),
--            }))
--        else
--            local enemyModel = attackData:getOriginTargetFighter()
--            if enemyModel == nil then
--                CCLog("普攻没有切配对的敌人，已经被打死了？")
--                return
--            end
--
--            local enemyView = self:getFighterView(enemyModel:getFighterID())
--            if enemyView then
--                aniNode:setLocalZOrder(enemyView:getLocalZOrder() + 1)
--            end
--
--            local dstCell = enemyModel:getCell()
--            local dstPos = BattleConfig.getHeroCellPos(dstCell.x, dstCell.y)
--            dstPos = cc.pAdd(dstPos, cc.p(0, 80))
--            local distance = cc.pGetDistance(cell, dstCell)
--            local diff = cc.pSub(dstPos, pos)
--            local angle = math.deg(math.atan2(diff.y, diff.x))
--            CCLog(vardump({angle = angle, pos = pos, dstPos = dstPos}, "angle"))
--            aniNode:setRotation(-angle)
--            skillMoveTime = distance / fireBallSpeed
--            --CCLog(vardump({skillMoveTime = skillMoveTime, cell = cell, dstCell = dstCell, distance = distance, fireBallSpeed = fireBallSpeed}, "attack speed"))
--            table.insert(self.bulletList, aniNode)
--            aniNode:runAction(cc.Sequence:create({
--                cc.Show:create(),
--                cc.MoveTo:create(skillMoveTime, dstPos),
--                cc.CallFunc:create(function()
--                    table.removeItem(self.bulletList, aniNode)
--                end),
--                cc.RemoveSelf:create(),
--            }))
--        end
--
--        skillMoveTime = self:playBulletTrajectory(heroModel, skillID, dstCell, enemyView)
--    elseif skillID == 1210 then
--        local dstCell = attackData:getDestCell()
--        skillMoveTime = self:playBulletTrajectory(heroModel, skillID, dstCell, nil)
--
--        local aniNode = self:createBullet(heroModel:getHeroID(), skillID)
--
--        aniNode:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
--        self.battleNode:addChild(aniNode)
--        aniNode:setVisible(false)
--
--        local heroModel = attackData:getHeroModel()
--
--        local offset = heroModel:getDirection() == "right" and 50 or -50
--
--        local cell = heroModel:getCell()
--        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
--        pos = cc.pAdd(pos, cc.p(offset, 80))
--
--        aniNode:setPosition(pos)
--        local dstCell = attackData:getDestCell()
--        local dstPos = BattleConfig.getHeroCellPos(dstCell.x, dstCell.y)
--        dstPos = cc.pAdd(dstPos, cc.p(0, 80))
--        local distance = cc.pGetDistance(cell, dstCell)
--        local diff = cc.pSub(dstPos, pos)
--        local angle = math.deg(math.atan2(diff.y, diff.x))
--        CCLog(vardump({angle = angle, pos = pos, dstPos = dstPos}, "angle"))
--        aniNode:setRotation(-angle)
--        skillMoveTime = distance / fireBallSpeed
--        --CCLog(vardump({skillMoveTime = skillMoveTime, cell = cell, dstCell = dstCell, distance = distance, fireBallSpeed = fireBallSpeed}, "attack speed"))
--        table.insert(self.bulletList, aniNode)
--        aniNode:runAction(cc.Sequence:create({
--            cc.Show:create(),
--            cc.MoveTo:create(skillMoveTime, dstPos),
--            cc.CallFunc:create(function()
--                table.removeItem(self.bulletList, aniNode)
--            end),
--            cc.RemoveSelf:create(),
--        }))
--    end

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(skillMoveTime),
        cc.CallFunc:create(handler(self, self.doAttack, attackData)),
    }))

    -- if skillData.consumeHP ~= nil and skillData.consumeHP > 0 then
    --     local fullHP = heroModel:getFullHP()
    --     local HP = math.floor(fullHP * skillData.consumeHP / 10000)
    --     heroModel:decHP(HP)
    -- end

    -- 大范围受击特效
    local cell = attackData:getDestCell()
    local pos = cc.p(BattleConfig.getCellPos(cell.x, cell.y))
    self:playScopeHitEffect(skillID, pos)

    if skillID == 5009 then
        self:shake(0.5, 20)
        --heroView:playAttackAnimation(skillID)
        self:playRageEffectOnHero(attackData)
    end
end

-- 显示子弹轨迹
function BattleController:playBulletTrajectory(fighter, skillID, dstCell, enemyView)
    local fighterView = self:getFighterView(fighter:getFighterID())
    local skillMoveTime = 0
    local bullet = self:createBullet(fighter:getHeroRes(), skillID)

    bullet:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.battleNode:addChild(bullet)
    bullet:setVisible(false)
    if enemyView and not tolua.isnull(enemyView) then
        bullet:setLocalZOrder(enemyView:getLocalZOrder() + 1)
    else
        bullet:setLocalZOrder(bullet:getLocalZOrder() + 1)
    end
    
    local offset = fighter:getDirection() == "right" and 50 or -50

    local cell = fighter:getCell()
    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
    pos = cc.pAdd(pos, cc.p(offset, 80))

    bullet:setPosition(_PPOS(pos))
    local dstPos = BattleConfig.getHeroCellPos(dstCell.x, dstCell.y)
    dstPos = cc.pAdd(dstPos, cc.p(0, 80))
    local distance = cc.pGetDistance(cell, dstCell)
    local diff = cc.pSub(dstPos, pos)
    local angle = math.deg(math.atan2(diff.y, diff.x))
    CCLog(vardump({angle = angle, pos = pos, dstPos = dstPos}, "angle"))
    bullet:setRotation(-angle)
    skillMoveTime = distance * 1.0 / BattleConfig.FIREBALL_SPEED
    --CCLog(vardump({skillMoveTime = skillMoveTime, cell = cell, dstCell = dstCell, distance = distance, fireBallSpeed = fireBallSpeed}, "attack speed"))
    table.insert(self.bulletList, bullet)
    bullet:runAction(cc.Sequence:create({
        cc.Show:create(),
        cc.MoveTo:create(skillMoveTime, _PPOS(dstPos)),
        cc.CallFunc:create(function()
            table.removeItem(self.bulletList, bullet)
        end),
        cc.RemoveSelf:create(),
    }))

    return skillMoveTime
end

-- 显示抛物线子弹轨迹
function BattleController:playParabolaBulletTrajectory(fighter, skillID, dstCell, enemyView)
    local fighterView = self:getFighterView(fighter:getFighterID())
    local skillMoveTime = 0
    local bullet = load_animation("image/spine/skill_effect/bullet/0001/", 1, BattleConfig.SPEED_RATIO) --self:createBullet(fighter:getHeroID(), skillID)
    bullet:setAnimation(0, "animation", true)

    bullet:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.battleNode:addChild(bullet)
    bullet:setVisible(false)
    if enemyView and not tolua.isnull(enemyView) then
        bullet:setLocalZOrder(enemyView:getLocalZOrder() + 1)
    else
        bullet:setLocalZOrder(bullet:getLocalZOrder() + 1)
    end

    local offset = fighter:getDirection() == "right" and 50 or -50

    local cell = fighter:getCell()
    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
    pos = cc.pAdd(pos, cc.p(offset, 80))

    bullet:setPosition(_PPOS(pos))
    local dstPos = BattleConfig.getHeroCellPos(dstCell.x, dstCell.y)
    dstPos = cc.pAdd(dstPos, cc.p(0, 80))
    local distance = cc.pGetDistance(cell, dstCell)
--    local diff = cc.pSub(dstPos, pos)
--    local angle = math.deg(math.atan2(diff.y, diff.x))
--    CCLog(vardump({angle = angle, pos = pos, dstPos = dstPos}, "angle"))
    if pos.x > dstPos.x then
        bullet:setRotation(-360)
    end
    skillMoveTime = distance * 1.0 / BattleConfig.FIREBALL_SPEED * 2
    --CCLog(vardump({skillMoveTime = skillMoveTime, cell = cell, dstCell = dstCell, distance = distance}, "attack speed"))
    table.insert(self.bulletList, bullet)
    bullet:runAction(cc.Sequence:create({
        cc.Show:create(),
        cc.ParabolaTo:create(skillMoveTime, _PPOS(dstPos), distance * BattleConfig.CELL_HEIGHT * 0.3333),
        cc.CallFunc:create(function()
            table.removeItem(self.bulletList, bullet)
        end),
        cc.RemoveSelf:create(),
    }))

    return skillMoveTime
end

function BattleController:playScopeHitEffect(skillID, pos)
    local fileUtils = cc.FileUtils:getInstance()

    local pngPath = string.format("image/spine/skill_effect/scopehit/%d/bottom/floor.png", skillID)
    local skillBG = nil
    if fileUtils:isFileExist(pngPath) then
        skillBG = cc.Sprite:create(pngPath)
        skillBG:setPosition(_PPOS(pos))
        skillBG:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        self.battleNode:addChild(skillBG, -1)
    else
        skillBG = load_animation(string.format("image/spine/skill_effect/scopehit/%d/bottom/", skillID), 1, BattleConfig.SPEED_RATIO)
        if skillBG then
            skillBG:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            skillBG:setAnimation(0, "animation", true)
            self.battleNode:addChild(skillBG)
            skillBG:setPosition(_PPOS(pos))
        end
    end

    local skillAni = load_animation(string.format("image/spine/skill_effect/scopehit/%d/top/", skillID), 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
        skillAni:setAnimation(0, "animation", false)
        skillAni:setLocalZOrder(0)
        self.battleNode:addChild(skillAni)

        skillAni:setTimeScale(1)
        skillAni:setScale(1)
        skillAni:setPosition(_PPOS(pos))
        skillAni:setGlobalZOrder(101)
        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillBG:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(1),
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function()
                    if skillBG and tolua.isnull(skillBG) then
                        skillBG:removeFromParent()
                        skillBG = nil
                    end
                end),
            }))
        end, sp.EventType.ANIMATION_END)
    end
end

function BattleController:onInstanceAttackComplete(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

     local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local skillMoveTime = 0.0
    local fireBallSpeed = BattleConfig.FIREBALL_SPEED -- 远程轨迹速度 15个格子每秒

    local battleModel = self.battleModel

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(1),
        cc.CallFunc:create(handler(self, self.doAttack, attackData)),
    }))
end

function BattleController:onTrapAttackComplete(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(1),
        cc.CallFunc:create(handler(self, self.doAttack, attackData)),
    }))
end

function BattleController:onFairyAttackComplete(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

    local teamSide = attackData:getTeamSide()
    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    else
        team = self.battleModel.rightTeam
    end

    local fairyModel = team:getFairyModel()
    local fairyView = self:getFighterView(fairyModel:getFighterID())

    self:pauseBattle()
    self:fairySkillAction(
        attackData:getSkillID(), 
        fairyModel:getFairyID(), 
        function() 
            self:doAttack(attackData)
        end)

    if fairyView and not tolua.isnull(fairyView) then
        fairyView:skillReleased()
    end
end

function BattleController:onObstacleAttackComplete(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

    self:doAttack(attackData)
end

function BattleController:onTurretAttackComplete(name, data)
    CCLog("onTurretAttackComplete")
    local attackData = AttackDataModel.decode(data, self.battleModel)

    local turretModel = attackData.attacker
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local turretView = self:getFighterView(turretModel:getFighterID())
    if turretView == nil or tolua.isnull(turretView) then
        assert(not turretModel:isAlive(), "英雄没有死，却没有HeroView")
    end

    turretView:attack()

    local skillMoveTime = 0.0

    if skillData.type == enums.SkillType.NormAttack then
        local enemy = turretModel:getMatchedEnemy()
        local dstCell = enemy:getCell()
        local enemyView = self:getFighterView(enemy:getFighterID())

        skillMoveTime = self:playParabolaBulletTrajectory(turretModel, skillID, dstCell, enemyView)
    end

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(skillMoveTime),
        cc.CallFunc:create(handler(self, self.doAttack, attackData)),
    }))

end

function BattleController:onHatredTargetAttackComplete(name, data)
    CCLog("onHatredTargetAttackComplete")
    local attackData = AttackDataModel.decode(data, self.battleModel)

    self:doAttack(attackData)
end

function BattleController:onAttackInterval(name , data)
    -- TODO:
end

function BattleController:onAttackBreakOff(name , data)
    CCLog("on event:", vardump({name = name}))
    local quiet = data.quiet

    if not quiet then
        local attackData = AttackDataModel.decode(data.attackData, self.battleModel)

        local heroModel = attackData:getHeroModel()
        local skillID = attackData:getSkillID()
        local skillLevel = attackData:getSkillLevel()
        local skillData = attackData:getSkillData()

        local heroView = self:getFighterView(heroModel:getFighterID())
        if heroView and not tolua.isnull(heroView) then
            heroView:attackBreakOff(attackData)

            if skillData.type == enums.SkillType.RageSkill and self.inRageAttacking then
                self:rangeAttackEnd(attackData:getHeroModel())
            end
        end
    end
end

--function BattleController:calcSkillAffectValue(attackData, targetFighter)
--    -- TODO:
--    local skillData = attackData:getSkillData()
--    local formulaFunction = BaseConfig.FormulaFunc(skillData.formula)
--    local params = attackData:generateFormulaParams(targetFighter)
--    local affectValue = formulaFunction(params)
--
--    local formulaExpr = BaseConfig.FormulaContent(skillData.formula)
--    CCLog(vardump({expr = formulaExpr, params = params, result = affectValue}, "formula"))
--    return affectValue
--end

function BattleController:onHit(name , data)
    --CCLog(vardump(event.data, "BattleController:onHit"))

    local attackerID = data.attackerID
    local fighterID = data.fighterID
    local attacker = FighterModel.getFighter(attackerID)
    local fighter = FighterModel.getFighter(fighterID)
    local damage = data.damage
    local skillID = data.skillID
    local restraint = data.restraint
    local critical = data.critical

    if fighter:getFighterType() == "hero" then
        local skillData = assert(BaseConfig.GetHeroSkill(skillID, 1))
        local heroView = self:getFighterView(fighter:getFighterID())
        if heroView and not tolua.isnull(heroView) then
            if skillData.type == enums.SkillType.RageSkill then
                heroView:resumeBattle()
            end

            local bullet = false
            if attacker:getFighterType() == "hero" then
                local heroID = attacker:getHeroID()
                bullet = BattleConfig.heroSkillIsBulletAttack(heroID, skillID)
            end

            heroView:hit(damage, skillID, restraint, critical)
            -- TODO:问题多多
            -- if bullet  or (skillID == 1001 or skillID == 1002 or skillID == 1003)
            --         or (skillID == 1348) or (attacker:getFighterType() ~= "hero")
            -- then
            --     heroView:hit(damage, skillID, restraint, critical)
            -- else
            --     heroView:hpChange(-damage, restraint, critical)
            -- end

            if self.isCoinsMonster and fighter:getTeamSide() == "right" then
                self:updateDamageCoins()
                heroView:playDropCoin()
            end
        end

        fighter:onHit(attacker, skillID)
        self.battleModel:onHit(fighter, damage)
        self:updateControlPanel()

        if skillData.Cickflt > 1 then
            local direction = attacker:getDirection()
            local data = {fighterID = fighterID, value = skillData.Cickflt - 1, direction = direction}
            self:onKnockedback("Blow fly", data)
        end
    end

--    local fighterView = self:getFighterView(fighter:getFighterID())
--    if fighterView and not tolua.isnull(fighterView) then
--        self:showHPChange(fighterView, -damage, critical, restraint)
--    end
end

--function BattleController:showHPChange(fighterView, hp, critical, restraint)
--    local basePos = cc.p(fighterView:getPosition())
--    local parent = fighterView:getParent()
--    if parent then
--        local worldPos = parent:convertToWorldSpace(basePos)
--        local relPos = self.battleNode:convertToNodeSpace(worldPos)
--        basePos = relPos
--    end
--
--    local hintNode = cc.Node:create()
--    hintNode:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
--    hintNode:setCascadeOpacityEnabled(true)
--    hintNode:setLocalZOrder(fighterView:getLocalZOrder() + 1)
--
--    local height = math.max(27 * 1.5, 39, 28)
--    local width = 0
--    if critical then
--        hintNode:setContentSize(cc.size(360, 50 + 39))
--        hintNode:setAnchorPoint(cc.p(0.5, 0.5))
--        hintNode:setPosition(cc.pAdd(basePos, cc.p(0, 170)))
--
--        local sprite = cc.Sprite:create("res/image/ui/img/btn/btn_1059.png")
--        sprite:setPosition(cc.p(360 / 2, 65))
--        sprite:setAnchorPoint(cc.p(0.5, 0.5))
--        hintNode:addChild(sprite)
--
--        local atlasPath = "res/image/ui/img/btn/btn_1059.png"
--        local sign = "" -- "":" --string.chr(string.byte("9")+1)
--        local hp_str = sign .. "" .. math.abs(math.floor(hp))
--        local label = cc.LabelAtlas:_create(hp_str, atlasPath, 31, 39,  string.byte("0"))
--        label:setScale(1)
--        label:setAnchorPoint(cc.p(0.5, 0.5))
--        label:setPosition(cc.p(360 / 2, 20))
--        hintNode:addChild(label, 9999)
--
--        self.battleNode:addChild(hintNode)
--        --table.insert(self.actionNodeList, hintNode)
--        hintNode:setScale(0.7)
--        hintNode:runAction(cc.Sequence:create({
--            cc.Spawn:create({cc.MoveBy:create(0.25, cc.p(0, 70)), cc.ScaleTo:create(0.25, 1.3)}),
--            cc.ScaleTo:create(0.05, 1),fadeout
--            cc.Spawn:create({cc.MoveBy:create(0.4, cc.p(0, 40)), cc.FadeOut:create(0.4)}),
--            --cc.CallFunc:create(function() table.removeItem(self.actionNodeList, hintNode) end),
--            cc.RemoveSelf:create(),
--        }))
--    else
--        if restraint then
--            local atlasPath = "image/ui/img/btn/btn_469.png"
--            local label = cc.LabelAtlas:_create("23", atlasPath, 27, 28,  string.byte("0"))
--            label:setColor(cc.c3b(255, 10, 10))
--            label:setAnchorPoint(cc.p(0, 0.5))
--            label:setPosition(cc.p(width, height / 2))
--            hintNode:addChild(label)
--
--            width = width + 54
--        end
--
--        local atlasPath = hp > 0 and "image/atlas/numgreen.png" or "image/atlas/numred.png"
--        local sign = "" -- "":" --string.chr(string.byte("9")+1)
--        local hp_str = sign .. "" .. math.abs(math.floor(hp))
--        local label = cc.LabelAtlas:_create(hp_str, atlasPath, 18, 25,  string.byte("0"))
--        label:setScale(1.5)
--        label:setAnchorPoint(cc.p(0, 0.5))
--        label:setPosition(cc.p(width, height / 2))
--        hintNode:addChild(label, 9999)
--        width = width + #hp_str * 27 * 1.5
--
--        hintNode:setContentSize(cc.size(width, height))
--        hintNode:setAnchorPoint(cc.p(0.5, 0.5))
--        hintNode:setPosition(cc.pAdd(basePos, cc.p(0, 160)))
--
--        self.battleNode:addChild(hintNode)
--        --table.insert(self.actionNodeList, hintNode)
--        hintNode:runAction(cc.Sequence:create({
--            cc.MoveBy:create(0.4, cc.p(0, 70)),
--            cc.DelayTime:create(0.4),
--            --cc.CallFunc:create(function() table.removeItem(self.actionNodeList, hintNode) end),
--            cc.RemoveSelf:create(),
--        }))
--    end
--end

function BattleController:onKnockedback(name , data)
    CCLog(vardump(data, "BattleController:onKnockedback()"))
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local direction = data.direction
    local value = data.value or 1

    local rawcell = heroModel:getCell()
    local cell = rawcell
    if direction == "right" then
        cell = {x = cell.x + value, y = cell.y}
    else
        cell = {x = cell.x - value, y = cell.y}
    end
    cell.x = math.min(BattleConfig.X_CELL_COUNT - 1, math.max(cell.x, 0))
    
    local destPos = BattleConfig.getCellPos(cell.x, cell.y)

    CCLog(vardump({raw = rawcell, cell = cell, pos = destPos, name = heroModel:getName()}, "onKnockedback"))

    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView then
        heroModel:incHitting()
        heroModel:clearMoving()
        heroModel:setCellAndUpdatePos(cell)
        heroView:runAction(cc.Sequence:create({
            cc.MoveTo:create(0.5, _PPOS(destPos)),
            cc.Place:create(_PPOS(destPos)),
            cc.CallFunc:create(function()
                heroModel:setCellAndUpdatePos(cell)
                heroModel:decHitting()
            end),
        }))
    end
end

function BattleController:onSuction(name , data)
    CCLog(vardump(data, "BattleController:onSuction()"))
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local cell = data.cell

    local destPos = BattleConfig.getCellPos(cell.x, cell.y)
    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView then
        heroModel:incHitting()
        heroModel:clearMoving()
        heroModel:setCell(cell)
        heroView:runAction(cc.Sequence:create({
            cc.MoveTo:create(0.5, _PPOS(destPos)),
            cc.CallFunc:create(function()
                heroModel:setCellAndUpdatePos(cell)
                heroModel:decHitting()
            end),
        }))
    end
end

function BattleController:onHeroMiss(name , data)
    CCLog("BattleController:onHeroMiss")

    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = self:getFighterView(heroModel:getFighterID())

    if heroView and not tolua.isnull(heroView) then
        heroView:miss()
    end

    self:updateControlPanel()
end

function BattleController:onHeroCrit(name , data)
    CCLog("BattleController:onHeroMiss")

    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = self:getFighterView(heroModel:getFighterID())

    if heroView and not tolua.isnull(heroView) then
        heroView:crit()
    end

    self:updateControlPanel()
end

function BattleController:onHeroTreated(name, data)
    local fighterID = data.fighterID
    local hp = data.hp
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = self:getFighterView(heroModel:getFighterID())

    if heroView and not tolua.isnull(heroView) then
        heroView:treated(data.hp)
    end
end

function BattleController:onFairyCool(name, data)
    local teamSide = data.teamSide
    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    else
        team = self.battleModel.rightTeam
    end

    local fairyModel = team:getFairyModel()
    local fairyView = self:getFighterView(fairyModel:getFighterID())
    if fairyView and not tolua.isnull(fairyView) then
        fairyView:cool()
    end

    if self.battleModel:isAutoBattle() then
        fairyModel:autoReleaseSkill()
    end
end

function BattleController:onFairyCoolPercentChange(name, data)
    CCLog(vardump({name,data}, "BattleController:onFairyCoolPercentChange"))
    local fighterID = data.fighterID
    local percent = data.percent

    local fighterView = self:getFighterView(fighterID)
    if fighterView then
        fighterView:updateCDPercent(percent)
    end
end

function BattleController:onFairySkillCommand(name, data)
    local teamSide = data.teamSide
    local index = data.index

    local team = nil
    if teamSide == "left" then
        team = self.battleModel.leftTeam
    else
        team = self.battleModel.rightTeam
    end

    local fairyModel = team:getFairyModel()
    fairyModel:releaseSkill(index)
end

function BattleController:onHitBuffAffect(name, data)
    CCLog("BattleController:onHitBuffAffect")

    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local affect = data.affect

    local heroView = assert(self:getFighterView(heroModel:getFighterID()))
    if tolua.isnull(heroView) then
        CCLog(vardump(heroModel), "heroView of hero is not exists")
        return
    end

    heroView:hitBuffAffect(affect)
end

function BattleController:onImmune(name, data)
    CCLog("BattleController:onImmune")

    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)

    local heroView = assert(self:getFighterView(heroModel:getFighterID()))
    if tolua.isnull(heroView) then
        CCLog(vardump(heroModel), "heroView of hero is not exists")
        return
    end

    heroView:immune()
end

function BattleController:onRandomDialogue(name, data)
    local teamSide = data.teamSide
    local dialogueID = data.dialogueID
    CCLog(vardump({teamSide = teamSide, dialogueID = dialogueID}))

    local dialogueData = BaseConfig.GetDialogue(dialogueID)

    CCLog(vardump({teamSide = teamSide, dialogueID = dialogueID, dialogueData = dialogueData}))

    local monsterID = data.monsterID

    if monsterID ~= nil and monsterID ~= 0 then
        local monster = nil

        local team = self.battleModel:getTeam(teamSide)
        local heroModels = team:getAliveHeroModels()
        for _, heroModel in ipairs(heroModels) do
            if heroModel:getHeroID() == monsterID then
                monster = heroModel
            end
        end

        if monster then
            local view = self:getFighterView(monster:getFighterID())
            if view then
                view:dialogue(dialogueData.content[1])
            end
        else
            CCLog("怪物:", monsterID, "没有找到")
        end
    else
        local team = self.battleModel:getTeam(teamSide)
        local heroModels = team:getAliveHeroModels()
        local index = self.battleModel:random(1, #heroModels)
        local heroModel = heroModels[index]

        local heroView = self:getFighterView(heroModel:getFighterID())
        if heroView then
            heroView:randomDialogue(dialogueData.content)
        end
    end
end

function BattleController:onDialogue(name, data)
    local teamSide = data.teamSide
    local dialogueID = data.dialogueID
    CCLog(vardump({teamSide = teamSide, dialogueID = dialogueID}))

    local dialogueData = BaseConfig.GetDialogue(dialogueID)

    CCLog(vardump({teamSide = teamSide, dialogueID = dialogueID, dialogueData = dialogueData}))

    local monsterID = data.monsterID
    local monster = nil

    local team = self.battleModel:getTeam(teamSide)
    local heroModels = team:getAliveHeroModels()
    for _, heroModel in ipairs(heroModels) do
        if heroModel:getHeroID() == monsterID then
            monster = heroModel
        end
    end

    if monster then
        local view = self:getFighterView(monster:getFighterID())
        if view then
            view:dialogue(dialogueData.content[1])
        end
    else
        CCLog("怪物:", monsterID, "没有找到")
    end
end

function BattleController:onMonsterSkill(name, data)
    CCLog(vardump({name = name, data = data}, "BattleController:onMonsterSkill"))

    local skillID = data.skillID
    local fighterID = data.fighterID
    local fighter = FighterModel.getFighter(fighterID)
    local skillData = BaseConfig.GetHeroSkill(skillID, 1)
    fighter:doSkill(skillData)
end


--function BattleController:onRageSkill(attackData)
--    CCLog(vardump(attackData, "rage skill"))
--    local heroModel = attackData.srcHero
--
--    local cell = heroModel:getCell()
--    local pos = BattleConfig.getCellPos(cell.x, cell.y)
--
--    local heroView = self:getHeroViewByModel(heroModel)
--    if heroView then
--        local skillID = attackData.skillID
--
--        heroView:performRageSkill()
--        local label = cc.LabelTTF:create("怒", "Arial", 50)
--        label:setPosition(cc.pAdd(pos, cc.p(0, 80)))
--        self:addChild(label, 100)
--        label:setColor(cc.c3b(255, 0, 0))
--
--        local enemyModels = self.battleModel:getEnemyMembers(heroModel:getTeamSide())
--
--        label:runAction(cc.Sequence:create({
--            cc.DelayTime:create(1),
--            cc.CallFunc:create(function()
--                for idx, enemy in ipairs(enemyModels) do
--                    attackData.dstHero = enemy
--                    enemy:hit(attackData)
--                end
--            end),
--
--            cc.DelayTime:create(1),
--            cc.RemoveSelf:create(),
--        }))
--
--        -- TODO:
--        self.battleModel:getTeam(heroModel:getTeamSide()):decRage(20)
--        self:updateControlPanel()
--    else
--        CCLog("Hero view not found")
--    end
--end

function BattleController:onRegionRageSkill(name, data)
    if self.params.battleType == "GUIDE" then        
        if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
            Common.CloseGuideLayer({1})
            Common.OpenGuideLayer({1})
            CCLog("GUIDE: 猪八戒范围选择")
        -- elseif self.battleModel.guideStepInfo.step == 3  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
        --     Common.CloseGuideLayer({1})
        --     Common.OpenGuideLayer({1})
        --     CCLog("GUIDE: 唐僧范围选择")
        end

        if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 1 then
            Common.CloseGuideLayer({2})
            Common.OpenGuideLayer({2})
            CCLog("GUIDE: 猪八戒范围选择")
        end

        -- if self.battleModel.guideStepInfo.step == 2 and self.battleModel.guideStepInfo.open[2] and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 2 then
        --     Common.CloseGuideLayer({2})
        --     Common.OpenGuideLayer({2})
        --     CCLog("GUIDE: 猪八戒范围选择")
        -- end
        -- if self.battleModel.guideStepInfo.step == 3 and self.battleModel.guideStepInfo.open[3] and GameCache.NewbieGuide.Step == 0 and self.battleModel.roundIndex == 2 then
        --     Common.CloseGuideLayer({0})
        --     Common.OpenGuideLayer({0})
        --     CCLog("GUIDE: 吕洞宾范围选择")
        -- end
    end

    self.controlPanel:refresh()

    self:clearRegionRageSkill()

--    if self.regionRageSkill == nil then
        local attackData = AttackDataModel.decode(data, self.battleModel)
        local heroModel = attackData:getHeroModel()

--        self.regionRageSkill = {attackData = attackData}
--        self:drawAttackScope()
--        if self.autoBattle or heroModel:getTeamSide() == "right" then
--            self.battleModel:addAction(BattleModel.TIME_UNIT * 10, function()
--                if self.regionRageSkill and self.regionRageSkill.dragScopeNode then
--                    self.regionRageSkill.dragScopeNode:done()
--                end
--            end)
--        end

        if  self:isAutoBattle() or heroModel:getTeamSide() == "right" then
            local cell = attackData:getRegionCenterCell()
            attackData:setDestCell(cell)
            local heroModel = attackData:getHeroModel()
            heroModel:doAttack(attackData)
            heroModel:setInRageScopeSelecting(false)
        else
            local team = heroModel:getTeam()
            if team:getRegionRageData() == nil then
                team:setRegionRageData({attackData = attackData})
                --self:drawAttackScope()
                self.regionSkillShadow:setVisible(true)
                self:createRegionRageView(attackData)
            end

            if BattleConfig.REGION_RAGE_PAUSE then
                self:pauseBattle()
            end
        end
 --   end
end

function BattleController:onHeroChoiceRageSkill(name, data)
    CCLog("BattleController:onHeroChoiceRageSkill()")
    local attackData = AttackDataModel.decode(data, self.battleModel)
    local heroModel = attackData:getHeroModel()

    -- TODO:现在只有复活技能在用，点击英雄头像
    local team = heroModel:getTeam()
    team:setResurrectionData(attackData)

    if  self:isAutoBattle() or heroModel:getTeamSide() == "right" then
        local deadHeroModels = team:getDeadHeroModels()
        if #deadHeroModels > 0 then
            team:resurrectHero(deadHeroModels[1], self.battleModel)
        else
            team:resetResurrectionData()
            assert(false, "点了复活技能，没有死人")
        end
    end

    self.controlPanel:refresh()
end

-- 被悬崖拖死在了原地
function BattleController:onHeroStuck(name, data)
    CCLog("on event:", vardump({name = name}))
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    CCLog("英雄死了:", heroModel:getName())

    self.battleModel:heroDie(heroModel)
    local heroView = self:getFighterView(heroModel:getFighterID())


    CCLog(vardump({roundIndex = self.battleModel.roundIndex,
        roundCount = self.battleModel:getRoundCount(),
        teamSide = heroModel:getTeamSide(),
        rightTeamAliveCount = self.battleModel.rightTeam:getAliveHeroCount(true),
        dropList = self.params.dropList
    }, "HeroDie"))

    if heroView and not tolua.isnull(heroView) then
        heroModel:setView(nil)
        local absPos = heroView:convertToWorldSpace(cc.p(0, 0))
        heroView:retain()
        self.battleNode:removeChild(heroView, false)

        local midMapView = self.mapMgr:getMiddleLayer()
        local scrollPos = midMapView:convertToNodeSpace(absPos)
        heroView:setRotationSkewX(0)
        heroView:setPosition(_PPOS(scrollPos))

        midMapView:addChild(heroView, 999)
        heroView:release()
    end

    --self:drawAttackScope()
    self.controlPanel:refresh()
end

function BattleController:onFighterDie(name, data)
    CCLog("on event:", vardump({name = name}))
    local fighterID = data.fighterID
    local fighterModel = FighterModel.getFighter(fighterID)
    CCLog("英雄死了:", fighterModel:getName())

    if fighterModel:getFighterType() == "hero" then
        local team = fighterModel:getTeam()
        local regionRageData = team:getRegionRageData()
        if regionRageData ~= nil then
            local heroModel = regionRageData.attackData:getHeroModel()
            if fighterModel == heroModel then
                self:clearRegionRageSkill(heroModel)
                self:clearHeroRageScopeHighlight()
            end
        end
    end

    local heroView = self:getFighterView(fighterID)
    CCLog(vardump({roundIndex = self.battleModel.roundIndex,
                roundCount = self.battleModel:getRoundCount(),
                teamSide = fighterModel:getTeamSide(),
                rightTeamAliveCount = self.battleModel.rightTeam:getAliveHeroCount(true),
                dropList = self.params.dropList
                }, "HeroDie"))
    if heroView and not tolua.isnull(heroView)
            and self.battleModel.roundIndex == self.battleModel:getRoundCount()
            and fighterModel:getTeamSide() == "right"
            and self.battleModel.rightTeam:getAliveHeroCount(true) == 0
            and self.params.droplist ~= nil
    then
        local pos = self.battleNode:convertToWorldSpace(cc.p(heroView:getPosition()))
        CCLog("dropList begin")
        self:lose(self.params.droplist, pos,  function()
            self.dropBoxLabel:setString(tostring(#self.params.droplist))

            local iconScale = self.dropBoxIcon:getScale()
            self.dropBoxIcon:runAction(cc.Spawn:create(
                cc.Sequence:create({
                    cc.ScaleTo:create(0.2, iconScale * 1.2),
                    cc.ScaleTo:create(0.4, iconScale * 0.8),
                    cc.ScaleTo:create(0.2, iconScale * 1.0),
                }), cc.Blink:create(0.8, 2)))
            CCLog("dropList end")
        end)
    end

    self.battleModel:heroDie(fighterModel)

    if heroView and not tolua.isnull(heroView) then
        fighterModel:setView(nil)
        heroView:stopAllActions()
        heroView:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), 
            cc.CallFunc:create(function()
                local midMapView = self.mapMgr:getMiddleLayer()
                BattleUtils.moveNodeContainer(heroView, midMapView)
                heroView:setRotationSkewX(0)
                heroView:die()
            end)
        ))
    end

    --self:drawAttackScope()

    local bossHPBar = self.bossHPBarMap[fighterModel]
    if bossHPBar then
        bossHPBar:removeFromParent()
        self.bossHPBarMap[fighterModel] = nil
    end
    
    self.controlPanel:refresh()
end

function BattleController:onFighterExpired(name, data)
    CCLog("on event:", vardump({name = name}))
    local fighterID = data.fighterID
    local fadeoutTime = data.fadeoutTime
    local fighterModel = FighterModel.getFighter(fighterID)
    CCLog("英雄死了:", fighterModel:getName())

    if fighterModel:getFighterType() == "hero" then
        local team = fighterModel:getTeam()
        local regionRageData = team:getRegionRageData()
        if regionRageData ~= nil then
            local heroModel = regionRageData.attackData:getHeroModel()
            if fighterModel == heroModel then
                self:clearRegionRageSkill(heroModel)
                self:clearHeroRageScopeHighlight()
            end
        end
    end

    local heroView = self:getFighterView(fighterID)
    if heroView and not tolua.isnull(heroView) then
        heroView:expired(fadeoutTime)
    end
    --self:drawAttackScope()

    self.controlPanel:refresh()
end

function BattleController:onHeroKill(name, data)
    -- TODO:杀死一个人
    CCLog("on event:", vardump({name = name, data = data}))
    local fighterID = data.fighterID
    local killedFighterID = data.killedFighterID
    local killer = FighterModel.getFighter(fighterID)
    local killedFighter  = FighterModel.getFighter(killedFighterID)

    if killer:getFighterType() == "hero" then
        local team = killer:getTeam()
        team:onHeroKill(killer, killedFighter)
    end
end

function BattleController:onHPChange(name, data)
    CCLog("on event:", vardump({name = name}))

    local fighterID = data.fighterID
    local fighter = FighterModel.getFighter(fighterID)

    local fighterView = self:getFighterView(fighter:getFighterID())
    if fighterView and not tolua.isnull(fighterView) then
        fighterView:updateHPPercent(data.percent)
        if data.hint then
            fighterView:hpChange(data.value)
        end
    end

    self:updateHPBar()

    local bossHPBar = self.bossHPBarMap[fighter]
    if bossHPBar then
        bossHPBar:updatePercent(data.percent)
    end
end

function BattleController:onHeroBuffAdded(name, data)
    CCLog("on event:", vardump({name = name}))
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local buff = BuffModel.decode(data.buff, self.battleModel)
    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView and not tolua.isnull(heroView) then
        heroView:buffAdded(buff)

        -- 法海收怪
        local buffData = buff:getBuffData()
        if buffData.affect == enums.BuffAffectType.Shackle and buff.skillID == 1345 then
            local heroAni = heroView:createHeroAni()
            if heroModel:getDirection() == "left" then
                heroAni:setRotationSkewY(180)
            end
            local attacker = buff.attacker
            local toPos = cc.pAdd(attacker:getCellPos(), cc.p(0, 200))
            local fromPos = cc.p(heroView:getPosition())

            self.battleNode:addChild(heroAni)
            heroAni:setPosition(fromPos)
            heroAni:runAction(cc.Sequence:create({
                    cc.Spawn:create({
                        cc.MoveTo:create(0.4, toPos),
                        cc.ScaleTo:create(0.4, 0.2)
                    }), 
                    cc.RemoveSelf:create()
            })) 
        end        
    end
end

function BattleController:onHeroBuffRemoved(name, data)
    CCLog("on event:", vardump({name = name}))
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local buff = BuffModel.decode(data.buff, self.battleModel)
    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView and not tolua.isnull(heroView) then
        heroView:buffRemoved(buff)
    end
end

function BattleController:onHeroBuffReplaced(name, data)
    CCLog("on event:", vardump({name = name}))
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local newBuff = BuffModel.decode(data.newBuff, self.battleModel)
    local oldBuff = BuffModel.decode(data.oldBuff, self.battleModel)
    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView and not tolua.isnull(heroView) then
        heroView:buffReplaced(oldBuff, newBuff)
    end
end

function BattleController:onFollowMagicCircleAdded(name, data)
    CCLog("on event:", vardump({name = name}))

    local fighterID = data.fighterID
    local fighter = FighterModel.getFighter(fighterID)
    local view = self:getFighterView(fighter:getFighterID())
    local skillID = data.skillID

    if view and not tolua.isnull(view) then
        view:magicCircleAdded(skillID)
    end
end

function BattleController:onFollowMagicCircleRemoved(name, data)
    CCLog("on event:", vardump({name = name}))

    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local heroView = self:getFighterView(heroModel:getFighterID())
    local skillID = data.skillID

    if heroView and not tolua.isnull(heroView) then
        heroView:magicCircleRemoved(skillID)
    end
end

function BattleController:onFixedMagicCircleAdded(name, data)
    CCLog("on event:", vardump({name = name, data = data}))

    local cell = data.cell
    local ID = data.ID or 0
    local magicSkillID = data.skillID
    local serialID = data.serialID

    self.battleModel.magicCircleList:dump()
    local magicCircleModel = assert(self.battleModel.magicCircleList:find(ID), "error:magicCircleModel.ID = " .. ID)
    local view = FixedMagicCircleView.new(magicSkillID)
    view:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    magicCircleModel:setView(view)
    view:setPosition(_PPOS(BattleConfig.getCellPos(cell.x, cell.y)))
    self.battleNode:addChild(view)

    self:setMagicCircleView(serialID, view)
end

function BattleController:onFixedMagicCircleRemoved(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local ID = data.ID or 0
    local serialID = data.serialID

    local view = self:getMagicCircleView(serialID)
    if view and not tolua.isnull(view) then
        view:clear()
        view:removeFromParent()
        CCLog("remove Magic Circle View")
    end
end

function BattleController:onRemoveFixedMagicCircle(name, data)
    local fighterID = data.fighterID
    local fighter = FighterModel.getFighter(fighterID)
    local skillID = data.skillID

    self.battleModel:removeMagicCircle(fighter, skillID)
end

function BattleController:onResurrectionMonster(name, data)
    local srcMonsterID = data.srcMonsterID
    local dstMonsterID = data.dstMonsterID
    local srcMonster = nil
    local dstMonster = nil

    local team = self.battleModel.rightTeam

    local heroModels = team:getAllHeroModels(true)
    for _, heroModel in ipairs(heroModels) do
       if heroModel:getHeroID() == srcMonsterID then
           srcMonster = heroModel
       end
       if heroModel:getHeroID() == dstMonsterID then
           dstMonster = heroModel
       end
    end

    if srcMonster and dstMonster then
        CCLog(srcMonster:getName(), "6秒后复活", dstMonster:getName())
        dstMonster:resurrect(nil, dstMonster:getFullHP())
    else
        CCLog("怪物:", srcMonsterID, "或", dstMonsterID, "没有找到")
    end
end

function BattleController:onContinuousSkillBegin(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

    local heroModel = attackData:getHeroModel()
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()
    local skillLevel = attackData:getSkillLevel()
    local skillData = attackData:getSkillData()

    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView then
        heroView:onContinuousSkillBegin(skillID)
    end

    -- TODO:
    if skillID == 1331 then
        local targetFighterList = attackData:getTargetFighterList()
        for _, enemyModel in ipairs(targetFighterList) do
            enemyModel:incContinuousHitCount()
            local enemyView = self:getFighterView(enemyModel:getFighterID())
            if enemyView then
                enemyView:continuousHitBegin(skillID)
            end
        end
    end
end

function BattleController:onContinuousSkillEnd(name, data)
    CCLog("on event:", vardump({name = name}))
    local attackData = AttackDataModel.decode(data, self.battleModel)

    local heroModel = attackData:getHeroModel()
    local heroID = heroModel:getHeroID()
    local skillID = attackData:getSkillID()

    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView then
        heroView:onContinuousSkillEnd(skillID)
    end

    -- TODO:
    if skillID == 1331 then
        local targetFighterList = attackData:getTargetFighterList()
        for _, enemyModel in ipairs(targetFighterList) do
            enemyModel:decContinuousHitCount()
            local enemyView = self:getFighterView(enemyModel:getFighterID())
            if enemyView then
                enemyView:continuousHitEnd(skillID)
            end
        end
    end
--
--    local enemyModel = heroModel:getMatchedEnemy()
--    if enemyModel == nil then
--        CCLog("没有配对的敌人，已经被打死了？")
--        return
--    end
--    enemyModel:incContinuousHitCount()

--    local aniBG = self.battleNode:getChildByName(string.format("continue_skill_bg_%s_%d", fighterID, skillID))
--    local aniNode = self.battleNode:getChildByName(string.format("continue_skill_ani_%s_%d", fighterID, skillID))
--
--    if aniBG then
--        aniBG:removeFromParent()
--    end
--
--    if aniNode then
--        table.removeItem(self.bulletList, aniNode)
--        aniNode:removeFromParent()
--    end
end

function BattleController:onAITriggered(name, data)

end

function BattleController:onTrapSkill(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local fighterID = data.fighterID
    local targetID = data.targetID

    local target = FighterModel.getFighter(targetID)
    local targetView = self:getFighterView(targetID)

    local trapModel = FighterModel.getFighter(fighterID)
    if trapModel then
        local trapView = self:getFighterView(fighterID)
        if trapView and not tolua.isnull(trapView) then
            BattleUtils.moveNodeContainer(trapView, self.battleNode)

            trapView:setLocalZOrder(targetView:getLocalZOrder() + 1)
            trapView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
            trapView:attack()
        else
            CCLog("trapView is null")
        end
    else
        CCLog("find trap fail:", vardump(trapID, cell))
    end
end

function BattleController:onTrapAdded(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local fighterID = data.fighterID
    local trapID = data.trapID
    local cell = data.pos
    local range = data.range

    local trapModel = FighterModel.getFighter(fighterID)
    local roundIndex = self.battleModel.roundIndex

    if trapModel then
        local trapView = BattleTrapView.new(trapID, cell, range)
        self:setFighterView(fighterID, trapView)

        trapModel:setView(trapView)
        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
        local woldPos = self.battleNode:convertToWorldSpace(_PPOS(pos))
        trapView:setVisible(true)
        local zorder = BattleUtils.getCellZOrder({x = trapModel.pos.x, y = 0}, "right")
        --trapView:setPosition(pos
        --self.battleNode:addChild(trapView, zorder + 1)
        local midMapView = self.mapMgr:getMiddleLayer()
        local offset = self.mapMgr:getRoundOffset(self.battleModel.roundIndex)
        woldPos = cc.pAdd(woldPos, offset)

        CCLog(vardump({pos = pos, roundIndex = self.battleModel.roundIndex, offset = offset, worlPos = woldPos, midSize = midMapView:getContentSize()}, "trapView:pos"))
        trapView:setRotationSkewX(0)
        trapView:setPosition(woldPos)

        trapView:setGlobalZOrder(103)

        local zorder = BattleUtils.getCellZOrder(cell, "right")
        trapView:setLocalZOrder(zorder - 1)
        midMapView:addChild(trapView, zorder)
    end
end

function BattleController:onTrapRemoved(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local fighterID = data.fighterID

    local trapModel = FighterModel.getFighter(fighterID)
    if trapModel then
        local trapView = self:getFighterView(trapModel:getFighterID())
        if trapView and not tolua.isnull(trapView) then
            trapView:idle()

            local midMapView = self.mapMgr:getMiddleLayer()

            BattleUtils.moveNodeContainer(trapView, midMapView)
            trapView:setOpacity(150)
            trapView:runAction(cc.Sequence:create({
                cc.FadeTo:create(0.5, 80),
                cc.RemoveSelf:create(),
            }))
        end
    end
end

function BattleController:onTurretAdded(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local TurretView = require("scene.battle.view.TurretView")
    local fighterID = data.fighterID
    local teamSide = data.teamSide
    local showHPBar = data.showHPBar
    local res = data.res
    local cell = data.cell

    local turretModel = FighterModel.getFighter(fighterID)
    local turretView = TurretView.new(res, showHPBar)
    self:setFighterView(turretModel:getFighterID(), turretView)

    --turretModel:setView(turretView)
    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
    turretView:setPosition(_PPOS(pos))
    turretView:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.battleNode:addChild(turretView)
end

function BattleController:onObstacleAdded(name, data)
    CCLog("on event:", vardump({name = name, data = data, round = self.battleModel.roundIndex}))
    local fighterID = data.fighterID
    local obstacleID = data.obstacleID
    local cell = data.pos
    local res = data.res
    local obstacleType = data.type

    local obstacleModel = FighterModel.getFighter(fighterID)
    local roundIndex = self.battleModel.roundIndex

    if obstacleModel then
        local obstacleView = BattleObstacleView.new(obstacleID, cell, res, obstacleType)
        self:setFighterView(fighterID, obstacleView)

        obstacleModel:setView(obstacleView)
        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
        local woldPos = self.battleNode:convertToWorldSpace(_PPOS(pos))
        obstacleView:setVisible(true)
        local zorder = BattleUtils.getCellZOrder({x = obstacleModel.pos.x, y = 0}, "right")
--        self.battleNode:addChild(obstacleView, zorder)
        local offset = self.mapMgr:getRoundOffset(self.battleModel.roundIndex)
        woldPos = cc.pAdd(woldPos, offset)

        local midMapView = self.mapMgr:getMiddleLayer()
        CCLog(vardump({pos = pos, roundIndex = self.battleModel.roundIndex, offset = offset, worlPos = woldPos, }, "ObstacleView:pos"))
        obstacleView:setRotationSkewX(0)
        obstacleView:setPosition(woldPos)

        obstacleView:setGlobalZOrder(103)
        midMapView:addChild(obstacleView, zorder)

        --self.mapMgr:addMiddleRegionChild(roundIndex, pos, obstacleView)
    end
end

function BattleController:onObstacleRemoved(name, data)
    CCLog("on event:", vardump({name = name, data = data}))
    local fighterID = data.fighterID
    local res = data.res

    local obstacleModel = FighterModel.getFighter(fighterID)
    if obstacleModel then
        if obstacleModel:isHittable() then
        local obstacleView = self:getFighterView(fighterID)
        obstacleView:setOpacity(150)
        obstacleView:runAction(cc.Sequence:create({
            cc.FadeOut:create(2),
            cc.RemoveSelf:create(),
        }))

        local effectPath = string.format("image/map/obstacle/effect/%s/", res)
        local effectAni = load_animation(effectPath)
        if effectAni then
            print("play obstacle effect:", effectPath)
            effectAni:setAnimation(0, "animation", false)
            effectAni:setPosition(obstacleView:getPosition())

            local midMapView = self.mapMgr:getMiddleLayer()
            effectAni:setGlobalZOrder(103)
            midMapView:addChild(effectAni)

            effectAni:registerSpineEventHandler(function(event)
                effectAni:setVisible(false)
                effectAni:runAction(cc.Sequence:create({
                    cc.DelayTime:create(0.01),
                    cc.RemoveSelf:create(),
                }))
            end, sp.EventType.ANIMATION_END)
        end

        else
--            local obstacleView = self:getFighterView(obstacleModel:getFighterID())
--            if obstacleView and not tolua.isnull(obstacleView) then
--                obstacleModel:setView(nil)
--                local absPos = obstacleView:convertToWorldSpace(cc.p(0, 0))
--                obstacleView:retain()
--                self.battleNode:removeChild(obstacleView, false)
--
--                local midLayer = self.mapMgr:getMiddleLayer()
--                local scrollPos = midLayer:convertToNodeSpace(absPos)
--                obstacleView:setSkewY(0)
--                obstacleView:setPosition(scrollPos)
--                midLayer:addChild(obstacleView, 999)
--                obstacleView:release()
--            end
        end
    end
end

function BattleController:onProtectByturret(name, data)
    local fighterID = data.fighterID
    local figtherView = self:getFighterView(fighterID)

    figtherView:protectByturret()
end

function BattleController:onLoseProtectionOfTurret(name, data)
    local fighterID = data.fighterID
    local figtherView = self:getFighterView(fighterID)
    figtherView:loseProtectionOfTurret()
end

function BattleController:onSetHeroPos(name, data)
    local fighterID = data.fighterID
    local pos = data.pos
    local figtherView = self:getFighterView(fighterID)
    if figtherView then
        --figtherView:setPosition(_PPOS(pos))
        figtherView:runAction(cc.MoveTo:create(BattleConfig.TIME_UNIT, _PPOS(pos)))
    end
end

function BattleController:onTeleportToCell(name, data)
    CCLog("on event:", vardump({name = name, data = data}))

    local fighterID = data.fighterID
    local cell = data.cell
    local pos = BattleConfig.getCellPos(cell.x, cell.y)
    local figtherView = self:getFighterView(fighterID)
    if figtherView then
        figtherView:setPosition(_PPOS(pos))
        figtherView:teleport()

        if data.status == "begin" then

        else

        end
    end
end

function BattleController:onTransfiguration(name, data)
    -- self.battleModel:dispatchEvent(AppEvent.UI.Battle.Transfiguration, {dstMonsterID = self.aiData.Content, srcMonsterID = self.aiData.Monster})

    local srcMonsterID = data.srcMonsterID
    local dstMonsterID = data.dstMonsterID
    local srcMonster = nil
    local dstMonster = nil

    local team = self.battleModel.rightTeam

    local heroModels = team:getAllHeroModels(true)
    for _, heroModel in ipairs(heroModels) do
       if heroModel:getHeroID() == srcMonsterID then
           srcMonster = heroModel
       end
    end

    local bossHPBar = self.bossHPBarMap[srcMonster]
    if bossHPBar then
        bossHPBar:removeFromParent()
        self.bossHPBarMap[srcMonster] = nil
    end

    local team = srcMonster:getTeam()
    team:transfiguration(srcMonster, dstMonsterID)
end

function BattleController:clearRegionRageSkill(heroModel)
    self.regionSkillShadow:setVisible(false)

    if heroModel then
        local team = heroModel:getTeam()
        local regionRageData = team:getRegionRageData()
        if regionRageData ~= nil then
            heroModel:setInRageScopeSelecting(false)
            team:setRegionRageData(nil)
            self:resumeBattle()
        end
    else
        local team

        local teams = {self.battleModel.leftTeam, self.battleModel.rightTeam }
        for _, team in ipairs(teams) do
            local regionRageData = team:getRegionRageData()
            if regionRageData ~= nil then
                heroModel = regionRageData.attackData:getHeroModel()
                heroModel:setInRageScopeSelecting(false)
                local fighterID = heroModel:getFighterID()
                local regionNode = self.fighterRegionNodeMap[fighterID]
                if regionNode and not tolua.isnull(regionNode) then
                    regionNode:removeFromParent()
                end
                self.fighterRegionNodeMap[fighterID] = nil

                local areaNode = self.fighterAreaNodeMap[fighterID]
                if areaNode and not tolua.isnull(areaNode) then
                    areaNode:removeFromParent()
                end
                self.fighterAreaNodeMap[fighterID] = nil

                team:setRegionRageData(nil)

                if self.battleModel.pausedCount > 0 then
                    self:resumeBattle()
                end
            end
        end
    end


--    if self.regionRageSkill ~= nil then
--        local rageSkillInfo = self.regionRageSkill
--        if rageSkillInfo.dragScopeNode ~= nil and not tolua.isnull(rageSkillInfo.dragScopeNode) then
--            local clippingNode = rageSkillInfo.dragScopeNode:getParent()
--            local typeName = tolua.type(clippingNode)
--            CCLog("ClassName:" .. typeName)
--            rageSkillInfo.dragScopeNode:removeFromParent()
--            rageSkillInfo.dragScopeNode = nil
--        end
--
--        if rageSkillInfo.skillRegionNode ~= nil and not tolua.isnull(rageSkillInfo.skillRegionNode) then
--            rageSkillInfo.skillRegionNode:removeFromParent()
--            rageSkillInfo.skillRegionNode = nil
--        end
--
--        local attackData = rageSkillInfo.attackData
--        local heroModel = attackData:getHeroModel()
--        heroModel:setInRageScopeSelecting(false)
--    end
--
--    self.regionRageSkill = nil
end

function BattleController:battleEnd(record, result)
    -- Profiler:stop()
    -- local profileReportFileName = cc.FileUtils:getInstance():getWritablePath() .. "d1_profile.txt"
    -- Profiler:writeReport(profileReportFileName)
    -- local report = cc.FileUtils:getInstance():getStringFromFile(profileReportFileName)
    -- release_print("report:", report)

    xpcall(function() 
        self:updateAcceleration(1) 
        local btn_pause = self.foregroundNode:getChildByName("btn_pause")
        btn_pause:setVisible(false)
    end, __G__TRACKBACK__)

    local callback = self.params and self.params.callback or function(...) end

    local deadHeroNum = self.battleModel.leftTeam:getDeadHeroCount()
    local fullHP = self.battleModel.leftTeam:getFullHP()
    local leftHP = math.floor(self.battleModel.leftTeam:getCurHP())
    local usedTime = math.ceil(self.battleModel.totalTimeTick * BattleConfig.TIME_UNIT)

    local enemyFullHP = self.battleModel.rightTeam:getFullHP()
    local enemyLeftHP = math.floor(self.battleModel.rightTeam:getCurHP())

    local heroRP = self.battleModel.leftTeam:getRage()
    local enemyRP = self.battleModel.rightTeam:getRage()

    local climbHero = self.battleModel.leftTeam:getAllHeroHPLeft()
    local climbEnemy = self.battleModel.rightTeam:getAllHeroHPLeft()

    local heroDamageStat = self.battleModel.leftTeam:getAllHeroDamageStat()
    local enemyDamageStat = self.battleModel.rightTeam:getAllHeroDamageStat()

    local battleResult = {
        sessionID = self.params.sessionID,
        record = {}, -- TODO:先不传
        result = result,
        params = self.params,
        deadHeroNum = deadHeroNum,
        fullHP = fullHP,
        leftHP = leftHP,
        CostTime = usedTime,
        usedTime = usedTime,
        heroRP = heroRP,
        enemyRP = enemyRP,
        HeroList = climbHero,
        climbHero = climbHero,
        climbEnemy = climbEnemy,
        heroDamageStat = heroDamageStat,
        enemyDamageStat = enemyDamageStat,
        enemyFullHP = enemyFullHP,
        enemyLeftHP = enemyLeftHP,
    }
    CCLog(vardump({
        record = "...",
        result = result,
        params = "...",
        deadHeroNum = deadHeroNum,
        fullHP = fullHP,
        leftHP = leftHP,
        usedTime = usedTime,
        heroRP = heroRP,
        enemyRP = enemyRP,
        climbHero = climbHero,
        climbEnemy = climbEnemy,
        heroDamageStat = heroDamageStat,
        enemyDamageStat = enemyDamageStat,
        enemyFullHP = enemyFullHP,
        enemyLeftHP = enemyLeftHP,

    }, "BattleResult"))

    callback(battleResult)

    self.battleModel.finished = true
end

function BattleController:playBackgroundMusic()
    Common.stopMusic(true)
    local musicFile = string.format("audio/music/battle_%02d.mp3", self.battleModel:random(1, 3))
    Common.playMusic(musicFile, true)
end

function BattleController:stopBackgroundMusic()
    Common.stopMusic(true)
end

function BattleController:showBossHPBar()
    local bossCount = table.nums(self.bossHPBarMap)
    if bossCount == 2 then
        local bossModel_1, bossHPBar_1 = next(self.bossHPBarMap)    
        local bossModel_2, bossHPBar_2 = next(self.bossHPBarMap, bossModel_1)

        bossHPBar_1:setPosition(cc.p(display.cx - 220, display.cy + 225))
        bossHPBar_1:setVisible(true)
        bossHPBar_2:setPosition(cc.p(display.cx + 220, display.cy + 225))
        bossHPBar_2:setVisible(true)
    elseif bossCount == 1 then
        local bossModel, bossHPBar = next(self.bossHPBarMap)    

        bossHPBar:setPosition(cc.p(display.cx, display.cy + 225))
        bossHPBar:setVisible(true)
    end
end

function BattleController:onBattleStateChange(name, data)
    CCLog(vardump({name = name, data = data}, "BattleController:onBattleStateChange"))
    local old = data.old
    local new = data.new
    local time = data.useTime

    self.stateLabel:setString(new)

    self:clearRegionRageSkill(nil)

    local fairyModel = self.battleModel.leftTeam:getFairyModel()
    if fairyModel then
        local fairyView = self:getFighterView(fairyModel:getFighterID())
        if fairyView and not tolua.isnull(fairyView) then
            fairyView:setEnabled(new == "fight")
        end
    end

    local fairyModel = self.battleModel.rightTeam:getFairyModel()
    if fairyModel then
        local fairyView = self:getFighterView(fairyModel:getFighterID())
        if fairyView and not tolua.isnull(fairyView) then
            fairyView:setEnabled(new == "fight")
        end
    end

    if new == "starting" then
        local beginStoryID = self.battleModel:getCurRoundBeginStory()
        if beginStoryID and beginStoryID ~= 0 then
            self.foregroundNode:setVisible(false)
            self.battleNode:setVisible(false)

            CCLog("start begin story")
            local callback = function()
                self:started()
                self.foregroundNode:setVisible(true)
                self.battleNode:setVisible(true)
            end
            local storyLayer = Common.CreateStoryLayer(beginStoryID, callback)
            if storyLayer then
                self:addChild(storyLayer, 5)
            else
                callback()
            end
        else
            self:started()
        end
    elseif new == "entrance" then
        local endPercent = self.mapMgr:getRoundOffsetPercent(self.battleModel.roundIndex) * 100
        local curPercent = self.mapMgr:getPercent() * 100
        map_inc_percent = (endPercent - curPercent) / (BattleConfig.ENTRANCE_TIME / BattleConfig.TIME_UNIT)

        self:updateRoundLabel()
        self:moveToBattleground(time)
        self.controlPanel:setVisible(false)
        self.mapMgr:resetHide()

        if self.battleModel:roundHasBoss(self.battleModel.roundIndex) then
            self:playBossWarning(function() Common.playMusic("audio/effect/battle_boss.mp3", true) end)
        end
    elseif new == "fight" then
        self.mapMgr:hideOutOfRegion() -- TODO:还有BUG，暂时不用
        if GameCache.NewbieGuide.Step == 3 and self.battleModel.roundIndex == 1 then
            CCLog("GUIDE: 自动战斗引导")

            self:pauseBattle()
            Common.OpenGuideLayer({3})     
            self.btn_autoBattle:setVisible(true)       
        end

        CCLog("map percent:", self.mapMgr:getPercent())
        self.rageAttackDataList = {}
        --local mapScrollView = self.mapMgr:getScrollView()
        --mapScrollView:stopAutoScrollChildren()
        --mapScrollView:jumpToPercentHorizontal(self.battleModel.roundIndex * 33)
        self.battleNode:removeChildByName("cloud_aircraft")

        self.battleModel:onBattleRoundStart()
        self.controlPanel:setVisible(true)

        if self.params.battleType == "PVE" or self.params.battleType == "GUIDE" then
            local nodeSeqID = self.params.nodeSequence[self.battleModel.roundIndex].ID
            self:monsterHint(nodeSeqID, handler(self, self.pauseBattle), handler(self, self.resumeBattle))

            self:showBossHPBar()
        end
    elseif new == "win" then
        self.mapMgr:resetHide()

        local function roundEnd()
            if self.battleModel.roundIndex >= self.battleModel:getRoundCount() then
                local heroViews = self:getAliveHeroViews("left")
                for _, heroView in ipairs(heroViews) do
                    heroView:win()
                end

                -- if self.params.battleType == "GUIDE" then
                --     self:battleEnd(nil, "win")
                -- else
                    local recordJson = self.battleModel:getRecordJson()

                    CCLog("battle record", recordJson)

                    local path = cc.FileUtils:getInstance():getWritablePath() .. "record.json"
                    local f = io.open(path, "w")
                    f:write(recordJson)
                    f:close()
                    CCLog("write record: " .. path)

                    self:updateDamageCoins()
                    self:runAction(cc.Sequence:create({
                        cc.DelayTime:create(2),
                        cc.CallFunc:create(function() self:battleEnd(recordJson, "win") end),
                    }))
                -- end
            else
                self.forwordButton:setEnabled(true)
                self.forwordButton:setVisible(true)

                local action = cc.RepeatForever:create(cc.Sequence:create({
                    cc.EaseSineInOut:create(cc.MoveBy:create(0.8, cc.p(-30, 0))),
                    cc.EaseSineInOut:create(cc.MoveBy:create(0.8, cc.p(30, 0))),
                    cc.CallFunc:create(function()
                        --if self:isAutoBattle() then
                        self:startNextBattleRound()
                        --end
                    end),
                }))
                self.forwordButton:runAction(action)
            end

            self:clearHeroRageScopeHighlight()
            self.battleModel:onBattleRoundEnd()
        end

        local heroViews = self:getAliveHeroViews("left")
        for _, heroView in ipairs(heroViews) do
            heroView:idle()
        end
        
        local endStoryID = self.battleModel:getCurRoundEndStory()
        if endStoryID and endStoryID ~= 0 then
            CCLog("start end story")
            local callback = function()
                roundEnd()
                self.foregroundNode:setVisible(true)
                self.battleNode:setVisible(true)

                if self.params.battleType == "GUIDE" then
                    if self.battleModel.roundIndex < self.battleModel:getRoundCount() then
                        self:startNextBattleRound()
                    end
                    self.forwordButton:setVisible(false)
                end
            end

            if self.battleModel.roundIndex >= self.battleModel:getRoundCount() then
                local btn_pause = self.foregroundNode:getChildByName("btn_pause")
                btn_pause:setVisible(false)
            end

            local storyLayer = Common.CreateStoryLayer(endStoryID, callback)
            self:addChild(storyLayer, 5)
            self.battleNode:setVisible(false)
            self.foregroundNode:setVisible(false)
        else
            self:runAction(cc.Sequence:create({
                cc.DelayTime:create(1),
                cc.CallFunc:create(function() roundEnd() end),
            }))
        end
    elseif new == "fail" then
        self.mapMgr:resetHide()

--        local label = cc.LabelTTF:create("你输了", "Arial", 35)
--        self:addChild(label, 999)
--        label:setColor(cc.c3b(255, 255, 0))
--        label:setPosition(cc.p(display.cx, display.cy))
        self.battleModel:onBattleRoundEnd()
        local enemyViews = self:getAliveHeroViews("right")
        for _, heroView in ipairs(enemyViews) do
            heroView:win()
        end

        local recordJson = self.battleModel:getRecordJson()
        CCLog("battle record", recordJson)
        local path = cc.FileUtils:getInstance():getWritablePath() .. "record.json"
        local f = io.open(path, "w")
        f:write(recordJson)
        f:close()
        CCLog("write record: " .. path)
        self:updateDamageCoins()
        self:runAction(cc.Sequence:create({
            cc.DelayTime:create(3),
            cc.CallFunc:create(function() self:battleEnd(recordJson, "fail") end),
        }))

        -- if self.battleModel.pausedCount > 0 then
        --    self:resumeBattle()
        -- end
    elseif new == "timeout" then
        self.mapMgr:resetHide()
        
        self.battleModel:onBattleRoundEnd()
        local heroViews = self:getAliveHeroViews("left")
        for _, heroView in ipairs(heroViews) do
            heroView:timeout()
        end

        local enemyViews = self:getAliveHeroViews("right")
        for _, heroView in ipairs(enemyViews) do
            heroView:win()
        end

        local recordJson = self.battleModel:getRecordJson()
        CCLog("battle record", recordJson)
        local path = cc.FileUtils:getInstance():getWritablePath() .. "record.json"
        local f = io.open(path, "w")
        f:write(recordJson)
        f:close()
        CCLog("write record: " .. path)
        self:updateDamageCoins()

        self:runAction(cc.Sequence:create({
            cc.DelayTime:create(3),
            cc.CallFunc:create(function() self:battleEnd(recordJson, "fail") end),
        }))

        -- if self.battleModel.pausedCount > 0 then
        --     self:resumeBattle()
        -- end
    end

    self:updateControlPanel()
end

function BattleController:onBattleTimeout(name, data)

end

function BattleController:onHeroDirectionChange(name, data)
    local fighterID = data.fighterID
    local heroModel = FighterModel.getFighter(fighterID)
    local direction = data.direction

    local heroView = self:getFighterView(heroModel:getFighterID())
    if heroView then
       heroView:setDirection(direction)
    end
end

function BattleController:onFriendGuard(name, data)
    self:pauseBattle()

    local guardHint = cc.Sprite:create("image/ui/img/btn/btn_1206.png")
    guardHint:setPosition(cc.p(-display.width, display.cy))
    self:addChild(guardHint, 1000)

    local function showFriend()
        local teamSide = "right"
        local team = self.battleModel.rightTeam
        local heroViews = self:getAliveHeroViews(teamSide)
        for _, heroView in ipairs(heroViews) do
            heroView:show()
            heroView:friendGuard()
        end

        if self.battleModel.roundIndex == 1 then
            local fairyModel = team:getFairyModel()
            -- 只显示攻击方仙女
            if fairyModel and teamSide == "left" then
                local headIconPath = fairyModel:getHeadIconPath()
                local skillID1 = fairyModel:getSkill(1)
                local skillID2 = fairyModel:getSkill(2)

                local fairyView = BattleFairyView.new(self, teamSide, skillID1, skillID2, headIconPath)
                self:setFighterView(fairyModel:getFighterID(), fairyView)

                CCLog("create fairyView")
                self:addChild(fairyView, 3)

                if teamSide == "left" then
                    fairyView:setPosition(cc.p(100, 90))
                else
                    fairyView:setPosition(cc.p(960 - 100, 90))
                end
            end
        end

        self:updateZOrder()
    end

    guardHint:runAction(cc.Sequence:create({
        cc.MoveTo:create(0.5, cc.p(display.cx, display.cy)),
        cc.DelayTime:create(2),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function() 
            self:resumeBattle() 
            showFriend()
        end),
        cc.RemoveSelf:create(),
    }))   
end

function BattleController:onTimerStart()
    if self.timerPanel then
        self.timerPanel:setVisible(true)
    end
end

function BattleController:onTimerEnd()
    if self.timerPanel then
        self.timerPanel:setVisible(false)
    end
end

function BattleController:moveToBattleground()
    local useTime = BattleConfig.ENTRANCE_TIME / BattleConfig.SPEED_RATIO

    local function heroWalk()
--        local endPercent = self.battleModel.roundIndex * 0.33
--        local timeUnit = BattleConfig.TIME_UNIT
--
--        local action = nil
--        action = cc.RepeatForever:create(cc.Sequence:create({
--            cc.DelayTime:create(timeUnit),
--            cc.CallFunc:create(function()
--                local percent = self.mapMgr:getPercentHorizontal()
--                CCLog(vardump({percent, endPercent}, "scroll map"))
--                if percent >= endPercent then
--                    self.battleModel:setState("fight")
--                    self:stopAction(action)
--                end
--            end),
--        }))
--        self:runAction(action)

        if self.mapMgr:isHorizontal() then
            for idx, heroModel in ipairs(self.battleModel.leftTeam:getAliveHeroModels()) do
                --local heroView = self:getFighterView(heroModel:getFighterID())
                --heroView:walk(true)
                heroModel:setState("walk")
                local team = heroModel:getTeam()
                local heroView = self:getFighterView(heroModel:getFighterID())
                local cell = team:getHeroRawCell(heroModel)
                local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
                heroModel:setCell(cell)
                heroView:stopAllActions()
                heroView:setDirection(heroModel:getDirection())
                heroView:runAction(cc.MoveTo:create(useTime,  _PPOS(pos)))
                heroView:walk()
            end
        else
            if self.battleModel.roundIndex > 1 then
            local cloudAni = load_animation("res/image/spine/skill_effect/bigcloud/", 1, BattleConfig.SPEED_RATIO)
                if cloudAni then
                    cloudAni:setAnimation(0, "animation", true)
                    cloudAni:setName("cloud_aircraft")
                    cloudAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
                    cloudAni:setPosition(_PPOS(BattleConfig.getCellPos(4, 1)))
                    self.battleNode:addChild(cloudAni)
                end

                for idx, heroModel in ipairs(self.battleModel.leftTeam:getAliveHeroModels()) do
                    --local heroView = self:getFighterView(heroModel:getFighterID())
                    --heroView:walk(true)
                    heroModel:setState("ready")
                    local team = heroModel:getTeam()
                    local heroView = self:getFighterView(heroModel:getFighterID())
                    local cell = team:getHeroRawCell(heroModel)
                    local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
                    heroModel:setCell(cell)
                    heroView:relineup(_PPOS(pos))
                    heroView:ready()
                end
            end
        end
    end

--    local function heroReady()
--        for idx, heroModel in ipairs(self.battleModel.leftTeam:getAliveHeroModels()) do
--            local heroView = self:getHeroViewByModel(heroModel)
--            heroModel:onBattleRoundStart()
--            --heroView:ready()
--        end
--    end

    heroWalk()

--    self:runAction(cc.Sequence:create({
--        cc.DelayTime:create(useTime),
--        cc.CallFunc:create(function()
--            self:lineupEnemy(self.battleModel.roundIndex)
--        end),
--    }))

--    self:runAction(cc.Sequence:create({
--        cc.DelayTime:create(useTime),
--        cc.CallFunc:create(function()
--            self.battleModel:onBattleRoundStart()
--        end),
--    }))
end

function BattleController:onBattleEvent(name, data)
    CCLog(vardump({name = name, data = data}, "BattleController:onBattleEvent"))
    self.battleModel:onEvent(name, data)
end

function BattleController:onCleanEvent(method, event)
    if method then
        local eventName = event:getEventName()
        local eventData = event.data
        method(self, eventName, eventData)
    end
end

function BattleController:onEvent(method, event)
    local eventName = event:getEventName()
    local eventData = event.data

    if method then
        self:onBattleEvent(eventName, eventData)
        method(self, eventName, eventData)
    else
        CCLog(eventName, "has no handler")
    end
end

function BattleController:registerBattleHandler()
    self:addEventListener(AppEvent.UI.Battle.Wait,                        handler(self, self.onEvent, self.onWait))
    self:addEventListener(AppEvent.UI.Battle.Match,                       handler(self, self.onEvent, self.onMatch))
    self:addEventListener(AppEvent.UI.Battle.MoveBy,                      handler(self, self.onEvent, self.onMoveBy))
    self:addEventListener(AppEvent.UI.Battle.AttackScopeChange,           handler(self, self.onEvent, self.onAttackScopeChange))
    self:addEventListener(AppEvent.UI.Battle.AttackBegin,                 handler(self, self.onEvent, self.onAttackBegin))
    self:addEventListener(AppEvent.UI.Battle.AttackComplete,              handler(self, self.onEvent, self.onAttackComplete))
    self:addEventListener(AppEvent.UI.Battle.AttackBreakOff,              handler(self, self.onEvent, self.onAttackBreakOff))
    self:addEventListener(AppEvent.UI.Battle.AttackInterval,              handler(self, self.onEvent, self.onAttackInterval))
    self:addEventListener(AppEvent.UI.Battle.Hit,                         handler(self, self.onEvent, self.onHit))
    self:addEventListener(AppEvent.UI.Battle.MISS,                        handler(self, self.onEvent, self.onHeroMiss))
    self:addEventListener(AppEvent.UI.Battle.CRIT,                        handler(self, self.onEvent, self.onHeroCrit))
    self:addEventListener(AppEvent.UI.Battle.RegionRageSkill,             handler(self, self.onEvent, self.onRegionRageSkill))
    self:addEventListener(AppEvent.UI.Battle.HeroChoiceRageSkill,         handler(self, self.onEvent, self.onHeroChoiceRageSkill))
    self:addEventListener(AppEvent.UI.Battle.HeroStateChange,             handler(self, self.onEvent, self.onHeroStateChange))
    self:addEventListener(AppEvent.UI.Battle.HPChange,                    handler(self, self.onEvent, self.onHPChange))
    self:addEventListener(AppEvent.UI.Battle.FighterDie,                  handler(self, self.onEvent, self.onFighterDie))
    self:addEventListener(AppEvent.UI.Battle.FighterExpired,              handler(self, self.onEvent, self.onFighterExpired))
    self:addEventListener(AppEvent.UI.Battle.HeroStuck,                   handler(self, self.onEvent, self.onHeroStuck))
    self:addEventListener(AppEvent.UI.Battle.BattleStateChange,           handler(self, self.onEvent, self.onBattleStateChange))
    self:addEventListener(AppEvent.UI.Battle.HeroDirectionChange,         handler(self, self.onEvent, self.onHeroDirectionChange))
    self:addEventListener(AppEvent.UI.Battle.BuffAdded,                   handler(self, self.onEvent, self.onHeroBuffAdded))
    self:addEventListener(AppEvent.UI.Battle.BuffRemoved,                 handler(self, self.onEvent, self.onHeroBuffRemoved))
    self:addEventListener(AppEvent.UI.Battle.BuffReplaced,                handler(self, self.onEvent, self.onHeroBuffReplaced))
    self:addEventListener(AppEvent.UI.Battle.RageChanged,                 handler(self, self.onEvent, self.onTeamRageChanged))
    self:addEventListener(AppEvent.UI.Battle.RageComboHit,                handler(self, self.onEvent, self.onTeamComboHit))
    self:addEventListener(AppEvent.UI.Battle.TeamLineup,                  handler(self, self.onEvent, self.onTeamLineup))
    self:addEventListener(AppEvent.UI.Battle.HeroLineup,                  handler(self, self.onEvent, self.onHeroLineup))
    self:addEventListener(AppEvent.UI.Battle.HeroRelineup,                handler(self, self.onEvent, self.onHeroRelineup))
    self:addEventListener(AppEvent.UI.Battle.TeamRelineup,                handler(self, self.onEvent, self.onTeamRelineup))
    self:addEventListener(AppEvent.UI.Battle.RegionRageSkillDrop,         handler(self, self.onEvent, self.onRegionRageSkillDrop))
    self:addEventListener(AppEvent.UI.Battle.RegionRageSkillCancel,       handler(self, self.onEvent, self.onRegionRageSkillCancel))
    self:addEventListener(AppEvent.UI.Battle.Kill,                        handler(self, self.onEvent, self.onHeroKill))
    self:addEventListener(AppEvent.UI.Battle.Timeout,                     handler(self, self.onEvent, self.onBattleTimeout))

    self:addEventListener(AppEvent.UI.Battle.FollowMagicCircleAdded,      handler(self, self.onEvent, self.onFollowMagicCircleAdded))
    self:addEventListener(AppEvent.UI.Battle.FollowMagicCircleRemoved,    handler(self, self.onEvent, self.onFollowMagicCircleRemoved))
    self:addEventListener(AppEvent.UI.Battle.FixedMagicCircleAdded,       handler(self, self.onEvent, self.onFixedMagicCircleAdded))
    self:addEventListener(AppEvent.UI.Battle.FixedMagicCircleRemoved,     handler(self, self.onEvent, self.onFixedMagicCircleRemoved))

    self:addEventListener(AppEvent.UI.Battle.ContinuousSkillBegin,        handler(self, self.onEvent, self.onContinuousSkillBegin))
    self:addEventListener(AppEvent.UI.Battle.ContinuousSkillEnd,          handler(self, self.onEvent, self.onContinuousSkillEnd))

    self:addEventListener(AppEvent.UI.Battle.AITriggered,                 handler(self, self.onEvent, self.onAITriggered))
    self:addEventListener(AppEvent.UI.Battle.TrapSkill,                   handler(self, self.onEvent, self.onTrapSkill))

    self:addEventListener(AppEvent.UI.Battle.TrapAdded,                   handler(self, self.onEvent, self.onTrapAdded))
    self:addEventListener(AppEvent.UI.Battle.TrapRemoved,                 handler(self, self.onEvent, self.onTrapRemoved))

    self:addEventListener(AppEvent.UI.Battle.ObstacleAdded,               handler(self, self.onEvent, self.onObstacleAdded))
    self:addEventListener(AppEvent.UI.Battle.ObstacleRemoved,             handler(self, self.onEvent, self.onObstacleRemoved))

    self:addEventListener(AppEvent.UI.Battle.TurretAdded,                 handler(self, self.onEvent, self.onTurretAdded))

    self:addEventListener(AppEvent.UI.Battle.Resurrection,                handler(self, self.onEvent, self.onResurrection))
--    self:addEventListener(AppEvent.UI.Battle.Resurrecting,                handler(self, self.onEvent, self.onResurrecting))

    self:addEventListener(AppEvent.UI.Battle.HitBuffAffect,               handler(self, self.onEvent, self.onHitBuffAffect))
    self:addEventListener(AppEvent.UI.Battle.Treated,                     handler(self, self.onEvent, self.onHeroTreated))
    self:addEventListener(AppEvent.UI.Battle.FairyCool,                   handler(self, self.onEvent, self.onFairyCool))

    self:addEventListener(AppEvent.UI.Battle.Knockedback,                 handler(self, self.onEvent, self.onKnockedback))
    self:addEventListener(AppEvent.UI.Battle.Suction,                     handler(self, self.onEvent, self.onSuction))
    self:addEventListener(AppEvent.UI.Battle.Immune,                      handler(self, self.onEvent, self.onImmune))
    self:addEventListener(AppEvent.UI.Battle.RandomDialogue,              handler(self, self.onEvent, self.onRandomDialogue))
    self:addEventListener(AppEvent.UI.Battle.Dialogue,                    handler(self, self.onEvent, self.onDialogue))
    self:addEventListener(AppEvent.UI.Battle.MonsterSkill,                handler(self, self.onEvent, self.onMonsterSkill))
    self:addEventListener(AppEvent.UI.Battle.Summoning,                   handler(self, self.onEvent, self.onSummoning))
    self:addEventListener(AppEvent.UI.Battle.SummonTarget,                handler(self, self.onEvent, self.onSummonTarget))
    self:addEventListener(AppEvent.UI.Battle.Replication,                 handler(self, self.onEvent, self.onReplication))
    self:addEventListener(AppEvent.UI.Battle.HeroCellChanged,             handler(self, self.onEvent, self.onHeroCellChanged))
    self:addEventListener(AppEvent.UI.Battle.RemoveFixedMagicCircle,      handler(self, self.onEvent, self.onRemoveFixedMagicCircle))
    self:addEventListener(AppEvent.UI.Battle.ResurrectionMonster,         handler(self, self.onEvent, self.onResurrectionMonster))
    self:addEventListener(AppEvent.UI.Battle.TurnIntoEgg,                 handler(self, self.onEvent, self.onTurnIntoEgg))
    self:addEventListener(AppEvent.UI.Battle.EggExpired,                  handler(self, self.onEvent, self.onEggExpired))
    self:addEventListener(AppEvent.UI.Battle.TrapSkill,                   handler(self, self.onEvent, self.onTrapSkill))
    self:addEventListener(AppEvent.UI.Battle.ProtectByturret,             handler(self, self.onEvent, self.onProtectByturret))
    self:addEventListener(AppEvent.UI.Battle.LoseProtectionOfTurret,      handler(self, self.onEvent, self.onLoseProtectionOfTurret))
    self:addEventListener(AppEvent.UI.Battle.SetHeroPos,                  handler(self, self.onCleanEvent, self.onSetHeroPos))
    self:addEventListener(AppEvent.UI.Battle.FairyCoolPercentChange,      handler(self, self.onCleanEvent, self.onFairyCoolPercentChange))
    self:addEventListener(AppEvent.UI.Battle.FairySkillCommand,           handler(self, self.onCleanEvent, self.onFairySkillCommand))
    self:addEventListener(AppEvent.UI.Battle.FriendGuard,                 handler(self, self.onCleanEvent, self.onFriendGuard))
    self:addEventListener(AppEvent.UI.Battle.TimerStart,                  handler(self, self.onCleanEvent, self.onTimerStart))
    self:addEventListener(AppEvent.UI.Battle.TimerEnd,                    handler(self, self.onCleanEvent, self.onTimerEnd))
    self:addEventListener(AppEvent.UI.Battle.TeleportToCell,              handler(self, self.onCleanEvent, self.onTeleportToCell))
    self:addEventListener(AppEvent.UI.Battle.Transfiguration,             handler(self, self.onCleanEvent, self.onTransfiguration))
    
    
end

function BattleController:onEnter()
    CCLog("BattleController:onEnter()")
end

function BattleController:onExit()
    CCLog("BattleController:onExit()")
    self:stopBackgroundMusic()

    self:unscheduleUpdate()
end

function BattleController:onCleanup()
    CCLog("BattleController:onCleanup()")
    self:unscheduleUpdate()

    if self.dispatcher then
        self.dispatcher:removeAllEventListeners()
        self.dispatcher:release()
        self.dispatcher = nil
    end

    self.battleModel:cleanup()

    cc.FileUtils:getInstance():traceCacheFileInfo()
    cc.FileUtils:getInstance():enableCacheFileData(false)
end

function BattleController:onEnterTransitionFinish()
    Common.OpenGuideLayer( { 3} )
end

function BattleController:onExitTransitionStart()

end

function BattleController:start()
    self:scheduleUpdate()

    self.battleModel:start()
end

function BattleController:started()
    self.battleModel:started()

    self:playBackgroundMusic()
end

function BattleController:unschedulePreload()
    if self.preloadScheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        CCLog("scheduler:unschedulePreload(", self.preloadScheduleEntryID, ")")
        scheduler:unscheduleScriptEntry(self.preloadScheduleEntryID)
        self.preloadScheduleEntryID = nil
    end
end

function BattleController:schedulePreload()
    if tolua.isnull(self) then
        CCLog(debug.traceback())
        return
    end

    local scheduler = cc.Director:getInstance():getScheduler()

    if self.preloadScheduleEntryID ~= nil then
        self:unschedulePreload()
    end

    local updateFunc = function()
        local ok, err = coroutine.resume(self._preload_thread)
        if not ok then
            print("schedulePreload error:", err)
            self:unschedulePreload()
        end
    end

    local preloadScheduleEntryID = scheduler:scheduleScriptFunc(updateFunc, 1.0 / 60, false)
    self.preloadScheduleEntryID = preloadScheduleEntryID
    CCLog("scheduler:schedulePreload(", self.preloadScheduleEntryID, ")")
end

function BattleController:unscheduleUpdate()
    if self.scheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        CCLog("scheduler:unscheduleScriptEntry(", self.scheduleEntryID, ")")
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end
end

function BattleController:scheduleUpdate()
    if tolua.isnull(self) then
        CCLog(debug.traceback())
        return
    end

    local scheduler = cc.Director:getInstance():getScheduler()

    if self.scheduleEntryID ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end

    local updateFunc = function()
        local func = handler(self, self.onUpdate)
        xpcall(func, __G__TRACKBACK__)
    end

    local scheduleEntryID = scheduler:scheduleScriptFunc(updateFunc, BattleConfig.TIME_UNIT / BattleConfig.SPEED_RATIO, false)
    self.scheduleEntryID = scheduleEntryID
end

function BattleController:genHeroZOrder(fighter)
    if fighter then
        local cell = fighter:getCell()
        local dir = fighter:getDirection()

        return BattleUtils.getCellZOrder(cell, dir)
    end

    return 0
end

function BattleController:updateZOrder()
    -- 更新ZOrder
    if self.inRageAttacking then
        return
    end
    
    local heroViews = self:getAliveHeroViews("left", true)
    for i, view in ipairs(heroViews) do
        if view == nil or tolua.isnull(view) then
            CCLog("view is null")
        else
            local posY = view:getPositionY()
            view:setLocalZOrder(display.height - posY)
        end
    end

    local enemyViews = self:getAliveHeroViews("right", true)
    for i, view in ipairs(enemyViews) do
        if view == nil or tolua.isnull(view) then
            CCLog("view is null")
        else
            local posY = view:getPositionY()
            view:setLocalZOrder(display.height - posY)
        end
    end

--    local obstacleViews = self.battleModel.gameObstacle:getObstacleViews()
--    for _, obstacleView in ipairs(obstacleViews) do
--        local cell = obstacleView:getCell()
--        obstacleView:setLocalZOrder((5 - cell.y + 1) * 10000)
--    end
end

function BattleController:addCoroutine(action)
    table.insert(self.threadList, coroutine.create(action))
end

function BattleController:updateThreadList()
    local count = #self.threadList
    for i = count, 1, -1 do
        local thread = self.threadList[i]
        coroutine.resume(thread)

        if coroutine.status(thread) == "dead" then
            table.remove(self.threadList, i)
        end
    end
end

function BattleController:onUpdate(delta)
    if BattleConfig.RAGE_SKILL_PAUSE and self.inRageAttacking then
        return
    end

    if #self.rageAttackDataList > 0 then
        local attackData = table.remove(self.rageAttackDataList, 1)
        self:onRageAttackBegin(attackData)
        return
    end

    --self:updateThreadList()

    if not self.battleModel:isPaused() then
        local st = os.clock()

        self.battleModel:update(self)
        self:updateTimeLabel()
        self:updateTimerLabel()
        self:updateCDBar()

        local state = self.battleModel:getState()
        if state == "entrance" then
            local endPercent = self.mapMgr:getRoundOffsetPercent(self.battleModel.roundIndex)

            -- if self.params.battleType == "GUIDE" then
            --     self.mapMgr:scrollToPercent(endPercent * 100, 1.0 / 60)
            --     self.battleModel:setState("fight")
            -- else
                local percent = self.mapMgr:getPercent()
                --CCLog("cur map percent:", percent)

                if percent and (percent + (map_inc_percent / 100.0) < endPercent) then
                    self:scrollMap()
                    self:updateZOrder()
                else                
                    local beginStoryID = self.battleModel:getCurRoundXXXStory()
                    if beginStoryID and beginStoryID ~= 0 then
                        CCLog("start begin story")
                        local callback = function()
                            self.battleModel:setState("fight")
                            self.foregroundNode:setVisible(true)
                            self.battleNode:setVisible(true)
                        end
                        local storyLayer = Common.CreateStoryLayer(beginStoryID, callback)
                        self:addChild(storyLayer, 5)
                        self.foregroundNode:setVisible(false)
                        self.battleNode:setVisible(false)
                    else
                        self.battleModel:setState("fight")
                    end                    
                end
            -- end
        elseif state == "fight"  then
            if self.battleModel:isAutoBattle() then
                local leftTeam = self.battleModel.leftTeam
                if  leftTeam:getRage() == 100 then
                    self:checkAutoBattle("left")
                end
            end
            
            local rightTeam = self.battleModel.rightTeam
            if  rightTeam:getRage() == 100 then
                self:checkAutoBattle("right")
            end
        end

        --printf("BattleController:onUpdate use time:%.07f", os.clock() - st)
    end
end

function BattleController:scrollMap()
    local nextPercent = self.mapPercentPos + map_inc_percent

    self.mapPercentPos = nextPercent
    self.mapMgr:scrollToPercent(nextPercent, BattleConfig.TIME_UNIT)
end

-- 我军布阵
function BattleController:lineupHero(roundIndex)
    if roundIndex == 1 then
        self.battleModel.leftTeam:lineup(self.battleModel:getAttackerForm(), self.battleModel)
    else
        self.battleModel.leftTeam:relineup(self.battleModel)
    end
end

local scope_1_colors = {cc.c4f(1, 0, 0, 0.5), cc.c4f(0, 1, 0, 0.5), cc.c4f(0, 0, 1, 0.5), cc.c4f(1, 1, 0, 0.5), cc.c4f(0, 1, 1, 0.5) }
local scope_2_colors = {cc.c4f(1, 1, 1, 0.5), cc.c4f(1, 1, 0, 0.5), cc.c4f(1, 0, 1, 0.5), cc.c4f(0, 1, 1, 0.5), cc.c4f(0, 0, 0, 0.5) }
local line_1_colors = {cc.c4f(1, 0, 0, 1), cc.c4f(0, 1, 0, 1), cc.c4f(0, 0, 1, 1), cc.c4f(1, 1, 0, 1), cc.c4f(0, 1, 1, 1) }
local line_2_colors = {cc.c4f(1, 1, 1, 1), cc.c4f(1, 1, 0, 1), cc.c4f(1, 0, 1, 1), cc.c4f(0, 1, 1, 1), cc.c4f(0, 0, 0, 1) }

function BattleController:onRegionRageSkillDragDrop(dragData)
    local attackData = dragData.data
    local heroModel = attackData:getHeroModel()

    local dragNode = dragData.dragNode
    local pos = BattleConfig.BPOS(dragData.pos)

    CCLog(vardump({pos = pos, area = dragData.area}, "drag scope area pos"))
    dragNode:removeFromParent()

    attackData:setDestPos(pos)
    local heroModel = attackData:getHeroModel()
    heroModel:setInRageScopeSelecting(false)
    CCLog("heroModel:setInRageScopeSelecting(false)", heroModel:getName())
    heroModel:doAttack(attackData)

    heroModel:getTeam():setRegionRageData(nil)

    self.regionSkillShadow:setVisible(false)

    local fighterID = heroModel:getFighterID()
    local skillRegionNode = self.fighterRegionNodeMap[fighterID]
    if skillRegionNode and not tolua.isnull(skillRegionNode) then
        skillRegionNode:removeFromParent()
    end
    self.fighterRegionNodeMap[fighterID] = nil

    local skillAreaNode = self.fighterAreaNodeMap[fighterID]
    if skillAreaNode and not tolua.isnull(skillAreaNode) then
        skillAreaNode:removeFromParent()
    end
    self.fighterAreaNodeMap[fighterID] = nil

    self:clearHeroRageScopeHighlight()

    self:dispatchEvent(AppEvent.UI.Battle.RegionRageSkillDrop)

    self:resumeBattle()
end

function BattleController:onRegionRageSkillDragCancel(dragData)
    local attackData = dragData.data

    local heroModel = attackData:getHeroModel()
    heroModel:setInRageScopeSelecting(false)

    heroModel:getTeam():setRegionRageData(nil)

    CCLog("heroModel:setInRageScopeSelecting(false)", heroModel:getName())
    self.regionSkillShadow:setVisible(false)

    local fighterID = heroModel:getFighterID()
    local skillRegionNode = self.fighterRegionNodeMap[fighterID]
    if skillRegionNode and not tolua.isnull(skillRegionNode) then
        skillRegionNode:removeFromParent()
    end
    self.fighterRegionNodeMap[fighterID] = nil

    local skillAreaNode = self.fighterAreaNodeMap[fighterID]
    if skillAreaNode and not tolua.isnull(skillAreaNode) then
        skillAreaNode:removeFromParent()
    end
    self.fighterAreaNodeMap[fighterID] = nil

    self:clearHeroRageScopeHighlight()

    self:dispatchEvent(AppEvent.UI.Battle.RegionRageSkillCancel)
    self.controlPanel:refresh()

    self:resumeBattle()

    if self.params.battleType == "GUIDE" then
        if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
            CCLog("GUIDE: 猪八戒取消")
            --self.battleModel.guideStepInfo.open[1] = false

            self:resumeBattle()
            self:pauseBattle()

            Common.ResetGuideLayer( { big = 1, small = 6 } )
            Common.OpenGuideLayer( { 1} )       
        elseif self.battleModel.guideStepInfo.step == 3  and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
            CCLog("GUIDE: 唐僧取消")
            --self.battleModel.guideStepInfo.open[1] = false

            self:resumeBattle()
            self:pauseBattle()

            Common.ResetGuideLayer( { big = 1, small = 10 } )
            Common.OpenGuideLayer( { 1} )    
            --self.battleModel.guideStepInfo.open[1] = true        
        end

        if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 1 then
            CCLog("GUIDE: 猪八戒取消")
            --self.battleModel.guideStepInfo.open[2] = false

            self:resumeBattle()
            self:pauseBattle()

            Common.ResetGuideLayer( { big = 2, small = 4 } )
            Common.OpenGuideLayer( { 2} )    
            --self.battleModel.guideStepInfo.open[2] = true                
        end

        -- if self.battleModel.guideStepInfo.step == 2 and self.battleModel.guideStepInfo.open[2] and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 2 then
        --     CCLog("GUIDE: 猪八戒取消")
        --     --self.battleModel.guideStepInfo.open[2] = false

        --     self:resumeBattle()
        --     self:pauseBattle()

        --     Common.ResetGuideLayer( { big = 2, small = 7 } )
        --     Common.OpenGuideLayer( { 2} )    
        --     --self.battleModel.guideStepInfo.open[2] = true                
        -- end
        -- if self.battleModel.guideStepInfo.step == 3 and self.battleModel.guideStepInfo.open[2] and GameCache.NewbieGuide.Step == 0 and self.battleModel.roundIndex == 2 then
        --     CCLog("GUIDE: 吕洞宾取消")
        --     --self.battleModel.guideStepInfo.open[3] = false

        --     self:resumeBattle()
        --     self:pauseBattle()
            
        --     Common.ResetGuideLayer( { big = 0, small = 7 } )
        --     Common.OpenGuideLayer( { 0} )      
        --     --self.battleModel.guideStepInfo.open[3] = true              
        -- end
    end
end

-- 取消怒气技能范围内的英雄高亮
function BattleController:clearHeroRageScopeHighlight()
    -- if resumeAnimation then
    --     self:resumeBattleAnimation()
    -- end

    for fighterID, fighterView in pairs(self.fighterViewMap) do
        if not tolua.isnull(fighterView) and fighterView.inAttackScope then
            fighterView:inAttackScope(false)
        end
    end


--    local heroViews = self:getAliveHeroViews("left")
--    for _, heroView in ipairs(heroViews) do
--        if heroView and not tolua.isnull(heroView) then
--            heroView:inAttackScope(false)
--        end
--    end
--
--    local heroViews = self:getAliveHeroViews("right")
--    for _, heroView in ipairs(heroViews) do
--        if heroView and not tolua.isnull(heroView) then
--            heroView:inAttackScope(false)
--        end
--    end
--
--    local trapList = self.battleModel.gameTrap:getAllTrapList()
--    for _, trap in ipairs(trapList) do
--        local view = self:getFighterView(trap:getFighterID())
--        if view and not tolua.isnull(view) then
--            view:inAttackScope(false)
--        end
--    end
end

function BattleController:onRegionScopeChange(pos, chgType, attackData)
    pos = BattleConfig.BPOS(pos)
    if chgType == "begin" then
        if self.params.battleType == "GUIDE" then
            if self.battleModel.guideStepInfo.step == 1 and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
                Common.CloseGuideLayer({1})
                Common.OpenGuideLayer({1})
                CCLog("GUIDE: 猪八戒范围拖动")
            -- elseif self.battleModel.guideStepInfo.step == 3 and GameCache.NewbieGuide.Step == 1 and self.battleModel.roundIndex == 1 then
                -- Common.CloseGuideLayer({1})
                -- Common.OpenGuideLayer({1})
                -- CCLog("GUIDE: 唐僧范围拖动")
            end


            if self.battleModel.guideStepInfo.step == 1  and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 1 then
                Common.CloseGuideLayer({2})
                Common.OpenGuideLayer({2})
                CCLog("GUIDE: 猪八戒范围拖动")
            end

            -- if self.battleModel.guideStepInfo.step == 2 and self.battleModel.guideStepInfo.open[2] and GameCache.NewbieGuide.Step == 2 and self.battleModel.roundIndex == 2 then
            --     Common.CloseGuideLayer({2})
            --     Common.OpenGuideLayer({2})
            --     CCLog("GUIDE: 猪八戒范围拖动")
            -- end
            -- if self.battleModel.guideStepInfo.step == 3 and self.battleModel.guideStepInfo.open[3] and GameCache.NewbieGuide.Step == 0 and self.battleModel.roundIndex == 2 then
            --     Common.CloseGuideLayer({0})
            --     Common.OpenGuideLayer({0})
            --     CCLog("GUIDE: 吕洞宾范围拖动")
            -- end
        end
    end      

    attackData:setDestPos(pos)
    self:clearHeroRageScopeHighlight()

    local targetHeroList = attackData:calcHeroTargetFighterList()
    for _, heroModel in ipairs(targetHeroList) do
        CCLog(heroModel:getName(), "in selecting")
        local heroView = self:getFighterView(heroModel:getFighterID())
        if heroView and not tolua.isnull(heroView) then
            heroView:inAttackScope(true, attackData:targetIsTeammate())
        end
    end
end

function BattleController:doneRegionSelection(heroModel)
--    local rageSkillInfo = self.regionRageSkill
--    if rageSkillInfo then
--        rageSkillInfo.dragScopeNode:done()
--        return true
--    end

    if heroModel then
        local team = heroModel:getTeam()
        local regionRageData = team:getRegionRageData()
        if regionRageData ~= nil then
            local fighterID = heroModel:getFighterID()
            local areaNode = self.fighterAreaNodeMap[fighterID]
            if areaNode and not tolua.isnull(areaNode) then
                areaNode:done()
            end
        end
    end

    return false
end

function BattleController:createRegionRageView(attackData)
    CCLog("BattleController:createRegionRageView")
    local heroModel = attackData:getHeroModel()
    if heroModel:isAlive() then
        local battleModel = self.battleModel

        local cell = heroModel:getCell()
        local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)
        local fighterID = heroModel:getFighterID()

        local skillRegionNode = self.fighterRegionNodeMap[fighterID]
        if skillRegionNode and not tolua.isnull(skillRegionNode) then
            skillRegionNode:removeFromParent()
        end

        local skillData = attackData.skillData
        local area = attackData:skillArea():clone()
        local isTeammate = attackData:targetIsTeammate()

        local skillRegionNode = SkillRegionNode.new()        
        local regionRect = attackData:absRegionRect()
        skillRegionNode:setScaleX(POS_RATIO_X)
        skillRegionNode:setScaleY(POS_RATIO_Y)
        skillRegionNode:setRect(regionRect)
        self.battleNode:addChild(skillRegionNode)

        local skillAreaNode = self.fighterAreaNodeMap[fighterID]
        if skillAreaNode and not tolua.isnull(skillAreaNode) then
            skillAreaNode:removeFromParent()
        end

        local skillAreaNode = SkillAreaNode.new(skillData, cell, attackData:getRegionCenterCell(), heroModel:getDirection(), area, regionRect, battleModel, isTeammate)
        skillAreaNode:setScaleX(POS_RATIO_X)
        skillAreaNode:setScaleY(POS_RATIO_Y)

        local stencil = SkillRegionNode.new()                
        stencil:setScaleX(POS_RATIO_X)
        stencil:setScaleY(POS_RATIO_Y)
        stencil:setRect(regionRect)

        local clippingNode = cc.ClippingNode:create()
        clippingNode:setInverted(false)
        clippingNode:setAlphaThreshold(0)
        clippingNode:setStencil(stencil)
        self.battleNode:addChild(clippingNode)
        clippingNode:addChild(skillAreaNode)

        local shadowStencil = SkillRegionNode.new()                
        shadowStencil:setScaleX(POS_RATIO_X)
        shadowStencil:setScaleY(POS_RATIO_Y)
        shadowStencil:setRect(regionRect)

        local shadowSkillAreaNode = SkillAreaNode.new(skillData, cell, attackData:getRegionCenterCell(), heroModel:getDirection(), area, regionRect, battleModel, isTeammate, true)
        shadowSkillAreaNode:setScaleX(POS_RATIO_X)
        shadowSkillAreaNode:setScaleY(POS_RATIO_Y)
        shadowSkillAreaNode:setCascadeOpacityEnabled(true)
        shadowSkillAreaNode:setOpacity(50)

        local shadowClippingNode = cc.ClippingNode:create()
        shadowClippingNode:setInverted(true)
        shadowClippingNode:setAlphaThreshold(0)
        shadowClippingNode:setStencil(shadowStencil)
        self.battleNode:addChild(shadowClippingNode)
        shadowClippingNode:addChild(shadowSkillAreaNode)

        local function onRegionScopeChange(pos, chgType, attackData)
            self:onRegionScopeChange(pos, chgType, attackData)

            if chgType == "move" then
                shadowSkillAreaNode:setPosition(pos)            
            end
        end

        local function onSkillAreaNodeCleanup()
            self:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                     clippingNode:removeFromParent() 
                     shadowClippingNode:removeFromParent()
                end),
            }))        
        end

        skillAreaNode:setCallback(
            handler(self, self.onRegionRageSkillDragDrop),
            handler(self, self.onRegionRageSkillDragCancel),
            onRegionScopeChange,
            onSkillAreaNodeCleanup,
            attackData
        )       

        self.fighterRegionNodeMap[fighterID] = skillRegionNode
        self.fighterAreaNodeMap[fighterID] = skillAreaNode
        CCLog(vardump({cell = cell, pos = cc.p(skillAreaNode:getPosition()), opos = pos}, "dragNode"))
    else
        CCLog(hero:getName(), "已经死亡")
    end
end

local DRAW_MATH_LINE = false -- 画配对线
function BattleController:drawAttackScope()
    if self.regionRageSkill ~= nil then
        local rageSkillInfo = self.regionRageSkill
        local attackData = rageSkillInfo.attackData

        local heroModel = attackData:getHeroModel()
        if heroModel:isAlive() then
            local battleModel = self.battleModel

            local cell = heroModel:getCell()
            local pos = BattleConfig.getHeroCellPos(cell.x, cell.y)

            local regionRect = attackData:absRegionRect()


            if rageSkillInfo.dragScopeNode == nil then
                --local enemy = heroModel:getMatchedEnemy()
                local skillData = attackData.skillData
                local area = attackData:skillArea():clone()
                local isTeammate = attackData:targetIsTeammate()
                --local scopeDragNode = ScopeDragNode.new(cell, attackData:getRegionCenterCell(), heroModel:getDirection(), area, regionRect, battleModel, isTeammate)
                local skillRegionNode = SkillRegionNode.new()
                self.battleNode:addChild(skillRegionNode)
                skillRegionNode:setRect(regionRect)

                local skillAreaNode = SkillAreaNode.new(skillData, cell, attackData:getRegionCenterCell(), heroModel:getDirection(), area, regionRect, battleModel, isTeammate)

--                local stencil = SkillRegionNode.new(regionRect)
--                stencil:setRect(regionRect)
--
--                local clippingNode = cc.ClippingNode:create()
--                clippingNode:setInverted(false)
--                clippingNode:setAlphaThreshold(0.5)
--                clippingNode:setStencil(stencil)
--
                skillAreaNode:setCallback(
                    handler(self, self.onRegionRageSkillDragDrop),
                    handler(self, self.onRegionRageSkillDragCancel),
                    handler(self, self.onRegionScopeChange),
                    nil,
                    attackData                )
--
--                -- TODO: 斜20 self.foregroundNode:addChild(scopeDragNode)
--
--                clippingNode:addChild(skillAreaNode)
--                self.battleNode:addChild(clippingNode)

                self.battleNode:addChild(skillAreaNode)
                rageSkillInfo.skillRegionNode = skillRegionNode
                rageSkillInfo.dragScopeNode = skillAreaNode

                CCLog(vardump({cell = cell, pos = cc.p(skillAreaNode:getPosition()), opos = pos}, "dragNode"))
            else
                rageSkillInfo.dragScopeNode:updateHeroCell(cell, regionRect)
            end
        else
            self:clearRegionRageSkill(nil)
        end
    end
end

-- TODO:掉落用
function BattleController:lose(goodsTabs, enemyPos, callFunc)
    local xRandTab = {}
    for i=1,table.nums(goodsTabs) do
        table.insert(xRandTab, i)
    end

    self.xHeightTab = {}
    self.loseTab = {}
    for k,v in pairs(goodsTabs) do
        -- if v.Type ~= 4 then
            local s = Common.getGoods(v, false, 2)
            s:setPosition(enemyPos.x, enemyPos.y)
            self:addChild(s, 10)
            s:setScale(0)
            s:setTouchEnable(false)
            table.insert(self.loseTab, s)

            local rad = self.battleModel:random(1, #xRandTab)
            local x = xRandTab[rad] * SCREEN_WIDTH * 0.15
            table.remove(xRandTab, rad)
            local xHeight = {}
            xHeight.x = x
            local yValue = self.battleModel:random(1, 6)
            xHeight.y = SCREEN_HEIGHT * 0.38 - 20 * yValue
            xHeight.height = SCREEN_HEIGHT * 0.5
            table.insert(self.xHeightTab, xHeight)
        -- end
    end

    local function loseAction()
        for k,v in ipairs(self.loseTab) do
            local inDelay = cc.DelayTime:create(0.1 * (k - 1))
            local inTime = 0.4
            local inJump = cc.JumpTo:create(inTime, cc.p(self.xHeightTab[k].x, self.xHeightTab[k].y), self.xHeightTab[k].height, 1)
            local inScale = cc.ScaleTo:create(inTime, 1)
            local inSpawn = cc.Spawn:create(inJump, inScale)
            local inSequence = cc.Sequence:create(inDelay, inSpawn)

            local jump1 = cc.JumpTo:create(0.4, cc.p(self.xHeightTab[k].x, self.xHeightTab[k].y), 60, 2)
            local delay = cc.DelayTime:create(1)

            local eludeAction = nil
            local actionNum = self.battleModel:random(1, 3)
            if actionNum == 1 then
                local move1 = cc.MoveBy:create(0.08, cc.p(-60, -120))
                local move2 = cc.MoveBy:create(0.06, cc.p(120, 240))
                local move3 = cc.MoveBy:create(0.06, cc.p(-40, -80))
                local move4 = cc.MoveBy:create(0.06, cc.p(120, 240))
                local move5 = cc.MoveBy:create(0.06, cc.p(-20, -60))
                eludeAction = cc.Sequence:create(move1, move2, move3, move4, move5)
            elseif actionNum == 2 then
                local move1 = cc.MoveBy:create(0.08, cc.p(-100, 0))
                local move2 = cc.MoveBy:create(0.08, cc.p(160, 0))
                local move3 = cc.MoveBy:create(0.08, cc.p(-100, 0))
                local move4 = cc.MoveBy:create(0.06, cc.p(60, 0))
                local move5 = cc.MoveBy:create(0.06, cc.p(-80, 0))
                local move6 = cc.MoveBy:create(0.06, cc.p(60, 0))
                eludeAction = cc.Sequence:create(move1, move2, move3, move4, move5, move6)
            elseif actionNum == 3 then
                local move1 = cc.JumpBy:create(0.1, cc.p(-150, 20), 60, 1)
                local rotate1 = cc.RotateBy:create(0.1, -100)
                local spawn1 = cc.Spawn:create(move1, rotate1)
                local move2 = cc.JumpBy:create(0.1, cc.p(-80, 20), 60, 1)
                local rotate2 = cc.RotateBy:create(0.1, -60)
                local spawn2 = cc.Spawn:create(move2, rotate2)
                local move3 = cc.JumpBy:create(0.1, cc.p(-80, 20), 60, 1)
                local rotate3 = cc.RotateBy:create(0.1, -60)
                local spawn3 = cc.Spawn:create(move3, rotate3)
                local delay1 = cc.DelayTime:create(0.1)
                eludeAction = cc.Sequence:create(spawn1, delay1:clone(), spawn2, delay1:clone(), spawn3)
            end

            local flyTime = 0.3
            local flyMove = cc.MoveTo:create(flyTime, cc.p(SCREEN_WIDTH * 0.9, SCREEN_HEIGHT * 0.9))
            local flyScale = cc.ScaleTo:create(flyTime, 0)
            local flyRotate = cc.RotateBy:create(flyTime, 720)
            local flySpawn = cc.Spawn:create(flyMove, flyScale, flyRotate)
            local actCallFunc = nil
            if k == (#self.loseTab) then
                actCallFunc = cc.CallFunc:create(function()
                    callFunc()
                end)
            end
            v:runAction(cc.Sequence:create(inSequence, jump1, delay, eludeAction, flySpawn, actCallFunc))
        end
    end

    Common.playSound("res/audio/effect/hero_show.mp3", false)
    loseAction()
end

function BattleController:playFairyAnimation(fairyID)
    -- ("粉","绿","蓝","紫","蓝","黄","紫")
    local fairyAniMap = {
        [1001] = "pink",
        [1002] = "green",
        [1003] = "blue",
        [1004] = "pink",
        [1005] = "blue",
        [1006] = "yellow",
        [1007] = "pink",
    }
    local aniPath = "image/spine/fairy/animation/" .. fairyAniMap[fairyID] .. "/"

    local skillAni = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
    skillAni:setPosition(cc.p(SCREEN_WIDTH * 0.45, SCREEN_HEIGHT * 0.4))
    skillAni:setAnimation(0, "animation", false)
    skillAni:setLocalZOrder(0)
    skillAni:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.battleNode:addChild(skillAni, 99999)

    skillAni:registerSpineEventHandler(function(event)
        skillAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(1),
            cc.RemoveSelf:create(),
        }))
    end, sp.EventType.ANIMATION_END)
end

function BattleController:fairySkillAction(skillID, fairyID, endCallback)
    local fairyConfig = BaseConfig.GetFairy(fairyID)
    local soundStep1 = fairyConfig.sound0
    local soundStep2 = skillID == fairyConfig.Skill1 and fairyConfig.sound1 or fairyConfig.sound2

    Common.playSound(cc.FileUtils:getInstance():fullPathForFilename("audio/fairy/" .. soundStep1 .. ".mp3"), false)

    self:removeChildByName("fairySkill")
    local maskLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    self.middleMapNode:addChild(maskLayer, 0)

    local node = cc.Node:create()
    node:setName("fairySkill")
    node:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.battleNode:addChild(node, 99999)

    local skillRes = BaseConfig.GetHeroSkill(skillID, 1).Res
    local fairyRes = BaseConfig.GetFairy(fairyID).Res
    local fairySkillName = createMixSprite("image/ui/fairy/"..fairyRes.."_bg2.png",nil,"image/ui/fairy/"..skillRes.."_name.png")
    fairySkillName:setTouchEnable(false)
    fairySkillName:setChildPos(0.45, 0.5)
    fairySkillName:setPosition(-SCREEN_WIDTH * 0.65, SCREEN_HEIGHT * 0.4)
    node:addChild(fairySkillName)

    local fairyBg = cc.Sprite:create("image/ui/fairy/"..fairyRes.."_bg1.png")
    fairyBg:setPosition(-SCREEN_WIDTH * 0.45, SCREEN_HEIGHT * 0.4)
    node:addChild(fairyBg)
    local fairySpri = sp.SkeletonAnimation:create("image/spine/fairy/"..fairyID.."/skeleton.skel", "image/spine/fairy/"..fairyID.."/skeleton.atlas")
    fairySpri:setPosition(-SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.3)
    node:addChild(fairySpri)
    fairySpri:setAnimation(0, "idl_1", true)

    local stopTime = 0.2
    local actionTime = 0.4
    local delayTime = 0.2
    local allDelay = cc.DelayTime:create(actionTime + delayTime + stopTime)
    local stopDelay = cc.DelayTime:create(stopTime)
    local actionDelay = cc.DelayTime:create(actionTime)
    local delay1 = cc.DelayTime:create(0.05)
    local move1 = cc.MoveBy:create(0.05, cc.p(-80, 0))
    local move2 = cc.MoveBy:create(0.04, cc.p(130, 0))
    local move3 = cc.MoveBy:create(0.04, cc.p(-70, 0))
    local move4 = cc.MoveBy:create(0.04, cc.p(20, 0))
    local nameDelay = cc.DelayTime:create(delayTime)
    local nameMove = cc.MoveTo:create(actionTime, cc.p(SCREEN_WIDTH * 0.55, SCREEN_HEIGHT * 0.4))
    local nameMoveAction = cc.EaseBounceOut:create(nameMove)
    local soundAction = cc.CallFunc:create(function() Common.playSound(cc.FileUtils:getInstance():fullPathForFilename("audio/hero/" .. soundStep2 .. ".mp3"), false) end)
    local endTime = 0.08
    local endMove = cc.MoveTo:create(endTime, cc.p(SCREEN_WIDTH * 1.5, SCREEN_HEIGHT * 0.4))
    local endMoveAction = cc.EaseBackIn:create(endMove)
    local endFadeOut = cc.FadeOut:create(endTime)
    local endSpawn = cc.Spawn:create(endMoveAction, endFadeOut)
    local endSpawn1 = cc.Sequence:create(delay1:clone(), cc.ScaleTo:create(endTime, 1, 0))


    fairySkillName:runAction(cc.Sequence:create(nameDelay, nameMoveAction, soundAction))
    local bg = fairySkillName:getBg()
    local child = fairySkillName:getChild()
    bg:runAction(cc.Sequence:create(allDelay, endSpawn1))
    child:runAction(cc.Sequence:create(actionDelay, delay1, move1, move2, move3, move4,
        stopDelay, endSpawn1:clone()))

    local fairyDelay = cc.DelayTime:create(actionTime - delayTime)
    local fairyMove1 = cc.MoveTo:create(actionTime, cc.p(SCREEN_WIDTH * 0.35, SCREEN_HEIGHT * 0.4))
    local fairyMoveAction1 = cc.EaseBackOut:create(fairyMove1)
    local fairyMove2 = cc.MoveTo:create(actionTime, cc.p(SCREEN_WIDTH * 0.2, SCREEN_HEIGHT * 0.43))
    local fairyMoveAction2 = cc.EaseBackOut:create(fairyMove2)
    local maskLayerFunc = cc.CallFunc:create(function()
        local fadeout = cc.FadeOut:create(endTime)
        local removeSelf = cc.RemoveSelf:create()
        maskLayer:runAction(cc.Sequence:create(fadeout, removeSelf))
        self:resumeBattle()
        endCallback()

        self:playFairyAnimation(fairyID)
    end)
    fairyBg:runAction(cc.Sequence:create(fairyMoveAction1, actionDelay:clone(), stopDelay:clone(), delay1:clone(), endSpawn:clone()))
    
    local fairyMove2 = cc.MoveTo:create(actionTime, cc.p(SCREEN_WIDTH * 0.22, SCREEN_HEIGHT * 0.3))
    local fairyMoveAction2 = cc.EaseBackOut:create(fairyMove2)
    fairySpri:runAction(cc.Sequence:create(delay1:clone(), fairyMoveAction2, actionDelay:clone(), stopDelay:clone(), endSpawn:clone(), maskLayerFunc))
end

function BattleController:monsterHint(nodeSeqId, touchFunc, releaseFunc)
    local config = BaseConfig.getIntroduce(nodeSeqId)
    if config == nil then
        return
    end

    local function introducePanel()
        local node = cc.Node:create()
        local runningScene = cc.Director:getInstance():getRunningScene()
        runningScene:addChild(node)
        local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,100), SCREEN_WIDTH, SCREEN_HEIGHT)
        node:addChild(bgLayer)
        local nodeGrid = cc.NodeGrid:create()
        nodeGrid:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        node:addChild(nodeGrid)

        local panel = cc.Sprite:create("image/ui/img/bg/bg_298.png")
        panel:setAnchorPoint(1, 0.5)
        nodeGrid:addChild(panel)
        local panelSize = panel:getContentSize()
        panel:setPosition(cc.p(panelSize.width * 0.5, 0))

        local leftPanel = cc.Sprite:create("image/ui/img/bg/bg_297.png")
        leftPanel:setPosition(panelSize.width * 0.25, panelSize.height * 0.48)
        panel:addChild(leftPanel)
        local lianhua = cc.Sprite:create("image/ui/img/btn/btn_1249.png")
        lianhua:setPosition(panelSize.width * 0.25, panelSize.height * 0.2)
        panel:addChild(lianhua)
        lianhua:setScale(0)
        local people = cc.Sprite:create("image/ui/img/btn/btn_1248.png")
        people:setPosition(panelSize.width * 0.3, panelSize.height * 0.5)
        panel:addChild(people)
        people:setScale(0)
        local name = createMixScale9Sprite("image/ui/img/btn/btn_1181.png", nil, nil, cc.size(120, 40))
        name:setPosition(panelSize.width * 0.25, panelSize.height * 0.12)
        panel:addChild(name)
        name:setCircleFont(config.Name, 1, 1, 22, cc.c3b(243, 207, 137))

        local rightPanel = cc.Sprite:create("image/ui/img/bg/bg_296.png")
        rightPanel:setPosition(panelSize.width * 0.7, panelSize.height * 0.48)
        panel:addChild(rightPanel)
        local title1 = Common.finalFont("简介", 1, 1, 22, cc.c3b(19, 59, 98))
        title1:setPosition(panelSize.width * 0.7, panelSize.height * 0.8)
        panel:addChild(title1)
        local title2 = Common.finalFont("攻略", 1, 1, 22, cc.c3b(19, 59, 98))
        title2:setPosition(panelSize.width * 0.7, panelSize.height * 0.43)
        panel:addChild(title2)
        local ColorLabel = require("tool.helper.ColorLabel")
        local desc1 = ColorLabel.new("", 20, 12, true)
        desc1:setAnchorPoint(0, 1)
        desc1:setPosition(panelSize.width * 0.49, panelSize.height * 0.74)
        panel:addChild(desc1)
        desc1:setString("[72,106,167]"..config.Desc.."[=]")
        local desc2 = ColorLabel.new("", 20, 12, true)
        desc2:setAnchorPoint(0, 1)
        desc2:setPosition(panelSize.width * 0.49, panelSize.height * 0.37)
        panel:addChild(desc2)
        desc2:setString("[72,106,167]"..config.Suggestion.."[=]")

        -- 1为星将，2为怪，3为技能特效，4为图片资源
        local targettype = config.TargetType
        local target = config.Target
        local HeroAction = require("tool.helper.HeroAction")
        if targettype == 1 then
            lianhua:setScale(1)
            local skins = { ["Arm"] = 0, ["Hat"] = 0, ["Coat"] = 0}
            local animation = HeroAction.new(panelSize.width * 0.25, panelSize.height * 0.25, tonumber(target), skins)
            animation:setTouchEnabled(false)
            panel:addChild(animation)
        elseif targettype == 2 then
            lianhua:setScale(1)
            local animation = CreatePlayer(panelSize.width * 0.25, panelSize.height * 0.25, target)
            animation:setAnimation(0, "idle", true)
            panel:addChild(animation)
        elseif targettype == 3 then
            lianhua:setScale(1)
            people:setScale(1)
            local animation = nil
            local path = string.format("image/spine/skill_effect/buff/%d/top/skeleton.skel", target)
            if cc.FileUtils:getInstance():isFileExist(path) then
                animation = load_animation(string.format("image/spine/skill_effect/buff/%d/top/", target), 1, BattleConfig.SPEED_RATIO)
            else
                animation = load_animation(string.format("image/spine/skill_effect/buff/%d/", target), 1, BattleConfig.SPEED_RATIO)
            end
            animation:setAnimation(0, "animation", true)
            animation:setPosition(panelSize.width * 0.25, panelSize.height * 0.25)
            panel:addChild(animation)
            animation:setScaleX(-1)
        elseif targettype == 4 then
            local spriBg = cc.Sprite:create("image/ui/img/btn/btn_1250.png")
            spriBg:setPosition(panelSize.width * 0.25, panelSize.height * 0.53)
            panel:addChild(spriBg)
            local spri = cc.Sprite:create("image/ui/introduce/"..target..".png")
            spri:setPosition(panelSize.width * 0.25, panelSize.height * 0.53)
            panel:addChild(spri)
        end

        local function onTouchBegan(touch, event)
            return true
        end
        local function onTouchEnded(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if not cc.rectContainsPoint(rect, locationInNode) then
                local pagrTurn = cc.PageTurn3D:create(0.5, cc.size(15,10))
                nodeGrid:runAction(cc.Sequence:create(pagrTurn, cc.CallFunc:create(function()
                    if releaseFunc then
                        releaseFunc()
                    end
                    node:removeFromParent()
                    node = nil
                end)))
            end
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

        panel:setScaleX(0.01)
        local scale1 = cc.ScaleTo:create(0.2, 1.1, 1)
        local scale2 = cc.ScaleTo:create(0.06, 0.95, 1)
        local scale3 = cc.ScaleTo:create(0.04, 1, 1)
        panel:runAction(cc.Sequence:create(scale1, scale2, scale3))
    end

    local btn_warning = cc.LayerColor:create(cc.c4f(255, 0, 0, 0), 50, 50)
    btn_warning:setPosition(SCREEN_WIDTH * 1.3, SCREEN_HEIGHT * 0.7)
    self:addChild(btn_warning, 10)
    local warningEffect = load_animation("image/spine/ui_effect/44/", 1, BattleConfig.SPEED_RATIO)
    warningEffect:setAnimation(0, "animation", true)
    warningEffect:setPosition(25, 25)
    btn_warning:addChild(warningEffect)

    local iconPos = cc.p(SCREEN_WIDTH - 100, SCREEN_HEIGHT * 0.7)
    local move = cc.EaseBackOut:create(cc.MoveTo:create(0.3, iconPos))
    btn_warning:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
        if config.PopupType == 1 then            
            introducePanel()
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

        if cc.rectContainsPoint(rect, locationInNode) then
            if touchFunc then
                touchFunc()
            end
            introducePanel()
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, btn_warning)

    -- 自动弹出
    if config.PopupType == 1 then            
        touchFunc()
    end
end

function BattleController:playBossWarning(callback)
    local centerBg = cc.Sprite:create("image/ui/img/btn/btn_1414.png")
    centerBg:setScaleX(display.width / (centerBg:getContentSize().width))
    centerBg:setScaleY(display.height / (centerBg:getContentSize().height))
    centerBg:setPosition(display.width * 0.5, display.height * 0.5)
    self:addChild(centerBg, 5)
    local centerSpri = cc.Sprite:create("image/ui/img/btn/btn_1413.png")
    centerSpri:setPosition(display.width * 0.5, display.height * 0.5)
    self:addChild(centerSpri, 5)
    local leftSpri = cc.Sprite:create("image/ui/img/btn/btn_1412.png")
    self:addChild(leftSpri, 5)
    leftSpri:setFlippedX(true)
    leftSpri:setFlippedY(true)
    leftSpri:setPosition(-display.width, display.height * 0.18)
    local rightSpri = cc.Sprite:create("image/ui/img/btn/btn_1412.png")
    self:addChild(rightSpri, 5)
    rightSpri:setPosition(display.width, display.height * 0.82)
    centerBg:setOpacity(0)
    centerSpri:setOpacity(0)
    leftSpri:setOpacity(0)
    rightSpri:setOpacity(0)

    local joinTime = 0.5
    local centerDelayTime = 1.5
    local leaveTime = 0.2
    local moveJoin1 = cc.MoveTo:create(joinTime, cc.p(display.width * 0.5, display.height * 0.18))
    local moveJoin11 = cc.EaseBounceOut:create(moveJoin1)
    local fadeIn1 = cc.FadeIn:create(joinTime)
    local leftSpawn1 = cc.Spawn:create(moveJoin11, fadeIn1) 

    local moveLeave1 = cc.MoveTo:create(leaveTime, cc.p(display.width, display.height * 0.18))
    local moveLeave11 = cc.EaseBackIn:create(moveLeave1)

    local moveJoin2 = cc.MoveTo:create(joinTime, cc.p(display.width * 0.5, display.height * 0.82))
    local moveJoin21 = cc.EaseBounceOut:create(moveJoin2)
    local fadeIn2 = cc.FadeIn:create(joinTime)
    local rightSpawn2 = cc.Spawn:create(moveJoin21, fadeIn2) 

    local moveLeave2 = cc.MoveTo:create(leaveTime, cc.p(-display.width, display.height * 0.82))
    local moveLeave21 = cc.EaseBackIn:create(moveLeave2)

    local centerDelay1 = cc.DelayTime:create(joinTime)
    local centerBlink = cc.Blink:create(centerDelayTime, 2)
    local centerJoinFunc1 = cc.CallFunc:create(function()
        Common.stopBackgroundMusic()
        Common.playSound("res/audio/effect/battle_warning.mp3")
        centerBg:setOpacity(255)
        centerSpri:setOpacity(255)
    end)
    local centerLeaveFunc2 = cc.CallFunc:create(function()
        if callback then
            callback()
        end
        centerBg:removeFromParent()
        centerSpri:removeFromParent()
    end)

    local delay1 = cc.DelayTime:create(centerDelayTime) 
    local removeSelf = cc.RemoveSelf:create()
    leftSpri:runAction(cc.Sequence:create({leftSpawn1, delay1:clone(), moveLeave11, removeSelf:clone()}))
    rightSpri:runAction(cc.Sequence:create({rightSpawn2, delay1:clone(), moveLeave21, removeSelf:clone()}))
    centerSpri:runAction(cc.Sequence:create({centerDelay1, centerJoinFunc1, centerBlink, centerLeaveFunc2}))
end

function BattleController:createDamageIconNode()
    local node = cc.Node:create()
    node:setContentSize(cc.size(349, 116))
    node:setPosition(cc.p(display.left + 20, display.top - 180))

    self.foregroundNode:addChild(node)

    local bg = cc.Sprite:create("image/ui/img/btn/btn_1351.png")
    bg:setPosition(180, 70)
    node:addChild(bg)

    local iconCoin = cc.Sprite:create("image/ui/img/btn/btn_1353.png")
    iconCoin:setPosition(45, 60)
    node:addChild(iconCoin)

    local iconCross = cc.Sprite:create("image/ui/img/btn/btn_1352.png")
    iconCross:setPosition(90, 60)
    node:addChild(iconCross)

    local labelCoins = cc.LabelAtlas:_create("0", "image/ui/img/btn/btn_1356.png", 24, 47,  string.byte("0"))
    labelCoins:setPosition(110, 40)
    labelCoins:setScale(0.8)
    node:addChild(labelCoins)

    self.label_coins = labelCoins
end

function BattleController:updateDamageCoins()
    if self.isCoinsMonster then
        local enemyFullHP = self.battleModel.rightTeam:getFullHP()
        local enemyLeftHP = math.floor(self.battleModel.rightTeam:getCurHP())

        local totalDamage = enemyFullHP - enemyLeftHP

        self.label_coins:setString(math.floor(totalDamage / 10.0))
    end
end

return BattleController
