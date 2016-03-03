local ReceiveLayer = class("ReceiveLayer", BaseLayer)

local MAX_POWER = 60
local ONE_POWER = 3

function ReceiveLayer:ctor(size)
    self.data.bgSize = size
    self.data.UnRecFriends = {} --未领取体力
    self:createUI()
    self:ExchangeList()
end

function ReceiveLayer:onEnter()
    self:updateFriend()
end

function ReceiveLayer:createUI()
    local leftBg = createMixSprite("image/ui/img/bg/bg_171.png", nil, "image/ui/img/btn/btn_040.png")
    leftBg:getBg():setScaleX(0.52)
    leftBg:setChildPos(0.55, 0.6)
    leftBg:setTouchEnable(false)
    leftBg:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.78)
    self:addChild(leftBg)

    local friendsRequest = Common.finalFont("侠义值兑换", 1, 1, 25)
    friendsRequest:setPosition(self.data.bgSize.width * 0.14, self.data.bgSize.height * 0.79)
    self:addChild(friendsRequest)

    local detailName2 = createMixSprite("image/ui/img/btn/btn_651.png", nil, "image/ui/img/btn/btn_039.png")
    detailName2:setTouchEnable(false)
    detailName2:setPosition(self.data.bgSize.width * 0.69, self.data.bgSize.height * 0.78)
    detailName2:setChildPos(0.25, 0.5)
    detailName2:setCircleFont("仙友赠送的体力", 1, 1, 20, cc.c3b(233, 242, 255), 1)
    detailName2:setFontOutline(cc.c4b(27, 31, 49, 255), 1)
    self:addChild(detailName2)

    self.controls.errantry = Common.finalFont(GameCache.Avatar.Errantry, 1 , 1, 22, cc.c3b(255, 220, 20), 1)
    self.controls.errantry:setPosition(self.data.bgSize.width * 0.3, self.data.bgSize.height * 0.79)
    self:addChild(self.controls.errantry)

    self.controls.allReceive = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
    self.controls.allReceive:setPosition(self.data.bgSize.width * 0.82, self.data.bgSize.height * 0.15)
    self.controls.allReceive:setCircleFont("一键领取", 1, 1, 25, cc.c3b(248, 216, 136))
    self.controls.allReceive:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self:addChild(self.controls.allReceive)
    self.controls.allReceive:addTouchEventListener(function(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            local isSuccess = GameCache.addDailyPower(0)
            if not isSuccess then
                application:showFlashNotice("今天收取体力总数已达上限～！")
            else
                self:QuickAcceptPower()
            end
        end
    end)

    self.controls.confine = Common.finalFont("小提示:每日限领"..MAX_POWER.."点", self.data.bgSize.width * 0.56, self.data.bgSize.height * 0.15, 25, cc.c3b(54, 87, 154))
    self:addChild(self.controls.confine)

    self.controls.noReceiveAlert = cc.Node:create()
    self.controls.noReceiveAlert:setPosition(self.data.bgSize.width * 0.68, self.data.bgSize.height * 0.45)
    self:addChild(self.controls.noReceiveAlert)
    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    spri:setPosition(-100, 0)
    self.controls.noReceiveAlert:addChild(spri)
    local desc = Common.finalFont("你还没收到赠送的体力", 1, 1, 22, cc.c3b(61, 131, 172))
    desc:setPosition(60, 0)
    self.controls.noReceiveAlert:addChild(desc)
end

function ReceiveLayer:exchangeUI()
    if self.controls.scrollBar then
        local totalFriend = #self.data.ExchangeList
        if totalFriend > 2 then
            self.controls.scrollBar:setSize(cc.size(5, self.data.scrollHighest / (totalFriend - 1)))
            self.data.scrollDistance = self.data.scrollHighest - (self.data.scrollHighest / (totalFriend - 1))
        else
            self.controls.scrollBar:setSize(cc.size(5, self.data.scrollHighest))
            self.data.scrollDistance = 0
        end
        self.controls.scrollBar:setPosition(self.data.bgSize.width * 0.384, 420)
    else
        self.controls.scrollBar = ccui.ImageView:create()
        self.controls.scrollBar:setScale9Enabled(true)
        self.controls.scrollBar:loadTexture("image/ui/img/btn/btn_353.png")
        self.data.scrollHighest = 380
        local totalFriend = #self.data.ExchangeList

        if totalFriend > 2 then
            self.controls.scrollBar:setSize(cc.size(5, self.data.scrollHighest / (totalFriend - 1)))
            self.data.scrollDistance = self.data.scrollHighest - (self.data.scrollHighest / (totalFriend - 1))
        else
            self.controls.scrollBar:setSize(cc.size(5, self.data.scrollHighest))
            self.data.scrollDistance = 0
        end
        self.controls.scrollBar:setAnchorPoint(0, 1)
        self.controls.scrollBar:setPosition(self.data.bgSize.width * 0.384, 420)
        self:addChild(self.controls.scrollBar)
    end

    if self.controls.exchangeTableView then
        self.controls.exchangeTableView:reloadData()
    else
        self.controls.exchangeTableView = self:createExchangeView()
        self:addChild(self.controls.exchangeTableView)
    end
end

function ReceiveLayer:createExchangeView()
    local function scrollViewDidScroll(view)
        local totalHeight = self.data.scrollHighest - view:getContentSize().height
        local addHeight = self.data.scrollDistance * (1 - (view:getContentOffset().y / totalHeight))

        if addHeight < self.data.scrollDistance and addHeight > 0 then
            self.controls.scrollBar:setPositionY(420 - addHeight)
        end
    end
    local function cellSizeForTable(table,idx) 
        return 200,100
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local function onTouchFunc(exchangeSelf)
            local goodsInfo = exchangeSelf.goodsInfo
            if GameCache.Avatar.Errantry >= (goodsInfo.Price * goodsInfo.Num) then
                self:Exchange(goodsInfo.Type, goodsInfo.ID, goodsInfo.Price, goodsInfo.Num, exchangeSelf)
            else
                application:showFlashNotice("侠义值不足～！")
            end
        end

        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), 420, 190)
            layerColor:setAnchorPoint(0 , 0)
            local item = require("scene.main.friend.widget.ExchangeInfo").new(self.data.ExchangeList[idx + 1], onTouchFunc)
            item:setPosition(self.data.bgSize.width * 0.18, self.data.bgSize.height * 0.18)
            layerColor:addChild(item)
            return layerColor
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:addChild(getLayer())
        else
            cell:removeAllChildren()
            cell:addChild(getLayer())
        end

        return cell
    end
    local function numberOfCellsInTableView(table)
       return #self.data.ExchangeList
    end
    ccSize = cc.size(320, 360)
    local tableView = cc.TableView:create(ccSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(20 , 40))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView    
end

function ReceiveLayer:createFriendsView(size)
    local row = math.ceil((#self.data.UnRecFriends) / 3)
    local layoutHeight = (size.height * 0.83) * row
    function cellSizeForTable(table,idx) 
        return layoutHeight, 100
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local function layout()
            local layerColor = cc.LayerColor:create(cc.c4b(0,0,200,0), size.width, layoutHeight)
            layerColor:setAnchorPoint(0, 0)

            for k,v in pairs(self.data.UnRecFriends) do
                local info = require("scene.main.friend.widget.DetailInfo").new(v)
                info:downButton("image/ui/img/btn/btn_610.png", nil, "image/ui/img/btn/btn_653.png")
                local btn = info:getButton()
                btn:setChildPos(0.4, 0.5)
                btn:setFont("+"..ONE_POWER, 1, 1, 20, nil, 1)
                btn:setFontPos(0.7, 0.5)
                info:setPosition(size.width * 0.2 + ((k - 1) % 3) * 150, layoutHeight - 60 - (math.floor((k - 1) / 3)) * size.height * 0.83)
                layerColor:addChild(info)
                btn:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if not table:isTouchMoved() then
                            local isSuccess = GameCache.addDailyPower(ONE_POWER)
                            if not isSuccess then
                                application:showFlashNotice("今天收取体力总数已达上限～！")
                            else
                                self:AcceptPowerFromFriend(v.RID)
                            end
                        end
                    end
                end)
            end
            return layerColor
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:addChild(layout())
        else
            cell:removeAllChildren()
            cell:addChild(layout())
        end
        if layoutHeight > (size.height * 0.8) then
            table:setBounceable(true)
        else
            table:setBounceable(false)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
       return 1
    end

    local tableView = cc.TableView:create(size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(self.data.bgSize.width * 0.4, self.data.bgSize.height * 0.22))
    tableView:setDelegate()
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    return tableView
end

function ReceiveLayer:updateFriend()
    self.data.UnRecFriends = {}
    local allFriends = GameCache.getFriendsList()
    for k,v in pairs(allFriends) do
        if v.IsReceivePower then
            table.insert(self.data.UnRecFriends, v)
        end
    end

    if self.controls.friendsView then
        self.controls.friendsView:removeFromParent()
        self.controls.friendsView = nil
    end
    self.controls.friendsView = self:createFriendsView(cc.size(self.data.bgSize.width * 0.56, self.data.bgSize.height * 0.5))
    self:addChild(self.controls.friendsView)
    
    if (#self.data.UnRecFriends) > 0 then
        self.controls.allReceive:setTouchEnable(true)
        self.controls.allReceive:setPosition(self.data.bgSize.width * 0.82, self.data.bgSize.height * 0.15)
        self.controls.confine:setScale(1)
        local power = (GameCache.FriendInfo.DailyAcceptPower > MAX_POWER) and MAX_POWER or GameCache.FriendInfo.DailyAcceptPower
        self.controls.confine:setString("小提示:每日限领("..power.."/"..MAX_POWER..")")
        self.controls.noReceiveAlert:setScale(0)
    else
        self.controls.allReceive:setTouchEnable(false)
        self.controls.allReceive:setPosition(-SCREEN_WIDTH, -SCREEN_HEIGHT)
        self.controls.confine:setScale(0)
        self.controls.noReceiveAlert:setScale(1)
    end
end

function ReceiveLayer:updateErrantry()
    self.controls.errantry:setString(GameCache.Avatar.Errantry)
    self.controls.errantry:playChangeAction()
end

--[[
    收取体力
]]--
function ReceiveLayer:AcceptPowerFromFriend(id)
    rpc:call("Friend.AcceptPowerFromFriend", id, function(event)
        if event.status == Exceptions.Nil then
            application:showFlashNotice("领取成功")
            GameCache:acceptPowerFromFriend(id)
            self:updateFriend()
            application:dispatchCustomEvent(AppEvent.UI.Friend.Hint, {IsHintUnRec = true})
        end
    end)
end

--[[
    收取所有体力
]]--
function ReceiveLayer:QuickAcceptPower()
    rpc:call("Friend.QuickAcceptPower", nil, function(event)
        if event.status == Exceptions.Nil then
            for k,v in pairs(self.data.UnRecFriends) do
                local isSuccess = GameCache.addDailyPower(ONE_POWER)
                if isSuccess then
                    GameCache:acceptPowerFromFriend(v.RID)
                else
                    application:showFlashNotice("今天收取体力总数已达上限～！")
                    break
                end
            end
            self:updateFriend()
            application:dispatchCustomEvent(AppEvent.UI.Friend.Hint, {IsHintUnRec = true})
        end
    end)
end

--[[
    兑换物品列表
]]--
function ReceiveLayer:ExchangeList()
    rpc:call("Shop.Info", BaseConfig.MALL_TYPE_FRIEND, function(event)
        if event.status == Exceptions.Nil then
            self.data.ExchangeList = {}
            self.data.ExchangeList = event.result.List
            if (#self.data.ExchangeList) > 0 then
                self:exchangeUI()
            else
                if self.controls.exchangeTableView then
                    self.controls.exchangeTableView:removeFromParent()
                    self.controls.exchangeTableView = nil
                end
            end
        end
    end)
end

--[[
    兑换
]]--
function ReceiveLayer:Exchange(type, id, price, num, button)
    rpc:call("Shop.Exchange", {ShopType = BaseConfig.MALL_TYPE_FRIEND, GoodsType = type, GoodsID = id, GoodsNum = num}, function(event)
        if event.status == Exceptions.Nil then
            application:showIconNotice({event.result.Gain})
            self:updateErrantry()
            self:ExchangeList()
        end
    end)
end


return ReceiveLayer
