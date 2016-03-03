local RecordLayer = class("RecordLayer", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")

local DefPanel = 1
local AtkPanel = DefPanel + 1

function RecordLayer:ctor(recordInfo, callback)
    self.callback = callback
    self.data.ExchangeBuildNumber = 1
    self.data.DecorationBuildNumber = 2
    self.data.PillBuildNumber = 3
    self.data.WoodBuildNumber = 4
    self.data.MetalBuildNumber = 5
    self.data.HeroSoulBuildNumber = 6
    RecordLayer.super.ctor(self)

    if recordInfo.Def or recordInfo.Atk then
        self.data.isHaveRecord = true
    end
    self.data.defInfoTabs = recordInfo.Def or {}
    self.data.atkInfoTabs = recordInfo.Atk or {}
    self.data.currPanel = DefPanel
    self:createUI()
end

function RecordLayer:createUI()
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 200), display.width, display.height)
    layerColor:setPosition(display.width/2 - layerColor:getContentSize().width / 2, 
                            display.height/2 - layerColor:getContentSize().height / 2)
    self:addChild(layerColor)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(650, 470))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local timu = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_1199.png") 
    timu:setPosition(size.width * 0.5, size.height * 0.98)
    self.controls.bg:addChild(timu)
    timu:setTouchEnable(false)

    self.controls.noReceiveAlert = cc.Node:create()
    self.controls.noReceiveAlert:setPosition(size.width * 0.46, size.height * 0.5)
    self.controls.bg:addChild(self.controls.noReceiveAlert)
    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    spri:setPosition(-40, 0)
    self.controls.noReceiveAlert:addChild(spri)
    local desc = Common.finalFont("暂无战况", 1, 1, 22, cc.c3b(61, 131, 172))
    desc:setPosition(60, 0)
    self.controls.noReceiveAlert:addChild(desc)
    if self.data.isHaveRecord then
        self.controls.noReceiveAlert:setScale(0)
    end

    local chooseBtns = {}
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(chooseBtns) do
                if name == v:getName() then
                    v:setTouchStatus()
                    v:setFontColor(cc.c3b(253, 230, 154))
                    v:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
                    if name == "attack" then
                        v:getChild():setVisible(false)
                    end
                else
                    v:setNormalStatus()
                    v:setFontColor(cc.c3b(177, 174, 170))
                    v:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
                end
            end

            if name ==  "defend" then
                self.data.currPanel = DefPanel
                self.controls.defView:setPosition(cc.p(20, 30))
                self.controls.atkView:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
            elseif name == "attack" then
                self.data.currPanel = AtkPanel
                self.controls.defView:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
                self.controls.atkView:setPosition(20, 30)
            end
        end
    end

    local btn_defend = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
    btn_defend:setRotation(90)
    btn_defend:setAnchorPoint(0.5, 0)
    btn_defend:setBgTouchAnchorPoint(0.5, 0)
    btn_defend:setTouchStatus()
    btn_defend:setCircleFont("防\n守" , 1, 1, 30, cc.c3b(253, 230, 154))
    btn_defend:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
    btn_defend:setFontPos(0.5, 0.9)
    btn_defend:getFont():setRotation(-90)
    btn_defend:setPosition(size.width * 0.988, size.height * 0.72)
    btn_defend:setName("defend")
    btn_defend:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_defend)
    table.insert(chooseBtns, btn_defend)

    local btn_attack = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png", "image/ui/img/btn/btn_398.png")
    btn_attack:setChildPos(0.05, 1.3)
    btn_attack:setRotation(90)
    btn_attack:setAnchorPoint(0.5, 0)
    btn_attack:setBgTouchAnchorPoint(0.5, 0)
    btn_attack:setCircleFont("进\n攻" , 1, 1, 30, cc.c3b(177, 174, 170))
    btn_attack:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
    btn_attack:setFontPos(0.5, 0.9)
    btn_attack:getFont():setRotation(-90)
    btn_attack:setPosition(size.width * 0.988, size.height * 0.32)
    btn_attack:setName("attack")
    btn_attack:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_attack)
    table.insert(chooseBtns, btn_attack)

    -- 判断是否需要提示
    local isAlert = false
    for k,atkInfo in pairs(self.data.atkInfoTabs) do
        if not atkInfo.IsRead then
            isAlert = true
        end
    end
    if not isAlert then
        btn_attack:getChild():setVisible(false)
    end

    local close = ccui.Button:create("image/ui/img/btn/btn_598.png")
    close:setPosition(size.width * 0.98, size.height * 0.98)
    self.controls.bg:addChild(close)
    close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.callback then
                self.callback()
            end
            self:removeFromParent()
            self = nil
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.bg)

    self.controls.defView = self:createView(cc.size(size.width * 0.98, size.height * 0.85), self.data.defInfoTabs, DefPanel)
    self.controls.bg:addChild(self.controls.defView)
    self.controls.defView:setPosition(cc.p(20, 30))
    self.controls.atkView = self:createView(cc.size(size.width * 0.98, size.height * 0.85), self.data.atkInfoTabs, AtkPanel)
    self.controls.bg:addChild(self.controls.atkView)
    self.controls.atkView:setPosition(SCREEN_WIDTH, SCREEN_HEIGHT)
end

function RecordLayer:createView(size, recordInfoTabs, currPanel)
    local dateTag = 1
    local winTag = dateTag + 1
    local descTag = winTag + 1
    local resultTag = descTag + 1
    local lookTag = resultTag + 1
    local alertTag = lookTag + 1

    function cellSizeForTable(table,idx) 
        return 90, 100
    end
    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local recordInfo = recordInfoTabs[(#recordInfoTabs) - idx]

        local winSpri = nil
        local dateLab = nil
        local descLab = nil
        local btn_result = nil
        local btn_loot = nil
        local alertSpri = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local bg = cc.Sprite:create("image/ui/img/bg/bg_173.png")
            local bgSize = bg:getContentSize()
            bg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            cell:addChild(bg)

            winSpri = cc.Sprite:create("image/ui/img/btn/btn_621.png")
            winSpri:setTag(winTag)
            winSpri:setPosition(bgSize.width * 0.12, bgSize.height * 0.5)
            cell:addChild(winSpri)

            descLab = ColorLabel.new("[255,0,0]我掠夺了[=]", 22, nil, true)
            descLab:setAnchorPoint(0, 0.5)
            descLab:setTag(descTag)
            descLab:setPosition(bgSize.width * 0.23, bgSize.height * 0.65)
            cell:addChild(descLab)

            dateLab = Common.finalFont("1991/11/9", bgSize.width * 0.23, bgSize.height * 0.3, 20, cc.c3b(45,41,91))
            dateLab:setAnchorPoint(0, 0.5)
            dateLab:setTag(dateTag)
            cell:addChild(dateLab)

            btn_result = ccui.Button:create("image/ui/img/btn/btn_1198.png")
            btn_result:setTag(resultTag)
            btn_result:setPosition(bgSize.width * 0.76, bgSize.height * 0.5)
            cell:addChild(btn_result)

            btn_loot = ccui.Button:create("image/ui/img/btn/btn_1197.png")
            btn_loot:setTag(lookTag)
            btn_loot:setPosition(bgSize.width * 0.92, bgSize.height * 0.5)
            cell:addChild(btn_loot)

            alertSpri = cc.Sprite:create("image/ui/img/btn/btn_398.png")
            alertSpri:setTag(alertTag)
            alertSpri:setPosition(20, bgSize.height * 0.9)
            cell:addChild(alertSpri)
        else
            winSpri = cell:getChildByTag(winTag)
            dateLab = cell:getChildByTag(dateTag)
            descLab = cell:getChildByTag(descTag)
            btn_result = cell:getChildByTag(resultTag)
            btn_loot = cell:getChildByTag(lookTag)
            alertSpri = cell:getChildByTag(alertTag)
        end
        dateLab:setString(recordInfo.DateTime)
        btn_result:addTouchEventListener(function(sender, eventType)
            if (eventType == ccui.TouchEventType.ended) and (not table:isTouchMoved()) then
                rpc:call("Home.RecordDetail", recordInfo.ID, function (event)
                    if event.status == Exceptions.Nil then
                        if event.result then
                            recordInfo.IsRead = true
                            alertSpri:setVisible(false)
                            self:detailRecord(event.result)
                        else
                            application:showFlashNotice("没有任何建筑受到攻击~")
                        end
                    end
                end)
            end
        end)
        btn_loot:addTouchEventListener(function(sender, eventType)
            if (eventType == ccui.TouchEventType.ended) and (not table:isTouchMoved()) then
                local desc = "上仙,你是否要对"..recordInfo.EnemyName.."发起一次复仇?\n\n"
                local alert = "(注意:只有这一次免费复仇机会～)"
                require("tool.helper.CommonLayer").HintPanel(desc..alert, function()
                    local node = cc.Node:create()
                    cc.Director:getInstance():setNotificationNode(node)

                    local parent = self:getParent()
                    local cloudAction = parent:cloudAction(node)
                    cloudAction.joinAction(function()
                        cc.Director:getInstance():popScene()
                        rpc:call("Home.Avenge", recordInfo.ID, function (event)
                            if event.status == Exceptions.Nil and event.result then
                                local enemyHomeInfo = event.result
                                local enemyInfo = enemyHomeInfo.EnemyBase
                                application:pushScene("main.home.HomeScene", enemyHomeInfo, false, enemyInfo) 
                                cloudAction.exitAction()
                            end
                        end)
                    end)
                end)
            end
        end)
        local isWin = recordInfo.IsWin
        if isWin then
            winSpri:setTexture("image/ui/img/btn/btn_621.png")
        else
            winSpri:setTexture("image/ui/img/btn/btn_622.png")
        end
        if DefPanel == currPanel then
            winDesc = "[114,42,1]"..recordInfo.EnemyName.."[=][45,41,91]掠夺了你的家园[=]"
            descLab:setString(winDesc)
            btn_loot:setVisible(true)
        elseif AtkPanel == currPanel then
            winDesc = "[45,41,91]我掠夺了[=][114,42,1]"..recordInfo.EnemyName.."[=][45,41,91]的家园[=]"
            descLab:setString(winDesc)
            btn_loot:setVisible(false)
        end

        if recordInfo.IsRead then
            alertSpri:setVisible(false)
        else
            alertSpri:setVisible(true)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return (#recordInfoTabs)
    end

    local tableView = cc.TableView:create(size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    return tableView
end

function RecordLayer:detailRecord(recordInfoTabs)
    local bgSize = cc.size(520, 500)
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setOpacity(240)
    bg:setContentSize(bgSize)
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local detailName = createMixSprite("image/ui/img/btn/btn_781.png")
    detailName:setTouchEnable(false)
    detailName:setCircleFont("详细战报", 1, 1, 20, cc.c3b(78, 160, 190))
    detailName:setPosition(bgSize.width * 0.5, bgSize.height * 0.93)
    bg:addChild(detailName)
    if self.data.currPanel == DefPanel then
        detailName:setString("守方战报")
    else
        detailName:setString("攻方战报")
    end
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(bgSize.width * 0.2, bgSize.height * 0.93)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(bgSize.width * 0.8, bgSize.height * 0.93)
    bg:addChild(line)

    local winSpri1 = cc.Sprite:create("image/ui/img/btn/btn_621.png")
    winSpri1:setPosition(bgSize.width * 0.15, bgSize.height * 0.8)
    bg:addChild(winSpri1)
    local name = Common.finalFont("CEO之家:", 1, 1, 22, cc.c3b(78, 160, 190))
    name:setAnchorPoint(0, 0.5)
    name:setPosition(bgSize.width * 0.24, bgSize.height * 0.8)
    bg:addChild(name)
    local winSpri2 = cc.Sprite:create("image/ui/img/btn/btn_621.png")
    winSpri2:setPosition(bgSize.width * 0.15, bgSize.height * 0.65)
    bg:addChild(winSpri2)
    name = Common.finalFont("木料公司:", 1, 1, 22, cc.c3b(78, 160, 190))
    name:setAnchorPoint(0, 0.5)
    name:setPosition(bgSize.width * 0.24, bgSize.height * 0.65)
    bg:addChild(name)
    local winSpri3 = cc.Sprite:create("image/ui/img/btn/btn_621.png")
    winSpri3:setPosition(bgSize.width * 0.15, bgSize.height * 0.5)
    bg:addChild(winSpri3)
    name = Common.finalFont("造币公司:", 1, 1, 22, cc.c3b(78, 160, 190))
    name:setAnchorPoint(0, 0.5)
    name:setPosition(bgSize.width * 0.24, bgSize.height * 0.5)
    bg:addChild(name)
    local winSpri4 = cc.Sprite:create("image/ui/img/btn/btn_621.png")
    winSpri4:setPosition(bgSize.width * 0.15, bgSize.height * 0.35)
    bg:addChild(winSpri4)
    name = Common.finalFont("升星丹厂:", 1, 1, 22, cc.c3b(78, 160, 190))
    name:setAnchorPoint(0, 0.5)
    name:setPosition(bgSize.width * 0.24, bgSize.height * 0.35)
    bg:addChild(name)
    local winSpri5 = cc.Sprite:create("image/ui/img/btn/btn_621.png")
    winSpri5:setPosition(bgSize.width * 0.15, bgSize.height * 0.2)
    bg:addChild(winSpri5)
    name = Common.finalFont("将魂研究院:", 1, 1, 22, cc.c3b(78, 160, 190))
    name:setAnchorPoint(0, 0.5)
    name:setPosition(bgSize.width * 0.24, bgSize.height * 0.2)
    bg:addChild(name)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            bg:removeFromParent()
            bg = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    -- local recordInfo = {
    --     {
    --         Type = 1,
    --         IsWin = true,
    --         Count = {10, 99999, 99999, 10},
    --     },
    --     {
    --         Type = 2,
    --         IsWin = true,
    --         Count = {200000},
    --     },
    --     {
    --         Type = 3,
    --         IsWin = true,
    --         Count = {999, 999},
    --     },
    --     {
    --         Type = 4,
    --         IsWin = false,
    --         Count = {1},
    --     },
    --     {
    --         Type = 6,
    --         IsWin = false,
    --         Count = {1000, 50},
    --     },
    -- }

    if not recordInfoTabs then
        for i=1,5 do
            local desc = Common.finalFont("(未被攻击)", 1, 1, 22, cc.c3b(78, 160, 190))
            desc:setAnchorPoint(0, 0.5)
            desc:setPosition(bgSize.width * 0.45, bgSize.height * 0.8 - bgSize.height * 0.15 * (i - 1))
            bg:addChild(desc)
        end
        return
    end

    local newRecord = {}
    for k,v in pairs(recordInfoTabs) do
        newRecord[v.Type] = v
    end

    if newRecord[self.data.DecorationBuildNumber] then
        local info = newRecord[self.data.DecorationBuildNumber]
        if info.IsWin then
            winSpri1:setTexture("image/ui/img/btn/btn_621.png")
        else
            winSpri1:setTexture("image/ui/img/btn/btn_622.png")
        end
        local desc = Common.finalFont("", 1, 1, 22, cc.c3b(78, 160, 190))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(bgSize.width * 0.45, bgSize.height * 0.8)
        bg:addChild(desc)

        if self.data.currPanel == DefPanel then
            if info.IsWin then
                desc:setString("没有损失")
            else
                if 0 ~= info.Count then
                    desc:setString("被插旗")
                else
                    desc:setString("未插旗")
                end
            end
        else
            if info.IsWin then
                if 0 ~= info.Count then
                    desc:setString("战胜(已插旗)")
                else
                    desc:setString("战胜(未插旗)")
                end
            else
                desc:setString("技不如人")
            end
        end
    else
        winSpri1:setTexture("image/ui/img/btn/btn_555.png")
        local desc = Common.finalFont("(未被攻击)", 1, 1, 22, cc.c3b(78, 160, 190))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(bgSize.width * 0.45, bgSize.height * 0.8)
        bg:addChild(desc)
    end
    
    if newRecord[self.data.WoodBuildNumber] then
        local info = newRecord[self.data.WoodBuildNumber]
        if info.IsWin then
            winSpri2:setTexture("image/ui/img/btn/btn_621.png")
        else
            winSpri2:setTexture("image/ui/img/btn/btn_622.png")
        end
        local coinSpri = cc.Sprite:create("image/ui/img/btn/btn_1109.png")
        coinSpri:setPosition(bgSize.width * 0.48, bgSize.height * 0.65)
        bg:addChild(coinSpri)
        coinSpri:setScale(0.5)
        local capacity = Common.finalFont("", 1, 1, 20, nil, 1)
        capacity:setPosition(bgSize.width * 0.6, bgSize.height * 0.65)
        bg:addChild(capacity)
        capacity:setString(info.Count)
    else
        winSpri2:setTexture("image/ui/img/btn/btn_555.png")
        local desc = Common.finalFont("(未被攻击)", 1, 1, 22, cc.c3b(78, 160, 190))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(bgSize.width * 0.45, bgSize.height * 0.65)
        bg:addChild(desc)
    end

    if newRecord[self.data.MetalBuildNumber] then
        local info = newRecord[self.data.MetalBuildNumber]
        if info.IsWin then
            winSpri3:setTexture("image/ui/img/btn/btn_621.png")
        else
            winSpri3:setTexture("image/ui/img/btn/btn_622.png")
        end
        local coinSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        coinSpri:setPosition(bgSize.width * 0.48, bgSize.height * 0.5)
        bg:addChild(coinSpri)
        local capacity = Common.finalFont("", 1, 1, 20, nil, 1)
        capacity:setPosition(bgSize.width * 0.6, bgSize.height * 0.5)
        bg:addChild(capacity)
        capacity:setString(info.Count)

    else
        winSpri3:setTexture("image/ui/img/btn/btn_555.png")
        local desc = Common.finalFont("(未被攻击)", 1, 1, 22, cc.c3b(78, 160, 190))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(bgSize.width * 0.45, bgSize.height * 0.5)
        bg:addChild(desc)
    end

    if newRecord[self.data.PillBuildNumber] then
        local info = newRecord[self.data.PillBuildNumber]
        if info.IsWin then
            winSpri4:setTexture("image/ui/img/btn/btn_621.png")
        else
            winSpri4:setTexture("image/ui/img/btn/btn_622.png")
        end
        local upgradeStarSpri = cc.Sprite:create("image/ui/img/btn/btn_1236.png")
        upgradeStarSpri:setPosition(bgSize.width * 0.48, bgSize.height * 0.35)
        bg:addChild(upgradeStarSpri)
        upgradeStarSpri:setScale(0.4)
        local capacity = Common.finalFont("", 1, 1, 20, nil, 1)
        capacity:setPosition(bgSize.width * 0.6, bgSize.height * 0.35)
        bg:addChild(capacity)
        capacity:setString(info.Count)
    else
        winSpri4:setTexture("image/ui/img/btn/btn_555.png")
        local desc = Common.finalFont("(未被攻击)", 1, 1, 22, cc.c3b(78, 160, 190))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(bgSize.width * 0.45, bgSize.height * 0.35)
        bg:addChild(desc)
    end

    if newRecord[self.data.HeroSoulBuildNumber] then
        local info = newRecord[self.data.HeroSoulBuildNumber]
        if info.IsWin then
            winSpri5:setTexture("image/ui/img/btn/btn_621.png")
        else
            winSpri5:setTexture("image/ui/img/btn/btn_622.png")
        end
        local upgradeStarSpri = cc.Sprite:create("image/ui/img/btn/btn_1347.png")
        upgradeStarSpri:setPosition(bgSize.width * 0.52, bgSize.height * 0.2)
        bg:addChild(upgradeStarSpri)
        upgradeStarSpri:setScale(0.4)
        local capacity = Common.finalFont("", 1, 1, 20, nil, 1)
        capacity:setPosition(bgSize.width * 0.65, bgSize.height * 0.2)
        bg:addChild(capacity)
        capacity:setString(info.Count)
    else
        winSpri5:setTexture("image/ui/img/btn/btn_555.png")
        local desc = Common.finalFont("(未被攻击)", 1, 1, 22, cc.c3b(78, 160, 190))
        desc:setAnchorPoint(0, 0.5)
        desc:setPosition(bgSize.width * 0.5, bgSize.height * 0.2)
        bg:addChild(desc)
    end
    
end

function RecordLayer:RecordList(id)
    rpc:call("Loot.RecordList", {RID = id}, function(event)
        if event.status == Exceptions.Nil then
            self.data.recordList = event.result
        end
    end)
end

return RecordLayer




