local AddFriendLayer = class("AddFriendLayer", BaseLayer)

function AddFriendLayer:ctor(size)
    self.data.bgSize = size
	self.controls.friendTab = {}
    self:createUI()

    self.data.askFriends = GameCache.getAddRequest()
    self.data.recFriends = GameCache.getSuggestList()
    if (#self.data.askFriends) > 0 then
        self:updateFriend()
    end
    self:FriendRecommend()
end

function AddFriendLayer:createUI()
    local leftBg = cc.Sprite:create("image/ui/img/bg/bg_171.png")
    leftBg:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.78)
    leftBg:setScaleX(0.52)
    self:addChild(leftBg)

    local friendsRequest = Common.finalFont("你收到的好友请求", 1, 1, 25)
    friendsRequest:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.79)
    self:addChild(friendsRequest)

    local detailName2 = createMixSprite("image/ui/img/btn/btn_651.png")
    detailName2:setTouchEnable(false)
    detailName2:setPosition(self.data.bgSize.width * 0.69, self.data.bgSize.height * 0.78)
    detailName2:setCircleFont("系统推荐给你结识的仙友", 1, 1, 23, nil, 1)
    detailName2:setFontOutline(cc.c4b(27, 31, 49, 255), 1)
    self:addChild(detailName2)

    local btn_update = createMixSprite("image/ui/img/btn/btn_497.png")
    btn_update:setPosition(self.data.bgSize.width * 0.9, self.data.bgSize.height * 0.78)
    self:addChild(btn_update)
    btn_update:addTouchEventListener(handler(self, self.Refresh))

    local inputBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_656.png")
    inputBg:setContentSize(cc.size(310, 60))
    inputBg:setPosition(self.data.bgSize.width * 0.62, self.data.bgSize.height * 0.16)
    self:addChild(inputBg)

    self.controls.eb_uname = cc.EditBox:create(cc.size(300, 35), cc.Scale9Sprite:create())
    self.controls.eb_uname:setPosition(self.data.bgSize.width * 0.63, self.data.bgSize.height * 0.16)
    self.controls.eb_uname:setMaxLength(12)
    self.controls.eb_uname:setFontColor(cc.c3b(0,0,0))
    self.controls.eb_uname:setPlaceHolder("输入角色昵称或ID")
    self.controls.eb_uname:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self:addChild(self.controls.eb_uname)

    local btn_select = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(119, 72))
    btn_select:setPosition(self.data.bgSize.width * 0.88, self.data.bgSize.height * 0.16)
    btn_select:setFont("搜索" , 1, 1, 25, cc.c3b(226, 204, 169))
    btn_select:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    self:addChild(btn_select)
    btn_select:addTouchEventListener(handler(self, self.Search))

    self.controls.noAskFriends = cc.Node:create()
    self.controls.noAskFriends:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.45)
    self:addChild(self.controls.noAskFriends)
    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    spri:setPosition(-90, 0)
    self.controls.noAskFriends:addChild(spri)
    local desc = Common.finalFont("没有收到好友请求", 1, 1, 22, cc.c3b(61, 131, 172))
    desc:setPosition(40, 0)
    self.controls.noAskFriends:addChild(desc)
end

function AddFriendLayer:createTableView()
    local function scrollViewDidScroll(view)
        local totalHeight = self.data.scrollHighest - view:getContentSize().height
        local addHeight = self.data.scrollDistance * (1 - (view:getContentOffset().y / totalHeight))

        if addHeight < self.data.scrollDistance and addHeight > 0 then
            self.controls.scrollBar:setPositionY(420 - addHeight)
        end
    end
    local function scrollViewDidZoom(view)

    end
    local function tableCellTouched(table,cell)

    end
    local function cellSizeForTable(table,idx) 
        return 200,100
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), 420, 195)
            layerColor:setAnchorPoint(0 , 0)
            local item = self:requestPanel(self.data.askFriends[idx + 1])
            item:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.18)
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
       return #self.data.askFriends
    end
    ccSize = cc.size(420, 360)
    local tableView = cc.TableView:create(ccSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(8, 40))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    return tableView    
end

function AddFriendLayer:requestPanel(friendInfo)
    local node = cc.Node:create()

    local infoBG = cc.Sprite:create("image/ui/img/bg/bg_172.png")
    node:addChild(infoBG)
    local size = infoBG:getContentSize()

    local headPath =  string.format("image/icon/head/xj_%d.png", friendInfo.Icon)
    local headSpri = cc.Sprite:create(headPath)
    headSpri:setPosition(size.width * 0.26, size.height * 0.6)
    infoBG:addChild(headSpri)

    local headBG = cc.Sprite:create("image/icon/border/border_star_00.png")
    headBG:setPosition(headSpri:getContentSize().width * 0.5 - 3, headSpri:getContentSize().height * 0.5 - 3)
    headSpri:addChild(headBG)

    local Head_Texture_VIP = { "image/ui/img/bg/newhead.png", "image/ui/img/bg/newhead2.png", "image/ui/img/bg/newhead3.png" }
    if friendInfo.VIP < 15 then
        headBG:setTexture(Head_Texture_VIP[math.floor(friendInfo.VIP/5)+1])
    else
        headBG:setTexture("image/ui/img/bg/newhead4.png")
    end

    local friendName = Common.systemFont(friendInfo.Name, 1, 1, 25, nil)
    friendName:setPosition(size.width * 0.7, size.height * 0.74)
    infoBG:addChild(friendName)

    local friendLevel = Common.finalFont("Lv."..friendInfo.Level, headSpri:getContentSize().width * 0.5, 10, 18, nil, 1)
    headSpri:addChild(friendLevel)

    local Power = Common.finalFont("战力", size.width * 0.48, size.height * 0.4, 22)
    Power:setAnchorPoint(0, 0)
    infoBG:addChild(Power)

    local friendPower = Common.finalFont(friendInfo.TFP, 1, 1, 25, cc.c3b(151, 255, 74))
    friendPower:setPosition(Power:getPositionX() + Power:getContentSize().width * 1.2, size.height * 0.4)
    friendPower:setAnchorPoint(0, 0)
    infoBG:addChild(friendPower)

    local function askTouchEvent(sender, touchEvent)
        if touchEvent == ccui.TouchEventType.ended then
            local name = sender:getName()
            if "yes" == name then
                self:HandleAddRequest(friendInfo.RID, true)
            end
            if "no" == name then
                self:HandleAddRequest(friendInfo.RID, false)
            end
        end
    end

    self.btn_yes = createMixSprite("image/ui/img/btn/btn_654.png")
    self.btn_yes:setPosition(size.width * 0.26, 32)
    infoBG:addChild(self.btn_yes)
    self.btn_yes:setName("yes")
    self.btn_yes:addTouchEventListener(askTouchEvent)

    self.btn_no = createMixSprite("image/ui/img/btn/btn_655.png")
    self.btn_no:setPosition(size.width * 0.76, 32)
    infoBG:addChild(self.btn_no)
    self.btn_no:setName("no")
    self.btn_no:addTouchEventListener(askTouchEvent)
    return node
end

function AddFriendLayer:FriendRecommend()
	if self.data.recFriends then
		local num = (#self.data.recFriends) < 3 and (#self.data.recFriends) or 3  
        for k,v in pairs(self.controls.friendTab) do
            if v then
                v:removeFromParent()
                v = nil
            end
        end
        self.controls.friendTab = {}

		for i=1,num do
	        local info = require("scene.main.friend.widget.DetailInfo").new(self.data.recFriends[i])
	        info:downButton("image/ui/img/btn/btn_610.png")
            local btn = info:getButton()
            btn:setCircleFont("结识", 1, 1, 25, cc.c3b(238, 205, 142), 1)
	        info:setPosition(self.data.bgSize.width * 0.34 + i * 150, self.data.bgSize.height * 0.6)
            self:addChild(info)
	        table.insert(self.controls.friendTab, info)
            btn:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if (GameCache.getCurrFriendNum()) >= (GameCache.getMaxFriendNum()) then
                        application:showFlashNotice("上仙,您的好友数量已达上限,不能再添加了")
                    else
                        self:AskForFriend(info:getFriendInfo().RID)
                    end
                end
            end)
	    end
	end
end

function AddFriendLayer:updateFriend()
    self.data.askFriends = GameCache.getAddRequest()
    
    if 0 == (#self.data.askFriends) then
        self.controls.noAskFriends:setScale(1)
    else
        self.controls.noAskFriends:setScale(0)
    end
    if self.controls.scrollBar then
        local totalFriend = #self.data.askFriends
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
        local totalFriend = #self.data.askFriends

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

    if self.controls.tabView then
        self.controls.tabView:reloadData()
    else
        self.controls.tabView = self:createTableView()
        self:addChild(self.controls.tabView) 
    end
end

function AddFriendLayer:stringMatching(content)
    if "lv." == string.sub(string.lower(content), 1, 3) then
        local afterContent = string.sub(content, 4, string.len(content))
        local _, _, result = string.find(afterContent, "(%d+)")
        if afterContent == result then
            return afterContent, ""
        else
            application:showFlashNotice("输入有误")
        end
    else
        return 0, content
    end
end

--[[
    好友申请
]]--
function AddFriendLayer:AskForFriend(id)
    rpc:call("Friend.AddFriend", id, function(event)
        if event.status == Exceptions.Nil then
            self:doRefresh()
            application:showFlashNotice("交友申请已发出！")
        elseif event.status == Exceptions.EFriendOtherNumOverflow then
            application:showFlashNotice("真遗憾啊，对方仙友数量已满！")
        elseif event.status == Exceptions.EFriendRepeatSendRequest then
            application:showFlashNotice("请勿重复发送结交请求！")
        end
    end)
end

--[[
    接受或拒绝
]]--
function AddFriendLayer:HandleAddRequest(id, isAgree)
    if isAgree and ((GameCache.getCurrFriendNum()) >= (GameCache.getMaxFriendNum())) then
        application:showFlashNotice("上仙,您的好友数量已达上限,不能再添加了")
        return 
    end
    rpc:call("Friend.HandleAddRequest", {FriendRID = id, Accept = isAgree}, function(event)
        if event.status == Exceptions.Nil then
            GameCache.AddFriend(id, isAgree)
            if isAgree then
                application:dispatchCustomEvent(AppEvent.UI.Friend.UpgradeFriend, {})
                application:showFlashNotice("恭喜上仙,又成功结交一位新朋友!")
            end
            self:updateFriend()
            application:dispatchCustomEvent(AppEvent.UI.Friend.Hint, {IsHintAsk = true})
        elseif event.status == Exceptions.EFriendOtherNumOverflow then
            application:showFlashNotice("真遗憾啊~对方好友数量已经满了!")
        elseif event.status == Exceptions.EFriendSelfNumOverflow then
            application:showFlashNotice("上仙,您的好友数量已达上限,不能再添加了")
        end
    end)
end


function AddFriendLayer:doRefresh()
    rpc:call("Friend.Refresh", nil, function(event)
        if event.status == Exceptions.Nil then
            self.data.recFriends = event.result
            GameCache.updateFriendSuggestList(self.data.recFriends)
            self:FriendRecommend()
        end
    end)
end
--[[
    换一批好友
]]
function AddFriendLayer:Refresh(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:doRefresh()
    end
end

--[[
	搜索
]]--
function AddFriendLayer:Search(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.controls.eb_uname then
            local word = self.controls.eb_uname:getText()
            if word ~= "" then
                local name = string.trim(word) 
                if ("" == name) then
                    application:showFlashNotice("没有搜索到匹配的玩家")
                else
                    rpc:call("Friend.Search", name, function(event)
                        if event.status == Exceptions.Nil then
                            if event.result then
                                self.data.recFriends = event.result
                                self:FriendRecommend()
                            else
                                application:showFlashNotice("没有搜索到匹配的玩家")
                            end
                        end
                    end)
                end
            else
                application:showFlashNotice("不能为空哦～！")
            end
        end
    end
end

return AddFriendLayer






