local FriendsLayer = class("FriendsLayer", BaseLayer)

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

function FriendsLayer:ctor()
    FriendsLayer.super.ctor(self)
    self.controls.receiveLayer = nil
    self.controls.addFriendLayer = nil
    self.controls.friendListLayer = nil

    self.controls.tabBtns = {}
    self:createUI()
    self.listener1 = application:addEventListener(AppEvent.UI.Friend.UpgradeFriend, function(event)
        self.controls.friendsNum:setString("仙友人数"..GameCache.getCurrFriendNum().."/"..GameCache.getMaxFriendNum())
    end)
    self.listener2 = application:addEventListener(AppEvent.UI.Friend.Hint, function(event)
        local result = event.data
        local isHintAsk = result.IsHintAsk
        local isHintUnRec = result.IsHintUnRec
        if isHintAsk then
            local askFriends = GameCache.getAddRequest()
            if (#askFriends) > 0 then
                self.controls.btn_addFriend:setChildTextureVisible(true)
            else
                self.controls.btn_addFriend:setChildTextureVisible(false)
            end
        end
        if isHintUnRec then
            local allFriends = GameCache.getFriendsList()
            local unRecFriends = {}
            for k,v in pairs(allFriends) do
                if v.IsReceivePower then
                    table.insert(unRecFriends, v)
                end
            end
            if (#unRecFriends) > 0 then
                self.controls.btn_receive:setChildTextureVisible(true)
            else
                self.controls.btn_receive:setChildTextureVisible(false)
            end
        end
    end)
    application:dispatchCustomEvent(AppEvent.UI.Friend.Hint, {IsHintAsk = true, IsHintUnRec = true})
end

function FriendsLayer:onClose()
    application:removeEventListener(self.listener1)
    application:removeEventListener(self.listener2)
    cc.Director:getInstance():popScene()
end

function FriendsLayer:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(cc.size(885, 558))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()
    local fringe = cc.Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height)
    self.controls.bg:addChild(fringe, bgZOrder)

    local leftBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    leftBG:setContentSize(cc.size(328, 473))
    leftBG:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.442)
    self.controls.bg:addChild(leftBG, bgZOrder)
    fringe = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    fringe:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.442)
    self.controls.bg:addChild(fringe, bgZOrder)

    local rightBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    rightBG:setContentSize(cc.size(540, 485))
    rightBG:setPosition(self.data.bgSize.width * 0.685, self.data.bgSize.height * 0.442)
    self.controls.bg:addChild(rightBG, bgZOrder)

    local currPageName = createMixSprite("image/ui/img/bg/bg_142.png", "image/ui/img/bg/bg_142.png", "image/ui/img/btn/btn_481.png")
    currPageName:setTouchEnable(false)
    currPageName:setChildPos(0.52, 0.55)
    currPageName:setPosition(self.data.bgSize.width * 0.1, self.data.bgSize.height)
    self.controls.bg:addChild(currPageName, bgZOrder)

    self.controls.friendsNum = Common.finalFont("仙友人数"..GameCache.getCurrFriendNum().."/"..GameCache.getMaxFriendNum(), 1, 1, 22, cc.c3b(0, 255, 0), 1)
    self.controls.friendsNum:setPosition(self.data.bgSize.width * 0.3, self.data.bgSize.height * 0.92)
    self.controls.bg:addChild(self.controls.friendsNum, bgZOrder)

    self.controls.noFriendsAlert = cc.Node:create()
    self.controls.noFriendsAlert:setPosition(self.data.bgSize.width * 0.7, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.noFriendsAlert, bgZOrder)
    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    spri:setPosition(-140, 0)
    self.controls.noFriendsAlert:addChild(spri)
    local desc = Common.finalFont("你还没有好友,请先添加好友", 1, 1, 22, cc.c3b(61, 131, 172))
    desc:setPosition(40, 0)
    self.controls.noFriendsAlert:addChild(desc)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.98)
    self.controls.bg:addChild(btn_close, btnZOrder)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if self.controls.receiveLayer then
                self.controls.receiveLayer:removeFromParent()
                self.controls.receiveLayer = nil
            end
            if self.controls.addFriendLayer then
                self.controls.addFriendLayer:removeFromParent()
                self.controls.addFriendLayer = nil
                
            end
            if self.controls.friendListLayer then
                self.controls.friendListLayer:removeFromParent()
                self.controls.friendListLayer = nil
            end
            self:onClose()
        end
    end)

    function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.controls.tabBtns) do
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

            self.controls.noFriendsAlert:setScale(0)
            if name ==  "receive" then
                if nil ~=  self.controls.addFriendLayer then
                    self.controls.addFriendLayer:setScale(0)
                end
                if nil ~= self.controls.friendListLayer then
                    self.controls.friendListLayer:setScale(0)
                end
                if nil == self.controls.receiveLayer then
                    self.controls.receiveLayer = require("scene.main.friend.ReceiveLayer").new(self.data.bgSize)
                    self.controls.bg:addChild(self.controls.receiveLayer, bgZOrder)
                else
                    self.controls.receiveLayer:updateFriend()
                    self.controls.receiveLayer:updateErrantry()
                    self.controls.receiveLayer:setScale(1)
                end
            elseif name == "addFriend" then
                if nil ~= self.controls.receiveLayer then
                    self.controls.receiveLayer:setScale(0)
                end
                if nil ~= self.controls.friendListLayer then
                    self.controls.friendListLayer:setScale(0)
                end
                if nil == self.controls.addFriendLayer then
                    self.controls.addFriendLayer = require("scene.main.friend.AddFriendLayer").new(self.data.bgSize)
                    self.controls.bg:addChild(self.controls.addFriendLayer, bgZOrder)
                else
                    self.controls.addFriendLayer:updateFriend()
                    self.controls.addFriendLayer:setScale(1)
                end
            
            elseif name == "friendList" then
                if nil ~= self.controls.receiveLayer then
                    self.controls.receiveLayer:setScale(0)
                end
                if nil ~=  self.controls.addFriendLayer then
                    self.controls.addFriendLayer:setScale(0)
                end
                if self.controls.friendListLayer then
                    self.controls.friendListLayer:setScale(1)
                    self.controls.friendListLayer:updateFriend()
                end
                if 0 == GameCache.getCurrFriendNum() then
                    self.controls.noFriendsAlert:setScale(1)
                end
            end
        end
    end

    local size = self.data.bgSize
    local btn_friendList = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
    btn_friendList:setTouchStatus()
    btn_friendList:setCircleFont("仙友列表" , 1, 1, 25, cc.c3b(253, 230, 154))
    btn_friendList:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
    btn_friendList:setFontPos(0.5, 0.8)
    btn_friendList:setBgTouchAnchorPoint(0.5, 0)
    btn_friendList:setAnchorPoint(0.5, 0)
    btn_friendList:setPosition(size.width * 0.86, size.height * 0.856)
    btn_friendList:setName("friendList")
    btn_friendList:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_friendList, bgZOrder)
    table.insert(self.controls.tabBtns , btn_friendList)

    self.controls.btn_addFriend = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png", "image/ui/img/btn/btn_398.png")
    self.controls.btn_addFriend:setChildPos(0.9, 1.2)
    self.controls.btn_addFriend:setCircleFont("添加仙友" , 1, 1, 25, cc.c3b(177, 174, 170))
    self.controls.btn_addFriend:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
    self.controls.btn_addFriend:setBgTouchAnchorPoint(0.5, 0)
    self.controls.btn_addFriend:setFontPos(0.5, 0.8)
    self.controls.btn_addFriend:setAnchorPoint(0.5, 0)
    self.controls.btn_addFriend:setPosition(size.width * 0.68, size.height * 0.856)
    self.controls.btn_addFriend:setName("addFriend")
    self.controls.btn_addFriend:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(self.controls.btn_addFriend, bgZOrder)
    table.insert(self.controls.tabBtns , self.controls.btn_addFriend)

    self.controls.btn_receive = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png", "image/ui/img/btn/btn_398.png")
    self.controls.btn_receive:setChildPos(0.9, 1.2)
    self.controls.btn_receive:setCircleFont("领取兑换" , 1, 1, 25, cc.c3b(177, 174, 170))
    self.controls.btn_receive:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
    self.controls.btn_receive:setBgTouchAnchorPoint(0.5, 0)
    self.controls.btn_receive:setFontPos(0.5, 0.8)
    self.controls.btn_receive:setAnchorPoint(0.5, 0)
    self.controls.btn_receive:setName("receive")
    self.controls.btn_receive:setPosition(size.width * 0.5, size.height * 0.856)
    self.controls.btn_receive:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(self.controls.btn_receive, bgZOrder)
    table.insert(self.controls.tabBtns , self.controls.btn_receive)

    self.controls.friendListLayer = require("scene.main.friend.FriendListLayer").new(self.data.bgSize)
    self.controls.bg:addChild(self.controls.friendListLayer, bgZOrder)
    if 0 ~= GameCache.getCurrFriendNum() then
        self.controls.noFriendsAlert:setScale(0)
    end
end

return FriendsLayer




