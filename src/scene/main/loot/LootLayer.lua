local LootLayer = class("LootLayer", BaseLayer)
local TrumpGoodsInfo = require("scene.main.loot.widget.TrumpGoodsInfo")
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")
local commonLayer = require("tool.helper.CommonLayer")

local scheduler = cc.Director:getInstance():getScheduler()

local bgZOrder = 2
local topZOrder = bgZOrder + 1

local smallSafePillID = 1204
local bigSafePillID = 1205

function LootLayer:ctor(treasureTabs, winInfo)
    LootLayer.super.ctor(self)
    self.data.time = 0
    self.data.isClickCompound = false -- 防止连续点合成
    self:countMagicAndBook()
    self:createUI()

    self.data.treasureTabs = treasureTabs
    self:updateCompoundGoods(self.data.showMagicTab[1])
    if 0 ~= (#winInfo) then
        local box = require("scene.main.loot.widget.DrawBox").new(true, winInfo[1])
        self:addChild(box)
    end
    self:ProtectTime()

    scheduler_showTime = scheduler:scheduleScriptFunc(handler(self, self.showTime), 1, false)
end

function LootLayer:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(916, 588))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(self.controls.bg)
    self.data.size = self.controls.bg:getContentSize()
    
    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH * 0.5 - size.width * 0.5, SCREEN_HEIGHT * 0.91)
    self:addChild(pay)

    local close = createMixSprite("image/ui/img/btn/btn_598.png")
    close:setPosition(self.data.size.width * 0.98, self.data.size.height * 1.02)
    self.controls.bg:addChild(close, topZOrder)
    close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)

    -- tableType值 1是MagicTab， 2是BookTab
    local function createTable(tableSize, tableType)
        local height = nil
        local goodsTab = nil
        local heightSpace = 120
        function cellSizeForTable(table,idx) 
            if tableType == 1 then
                goodsTab = self.data.showMagicTab
                height = (#goodsTab) * heightSpace
            elseif tableType == 2 then
                goodsTab = self.data.showBookTab
                height = (#goodsTab) * heightSpace
            end
            return height, 100
        end

        function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()

            local function layout()
                local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0), tableSize.width, height)
                layerColor:setAnchorPoint(0, 0)

                for k,v in pairs(goodsTab) do
                    local item = TrumpGoodsInfo.new(BaseConfig.GOODS_EQUIP, v, BaseConfig.GOODS_MIDDLETYPE)
                    item:setState()
                    item:setPosition(tableSize.width * 0.5, height - heightSpace * 0.5 - (k - 1) * heightSpace)
                    item:addTouchEventListener(function(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            if not table:isTouchMoved() then
                                if self.data.currGoodsItem then
                                    self.data.currGoodsItem:setChooseBorderVisible(false)
                                end
                                self.data.currGoodsItem = item
                                self.data.currGoodsItem:setChooseBorderVisible(true)
                                self:updateCompoundGoods(v)
                            end
                        end
                    end)

                    if k == 1 then
                        if not self.data.currGoodsItem then
                            self.data.currGoodsItem = item
                            self.data.currGoodsItem:setChooseBorderVisible(true)
                        end
                    end
                    layerColor:addChild(item)
                end
                return layerColor
            end

            if cell then
                cell:removeFromParent()
                cell = nil
            end
            cell = cc.TableViewCell:new()
            cell:addChild(layout())

            return cell
        end

        function numberOfCellsInTableView(table)
           return 1
        end

        local ccSize = cc.size(tableSize.width, tableSize.height)
        local tableView = cc.TableView:create(ccSize)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setPosition(cc.p(0, 35))
        tableView:setDelegate()
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
        return tableView
    end

    local function middleUI()
        local size = self.data.size
        local middlebg = createMixSprite("image/ui/img/btn/btn_826.png", nil, "image/ui/img/btn/btn_825.png")
        middlebg:setTouchEnable(false)
        middlebg:setPosition(size.width * 0.5, size.height * 0.58)
        self.controls.bg:addChild(middlebg, bgZOrder)

        local quan1 = cc.Sprite:create("image/ui/img/btn/btn_828.png")
        quan1:setPosition(size.width * 0.5, size.height * 0.58)
        self.controls.bg:addChild(quan1, bgZOrder)
        quan1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(10, -360))))
        local quan2 = cc.Sprite:create("image/ui/img/btn/btn_829.png")
        quan2:setPosition(size.width * 0.5, size.height * 0.58)
        self.controls.bg:addChild(quan2, bgZOrder)
        quan2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(3, 360))))
        local quan3 = cc.Sprite:create("image/ui/img/btn/btn_827.png")
        quan3:setPosition(size.width * 0.5, size.height * 0.58)
        self.controls.bg:addChild(quan3, bgZOrder)

        self.controls.quanBG = cc.Sprite:create("image/ui/img/bg/bg_116.png")
        self.controls.quanBG:setPosition(size.width * 0.5, size.height * 0.59)
        self.controls.bg:addChild(self.controls.quanBG, bgZOrder)
        local out = cc.FadeOut:create(1)
        local out_reverse = out:reverse()
        self.controls.quanBG:runAction(cc.RepeatForever:create(cc.Sequence:create(out, out_reverse)))

        local left = createMixSprite("image/ui/img/bg/bg_193.png", nil, "image/ui/img/btn/btn_824.png")
        left:setTouchEnable(false)
        left:setAnchorPoint(0, 0.5)
        left:setChildPos(1, 0.96)
        left:setPosition(size.width * 0.03, size.height * 0.57)
        self.controls.bg:addChild(left, bgZOrder)

        local right = createMixSprite("image/ui/img/bg/bg_193.png", nil, "image/ui/img/btn/btn_823.png")
        right:setTouchEnable(false)
        right:setAnchorPoint(1, 0.5)
        right:setChildPos(0, 0.96)
        right:setPosition(size.width * 0.97, size.height * 0.57)
        self.controls.bg:addChild(right, bgZOrder)

        self.controls.middle_goods = TrumpGoodsInfo.new(BaseConfig.GOODS_EQUIP, self.data.showMagicTab[1]) 
        self.controls.middle_goods.posX = size.width * 0.5
        self.controls.middle_goods.posY = size.height * 0.65
        self.controls.middle_goods:setPosition(self.controls.middle_goods.posX, self.controls.middle_goods.posY)
        self.controls.middle_goods:setTouchEnable(false)
        self.controls.bg:addChild(self.controls.middle_goods, bgZOrder)

        self.controls.centerChooseEff = load_animation("image/spine/skill_effect/ragebox/blue/", 0.9)
        self.controls.bg:addChild(self.controls.centerChooseEff, bgZOrder)
        self.controls.centerChooseEff:setPosition(cc.p(self.controls.middle_goods.posX, self.controls.middle_goods.posY))
        self.controls.centerChooseEff:setAnimation(0, "animation", true)

        local detailBg = cc.Sprite:create("image/ui/img/bg/bg_115.png")
        detailBg:setPosition(size.width * 0.5, size.height * 0.45)
        self.controls.bg:addChild(detailBg, bgZOrder)
        local detailBgSize = detailBg:getContentSize()

        self.controls.goodsName = Common.finalFont("" , 1 , 1 , 20, cc.c3b(255, 126, 56), 1)
        self.controls.goodsName:setPosition(detailBgSize.width * 0.5, detailBgSize.height * 0.85)
        detailBg:addChild(self.controls.goodsName)

        self.controls.goods_attribute1 = ColorLabel.new("", 20)
        self.controls.goods_attribute1:setPosition(detailBgSize.width * 0.5, detailBgSize.height * 0.5)
        detailBg:addChild(self.controls.goods_attribute1)

        self.controls.goods_attribute2 = ColorLabel.new("", 20)
        self.controls.goods_attribute2:setPosition(detailBgSize.width * 0.5, detailBgSize.height * 0.2)
        detailBg:addChild(self.controls.goods_attribute2)

        self.controls.compound = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
        self.controls.compound:setCircleFont("合成" , 1, 1, 30, cc.c3b(248, 216, 136), 1)
        self.controls.compound:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
        self.controls.compound:setPosition(size.width * 0.5, size.height * 0.25)
        self.controls.bg:addChild(self.controls.compound, bgZOrder)
        self.controls.compound:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if not self.data.isClickCompound then
                    self.data.isClickCompound = true
                    local isCanCompound = true
                    for k,v in pairs(self.data.equipFragShowTab) do
                        if v:getGoodsNum() < 1 then
                            isCanCompound = false
                        end
                    end
                    if isCanCompound then
                        self.controls.quanBG:setRotation(0)
                        self:Compound(self.data.currTreasureID)
                    else
                        application:showFlashNotice("碎片不足")
                        self.data.isClickCompound = false
                    end
                end
            end
        end)

        local leftSize = left:getContentSize()
        local viewSize = cc.size(leftSize.width, leftSize.height * 0.75)
        self.controls.magicView = createTable(viewSize, 1)
        self.controls.magicView:setPosition(0, -viewSize.height * 0.5)
        left:addChild(self.controls.magicView)
        self.controls.bookView = createTable(viewSize, 2)
        self.controls.bookView:setPosition(-viewSize.width, -viewSize.height * 0.5) 
        right:addChild(self.controls.bookView)
        
        local posX1, posY1 = left:getPosition()
        local posX2, posY2 = right:getPosition()
        self.controls.bg:addChild(self:createUnClickLayer(posX1, posY1 + leftSize.height * 0.4, 
                                posX2 - leftSize.width, posY2 + leftSize.height * 0.4, 
                                posX1, posY1 - leftSize.height * 1.38,
                                posX2 - leftSize.width, posY2 - leftSize.height * 1.38,
                                leftSize), bgZOrder)
        
        self.data.equipFragTab = {}
        if 0 == (#self.data.equipFragTab) then
            for i=1,6 do
                local item = TrumpGoodsInfo.new(BaseConfig.GOODS_FRAG, self.data.showMagicTab[1])
                item:setScale(0)
                self.controls.quanBG:addChild(item)
                table.insert(self.data.equipFragTab, item)
            end
        end
    end
    middleUI()

    local bottomBG = cc.Sprite:create("image/ui/img/bg/bg_194.png")
    local bottomSize = bottomBG:getContentSize()
    bottomBG:setPosition(self.data.size.width * 0.5, self.data.size.height * 0.12)
    self.controls.bg:addChild(bottomBG, bgZOrder)

    self.controls.time = Common.finalFont("", bottomSize.width * 0.42, bottomSize.height * 0.4, 25, cc.c3b(194, 216, 230), 1)
    bottomBG:addChild(self.controls.time)

    local btn_safe = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, "image/ui/img/btn/btn_1205.png", cc.size(158, 50))
    btn_safe:setCircleFont("获取保护", 1, 1, 20, cc.c3b(238, 205, 142))
    btn_safe:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    btn_safe:setPosition(bottomSize.width * 0.15, bottomSize.height * 0.35)
    bottomBG:addChild(btn_safe, 1)
    btn_safe:setChildPos(0.2, 0.5)
    btn_safe:setFontPos(0.62, 0.5)
    btn_safe:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended and inside then
            local safeNode = self:safeUI()
            self:addChild(safeNode)
        end
    end)

    local btn_defForm = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, "image/ui/img/btn/btn_1203.png", cc.size(158, 50))
    btn_defForm:setCircleFont("防守阵容", 1, 1, 20, cc.c3b(238, 205, 142))
    btn_defForm:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    btn_defForm:setPosition(bottomSize.width * 0.7, bottomSize.height * 0.35)
    bottomBG:addChild(btn_defForm, 1)
    btn_defForm:setChildPos(0.2, 0.5)
    btn_defForm:setFontPos(0.62, 0.5)
    btn_defForm:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended and inside then
            rpc:call("Loot.GetDefFormation", {}, function(event)
                application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_LOOT_DEFENSE, { attackerForm = event.result })
            end)
        end
    end)

    local btn_record = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, "image/ui/img/btn/btn_670.png", cc.size(158, 50))  
    btn_record:setCircleFont("夺宝记录", 1, 1, 20, cc.c3b(238, 205, 142))
    btn_record:setFontOutline(cc.c4b(70, 50, 14, 255), 2)
    btn_record:setPosition(bottomSize.width * 0.9, bottomSize.height * 0.35)
    bottomBG:addChild(btn_record, 1)
    btn_record:setChildPos(0.2, 0.5)
    btn_record:setFontPos(0.62, 0.5) 
    btn_record:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended and inside then
            rpc:call("Loot.History", nil, function(event)
                if event.status == Exceptions.Nil then
                    local recordInfo = event.result
                    local recordLayer = require("scene.main.loot.LootRecordLayer").new(recordInfo)
                    self:addChild(recordLayer)
                end
            end)
        end
    end)

end

function LootLayer:onEnter()

end

function LootLayer:onEnterTransitionFinish( )
    Common.OpenSystemLayer({5})
    LootLayer.super.onEnterTransitionFinish(self)
    
end

function LootLayer:onExit()
    LootLayer.super.onExit(self)
end

function LootLayer:onCleanup()
    scheduler:unscheduleScriptEntry(scheduler_showTime)
end

function LootLayer:safeUI()
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(420, 220))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    local bgSize = bg:getContentSize()

    local smallTag = 1
    local bigTag = smallTag + 1
    local function safeFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            local propsInfo = sender:getGoodsInfo()
            if propsInfo.Num > 0 then
                if self.data.time > 0 then
                    commonLayer.HintPanel("当前正处于保护状态,使用后将会覆盖,是否继续?", function()
                        rpc:call("Loot.Protect", propsInfo.ID, function(event)
                            if event.status == Exceptions.Nil then
                                GameCache.minusProps(propsInfo.ID, 1)
                                sender:setPropsNum()
                                self.data.time = event.result
                            end
                        end)
                    end)
                else
                    rpc:call("Loot.Protect", propsInfo.ID, function(event)
                        if event.status == Exceptions.Nil then
                            GameCache.minusProps(propsInfo.ID, 1)
                            sender:setPropsNum()
                            self.data.time = event.result
                        end
                    end)
                end
            else
                local buyLayer = commonLayer.BuyPropsLayer(propsInfo.ID, function()
                    rpc:call("Loot.BuyAndProtect", propsInfo.ID, function(event)
                        if event.status == Exceptions.Nil then
                            self.data.time = event.result
                        end
                    end)
                end)
                self:addChild(buyLayer)
            end
        end
    end

    local smallPillInfo = GameCache.GetProps(smallSafePillID)
    if nil == smallPillInfo then
        smallPillInfo = {ID = smallSafePillID, Num = 0}
    end
    local smallPillItem = TrumpGoodsInfo.new(BaseConfig.GOODS_PROPS, smallPillInfo, BaseConfig.GOODS_BIGTYPE)
    smallPillItem:setName()
    smallPillItem:setPropsNum()
    smallPillItem:setTag(smallTag)
    smallPillItem:setPosition(bgSize.width * 0.3, bgSize.height * 0.6)
    bg:addChild(smallPillItem, bgZOrder)
    smallPillItem:addTouchEventListener(safeFunc)

    local bigPillInfo = GameCache.GetProps(bigSafePillID)
    if nil == bigPillInfo then
        bigPillInfo = {ID = bigSafePillID, Num = 0}
    end
    local bigPillItem = TrumpGoodsInfo.new(BaseConfig.GOODS_PROPS, bigPillInfo, BaseConfig.GOODS_BIGTYPE)
    bigPillItem:setName()
    bigPillItem:setPropsNum()
    bigPillItem:setTag(bigTag)
    bigPillItem:setPosition(bgSize.width * 0.7, bgSize.height * 0.6)
    bg:addChild(bigPillItem, bgZOrder)
    bigPillItem:addTouchEventListener(safeFunc)

    local desc = Common.finalFont("免战4小时", 1, 1, 20, cc.c3b(151, 255, 74), nil)
    desc:setPosition(bgSize.width * 0.3, bgSize.height * 0.2)
    bg:addChild(desc, bgZOrder)
    desc = Common.finalFont("免战8小时", 1, 1, 20, cc.c3b(151, 255, 74), nil)
    desc:setPosition(bgSize.width * 0.7, bgSize.height * 0.2)
    bg:addChild(desc, bgZOrder)

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

    return node
end

--[[
    屏蔽tableview超出可视区域的事件
]]
function LootLayer:createUnClickLayer(posX1, posY1, posX2, posY2, posX3, posY3, posX4, posY4,clickContentSize)
    local size = self.controls.bg:getContentSize()
    local posX, posY = self.controls.bg:getPosition()
    local layer = cc.LayerColor:create(cc.c4b(255,0,0,0), size.width, size.height)
    layer:setPosition(posX - size.width * 0.5, posY - size.height * 0.5)

    local layer1 = cc.LayerColor:create(cc.c4b(255,0,255,0), clickContentSize.width, clickContentSize.height)
    layer1:setPosition(posX1, posY1)
    
    local layer2 = cc.LayerColor:create(cc.c4b(0,255,255,0), clickContentSize.width, clickContentSize.height)
    layer2:setPosition(posX2, posY2)

    local layer3 = cc.LayerColor:create(cc.c4b(255,255,0,0), clickContentSize.width, clickContentSize.height)
    layer3:setPosition(posX3, posY3)

    local layer4 = cc.LayerColor:create(cc.c4b(200,200,200,0), clickContentSize.width, clickContentSize.height)
    layer4:setPosition(posX4, posY4)

    layer:addChild(layer2)
    layer:addChild(layer1)
    layer:addChild(layer3)
    layer:addChild(layer4)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then 
            return true
        end
        return false
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer1)
    local listener2 = listener1:clone()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, layer2)
    local listener3 = listener1:clone()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener3, layer3)
    local listener4 = listener1:clone()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener4, layer4)
    return layer
end

function LootLayer:getPillNum()
    local propsInfoSmall = GameCache.GetProps(1204)
    if propsInfoSmall then
        self.data.pillID = 1204
        return propsInfoSmall.Num
    end

    local propsInfoBig = GameCache.GetProps(1205)
    if propsInfoBig then
        self.data.pillID = 1205
        return propsInfoBig.Num
    end

    return 0
end

function LootLayer:changeTreasureInfo(treasureInfo)
    for k,v in pairs(self.data.treasureTabs) do
        if v.ID == treasureInfo.ID then
            v = nil
            v = treasureInfo
        end
    end
end

function LootLayer:getFragNum(fragID, seat)
    for k,v in pairs(self.data.treasureTabs) do
        if v.ID == fragID then
            return v.SeatCount[seat]
        end
    end
    return 0
end

function LootLayer:setFragNum(fragID, seat)
    for k,v in pairs(self.data.treasureTabs) do
        if v.ID == fragID then
            v.SeatCount[seat] = v.SeatCount[seat] - 1
        end
    end
end

-- 从配置表中筛选出需要显示的符咒和天书(存储id和需要的碎片个数)
function LootLayer:countMagicAndBook()
    local tempTab = {}
    local treasureConfig = BaseConfig.AllTreasureConfig()

    for ID, item in pairs(treasureConfig.Data) do
        local elem
        _, elem = next(item.Seat_List)

        local value = {}
        value.Icon = elem.Icon
        value.ID = elem.ID 
        value.Name = elem.Name
        value.Seat = elem.Seat
        value.EnergyID = elem.EnergyID
        value.Num = table.nums(item.Seat_List)
        table.insert(tempTab, value)
    end

    self.data.showMagicTab = {}
    self.data.showBookTab = {}
    
    for k,v in pairs(tempTab) do
        local equipConfig = BaseConfig.GetEquip(v.ID, 0)
        local equipType = equipConfig.type
        local equipStarLevel = equipConfig.starLevel
        v.StarLevel = equipStarLevel
        if 5 == equipType then
            table.insert(self.data.showMagicTab, v)
        elseif 6 == equipType then
            table.insert(self.data.showBookTab, v)
        end
    end
    table.sort(self.data.showMagicTab, handler(self, self.trumpSort))
    table.sort(self.data.showBookTab, handler(self, self.trumpSort))
end

function LootLayer:trumpSort(a, b)
    local aConfig = BaseConfig.GetEquip(a.ID, a.StarLevel)
    local bConfig = BaseConfig.GetEquip(b.ID, b.StarLevel)
    local aOwnGoodsInfo = GameCache.GetEquip(a.ID, a.StarLevel)
    local bOwnGoodsInfo = GameCache.GetEquip(b.ID, b.StarLevel)
    -- local aNum = 0
    -- local bNum = 0
    -- if aOwnGoodsInfo then
    --     aNum = aOwnGoodsInfo.Num
    -- end
    -- if bOwnGoodsInfo then
    --     bNum = bOwnGoodsInfo.Num
    -- end
    if aConfig.talent == bConfig.talent then
        return aConfig.id > bConfig.id
    else
        return aConfig.talent < bConfig.talent
    end
end

function LootLayer:updateCompoundGoods(goodsInfo)
    self.data.currGoodsInfo = goodsInfo
    self.data.currTreasureID = goodsInfo.ID

    local function initPos()
        if (nil == self.data.posTabs) or (0 ~= (#self.data.posTabs)) then
            self.data.posTabs = {}
        end
        local size = self.controls.quanBG:getContentSize()
        local pos2 = {{size.width * 0.05, size.height * 0.5}, {size.width * 0.95, size.height * 0.5}}
        table.insert(self.data.posTabs, pos2)
        local pos3 = {{size.width * 0.5, size.height * 0.92}, {size.width * 0.05, size.height * 0.34}, {size.width * 0.95, size.height * 0.34}}
        table.insert(self.data.posTabs, pos3)
        local pos4 = {{size.width * 0.1, size.height * 0.75}, {size.width * 0.1, size.height * 0.25}, 
                    {size.width * 0.9, size.height * 0.25}, {size.width * 0.9, size.height * 0.75}}
        table.insert(self.data.posTabs, pos4)      
        local pos5 = {{size.width * 0.5, size.height * 0.92}, {size.width * 0.08, size.height * 0.65},
                    {size.width * 0.1, size.height * 0.28}, {size.width * 0.9, size.height * 0.28}, 
                    {size.width * 0.92, size.height * 0.65}} 
        table.insert(self.data.posTabs, pos5)
    end
    initPos()

    if self.data.equipFragShowTab then
        for i,v in ipairs(self.data.equipFragShowTab) do
            v:stopAllActions()
            v:setScale(0)
        end
    end
    self.data.equipFragShowTab = {}

    local equipConfigInfo = BaseConfig.GetEquip(goodsInfo.ID, 0)
    self.controls.middle_goods:setGoodsInfo(goodsInfo)
    self.controls.goodsName:setString(equipConfigInfo.name)
    -- 如果学习阶段没达到法宝的开启条件就不需要显示碎片
    local currID = (GameCache.Avatar.EnergyStep - 1) * 6 + GameCache.Avatar.EnergyAttrNum
    if currID <= goodsInfo.EnergyID then
        if (currID ~= goodsInfo.EnergyID) or (GameCache.Avatar.EnergyAttrNum ~= 0) then
            local energyID = goodsInfo.EnergyID + 1
            energyID = energyID > 240 and 240 or energyID
            local energyConfig = BaseConfig.getEnergyInfo(energyID)
            self.controls.goods_attribute1:setString("[255,255,255]开启条件[=]")
            self.controls.goods_attribute2:setString("[255,255,255]"..energyConfig.StepName.."[=]")
            self.controls.compound:setTouchEnable(false)
            self.controls.compound:setScale(0)
            self.controls.centerChooseEff:setVisible(false)
            return
        end
    end

    local descTab = Common.getEquipExtraDesc(equipConfigInfo, 1, nil, "[0, 255, 0]")
    self.controls.goods_attribute1:setString(descTab[1])
    self.controls.goods_attribute2:setString(descTab[2])

    local function onFragEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not self.data.isClickCompound then
                if self.data.time > 0 then
                    commonLayer.HintPanel("你现在处于免战状态,不可参与夺宝,是否解除免战?", function()
                        rpc:call("Loot.CancelProtect", nil, function(event)
                            if event.status == Exceptions.Nil then
                                self.data.time = 0
                            end
                        end)
                    end)
                else
                    Common.CloseSystemLayer({5})
                    local list = require("scene.main.loot.LootListLayer").new(sender.data.goodsInfo)
                    self:addChild(list)
                    
                end
            end
        end
    end
    for i=1,6 do
        local item = self.data.equipFragTab[i]
        item:setScale(0)
        if i <= goodsInfo.Num then
            -- goodsInfo是显示列表中的物品，碎片和物品只是id相同，不能将goodsInfo用来表示碎片
            -- 为每个碎片单独创建info
            local FragInfo = {}
            FragInfo.Icon = goodsInfo.Icon
            FragInfo.ID = goodsInfo.ID 
            FragInfo.Seat = i
            FragInfo.Name = BaseConfig.GetTreasure(FragInfo.ID, FragInfo.Seat).Name
            FragInfo.FragNum = self:getFragNum(FragInfo.ID, FragInfo.Seat)
            item:setGoodsInfo(FragInfo)
            item:showFragNum(FragInfo.FragNum)
            item:setPosition(self.data.posTabs[goodsInfo.Num - 1][i][1], self.data.posTabs[goodsInfo.Num - 1][i][2])
            table.insert(self.data.equipFragShowTab, item)
            item:addTouchEventListener(onFragEvent)
        end
    end

    local function playActions()
        if nil == self.controls.splitEffect then
            self.controls.splitEffect = effects:CreateAnimation(self.controls.middle_goods, 0, 0, nil, 24, false)
        else
            effects:RepeatAnimation(self.controls.splitEffect)
        end

        for k,v in pairs(self.data.equipFragShowTab) do
            v:stopAllActions()
            local size = self.controls.quanBG:getContentSize()
            v:setPosition(size.width * 0.5, size.height * 0.5)
        end
        self.controls.middle_goods:stopAllActions()
        self.controls.middle_goods:setPosition(self.controls.middle_goods.posX, self.controls.middle_goods.posY)

        local move1 = cc.MoveBy:create(0.08, cc.p(12, -10))
        local move2 = cc.MoveBy:create(0.08, cc.p(-24, 20))
        local move3 = cc.MoveBy:create(0.05, cc.p(18, -15))
        local move4 = cc.MoveBy:create(0.05, cc.p(-12, 10))
        local move5 = cc.MoveBy:create(0.03, cc.p(12, -7))
        local move6 = cc.MoveBy:create(0.03, cc.p(-6, 4))
        local move7 = cc.MoveBy:create(0.02, cc.p(2, -2))
        local middleFunc = cc.CallFunc:create(function()
            local num = #self.data.equipFragShowTab
            for k,v in pairs(self.data.equipFragShowTab) do
                local delay = cc.DelayTime:create((k - 1) * 0.1)
                local move = cc.MoveTo:create(0.1, cc.p(self.data.posTabs[num - 1][k][1], self.data.posTabs[num - 1][k][2]))
                local scale = cc.ScaleTo:create(0.05, 0.8)
                v:runAction(cc.Sequence:create(delay, cc.Spawn:create(move, scale)))
            end
            self.controls.compound:setScale(1)
            self:changeCompoundState()
        end)

        self.controls.middle_goods:runAction(cc.Sequence:create(move1, move2, move3, move4, move5, move6, move7, middleFunc))
    end
    playActions()
end

function LootLayer:changeCompoundState()
    local isCanCompound = true
    for k,v in pairs(self.data.equipFragShowTab) do
        if v:getGoodsNum() < 1 then
            isCanCompound = false
        end
    end
    if isCanCompound then
        self.controls.compound:setTouchEnable(true)
        self.controls.compound:setNorGLProgram(true)
        self.controls.centerChooseEff:setVisible(true)
    else
        self.controls.compound:setTouchEnable(false)
        self.controls.compound:setNorGLProgram(false)
        self.controls.centerChooseEff:setVisible(false)
    end
end

function LootLayer:showTime(dt)
    if self.controls.time then
        if self.data.time > 0 then
            self.data.time = self.data.time - 1
            local time = Common.timeFormat(self.data.time)
            self.controls.time:setString("保护时间 "..time)
        else
            self.controls.time:setString("保护时间 "..string.format("%02d:%02d:%02d", 0, 0, 0))
        end
    end
end

--[[
    保护时间
]]
function LootLayer:ProtectTime()
    rpc:call("Loot.ProtectTime", nil, function(event)
        if event.status == Exceptions.Nil then
            self.data.time = event.result
        end
    end)
end

--[[
    刷新已拥有碎片
]]
function LootLayer:UpdateFragList()
    rpc:call("Loot.TreasureFragList", nil, function(event)
        local value = event.result
        if event.status == Exceptions.Nil then
            self.data.treasureTabs = value
            self:updateCompoundGoods(self.data.currGoodsInfo)
        end
    end)
end

--[[
    合成
]]--
function LootLayer:Compound(treasureID)
    rpc:call("Loot.Compound", treasureID, function(event)
        if event.status == Exceptions.Nil then
            local func = cc.CallFunc:create(function()
                if nil == self.controls.compoundEffect then
                    self.controls.compoundEffect = effects:CreateAnimation(self.controls.middle_goods, 0, 0, nil, 23, false)
                else
                    effects:RepeatAnimation(self.controls.compoundEffect)
                end

                local equipConfig = BaseConfig.GetEquip(treasureID, 0)
                GameCache.addEquip(treasureID, equipConfig.starLevel, 1)
                for k,v in pairs(self.data.equipFragShowTab) do
                    local num = v:getGoodsNum() - 1
                    v:showFragNum(num)
                    self:setFragNum(treasureID, k)
                end
                self.data.currGoodsItem:setNum()
                self.controls.quanBG:setScale(1)
                self.data.isClickCompound = false
                self:changeCompoundState()
                application:showFlashNotice("合成成功～！！！")
            end)
            local rotate = cc.RotateBy:create(0.6, 360 * 2)
            local scale = cc.Sequence:create(cc.DelayTime:create(0.4), cc.ScaleBy:create(0.2, 0))
            self.controls.quanBG:runAction(cc.Sequence:create(cc.Spawn:create(rotate, scale), func))
        end
    end)
end


return LootLayer




