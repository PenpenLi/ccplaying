--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-18
-- Time: 下午3:18
-- To change this template use File | Settings | File Templates.
--
local HeroHeadNode = import(".HeroHeadNode")
local FairyHeadNode = import(".FairyHeadNode")
local HeroAniNode = import(".HeroAniNode")
local BattleFormData = import(".BattleFormData")
local CommonTool = require("tool.helper.Common")
local HeroTip = require("tool.helper.HeroTip")

local heroTypeList = {
    {type = "fairy",   name = "仙女", on = "image/ui/img/btn/btn_641.png", off = "image/ui/img/btn/btn_642.png"},
    {type = "all",     name = "全部", on = "image/ui/img/btn/btn_641.png", off = "image/ui/img/btn/btn_642.png"},
    {type = "near",    name = "近战", on = "image/ui/img/btn/btn_641.png", off = "image/ui/img/btn/btn_642.png"},
    {type = "far",     name = "远战", on = "image/ui/img/btn/btn_641.png", off = "image/ui/img/btn/btn_642.png"},
    {type = "veryFar", name = "超远", on = "image/ui/img/btn/btn_641.png", off = "image/ui/img/btn/btn_642.png"},    
}

-- 仙女功能开启等级
local FAIRY_OPEN_LEVEL = 15

--local function circle(cx, cy, r)
--    local circle_points = {}
--    for i = 1, 360, 2 do
--        local rad = math.rad(i)
--        local x = cx + r * math.cos(rad)
--        local y = cy + r * math.sin(rad) * 0.4
--        table.insert(circle_points, cc.p(x, y))
--    end
--    return circle_points
--end
--
--local CIRCLE_1_POINTS = circle(284, 210, 130)
--local CIRCLE_2_POINTS = circle(284, 210, 250)

local function SPOS(x, y)
    local cx = 320
    local cy = 240

    local x = cx + 150 * (x - 2)
    local y = cy + 90 * (y - 2) * 0.8
    return cc.p(x, y)
end
-------------------------------------------------------------------------------

local BattleFormLayer = class("BattleFormLayer", BaseLayer)

--[[
    params = {
        heroLimit = {
            level = {from = 1, to = 100}, -- 等级限制
            gender = {male = true, female = true} -- 性别限制
            number = 1,                   -- 英雄数量必须为 number
            maxNumber = 4,                -- 最多英雄数
            minNumber = 1,                -- 最少英雄数
        },
        ...
    }
--]]
function BattleFormLayer:ctor(formType, params)
    CCLog(vardump({formType, params = params}, "BattleFormLayer:ctor"))
    CCLog("form -----> ", vardump(params.attackerForm))
    self.data.formType = formType or GameCache.FORM_TYPE_DEFAULT
    self.data.heroAniMap = {}
    self.data.params = params or {}

    if params then
        if params.HeroRestrict then
            if params.HeroRestrict == 1 then
                self.data.params.heroLimit = {gender = {male = true}}
            elseif params.HeroRestrict == 2 then
                self.data.params.heroLimit = {gender = {female = true}}
            elseif params.HeroRestrict == 3 then
                self.data.params.heroLimit = {}
            end
        end
    end

    self.data.heroType = "all" -- "all", "near", "far", "veryFar", "fairy"

--    self.data.heroDataList = heroDataManager.heroDataList
--    self.data.curHeroDataList = self.data.heroDataList

    self.data.heroIDList = table.keys(GameCache.GetAllHero())
    self:sortHeroIDList(self.data.heroIDList)
    self.data.curHeroIDList = self:filterHeroList(self.data.heroIDList, "all", self.data.params.heroLimit or {})

    -- TODO:10级开启仙女技能
    local enableFairy = true
    if self.data.params.heroLimit and self.data.params.heroLimit.enableFairy == false then
        enableFairy = false
    end

    if GameCache.Avatar.Level >= FAIRY_OPEN_LEVEL and enableFairy then
        self.data.fairyList = table.values(GameCache.AllFairy)
    else
        self.data.fairyList = {}
    end

    self.heroMoveEnabled = true
    self.data.slotPosCache = {
        ["1:1"] = SPOS(1, 1),
        ["1:2"] = SPOS(1, 2),
        ["1:3"] = SPOS(1, 3),
        ["2:1"] = SPOS(2, 1),
        ["2:2"] = SPOS(2, 2),
        ["2:3"] = SPOS(2, 3),
        ["3:1"] = SPOS(3, 1),
        ["3:2"] = SPOS(3, 2),
        ["3:3"] = SPOS(3, 3),
    }
    vardump(self.data.slotPosCache, "slot pos")
    self.data.slotZOrderCache = {}

    local formData = BattleFormData.new()
    local form = self:getCurForm()

        -- 加入助战NPC
    if self.data.params.nodeInfo and self.data.params.nodeInfo.IsFirst then
        local nodeID = self.data.params.nodeInfo.NodeID
        local diffLV = self.data.params.nodeInfo.DiffLevel
        local extraHeroList = BaseConfig.getFightingNPC(nodeID, 1)

        if extraHeroList then
            form.Hero = form.Hero or {}
            for _, slotData in ipairs(extraHeroList) do
                table.insert(form.Hero, slotData)
            end
            CCLog(vardump(form, "add npc to form"))
        end
    end

    formData:setForm(form)
    local playFairyID = self:getCurFairyID()
    formData:setPlayFairyID(playFairyID)
    formData:setFairyList(self.data.fairyList)
    self.data.formData = formData

    self.controls.heroListTableView = nil
    self.startingBattle = false

    self.inited = false
    self:startSetupUIThread()

--    local getHandler = httpClient:addEventListener(AppEvent.Network.Formation.GetRoleAllFormation, handler(self, self.responseGetRoleAllFormation))
--    table.insert(self.handlers, getHandler)
--
--    local setHandler = httpClient:addEventListener(AppEvent.Network.Formation.SetRoleFormation, handler(self, self.responseSetRoleFormation))
--    table.insert(self.handlers, setHandler)
--
--    local towerBeginHandler = httpClient:addEventListener(AppEvent.Network.Tower.BeginF, handler(self, self.responseBeginTower))
--    table.insert(self.handlers, towerBeginHandler)

    -- local handlerFairy = httpClient:addEventListener(AppEvent.Network.Fairy.GetAllFairy, handler(self, self.responseGetFairyList))
    -- table.insert(self.handlers, handlerFairy)

    -- local fairyOutHandler = httpClient:addEventListener(AppEvent.Network.Fairy.FairyOut, handler(self, self.responseFairyOutHandler))

    -- self:requestGetFairyList()

    -- if self:isTower() then
    --     self:requestGetRoleAllFormation()
    -- end
end

function BattleFormLayer:getConsume()
    local BattleConsumeTypeName = {
        [enums.BattleConsumeType.Power] = "体力",
        [enums.BattleConsumeType.Endurance] = "耐力",
    }

    local formType_battleSystem = {
        [GameCache.FORM_TYPE_INSTANCE]        = enums.BattleSystem.Instance, -- "副本",
        [GameCache.FORM_TYPE_ARENA]           = enums.BattleSystem.Arena,    -- "竞技场",
        [GameCache.FORM_TYPE_VEHICLE]         = enums.BattleSystem.Transport,-- "运镖",
        [GameCache.FORM_TYPE_LOOT]            = enums.BattleSystem.Loot,     -- "夺宝",
        [GameCache.FORM_TYPE_TOWER]           = nil,                         -- "爬塔",
        [GameCache.FORM_TYPE_DAILY]           = enums.BattleSystem.Activity, -- "每日副本",
        [GameCache.FORM_TYPE_ARENA_DEFENSE]   = nil,                         -- "竞技场防守",
        [GameCache.FORM_TYPE_VEHICLE_DEFENSE] = nil,                         -- "运镖防守",
        [GameCache.FORM_TYPE_HOME]            = enums.BattleSystem.Home,     -- "家园",
        [GameCache.FORM_TYPE_HOME_DEFENSE]    = nil,                         -- "家园防守",
        [GameCache.FORM_TYPE_LOOT_DEFENSE]    = nil,                         -- "夺宝防守",
    }

    local consume = BaseConfig.GetBattleConsume(formType_battleSystem[self.data.formType])

    if consume then
        local consumeType =  BattleConsumeTypeName[consume.Type] or ""
        local consumeValue = consume.Value

        return consumeType, consumeValue
    else
        return nil
    end
end

function BattleFormLayer:loadBgImage()
    local mapImagePath = "image/instance/image/"

    local chapterID = self.data.params.chapterID or 1
    local jsonfile = string.format("image/instance/json/inst_%d.json", chapterID)
    local js = cc.FileUtils:getInstance():getStringFromFile(jsonfile)
    local map = json.decode(js)

    if map then
        for j=1,#map do
            if map[j].name == "bg" then
                for k=1,#map[j].sprites do
                    local path = mapImagePath .. map[j].sprites[k].image
                    local pos = map[j].sprites[k].pos

                    local sprite = cc.Sprite:create(path)
                    sprite:setPosition(cc.p(pos.x, pos.y))
                    return sprite
                end
            end
        end
    else
        local background = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
        background:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
        return background
    end
    return nil
end

function BattleFormLayer:isHeroMoveDisabled()
    return not self.heroMoveEnabled
end

function BattleFormLayer:disabledHeroMove()
    self.heroMoveEnabled = false
end

function BattleFormLayer:enableHeroMove()
    self.heroMoveEnabled = true
end

function BattleFormLayer:onEnter()
    if not self.inited then
        return
    end

    self.data.heroIDList = table.keys(GameCache.GetAllHero())

    -- 爬塔死亡的星将将自动移除战斗阵型
    -- local formType = self.data.formType
    -- if formType == GameCache.FORM_TYPE_TOWER then
    --     self:requestGetRoleAllFormation()
    -- end
    self:refreshForm()

    if self.data.formType == GameCache.FORM_TYPE_HOME then
        local homeTimeLeftHandler 
        homeTimeLeftHandler = application:addEventListener(AppEvent.UI.Home.CountDown, function(event)
            if tolua.isnull(self) then
                application:removeEventListener(homeTimeLeftHandler)
            else
                local result = event.data
                local time = result.Time

                self.controls.homeLabel:setVisible(true)
                self.controls.homeTime:setVisible(true)
                self.controls.homeTime:setString(Common.timeFormat(time))

                if time <= 0 then                    
                    require("tool.helper.CommonLayer").HintPanel("时间到", function() 
                        application:popScene() 
                        if self.data.formType == GameCache.FORM_TYPE_HOME then
                            application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
                        end
                    end)
                end
            end
        end)

        self.data.homeTimeLeftHandler = homeTimeLeftHandler
    end
end

function BattleFormLayer:onExit()
    if self.data.formType == GameCache.FORM_TYPE_HOME then
        if self.data.homeTimeLeftHandler then
            application:removeEventListener(self.data.homeTimeLeftHandler)
            self.data.homeTimeLeftHandler = nil
        end
    end
end

function BattleFormLayer:setupUIComplete()
    Common.OpenGuideLayer({1,2,3,8})
    Common.OpenSystemLayer({5})
    BattleFormLayer.super.onEnterTransitionFinish(self)
    self:refreshForm()
end

function BattleFormLayer:onEnterTransitionFinish( )
    -- Common.OpenGuideLayer({1,2,3,8})
    -- Common.OpenSystemLayer({5})
    -- BattleFormLayer.super.onEnterTransitionFinish(self)
    -- self:refreshForm()
end

function BattleFormLayer:sortHeroIDList(heroIDList)
    table.sort(heroIDList, function(heroID1, heroID2)
        local heroData1 = GameCache.GetHero(heroID1)
        local heroData2 = GameCache.GetHero(heroID2)

        local TFP1 = heroData1.TFP or 0
        local TFP2 = heroData2.TFP or 0

        return TFP1 > TFP2
    end)
end

-- function BattleFormLayer:requestGetFairyList()
--     local action = {method = "Fairy.GetAllFairy", param = {}}
--     httpClient:call(action)
-- end

-- function BattleFormLayer:responseGetFairyList(event)
--     if event.status == Exceptions.Nil then
--         CCLog(vardump(event.result, "FairyList"))
--         GameCache.AllFairy = event.result

--         if not tolua.isnull(self) then
--             self.data.fairyList = GameCache.AllFairy

--             self.data.formData:setFairyList(self.data.fairyList)
--             self:fairyChanged()
--         end
--     end
-- end

-- function BattleFormLayer:responseFairyOut(event)
--     if event.status == Exceptions.Nil then
--         self:requestGetFairyList()
--     end
-- end

function BattleFormLayer:requestGetRoleAllFormation()
    rpc:call("Formation.GetRoleAllFormation", nil, handler(self, self.responseGetRoleAllFormation))
end

function BattleFormLayer:responseGetRoleAllFormation(event)
    if not tolua.isnull(self) then
        CCLog(vardump(event.result, "responseGetRoleAllFormation"))
        self:refreshForm()
    end
end

-- function BattleFormLayer:requestSetRoleFormation(form, fairyID)
--     rpc:call("Formation.SetRoleFormation", {Type = self.data.formType, Hero = form, Fairy = fairyID}, handler(self, self.responseSetRoleFormation))
-- end

-- function BattleFormLayer:responseSetRoleFormation(event)
--     CCLog(event:getEventName(), vardump(event))
--     if tolua.isnull(self) then
--         CCLog("self is null")
--         return
--     end

--     if event.status == Exceptions.Nil then
--         if event.result then
--             local form = self.data.formData:getForm()
--             local fairyID = self.data.formData:getPlayFairyID()
--             GameCache.AllFormation[self.data.formType] = {Type = self.data.formType, Hero = form, Fairy = fairyID}

--             local battleType = self.data.params.battleType
--             if battleType == "PVE" or battleType == "PVP" then
--                 self:startBattle()
--             elseif battleType == "Tower" then
--                 rpc:call("Tower.BeginF", nil, handler(self, self.responseBeginTower))
--             elseif battleType == nil then
--                 application:popScene()
--                 application:showFlashNotice("保存阵容成功！")
--             end
--         else
--             BaseConfig.isCanClick = true
--             self.startingBattle = false

--             application:showFlashNotice("设置阵容失败")
--         end
--     else
--         BaseConfig.isCanClick = true
--         self.startingBattle = false

--         application:showFlashNotice("设置阵容失败")
--     end

--     -- self:requestGetRoleAllFormation()
-- end

function BattleFormLayer:responseBeginTower(event)
    CCLog(event:getEventName())
    if tolua.isnull(self) then
        CCLog("self is null")
        return
    end
    CCLog("爬塔开始", vardump({name =event:getEventName(), result = event.result}))

    if event.result then
        self:startBattle()
    else
        application:showFlashNotice(string.format("网络请求异常:错误代码%d", event.result))
    end
end

function BattleFormLayer:reachMaxHeroNumber()   
    local heroLimit = self.data.params.heroLimit
    if heroLimit then
        local maxNumber = heroLimit.number or heroLimit.maxNumber
        if maxNumber then
            local formData = self.data.formData
            local formUnitCount = #formData:getForm()
            if formUnitCount == maxNumber then
                return true
            end
        end
    end
    return false
end

function BattleFormLayer:refreshForm()
    local formData = self.data.formData

    self:clearHeroSlotList()
    self:createHeroSlotList()
    local form = formData:getForm()
    if GameCache.NewbieGuide.Step == 1 then
        CCLog(vardump(form, "GuideStep 1"))
        -- if #form == 1 then
        --     Common.ResetGuideLayer({big=1, small = 4})
        --     Common.OpenGuideLayer({1})
        -- end

        -- 加NPC
        if #form == 4 then
            Common.ResetGuideLayer({big=1, small = 5})
            Common.OpenGuideLayer({1})
        end
    elseif GameCache.NewbieGuide.Step == 3 then
        CCLog(vardump(form, "GuideStep 3"))
        if #form == 2 then
            Common.ResetGuideLayer({big=3, small = 4})
            Common.OpenGuideLayer({3})
        end
    elseif GameCache.NewbieGuide.Step == 8 then
        CCLog(vardump(form, "GuideStep 8"))
        if #form == 3 then
            Common.ResetGuideLayer({big=8, small = 4})
            Common.OpenGuideLayer({8})
        end
    end
end

function BattleFormLayer:fairyChanged()
    local playFairyID = self.data.formData:getPlayFairyID()
    if playFairyID and playFairyID ~= 0 then
        local fairyConfig = BaseConfig.GetFairy(playFairyID)
        local iconPath = string.format("image/ui/fairy/%s_head.png", fairyConfig.Res)
        self.controls.spriteFairy:setTexture(iconPath)
        self.controls.spriteFairy:setVisible(true)
    else
        self.controls.spriteFairy:setVisible(false)
    end

    local tableView = self.controls.heroListTableView

    local offset = tableView:getContentOffset()
    tableView:reloadData()
    tableView:setContentOffset(offset)
end

function BattleFormLayer:setFormType(formType)
    self.data.formType = formType
end

function BattleFormLayer:isTower()
    local params = self.data.params or {}
    return params.battleType == "Tower"
end

function BattleFormLayer:getCurForm()
    return self.data.params.attackerForm or {}
end

function BattleFormLayer:getCurFairyID()
    local curForm = self:getCurForm()
    return curForm and curForm.Fairy or 0
end

function BattleFormLayer:startBattle(isPVP)
    local form = self.data.formData:getForm()
    if #form == 0 then
        application:showFlashNotice("请选择星将")
        self.startingBattle = false
    else
        if self.startingBattle then
            self.startingBattle = false
            Common.CloseGuideLayer({1,2,3,8})
            local fairyData = self.data.formData:getPlayFairyData()
            local formInfo = {form = form, fairyData = fairyData }
            CCLog(vardump(formInfo, "Start Battle"))
            self.data.params.battleFormType = self.data.formType

            -- -- 加入助战NPC
            -- if self.data.params.nodeInfo then
            --     local nodeID = self.data.params.nodeInfo.NodeID
            --     local diffLV = self.data.params.nodeInfo.DiffLevel
            --     local extraHeroList = BaseConfig.getFightingNPC(nodeID, 1)

            --     if extraHeroList then
            --         for _, slotData in ipairs(extraHeroList) do
            --             table.insert(formInfo.form, slotData)
            --         end
            --         CCLog(vardump(formInfo, "Start Battle 2"))
            --     end
            -- end
            

            if isPVP then
                local ownHeroInfo = {Hero = formInfo.form, Fairy = formInfo.fairyData}
                local enemyHeroInfo = {Hero = self.data.params.form.Hero, Fairy = self.data.params.form.Fairy,
                                    HeroList = self.data.params.heroList, EnemyInfo = self.data.params.enemy}
                application:pushScene("loading.PVPLoadingScene", ownHeroInfo, enemyHeroInfo, function()
                    -- PVP动画播放完后的回调 (声哥在这儿处理加载资源和跳转)
                    application:popScene()
                    application:replaceScene("battle.BattleScene", self.data.params, formInfo)
                end) 
            else
                application:replaceScene("battle.BattleScene", self.data.params, formInfo)
            end
        end
    end
end

function BattleFormLayer:getHeroTowerHP(heroID)
    local params = self.data.params or {}

    local climbHero = params.climbHero or {}
    for _, v in ipairs(climbHero) do
        if v.ID == heroID then
            return v.RemainHP
        end
    end
    return nil
end

function BattleFormLayer:getHeroTowerIsInClinic(heroID)
    local params = self.data.params or {}

    local climbHero = params.climbHero or {}
    for _, v in ipairs(climbHero) do
        if v.ID == heroID then
            return v.IsInClinic
        end
    end
    return nil
end

function BattleFormLayer:setupUI()
    local PANEL_WIDTH = 900
    local PANEL_HEIGHT = 620

--    local spriteLayerBg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
--    spriteLayerBg:setPosition(cc.p(display.cx, display.cy))
--    self:addChild(spriteLayerBg)
    local spriteLayerBg = self:loadBgImage()
    if spriteLayerBg then
        self:addChild(spriteLayerBg)
    end

    local formPanel = cc.Node:create()
    formPanel:setContentSize(cc.size(PANEL_WIDTH, PANEL_HEIGHT))
    formPanel:setPosition(cc.p((display.width - PANEL_WIDTH) / 2, (display.height - PANEL_HEIGHT) / 2))
    self:addChild(formPanel)

    local spriteBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    spriteBg:setContentSize(cc.size(PANEL_WIDTH, PANEL_HEIGHT))
    spriteBg:setAnchorPoint(cc.p(0, 0))
    formPanel:addChild(spriteBg)

--    local spriteTitle = cc.Sprite:create("image/ui/img/btn/btn_376.png")
--    spriteTitle:setPosition(cc.p(PANEL_WIDTH / 2, PANEL_HEIGHT - 32))
--    formPanel:addChild(spriteTitle)
--
--    local spriteLeftIcon = cc.Sprite:create("image/ui/img/btn/btn_377.png")
--    spriteLeftIcon:setRotationSkewY(180)
--    spriteLeftIcon:setPosition(cc.p(PANEL_WIDTH / 2 - 190, PANEL_HEIGHT - 32))
--    formPanel:addChild(spriteLeftIcon)
--
--    local spriteRightIcon = cc.Sprite:create("image/ui/img/btn/btn_377.png")
--
--    spriteRightIcon:setPosition(cc.p(PANEL_WIDTH / 2 + 190, PANEL_HEIGHT - 32))
--    formPanel:addChild(spriteRightIcon)

    local heroPanel = cc.Node:create()
    heroPanel:setContentSize(cc.size(282, 595))
    heroPanel:setPosition(cc.p(53, 8))
    formPanel:addChild(heroPanel, 2)
    self.controls.heroPanel = heroPanel

    local heroPanelBg = cc.Sprite:create("image/ui/img/bg/bg_166.png")
    heroPanelBg:setPosition(cc.p(0, 0))
    heroPanelBg:setAnchorPoint(cc.p(0, 0))
    heroPanel:addChild(heroPanelBg)

    coroutine.yield()

    for i = 1, 5 do
        local selected = false
        if heroTypeList[i].type == self.data.heroType then
            selected = true
        end

        local img = selected and heroTypeList[i].on or heroTypeList[i].off
        local button = ccui.Button:create(img, img)
        button:setName("btn_hero_type_" .. heroTypeList[i].type)
        button:setScale(1)
        button:setPosition(cc.p(-20, (6 - i) * 112 - 41))
        button:setTitleFontSize(28)
        button:setTitleText("")
        heroPanel:addChild(button)
        button:setLocalZOrder(selected and 1 or -1)

        local btnSize = button:getContentSize()

        --local labelTitle = cc.LabelTTF:create(heroTypeList[i].name, "Arial", 26, cc.size(30, 200), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        local labelTitle = CommonTool.finalFont(heroTypeList[i].name, 0 , 0 , 26, cc.c3b(255, 255, 255), 1)
        labelTitle:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        labelTitle:setDimensions(30, 200)
        labelTitle:setColor(cc.c3b(255, 255, 255))
        labelTitle:setPosition(cc.p(btnSize.width * 0.6, btnSize.height * 0.5))
        labelTitle:setAnchorPoint(cc.p(0.5, 0.5))
        button:addChild(labelTitle)

        local heroType = heroTypeList[i].type
        button:addTouchEventListener(widget_click_listener(function(sender)
            CCLog("HeroType:", heroType)
            self:setHeroType(heroType)
        end))
    end

    coroutine.yield()

    local spriteFlower = cc.Sprite:create("image/ui/img/btn/btn_645.png")
    spriteFlower:setPosition(cc.p(141, 90))
    heroPanel:addChild(spriteFlower)

    local tableView = self:createTowColumnHeroList()
    heroPanel:addChild(tableView)
    tableView:reloadData()
    self.controls.heroListTableView = tableView

    local slotsPanel = cc.Node:create()
    slotsPanel:setContentSize(cc.size(568, 545))
    slotsPanel:setPosition(cc.p(280, 12))
    formPanel:addChild(slotsPanel, 3)
    self.controls.slotsPanel = slotsPanel

    local slotsPanelBg = cc.Sprite:create("image/ui/img/bg/bg_167.png")
    slotsPanelBg:setPosition(cc.p(280, 8))
    slotsPanelBg:setAnchorPoint(cc.p(0, 0))
    formPanel:addChild(slotsPanelBg)

    local fairyNode = cc.Node:create()
    fairyNode:setContentSize(cc.size(115, 115))
    fairyNode:setAnchorPoint(cc.p(0.5, 0.5))
    fairyNode:setPosition(cc.p(110, 520))
    slotsPanel:addChild(fairyNode)

    local spriteFairyBg = cc.Sprite:create("image/ui/img/btn/btn_643.png")
    spriteFairyBg:setPosition(cc.p(115 / 2, 115 / 2))
    fairyNode:addChild(spriteFairyBg)
    self.controls.fairyBG = spriteFairyBg

    coroutine.yield()

    local bgSize = spriteFairyBg:getContentSize()

    -- local stencil = cc.Sprite:create("image/ui/img/btn/btn_643.png")
    -- stencil:setScale(1)
    -- local clippingNode = cc.ClippingNode:create()
    -- clippingNode:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2))
    -- clippingNode:setInverted(false)
    -- clippingNode:setAlphaThreshold(0.5)
    -- clippingNode:setStencil(stencil)

    -- spriteFairyBg:addChild(clippingNode)

    local spriteFairy = cc.Sprite:create("image/ui/fairy/xn_001_head.png")
    spriteFairy:setScale(0.9)
    spriteFairy:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2 + 8))
    spriteFairyBg:addChild(spriteFairy)
    self.controls.spriteFairy = spriteFairy
    spriteFairy:setVisible(false)

    local spriteFairyIcon = cc.Sprite:create("image/ui/img/btn/btn_647.png")
    spriteFairyIcon:setPosition(cc.p(115 / 2, 20))
    fairyNode:addChild(spriteFairyIcon)

    local formTFPNode = cc.Node:create()
    formTFPNode:setContentSize(cc.size(162, 61))
    formTFPNode:setAnchorPoint(cc.p(0.5, 0.5))
    formTFPNode:setPosition(cc.p(235, 535))
    slotsPanel:addChild(formTFPNode)

    local formTFPBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_x_111.png")
    formTFPBG:ignoreAnchorPointForPosition(true)
    formTFPBG:setContentSize(cc.size(172, 61))
    formTFPBG:setPosition(cc.p(0, 0))
    formTFPNode:addChild(formTFPBG)

    coroutine.yield()

    --local labelTFPTitle = cc.LabelTTF:create("战力", "Arial", 20)
    local labelTFPTitle = CommonTool.finalFont("战力", 0 , 0 , 20, cc.c3b(255, 255, 255), 1)
    labelTFPTitle:setColor(cc.c3b(255, 255, 255))
    labelTFPTitle:setPosition(cc.p(43, 32))
    formTFPNode:addChild(labelTFPTitle, 1)

    --local labelTFP = cc.LabelTTF:create("0", "Arial", 26)
    local labelTFP = CommonTool.systemFont("", 0 , 0 , 26)
    labelTFP:setColor(cc.c3b(10, 255, 10))
    labelTFP:setPosition(cc.p(110, 31))
    formTFPNode:addChild(labelTFP, 1)

    self.controls.labelTFP = labelTFP

    local formNameNode = cc.Node:create()
    formNameNode:setContentSize(cc.size(162, 61))
    formNameNode:setAnchorPoint(cc.p(0.5, 0.5))
    formNameNode:setPosition(cc.p(425, 535))
    slotsPanel:addChild(formNameNode)

    self:addFormTipListener(formNameNode, slotsPanel)

    local formNameBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_x_111.png")
    formNameBG:ignoreAnchorPointForPosition(true)
    formNameBG:setContentSize(cc.size(162, 61))
    formNameBG:setPosition(cc.p(0, 0))
    formNameNode:addChild(formNameBG)

    --local labelFormName = cc.LabelTTF:create("锐金阵法", "Arial", 22)
    local labelFormName = CommonTool.finalFont("锐金阵法", 0 , 0 , 22, cc.c3b(255, 255, 255), 1)
    labelFormName:setColor(cc.c3b(255, 255, 255))
    labelFormName:setPosition(cc.p(60, 31))
    formNameNode:addChild(labelFormName, 1)
    self.controls.labelFormName = labelFormName

    local formIcon = cc.Sprite:create("image/ui/img/btn/btn_375.png")
    formIcon:setPosition(cc.p(130, 31))
    formNameNode:addChild(formIcon, 1)
    self.controls.formIcon = formIcon
    formIcon:setVisible(false)

    local btnFormHelp = ccui.Button:create("image/ui/img/btn/btn_868.png")
    btnFormHelp:setName("btnFormHelp")
    btnFormHelp:setPosition(cc.p(540, 535))
    slotsPanel:addChild(btnFormHelp)

    btnFormHelp:addTouchEventListener(widget_click_listener(function(sender)
        local FormDescNode = require("scene.form.FormDescNode")
        local helpNode = FormDescNode.new(self.data.formData)

        self:addChild(helpNode, 10000)
    end))

    coroutine.yield()

    -- local richTextHint = ccui.RichText:create()
    -- richTextHint:ignoreContentAdaptWithSize(true)
    -- richTextHint:setContentSize(cc.size(400, 30))
    -- richTextHint:setPosition(cc.p(360, 480))
    -- slotsPanel:addChild(richTextHint)
    -- self.richTextHint = richTextHint

    -- if self.data.formType == GameCache.FORM_TYPE_HOME_DEFENSE then
    --     local buildName = self.data.params.buildName
    --     if buildName then
    --         richTextHint:pushBackElement(ccui.RichElementText:create(1, cc.c3b(255, 185, 15), 255, "正在驻防", "Arial", 20))
    --         richTextHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(20, 255, 20), 255, "[" .. buildName .. "] ", "Arial", 20))
    --     end
    -- end

    -- if self.data.params.heroLimit and self.data.params.heroLimit.maxNumber then
    --     local maxNumber = self.data.params.heroLimit.maxNumber
    --     richTextHint:pushBackElement(ccui.RichElementText:create(3, cc.c3b(255, 185, 15), 255, "可上阵", "Arial", 20))
    --     richTextHint:pushBackElement(ccui.RichElementText:create(4, cc.c3b(20, 255, 20), 255, "" .. maxNumber, "Arial", 20))
    --     richTextHint:pushBackElement(ccui.RichElementText:create(5, cc.c3b(255, 185, 15), 255, "个星将", "Arial", 20))
    -- end

    if self.data.params.heroLimit and self.data.params.heroLimit.maxNumber then
        local maxNumber = self.data.params.heroLimit.maxNumber

        local labelPrefix = Common.finalFont("可上阵", 305, 470, 22, cc.c3b(255, 185, 15), 0)
        labelPrefix:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        labelPrefix:setAnchorPoint(cc.p(1, 0.5))
        slotsPanel:addChild(labelPrefix)

        local labelNum = Common.finalFont("" .. maxNumber, 320, 470, 22, cc.c3b(20, 255, 20), 0)
        labelNum:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        labelNum:setAnchorPoint(cc.p(0.5, 0.5))
        slotsPanel:addChild(labelNum)

        local labelPostfix = Common.finalFont("个星将", 335, 470, 22, cc.c3b(255, 185, 15), 0)
        labelPostfix:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        labelPostfix:setAnchorPoint(cc.p(0, 0.5))
        slotsPanel:addChild(labelPostfix)
    end

    if self.data.formType == GameCache.FORM_TYPE_HOME then

        local homeTimeBG = cc.Sprite:create("image/ui/img/btn/btn_1116.png")
        homeTimeBG:setPosition(330, 440)
        slotsPanel:addChild(homeTimeBG)
        homeTimeBG:setOpacity(150)

        -- 家园掠夺倒计时
        local labelHomeTime = Common.finalFont("掠夺倒计时:", 350, 440, 22, cc.c3b(255,255,140), 1)
        labelHomeTime:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        labelHomeTime:setAnchorPoint(cc.p(1, 0.5))
        slotsPanel:addChild(labelHomeTime)
        labelHomeTime:setVisible(false)

        local labelHomeTimeVal = Common.finalFont("00:00", 360, 440, 22, cc.c3b(255,255,140), 1)
        labelHomeTimeVal:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        labelHomeTimeVal:setAnchorPoint(cc.p(0, 0.5))
        slotsPanel:addChild(labelHomeTimeVal)
        labelHomeTimeVal:setVisible(false)

        self.controls.homeLabel = labelHomeTime
        self.controls.homeTime = labelHomeTimeVal
    end

    coroutine.yield()

--    local buttonBg = cc.Sprite:create("image/ui/img/bg/bg_094.png")
--    buttonBg:setPosition(cc.p(60, 5))
--    buttonBg:setAnchorPoint(cc.p(0, 0))
--    slotsPanel:addChild(buttonBg)

    self:createStart(slotsPanel)

    coroutine.yield()

    self:createMeteor(slotsPanel)

    coroutine.yield()

    self:createHeroSlotList()

    local consumeType, consumeValue = self:getConsume()

    if consumeType and consumeValue then
        local powerNode = cc.Node:create()
        powerNode:setContentSize(cc.size(120, 60))
        powerNode:setPosition(130, 60)
        powerNode:setAnchorPoint(cc.p(0.5, 0.5))
        slotsPanel:addChild(powerNode)

        local spritePhyBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_644.png")
        spritePhyBg:ignoreAnchorPointForPosition(true)
        spritePhyBg:setContentSize(cc.size(120, 60))
        spritePhyBg:setPosition(0, 0)
        powerNode:addChild(spritePhyBg, 1)

        --local labelExp = cc.LabelTTF:create("EXP:", "Arial", 24)
        local labelExp = CommonTool.finalFont("EXP", 0 , 0 , 20, cc.c3b(255, 255, 255), 1)
        labelExp:setColor(cc.c3b(151, 255, 74))
        labelExp:setPosition(cc.p(35, 20))
        powerNode:addChild(labelExp, 2)

        --local labelExpVal = cc.LabelTTF:create("120", "Arial", 24)
        local expVal = consumeType == "体力" and consumeValue * 10 or consumeValue * 30
        local labelExpVal = CommonTool.finalFont("+" .. expVal, 0 , 0 , 20, cc.c3b(255, 255, 255), 1)
        labelExpVal:setColor(cc.c3b(10, 255, 10))
        labelExpVal:setPosition(cc.p(90, 20))
        powerNode:addChild(labelExpVal, 2)

        local typeIconMap = {
            ["体力"] = "image/ui/img/bg/tili.png",
            ["耐力"] = "image/ui/img/bg/naili.png",
        }
        local iconPath = typeIconMap[consumeType]
        local spritePhyPower = cc.Sprite:create(iconPath)
        spritePhyPower:setPosition(cc.p(40, 43))
        powerNode:addChild(spritePhyPower, 2)

        --local labelNeedPhyPower = cc.LabelTTF:create("10", "Arial", 24)
        local labelNeedPhyPower = CommonTool.finalFont(string.format("%d", -consumeValue), 0 , 0 , 20, cc.c3b(255, 255, 255), 1)
        labelNeedPhyPower:setColor(cc.c3b(10, 255, 10))
        labelNeedPhyPower:setPosition(cc.p(90, 43))
        powerNode:addChild(labelNeedPhyPower, 2)
    else
        if self.data.formType == GameCache.FORM_TYPE_HOME_DEFENSE then
            local buildName = self.data.params.buildName
            if buildName then
                local labelPrefix = Common.finalFont("正在驻防", 200, 60, 22, cc.c3b(255, 185, 15), 0)
                labelPrefix:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
                labelPrefix:setAnchorPoint(cc.p(1, 0.5))
                slotsPanel:addChild(labelPrefix)

                local labelNum = Common.finalFont("[" .. buildName .. "] ", 205, 60, 22, cc.c3b(20, 255, 20), 0)
                labelNum:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                labelNum:setAnchorPoint(cc.p(0, 0.5))
                slotsPanel:addChild(labelNum)
            end
        end
    end

    coroutine.yield()

    local btnViewEnemyForm = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(163,62))
    btnViewEnemyForm:setCircleFont("反派角色", 0 , 0 , 20, cc.c3b(204, 190, 115), 1)
    btnViewEnemyForm:setFontPos(0.5, 0.5)
    btnViewEnemyForm:setName("btn_viewEnemyForm")
    btnViewEnemyForm:setPosition(PANEL_WIDTH - 310, 74)
    formPanel:addChild(btnViewEnemyForm)
    btnViewEnemyForm:setVisible(false)
    btnViewEnemyForm:setTouchEnable(false)

    btnViewEnemyForm:addTouchEventListener(function(sender, eventType)
        -- TODO:查看对方阵容
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            application:showFlashNotice("还没有实现！")
        end
    end)

    local btnStart = nil

    local battleType = self.data.params.battleType
    if  battleType == nil then
        btnStart = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(180,69))
        btnStart:setCircleFont("保存!", 0 , 0 , 28, cc.c3b(10, 254, 10), 1)
        btnStart:setChildPos(0.5, 0.5)
        btnStart:setFontPos(0.5, 0.5)
        btnStart:setName("btn_start")
        btnStart:setPosition(PANEL_WIDTH - 110, 74)
        formPanel:addChild(btnStart)

        btnViewEnemyForm:setVisible(false)
    elseif battleType == "PVP" then
        btnStart = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_670.png", cc.size(180,69))
        btnStart:setCircleFont("挑战", 0 , 0 , 28, cc.c3b(223, 188, 109), 1)
        btnStart:setChildPos(0.3, 0.5)
        btnStart:setFontPos(0.6, 0.5)
        btnStart:setName("btn_start")
        btnStart:setPosition(PANEL_WIDTH - 110, 74)
        formPanel:addChild(btnStart)
    else
        btnStart = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_1043.png", cc.size(180,69))
        btnStart:setCircleFont("", 0 , 0 , 28, cc.c3b(10, 254, 10), 1)
        btnStart:setChildPos(0.5, 0.5)
        btnStart:setFontPos(0.6, 0.5)
        btnStart:setName("btn_start")
        btnStart:setPosition(PANEL_WIDTH - 110, 74)
        formPanel:addChild(btnStart)
    end

    coroutine.yield()

    btnStart:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            self.startingBattle = true

            local form = self.data.formData:getForm()
            local fairyID = self.data.formData:getPlayFairyID()

            local startBattle = function()
                BaseConfig.isCanClick = false

                local battleType = self.data.params.battleType

                local formType = self.data.formType

                CCLog("阵容类型:", GameCache.FormNameTable[formType])

                if formType == GameCache.FORM_TYPE_INSTANCE then

                    -- 过滤掉阵容里面的助战NPC
                    local function filterOutNPC(form)
                        local newForm = {}
                        for _, slot in ipairs(form) do
                            if slot.X and slot.Y and slot.ID then
                                table.insert(newForm, slot)
                            end
                        end

                        return newForm
                    end
                    -- 副本
                    rpc:call("Instance.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = filterOutNPC(form), Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            self.data.params.form = {Type = self.data.formType, Hero = form, Fairy = fairyID or 0}

                            self:startBattle()
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false
                            application:showFlashNotice(event.desc or "进入战斗失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_ARENA then
                    -- 竞技场
                    rpc:call("Arena.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = form, Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            if self.data.params.attackerForm.Fairy ~= 0 and event.result.Fairy and event.result.Fairy.ID ~= 0 then
                                self.data.params.fairyData = event.result.Fairy
                            end

                            self.data.params.form            = event.result.Form
                            self.data.params.heroList        = event.result.HeroList
                            self.data.params.enemy = { Name = event.result.Name, Level = event.result.Level, TFP = event.result.TFP}

                            self:startBattle(true)
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false
                            application:showFlashNotice(event.desc or "进入战斗失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_VEHICLE then
                    -- 运镖
                    rpc:call("Vehicle.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = form, Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            if self.data.params.fairyID ~= 0 and event.result.Fairy and event.result.Fairy.ID ~= 0 then
                                self.data.params.fairyData = event.result.Fairy
                            end

                            self.data.params.form            = event.result.Form
                            self.data.params.heroList        = event.result.HeroList
                            self.data.params.isFriendGuard   = event.result.IsFriendGuard    -- 是否有仙友护卫
                            self.data.params.friendForm      = event.result.FriendForm       -- 护卫仙友阵容
                            self.data.params.friendHeroList  = event.result.FriendHeroList   -- 阵容星将详细属性
                            self.data.params.friendFairyData = event.result.FriendForm.Fairy ~= 0 and event.result.FriendFairy or nil
                            self.data.params.enemy = { Name = event.result.Name, Level = event.result.Level, TFP = event.result.TFP}

                            self:startBattle(true)
                        else
                            local desc = "进入战斗失败"
                            if event.status == Exceptions.EVehicleInHijacked then
                                desc = "目标正在被劫中..."
                            elseif event.status == Exceptions.EVehicleNotInTransport then
                                desc = "目标已不在运送途中"
                            elseif event.status == Exceptions.EVehicleHijackedCountOverflow then
                                desc = "目标被劫次数已达上限"
                            end
                            BaseConfig.isCanClick = true
                            self.startingBattle = false
                            application:showFlashNotice(desc)
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_LOOT then
                    -- 夺宝
                    rpc:call("Loot.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = form, Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            if self.data.params.attackerForm.Fairy ~= 0 and event.result.Fairy and event.result.Fairy.ID ~= 0 then
                                self.data.params.fairyData = event.result.Fairy
                            end

                            self.data.params.form            = event.result.Form
                            self.data.params.heroList        = event.result.HeroList
                            self.data.params.enemy = { Name = event.result.Name, Level = event.result.Level, TFP = event.result.TFP}

                            self:startBattle(true)
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false
                            application:showFlashNotice(event.desc or "进入战斗失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_TOWER then
                    -- 爬塔
                    rpc:call("Tower.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = form, Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            if self.data.params.attackerForm.Fairy ~= 0 and event.result.Fairy and event.result.Fairy.ID ~= 0 then
                                self.data.params.fairyData = event.result.Fairy
                            end

                            local towerHeroList   = event.result.HeroList
                            local enemyHeroHPList = event.result.EnemyHeroHP

                            local enemyRemainHPList = {}
                            for i, v in ipairs(enemyHeroHPList) do
                                local item = {}
                                item.ID = towerHeroList[i].ID
                                item.RemainHP = v
                                table.insert(enemyRemainHPList, item)
                            end

                            self.data.params.heroRP     = event.result.RP
                            self.data.params.enemyRP    = event.result.EnemyRP
                            self.data.params.climbEnemy = enemyRemainHPList

                            self.data.params.form       = event.result.Form
                            self.data.params.heroList   = event.result.HeroList
                            self:startBattle()
                        else
                            application:showFlashNotice(event.desc or "进入战斗失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_DAILY then
                    -- 每日副本
                    rpc:call("InstanceDaily.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = form, Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            self.data.params.form = {Type = self.data.formType, Hero = form, Fairy = fairyID or 0}

                            self:startBattle()
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false
                            application:showFlashNotice(event.desc or "进入战斗失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_HOME then
                    -- 家园
                    local turretList = nil

                    if self.data.params.turretID and  self.data.params.turretNum then 
                        local turretID = self.data.params.turretID

                        -- 配置坐标 x:[1,20], y[1,5]
                        if self.data.params.turretNum == 1 then
                            turretList = {{ ID = turretID, Pos = {  x = 19, y = 3}}, }
                        elseif self.data.params.turretNum == 2 then
                            turretList = {{ ID = turretID, Pos = {  x = 19, y = 1}}, { ID = turretID, Pos = {  x = 19, y = 5}, Power = turretPower},}
                        end
                    end
                    rpc:call("Home.BeginF", { SessionID = self.data.params.sessionID, Form = {Hero = form, Fairy = fairyID or 0}, }, function ( event )
                        if event.status == Exceptions.Nil then
                            if self.data.params.attackerForm.Fairy ~= 0 and event.result.Fairy and event.result.Fairy.ID ~= 0 then
                                self.data.params.fairyData = event.result.Fairy
                            end

                            self.data.params.nodeSequence    = {{Turret = turretList}}
                            self.data.params.form            = event.result.Form or {}
                            self.data.params.heroList        = event.result.HeroList
                            self:startBattle()
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false
                            application:showFlashNotice(event.desc or "进入战斗失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_ARENA_DEFENSE then
                    -- 竞技场防守
                    rpc:call("Arena.SetDefFormation", {Hero = form, Fairy = fairyID or 0}, function(event)
                        if event.status == Exceptions.Nil then
                            application:popScene()
                            application:showFlashNotice("保存阵容成功！")
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false

                            application:showFlashNotice("设置阵容失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_VEHICLE_DEFENSE then
                    -- 运镖防守

                    rpc:call("Vehicle.SetDefFormation", {Hero = form, Fairy = fairyID or 0}, function(event)
                        if event.status == Exceptions.Nil then
                            application:popScene()
                            application:showFlashNotice("保存阵容成功！")
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false

                            application:showFlashNotice("设置阵容失败")
                        end
                    end)

                elseif formType == GameCache.FORM_TYPE_HOME_DEFENSE then
                    -- 家园防守阵容

                    local form = {Hero = form, Fairy = fairyID or 0}
                    rpc:call("Home.SetDefFormation", {Target = self.data.params.buildNumber, Form = form}, function(event)
                        if event.status == Exceptions.Nil then
                            application:popScene()
                            application:showFlashNotice("保存阵容成功！")

                            self.data.params.callback()
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false

                            application:showFlashNotice("设置阵容失败")
                        end
                    end)
                elseif formType == GameCache.FORM_TYPE_LOOT_DEFENSE then
                    -- 夺宝防守阵容
                    
                    rpc:call("Loot.SetDefFormation", {Hero = form, Fairy = fairyID or 0}, function(event)
                        if event.status == Exceptions.Nil then
                            application:popScene()
                            application:showFlashNotice("保存阵容成功！")
                        else
                            BaseConfig.isCanClick = true
                            self.startingBattle = false

                            application:showFlashNotice("设置阵容失败")
                        end
                    end)
                else
                    CCLog("error: 未知战斗类型 ", battleType)
                    BaseConfig.isCanClick = true
                end
            end

            local heroLimitNum = nil
            local heroLimitMin = nil
            local heroLimitMax = nil
            if self.data.params.heroLimit then
                heroLimitNum = self.data.params.heroLimit.number
                heroLimitMin = self.data.params.heroLimit.minNumber
                heroLimitMax = self.data.params.heroLimit.maxNumber
            end

            local action = "战斗"
            local battleType = self.data.params.battleType
            if  battleType == nil then
                action = "保存"
            end

            local formUnitCount = #form
            if formUnitCount == 0 then
                application:dialog("", "没有星将上阵，不能" .. action .. "！", {"确定"})
                self.startingBattle = false
            elseif formUnitCount > 5 then
                application:dialog("", "星将数量异常，不能" .. action .. "！", {"确定"})
                self.startingBattle = false
            else
                local function checkFairyAndStartBattle()
                    if (self.data.fairyList ~= nil and #self.data.fairyList > 0) and (fairyID == 0 or fairyID == nil) then

                        local panel = require("tool.helper.CommonLayer").HintPanel("没有仙女出战，上仙您是否需要仙女上阵？", 
                            function() startBattle() end, 
                            true, 
                            function() 
                                self.startingBattle = false 
                                self:setHeroType("fairy")
                            end,
                            nil,
                            "不上",
                            "上仙女"
                        )

                        -- application:dialog("", "没有仙女上阵，你是否要继续?", {"继续", "返回"}, function(index, data, buttonText)
                        --     CCLog(vardump{index, data, buttonText})
                        --     if index == 2 then
                        --         startBattle()
                        --     else
                        --         self.startingBattle = false
                        --     end
                        -- end)
                    else
                        startBattle()
                    end
                end

                if heroLimitNum ~= nil then
                    if formUnitCount ~= heroLimitNum then
                        application:dialog("", string.format("上阵星将数量必须为 %d！", heroLimitNum), {"确定"})
                        self.startingBattle = false
                    else
                        checkFairyAndStartBattle()
                    end
                else
                    local enabled = true
                    if heroLimitMin ~= nil and formUnitCount < heroLimitMin then
                        enabled = false

                        application:dialog("", string.format("上阵星将数量必须大于等于 %d！", heroLimitMin), {"确定"})
                        self.startingBattle = false
                    end

                    if heroLimitMax ~= nil and formUnitCount > heroLimitMax then
                        enabled = false

                        application:dialog("", string.format("上阵星将数量必须小于等于 %d！", heroLimitMax), {"确定"})
                        self.startingBattle = false
                    end

                    if enabled then
                        checkFairyAndStartBattle()
                    end
                end
            end
        end
    end)

    coroutine.yield()

    local btnClose = ccui.Button:create("image/ui/img/btn/btn_598.png", "image/ui/img/btn/btn_598.png")
    btnClose:setName("btnClose")
    btnClose:setPosition(cc.p(PANEL_WIDTH - 20, PANEL_HEIGHT - 30))
    formPanel:addChild(btnClose)

    btnClose:addTouchEventListener(widget_click_listener(function(sender)
        application:popScene()

        if self.data.formType == GameCache.FORM_TYPE_HOME then
            application:dispatchCustomEvent(AppEvent.UI.Home.IsLoot, {IsLoot = false})
        end
    end))

    local formChangedHandler
    formChangedHandler = application:addEventListener(AppEvent.UI.Cache.FormChanged, function()
        if tolua.isnull(self) then
            application:removeEventListener(formChangedHandler)
        else
            CCLog("阵容有了变化，刷新一下")
            self:refreshForm()
        end
    end)

    self.inited = true

    self:formChanged()
end

function BattleFormLayer:addFormTipListener(node, parent)
    local TIPS_NODE_NAME = "form_name_tips"
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()

        local rect = node:getBoundingBox()
        local worldPos = parent:convertToWorldSpace(cc.p(0, 0))
        rect.x = rect.x + worldPos.x
        rect.y = rect.y + worldPos.y

            --CCLog(vardump({rect = rect, pos = location}, "two row rect and pos"))
        if cc.rectContainsPoint(rect, location) then
            CCLog("form tips onTouchBegan")
            local formData = self.data.formData
            local name = formData:getName()
            local desc = formData:getFormDesc(name)

            CCLog(vardump({name, desc}, "Tips"))

            if desc then
                local size = cc.size(300, 220)
                local tipsNode = cc.Node:create()
                tipsNode:setContentSize(size)

                local topsBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_092.png")
                topsBG:ignoreAnchorPointForPosition(true)
                topsBG:setContentSize(size)
                topsBG:setPosition(cc.p(0, 0))
                tipsNode:addChild(topsBG)

                local labelName = Common.finalFont("【" .. name .. "】", 0, 0, 25, cc.c3b(unpack(desc.color)), 0)
                labelName:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                labelName:setDimensions(size.width, size.height / 2)
                labelName:setPosition(cc.p(10, size.height / 4 * 3 - 15))
                labelName:setAnchorPoint(cc.p(0, 0.5))
                tipsNode:addChild(labelName)

                local richTextCond = ccui.RichText:create()
                richTextCond:ignoreContentAdaptWithSize(false)
                richTextCond:setContentSize(cc.size(270, 80))
                richTextCond:setPosition(cc.p(size.width / 2, size.height / 4 * 3 - 50))
                tipsNode:addChild(richTextCond)

                richTextCond:pushBackElement(ccui.RichElementText:create(1, cc.c3b(239, 209, 158), 255, "激活条件: ", BaseConfig.fontname, 20))
                richTextCond:pushBackElement(ccui.RichElementText:create(2, cc.c3b(unpack(desc.color)), 255, desc.condition[1], BaseConfig.fontname, 20))
                richTextCond:pushBackElement(ccui.RichElementText:create(3, cc.c3b(255, 255, 255), 255, desc.condition[2], BaseConfig.fontname, 20))

                local richTextEffect = ccui.RichText:create()
                richTextEffect:ignoreContentAdaptWithSize(false)
                richTextEffect:setContentSize(cc.size(270, 80))
                richTextEffect:setPosition(cc.p(size.width / 2, size.height / 4 - 20))
                tipsNode:addChild(richTextEffect)

                richTextEffect:pushBackElement(ccui.RichElementText:create(1, cc.c3b(239, 209, 158), 255, "加成效果: ", BaseConfig.fontname, 20))
                richTextEffect:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 255), 255, desc.effect[1], BaseConfig.fontname, 20))
                richTextEffect:pushBackElement(ccui.RichElementText:create(3, cc.c3b(255, 255, 255), 255, "  ", BaseConfig.fontname, 20))
                richTextEffect:pushBackElement(ccui.RichElementText:create(4, cc.c3b(239, 209, 158), 255, desc.effect[2], BaseConfig.fontname, 20))

                tipsNode:setName(TIPS_NODE_NAME)
                tipsNode:setPosition(cc.pAdd(cc.p(node:getPosition()), cc.p(-320, -250)))
                parent:addChild(tipsNode, 1000)
            end

            return true
        else
            return false
        end
    end

    local function onTouchEnded(touch, event)
        local tipsNode = parent:getChildByName(TIPS_NODE_NAME)
        if tipsNode then
            tipsNode:removeFromParent()
        end

        CCLog("form tips onTouchEnd")
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)

    self:setupUIComplete()
end

-- battleType = {"all", "near", "far", "veryFar"}
function BattleFormLayer:filterHeroList(heroIDList, battleType, heroLimit)
    local excludeList = self.data.params.excludeList

    local excludeHeroMap = {}
    if excludeList then
        for _, heroID in ipairs(excludeList) do
            excludeHeroMap[heroID] = true
        end
    end

    local resultHeroIDList = {}
    for idx, heroID in ipairs(self.data.heroIDList) do
        local heroBaseData = BaseConfig.GetHero(heroID, 1)

        while true do
            if excludeHeroMap[heroID] then
                break
            end

            if battleType == "all" then
                -- 不过滤
            elseif battleType == "near" then
                if heroBaseData.atkSkill ~= 1001 then
                    break
                end
            elseif battleType == "far" then
                if heroBaseData.atkSkill ~= 1002 then
                    break
                end
            elseif battleType == "veryFar" then
                if heroBaseData.atkSkill ~= 1003 then
                    break
                end
            else
                assert(false, "unknown battleType" .. tostring(battleType))
            end

            if heroLimit.gender then
                local ok = false
                local gender = heroLimit.gender
                if gender.male then
                    if heroBaseData.gender == 1 then
                        ok = true
                    end
                end

                if gender.female then
                    if heroBaseData.gender == 2 then
                        ok = true
                    end
                end

                if not ok then
                    break
                end
            end

            if heroLimit.level then
                local levelLimit = heroLimit.level
                local heroData = GameCache.GetHero(heroID)
                local heroLevel = heroData.Level
                local ok = false

                if heroLevel >= levelLimit.min and heroLevel <= levelLimit.max then
                    ok = true
                end

                if not ok then
                    break
                end
            end

            table.insert(resultHeroIDList, heroID)
            break
        end
    end

    return resultHeroIDList
end

function BattleFormLayer:setHeroType(type)
    assert(type == "all" or type == "near" or type == "far" or type == "veryFar" or type == "fairy")
    self.data.heroType = type

    local heroPanel = self.controls.heroPanel
    for _, heroType in ipairs(heroTypeList) do
        local button = heroPanel:getChildByName("btn_hero_type_" .. heroType.type)
        if button then
            local selected = false
            if heroType.type == self.data.heroType then
                selected = true
            end

            local img = selected and heroType.on or heroType.off --"image/ui/img/btn/btn_641.png" or "image/ui/img/btn/btn_642.png"
            button:loadTextures(img, img)
            button:setLocalZOrder(selected and 1 or -1)
        end
    end

    if type == "fairy" then
        self.data.curHeroIDList = {}
    else
        self.data.curHeroIDList = self:filterHeroList(self.data.heroIDList, type, self.data.params.heroLimit or {})
    end


--    if type == "all" then
--        self.data.curHeroIDList = self.data.heroIDList
--    elseif type == "near" then
--        local heroIDList = {}
--        for idx, heroID in ipairs(self.data.heroIDList) do
--            local heroBaseData = BaseConfig.GetHero(heroID, 1)
--            if heroBaseData.atkSkill == 1001 then
--                table.insert(heroIDList, heroID)
--            end
--        end
--        self.data.curHeroIDList = heroIDList
--    elseif type == "far" then
--        local heroIDList = {}
--        for idx, heroID in ipairs(self.data.heroIDList) do
--            local heroBaseData = BaseConfig.GetHero(heroID, 1)
--            if heroBaseData.atkSkill == 1002 then
--                table.insert(heroIDList, heroID)
--            end
--        end
--        self.data.curHeroIDList = heroIDList
--    elseif type == "veryFar" then
--        local heroIDList = {}
--        for idx, heroID in ipairs(self.data.heroIDList) do
--            local heroBaseData = BaseConfig.GetHero(heroID, 1)
--            if heroBaseData.atkSkill == 1003 then
--                table.insert(heroIDList, heroID)
--            end
--        end
--        self.data.curHeroIDList = heroIDList
--    elseif type == "fairy" then
--        self.data.curHeroIDList = {}
--
--        CCLog("fairy count :",  #self.data.fairyList)
--    end

    CCLog("hero count :",  #self.data.curHeroIDList)
    self:sortHeroIDList(self.data.curHeroIDList)
    self.controls.heroListTableView:reloadData()
end

function BattleFormLayer:createTowColumnHeroList()
    local formData = self.data.formData
    local HERO_CELL_HEIGHT = 120
    local HERO_CELL_WIDTH = 266

    local FAIRY_CELL_HEIGHT = 140
    local FAIRY_CELL_WIDTH = 266

    local function scrollViewDidScroll(view)
        print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        print("cell touched at index: " .. cell:getIdx())
    end

    local function cellSizeForTable(table,idx)
        if self.data.heroType == "fairy" then
            return FAIRY_CELL_HEIGHT, FAIRY_CELL_WIDTH
        else
            return HERO_CELL_HEIGHT, HERO_CELL_WIDTH
        end
    end

    local function tableHeroCellAtIndex(table, idx)
        --CCLog("tableHeroCellAtIndex " .. idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        local height, width = cellSizeForTable(table, idx)

        local isHeroLocked = self.data.reachMaxHeroNumber
        for i = 1, 2 do
            local heroID = self.data.curHeroIDList[idx * 2 + i]

            if heroID == nil then
                break
            end

            local heroData = GameCache.GetHero(heroID)

            local heroNode = HeroHeadNode.new(heroData, false)
            local heroInForm = formData:findByHeroID(heroData.ID) and true or false
            heroNode:setInForm(heroInForm)
            if heroInForm then
                heroNode:setLocked(false)
            else
                heroNode:setLocked(isHeroLocked)
            end
            heroNode:setPosition(cc.p(i == 1 and 75 or 195, 50))
            heroNode:setAnchorPoint(cc.p(0.5, 0.5))
            cell:addChild(heroNode)

            if self:isTower() then
                local hp = self:getHeroTowerHP(heroData.ID)
                if hp == nil then

                else
                    heroNode:showHP(hp)
                end
                heroNode:showIsInClinic(self:getHeroTowerIsInClinic(heroData.ID))
            end

            local function onTouchBegan(touch, event)
                local location = touch:getLocation()

                local rect = heroNode:getBoundingBox()
                local worldPos = heroNode:convertToWorldSpace(cc.p(0, 0))
                rect.x, rect.y = worldPos.x, worldPos.y

                --CCLog(vardump({rect = rect, pos = location}, "two row rect and pos"))
                if cc.rectContainsPoint(rect, location) then
                    CCLog("onTouchBegan")

                    heroNode:stopAllActions()
                    heroNode:runAction(cc.Sequence:create({
                        cc.CallFunc:create(function()
                            CCLog("heroID 1:", heroID)
                        end),
                        cc.DelayTime:create(0.5),
                        cc.CallFunc:create(function() 
                            CCLog("heroID 2:", heroID)

                            self:removeChildByName("hero_tip")
                            local tipNode = HeroTip.new(heroID)
                            tipNode:setPosition(cc.p(360, 160))
                            tipNode:setName("hero_tip")
                            self:addChild(tipNode)
                        end),
                    }))

                    return true
                else
                    return false
                end
            end

            local function onTouchEnded(touch, event)
                CCLog("onTouchEnded")
                heroNode:stopAllActions()
                self:removeChildByName("hero_tip")

                if heroNode:isLocked() then
                    return 
                end

                local location = touch:getLocation()
                local startLocation = touch:getStartLocation()
                local distance = cc.pGetDistance(location, startLocation)

                if distance < 10 then
                    if self:isTower() then
                        local enabled, reason = heroNode:isTowerEnabled()
                        if enabled then
                            self:selectHero(heroNode)
                        else
                            application:showFlashNotice(string.format("星将 %s %s, 不能上阵！", heroNode:getName(), reason))
                        end
                    else
                        self:selectHero(heroNode)
                    end
                end
            end

            local listener = cc.EventListenerTouchOneByOne:create()
            listener:setSwallowTouches(false)
            listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
            heroNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, heroNode)
        end

        return cell
    end

    local function tableFairyCellAtIndex(table, idx)
        CCLog("tableFairyCellAtIndex " .. idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        local height, width = cellSizeForTable(table, idx)

        for i = 1, 2 do
            local fairyData = self.data.fairyList[idx * 2 + i]
            if fairyData == nil then
                break
            end

            local fairyNode = FairyHeadNode.new(fairyData)
            fairyNode:setPosition(cc.p(i == 1 and 75 or 195, 50))
            fairyNode:setAnchorPoint(cc.p(0.5, 0.5))
            fairyNode:setInForm(fairyData.ID == formData:getPlayFairyID())
            cell:addChild(fairyNode)

            local function onTouchBegan(touch, event)
                local location = touch:getLocation()

                local rect = fairyNode:getBoundingBox()
                local worldPos = fairyNode:convertToWorldSpace(cc.p(0, 0))
                rect.x, rect.y = worldPos.x, worldPos.y

                --CCLog(vardump({rect = rect, pos = location}, "two row rect and pos"))
                if cc.rectContainsPoint(rect, location) then
                    return true
                else
                    return false
                end
            end

            local function onTouchEnded(touch, event)
                --CCLog("onTouchEnded")
                local location = touch:getLocation()
                local startLocation = touch:getStartLocation()
                local distance = cc.pGetDistance(location, startLocation)

                if distance < 10 then
                    self:selectFairy(fairyNode)
                end
            end

            local listener = cc.EventListenerTouchOneByOne:create()
            listener:setSwallowTouches(false)
            listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
            fairyNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, fairyNode)
        end

        return cell
    end


    local function tableCellAtIndex(table, idx)
        --CCLog("tableCellAtIndex", self.data.heroType, idx)
        if self.data.heroType == "fairy" then
            return tableFairyCellAtIndex(table, idx)
        else
            return tableHeroCellAtIndex(table, idx)
        end
    end

    local function numberOfCellsInTableView(table)
        local count = 0
        if self.data.heroType == "fairy" then
            count = math.floor((#self.data.fairyList + 1) / 2)
        else
            count = math.floor((#self.data.curHeroIDList + 1) / 2)
        end

        --CCLog("numberOfCellsInTableView", self.data.heroType, count)
        return count
    end

    local tableView = cc.TableView:create(cc.size(262, 550))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(10, 20))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    return tableView
end

function BattleFormLayer:getSlotPos(x, y)
    if type(x) == "table" then
        local slot = x
        x, y = slot.x, slot.y
    end

    local pos = self.data.slotPosCache[x .. ":" .. y]
    if pos == nil then
        pos = cc.p((x - 0.5) * 150, (y - 0.5) * 80 + 100)
        self.data.slotPosCache[x .. ":" .. y] = pos
    end

    return pos
end

function BattleFormLayer:getSlotZOrder(x, y)
    --CCLog(vardump({x = x, y = y}, "getSlotZOrder"))
    if type(x) == "table" then
        local slot = x
        x, y = slot.x, slot.y
    end

    local zorder = self.data.slotZOrderCache[x .. ":" .. y]
    if zorder == nil then
        zorder = (3 - y) * 100 + (3 - x)
        self.data.slotZOrderCache[x .. ":" .. y] = zorder
    end

    return zorder
end

function BattleFormLayer:createHeroSlotList()
    local formData = self.data.formData
    local slotsPanel = self.controls.slotsPanel
    for y = 3, 1, -1 do
        for x = 1, 3 do
            if formData:isUsed(x, y) then
                local pos = self:getSlotPos(x, y)

                local heroShadow = cc.Sprite:create("image/ui/img/btn/btn_279.png")
                local shadowName = string.format("shadow_%d_%d", x, y)
                heroShadow:setName(shadowName)
                --heroShadow:setScale(display.contentScaleFactor)
                heroShadow:setAnchorPoint(cc.p(0.5, 0.5))
                heroShadow:setPosition(pos)
                slotsPanel:removeChildByName(shadowName)
                slotsPanel:addChild(heroShadow)

                local heroID = formData:getHeroID(x, y)
                if heroID ~= nil and heroID ~= 0 then
                    local heroAni = HeroAniNode.new(heroID)
                    --heroAni:setGlobalZOrder(1)
                    heroAni:setLocalZOrder(self:getSlotZOrder(x, y))
                    self:setDragEventListener(heroAni)
                    heroAni:setPosition(pos)
                    heroAni:setSlot({x = x, y = y})
                    local heroAniName = string.format("heroAniNode_%d", heroID)
                    heroAni:setName(heroAniName)
                    slotsPanel:removeChildByName(heroAniName)
                    slotsPanel:addChild(heroAni)
                    self.data.heroAniMap[heroID] = heroAni
                else 
                    local npcID = formData:getNpcID(x, y)
                    if npcID ~= nil and npcID ~= 0 then
                        local heroAni = HeroAniNode.new(npcID, true)
                        --heroAni:setGlobalZOrder(1)
                        heroAni:setLocalZOrder(self:getSlotZOrder(x, y))
                        self:setDragEventListener(heroAni)
                        heroAni:setPosition(pos)
                        heroAni:setSlot({x = x, y = y})
                        local heroAniName = string.format("heroAniNode_%d", npcID)
                        heroAni:setName(heroAniName)
                        slotsPanel:removeChildByName(heroAniName)
                        slotsPanel:addChild(heroAni)
                        self.data.heroAniMap[npcID] = heroAni
                    end 
                end
            end
        end
    end

    self:formChanged()
    self:fairyChanged()
end

function BattleFormLayer:clearHeroSlotList()
    local slotPanel = self.controls.slotsPanel
    local formData = self.data.formData
    for y = 3, 1, -1 do
        for x = 1, 3 do
            local shadowName = string.format("shadow_%d_%d", x, y)
            local heroShadow = slotPanel:getChildByName(shadowName)

            if heroShadow then
                heroShadow:removeFromParent()
            end
        end
    end

    for heroID, heroAni in pairs(self.data.heroAniMap) do
        if heroAni and not tolua.isnull(heroAni) then
           heroAni:removeFromParent()
        end
    end
    self.data.heroAniMap = {}
end

function BattleFormLayer:getTFP()
    local CalHeroAttr = require("tool.helper.CalHeroAttr")

    local form = self.data.formData:getForm()
    local fairyID = self.data.formData:getPlayFairyID()

    return CalHeroAttr.FormTFP({Hero = form, Fairy = fairyID})
    -- local TFP = 0
    -- local slotPanel = self.controls.slotsPanel
    -- local formData = self.data.formData
    -- for y = 3, 1, -1 do
    --     for x = 1, 3 do
    --         local heroAniName = string.format("heroAniNode_%d", formData:getHeroID(x, y))
    --         local heroAni = slotPanel:getChildByName(heroAniName)

    --         if heroAni then
    --             TFP = TFP + heroAni:getTFP()
    --         end
    --     end
    -- end

    -- return TFP
end

function BattleFormLayer:getHeroAniNode(slot)
    local slotPanel = self.controls.slotsPanel
    local formData = self.data.formData

    local heroID = formData:getHeroID(slot.x, slot.y) or formData:getNpcID(slot.x, slot.y)
    local heroAni = self.data.heroAniMap[heroID]

    return heroAni
end

function BattleFormLayer:getHeroShadow(slot)
    local slotPanel = self.controls.slotsPanel
    local shadowName = string.format("shadow_%d_%d", slot.x, slot.y)

    --CCLog("getHeroShadow", shadowName)
    local children = slotPanel:getChildren()
    for idx, node in ipairs(children) do
        local name = node:getName()
        --CCLog("Hero[" .. idx .. "]:", name)
    end

    local heroShadow = slotPanel:getChildByName(shadowName)

    return heroShadow
end

function BattleFormLayer:updateHeroSlotList()
    self:clearHeroSlotList()
    self:createHeroSlotList()
end

function BattleFormLayer:updateHeroShadow()
    for x = 1, 3 do
        for y = 1, 3 do
            local heroNode = self:getHeroAniNode({x = x, y = y})
            local heroShadow = self:getHeroShadow({x = x, y = y})
            local shadowImage = "image/ui/img/btn/btn_279.png"
            if heroNode then
                shadowImage = heroNode:getShadowImage()
            end

            if heroShadow then
                heroShadow:setTexture(shadowImage)
            end
        end
    end
end

function BattleFormLayer:formNameChanged()
    local formData = self.data.formData

    local name = formData:getName()
    local icon = formData:getIcon(name)
    self.controls.labelFormName:setString(name)

    CCLog("form icon:", icon)
    if icon then
        self.controls.formIcon:setTexture(icon)
        self.controls.formIcon:setVisible(true)
    else
        self.controls.formIcon:setVisible(false)
    end

    self:updateHeroShadow()
end

function BattleFormLayer:formChanged()
    if not self.inited then
        return 
    end

    self:formNameChanged()
    self:updateHeroShadow()

    self.data.reachMaxHeroNumber = self:reachMaxHeroNumber()

    local tableView = self.controls.heroListTableView
    local offset = tableView:getContentOffset()
    tableView:reloadData()
    tableView:setContentOffset(offset)

    local len = #tostring(self:getTFP())
    local scale = 1
    if len > 6 then
        scale = 1-(len-6)*0.1
    end
    
    self.controls.labelTFP:setString("" .. self:getTFP())
    self.controls.labelTFP:setScale(scale)
end

function BattleFormLayer:selectHero(heroHeadNode)
    CCLog("BattleFormLayer:selectHero()")
    if self:isHeroMoveDisabled() then
        CCLog("正在操作中，不作为")
        return
    end

    local heroID = heroHeadNode:getHeroID()

    local slot = self.data.formData:findByHeroID(heroID)
    CCLog(vardump({slot = slot, heroID = heroID}))
    if slot then
        CCLog("下阵")
        self:leaveStage(heroHeadNode)
    else
        CCLog("上阵")
        self:enterStage(heroHeadNode)
    end
end

function BattleFormLayer:selectFairy(fairyHeadNode)
    local fairyData = fairyHeadNode:getFairyData()
    CCLog("selectFairy:", fairyData.Name)

    local playFairyID = self.data.formData:getPlayFairyID()
    if playFairyID and playFairyID ~= 0 then
        if fairyData.ID == playFairyID then
            self.data.formData:setPlayFairyID(nil)
            CCLog("仙女下阵")
        else
            CCLog("仙女上阵")
            self.data.formData:setPlayFairyID(fairyData.ID)
        end
    else
        CCLog("仙女上阵")
        self.data.formData:setPlayFairyID(fairyData.ID)
    end

    self:formChanged()
    self:fairyChanged()
end

function BattleFormLayer:playSound(heroID)
    local soundList = BaseConfig.GetSoundHero(heroID).Speak

    if soundList ~= nil and #soundList > 0 then
        local sound = soundList[math.random(1, #soundList)]
        local path = "audio/hero/"..sound ..".mp3"
        Common.playSound(path)
    end
end

-- 英雄上阵
function BattleFormLayer:enterStage(heroHeadNode)
    local heroID = heroHeadNode:getHeroID()

    local battleType = self.data.params.battleType
    CCLog("战斗类型:", battleType)

    if battleType == "Tower" then
        local towerHP = self:getHeroTowerHP(heroID)
        if towerHP == nil then
            application:showFlashNotice(string.format("星将 %s 不能上阵！", heroHeadNode:getName()))
            return
        elseif towerHP <= 0 then
            application:showFlashNotice(string.format("星将 %s 已经死亡!！", heroHeadNode:getName()))
            return
        end
    end

    local heroType = heroHeadNode:getHeroType()
    local formData = self.data.formData
    local slot = formData:findFreeSlot(heroType)

    if slot then
        if battleType ~= "GUIDE" then
            self:playSound(heroID)
        end
        
        Common.CloseGuideLayer({1,3,8})

        self:disabledHeroMove()

        local slotsPanel = self.controls.slotsPanel
        local pos = cc.p(heroHeadNode:getPosition())
        local worldPos = heroHeadNode:getParent():convertToWorldSpace(pos)
        local panelPos = slotsPanel:convertToNodeSpace(worldPos)
        CCLog(vardump({panelPos = panelPos, pos = pos, worldPos = worldPos}, "Hero Enter Stage Pos"))
        local heroAni = HeroAniNode.new(heroHeadNode:getHeroID())
        --heroAni:setGlobalZOrder(1)
        heroAni:setLocalZOrder(self:getSlotZOrder(slot.x, slot.y))
        self:setDragEventListener(heroAni)
        heroAni:setPosition(cc.pAdd(panelPos, cc.p(0, -65)))
        heroAni:setSlot({x = slot.x, y = slot.y})
        heroAni:setName(json.encode({type = "heroMoving"}))
        slotsPanel:addChild(heroAni)

        local destPos = self:getSlotPos(slot.x, slot.y)
        heroAni:runAction(cc.Sequence:create({
            cc.MoveTo:create(0.3, destPos),
            cc.CallFunc:create(function()
                local x = slot.x
                local y = slot.y
                formData:setHeroID(x, y, heroID)

                heroAni:setSlot({x = x, y = y})
                local heroAniName = string.format("heroAniNode_%d", heroID)
                heroAni:setName(heroAniName)
                self.data.heroAniMap[heroID] = heroAni
                self:formChanged()

                self:enableHeroMove()

                Common.OpenGuideLayer({1,3,8})
            end),
        }))
    else
        CCLog(vardump(formData.slots, "没有找到可用的Slot"))
    end
end

-- 英雄下阵
function BattleFormLayer:leaveStage(heroHeadNode)
    local heroID = heroHeadNode:getHeroID()
    local slotsPanel = self.controls.slotsPanel
    local pos = cc.p(heroHeadNode:getPosition())
    local worldPos = heroHeadNode:getParent():convertToWorldSpace(pos)
    local panelPos = slotsPanel:convertToNodeSpace(worldPos)
    local formData = self.data.formData

    local heroAni = self.data.heroAniMap[heroID]
    self:disabledHeroMove()
    heroAni:runAction(cc.Sequence:create({
        cc.MoveTo:create(0.3, cc.pAdd(panelPos, cc.p(0, -65))),
        cc.CallFunc:create(function()
            local slot = heroAni:getSlot()
            formData:setHeroID(slot.x, slot.y, 0)
            self:formChanged()

            self:enableHeroMove()
        end),
        cc.RemoveSelf:create(),
    }))

--    local children = slotsPanel:getChildren()
--    for idx, node in ipairs(children) do
--        local name = node:getName()
--        CCLog("Hero[" .. idx .. "]:", name)
--        local nodeHeroID = string.match("hero_(%d+)")
--        if nodeHeroID == heroID then
--
--            self:disabledHeroMove()
--            node:runAction(cc.Sequence:create({
--                cc.MoveTo:create(0.3, cc.pAdd(panelPos, cc.p(0, -65))),
--                cc.CallFunc:create(function()
--                    local slot = node:getSlot()
--                    formData:setHeroID(slot.x, slot.y, 0)
--                    self:formChanged()
--                    self.controls.labelTFP:setString("" .. self:getTFP())
--
--                    self:enableHeroMove()
--                end),
--                cc.RemoveSelf:create(),
--            }))
--            break
--        end
--    end
end

function BattleFormLayer:findNeareastAvailableSlot(heroAnidNode, pos)
    local formData = self.data.formData
    --CCLog({srcSlot = heroAnidNode:getSlot(), pos = pos})

    local srcSlot = heroAnidNode:getSlot()
    local slotInfoList = {}
    for x = 1, 3 do
        for y = 1, 3 do
            local slotPos = self:getSlotPos(x, y)
            local distance = cc.pGetDistance(pos, slotPos)
            table.insert(slotInfoList, {distance = distance, slot = {x = x, y = y}, pos = slotPos})
        end
    end

    table.sort(slotInfoList, function(slot1, slot2) return slot1.distance < slot2.distance end)
    for i = 1, 9 do
        local slotInfo = slotInfoList[i]
        local destSlot = slotInfo.slot

        --CCLog(vardump({srcSlot = srcSlot, destSlot = destSlot, destColCount = formData:colCount(destSlot.y), destIsUsed = formData:isUsed(destSlot.x, destSlot.y) }, "SlotInfo Of " .. i))

        if srcSlot.x == destSlot.x and srcSlot.y == destSlot.y then
            -- 返回原来的位置
            slotInfo.back = true
            return slotInfo
        elseif formData:isUsed(destSlot.x, destSlot.y) then
            if formData:isHero(destSlot.x, destSlot.y) then
                -- 原位置与目标位置的英雄交换
                slotInfo.swap = true
            else
                -- 原位置直接到目标位置
                slotInfo.move = true
            end
            return slotInfo
        elseif srcSlot.x ~= destSlot.x and formData:colCount(destSlot.x) == 1 and not formData:isUsed(destSlot.x, destSlot.y)  then
            -- 直接移动到目标位置，并且做一定的调整
            slotInfo.adjust = true

            slotInfo.heroMoves = {}
            slotInfo.shadowMoves = {}

            if destSlot.y == 1 then
                table.insert(slotInfo.heroMoves,   {from = {x = destSlot.x, y = 2}, to = {x = destSlot.x, y = 3}})
                table.insert(slotInfo.shadowMoves, {from = {x = destSlot.x, y = 2}, to = {x = destSlot.x, y = 3}})
            elseif destSlot.y == 3 then
                table.insert(slotInfo.heroMoves,   {from = {x = destSlot.x, y = 2}, to = {x = destSlot.x, y = 1}})
                table.insert(slotInfo.shadowMoves, {from = {x = destSlot.x, y = 2}, to = {x = destSlot.x, y = 1}})
            end

            if srcSlot.y == 1 then
                table.insert(slotInfo.heroMoves,   {from = {x = srcSlot.x, y = 3}, to = {x = srcSlot.x, y = 2}})
                table.insert(slotInfo.shadowMoves, {from = {x = srcSlot.x, y = 3}, to = {x = srcSlot.x, y = 2}})
            elseif srcSlot.y == 3 then
                table.insert(slotInfo.heroMoves,   {from = {x = srcSlot.x, y = 1}, to = {x = srcSlot.x, y = 2}})
                table.insert(slotInfo.shadowMoves, {from = {x = srcSlot.x, y = 1}, to = {x = srcSlot.x, y = 2}})
            end

            table.insert(slotInfo.shadowMoves,     {from = {x = srcSlot.x, y = srcSlot.y}, to = {x = destSlot.x, y = destSlot.y}})

            return slotInfo
        end

    end
    return nil
end

function BattleFormLayer:setDragEventListener(heroAnidNode)
    local startPos = nil
    local function onTouchBegan(touch, event)
        --CCLog("onTouchBegan")
        local location = touch:getLocation()

        local rect = heroAnidNode:getBoundingBox()
        local worldPos = heroAnidNode:convertToWorldSpace(cc.p(0, 0))
        rect.x, rect.y = worldPos.x, worldPos.y
        -- TODO:如果英雄节点没有大小，就设置为{width = 100, height = 150}
        if rect.width == 0 then
            rect.x = rect.x - 100 / 2
            rect.y = rect.y - 50 / 2
            rect.width = 100
            rect.height = 120
        end

        --CCLog(vardump({rect = rect, pos = location}, "rect and pos"))
        if (not self:isHeroMoveDisabled()) and cc.rectContainsPoint(rect, location) then
            if GameCache.NewbieGuide.Step == 5 then
                CCLog(vardump({rect = rect, name = heroAnidNode:getName(), slot = heroAnidNode:getSlot()}, "GUIDE:"))
                local slot = heroAnidNode:getSlot()
                if slot.x ~= 2 or slot.y ~= 1 then
                    return false
                end
            end

            startPos = cc.p(heroAnidNode:getPosition())
            self:disabledHeroMove()
            return true
        else
            return false
        end
    end

    local function onTouchMoved(touch, event)
        --CCLog("onTouchMoved")
        local location = touch:getLocation()
        local preLocation = touch:getPreviousLocation()

        local pos = cc.p(heroAnidNode:getPosition())
        heroAnidNode:setPosition(cc.pAdd(pos, cc.pSub(location, preLocation)))
    end

    local function onTouchEnded(touch, event)
        CCLog("onTouchEnded")

        local startLocation = touch:getStartLocation()
        local location = touch:getLocation()

        local distance = cc.pGetDistance(startLocation, location)
        if distance < 60 then
            heroAnidNode:runAction(cc.Sequence:create({
                cc.MoveTo:create(0.3, startPos),
                cc.CallFunc:create(function() self:enableHeroMove() end)
            }))
        else
            local pos = self.controls.slotsPanel:convertToNodeSpace(location)
            local srcSlot = heroAnidNode:getSlot()
            local srcSlotPos = self:getSlotPos(srcSlot)

            local slotInfo = self:findNeareastAvailableSlot(heroAnidNode, pos)
            local formData = self.data.formData

            if GameCache.NewbieGuide.Step == 1 then
                CCLog(vardump(slotInfo, "slotInfo"))
                local moveList = slotInfo.heroMoves
                if  slotInfo.distance < 100 and slotInfo.adjust and moveList and #moveList == 2 and
                    moveList[1].from.x == 3 and moveList[1].from.y == 2 and moveList[1].to.x == 3 and moveList[1].to.y == 3 and
                    moveList[2].from.x == 2 and moveList[2].from.y == 3 and moveList[2].to.x == 2 and moveList[2].to.y == 2 
                then
                    Common.CloseGuideLayer({1})
                    Common.OpenGuideLayer({1})
                else
                    heroAnidNode:runAction(cc.Sequence:create({
                        cc.MoveTo:create(0.3, startPos),
                        cc.CallFunc:create(function() self:enableHeroMove() end)
                    }))
                    return
                end
            end

            --CCLog(vardump(slotInfo, "SlotInfo"))
            if slotInfo and slotInfo.distance < 100 then
                if slotInfo.back then
                    heroAnidNode:runAction(cc.Sequence:create({
                        cc.MoveTo:create(0.3, slotInfo.pos),
                        cc.CallFunc:create(function()
                            self:updateHeroShadow()
                            self:enableHeroMove()
                        end)
                    }))
                elseif slotInfo.swap then
                    local destHeroAniNode = self:getHeroAniNode(slotInfo.slot)
                    destHeroAniNode:runAction(cc.Sequence:create({
                        cc.MoveTo:create(0.3, srcSlotPos),
                        cc.CallFunc:create(function()
                            local slot = heroAnidNode:getSlot()
                            if not destHeroAniNode.isNpc then
                                formData:setHeroID(srcSlot.x, srcSlot.y, destHeroAniNode:getHeroID())
                            else
                                formData:setNpcID(srcSlot.x, srcSlot.y, destHeroAniNode:getHeroID())
                            end
                            destHeroAniNode:setSlot(srcSlot.x, srcSlot.y)
                            destHeroAniNode:setLocalZOrder(self:getSlotZOrder(srcSlot.x, srcSlot.y))
                        end),
                    }))

                    heroAnidNode:runAction(cc.Sequence:create({
                        cc.MoveTo:create(0.3, slotInfo.pos),
                        cc.CallFunc:create(function()
                            if not heroAnidNode.isNpc then
                                formData:setHeroID(slotInfo.slot.x, slotInfo.slot.y, heroAnidNode:getHeroID())
                            else
                                formData:setNpcID(slotInfo.slot.x, slotInfo.slot.y, heroAnidNode:getHeroID())
                            end
                            heroAnidNode:setSlot(slotInfo.slot.x, slotInfo.slot.y)
                            heroAnidNode:setLocalZOrder(self:getSlotZOrder(slotInfo.slot.x, slotInfo.slot.y))
                            self:updateHeroShadow()

                            self:enableHeroMove()
                        end)
                    }))
                elseif slotInfo.move then
                    heroAnidNode:runAction(cc.Sequence:create({
                        cc.MoveTo:create(0.3, slotInfo.pos),
                        cc.CallFunc:create(function()
                            formData:setHeroID(srcSlot.x, srcSlot.y, 0)
                            if not heroAnidNode.isNpc then
                                formData:setHeroID(slotInfo.slot.x, slotInfo.slot.y, heroAnidNode:getHeroID())
                            else
                                formData:setNpcID(slotInfo.slot.x, slotInfo.slot.y, heroAnidNode:getHeroID())
                            end
                            heroAnidNode:setSlot(slotInfo.slot.x, slotInfo.slot.y)
                            heroAnidNode:setLocalZOrder(self:getSlotZOrder(slotInfo.slot.x, slotInfo.slot.y))
                            self:updateHeroShadow()

                            self:enableHeroMove()
                        end)
                    }))
                elseif slotInfo.adjust then
                    CCLog(vardump(slotInfo.heroMoves, "slotInfo.adjust"))

                    for _, move in ipairs(slotInfo.heroMoves) do
                        local fromSlot = move.from
                        local fromPos = self:getSlotPos(fromSlot)
                        local toSlot = move.to
                        local toPos = self:getSlotPos(toSlot)

                        local fromHeroAniNode = self:getHeroAniNode(fromSlot)
                        if fromHeroAniNode then
                            fromHeroAniNode:runAction(cc.Sequence:create({
                                cc.MoveTo:create(0.3, toPos),
                                cc.CallFunc:create(function()
                                    formData:unset(fromSlot.x, fromSlot.y)
                                    if not fromHeroAniNode.isNpc then
                                        formData:setHeroID(toSlot.x, toSlot.y, fromHeroAniNode:getHeroID())
                                    else
                                        formData:setNpcID(toSlot.x, toSlot.y, fromHeroAniNode:getHeroID())
                                    end
                                    fromHeroAniNode:setSlot(toSlot.x, toSlot.y)
                                    fromHeroAniNode:setLocalZOrder(self:getSlotZOrder(toSlot.x, toSlot.y))
                                end),
                            }))
                        else
                            self:runAction(cc.Sequence:create({
                                cc.DelayTime:create(0.3),
                                cc.CallFunc:create(function()
                                    formData:unset(fromSlot.x, fromSlot.y)
                                    formData:setHeroID(toSlot.x, toSlot.y, 0)
                                    formData:use(toSlot.x, toSlot.y)
                                end),
                            }))
                        end
                    end

                    for _, move in ipairs(slotInfo.shadowMoves) do
                        local fromSlot = move.from
                        local fromPos = self:getSlotPos(fromSlot)
                        local toSlot = move.to
                        local toPos = self:getSlotPos(toSlot)

                        local shadowNode = self:getHeroShadow(fromSlot)
                        if shadowNode then
                            shadowNode:runAction(cc.Sequence:create({
                                cc.MoveTo:create(0.3, toPos),
                                cc.CallFunc:create(function()
                                    local shadowName = string.format("shadow_%d_%d", toSlot.x, toSlot.y)
                                    shadowNode:setName(shadowName)
                                end),
                            }))
                        end
                    end

                    heroAnidNode:runAction(cc.Sequence:create({
                        cc.MoveTo:create(0.3, slotInfo.pos),
                        cc.CallFunc:create(function()
                            formData:unset(srcSlot.x, srcSlot.y)
                            if not heroAnidNode.isNpc then
                                formData:setHeroID(slotInfo.slot.x, slotInfo.slot.y, heroAnidNode:getHeroID())
                            else
                                formData:setNpcID(slotInfo.slot.x, slotInfo.slot.y, heroAnidNode:getHeroID())
                            end
                            heroAnidNode:setSlot(slotInfo.slot.x, slotInfo.slot.y)
                            heroAnidNode:setLocalZOrder(self:getSlotZOrder(slotInfo.slot.x, slotInfo.slot.y))

                            self:enableHeroMove()
                        end)
                    }))

                    self:runAction(cc.Sequence:create({
                        cc.DelayTime:create(0.35),
                        cc.CallFunc:create(function()
                            self:formChanged()
                        end),
                    }))

                end
            else
                heroAnidNode:runAction(cc.Sequence:create({
                    cc.FadeOut:create(0.1),
                    cc.CallFunc:create(function()
                        formData:setHeroID(srcSlot.x, srcSlot.y, 0)
                        self:formChanged()

                        self:enableHeroMove()
                    end),
                    cc.RemoveSelf:create(),
                }))
            end
        end
    end

    local function onTouchCanelled(touch, event)
        --CCLog("onTouchCanelled")
        local startPos = touch:getStartLocation()
        local pos = touch:getLocation()

        heroAnidNode:runAction(cc.Sequence:create({
            cc.FadeOut:create(0.1),
            cc.CallFunc:create(function() self:enableHeroMove() end),
            cc.RemoveSelf:create(),
        }))
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCanelled, cc.Handler.EVENT_TOUCH_CANCELLED)

    heroAnidNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, heroAnidNode)
end

function BattleFormLayer:createStart(node)
    local size = node:getContentSize()

    for i = 1, 20 do
        local x = math.random(1, size.width)
        local y = math.random(math.floor(size.height * 0.8), size.height)

        local star = cc.Sprite:create("image/ui/img/btn/btn_672.png")
        local scale = 0.8 + math.random()
        star:setScale(scale)
        star:setPosition(cc.p(x, y))
        star:setOpacity(0)
        local action = cc.Sequence:create({
            cc.DelayTime:create(math.random(5, 10)),
            cc.FadeIn:create(0.5),
            cc.DelayTime:create(math.random(0.3, 1.5)),
            cc.FadeOut:create(0.8),
        })
        star:runAction(cc.RepeatForever:create(action))
        node:addChild(star)
    end
end

function BattleFormLayer:createMeteor(node)
    local size = node:getContentSize()
    local isRepeatPlay = true
    local beginPos = {{size.width * 0.7}, {size.width * 0.8}, {size.width * 0.95}, {size.width * 1.1}}
    local starNum = math.random(1, 3)

    for i=1,starNum do
        local star = cc.Sprite:create("image/ui/img/btn/btn_589.png")
        node:addChild(star)
        local scaleValue = math.random(1, 2)
        star:setScale(scaleValue)

        local posIdx = math.random(1, (#beginPos))
        local beginPosX = beginPos[posIdx][1]
        local beginPosY = size.height * 1.1
        star:setPosition(beginPosX, beginPosY)
        table.remove(beginPos, posIdx)

        local lengthRom = math.random(3, 6)
        local length = size.width * 0.1 * lengthRom
        local endPosX = beginPosX - length / (math.cos(math.rad(45)))
        local endPosY = beginPosY - length * (math.sin(math.rad(45)))
        local time = 2
        local move = cc.MoveTo:create(time, cc.p(endPosX, endPosY))
        local fadeout = cc.FadeOut:create(time)
        local spawn = cc.Spawn:create(move, fadeout)
        local remove = cc.RemoveSelf:create()
        star:runAction(cc.Sequence:create(spawn, cc.CallFunc:create(function()
            if isRepeatPlay then
                isRepeatPlay = false
                self:createMeteor(node)
            end
        end), remove))
    end
end

return BattleFormLayer
