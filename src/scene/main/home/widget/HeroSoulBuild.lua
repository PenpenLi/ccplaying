local HeroSoulBuild = class("HeroSoulBuild", require("scene.main.home.widget.BuildNode"))
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")
local CommonLayer = require("tool.helper.CommonLayer")
local SoulGoodsInfo = require("scene.main.home.widget.SoulGoodsInfo")
local scheduler = cc.Director:getInstance():getScheduler()

local buildOpenLevel = 30
local resetVipLevel = 10
local soltOpenVipLevel = 5

local SOULTYPE_1 = 1  -- 近战类型
local SOULTYPE_2 = SOULTYPE_1 + 1 -- 远程类型
local SOULTYPE_3 = SOULTYPE_2 + 1 -- 超远类型

local WATERTAG = 1 -- 判断已开的研究位是否有星将
local SOULTAG = WATERTAG + 1
local LOCKTAG = SOULTAG + 1
local WATEREFFECTTAG = LOCKTAG + 1

local ISRESEARCHING = 0 -- 展示中的星将是否正在被研究

local OPENRESEARCT = 0 -- 研究位已开
local UNOPENRESEARCT = -1 -- 研究位未开

-- 通过收获时间判断是未培育状态还是可收获状态
local COLLECT_COLLECTSTATUS = 0
local COLLECT_NOTRESEARCHSTATUS = -1

local totalFreeTimes = 3
local refreshCostPrice = 50
local resetFreeTimesCostPrice = 800
local doubleCollectCostPrice = 300

function HeroSoulBuild:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildConfig = BaseConfig.getHomeSoul(buildInfo.Level)
    self.data.maxLevel = BaseConfig.homeSoulMaxLevel
    self.data.buildName = "将魂研究院"
    self.data.buildDesc = "将魂研究院中可生产指定的星将魂魄"
    HeroSoulBuild.super.ctor(self, number, buildInfo, isOwnHome, topNode)
    
    self.data.firstPanelSpriTab = {{"image/ui/img/btn/btn_1342.png", "image/ui/img/btn/btn_1343.png"},
                                    {"image/ui/img/btn/btn_1224.png", "image/ui/img/btn/btn_1229.png"},
                                    {"image/ui/img/btn/btn_1222.png", "image/ui/img/btn/btn_1227.png"},
                                    {"image/ui/img/btn/btn_1221.png", "image/ui/img/btn/btn_1226.png"}}
    self.data.firstPanelCenterSpri = "image/ui/img/btn/btn_1347.png"

end

function HeroSoulBuild:createBuildAccessory()
    local selfBuildLevel = GameCache.Avatar.Level
    if self.data.isOwnHome then
        if selfBuildLevel < buildOpenLevel then
            self.controls.build:setNorGLProgram(false)
        end
    else
        local enemyBuildLevel = self.data.enemyInfo.Level
        if (selfBuildLevel < buildOpenLevel) or (enemyBuildLevel < buildOpenLevel) then
            self.controls.build:setNorGLProgram(false)
        end

    end

    HeroSoulBuild.super.createBuildAccessory(self)
    self.controls.canCollect:setChildTexture("image/ui/img/btn/btn_1347.png")    
end

function HeroSoulBuild:setGetBtnIsTouchEnabled()
    -- body
end

function HeroSoulBuild:buildFunc()
    local function clickFunc()
        if self.data.isOwnHome then
           self:syncHomeData(function()
                self.data.isSettleBuildPanel = true
                self:buildFirstPanel(-30, -110)
            end)
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

    local selfBuildLevel = GameCache.Avatar.Level
    if self.data.isOwnHome then
        if selfBuildLevel < buildOpenLevel then
            application:showFlashNotice("上仙,你到了"..buildOpenLevel.."级就可以使用了")
        else
            clickFunc()
        end
    else
        local enemyBuildLevel = self.data.enemyInfo.Level
        if (selfBuildLevel < buildOpenLevel) and (enemyBuildLevel < buildOpenLevel) then
            application:showFlashNotice("上仙,你到了"..buildOpenLevel.."级就可以使用了")
        elseif selfBuildLevel < buildOpenLevel then
            application:showFlashNotice("上仙,你到了"..buildOpenLevel.."级就可以使用了")
        elseif enemyBuildLevel < buildOpenLevel then
            application:showFlashNotice("对方尚未开启该建筑")
        else
            clickFunc()
        end
    end
end

function HeroSoulBuild:firstPanelButtonFunc()
    if self.data.buildInfo.UpgradeCD > 0 then
        application:showFlashNotice("建筑正在升级中~")
        return 
    end
    local showSoulInfoTabs = self.data.buildInfo.ShowList
    local researchSoulInfoTabs = self.data.buildInfo.ResearchingList
    local refreshCD = self.data.buildInfo.RefreshCD
    local collectCD = self.data.buildInfo.CollectCD
    local freeTimes = self.data.buildInfo.FreeTimes
    local buyTimes = self.data.buildInfo.BuyTimes

    -- 算出开通研究位个数
    local openSlotNum = 0
    for k,soulInfo in pairs(researchSoulInfoTabs) do
        if soulInfo.ID >= OPENRESEARCT then
            openSlotNum = openSlotNum + 1
        end
    end

    local showSoulItemTab = {}
    local researchSoulBgSpriTab = {}

    local researchDesc = "正在培育中，请稍后～"
    local upgradeDesc = "正在升级中，请稍后～"
    local researchFinishDesc = "培育完成，请赶快收获吧！"
    
    local isCollectTiming = true
    local isCanResearch = false
    local isCanCollect = false
    local isUpgrading = true
    local isClickShowSoul = true
    local panel = nil
    local refreshCDLab = nil
    local collectCDLab = nil
    local collectFreeTimesLab = nil
    local quickFinishCostLab = nil
    local btn_reset = nil
    local btn_collect = nil
    local timeScheduler = nil

    local function setIsHaveResearchSoulStatus()
        local isHaveResearchSoul = false
        for k,soulInfo in pairs(researchSoulInfoTabs) do
            if soulInfo.ID > OPENRESEARCT then
                isHaveResearchSoul = true
                break
            end
        end
        if isHaveResearchSoul then
            btn_collect:setNorGLProgram(true)
            btn_collect:setTouchEnable(true)
        else
            btn_collect:setNorGLProgram(false)
            btn_collect:setTouchEnable(false)
        end
    end
    local function setResearchSoulItemVisible(slot, visible, newSoulInfo)
        local researchBg = researchSoulBgSpriTab[slot]
        local vessel1 = researchBg:getChildByTag(WATERTAG)
        local vesselEffect = researchBg:getChildByTag(WATEREFFECTTAG)
        local soulItem = researchBg:getChildByTag(SOULTAG)
        vessel1:setVisible(visible)
        soulItem:setVisible(visible)
        if visible then
            researchSoulInfoTabs[slot] = newSoulInfo
            soulItem:setGoodsInfo(researchSoulInfoTabs[slot])
            soulItem:setCollectNum()
        else
            vesselEffect:setVisible(visible)
            local researchSoulInfo = researchSoulInfoTabs[slot]
            researchSoulInfo.ID = 0
            researchSoulInfo.Num = 0
        end
    end
    local function showTouchEndFunc(sender, soulInfo)
        if not isCanResearch then
            if isUpgrading then
                application:showFlashNotice(upgradeDesc)
            else
                application:showFlashNotice(researchDesc)
            end
            return
        else
            if soulInfo.ResearchSlot > ISRESEARCHING then
                rpc:call("Home.CancelResearch", {ID = soulInfo.ID, ResearchSlot = soulInfo.ResearchSlot}, function (event)
                    if event.status == Exceptions.Nil and event.result then
                        if researchSoulInfoTabs[soulInfo.ResearchSlot].ID == soulInfo.ID then
                            Common.addTopSwallowLayer()
                            local soulItem = researchSoulBgSpriTab[soulInfo.ResearchSlot]:getChildByTag(SOULTAG)
                            local scale1 = cc.ScaleTo:create(0.2, 0)
                            soulItem:runAction(cc.Sequence:create({scale1, cc.CallFunc:create(function()
                                Common.removeTopSwallowLayer()
                                soulItem:setScale(1)
                                setResearchSoulItemVisible(soulInfo.ResearchSlot, false)
                                soulInfo.ResearchSlot = 0
                                setIsHaveResearchSoulStatus()
                                sender:setChooseStatus()
                            end)}))
                        end
                    end
                end)
            else
                local solt = nil
                for k,info in pairs(researchSoulInfoTabs) do
                    if info.ID == OPENRESEARCT then
                        solt = k
                        break
                    end
                end
                if solt then
                    if not isClickShowSoul then
                        return 
                    end
                    isClickShowSoul = false
                    soulInfo.ResearchSlot = solt
                    local newSoulInfo = {ID = soulInfo.ID, Num = 2}
                    rpc:call("Home.JoinResearch", {ID = soulInfo.ID, ResearchSlot = soulInfo.ResearchSlot}, function (event)
                        if event.status == Exceptions.Nil and event.result then
                            -- 飞入动画
                            Common.addTopSwallowLayer()
                            local soulItem = researchSoulBgSpriTab[soulInfo.ResearchSlot]:getChildByTag(SOULTAG)
                            local oldPos = cc.p(sender:getPositionX(), sender:getPositionY())
                            local wordPos = soulItem:convertToWorldSpace(cc.p(0, 0))
                            local newPos = panel:convertToNodeSpace(wordPos)

                            local newSoulItem = SoulGoodsInfo.new(newSoulInfo)
                            newSoulItem:setPosition(oldPos)
                            panel:addChild(newSoulItem)
                            newSoulItem:setScale(0.5)
                            local move = cc.MoveTo:create(0.2, newPos)
                            local scale1 = cc.ScaleTo:create(0.2, 1.2)
                            local spawn = cc.Spawn:create(move, scale1)
                            local scale2 = cc.ScaleTo:create(0.01, 1)
                            local removeSelf = cc.RemoveSelf:create()
                            newSoulItem:runAction(cc.Sequence:create({spawn, scale2, removeSelf, cc.CallFunc:create(function()
                                Common.removeTopSwallowLayer()
                                setResearchSoulItemVisible(soulInfo.ResearchSlot, true, newSoulInfo)
                                setIsHaveResearchSoulStatus()
                                sender:setChooseStatus()
                                isClickShowSoul = true
                            end)}))
                        end
                    end)
                else
                    application:showFlashNotice("已经没有空闲的研究位了！")
                    return
                end
            end
        end
    end
    local function cancelResearchFunc(slot, soulInfo)
        if not isCanResearch then
            if isUpgrading then
                application:showFlashNotice(upgradeDesc)
            else
                application:showFlashNotice(researchDesc)
            end
            return
        else
            rpc:call("Home.CancelResearch", {ID = soulInfo.ID, ResearchSlot = slot}, function (event)
                if event.status == Exceptions.Nil and event.result then
                    -- 当前研究位取消的星将是否就是目前展示中的星将
                    for k1,showSoulInfo in pairs(showSoulInfoTabs) do
                        if showSoulInfo.ResearchSlot > ISRESEARCHING and soulInfo.ID == showSoulInfo.ID and slot == showSoulInfo.ResearchSlot then
                            showSoulInfo.ResearchSlot = 0
                            local showSoulItem = showSoulItemTab[k1]
                            showSoulItem:setChooseStatus()
                            break
                        end
                    end
                    Common.addTopSwallowLayer()
                    local soulItem = researchSoulBgSpriTab[slot]:getChildByTag(SOULTAG)
                    local scale1 = cc.ScaleTo:create(0.2, 0)
                    soulItem:runAction(cc.Sequence:create({scale1, cc.CallFunc:create(function()
                        Common.removeTopSwallowLayer()
                        soulItem:setScale(1)
                        setResearchSoulItemVisible(slot, false)
                        setIsHaveResearchSoulStatus()
                    end)}))
                end
            end)
        end
    end

    local node = cc.Node:create()
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)

    panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(810, 540))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(panel)
    local panelSize = panel:getContentSize()

    local hua = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    hua:setPosition(panelSize.width * 0.5, panelSize.height * 0.5)
    panel:addChild(hua)

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.97)
    panel:addChild(title)

    local buildName = Common.finalFont(self.data.buildName, panelSize.width * 0.5, panelSize.height * 0.97, 25, cc.c3b(248, 255, 171), 1)
    buildName:setAdditionalKerning(-2)
    panel:addChild(buildName)

    local showBg = cc.Sprite:create("image/ui/img/btn/btn_1341.png")
    showBg:setPosition(panelSize.width * 0.42, panelSize.height - 150)
    panel:addChild(showBg)

    local btn_help = createMixSprite("image/ui/img/btn/btn_868.png")
    btn_help:setPosition(panelSize.width * 0.1, panelSize.height - 55)
    panel:addChild(btn_help)
    btn_help:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            self:helpUI()
        end
    end)

    for k,soulInfo in pairs(showSoulInfoTabs) do
        local soulItem = SoulGoodsInfo.new(soulInfo)
        panel:addChild(soulItem)
        soulItem:setPosition(panelSize.width * 0.13 + (k - 1) * 105, panelSize.height - 150)
        showSoulItemTab[k] = soulItem
        soulItem:setChooseStatus()
        soulItem:addShowTouchEndEventListener(showTouchEndFunc)
    end

    refreshCDLab = Common.finalFont(refreshCD.."后免费" , 1, 1, 20, nil, 1)
    refreshCDLab:setAdditionalKerning(-2)
    refreshCDLab:setPosition(panelSize.width * 0.88, panelSize.height - 110)
    panel:addChild(refreshCDLab)
    local refreshGoldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    refreshGoldSpri:setPosition(panelSize.width * 0.85, panelSize.height - 200)
    panel:addChild(refreshGoldSpri)
    local refreshGoldCostLab = Common.finalFont(refreshCostPrice, 1, 1, 20, cc.c3b(255, 240, 0), 1)
    refreshGoldCostLab:setAnchorPoint(0, 0.5)
    refreshGoldCostLab:setPosition(panelSize.width * 0.87, panelSize.height - 200)
    panel:addChild(refreshGoldCostLab)

    local btn_refresh = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, nil, cc.size(130, 60))
    btn_refresh:setButtonBounce(false)
    btn_refresh:setCircleFont("换一批", 1, 1, 25, cc.c3b(238, 205, 142))
    btn_refresh:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    btn_refresh:setPosition(panelSize.width * 0.88, panelSize.height - 155)
    panel:addChild(btn_refresh)
    btn_refresh:addTouchEventListener(function(sender, eventType, isIn)
        if eventType == ccui.TouchEventType.ended and isIn then
            local function refreshFunc()
                -- 刷新接口
                rpc:call("Home.RefreshShowList", researchSoulIDTabs, function (event)
                    if event.status == Exceptions.Nil and event.result then
                        refreshCD = event.result.RefreshCD
                        showSoulInfoTabs = event.result.ShowList
                        for k,soulItem in pairs(showSoulItemTab) do
                            local soulInfo = showSoulInfoTabs[k]
                            soulInfo.ResearchSlot = 0
                            soulItem:setGoodsInfo(soulInfo)
                            soulItem:setIsChoose(false)
                            -- soulItem:addShowTouchEndEventListener(showTouchEndFunc)
                        end
                    end
                end)
            end
            if refreshCD > 0 then
               if Common.isCostMoney(1001, refreshCostPrice) then
                   refreshFunc()
               end
            else
                refreshFunc()
            end
        end
    end)

    for i=1,4 do
        local lockGoldSpri = nil
        local lockGoldCostLab = nil

        local bg = cc.Sprite:create("image/ui/img/btn/btn_1338.png")
        bg:setPosition(panelSize.width * 0.16 + (i - 1) * 180 , panelSize.height - 330)
        panel:addChild(bg)
        researchSoulBgSpriTab[i] = bg

        local bgSize = bg:getContentSize()
        local vessel1 = cc.Sprite:create("image/ui/img/btn/btn_1339.png")
        vessel1:setTag(WATERTAG)
        vessel1:setPosition(bgSize.width * 0.5, bgSize.height * 0.3)
        bg:addChild(vessel1)

        local tempInfo = {ID = showSoulInfoTabs[i].ID, Num = 0}
        local soulItem = SoulGoodsInfo.new(tempInfo)
        soulItem:setTag(SOULTAG)
        soulItem:setLongTouchEnable(false)
        soulItem:setPosition(bgSize.width * 0.5, bgSize.height * 0.8)
        bg:addChild(soulItem)
        soulItem:setCancelButton()
        soulItem:setCancelButtonVisible(false)
        soulItem:setCollectNum()
        soulItem:setTouchEnable(false)
        soulItem:addCancelResearchEventListener(i, cancelResearchFunc)
        local move1 = cc.MoveBy:create(0.6, cc.p(0, -5))
        soulItem:runAction(cc.RepeatForever:create(cc.Sequence:create({move1, move1:reverse()})))

        local lock = createMixSprite("image/ui/img/btn/btn_258.png")
        lock:setTag(LOCKTAG)
        lock:setScale(0.8)
        lock:setButtonBounce(false)
        lock:setPosition(bgSize.width * 0.5, bgSize.height * 0.75)
        bg:addChild(lock)
        lock:addTouchEventListener(function(sender, eventType, isIn)
            if eventType == ccui.TouchEventType.ended and isIn then
                if not isCanResearch then
                    if isUpgrading then
                        application:showFlashNotice(upgradeDesc)
                    else
                        application:showFlashNotice(researchDesc)
                    end
                    return
                end
                local goldCost = (i - 2) * 200
                self:openSlotAlert(goldCost, function()
                    if Common.isCostMoney(1001, goldCost) then
                        if i == 4 then
                            if openSlotNum < 3 then
                                application:showFlashNotice("需先解锁第三个研究位")
                                return
                            end

                            if GameCache.Avatar.VIP < soltOpenVipLevel then
                                application:showFlashNotice("VIP"..soltOpenVipLevel.."以上可购买")
                                return
                            end
                        end
                        -- 开锁接口
                        rpc:call("Home.OpenResearchSlot", researchSoulIDTabs, function (event)
                            if event.status == Exceptions.Nil and event.result then
                                openSlotNum = i
                                researchSoulInfoTabs[i] = {ID = OPENRESEARCT, Num = 0}
                                sender:setVisible(false)
                                sender:setTouchEnable(false)

                                lockGoldSpri:setVisible(false)
                                lockGoldCostLab:setVisible(false)

                                application:showFlashNotice("购买成功～")
                            end
                        end)
                    end
                end, "购买研究位")
            end
        end)
        
        -- 研究位从第三位开始收费
        if (i == 3) or (i == 4) then
            lockGoldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
            lockGoldSpri:setPosition(bgSize.width * 0.38, -bgSize.height * 0.45)
            bg:addChild(lockGoldSpri)
            lockGoldCostLab = Common.finalFont(200 * (i - 2), 1, 1, 20, cc.c3b(255, 240, 0), 1)
            lockGoldCostLab:setAnchorPoint(0, 0.5)
            lockGoldCostLab:setPosition(bgSize.width * 0.5, -bgSize.height * 0.45)
            bg:addChild(lockGoldCostLab)
            if i == 4 then
                local lockSize = lock:getContentSize()
                local vipSpri = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
                vipSpri:setPosition(-15, 0)
                lock:addChild(vipSpri)
                local viplevel = Common.finalFont(soltOpenVipLevel, 1, 1, 20, cc.c3b(255,201,60),1)
                viplevel:setPosition(15, 0)
                lock:addChild(viplevel)
            end
        end

        local specialEffect = sp.SkeletonAnimation:create("image/spine/skill_effect/treated/top/skeleton.skel", "image/spine/skill_effect/treated/top/skeleton.atlas")
        specialEffect:setTag(WATEREFFECTTAG)
        specialEffect:setPosition(bgSize.width * 0.5, bgSize.height * 0.25)
        specialEffect:setAnimation(0, "animation", true)
        bg:addChild(specialEffect)
        specialEffect:setScale(0.5)

        -- 水特效
        local vessel2 = cc.Sprite:create("image/ui/img/btn/btn_1340.png")
        vessel2:setPosition(bgSize.width * 0.5, bgSize.height * 0.25)
        bg:addChild(vessel2)

        if i <= openSlotNum then
            lock:setVisible(false)
            lock:setTouchEnable(false)
            if researchSoulInfoTabs[i].ID > 0 then
                soulItem:setGoodsInfo(researchSoulInfoTabs[i])
                soulItem:setCollectNum()
                if collectCD == COLLECT_NOTRESEARCHSTATUS then
                    specialEffect:setVisible(false)
                end
            else
                vessel1:setVisible(false)
                specialEffect:setVisible(false)
                soulItem:setVisible(false)
                soulItem:setTouchEnable(false)
            end

            if i >= 3 then
                lockGoldSpri:setVisible(false)
                lockGoldCostLab:setVisible(false)
            end
        else
            vessel1:setVisible(false)
            specialEffect:setVisible(false)
            soulItem:setVisible(false)
            soulItem:setTouchEnable(false)
        end
    end

    local bottomBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottomBg:setContentSize(cc.size(790, 100))
    bottomBg:setPosition(panelSize.width * 0.5, 62)
    panel:addChild(bottomBg)

    collectCDLab = Common.finalFont(collectCD.."后收获" , 1, 1, 22, cc.c3b(255, 240, 0), 1)
    collectCDLab:setAdditionalKerning(-2)
    collectCDLab:setPosition(panelSize.width * 0.38, 62)
    panel:addChild(collectCDLab)

    collectFreeTimesLab = ColorLabel.new("", 22)
    collectFreeTimesLab:setAdditionalKerning(-2)
    collectFreeTimesLab:setPosition(panelSize.width * 0.3, 62)
    panel:addChild(collectFreeTimesLab)

    btn_reset = createMixSprite("image/ui/img/bg/add.png")
    btn_reset:setButtonBounce(false)
    btn_reset:setPosition(panelSize.width * 0.48, 62)
    panel:addChild(btn_reset)
    btn_reset:addTouchEventListener(function(sender, eventType, isInside)
        if eventType == ccui.TouchEventType.began then
            Common.addTopSwallowLayer()
        end
        if eventType == ccui.TouchEventType.ended then
            Common.removeTopSwallowLayer()
            if not isInside then
                return 
            end
            if GameCache.Avatar.VIP < resetVipLevel then
                application:showFlashNotice("VIP10可重置次数！")
                return 
            end
            self:openSlotAlert(resetFreeTimesCostPrice, function()
                if Common.isCostMoney(1001, resetFreeTimesCostPrice) then
                    -- 购买次数接口
                    rpc:call("Home.BuyResearchTimes", nil, function (event)
                        if event.status == Exceptions.Nil and event.result then
                            buyTimes = buyTimes - 1
                            freeTimes = totalFreeTimes
                            collectFreeTimesLab:setString("[255,255,255]今日剩余次数[=][155,255,74]"..freeTimes.."/"..totalFreeTimes.."次[=]")
                            sender:setVisible(false)
                            sender:setTouchEnable(false)
                            application:showFlashNotice("购买成功～")
                        end
                    end)
                end
            end, "重置次数？")
        end
    end)

    btn_collect = createMixSprite("image/ui/img/btn/btn_593.png", nil, "image/ui/img/btn/btn_060.png")
    btn_collect:setButtonBounce(false)
    btn_collect:setCircleFont("立即完成", 1, 1, 22, cc.c3b(248, 216, 136), 1)
    btn_collect:setFontPos(0.62, 0.5)
    btn_collect:setChildPos(0.2, 0.5)
    btn_collect:setPosition(panelSize.width * 0.65, 62)
    panel:addChild(btn_collect)
    quickFinishCostLab = Common.finalFont("300" , 1, 1, 18, cc.c3b(255, 240, 0), 1)
    quickFinishCostLab:setAdditionalKerning(-2)
    quickFinishCostLab:setPosition(-53, -10)
    btn_collect:addChild(quickFinishCostLab)

    local collectBtnEffect = effects:CreateAnimation(btn_collect, 0, 0, nil, 21, true)
    collectBtnEffect:setVisible(false)

    btn_collect:addTouchEventListener(function(sender, eventType, isIn)
        if eventType == ccui.TouchEventType.began then
            Common.addTopSwallowLayer()
        end
        if eventType == ccui.TouchEventType.ended then
            Common.removeTopSwallowLayer()
            if not isIn then
                return 
            end
            if isCanResearch then
                CCLog("===========开始培育============")
                local function beginResearch()
                    -- 开始培育接口
                    local researchSoulIDTabs = {}
                    for k,researchSoulInfo in pairs(researchSoulInfoTabs) do
                        table.insert(researchSoulIDTabs, researchSoulInfo.ID)
                    end
                    rpc:call("Home.BeginResearch", researchSoulIDTabs, function (event)
                        if event.status == Exceptions.Nil and event.result then
                            isCanCollect = false
                            isCanResearch = false
                            collectCD = self.data.buildConfig.ResearchTime
                            isCollectTiming = true
                            freeTimes = freeTimes - 1
                            collectFreeTimesLab:setString("[255,255,255]今日剩余次数[=][155,255,74]"..freeTimes.."/"..totalFreeTimes.."次[=]")
                            if freeTimes > 0 then
                                btn_reset:setVisible(false)
                                btn_reset:setTouchEnable(false)
                            elseif GameCache.Avatar.VIP >= resetVipLevel then
                                if buyTimes > 0 then
                                    btn_reset:setVisible(true)
                                    btn_reset:setTouchEnable(true)
                                else
                                    btn_reset:setVisible(false)
                                    btn_reset:setTouchEnable(false)
                                end
                            else
                                btn_reset:setVisible(true)
                                btn_reset:setTouchEnable(true)
                            end

                            quickFinishCostLab:setVisible(true)
                            btn_collect:getChild():setVisible(true)    
                            btn_collect:setFontPos(0.62, 0.5)
                            btn_collect:setString("立即完成")
                            collectBtnEffect:setVisible(false)

                            for k,bg in pairs(researchSoulBgSpriTab) do
                                local soulItem = bg:getChildByTag(SOULTAG)
                                soulItem:setCancelButtonVisible(false)
                                if researchSoulInfoTabs[k].ID > OPENRESEARCT then
                                    local vesselEffect = bg:getChildByTag(WATEREFFECTTAG)
                                    vesselEffect:setVisible(true)
                                end
                            end

                            showSoulInfoTabs = event.result
                            for k,soulItem in pairs(showSoulItemTab) do
                                local soulInfo = showSoulInfoTabs[k]
                                soulInfo.ResearchSlot = 0
                                soulItem:setGoodsInfo(soulInfo)
                                soulItem:setIsChoose(false)
                                -- soulItem:addShowTouchEndEventListener(showTouchEndFunc)
                            end
                        end
                    end)
                end

                local function needBuyTimes()
                    if freeTimes > 0 then
                        beginResearch()
                    else
                        if buyTimes > 0 then
                            self:openSlotAlert(resetFreeTimesCostPrice, function()
                                if Common.isCostMoney(1001, resetFreeTimesCostPrice) then
                                    -- 购买次数接口
                                    rpc:call("Home.BuyResearchTimes", nil, function (event)
                                        if event.status == Exceptions.Nil and event.result then
                                            buyTimes = buyTimes - 1
                                            freeTimes = totalFreeTimes
                                            collectFreeTimesLab:setString("[255,255,255]今日剩余次数[=][155,255,74]"..freeTimes.."/"..totalFreeTimes.."次[=]")
                                            btn_reset:setVisible(false)
                                            btn_reset:setTouchEnable(false)
                                            application:showFlashNotice("购买成功～")
                                        end
                                    end)
                                end
                            end, "重置次数？")
                        else
                            if GameCache.Avatar.VIP >= resetVipLevel then
                                application:showFlashNotice("今日培育次数已用完！")
                            else
                                application:showFlashNotice("VIP10可重置次数！")
                            end
                            return
                        end
                    end
                end

                local isEmptyResearch = false
                for k,researchSoulInfo in pairs(researchSoulInfoTabs) do
                    if OPENRESEARCT == researchSoulInfo.ID then
                        isEmptyResearch = true
                        break
                    end
                end
                if isEmptyResearch then
                    CommonLayer.HintPanel("还有空闲的研究位,是否开始培育？", function()
                        needBuyTimes()
                    end)
                else
                    needBuyTimes()
                end
            elseif isCanCollect then
                CCLog("===========收获============")
                local collectSoulInfoTabs = {}
                for k,researchSoulInfo in pairs(researchSoulInfoTabs) do
                    if researchSoulInfo.ID > OPENRESEARCT then
                        local collectSoulInfo = {}
                        collectSoulInfo.ID = researchSoulInfo.ID
                        collectSoulInfo.Num = researchSoulInfo.Num
                        collectSoulInfo.Type = BaseConfig.GT_SOUL
                        table.insert(collectSoulInfoTabs, collectSoulInfo)
                    end
                end
                self:collectUI(collectSoulInfoTabs, function(times)
                    -- 收获接口
                    rpc:call("Home.CollectResearch", times, function (event)
                        if event.status == Exceptions.Nil and event.result then
                            isCanCollect = false
                            isCanResearch = true
                            btn_collect:setString("开始培育")
                            collectBtnEffect:setVisible(false)

                            for k,v in pairs(collectSoulInfoTabs) do
                                v.Num = v.Num * times
                            end
                            application:showIconNotice(collectSoulInfoTabs)

                            for k,researchSoulInfo in pairs(researchSoulInfoTabs) do
                                local bg = researchSoulBgSpriTab[k]
                                local soulItem = bg:getChildByTag(SOULTAG)
                                soulItem:setCancelButtonVisible(true)
                                if researchSoulInfo.ID > OPENRESEARCT then
                                    setResearchSoulItemVisible(k, false)
                                end
                            end
                            setIsHaveResearchSoulStatus()
                        end
                    end)
                end)
            else
                CCLog("===========立即完成============")
                local collectGoldCost = self:getCollectGoldCost(collectCD)
                if Common.isCostMoney(1001, collectGoldCost) then
                    -- 立即完成接口
                    rpc:call("Home.QuickFinishResearch", nil, function (event)
                        if event.status == Exceptions.Nil and event.result then
                            isCanCollect = true
                            isCanResearch = false
                            collectCD = 0

                            quickFinishCostLab:setVisible(false)
                            btn_collect:getChild():setVisible(false)    
                            btn_collect:setFontPos(0.5, 0.5)
                            btn_collect:setString("收获")
                            collectBtnEffect:setVisible(true)
                        end
                    end)
                end
            end
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local startpos = target:convertToNodeSpace(touch:getStartLocation())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
            self:syncHomeData()
            scheduler:unscheduleScriptEntry(timeScheduler)
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

    local function timeScheduleFunc(dt)
        if refreshCDLab then
            if refreshCD > 0 then
                refreshCD = refreshCD - dt
                refreshCDLab:setString(Common.timeFormat(refreshCD).."后免费")
                refreshGoldSpri:setVisible(true)
                refreshGoldCostLab:setVisible(true)
                refreshCDLab:setVisible(true)
            else
                refreshGoldSpri:setVisible(false)
                refreshGoldCostLab:setVisible(false)
                refreshCDLab:setVisible(false)
            end
        end
        if collectCDLab and isCollectTiming then
            if collectCD > 0 then
                collectCD = collectCD - dt
                collectCDLab:setString(Common.timeFormat(collectCD).."后收获")
                quickFinishCostLab:setString(self:getCollectGoldCost(collectCD))
                collectCDLab:setVisible(true)
                collectFreeTimesLab:setVisible(false)
                btn_reset:setVisible(false)
                btn_reset:setTouchEnable(false)
                isCanResearch = false
                isCanCollect = false
            else
                isCollectTiming = false
                collectCDLab:setVisible(false)
                collectFreeTimesLab:setVisible(true)

                collectFreeTimesLab:setString("[255,255,255]今日剩余次数[=][155,255,74]"..freeTimes.."/"..totalFreeTimes.."次[=]")
                if freeTimes > 0 then
                    btn_reset:setVisible(false)
                    btn_reset:setTouchEnable(false)
                elseif GameCache.Avatar.VIP >= resetVipLevel then
                    if buyTimes > 0 then
                        btn_reset:setVisible(true)
                        btn_reset:setTouchEnable(true)
                    else
                        btn_reset:setVisible(false)
                        btn_reset:setTouchEnable(false)
                    end
                else
                    btn_reset:setVisible(true)
                    btn_reset:setTouchEnable(true)
                end

                -- 判断当前状态是可收获还是可培育
                quickFinishCostLab:setVisible(false)
                btn_collect:getChild():setVisible(false)    
                btn_collect:setFontPos(0.5, 0.5)
                if collectCD == COLLECT_COLLECTSTATUS then
                    application:showFlashNotice(researchFinishDesc)
                    btn_collect:setString("收获")
                    collectBtnEffect:setVisible(true)
                    isCanResearch = false
                    isCanCollect = true
                elseif collectCD == COLLECT_NOTRESEARCHSTATUS then
                    btn_collect:setString("开始培养")
                    collectBtnEffect:setVisible(false)
                    isCanResearch = true
                    isCanCollect = false

                    for k,bg in pairs(researchSoulBgSpriTab) do
                        local soulItem = bg:getChildByTag(SOULTAG)
                        soulItem:setCancelButtonVisible(true)
                    end
                    setIsHaveResearchSoulStatus()
                end
            end
        end

        if isUpgrading then
            if self.data.buildInfo.UpgradeCD > 0 then
                self.data.buildInfo.UpgradeCD = self.data.buildInfo.UpgradeCD - dt
                isCanResearch = false
                isUpgrading = true
            else
                isUpgrading = false
            end
        end
        
    end
    timeScheduleFunc(0)
    timeScheduler = scheduler:scheduleScriptFunc(timeScheduleFunc, 0.2, false)
end

function HeroSoulBuild:buildDetailPanel2(panel, panelSize)
    local createHeroSpri = cc.Sprite:create("image/ui/img/btn/btn_1115.png")
    createHeroSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.8)
    panel:addChild(createHeroSpri)
    local createHeroDesc = Common.finalFont("研究位开启个数:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    createHeroDesc:setAdditionalKerning(-2)
    createHeroDesc:setAnchorPoint(0, 0.5)
    createHeroDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.78)
    panel:addChild(createHeroDesc)
    local researchNum = 0
    for k,soulInfo in pairs(self.data.buildInfo.ResearchingList) do
        if soulInfo.ID > UNOPENRESEARCT then
            researchNum = researchNum + 1
        end
    end
    local createHero = Common.finalFont(researchNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    createHero:setPosition(panelSize.width * 0.73, panelSize.height * 0.78)
    panel:addChild(createHero)

    local defSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    defSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.61)
    panel:addChild(defSpri)
    defSpri:setScale(0.5)
    local defHeroNumDesc = Common.finalFont("防守星将:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defHeroNumDesc:setAdditionalKerning(-2)
    defHeroNumDesc:setAnchorPoint(0, 0.5)
    defHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.61)
    panel:addChild(defHeroNumDesc)
    local defNum = 0
    if self.data.buildInfo.DefForm.Hero then
        defNum = #self.data.buildInfo.DefForm.Hero
    end
    local defHomeNum = Common.finalFont(defNum.."/"..self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defHomeNum:setAnchorPoint(0, 0.5)
    defHomeNum:setPosition(panelSize.width * 0.61, panelSize.height * 0.61)
    panel:addChild(defHomeNum)

    local defTfpDesc = Common.finalFont("当前防御力:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defTfpDesc:setAdditionalKerning(-2)
    defTfpDesc:setAnchorPoint(0, 0.5)
    defTfpDesc:setPosition(panelSize.width * 0.68, panelSize.height * 0.61)
    panel:addChild(defTfpDesc)
    local defTfpValue = require("tool.helper.CalHeroAttr").FormTFP(self.data.buildInfo.DefForm)
    local defTfp = Common.finalFont(defTfpValue, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defTfp:setAnchorPoint(0, 0.5)
    defTfp:setPosition(panelSize.width * 0.84, panelSize.height * 0.61)
    panel:addChild(defTfp)

    local researchTime = 5
    local clockSpri = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
    clockSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.44)
    panel:addChild(clockSpri)
    local researchTimeLab = Common.finalFont("培育时间: "..self:getResearchTimeStr(self.data.buildConfig.ResearchTime).."/次" , 1, 1, 18, cc.c3b(150,150,109), 1)
    researchTimeLab:setAdditionalKerning(-2)
    researchTimeLab:setAnchorPoint(0, 0.5)
    researchTimeLab:setPosition(panelSize.width * 0.48, panelSize.height * 0.44)
    panel:addChild(researchTimeLab)
    
end

function HeroSoulBuild:producePanel(buildPanelNode, panelSize)
end

function HeroSoulBuild:isCanUpgrade()
    if not self.data.isOwnHome then
        return false
    end

    if (self.data.maxLevel) and (self.data.buildInfo.Level >= self.data.maxLevel) then
        return false
    end

    local buildConfig = self.data.buildConfig
    if (self.data.buildInfo.UpgradeCD <= 0) then
        if (GameCache.Avatar.Level >= buildConfig.AvtLevel) and 
            (GameCache.Avatar.Wood >= buildConfig.UpgradeCost) and
            (self.data.buildInfo.CollectCD <= 0) then
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

function HeroSoulBuild:isCanCollect()
    if not self.data.isOwnHome then
        return false
    end
    if self.data.buildInfo.CollectCD <= 0 then
        if self.data.buildInfo.CollectCD == COLLECT_COLLECTSTATUS then
            return true
        elseif self.data.buildInfo.CollectCD == COLLECT_NOTRESEARCHSTATUS then
            return false
        end
    else
        return false
    end
end

function HeroSoulBuild:updateBuild()
    self.data.buildConfig = BaseConfig.getHomeSoul(self.data.buildInfo.Level)

    if self.data.buildInfo.CollectCD > 0 then
        local capacity = (self.data.buildConfig.ResearchTime - self.data.buildInfo.CollectCD) / self.data.buildConfig.ResearchTime * 100
        self.controls.scrollBar_capacity:setPercent(capacity)
    elseif self.data.buildInfo.CollectCD == COLLECT_COLLECTSTATUS then
        self.controls.scrollBar_capacity:setPercent(100)
    elseif self.data.buildInfo.CollectCD == COLLECT_NOTRESEARCHSTATUS then
        self.controls.scrollBar_capacity:setPercent(0)
    end

    HeroSoulBuild.super.updateBuild(self)
end

function HeroSoulBuild:upgradePanel()
    if self.data.buildInfo.CollectCD > 0 then
        application:showFlashNotice("正在培育中，请稍后～")
        return
    else
        HeroSoulBuild.super.upgradePanel(self)
    end
end

function HeroSoulBuild:upgradeDetailPanel(panel, panelSize)
    local clockSpri = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
    clockSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.75)
    panel:addChild(clockSpri)
    local researchTimeLab = ColorLabel.new("", 20)
    researchTimeLab:setAdditionalKerning(-2)
    researchTimeLab:setAnchorPoint(0, 0.5)
    researchTimeLab:setPosition(panelSize.width * 0.46, panelSize.height * 0.75)
    panel:addChild(researchTimeLab)
    local upgraderesearchTime = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgraderesearchTime:setPosition(panelSize.width * 0.9, panelSize.height * 0.75)
    panel:addChild(upgraderesearchTime)

    local defHeroNumBg = cc.Sprite:create("image/ui/img/btn/btn_1178.png")
    defHeroNumBg:setPosition(panelSize.width * 0.68, panelSize.height * 0.53)
    panel:addChild(defHeroNumBg)
    local bar_defHeroNum = ccui.LoadingBar:create("image/ui/img/btn/btn_1113.png")
    bar_defHeroNum:setPosition(panelSize.width * 0.68, panelSize.height * 0.53)
    bar_defHeroNum:setPercent(50)
    panel:addChild(bar_defHeroNum)
    local defHeroNumDesc = Common.finalFont("防守星将:" , 1, 1, 18, cc.c3b(239,239,188), 1)
    defHeroNumDesc:setAdditionalKerning(-2)
    defHeroNumDesc:setAnchorPoint(0, 0.5)
    defHeroNumDesc:setPosition(panelSize.width * 0.48, panelSize.height * 0.55)
    panel:addChild(defHeroNumDesc)
    local defHeroNum = Common.finalFont(self.data.buildConfig.HeroNum, 1, 1, 22, cc.c3b(1, 241, 0), 1)
    defHeroNum:setAnchorPoint(0, 0.5)
    defHeroNum:setPosition(panelSize.width * 0.64, panelSize.height * 0.55)
    panel:addChild(defHeroNum)
    local afterDefHeroNum = Common.finalFont("", 1, 1, 22, cc.c3b(196, 231, 151), 1)
    afterDefHeroNum:setAnchorPoint(0, 0.5)
    panel:addChild(afterDefHeroNum)
    local defSpri = cc.Sprite:create("image/ui/img/btn/btn_071.png")
    defSpri:setPosition(panelSize.width * 0.43, panelSize.height * 0.53)
    panel:addChild(defSpri)
    defSpri:setScale(0.5)
    local upgradeDefHero = cc.Sprite:create("image/ui/img/btn/btn_411.png")
    upgradeDefHero:setPosition(panelSize.width * 0.92, panelSize.height * 0.55)
    panel:addChild(upgradeDefHero)

    if self.data.buildInfo.Level < self.data.maxLevel then
        local currConfig = self.data.buildConfig
        local afterConfig = BaseConfig.getHomeSoul(self.data.buildInfo.Level + 1)
        
        researchTimeLab:setString("[150,150,109]培育时间:[=][196, 231, 151]"..self:getResearchTimeStr(afterConfig.ResearchTime).."/次[=]")

        bar_defHeroNum:setPercent((currConfig.HeroNum / afterConfig.HeroNum) * 100)
        defHeroNum:setString(currConfig.HeroNum) 
        afterDefHeroNum:setString("+"..(afterConfig.HeroNum - currConfig.HeroNum))
        afterDefHeroNum:setPosition(defHeroNum:getPositionX() + defHeroNum:getContentSize().width + 10, 
                                panelSize.height * 0.55)
        if (afterConfig.HeroNum - currConfig.HeroNum) > 0 then
            upgradeDefHero:setScale(1)
        else
            upgradeDefHero:setScale(0)
        end
    else
        local currConfig = self.data.buildConfig
        researchTimeLab:setString("[150,150,109]培育时间:[=][196, 231, 151]"..self:getResearchTimeStr(currConfig.ResearchTime).."/次[=]")
        upgraderesearchTime:setScale(0)

        bar_defHeroNum:setPercent(100)
        defHomeNum:setString(self.data.buildConfig.HeroNum)
        upgradeDefHero:setScale(0)
    end
end

function HeroSoulBuild:collect()
    local collectSoulInfoTabs = {}
    for k,researchSoulInfo in pairs(self.data.buildInfo.ResearchingList) do
        if researchSoulInfo.ID > OPENRESEARCT then
            local collectSoulInfo = {}
            collectSoulInfo.ID = researchSoulInfo.ID
            collectSoulInfo.Num = researchSoulInfo.Num
            collectSoulInfo.Type = BaseConfig.GT_SOUL
            table.insert(collectSoulInfoTabs, collectSoulInfo)
        end
    end
    self:collectUI(collectSoulInfoTabs, function(times)
        rpc:call("Home.CollectResearch", times, function (event)
            if event.status == Exceptions.Nil and event.result then
                for k,v in pairs(collectSoulInfoTabs) do
                    v.Num = v.Num * times
                end
                application:showIconNotice(collectSoulInfoTabs)

                self:syncHomeData()
            end
        end)
    end)
end

function HeroSoulBuild:helpUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(600, 240))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local lab = Common.finalFont("玩法说明：", bgSize.width * 0.05, bgSize.height * 0.85, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("1.每日可免费进行3次将魂培育，免费次数使用完后VIP10\n可再购买3次机会。", bgSize.width * 0.05, bgSize.height * 0.62, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("2.单个培养皿保底收成为1个将魂。", bgSize.width * 0.05, bgSize.height * 0.4, 18, nil, 1)
    lab:setAnchorPoint(0, 0.5)
    bg:addChild(lab)
    lab = Common.finalFont("3.培育完成后请尽快收获！", bgSize.width * 0.05, bgSize.height * 0.2, 18, nil, 1)
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

    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)
end

function HeroSoulBuild:collectUI(collectInfoTabs, callFunc)
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(540, 380))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local desc = Common.systemFont("收获将魂", 1, 1, 30, cc.c3b(255, 240, 0), 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.85)
    panel:addChild(desc)

    local goodsTotal = #collectInfoTabs
    local itemWidth = 60
    local initWidth = panelSize.width * 0.5 - itemWidth * (goodsTotal - 1)
    for k,v in pairs(collectInfoTabs) do
        local item = SoulGoodsInfo.new(v)
        item:setNum()
        item:setPosition(initWidth + (k - 1) * itemWidth * 2, panelSize.height * 0.58)
        panel:addChild(item)
    end
    
    local btn_float = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
    btn_float:setCircleFont("普通收获", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_float:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_float:setPosition(panelSize.width * 0.3, panelSize.height * 0.22)
    panel:addChild(btn_float)
    btn_float:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if callFunc then
                callFunc(1)
            end
            panel:removeFromParent()
            panel = nil
        end
    end)

    local btn_double = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
    btn_double:setCircleFont("双倍收获", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_double:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_double:setPosition(panelSize.width * 0.7, panelSize.height * 0.22)
    panel:addChild(btn_double)
    btn_double:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if Common.isCostMoney(1001, doubleCollectCostPrice) then
                if callFunc then
                    callFunc(2)
                end
                panel:removeFromParent()
                panel = nil
            end
        end
    end)
    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(panelSize.width * 0.65, panelSize.height * 0.1)
    panel:addChild(goldSpri)
    local goldCostLab = Common.finalFont(doubleCollectCostPrice, 1, 1, 20, cc.c3b(255, 240, 0), 1)
    goldCostLab:setAnchorPoint(0, 0.5)
    goldCostLab:setPosition(panelSize.width * 0.68, panelSize.height * 0.1)
    panel:addChild(goldCostLab)

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

function HeroSoulBuild:openSlotAlert(goldCost, callFunc, useDesc)
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

    local desc = Common.systemFont("是否花费", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.3, panelSize.height * 0.65)
    panel:addChild(desc)
    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.65)
    panel:addChild(goldSpri)
    local goldCostLab = Common.finalFont(goldCost, 1, 1, 20, cc.c3b(255, 240, 0), 1)
    goldCostLab:setAnchorPoint(0, 0.5)
    goldCostLab:setPosition(panelSize.width * 0.45, panelSize.height * 0.65)
    panel:addChild(goldCostLab)
    local desc = Common.systemFont(useDesc, 1, 1, 20, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setPosition(panelSize.width * 0.55, panelSize.height * 0.65)
    panel:addChild(desc)
    desc:setPositionX(goldCostLab:getPositionX() + goldCostLab:getContentSize().width + 5)

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

function HeroSoulBuild:getResearchTimeStr(researchTime)
    local hour = math.floor(researchTime  / 3600)
    local minute = math.floor((researchTime  - hour * 3600) / 60)
    local sec = researchTime  % 60
    if hour > 24 then
        local day = math.floor(hour / 24)
        return (day.."天")
    else
        if hour == 0 then
            return (minute.."分"..sec.."秒")
        end
        return (hour.."小时"..minute.."分")
    end
end

function HeroSoulBuild:getCollectGoldCost(collectTime)
    local maxMinute = 100
    local goldCost = 0
    local minute = math.ceil(collectTime / 60)
    if minute > maxMinute then
        goldCost = maxMinute * 2 + (minute - maxMinute) * 1
    else
        goldCost = minute * 2
    end
    goldCost = (goldCost > 0) and goldCost or 0
    return goldCost
end

return HeroSoulBuild




