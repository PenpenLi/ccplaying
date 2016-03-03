local EquipRecycleLayer = class("EquipRecycleLayer", BaseLayer)

local EQUIPMENT_VIEW, TRUMP_VIEW = "equipMent", "trump"
local OFFSET_TAG = 10
local dischargeCostPrice = 20

local bgZOrder = 2

function EquipRecycleLayer:ctor()
    EquipRecycleLayer.super.ctor(self)

    self.data.isCurrEquipTab = {} -- 判断当前点击的位置是否有需要炼化的装备 （1表示有， 0表示无）
    self.data.currRecycleEquipTabs = {} -- 当前炼化炉中的装备
    for i=1,8 do
        table.insert(self.data.isCurrEquipTab, 0)
    end
    self.data.currShowEquipView = EQUIPMENT_VIEW
    self.data.isDischargeDress = false
    self.data.isHeroStarLevelSort = true
    self.data.isShowTips = false
    self.data.isCanRecycle = true

    self:createUI()
    self:lightAction()
    self:addListener()

    self.data.recycleEquipNum = 0 -- 正在执行飞入炼化炉动作时，不能进行炼化操作
end

function EquipRecycleLayer:addListener()
    self.listeners = {}
    local listener = application:addEventListener(AppEvent.UI.Recycle.isShowTips, function(event)
        local result = event.data
        local notShowFunc = result.NotShowFunc
        local showFunc = result.ShowFunc
        if self.data.isShowTips then
            showFunc()
        else
            notShowFunc()
        end
    end)
    table.insert(self.listeners, listener)
end

function EquipRecycleLayer:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(cc.size(945, 598))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.48)
    self:addChild(self.controls.bg)

    local bgSize = self.controls.bg:getContentSize()
    local fringe = cc.Scale9Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setContentSize(bgSize)
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(bgSize.width * 0.5, bgSize.height)
    self.controls.bg:addChild(fringe, bgZOrder)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    bg:setContentSize(cc.size(870, 542))
    bg:setPosition(bgSize.width * 0.47, bgSize.height * 0.46)
    self.controls.bg:addChild(bg, bgZOrder)

    local gold = createMixSprite("image/ui/img/btn/btn_995.png",nil, "image/ui/img/btn/btn_060.png")
    gold:setTouchEnable(false)
    gold:setPosition(bgSize.width * 0.29, bgSize.height * 0.94)
    self.controls.bg:addChild(gold, bgZOrder)
    gold:setChildPos(0.1, 0.5)
    self.controls.gold = Common.finalFont(Common.numConvert(GameCache.Avatar.Gold), 1, 1, 20, nil, 1)
    self.controls.gold:setPosition(bgSize.width * 0.295, bgSize.height * 0.94)
    self.controls.bg:addChild(self.controls.gold, bgZOrder)

    local equipToken = createMixSprite("image/ui/img/btn/btn_995.png",nil, "image/ui/img/btn/btn_217.png")
    equipToken:setTouchEnable(false)
    equipToken:setPosition(bgSize.width * 0.45, bgSize.height * 0.94)
    self.controls.bg:addChild(equipToken, bgZOrder)
    equipToken:setChildPos(0.1, 0.5)
    equipToken:getChild():setScale(0.8)
    self.controls.equipToken = Common.finalFont(Common.numConvert(GameCache.Avatar.EquipToken), 1, 1, 20, nil, 1)
    self.controls.equipToken:setPosition(bgSize.width * 0.46, bgSize.height * 0.94)
    self.controls.bg:addChild(self.controls.equipToken, bgZOrder)

    self:createRecycleUI()
    self:createDischargeUI()
    self:setDischargeViewVisible(false)

    local function labelBtns()
        local chooseBtns = {}
        local function btnTouchEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local name = sender:getName()
                for k,v in pairs(chooseBtns) do
                    if name == v:getName() then
                        v:setTouchStatus()
                        v:setFontColor(cc.c3b(253, 230, 154))
                        v:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
                    else
                        v:setNormalStatus()
                        v:setFontColor(cc.c3b(177, 174, 170))
                        v:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
                    end
                end

                if name ==  "recycle" then
                    self:setRecycleViewVisible(true)
                    self:setDischargeViewVisible(false)
                elseif name == "discharge" then
                    self:setDischargeViewVisible(true)
                    self:setRecycleViewVisible(false)
                end
            end
        end

        local size = self.controls.bg:getContentSize()
        local recycle = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
        recycle:setRotation(90)
        recycle:setAnchorPoint(0.5, 0)
        recycle:setBgTouchAnchorPoint(0.5, 0)
        recycle:setTouchStatus()
        recycle:setCircleFont("炼\n化" , 1, 1, 30, cc.c3b(253, 230, 154))
        recycle:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
        recycle:setFontPos(0.5, 0.9)
        recycle:getFont():setRotation(-90)
        recycle:setPosition(size.width * 0.925, size.height * 0.7)
        recycle:setName("recycle")
        recycle:addTouchEventListener(btnTouchEvent)
        self.controls.bg:addChild(recycle, bgZOrder)
        table.insert(chooseBtns , recycle)

        local discharge = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
        discharge:setRotation(90)
        discharge:setAnchorPoint(0.5, 0)
        discharge:setBgTouchAnchorPoint(0.5, 0)
        discharge:setCircleFont("剥\n离" , 1, 1, 30, cc.c3b(177, 174, 170))
        discharge:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
        discharge:setFontPos(0.5, 0.9)
        discharge:getFont():setRotation(-90)
        discharge:setPosition(size.width * 0.925, size.height * 0.4)
        discharge:setName("discharge")
        discharge:addTouchEventListener(btnTouchEvent)
        self.controls.bg:addChild(discharge, bgZOrder)
        table.insert(chooseBtns , discharge)

        local btn_store = createMixSprite("image/ui/img/btn/btn_1152.png")
        btn_store:setCircleFont("装备商店", 1, 1, 20, nil, 1)
        btn_store:setFontPos(0.65, 0.45)
        btn_store:setPosition(size.width * 0.82,size.height * 0.94)
        self.controls.bg:addChild(btn_store, bgZOrder)
        btn_store:addTouchEventListener(function( sender, eventType, isIn)
            if (eventType == ccui.TouchEventType.ended) and isIn then
                local layer = require("scene.main.ExchangeMall").new(BaseConfig.MALL_TYPE_EQUIP_RECYCLE, function()
                    self.controls.equipToken:setString(Common.numConvert(GameCache.Avatar.EquipToken))

                    if self.controls.equipmentView then
                        self.controls.equipmentView:resetUpdate()
                    end
                    if self.controls.trumpView then
                        self.controls.trumpView:resetUpdate()
                    end
                end)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(layer) 
            end
        end)
    end
    labelBtns() 

    local currPageName = createMixSprite("image/ui/img/bg/bg_142.png", "image/ui/img/bg/bg_142.png", "image/ui/img/btn/btn_812.png")
    currPageName:setTouchEnable(false)
    currPageName:setChildPos(0.52, 0.55)
    currPageName:setPosition(bgSize.width * 0.1, bgSize.height * 0.98)
    self.controls.bg:addChild(currPageName, bgZOrder)

    local close = createMixSprite("image/ui/img/btn/btn_598.png")
    close:setPosition(bgSize.width * 0.98, bgSize.height * 0.98)
    self.controls.bg:addChild(close, bgZOrder)
    close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            for _,listener in pairs(self.listeners) do
                application:removeEventListener(listener)
            end
            for k,equipInfo in pairs(self.data.currRecycleEquipTabs) do
                if equipInfo.Type == BaseConfig.GT_EQUIP then
                    GameCache.addEquip(equipInfo.ID, equipInfo.StarLevel, 1)
                elseif equipInfo.Type == BaseConfig.GT_PROPS then
                    GameCache.addProps(equipInfo, false, 1)
                end
            end
            cc.Director:getInstance():popScene()
        end
    end)

end

function EquipRecycleLayer:createRecycleUI()
    local size = self.controls.bg:getContentSize()
    self.controls.recycleTabViewBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    self.controls.recycleTabViewBG:setContentSize(cc.size(364, 504))
    self.controls.recycleTabViewBG:setPosition(size.width * 0.205, size.height * 0.46)
    self.controls.bg:addChild(self.controls.recycleTabViewBG, bgZOrder)
    local recycleViewBgSize = self.controls.recycleTabViewBG:getContentSize()

    local tishi = Common.finalFont("点击图标查看装备属性", 1, 1, 25, cc.c3b(17, 106, 159))
    tishi:setPosition(recycleViewBgSize.width * 0.43, recycleViewBgSize.height * 0.9)
    self.controls.recycleTabViewBG:addChild(tishi, bgZOrder)

    local viewSize = cc.size(self.controls.recycleTabViewBG:getContentSize().width, self.controls.recycleTabViewBG:getContentSize().height - 170)
    self.controls.equipmentView = require("scene.main.equipRecycle.widget.CommonTabView").new(viewSize, 15, 90, true, true)
    self.controls.recycleTabViewBG:addChild(self.controls.equipmentView, bgZOrder)

    self.controls.trumpView = require("scene.main.equipRecycle.widget.CommonTabView").new(viewSize, 15, 90, false, true)
    self.controls.recycleTabViewBG:addChild(self.controls.trumpView, bgZOrder)
    self.controls.trumpView:setScale(0.01)

    local layer = Common.createClickLayer(self.controls.recycleTabViewBG:getContentSize().width, 
                                        self.controls.recycleTabViewBG:getContentSize().height * 0.66, 0, 90)
    self.controls.recycleTabViewBG:addChild(layer, bgZOrder)

    self.controls.recycleStoveBG = cc.Sprite:create("image/ui/img/bg/bg_187.png")
    self.controls.recycleStoveBG:setPosition(size.width * 0.65, size.height * 0.46)
    self.controls.bg:addChild(self.controls.recycleStoveBG, bgZOrder)
    local stoveBgSize = self.controls.recycleStoveBG:getContentSize()

    local bottom = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(510, 90))
    bottom:setPosition(stoveBgSize.width * 0.5, stoveBgSize.height * 0.08)
    self.controls.recycleStoveBG:addChild(bottom)
    local equipTokenBgSize = cc.size(180, 40)
    local equipTokenBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1155.png")
    equipTokenBg:setContentSize(equipTokenBgSize)
    equipTokenBg:setPosition(stoveBgSize.width * 0.508, stoveBgSize.height * 0.42)
    self.controls.recycleStoveBG:addChild(equipTokenBg)
    local get = Common.finalFont("获得", 1, 1, 22, nil, 1)
    get:setPosition(equipTokenBgSize.width * 0.2, equipTokenBgSize.height * 0.5)
    equipTokenBg:addChild(get)
    local tokenSpri = cc.Sprite:create("image/ui/img/btn/btn_217.png")
    tokenSpri:setPosition(equipTokenBgSize.width * 0.4, equipTokenBgSize.height * 0.5)
    equipTokenBg:addChild(tokenSpri)
    tokenSpri:setScale(0.8)
    self.data.getEquipTokenNum = 0
    self.controls.getEquipToken = Common.finalFont(self.data.getEquipTokenNum, 1, 1, 25, cc.c3b(0, 255, 0), 1)
    self.controls.getEquipToken:setPosition(equipTokenBgSize.width * 0.7, equipTokenBgSize.height * 0.5)
    equipTokenBg:addChild(self.controls.getEquipToken)

    local function showRecycleEquip()
        self.data.recyclePosTabs = {{stoveBgSize.width * 0.25, stoveBgSize.height * 0.9},
                                {stoveBgSize.width * 0.75, stoveBgSize.height * 0.9},
                                {stoveBgSize.width * 0.85, stoveBgSize.height * 0.7},
                                {stoveBgSize.width * 0.85, stoveBgSize.height * 0.5},
                                {stoveBgSize.width * 0.75, stoveBgSize.height * 0.3},
                                {stoveBgSize.width * 0.25, stoveBgSize.height * 0.3},
                                {stoveBgSize.width * 0.15, stoveBgSize.height * 0.5},
                                {stoveBgSize.width * 0.15, stoveBgSize.height * 0.7}
        }

        for i=1,8 do
            local node = cc.Sprite:create("image/icon/border/head_bg.png")
            node:setScale(0.9)
            node:setPosition(self.data.recyclePosTabs[i][1], self.data.recyclePosTabs[i][2])
            self.controls.recycleStoveBG:addChild(node)
            local s = createMixScale9Sprite("image/icon/border/border_star_0.png", nil, nil, cc.size(100, 100))
            s:setTouchEnable(false)
            s:setPosition(self.data.recyclePosTabs[i][1], self.data.recyclePosTabs[i][2])
            s:setTag(i)
            self.controls.recycleStoveBG:addChild(s)
        end
    end
    showRecycleEquip()
    ------------------防止事件被屏蔽，按钮都设置在tabView上层----------------------
    local function selectedEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self.data.isShowTips = true
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self.data.isShowTips = false
        end
    end  
    local checkBox = ccui.CheckBox:create()
    checkBox:setTouchEnabled(true)
    checkBox:loadTextures("image/ui/img/btn/btn_877.png",
                               "image/ui/img/btn/btn_877.png",
                               "image/ui/img/btn/btn_878.png",
                               "image/ui/img/btn/btn_877.png",
                               "image/ui/img/btn/btn_878.png")
    checkBox:setPosition(recycleViewBgSize.width * 0.85, recycleViewBgSize.height * 0.9)
    checkBox:addEventListener(selectedEvent)  
    self.controls.recycleTabViewBG:addChild(checkBox, bgZOrder)
    checkBox:setSelectedState(false)

    local function tabViewBtns()
        local chooseBtns = {}
        local function btnTouchEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local name = sender:getName()
                for k,v in pairs(chooseBtns) do
                    if name == v:getName() then
                        v:setNormalStatus()
                    else
                        v:setTouchStatus()
                    end
                end

                if name ==  "equipMent" then
                    self.data.currShowEquipView = EQUIPMENT_VIEW
                    self.controls.equipmentView:setScale(1)
                    self.controls.trumpView:setScale(0.01)
                elseif name == "trump" then
                    self.data.currShowEquipView = TRUMP_VIEW
                    self.controls.equipmentView:setScale(0.01)
                    self.controls.trumpView:setScale(1)
                end
            end
        end

        local controls_btn_equip = createMixScale9Sprite("image/ui/img/btn/btn_818.png", "image/ui/img/btn/btn_819.png", nil, cc.size(163, 56))
        controls_btn_equip:setButtonBounce(false)
        controls_btn_equip:setFont("装备" , 1, 1, 20, cc.c3b(248, 216, 136))
        controls_btn_equip:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        controls_btn_equip:setPosition(recycleViewBgSize.width * 0.275, recycleViewBgSize.height * 0.1)
        controls_btn_equip:setName("equipMent")
        controls_btn_equip:addTouchEventListener(btnTouchEvent)
        self.controls.recycleTabViewBG:addChild(controls_btn_equip, bgZOrder)
        table.insert(chooseBtns , controls_btn_equip)

        local controls_btn_skill = createMixScale9Sprite("image/ui/img/btn/btn_818.png", "image/ui/img/btn/btn_819.png",  nil, cc.size(163, 56))
        controls_btn_skill:setTouchStatus()
        controls_btn_skill:setButtonBounce(false)
        controls_btn_skill:setFont("碎片" , 1, 1, 20, cc.c3b(248, 216, 136))
        controls_btn_skill:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        controls_btn_skill:setPosition(recycleViewBgSize.width * 0.725, recycleViewBgSize.height * 0.1)
        controls_btn_skill:setName("trump")
        controls_btn_skill:addTouchEventListener(btnTouchEvent)
        self.controls.recycleTabViewBG:addChild(controls_btn_skill, bgZOrder)
        table.insert(chooseBtns , controls_btn_skill)
    end
    tabViewBtns()

    local btn_auto = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
    btn_auto:setCircleFont("自动添加", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_auto:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_auto:setPosition(stoveBgSize.width * 0.28,stoveBgSize.height * 0.08)
    self.controls.recycleStoveBG:addChild(btn_auto)
    btn_auto:addTouchEventListener(function( sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            local isNeedMove = false
            for k,v in pairs(self.data.isCurrEquipTab) do
                if v == 0 then
                    isNeedMove = true
                    self:equipAutoMoveToStove(k)
                end
            end
            if not isNeedMove then
                application:showFlashNotice("亲,已经添加满了。")
            end
        end
    end)

    local btn_recycle = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
    btn_recycle:setCircleFont("炼化", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_recycle:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_recycle:setPosition(stoveBgSize.width * 0.72,stoveBgSize.height * 0.08)
    self.controls.recycleStoveBG:addChild(btn_recycle)
    btn_recycle:addTouchEventListener(function( sender, eventType, isInside)
        if eventType == ccui.TouchEventType.began then
            Common.addTopSwallowLayer()
        end
        if eventType == ccui.TouchEventType.ended then
            Common.removeTopSwallowLayer()
        end
        if eventType == ccui.TouchEventType.ended and 
                isInside and self.data.isCanRecycle and 
                (self.data.recycleEquipNum == 0) then
            local isAllow = false
            local deleteEquipIdxTab = {}
            local deleteItemTab = {}
            for k,v in pairs(self.data.isCurrEquipTab) do
                if v == 1 then
                    isAllow = true
                    table.insert(deleteEquipIdxTab, k)
                end
            end

            if isAllow then
                local isWarning = false
                for i=1 + OFFSET_TAG,(8 + OFFSET_TAG) do
                    local item = self.controls.recycleStoveBG:getChildByTag(i)
                    if item then
                        local equipConfig = BaseConfig.GetEquip(item.data.goodsInfo.ID, item.data.goodsInfo.StarLevel)
                        if equipConfig.talent > 13 then
                            isWarning = true
                            item:stopAllActions()
                            item:runAction(cc.Sequence:create(cc.Blink:create(0.8, 4)))
                        end

                        table.insert(deleteItemTab, item)
                    end
                end

                if isWarning then
                    local upgradePanel = self:upgradePanel(deleteEquipIdxTab, deleteItemTab)
                    local runningScene = cc.Director:getInstance():getRunningScene()
                    runningScene:addChild(upgradePanel)
                else
                    self:equipRecycle(deleteEquipIdxTab, deleteItemTab)
                end
            else
                application:showFlashNotice("请放入炼化装备")
            end
        end
    end)
end

function EquipRecycleLayer:createDischargeUI()
    local size = self.controls.bg:getContentSize()
    self.controls.dischargeTabViewBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    self.controls.dischargeTabViewBG:setContentSize(cc.size(364, 504))
    self.controls.dischargeTabViewBG:setPosition(size.width * 0.205, size.height * 0.46)
    self.controls.bg:addChild(self.controls.dischargeTabViewBG, bgZOrder)
    local dischargeBgSize = self.controls.dischargeTabViewBG:getContentSize()

    local tishi = Common.finalFont("请选择星将剥离绑定装备", 1, 1, 25, cc.c3b(17, 106, 159))
    tishi:setPosition(dischargeBgSize.width * 0.5, dischargeBgSize.height * 0.9)
    self.controls.dischargeTabViewBG:addChild(tishi, bgZOrder)

    local viewSize = cc.size(dischargeBgSize.width, dischargeBgSize.height - 170)
    self.controls.heroView = require("scene.main.equipRecycle.widget.CommonTabView").new(viewSize, 45, 90, false, false)
    self.controls.dischargeTabViewBG:addChild(self.controls.heroView, bgZOrder)

    local layer = Common.createClickLayer(dischargeBgSize.width, dischargeBgSize.height * 0.66, 0, 90)
    self.controls.dischargeTabViewBG:addChild(layer, bgZOrder)

    self.controls.dischargeStoveBG = cc.Sprite:create("image/ui/img/bg/bg_187.png")
    self.controls.dischargeStoveBG:setPosition(size.width * 0.65, size.height * 0.46)
    self.controls.bg:addChild(self.controls.dischargeStoveBG, bgZOrder)
    local stoveBgSize = self.controls.dischargeStoveBG:getContentSize()

    local equipTokenBgSize = cc.size(180, 40)
    local equipTokenBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1155.png")
    equipTokenBg:setContentSize(equipTokenBgSize)
    equipTokenBg:setPosition(stoveBgSize.width * 0.508, stoveBgSize.height * 0.42)
    self.controls.dischargeStoveBG:addChild(equipTokenBg)
    local get = Common.finalFont("消耗", 1, 1, 22, nil, 1)
    get:setPosition(equipTokenBgSize.width * 0.2, equipTokenBgSize.height * 0.5)
    equipTokenBg:addChild(get)
    local tokenSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    tokenSpri:setPosition(equipTokenBgSize.width * 0.4, equipTokenBgSize.height * 0.5)
    equipTokenBg:addChild(tokenSpri)
    tokenSpri:setScale(0.8)
    self.data.costGold = 0
    self.controls.costGold = Common.finalFont(self.data.costGold, 1, 1, 25, cc.c3b(0, 255, 0), 1)
    self.controls.costGold:setPosition(equipTokenBgSize.width * 0.7, equipTokenBgSize.height * 0.5)
    equipTokenBg:addChild(self.controls.costGold)

    self.data.currViewSortName = "starLevel"
    local function tabViewBtns()
        local chooseBtns = {}
        local function btnTouchEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local name = sender:getName()
                for k,v in pairs(chooseBtns) do
                    if name == v:getName() then
                        v:setNormalStatus()
                    else
                        v:setTouchStatus()
                    end
                end
                if name == self.data.currViewSortName then
                    return
                end
                self.data.currViewSortName = name
                
                if name ==  "starLevel" then
                    self.data.isHeroStarLevelSort = true
                    self.controls.heroView:setHeroStarLevelSort()
                elseif name == "level" then
                    self.data.isHeroStarLevelSort = false
                    self.controls.heroView:setHeroLevelSort()
                end

                self.controls.heroInfoBG:setVisible(false)
                for i=1,4 do
                    local equipItem = self.controls.dischargeStoveBG:getChildByTag(OFFSET_TAG + i)
                    if equipItem then
                        equipItem:setEquipChooseVisible(false)
                        equipItem:stopAllActions()
                        equipItem:setScale(0)
                    end
                end

                self.data.costGold = 0
                self.controls.costGold:setString(self.data.costGold)
                if GameCache.Avatar.Gold >= self.data.costGold then
                    self.controls.costGold:setColor(cc.c3b(0, 255, 0))
                else
                    self.controls.costGold:setColor(cc.c3b(255, 0, 0))
                end
            end
        end

        local controls_btn_equip = createMixScale9Sprite("image/ui/img/btn/btn_818.png", "image/ui/img/btn/btn_819.png", nil, cc.size(160, 56))
        controls_btn_equip:setButtonBounce(false)
        controls_btn_equip:setFont("按星级排序" , 1, 1, 20, cc.c3b(248, 216, 136))
        controls_btn_equip:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        controls_btn_equip:setPosition(dischargeBgSize.width * 0.275, dischargeBgSize.height * 0.1)
        controls_btn_equip:setName("starLevel")
        controls_btn_equip:addTouchEventListener(btnTouchEvent)
        self.controls.dischargeTabViewBG:addChild(controls_btn_equip, bgZOrder)
        table.insert(chooseBtns , controls_btn_equip)

        local controls_btn_skill = createMixScale9Sprite("image/ui/img/btn/btn_818.png", "image/ui/img/btn/btn_819.png", nil, cc.size(160, 56))
        controls_btn_skill:setTouchStatus()
        controls_btn_skill:setButtonBounce(false)
        controls_btn_skill:setFont("按等级排序" , 1, 1, 20, cc.c3b(248, 216, 136))
        controls_btn_skill:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        controls_btn_skill:setPosition(dischargeBgSize.width * 0.725, dischargeBgSize.height * 0.1)
        controls_btn_skill:setName("level")
        controls_btn_skill:addTouchEventListener(btnTouchEvent)
        self.controls.dischargeTabViewBG:addChild(controls_btn_skill, bgZOrder)
        table.insert(chooseBtns , controls_btn_skill)
    end
    tabViewBtns()

    local function showDischargeEquip()
        self.controls.heroInfoBG = cc.Sprite:create("image/icon/border/panel_border_star_0.png")
        self.controls.heroInfoBG:setPosition(stoveBgSize.width * 0.5,stoveBgSize.height * 0.9)
        self.controls.dischargeStoveBG:addChild(self.controls.heroInfoBG)
        self.controls.heroInfoBG:setVisible(false)

        local bgSize = self.controls.heroInfoBG:getContentSize()
        self.controls.heroName = Common.finalFont("", bgSize.width * 0.55, bgSize.height * 0.7, 25, nil, 1)
        self.controls.heroName:setAdditionalKerning(-2)
        self.controls.heroInfoBG:addChild(self.controls.heroName)

        self.controls.heroLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
        self.controls.heroLevel:setPosition(bgSize.width * 0.84, bgSize.height * 0.12)
        self.controls.heroLevel:setAnchorPoint(1, 0)
        self.controls.heroLevel:setScale(0.45)
        self.controls.heroLevel:setAdditionalKerning(-10)
        self.controls.heroInfoBG:addChild(self.controls.heroLevel)
        local ji = cc.Sprite:create("image/ui/img/btn/btn_790.png")
        ji:setAnchorPoint(0, 0)
        ji:setPosition(bgSize.width * 0.82, bgSize.height * 0.12)
        self.controls.heroInfoBG:addChild(ji)
        
        local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_436.png")
        bar_BG:setPosition(bgSize.width * 0.4, bgSize.height * 0.3)
        self.controls.heroInfoBG:addChild(bar_BG)
        self.controls.bar_heroLevel = ccui.LoadingBar:create("image/ui/img/btn/btn_789.png")
        self.controls.bar_heroLevel:setPercent(50)
        self.controls.bar_heroLevel:setPosition(bgSize.width * 0.395, bgSize.height * 0.3)
        self.controls.heroInfoBG:addChild(self.controls.bar_heroLevel)

        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            
            if cc.rectContainsPoint(rect, locationInNode) then
                if self.data.heroInfo then
                    return true
                end
            end
            return false
        end

        local function onTouchEnd(touch, event)
            local target = event:getCurrentTarget()
            local tag = target:getTag()
            local equipInfo = self.data.heroInfo.Equip[tag]
            if equipInfo.ID ~= 0 then
                CCLog("===========equipID", equipInfo.ID)
                local equipItem = self.controls.dischargeStoveBG:getChildByTag(OFFSET_TAG + tag)
                equipItem:setEquipChooseVisible(not equipItem.isEquipChoose)

                if equipItem.isEquipChoose then
                    self.data.costGold = self.data.costGold + dischargeCostPrice
                else
                    self.data.costGold = self.data.costGold - dischargeCostPrice
                end
                self.controls.costGold:setString(self.data.costGold)
                if GameCache.Avatar.Gold >= self.data.costGold then
                    self.controls.costGold:setColor(cc.c3b(0, 255, 0))
                else
                    self.controls.costGold:setColor(cc.c3b(255, 0, 0))
                end
            end
        end

        self.data.dischargePosTabs = {{stoveBgSize.width * 0.16, stoveBgSize.height * 0.72},
                                {stoveBgSize.width * 0.84, stoveBgSize.height * 0.72},
                                {stoveBgSize.width * 0.16, stoveBgSize.height * 0.35},
                                {stoveBgSize.width * 0.84, stoveBgSize.height * 0.35},
        }
        self.data.equipPathTab = {"image/ui/img/btn/btn_106.png",
                                "image/ui/img/btn/btn_105.png",
                                "image/ui/img/btn/btn_107.png",
                                "image/ui/img/btn/btn_104.png",
        }
        for i=1,4 do
            local node = cc.Sprite:create("image/icon/border/head_bg.png")
            node:setTag(i)
            node:setPosition(self.data.dischargePosTabs[i][1], self.data.dischargePosTabs[i][2])
            self.controls.dischargeStoveBG:addChild(node)

            local s = createMixSprite("image/icon/border/border_star_0.png", nil, self.data.equipPathTab[i])
            s:setTouchEnable(false)
            s:setPosition(self.data.dischargePosTabs[i][1], self.data.dischargePosTabs[i][2])
            self.controls.dischargeStoveBG:addChild(s)

            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
            self.controls.dischargeStoveBG:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
        end
    end
    showDischargeEquip()

    local btn_discharge = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
    btn_discharge:setCircleFont("开始剥离", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_discharge:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_discharge:setPosition(stoveBgSize.width * 0.5,stoveBgSize.height * 0.12)
    self.controls.dischargeStoveBG:addChild(btn_discharge)
    btn_discharge:addTouchEventListener(function( sender, eventType, isInside)
        if eventType == ccui.TouchEventType.ended and isInside then
            local isCanDischarge = false
            local equipItemTab = {}
            for i=1,4 do
                local equipItem = self.controls.dischargeStoveBG:getChildByTag(OFFSET_TAG + i)
                if equipItem and equipItem.isEquipChoose then
                    isCanDischarge = true
                    table.insert(equipItemTab, equipItem)
                end
            end

            if not isCanDischarge then
                application:showFlashNotice("请点选要剥离的装备~!")
            else
                if Common.isCostMoney(1001, self.data.costGold) then
                    local alert = self:UninstallEquipAlert(equipItemTab)
                    self:addChild(alert)
                end
            end
        end
    end)
end

function EquipRecycleLayer:setRecycleViewVisible(visible)
    if visible then
        self.controls.recycleTabViewBG:setScale(1)
        self.controls.recycleStoveBG:setScale(1)
    else
        self.controls.recycleTabViewBG:setScale(0)
        self.controls.recycleStoveBG:setScale(0)
    end
end

function EquipRecycleLayer:setDischargeViewVisible(visible)
    if visible then
        self.controls.dischargeTabViewBG:setScale(1)
        self.controls.dischargeStoveBG:setScale(1)
    else
        self.controls.dischargeTabViewBG:setScale(0)
        self.controls.dischargeStoveBG:setScale(0)
    end
end

function EquipRecycleLayer:upgradePanel(deleteEquipIdxTab, deleteItemTab)
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

    local desc = Common.finalFont("有个别的装备资质比较高哟～，还要坚持炼化吗?", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.7)
    desc:setAnchorPoint(0.5, 1)
    panel:addChild(desc)

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.3)
    panel:addChild(btnBG)
    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.3)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:equipRecycle(deleteEquipIdxTab, deleteItemTab)
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
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    return panel
end

----------------炼化所有方法-------------------
function EquipRecycleLayer:fromListMoveToStove(equipInfo, pos)
    if not self.data.isCanRecycle then
        return false
    end
    local isNeedMove = false
    local moveToPosIdx = nil
    for i = 1, (#self.data.isCurrEquipTab) do
        if self.data.isCurrEquipTab[i] == 0 then
            self.data.isCurrEquipTab[i] = 1
            isNeedMove = true
            moveToPosIdx = i
            break
        end
    end

    if isNeedMove then
        self.data.recycleEquipNum = self.data.recycleEquipNum + 1
        local item = require("scene.main.equipRecycle.widget.EquipGoodsInfo").new(equipInfo, BaseConfig.GOODS_MIDDLETYPE)
        item:setPosition(pos.x, pos.y)
        item:setTag(OFFSET_TAG + moveToPosIdx)
        self.controls.recycleStoveBG:addChild(item)
        item:setTouchEnable(false)
        item:addRemoveEvent(handler(self, self.removeItemInStove))

        item:runAction(cc.Sequence:create(cc.MoveTo:create(0.15, cc.p(self.data.recyclePosTabs[moveToPosIdx][1], self.data.recyclePosTabs[moveToPosIdx][2])),
            cc.CallFunc:create(function(sender)
                item:setCloseBtn()
                self:addEquipToken(equipInfo, moveToPosIdx)
                self.data.recycleEquipNum = self.data.recycleEquipNum - 1
        end)))
    else
        application:showFlashNotice("亲,已经添加满了。")
    end
    return isNeedMove
end

function EquipRecycleLayer:equipAutoMoveToStove(moveToPosIdx)
    if not self.data.isCanRecycle then
        return false
    end

    local tabView = nil
    if self.data.currShowEquipView == EQUIPMENT_VIEW then
        tabView = self.controls.equipmentView
    elseif self.data.currShowEquipView == TRUMP_VIEW then
        tabView = self.controls.trumpView
    end

    if 0 ~= (#tabView.data.infoTab) then
        self.data.recycleEquipNum = self.data.recycleEquipNum + 1
        self.data.isCurrEquipTab[moveToPosIdx] = 1
        local equipInfo = tabView.data.infoTab[1]
        equipInfo.Num = equipInfo.Num - 1
        if equipInfo.Num < 1 then
            tabView:removeItem(equipInfo)
        else
            tabView:updateView(tabView.data.infoTab)
        end

        local item = require("scene.main.equipRecycle.widget.EquipGoodsInfo").new(equipInfo, BaseConfig.GOODS_MIDDLETYPE)
        local posX, posY = self.data.recyclePosTabs[moveToPosIdx][1], self.data.recyclePosTabs[moveToPosIdx][2]
        item:setPosition(posX, posY)
        item:setTag(OFFSET_TAG + moveToPosIdx)
        self.controls.recycleStoveBG:addChild(item)
        item:setTouchEnable(false)
        item:addRemoveEvent(handler(self, self.removeItemInStove))
        item:AutoMoveToStoveAction()

        local node = cc.Node:create()
        local delay = cc.DelayTime:create(0.3)
        local removeSelf = cc.RemoveSelf:create()
        self:addChild(node)
        node:runAction(cc.Sequence:create({delay, cc.CallFunc:create(function()
            self:addEquipToken(equipInfo, moveToPosIdx)
            self.data.recycleEquipNum = self.data.recycleEquipNum - 1
        end), removeSelf}))
    else
        application:showFlashNotice("没有可炼化的装备")
    end
end

function EquipRecycleLayer:addEquipToken(equipInfo, moveToPosIdx)
    if equipInfo.Type == BaseConfig.GT_EQUIP then
        local equipConfig = BaseConfig.GetEquip(equipInfo.ID, equipInfo.StarLevel)
        self.data.getEquipTokenNum = self.data.getEquipTokenNum + equipConfig.equipToken
    elseif equipInfo.Type == BaseConfig.GT_PROPS then
        local propsConfig = BaseConfig.GetProps(equipInfo.ID)
        local compoundEquipID = propsConfig.useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundEquipID)
        local equipID = fragToEquipConfig.productID
        local equipStarLevel = fragToEquipConfig.starLevel
        local compoundNum = fragToEquipConfig.num
        local equipConfig = BaseConfig.GetEquip(equipID, equipStarLevel)
        self.data.getEquipTokenNum = self.data.getEquipTokenNum + math.floor(equipConfig.equipToken/compoundNum)
    end
    self.controls.getEquipToken:setString(self.data.getEquipTokenNum)
    self.data.currRecycleEquipTabs[moveToPosIdx] = equipInfo
end

--[[
    从炼化炉中移除装备，tag是通过GoodsInfo获取的
]]
function EquipRecycleLayer:removeItemInStove(tag, equipInfo)
    self.controls.recycleStoveBG:removeChildByTag(tag)
    self.data.isCurrEquipTab[tag - OFFSET_TAG] = 0
    self.data.currRecycleEquipTabs[tag - OFFSET_TAG] = nil
    local tabView = nil
    if equipInfo.Type == BaseConfig.GT_EQUIP then
        tabView = self.controls.equipmentView
    elseif equipInfo.Type == BaseConfig.GT_PROPS then
        tabView = self.controls.trumpView
    end
    tabView:addItem(equipInfo)

    if equipInfo.Type == BaseConfig.GT_EQUIP then
        local equipConfig = BaseConfig.GetEquip(equipInfo.ID, equipInfo.StarLevel)
        self.data.getEquipTokenNum = self.data.getEquipTokenNum - equipConfig.equipToken
    elseif equipInfo.Type == BaseConfig.GT_PROPS then
        local propsConfig = BaseConfig.GetProps(equipInfo.ID)
        local compoundEquipID = propsConfig.useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundEquipID)
        local equipID = fragToEquipConfig.productID
        local equipStarLevel = fragToEquipConfig.starLevel
        local compoundNum = fragToEquipConfig.num
        local equipConfig = BaseConfig.GetEquip(equipID, equipStarLevel)
        self.data.getEquipTokenNum = self.data.getEquipTokenNum - math.floor(equipConfig.equipToken/compoundNum)
    end
    self.controls.getEquipToken:setString(self.data.getEquipTokenNum)
end

----------------剥离所有方法-------------------
function EquipRecycleLayer:updateHeroEquipInfo(heroInfo)
    self.data.heroInfo = heroInfo
    self.data.heroConfigInfo = BaseConfig.GetHero(self.data.heroInfo.ID, self.data.heroInfo.StarLevel)
    local function updateHeroInfo()
        local starAttr = Common.getHeroStarLevelColor(heroInfo.StarLevel)
        local nameColor = starAttr.Color
        local starNum = starAttr.StarNum
        local starDesc = starAttr.Additional

        local starLevelPath = string.format("image/icon/border/panel_border_star_%d.png", heroInfo.StarLevel)
        self.controls.heroInfoBG:setVisible(true)
        self.controls.heroInfoBG:setTexture(starLevelPath)
        self.controls.heroName:setColor(nameColor)
        self.controls.heroName:setString(self.data.heroConfigInfo.name..starDesc)
        self.controls.heroLevel:setString(heroInfo.Level)
        
        self.data.maxExp = BaseConfig.GetHeroUpgradeExp(self.data.heroConfigInfo.talent, heroInfo.Level)
        self.controls.bar_heroLevel:setPercent(heroInfo.Exp/self.data.maxExp * 100) 
    end
    updateHeroInfo()

    for i=1,4 do
        local equipInfo = self.data.heroInfo.Equip[i]
        if equipInfo.ID ~= 0 then
            local equipItem = self.controls.dischargeStoveBG:getChildByTag(OFFSET_TAG + i)
            local equipName = BaseConfig.GetEquip(equipInfo.ID, 0).name
            if equipItem then
                equipItem:setGoodsInfo(equipInfo)
                equipItem:setEquipChooseVisible(false)
                equipItem:setLevel()
                equipItem:setName(equipName)
            else
                equipItem = require("scene.main.equipRecycle.widget.EquipGoodsInfo").new(equipInfo)
                equipItem:setLevel()
                equipItem:setName(equipName)
                equipItem:setPosition(self.data.dischargePosTabs[i][1], self.data.dischargePosTabs[i][2])
                equipItem:setTag(OFFSET_TAG + i)
                self.controls.dischargeStoveBG:addChild(equipItem)
            end
            equipItem:setScale(0)
            equipItem:stopAllActions()
            local scale1 = cc.ScaleTo:create(0.1, 1.12)
            local scale2 = cc.ScaleTo:create(0.1, 0.9)
            local scale3 = cc.ScaleTo:create(0.06, 1.06)
            local scale4 = cc.ScaleTo:create(0.04, 0.95)
            local scale5 = cc.ScaleTo:create(0.03, 1.02)
            local scale5 = cc.ScaleTo:create(0.01, 1)
            equipItem:runAction(cc.Sequence:create(scale1, scale2, scale3, scale4, scale5))
        else
            local equipItem = self.controls.dischargeStoveBG:getChildByTag(OFFSET_TAG + i)
            if equipItem then
                equipItem:stopAllActions()
                equipItem:setScale(0)
            end
        end
    end

    self.data.costGold = 0
    self.controls.costGold:setString(self.data.costGold)
    if GameCache.Avatar.Gold >= self.data.costGold then
        self.controls.costGold:setColor(cc.c3b(0, 255, 0))
    else
        self.controls.costGold:setColor(cc.c3b(255, 0, 0))
    end
end

function EquipRecycleLayer:lightAction()
    local function palyAction(light, space)
        local posX, posY = light:getPosition()
        local playTime = (math.random(10, 20)) * 0.1
        local fadeout = cc.FadeOut:create(playTime)
        local move = cc.MoveBy:create(playTime, cc.p(0, space))
        local spawn = cc.Spawn:create(fadeout, move)
        local seq = cc.Sequence:create(spawn, cc.CallFunc:create(function()
            light:setPosition(posX, posY)
            light:setOpacity(255)
        end))
        light:runAction(cc.RepeatForever:create(seq))
    end
    local size = self.controls.bg:getContentSize()
    local lightPosxTabs = {{size.width * 0.56, size.height * 0.4}, {size.width * 0.59, size.height * 0.42}, 
                            {size.width * 0.63, size.height * 0.38}, {size.width * 0.68, size.height * 0.32},
                            {size.width * 0.74, size.height * 0.38}, {size.width * 0.76, size.height * 0.4},
                            {size.width * 0.77, size.height * 0.42}, {size.width * 0.53, size.height * 0.43}}
    for i=1,#lightPosxTabs do
        local light = cc.Sprite:create("image/ui/img/btn/btn_808.png")
        light:setPosition(lightPosxTabs[i][1], lightPosxTabs[i][2])
        self.controls.bg:addChild(light, bgZOrder)
        if (i % 2) == 1 then
            light:setScale(0.6)
        end
        local radSpace = math.random(70, 130)
        palyAction(light, radSpace)
    end
end

function EquipRecycleLayer:UninstallEquipAlert(equipItemTab)
    local node = cc.Node:create()
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

    local desc = Common.finalFont("是否花费", 1, 1, 20, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setPosition(panelSize.width * 0.20, panelSize.height * 0.65)
    panel:addChild(desc, bgZOrder)
    desc = Common.finalFont("进行剥离", 1, 1, 20, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setPosition(panelSize.width * 0.60, panelSize.height * 0.65)
    panel:addChild(desc, bgZOrder)
    desc = Common.finalFont("(剥离将返还全部升星材料)", 1, 1, 18, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.52)
    panel:addChild(desc, bgZOrder)

    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png") 
    goldSpri:setPosition(panelSize.width * 0.45, panelSize.height * 0.65)
    panel:addChild(goldSpri, bgZOrder)
    local goldCost = Common.finalFont(self.data.costGold, panelSize.width * 0.49,panelSize.height * 0.65, 25, cc.c3b(255, 246, 0))
    goldCost:setAnchorPoint(0, 0.5)
    panel:addChild(goldCost, bgZOrder)

    local function buttonFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            if name == "sure" then
                self:UninstallEquip(equipItemTab)
            end
            node:removeFromParent()
            node = nil
        end
    end

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.28)
    panel:addChild(btnBG)
    local cancel = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 56))
    cancel:setButtonBounce(false)
    cancel:setFont("取消" , 1, 1, 25, cc.c3b(238, 205, 142))
    cancel:setName("cancel")
    cancel:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    cancel:setPosition(panelSize.width * 0.3,panelSize.height * 0.28)
    panel:addChild(cancel, bgZOrder)
    cancel:addTouchEventListener(buttonFunc)
    local sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 56))
    sure:setButtonBounce(false)
    sure:setFont("确定" , 1, 1, 25, cc.c3b(238, 205, 142))
    sure:setName("sure")
    sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    sure:setPosition(panelSize.width * 0.7,panelSize.height * 0.28)
    panel:addChild(sure, bgZOrder)
    sure:addTouchEventListener(buttonFunc)

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
    return node
end

function EquipRecycleLayer:showUninstallGetGoods(resultInfoTabs)
    local titleHeight = 70
    local numOneRow = 7
    local itemWidth = 38
    local itemHeight = 75

    local function craeteTableview(ccSize, viewHeight, goodsTabs)
        local function tableCellTouched(table,cell)
            CCLog("cell touched at index: ",cell:getIdx())
        end
        local function cellSizeForTable(table,idx) 
            return viewHeight,ccSize.width
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            local function getLayout()
                local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), ccSize.width, viewHeight)
                local beforeHeight = 0
                for k,v in pairs(goodsTabs) do
                    local height = math.ceil((#v.List) / numOneRow) * itemHeight + titleHeight
                    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), ccSize.width, height)
                    layer:setTag(k)
                    layer:setPosition(0, beforeHeight)
                    layerColor:addChild(layer)
                    beforeHeight = beforeHeight + height

                    local layerSize = layer:getContentSize()
                    local goodsTotal = (#v.List > numOneRow) and numOneRow or (#v.List)
                    local initWidth = layerSize.width * 0.5 - itemWidth * (goodsTotal - 1)
                    for k1,v1 in pairs(v.List) do
                        local title = cc.Sprite:create("image/ui/img/bg/bg_254.png")
                        title:setPosition(layerSize.width * 0.5, layerSize.height - 20)
                        layer:addChild(title)
                        local equipConfig = BaseConfig.GetEquip(v.ID, v.StarLevel)
                        local starData = Common.getHeroStarLevelColor(v.StarLevel) 
                        local name = equipConfig.name..starData.Additional
                        local nameLab = Common.finalFont(name, layerSize.width * 0.5, layerSize.height - 20, 20, starData.Color, 1)
                        layer:addChild(nameLab)
                        local nameLabPosX = nameLab:getPositionX()
                        local nameLabPosY = nameLab:getPositionY()
                        local nameLabSize = nameLab:getContentSize()

                        local lab1 = Common.finalFont("剥离", 1, 1, 20, cc.c3b(248, 216, 136), 1)
                        lab1:setAnchorPoint(1, 0.5)
                        layer:addChild(lab1)
                        lab1:setPosition(nameLabPosX - nameLabSize.width * 0.5 - 5, nameLabPosY)
                        local lab2 = Common.finalFont("返还结果", 1, 1, 20, cc.c3b(248, 216, 136), 1)
                        lab2:setAnchorPoint(0, 0.5)
                        layer:addChild(lab2)
                        lab2:setPosition(nameLabPosX + nameLabSize.width * 0.5 + 5, nameLabPosY)

                        local goodsItem = Common.getGoods(v1, true, BaseConfig.GOODS_SMALLTYPE)
                        goodsItem:setPositionX(initWidth + ((k1 - 1)%numOneRow) * itemWidth * 2)
                        goodsItem:setPositionY(layerSize.height - titleHeight - 20 - math.floor((k1 - 1) / numOneRow) * itemHeight)
                        layer:addChild(goodsItem)
                        goodsItem:setScale(0)
                        local scale1 = cc.ScaleTo:create(0.08, 1.2)
                        local scale2 = cc.ScaleTo:create(0.05, 1)
                        local delay = cc.DelayTime:create((k1 - 1) * 0.1)
                        goodsItem:runAction(cc.Sequence:create(delay, scale1, scale2))
                    end
                end
                
                return layerColor
            end

            if nil == cell then
                cell = cc.TableViewCell:new()
                layerColor = getLayout()
                cell:addChild(layerColor)
            end
            return cell
        end

        local function numberOfCellsInTableView(table)
            return 1
        end
        local goodsList = cc.TableView:create(ccSize)
        goodsList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        goodsList:setDelegate()
        goodsList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        goodsList:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
        goodsList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        goodsList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        goodsList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        goodsList:reloadData()
        return goodsList
    end

    local node = cc.Node:create()
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    node:addChild(swallowLayer)

    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(600, 420))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(panel)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.97)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.97)
    panel:addChild(dian)
    
    local viewHeight = 0
    for k,v in pairs(resultInfoTabs) do
        viewHeight = viewHeight + math.ceil((#v.List) / numOneRow) * itemHeight + titleHeight
    end
    local tableSize = cc.size(580, 320)
    local tableView = craeteTableview(tableSize, viewHeight, resultInfoTabs)
    tableView:setPosition(panelSize.width * 0.5 - tableSize.width * 0.5, 40)
    panel:addChild(tableView)

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
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

--[[
    炼化
]]
function EquipRecycleLayer:equipRecycle(deleteEquipIdxTab, deleteItemTab)
    local tempTab = {}
    for k,v in pairs(deleteItemTab) do
        local tempEquipInfo = {}
        local info = v:getGoodsInfo()
        tempEquipInfo.ID = info.ID
        tempEquipInfo.Type = info.Type
        table.insert(tempTab, tempEquipInfo)
    end

    self.data.isCanRecycle = false
    rpc:call("Equip.Recycle", tempTab, function(event)
        local tempEquipToken = event.result
        if event.status == Exceptions.Nil then
            for k,v in pairs(deleteEquipIdxTab) do
                self.data.isCurrEquipTab[v] = 0
            end
            for k,v in pairs(deleteItemTab) do
                v:setHideCloseBtn()
                local stoveBgSize = self.controls.recycleStoveBG:getContentSize()
                local posX, posY = stoveBgSize.width * 0.49, stoveBgSize.height * 0.5
                local scale = cc.ScaleBy:create(0.3, 0)
                local move = cc.MoveTo:create(0.3, cc.p(posX, posY))
                local rotate = cc.RotateBy:create(0.3 , 720)
                v:runAction(cc.Sequence:create(cc.Spawn:create(scale, move, rotate), cc.CallFunc:create(function()
                    v:removeFromParent()
                    v = nil

                    if k == (#deleteItemTab) then
                        self.controls.equipToken:setString(Common.numConvert(GameCache.Avatar.EquipToken))
                        self.controls.equipToken:playChangeAction()
                        application:showFlashNotice("恭喜!炼化成功!魂玉+"..tempEquipToken)

                        for k,v in pairs(self.data.currRecycleEquipTabs) do
                            v = nil
                        end
                        self.data.currRecycleEquipTabs = nil
                        self.data.currRecycleEquipTabs = {}

                        self.data.getEquipTokenNum = 0
                        self.controls.getEquipToken:setString(self.data.getEquipTokenNum)

                        self.data.isCanRecycle = true
                    end
                end)))
            end
        else
            self.data.isCanRecycle = true
        end
    end)
end

--[[
    剥离
]]
function EquipRecycleLayer:UninstallEquip(equipItemTab)
    local typeTab = {}
    for k,v in pairs(equipItemTab) do
        table.insert(typeTab, v.data.goodsConfigInfo.type)
    end

    rpc:call("Hero.UninstallEquip", {ID = self.data.heroInfo.ID, List = typeTab, 
                                IsClearSkin = self.data.isDischargeDress, IsPerfect = true}, 
                                function(event)
        if event.status == Exceptions.Nil then
            for k,v in pairs(equipItemTab) do
                v.isEquipChoose = false
                v:setScale(0)
                -- 从星将信息中删除该装备
                local tag = v:getTag() - OFFSET_TAG
                local equipInfo = self.data.heroInfo.Equip[tag]
                equipInfo.ID = 0 --设置ID为零等同于删除该装备信息
                equipInfo.SkinID = 0
                equipInfo.Level = 1

                if self.data.isDischargeDress then
                    local skinInfo = self.data.heroInfo.EquipSkin[tag]
                    skinInfo = {}
                end
            end
            -- 判断此星将是否还有装备
            local isHaveEquip = false
            for i=1,4 do
                local equipInfo = self.data.heroInfo.Equip[i]
                if equipInfo.ID ~= 0 then
                    isHaveEquip = true
                    break
                end
            end
            if not isHaveEquip then
                self.controls.heroView:updateHeroList(self.data.heroInfo)
                self.controls.heroInfoBG:setVisible(false)
            end

            self.controls.gold:setString(Common.numConvert(GameCache.Avatar.Gold))
            self.controls.gold:playChangeAction()

            self.data.costGold = 0
            self.controls.costGold:setString(self.data.costGold)
            if GameCache.Avatar.Gold >= self.data.costGold then
                self.controls.costGold:setColor(cc.c3b(0, 255, 0))
            else
                self.controls.costGold:setColor(cc.c3b(255, 0, 0))
            end

            -- 返还物品
            local goodsTabs = event.result
            if goodsTabs then
                self:showUninstallGetGoods(goodsTabs)
            end
        end
    end)
end

return EquipRecycleLayer


