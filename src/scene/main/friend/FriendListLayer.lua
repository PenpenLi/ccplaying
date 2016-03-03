local FriendListLayer = class("FriendListLayer", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")
local Head_Texture_VIP = { "image/ui/img/bg/newhead.png", "image/ui/img/bg/newhead2.png", "image/ui/img/bg/newhead3.png" }

function FriendListLayer:ctor(size)
    self.data.bgSize = size
    self.data.FriendHeadTab = {}
    self.data.isCanSend = true

    self:createUI()
end

function FriendListLayer:createUI()
    local infoBG = cc.Sprite:create("image/ui/img/bg/bg_169.png")
    infoBG:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.62)
    self:addChild(infoBG)
    local size = infoBG:getContentSize()

    local bottom = cc.Sprite:create("image/ui/img/bg/bg_168.png")
    bottom:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.3)
    self:addChild(bottom)

    local headBG = cc.Sprite:create("image/icon/border/head_bg.png")
    headBG:setPosition(size.width * 0.28, size.height * 0.55)
    infoBG:addChild(headBG)

    self.controls.headSpri = cc.Sprite:create("image/ui/img/btn/btn_484.png")
    self.controls.headSpri:setPosition(headBG:getContentSize().width * 0.5, headBG:getContentSize().height * 0.5)
    headBG:addChild(self.controls.headSpri)

    self.controls.headVipBg = cc.Sprite:create("image/icon/border/border_star_00.png")
    self.controls.headVipBg:setPosition(headBG:getContentSize().width * 0.5 - 3, headBG:getContentSize().height * 0.5 - 3)
    headBG:addChild(self.controls.headVipBg)

    self.controls.friendName = Common.systemFont("", 1, 1, 25, nil)
    self.controls.friendName:setPosition(size.width * 0.7, size.height * 0.65)
    infoBG:addChild(self.controls.friendName)

    local sprite_vip = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
    sprite_vip:setPosition(size.width * 0.25, size.height * 0.88)
    infoBG:addChild(sprite_vip)

    self.controls.friendVip = Common.finalFont("", 1, 1, 20, cc.c3b(255,201,60),1)
    self.controls.friendVip:setAnchorPoint(0, 0.5)
    self.controls.friendVip:setPosition(size.width * 0.32, size.height * 0.88)
    infoBG:addChild(self.controls.friendVip)

    self.controls.friendLevel = Common.finalFont("", headBG:getContentSize().width * 0.5, 10, 18, nil, 1)
    headBG:addChild(self.controls.friendLevel)

    local Power = Common.finalFont("战力", size.width * 0.48, size.height * 0.25, 22)
    Power:setAnchorPoint(0, 0)
    infoBG:addChild(Power)

    self.controls.friendPower = Common.finalFont("", 1, 1, 25, cc.c3b(151, 255, 74))
    self.controls.friendPower:setPosition(Power:getPositionX() + Power:getContentSize().width * 1.2, size.height * 0.25)
    self.controls.friendPower:setAnchorPoint(0, 0)
    infoBG:addChild(self.controls.friendPower)

    local function onTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName() 
            if "look" == name then
                rpc:call("Hero.GetFilterLevelHeroEx", {RID = self.data.friendId, MinStarLevel = 5}, function ( event )
                    if event.status == Exceptions.Nil and event.result ~= nil then
                        local herolayer = require("scene.main.hero.FriendAllHeroLayer").new(event.result)
                        local scene = cc.Director:getInstance():getRunningScene()
                        scene:addChild(herolayer)
                    else
                        application:showFlashNotice("不好意思，您的仙友暂时没有4星及以上星将!")
                    end
                end)
            end
            if "contact" == name then
                local contactPanel = self:contactPanel()
                self:addChild(contactPanel)
            end
            if "challenge" == name then
                application:showFlashNotice("功能暂未开放")
            end
            if "delete" == name then
                require("tool.helper.CommonLayer").AlertPanel("亲,确定删除该好友？", function() 
                     self:getDeleteFriend(self.data.friendId)
                end, true)
            end
        end
    end

    local btn_look = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(119, 72))
    btn_look:setPosition(self.data.bgSize.width * 0.11, self.data.bgSize.height * 0.3)
    btn_look:setCircleFont("查看", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_look:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self:addChild(btn_look)
    btn_look:setName("look")
    btn_look:addTouchEventListener(onTouchEvent)

    local btn_contact = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(119, 72))
    btn_contact:setPosition(self.data.bgSize.width * 0.29, self.data.bgSize.height * 0.3)
    btn_contact:setCircleFont("联络", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_contact:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self:addChild(btn_contact)
    btn_contact:setName("contact")
    btn_contact:addTouchEventListener(onTouchEvent)

    local btn_challenge = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(119, 72))
    btn_challenge:setPosition(self.data.bgSize.width * 0.11, self.data.bgSize.height * 0.14)
    btn_challenge:setCircleFont("挑战", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_challenge:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self:addChild(btn_challenge)
    btn_challenge:setName("challenge")
    btn_challenge:addTouchEventListener(onTouchEvent)

    local btn_delete = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(119, 72))
    btn_delete:setPosition(self.data.bgSize.width * 0.29, self.data.bgSize.height * 0.14)
    btn_delete:setCircleFont("删除", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_delete:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self:addChild(btn_delete)
    btn_delete:setName("delete")
    btn_delete:addTouchEventListener(onTouchEvent)

    self.controls.sendPower = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(167, 72))
    self.controls.sendPower:setPosition(self.data.bgSize.width * 0.68, self.data.bgSize.height * 0.11)
    self.controls.sendPower:setCircleFont("一键赠送", 1, 1, 25, cc.c3b(248, 216, 136))
    self.controls.sendPower:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self:addChild(self.controls.sendPower)
    self.controls.sendPower:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.began then
            self.data.isCanSend = false
        end
        if eventType == ccui.TouchEventType.ended and (not inside) then
            self.data.isCanSend = true
        end
        if (eventType == ccui.TouchEventType.ended) and inside then
            rpc:call("Friend.QuickSendPower", id, function(event)
                if event.status == Exceptions.Nil then
                    for k,friendInfo in pairs(self.data.friendsList) do
                        friendInfo.IsSendPower = true
                    end
                    self:updateFriend()
                    application:showFlashNotice("赠送成功！")
                end
                self.data.isCanSend = true
            end)
        end
    end)

    self:updateFriend()
end

function FriendListLayer:createFriendsView(size)
    local row = math.ceil((#self.data.friendsList) / 3)
    local layoutHeight = (240) * row
    function cellSizeForTable(table,idx) 
        return layoutHeight, 100
    end

    function tableCellAtIndex(viewTable, idx)
        local cell = viewTable:dequeueCell()

        local function getFriendInfoEvent(sender)
            for k,v in pairs(self.data.FriendHeadTab) do
                if v.setChooseBorder then
                    v:setChooseBorder(false)
                end
            end
            sender:setChooseBorder(true)
            self.data.friendId = sender.friendInfo.RID
            self.data.friendName = sender.friendInfo.Name
            self.controls.friendName:setString(sender.friendInfo.Name)
            self.controls.friendVip:setString(sender.friendInfo.VIP)
            self.controls.friendLevel:setString("Lv."..sender.friendInfo.Level)
            self.controls.friendPower:setString(sender.friendInfo.TFP)
            local headPath =  string.format("image/icon/head/xj_%d.png", sender.friendInfo.Icon)
            self.controls.headSpri:setTexture(headPath)
            if sender.friendInfo.VIP < 15 then
                self.controls.headVipBg:setTexture(Head_Texture_VIP[math.floor(sender.friendInfo.VIP/5)+1])
            else
                self.controls.headVipBg:setTexture("image/ui/img/bg/newhead4.png")
            end
        end 

        local function layout()
            local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0), size.width, layoutHeight)
            layerColor:setAnchorPoint(0, 0)

            for k,v in pairs(self.data.friendsList) do
                local info = require("scene.main.friend.widget.DetailInfo").new(v)
                info:downButton("image/ui/img/btn/btn_611.png", "image/ui/img/btn/btn_610.png")
                local btn = info:getButton()
                btn:setCircleFont("送体力", 1, 1, 25, cc.c3b(238, 205, 142), 1)
                info:setPosition(size.width * 0.2 + ((k - 1) % 3) * 150, layoutHeight - 60 - (math.floor((k - 1) / 3)) * 240)
                layerColor:addChild(info)
                if not v.IsSendPower then
                    btn:setTouchStatus()
                    btn:setTouchEnable(true)
                    btn:addTouchEventListener(function(sender, eventType, isInside)
                        if eventType == ccui.TouchEventType.ended and isInside and self.data.isCanSend then
                            if not viewTable:isTouchMoved() then
                                self.data.friendId = v.RID
                                self:SendPowerToFriend(v.RID, sender) 
                            end
                        end
                    end)
                else
                    btn:setTouchEnable(false)
                    btn:setNorGLProgram(false)
                end
                info:addTouchEventListener(getFriendInfoEvent)
                if k == 1 then
                    info:setChooseBorder(true)
                end
                table.insert(self.data.FriendHeadTab, info)
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

        return cell
    end

    function numberOfCellsInTableView(table)
       return 1
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

function FriendListLayer:contactPanel()
    local panelSize = cc.size(590, 280)

    local node = cc.Node:create()

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    bg:setContentSize(panelSize)
    bg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.68)
    node:addChild(bg)

    local bg1 = cc.Sprite:create("image/ui/img/bg/bg_274.png")
    bg1:setPosition(panelSize.width * 0.5, panelSize.height * 0.55)
    bg:addChild(bg1)

    local friendName = ColorLabel.new("[10,51,91]正在和[=][237,97,47]"..self.data.friendName.."[=][10,51,91]联络[=]", 25, nil, true)
    friendName:setPosition(panelSize.width * 0.5, panelSize.height * 0.84)
    bg:addChild(friendName)

    local size = cc.size(panelSize.width * 0.85,panelSize.height * 0.4)
    local edit_account = ccui.TextField:create()
    edit_account:setTouchEnabled(true)
    edit_account:ignoreContentAdaptWithSize(false)
    edit_account:setPlaceHolder("")
    edit_account:setContentSize(size)
    edit_account:setFontSize(25)
    edit_account:setColor(cc.c3b(42, 87, 124))
    edit_account:setMaxLengthEnabled(true)
    edit_account:setMaxLength(60)
    edit_account:setFontName("DFYuanW7-GBK")
    edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    edit_account:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    edit_account:setPosition(panelSize.width * 0.5, panelSize.height * 0.52)
    bg:addChild(edit_account)

    local btn_sure = createMixSprite("image/ui/img/btn/btn_593.png")
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    bg:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local content = edit_account:getStringValue()
            content = string.trim(content)
            if "" ~= content then
                self:ContactFriend(self.data.friendId, content)
            end
            node:removeFromParent()
            node = nil
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

function FriendListLayer:updateFriend()
    if 0 == GameCache.getCurrFriendNum() then
        self:setScale(0)
    else
        self.data.friendsList = {}
        local allFriends = GameCache.getFriendsList()
        for k,v in pairs(allFriends) do
            table.insert(self.data.friendsList, v)
        end

        table.sort(self.data.friendsList, function(a, b)
            return a.Level > b.Level
        end)
        if self.controls.friendsView then
            self.controls.friendsView:removeFromParent()
            self.controls.friendsView = nil
        end
        self.controls.friendsView = self:createFriendsView(cc.size(self.data.bgSize.width * 0.55, self.data.bgSize.height * 0.66))
        self.controls.friendsView:setPosition(cc.p(self.data.bgSize.width * 0.4, self.data.bgSize.height * 0.18))
        self:addChild(self.controls.friendsView)

        self.controls.sendPower:setTouchEnable(false)
        self.controls.sendPower:setNorGLProgram(false)
        for k,friendInfo in pairs(self.data.friendsList) do
            if not friendInfo.IsSendPower then
                self.controls.sendPower:setTouchEnable(true)
                self.controls.sendPower:setNorGLProgram(true)
                break
            end
        end

        self.data.friendId = self.data.friendsList[1].RID
        self.data.friendName = self.data.friendsList[1].Name
        self.controls.friendName:setString(self.data.friendsList[1].Name)
        self.controls.friendVip:setString(self.data.friendsList[1].VIP)
        self.controls.friendLevel:setString("Lv."..self.data.friendsList[1].Level)
        self.controls.friendPower:setString(self.data.friendsList[1].TFP)
        local headPath =  string.format("image/icon/head/xj_%d.png", self.data.friendsList[1].Icon)
        self.controls.headSpri:setTexture(headPath)
        if self.data.friendsList[1].VIP < 15 then
            self.controls.headVipBg:setTexture(Head_Texture_VIP[math.floor(self.data.friendsList[1].VIP/5)+1])
        else
            self.controls.headVipBg:setTexture("image/ui/img/bg/newhead4.png")
        end
    end
end

--[[
    留言
]]--
function FriendListLayer:ContactFriend(friendId, content)
    rpc:call("Friend.ContactFriend", {FriendRID = friendId,Msg = content}, function(event)
        if event.status == Exceptions.Nil then
            application:showFlashNotice("留言成功～！")
        end
    end)
end

--[[
    删除好友
]]--
function FriendListLayer:getDeleteFriend(id)
    rpc:call("Friend.DeleteFriend", id, function(event)
        if event.status == Exceptions.Nil then
            GameCache.deletaFriend(id)
            self:updateFriend()
            application:showFlashNotice("删除好友成功！")
            application:dispatchCustomEvent(AppEvent.UI.Friend.UpgradeFriend, {})
        end
    end)
end

--[[
    赠送体力
]]--
function FriendListLayer:SendPowerToFriend(id, btn)
    rpc:call("Friend.SendPowerToFriend", id, function(event)
        if event.status == Exceptions.Nil then
            btn:setTouchEnable(false)
            btn:setNorGLProgram(false)
            local friendInfo = GameCache.getFriendInfo(id)
            friendInfo.IsSendPower = true
            application:showFlashNotice("赠送成功,侠义值+5")

            local isAllSend = true
            for k,friendInfo in pairs(self.data.friendsList) do
                if not friendInfo.IsSendPower then
                    isAllSend = false
                    break
                end
            end
            if isAllSend then
                self.controls.sendPower:setTouchEnable(false)
                self.controls.sendPower:setNorGLProgram(false)
            end
        end
    end)
end

return FriendListLayer