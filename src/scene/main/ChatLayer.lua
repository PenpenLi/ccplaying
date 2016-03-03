--[[
Author: xuchen
Date: 2016-02-17
]]

local ChatLayer = class("ChatLayer", BaseLayer)
local CommonLayer = require("tool.helper.CommonLayer")

local WORLDVIEW = "世界"
local PRIVATEVIEW = "私聊"
local SYSTEMVIEW = "系统"

local VIEWMENU = {"世界", "私聊", "系统"}

local MAXMESSAGECOUNT = 50

local fileName = "chatRecord_"..GameCache.Avatar.RID..".lua"

function ChatLayer:ctor(func)
	-- 回调函数
	self.closeFunc = func
	self.listener = nil

	self.data.currentLayer = nil
	self.data.worldMessage = {}
	self.data.privateMessage = {}
	self.data.systemmessage = {}

	self.controls.menuItem = {}
	self.controls.worldLayer = nil
	self.controls.privateLayer = nil
	self.controls.systemLayer = nil

	self.controls.worldListView = nil
	self.controls.privateListView = nil
	self.controls.systemListView = nil

	self.data.privateMessage = {}
	self.data.worldMessageOfSend = nil
	self.data.privateMessageOfSend = nil

	self.data.peopleOfChat = {} -- 私人聊天记录
	self.data.currentChatPerson = nil -- 当前私聊对象
	self.controls.tableViewOfChatPeople = nil

	self.data.friendList = {}
	self.data.sendPrivateId = nil

	self.data.sendTimes = nil
	self:initLayer()
end

function ChatLayer:initLayer()

	local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,180))
	self:addChild(bgLayer)

	local bigBg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
	bigBg:setAnchorPoint(0, 0)
	bgLayer:addChild(bigBg)

	local bg = ccui.ImageView:create("image/ui/img/bg/bg_111.png")
	bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
	bg:setScale9Enabled(true)
	bg:setContentSize(cc.size(775, 490))
	bgLayer:addChild(bg)

	local light1 = ccui.ImageView:create("image/ui/img/bg/bg_112.png")
	light1:setScale9Enabled(true)
	light1Height = light1:getContentSize().height
	light1:setAnchorPoint(0, 1)
	light1:setPosition(cc.p(5, bg:getContentSize().height - 2))
	light1:setContentSize(cc.size(bg:getContentSize().width - 8, light1Height))
	bg:addChild(light1)

	local light2 = ccui.ImageView:create("image/ui/img/bg/bg_113.png")
	light2:setScale9Enabled(true)
	light2:setAnchorPoint(0, 1)
	local light2height = light2:getContentSize().height
	light2:setPosition(cc.p(5, bg:getContentSize().height - 2))
	light2:setContentSize(cc.size(bg:getContentSize().width - 8, light2height))
	bg:addChild(light2)

	local contentBg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
	contentBg:setScale9Enabled(true)
	contentBg:setContentSize(cc.size(745, 430))
	contentBg:setPosition(cc.p(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.45))
	bg:addChild(contentBg)
	local contentBgSize = contentBg:getContentSize()

	local titleBg = cc.Sprite:create("image/ui/img/bg/bg_142.png")
	titleBg:setAnchorPoint(0, 0.5)
	titleBg:setPosition(cc.p(0, bg:getContentSize().height - 10))
	bg:addChild(titleBg)

	local title = cc.Sprite:create("image/ui/img/btn/btn_1258.png")
	title:setPosition(cc.p(titleBg:getContentSize().width * 0.5, titleBg:getContentSize().height * 0.5 + 5))
	titleBg:addChild(title)

	local worldLayer = cc.Layer:create()
	local privateLayer = cc.Layer:create()
	local systemLayer = cc.Layer:create()
	self.controls.worldLayer = worldLayer
	self.controls.privateLayer = privateLayer
	self.controls.systemLayer = systemLayer
	local layerMultiplex = cc.LayerMultiplex:create(worldLayer, privateLayer, systemLayer)
	contentBg:addChild(layerMultiplex)
	self.controls.layerMultiplex = layerMultiplex

	-- 读取本地私人聊天记录
	local localChatRecord = {}
	local localChatRecord = Common.copyTab(Common.readFile(fileName))
	if localChatRecord then
		self.data.peopleOfChat = localChatRecord
	end

	self:createWorldView(contentBgSize)
	self:createPrivateView(contentBgSize)
	self:createSystemView(contentBgSize)

	for _,person in pairs(self.data.peopleOfChat) do
		if person.isShow then
			-- 更新聊天对象
			self.data.sendPrivateId = person.Id
			-- 刷新私聊界面
			self:udatePrivateListView(person)
		end
	end

	-- 请求发送次数
	rpc:call("Chat.ChatRemain", nil, function(event)
		self:createTimesNode(event.result)
	end)

	local function onTouchBegan(touch, event)
		return true
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, contentBg)
	self.listener = listener

	local closeBtn = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
	closeBtn:setPosition(cc.p(bg:getContentSize().width, bg:getContentSize().height))
	closeBtn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			--self:removeFromParent()
			self:setVisible(false)
			if self.listener then
				self.listener:setSwallowTouches(false)
			end
			if self.closeFunc then
				self.closeFunc()
			end
		end
	end)
	bg:addChild(closeBtn)

	-- 创建聊天频道按钮
	local menu = cc.Menu:create()
	menu:setPosition(cc.p(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.9 - 15))
	bg:addChild(menu)

	local function selectView(tag, sender)
		local selectedTag = sender:getName()
		if sender:isSelected() then
			return
		end
		if selectedTag == WORLDVIEW then
			self.controls.menuItem[1]:selected()
			self.controls.menuItem[2]:unselected()
			self.controls.menuItem[3]:unselected()
			self.controls.menuItem[1]:getChildByName(WORLDVIEW):setColor(cc.c3b(253, 230, 154))
			self.controls.menuItem[2]:getChildByName(PRIVATEVIEW):setColor(cc.c3b(174,174,170))
			self.controls.menuItem[3]:getChildByName(SYSTEMVIEW):setColor(cc.c3b(174,174,170))
			layerMultiplex:switchTo(0)
			self.data.currentLayer = WORLDVIEW
			self.controls.worldListView:scrollToBottom(0.1, true)
		elseif selectedTag == PRIVATEVIEW then
			self.controls.menuItem[2]:selected()
			self.controls.menuItem[1]:unselected()
			self.controls.menuItem[3]:unselected()
			self.controls.menuItem[2]:getChildByName(PRIVATEVIEW):setColor(cc.c3b(253, 230, 154))
			self.controls.menuItem[1]:getChildByName(WORLDVIEW):setColor(cc.c3b(174,174,170))
			self.controls.menuItem[3]:getChildByName(SYSTEMVIEW):setColor(cc.c3b(174,174,170))
			layerMultiplex:switchTo(1)
			self.data.currentLayer = PRIVATEVIEW
			self.controls.privateListView:scrollToBottom(0.1, true)
		elseif selectedTag == SYSTEMVIEW then
			self.controls.menuItem[3]:selected()
			self.controls.menuItem[1]:unselected()
			self.controls.menuItem[2]:unselected()
			self.controls.menuItem[3]:getChildByName(SYSTEMVIEW):setColor(cc.c3b(253, 230, 154))
			self.controls.menuItem[1]:getChildByName(WORLDVIEW):setColor(cc.c3b(174,174,170))
			self.controls.menuItem[2]:getChildByName(PRIVATEVIEW):setColor(cc.c3b(174,174,170))
			layerMultiplex:switchTo(2)
			self.data.currentLayer = SYSTEMVIEW
			self.controls.systemListView:scrollToBottom(0.1, true)
		end
	end

	local xPos = 0
	for i, itemName in pairs(VIEWMENU) do
		local item = cc.MenuItemImage:create("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png")
		item:setScale(0.9)
		item:setName(itemName)
		item:setAnchorPoint(0.5, 0)
		item:setPosition(cc.p(xPos, 0))
		item:registerScriptTapHandler(selectView)
		menu:addChild(item)
		local itemFont = Common.finalFont(itemName,0,0,26,cc.c3b(174,174,170))
		itemFont:setName(itemName)
		itemFont:setPosition(cc.p(item:getContentSize().width * 0.5, item:getContentSize().height * 0.4))
		item:addChild(itemFont)
		if itemName == WORLDVIEW then
			item:selected()
			itemFont:setColor(cc.c3b(253, 230, 154))
		end
		xPos = xPos + 130
		table.insert(self.controls.menuItem, item)
	end

	self.data.currentLayer = WORLDVIEW

	-- 刷新私聊人物表
	self:updatePeopleOfChat()

	self:addEvenetListener()

end

function ChatLayer:createWorldView(size)
	local editBg = ccui.ImageView:create("image/ui/img/btn/btn_1421.png")
	editBg:setScale9Enabled(true)
	editBg:setAnchorPoint(0, 1)
	editBg:setPosition(cc.p(25, size.height * 0.92))
	editBg:setContentSize(cc.size(size.width * 0.78, 53))
	self.controls.worldLayer:addChild(editBg)

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = pSender
        if strEventName == "changed" then
            local text = edit:getText()
            local content = string.trim(text)
            if string.utf8len(content) >= 140 then
            	application:showFlashNotice("最多140个字符哦")
                content = utf8.sub(content,1,140)
                edit:setText(content)
            end
   			self.data.worldMessageOfSend = content
        end
    end

    local unused_texture = "dummy/kb.png"
	local editContent = ccui.EditBox:create(cc.size(size.width * 0.78 - 20, 43), unused_texture)
	editContent:setTouchEnabled(true)
	editContent:ignoreContentAdaptWithSize(false)
 	editContent:setFontName(BaseConfig.fontname)
 	editContent:setFontColor(cc.c3b(0,0,0))
 	editContent:setMaxLength(140)
    editContent:setPosition(cc.p(editBg:getContentSize().width * 0.5, editBg:getContentSize().height * 0.5 - 3))
    editContent:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editContent:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editContent:registerScriptEditBoxHandler(editBoxTextEventHandle) 
    editBg:addChild(editContent)
    editContent:setPlaceHolder("请输入发言内容：")

	local sendMessageBtn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
	sendMessageBtn:setPosition(cc.p(size.width * 0.84, size.height * 0.92 + 4))
	sendMessageBtn:setAnchorPoint(0, 1)
	self.controls.worldLayer:addChild(sendMessageBtn)
	local sendBg = cc.Sprite:create("image/ui/img/btn/btn_1259.png")
	sendBg:setPosition(cc.p(sendMessageBtn:getContentSize().width * 0.5, sendMessageBtn:getContentSize().height * 0.5))
	sendMessageBtn:addChild(sendBg)

	sendMessageBtn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			if GameCache.Avatar.Level < 10 then
				application:showFlashNotice("10级开启发言功能!")
				editContent:setText("") 
				return
			end
			if self.data.worldMessageOfSend then
				if self:isIllegalWord(self.data.worldMessageOfSend) then
					rpc:call("Chat.ChatRemain", nil, function(event)
						local isSend = self:sendLimit(event.result)
						if isSend then
							self:sendMessage("all")
							self.data.worldMessageOfSend = nil
							editContent:setText("")
							-- 更新UI
							self:updateTimesNode(event.result - 1)
						else
							application:showFlashNotice("元宝不足,不能发送消息!")
							editContent:setText("")
						end
					end)
				else
					local _, notice = self:isIllegalWord(self.data.worldMessageOfSend)
					application:showFlashNotice(notice)
				end
			else
				application:showFlashNotice("请输入发言内容!")
			end
		end
	end)

	local freeTimesBg1 = ccui.ImageView:create("image/ui/img/btn/btn_1418.png")
	freeTimesBg1:setAnchorPoint(0,1)
	freeTimesBg1:setPosition(cc.p(size.width * 0.84 - 3, size.height * 0.79))
	self.controls.worldLayer:addChild(freeTimesBg1)

	local freeTimesBg2 = ccui.ImageView:create("image/ui/img/btn/btn_1419.png")
	freeTimesBg2:setScale9Enabled(true)
	freeTimesBg2:setAnchorPoint(0,1)
	freeTimesBg2:setContentSize(cc.size(100, 27))
	freeTimesBg2:setPosition(cc.p(size.width * 0.84 - 3, size.height * 0.79))
	self.controls.worldLayer:addChild(freeTimesBg2)

	local timesNode = cc.Node:create()
	timesNode:setPosition(cc.p(size.width * 0.9+2, size.height * 0.75+3))
	self.controls.worldLayer:addChild(timesNode)
	self.controls.worldTimesNode = timesNode

	local listView = ccui.ListView:create()
	listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setContentSize(cc.size(size.width * 0.9, size.height * 0.6))
    listView:setAnchorPoint(0, 0)
    listView:setPosition(30,40)
 	self.controls.worldLayer:addChild(listView)
    self.controls.worldListView = listView
    self.data.worldListViewSize = listView:getContentSize()
end

function ChatLayer:sendLimit(times)	
	if times <= 0 and times >= -10 then
		if GameCache.Avatar.Gold < 5 then
			return false
		end
	elseif times < -10 and times >= -20 then
		if GameCache.Avatar.Gold < 10 then
			return false
		end
	elseif times < -20 then
		if GameCache.Avatar.Gold < 20 then
			return false
		end
	end
	return true	
end

function ChatLayer:createTimesNode(times)
	local function createTimesLabel(str)
		local time = Common.finalFont(str, 0, 0, 19, cc.c3b(143, 255, 99))
		return time
	end
	local function createMoneyLabel(str)
		local money = cc.Sprite:create("image/ui/img/btn/btn_845.png")
		money:setScale(0.5)
		money:setPosition(cc.p(-20, 0))
		local time = Common.finalFont(str, 16, 0, 20, cc.c3b(255, 255, 255))
		return money, time
	end
	if times > 0 and times <= 10 then
		local t1 = createTimesLabel("免费".."("..tostring(times)..")")
		local t2 = createTimesLabel("免费".."("..tostring(times)..")")
		self.controls.worldTimesNode:addChild(t1)
		self.controls.privateTimesNode:addChild(t2)
	elseif times > 10 then
		local t1 = createTimesLabel("免费发言")
		local t2 = createTimesLabel("免费发言")
		self.controls.worldTimesNode:addChild(t1)
		self.controls.privateTimesNode:addChild(t2)
	elseif times <= 0 and times >= -10 then
		local m1, t1 = createMoneyLabel("5")
		local m2, t2 = createMoneyLabel("5")
		self.controls.worldTimesNode:addChild(t1)
		self.controls.privateTimesNode:addChild(t2)
		self.controls.worldTimesNode:addChild(m1)
		self.controls.privateTimesNode:addChild(m2)
	elseif times < -10 and times >= -20 then
		local m1, t1 = createMoneyLabel("10")
		local m2, t2 = createMoneyLabel("10")
		self.controls.worldTimesNode:addChild(t1)
		self.controls.privateTimesNode:addChild(t2)
		self.controls.worldTimesNode:addChild(m1)
		self.controls.privateTimesNode:addChild(m2)
	elseif times < -20 then
		local m1, t1 = createMoneyLabel("20")
		local m2, t2 = createMoneyLabel("20")
		self.controls.worldTimesNode:addChild(t1)
		self.controls.privateTimesNode:addChild(t2)
		self.controls.worldTimesNode:addChild(m1)
		self.controls.privateTimesNode:addChild(m2)
	end
end

function ChatLayer:updateTimesNode(times)
	self.controls.worldTimesNode:removeAllChildren()
	self.controls.privateTimesNode:removeAllChildren()
	self:createTimesNode(times)
end

function ChatLayer:createPrivateView(size)
	local editBg = ccui.ImageView:create("image/ui/img/btn/btn_1421.png")
	editBg:setScale9Enabled(true)
	editBg:setAnchorPoint(0, 1)
	editBg:setPosition(cc.p(size.width * 0.2, size.height * 0.92))
	editBg:setContentSize(cc.size(size.width * 0.614, 53))
	self.controls.privateLayer:addChild(editBg)

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = pSender
        if strEventName == "changed" then
            local text = edit:getText()
            local content = string.trim(text)
            if string.utf8len(content) >= 140 then
            	application:showFlashNotice("最多140个字符哦")
                content = utf8.sub(content,1,140)
                edit:setText(content)
            end
            self.data.privateMessageOfSend = content
        end
    end

    local unused_texture = "dummy/kb.png"
	local editContent = ccui.EditBox:create(cc.size(size.width * 0.58, 43), unused_texture)
	editContent:setTouchEnabled(true)
	editContent:ignoreContentAdaptWithSize(false)
 	editContent:setFontName(BaseConfig.fontname)
 	editContent:setFontColor(cc.c3b(0,0,0))
 	editContent:setMaxLength(140)
    editContent:setPosition(cc.p(editBg:getContentSize().width * 0.5, editBg:getContentSize().height * 0.5 - 3))
    editContent:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editContent:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editContent:registerScriptEditBoxHandler(editBoxTextEventHandle) 
    editBg:addChild(editContent)
    editContent:setPlaceHolder("请输入发言内容：")

	local sendMessageBtn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
	sendMessageBtn:setPosition(cc.p(size.width * 0.84, size.height * 0.92 + 4))
	sendMessageBtn:setAnchorPoint(0, 1)
	self.controls.privateLayer:addChild(sendMessageBtn)
	local sendBg = cc.Sprite:create("image/ui/img/btn/btn_1259.png")
	sendBg:setPosition(cc.p(sendMessageBtn:getContentSize().width * 0.5, sendMessageBtn:getContentSize().height * 0.5))
	sendMessageBtn:addChild(sendBg)

	sendMessageBtn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			if GameCache.Avatar.Level < 10 then
				application:showFlashNotice("10级开启发言功能!")
				editContent:setText("") 
				return
			end
			if self.data.privateMessageOfSend then
				if self:isIllegalWord(self.data.privateMessageOfSend) then
					if self.data.sendPrivateId then
						rpc:call("Chat.ChatRemain", nil, function(event)
							local isSend = self:sendLimit(event.result)
							if isSend then
								self:sendMessage(self.data.sendPrivateId)
								-- 更新UI
								self:updateTimesNode(event.result - 1)
							else
								application:showFlashNotice("元宝不足,不能发送消息!")
							end
							self.data.privateMessageOfSend = nil
							editContent:setText("") 
						end)
					else
						application:showFlashNotice("请选择聊天对象!")
						editContent:setText("") 
					end
				else
					local _, notice = self:isIllegalWord(self.data.privateMessageOfSend)
					application:showFlashNotice(notice)
				end
			else
				application:showFlashNotice("请输入发言内容!")
			end
		end
	end)

	local freeTimesBg1 = ccui.ImageView:create("image/ui/img/btn/btn_1418.png")
	freeTimesBg1:setAnchorPoint(0,1)
	freeTimesBg1:setPosition(cc.p(size.width * 0.84 - 3, size.height * 0.79))
	self.controls.privateLayer:addChild(freeTimesBg1)

	local freeTimesBg2 = ccui.ImageView:create("image/ui/img/btn/btn_1419.png")
	freeTimesBg2:setScale9Enabled(true)
	freeTimesBg2:setAnchorPoint(0,1)
	freeTimesBg2:setContentSize(cc.size(100, 27))
	freeTimesBg2:setPosition(cc.p(size.width * 0.84 - 3, size.height * 0.79))
	self.controls.privateLayer:addChild(freeTimesBg2)

	local timesNode = cc.Node:create()
	timesNode:setPosition(cc.p(size.width * 0.9+2, size.height * 0.75+3))
	self.controls.privateLayer:addChild(timesNode)
	self.controls.privateTimesNode = timesNode

    local friendListBg = ccui.ImageView:create("image/ui/img/bg/bg_348.png")
    friendListBg:setAnchorPoint(0, 1)
    friendListBg:setScale9Enabled(true)
    friendListBg:setContentSize(cc.size(size.width * 0.15, size.height * 0.933))
    friendListBg:setPosition(cc.p(9, size.height * 0.965))
    self.controls.privateLayer:addChild(friendListBg)
    local friendListBgSize = friendListBg:getContentSize()

    if self.data.peopleOfChat then
    	local copy = false
    	for _,person in pairs(self.data.peopleOfChat) do
    		if person.Id == "0" then
    			copy = true
    		end
    	end
    	if not copy then
    		table.insert(self.data.peopleOfChat,{["Id"]="0", ["Icon"]="", ["Vip"]="",
    		 ["Level"]="", ["Message"]={}, ["isShow"]=false, isNotice=false})
    	end
    end
    local tableView = self:createPeopleWithChat(friendListBgSize)
    friendListBg:addChild(tableView)
    self.controls.tableViewOfChatPeople = tableView

	local listView = ccui.ListView:create()
	listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setContentSize(cc.size(size.width * 0.8, size.height * 0.6))
    listView:setAnchorPoint(0, 0)
    listView:setPosition(size.width * 0.2 - 20, 40)
 	self.controls.privateLayer:addChild(listView)
    self.controls.privateListView = listView
    self.data.privateListViewSize = listView:getContentSize()

end

function ChatLayer:createSystemView(size)
	local listView = ccui.ListView:create()
	listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setContentSize(cc.size(size.width * 0.9, size.height * 0.85))
    listView:setAnchorPoint(0, 0)
    listView:setPosition(35, 40)
 	self.controls.systemLayer:addChild(listView)
    self.controls.systemListView = listView
    self.data.systemListViewSize = listView:getContentSize()
end

function ChatLayer:createTimeListItem(time, width, isNum)
	local customItem = ccui.Layout:create()

    local timeBg = ccui.ImageView:create("image/ui/img/btn/btn_1424.png")
    timeBg:setPosition(cc.p(width/2, 25))
    customItem:addChild(timeBg)

    local t = nil
	local hour = nil 
	local min = nil
	local sec = nil

    if isNum then
    	local m = os.date("*t", time)
    	hour = m.hour
    	min = m.min
    	sec = m.sec
	  	if tonumber(m.hour) < 10 then
    		hour = "0"..m.hour
    	end 
    	if tonumber(m.min) < 10 then
    		min = "0"..m.min
    	end
    	if tonumber(m.sec) < 10 then
    		sec = "0"..m.sec
    	end	
    else
	    local info = {}
		for data in string.gmatch(time, "%w+") do
	 		table.insert(info, data)
		end
    	hour = info[1]
    	min = info[2]
    	sec = info[3]
	  	if tonumber(info[1]) < 10 then
    		hour = "0"..info[1]
    	end 
    	if tonumber(info[2]) < 10 then
    		min = "0"..info[2]
    	end
    	if tonumber(info[3]) < 10 then
    		sec = "0"..info[3]
    	end	
    end

    t = hour..":"..min..":"..sec
    local timeLabel = Common.finalFont(t, 55, 10, 16, cc.c3b(177, 174, 170))
    timeBg:addChild(timeLabel)

	customItem:setContentSize(cc.size(width, 50))
	return customItem
end

function ChatLayer:createSendItemOfListView(informations, str)
	local customItem = ccui.Layout:create()
	local itemSize = nil
	local newSize = nil
	if str == WORLDVIEW then
		itemSize = cc.size(self.data.worldListViewSize.width, 0)
	elseif str == PRIVATEVIEW then
		itemSize = cc.size(self.data.privateListViewSize.width, 0)
	end

	local headBg = cc.Sprite:create("image/ui/img/bg/newhead.png")
	headBg:setScale(0.7)
	headBg:setAnchorPoint(1, 1)
	customItem:addChild(headBg)
	local headBgSize = headBg:getBoundingBox()
	local head = ccui.ImageView:create(Common.heroIconImgPath(GameCache.Avatar.Icon))
	head:setPosition(cc.p(headBgSize.width/2 + 19, headBgSize.height/2 + 18))
	headBg:addChild(head)
	head:setRotationSkewY(180)

    local messageLabel = self:createBubbleFont(informations.Body, true)
    messageLabel:setAnchorPoint(1, 1)
    customItem:addChild(messageLabel)
    local messageLabelSize = messageLabel:getContentSize()

	if headBgSize.height*0.7 >= messageLabelSize.height then
		newSize = cc.size(itemSize.width, headBgSize.height)
	else
		newSize = cc.size(itemSize.width, headBgSize.height*0.3+messageLabelSize.height)
	end

	local littleIcon = cc.Sprite:create("image/ui/img/btn/btn_1428.png")
	littleIcon:setAnchorPoint(1, 1)
	customItem:addChild(littleIcon)

	headBg:setPosition(cc.p(newSize.width, newSize.height))
	messageLabel:setPosition(cc.p(newSize.width-headBgSize.width-10, newSize.height-headBgSize.height*0.3))
	littleIcon:setPosition(cc.p(newSize.width-headBgSize.width, newSize.height-headBgSize.height*0.3-5))

    customItem:setContentSize(newSize)

    return customItem
end

function ChatLayer:createReceiveItemOfListView(informations)
	local currentListView = nil
	local customItem = ccui.Layout:create()
	local itemSize = nil
	local newSize = nil

	-- 世界聊天
	currentListView = self.controls.worldListView
	itemSize = cc.size(self.data.worldListViewSize.width, 0)
	-- 获取info
    local info = {}
	for data in string.gmatch(informations.Info, "%w+") do
	 	table.insert(info, data)
	end
	local id = info[1]
	local level = info[2]
	local vip = tonumber(info[3])
	local icon = info[4] 

	local headBg = ccui.MixButton:create("image/ui/img/bg/newhead.png")
	headBg:setScale(0.7)
	headBg:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.8),cc.ScaleTo:create(0.05, 0.7)))
			self:createOthersPanel(id, informations.From, icon, vip, level)
		end 
	end)		
	headBg:setAnchorPoint(0, 1)
	customItem:addChild(headBg)
	local headBgSize = headBg:getBoundingBox()

	local head = ccui.ImageView:create(Common.heroIconImgPath(icon))
	head:setPosition(cc.p(headBg:getContentSize().width/2 + 3, headBg:getContentSize().height/2 + 3))
	headBg:addChild(head)

    local messageLabel = self:createBubbleFont(informations.Body, false)
    messageLabel:setAnchorPoint(0, 1)
	customItem:addChild(messageLabel)
	local messageLabelSize = messageLabel:getContentSize()

	if headBgSize.height*0.7 >= messageLabelSize.height then
		newSize = cc.size(itemSize.width, headBgSize.height)
	else
		newSize = cc.size(itemSize.width, headBgSize.height*0.3+messageLabelSize.height)
	end

	local littleIcon = cc.Sprite:create("image/ui/img/btn/btn_1427.png")
	littleIcon:setAnchorPoint(0, 1)
	customItem:addChild(littleIcon)

	headBg:setPosition(cc.p(0, newSize.height))
	messageLabel:setPosition(cc.p(headBgSize.width+15, newSize.height-headBgSize.height*0.3))
	littleIcon:setPosition(cc.p(headBgSize.width+5, newSize.height-headBgSize.height*0.3-5))

	local name = Common.finalFont(informations.From.."(".."Lv."..level..")", 
						headBgSize.width+15, newSize.height, 16, cc.c3b(0, 240, 250))
	name:setAnchorPoint(0, 1)
	customItem:addChild(name)	

 	if vip > 0 then
		local vipBg = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
		vipBg:setAnchorPoint(0, 1)
		vipBg:setPosition(cc.p(newSize.width*0.6, newSize.height))
		customItem:addChild(vipBg)
	    local vipLabel = Common.finalFont(vip, 55, 11, 22, cc.c3b(255, 180, 0))
		vipBg:addChild(vipLabel)
 	end

	customItem:setContentSize(newSize)

	return customItem,currentListView
end

function ChatLayer:createSystemReceiveItem(informations, str)
	local informations = {To = "all", From = "system", Body = "我爱你们，感谢大家的支持让游戏屡创传奇。明天送出大礼! 我爱你们，感谢大家的支持让游戏屡创传奇。明天送出大礼!", 
				Info = "", Time = 1456890593}
	-- 如果是系统消息
	local customItem = ccui.Layout:create() 

	local width = nil
	if str == WORLDVIEW then
		width = self.data.worldListViewSize.width
	elseif str == SYSTEMVIEW then
		width = self.data.systemListViewSize.width
	end

	local name = Common.finalFont("【系统公告】", 10, 80, 20, cc.c3b(255, 0, 0))
	name:setAnchorPoint(0, 1)
	customItem:addChild(name)
	local nameSize = name:getContentSize()

    local messageLabel = self:createSystemFont(informations.Body)
    messageLabel:setAnchorPoint(0, 1)
	customItem:addChild(messageLabel)
	local messageLabelSize = messageLabel:getContentSize()

	local newSize = cc.size(width, nameSize.height+messageLabelSize.height+5)
	name:setPosition(cc.p(0, newSize.height))
	messageLabel:setPosition(cc.p(7, newSize.height-nameSize.height-5))

	customItem:setContentSize(newSize)

	return customItem
end

function ChatLayer:sendMessage(rid)
	local currentTime = self:getCurrentTime()
	local receiveIdOfMessage = rid
	local sendNameOfMessage = GameCache.Avatar.Name
	local message = ""
	local info = GameCache.Avatar.RID..","..GameCache.Avatar.Level..","..GameCache.Avatar.VIP..","..GameCache.Avatar.Icon
	local param = {}
	local chatRecord = {}

	if self.data.currentLayer == WORLDVIEW then
		message = self.data.worldMessageOfSend
		param = {To = rid, From = sendNameOfMessage, Body = message, Info = info}
		rpc:call("Chat.Send", param)
		-- 创建listViewItem
		chatRecord = {To = rid, From = sendNameOfMessage, Body = message, Info = info, Time = currentTime}
		-- 检测list的Item是否大于等于2*MAXMESSAGECOUNT, 最开始的两项
		if #self.controls.worldListView:getItems() >= 2*MAXMESSAGECOUNT then
			self.controls.worldListView:removeItem(2)
			-- 移除时间Item
			self.controls.worldListView:removeItem(1)
		end
		-- 时间Item
		local timeItem = self:createTimeListItem(currentTime, self.data.worldListViewSize.width, false)
		self.controls.worldListView:pushBackCustomItem(timeItem)
		-- 内容Item
		local item = self:createSendItemOfListView(chatRecord, WORLDVIEW)
		self.controls.worldListView:pushBackCustomItem(item)
		self.controls.worldListView:refreshView()
		self.controls.worldListView:scrollToBottom(0.1, true)
	elseif self.data.currentLayer == PRIVATEVIEW then
		message = self.data.privateMessageOfSend
		param = {To = rid, From = sendNameOfMessage, Body = message, Info = info}
		rpc:call("Chat.Send", param)
		-- 检测list的Item是否大于等于2*MAXMESSAGECOUNT, 最开始的两项
		if #self.controls.privateListView:getItems() >= 2*MAXMESSAGECOUNT then
			self.controls.privateListView:removeItem(2)
			-- 移除时间Item
			self.controls.privateListView:removeItem(1)
		end
		-- 创建listViewItem
		chatRecord = {To = rid, From = sendNameOfMessage, Body = message, Info = info, Time = currentTime}
		-- 时间Item
		local timeItem = self:createTimeListItem(currentTime, self.data.privateListViewSize.width, false)
		self.controls.privateListView:pushBackCustomItem(timeItem)
		-- 内容Item
		local item = self:createSendItemOfListView(chatRecord, PRIVATEVIEW)
		self.controls.privateListView:pushBackCustomItem(item)
		self.controls.privateListView:refreshView()
		self.controls.privateListView:scrollToBottom(0.1, true)
	 	-- 遍历self.data.peopleOfChat, 插入聊天记录
	 	for _,person in pairs(self.data.peopleOfChat) do
	 		if person.Id == receiveIdOfMessage then
	 			if #person.Message >= MAXMESSAGECOUNT then
	 				table.remove(person.Message, MAXMESSAGECOUNT)
	 			end
	 			table.insert(person.Message, 1, chatRecord)
	 		end
	 	end
	end 
end

function ChatLayer:addEvenetListener()
	local listener = application:addEventListener(AppEvent.UI.Heartbeat.Chat, function(event)
		local result = event.data
		for _,obj in pairs(result) do
			local message = json.decode(obj)
			if message.From ~= GameCache.Avatar.Name then
				if message.To == "all" then
					if message.From == "system" then
						-- 世界聊天(系统消息)
						if #self.controls.worldListView:getItems() >= 2*MAXMESSAGECOUNT then
							self.controls.worldListView:removeItem(2)
							-- 移除时间Item
							self.controls.worldListView:removeItem(1)
						end
						local timeWorldItem = self:createTimeListItem(message.Time, self.data.worldListViewSize.width, true)
						self.controls.worldListView:pushBackCustomItem(timeWorldItem)
						local itemOfWorld = self:createSystemReceiveItem(message, WORLDVIEW)
						self.controls.worldListView:pushBackCustomItem(itemOfWorld)
						self.controls.worldListView:refreshView()
						self.controls.worldListView:scrollToBottom(0.1, true)

						-- 系统消息
						if #self.controls.systemListView:getItems() >= 2*MAXMESSAGECOUNT then
							self.controls.systemListView:removeItem(2)
							-- 移除时间Item
							self.controls.systemListView:removeItem(1)
						end
						local timeSystemItem = self:createTimeListItem(message.Time, self.data.systemListViewSize.width, true)
						self.controls.systemListView:pushBackCustomItem(timeSystemItem)
						local itemOfSystem = self:createSystemReceiveItem(message, SYSTEMVIEW)
						self.controls.systemListView:pushBackCustomItem(itemOfSystem)
						self.controls.systemListView:refreshView()
						self.controls.systemListView:scrollToBottom(0.1, true)
					else
						-- 世界聊天
						if #self.controls.worldListView:getItems() >= 2*MAXMESSAGECOUNT then
							self.controls.worldListView:removeItem(2)
							-- 移除时间Item
							self.controls.worldListView:removeItem(1)
						end
						-- 时间item
						local timeItem = self:createTimeListItem(message.Time, self.data.worldListViewSize.width, true)
						self.controls.worldListView:pushBackCustomItem(timeItem)					
						local item,listView = self:createReceiveItemOfListView(message)
						listView:pushBackCustomItem(item)
						listView:refreshView()
						listView:scrollToBottom(0.1, true)
					end
				else
					-- 私聊
					self:receivePrivateMessage(message)
				end
			end
		end
	end)
end

function ChatLayer:messageIsShow(message)
	for _,person in pairs(self.data.peopleOfChat) do
        local sendInfo = {}
        for data in string.gmatch(message.Info, "%w+") do
            table.insert(sendInfo, data)
        end
        local id = sendInfo[1]
		if person.Id == id then
			return person.isShow
		end
	end
end

function ChatLayer:receivePrivateMessage(message)
	self:insertToPeopleOfChat2(message)
	-- 刷新聊天对象表
	self:updatePeopleOfChat()
	if self:messageIsShow(message) then
		if #self.controls.privateListView:getItems() >= 2*MAXMESSAGECOUNT then
			self.controls.privateListView:removeItem(2)
			-- 移除时间Item
			self.controls.privateListView:removeItem(1)
		end
		-- 时间Item
		local timeItem = self:createTimeListItem(message.Time, self.data.privateListViewSize.width, true)
		self.controls.privateListView:pushBackCustomItem(timeItem)
		-- 直接插入数据Item到privateListView
		local item = self:createPrivateViewReceiveItem(message)
		self.controls.privateListView:pushBackCustomItem(item)
		self.controls.privateListView:refreshView()
		self.controls.privateListView:scrollToBottom(0.1, true)
	end
end

function ChatLayer:createPrivateViewReceiveItem(informations)
	local customItem = ccui.Layout:create()
	local itemSize = cc.size(self.data.privateListViewSize.width, 0)
	local newSize = nil
	-- 获取info
    local info = {}
	for data in string.gmatch(informations.Info, "%w+") do
	 	table.insert(info, data)
	end
	local id = info[1]
	local level = info[2]
	local vip = info[3]
	local icon = info[4]
	-- 创建Item
	local headBg = ccui.MixButton:create("image/ui/img/bg/newhead.png")
	headBg:setScale(0.7)
	headBg:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.8),cc.ScaleTo:create(0.05, 0.7)))
			self:createOthersPanel(id, informations.From, icon, vip, level)
		end 
	end)		
	headBg:setAnchorPoint(0, 1)
	customItem:addChild(headBg)
	local headBgSize = headBg:getBoundingBox()

	local head = ccui.ImageView:create(Common.heroIconImgPath(icon))
	head:setPosition(cc.p(headBg:getContentSize().width/2 + 3, headBg:getContentSize().height/2 + 3))
	headBg:addChild(head)

    local messageLabel = self:createBubbleFont(informations.Body, false)
    messageLabel:setAnchorPoint(0, 1)
	customItem:addChild(messageLabel)
	local messageLabelSize = messageLabel:getContentSize()

	if headBgSize.height*0.7 >= messageLabelSize.height then
		newSize = cc.size(itemSize.width, headBgSize.height)
	else
		newSize = cc.size(itemSize.width, headBgSize.height*0.3+messageLabelSize.height)
	end

	local littleIcon = cc.Sprite:create("image/ui/img/btn/btn_1427.png")
	littleIcon:setAnchorPoint(0, 1)
	customItem:addChild(littleIcon)

	headBg:setPosition(cc.p(0, newSize.height))
	messageLabel:setPosition(cc.p(headBgSize.width+15, newSize.height-headBgSize.height*0.3))
	littleIcon:setPosition(cc.p(headBgSize.width+5, newSize.height-headBgSize.height*0.3-5))

	local name = Common.finalFont(informations.From.."(".."Lv."..level..")", 
						headBgSize.width+15, newSize.height, 16, cc.c3b(0, 240, 250))
	name:setAnchorPoint(0, 1)
	customItem:addChild(name)	

 	if tonumber(vip) > 0 then
		local vipBg = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
		vipBg:setAnchorPoint(0, 1)
		vipBg:setPosition(cc.p(newSize.width*0.6, newSize.height))
		customItem:addChild(vipBg)
	    local vipLabel = Common.finalFont(vip, 55, 11, 22, cc.c3b(255, 180, 0))
		vipBg:addChild(vipLabel)
 	end

	customItem:setContentSize(newSize)

	return customItem
end

function ChatLayer:udatePrivateListView(message)
	self.controls.privateListView:removeAllItems()
	for i=#message.Message, 1, -1 do
		if message.Message[i].From == GameCache.Avatar.Name then
			-- 发送方为自己
			local sendItem = self:createSendItemOfListView(message.Message[i], PRIVATEVIEW)
			if sendItem then
				local timeItem = self:createTimeListItem(message.Message[i].Time, self.data.privateListViewSize.width, false)
				self.controls.privateListView:pushBackCustomItem(timeItem)
				self.controls.privateListView:pushBackCustomItem(sendItem)
			end
		else
			local receiveItem = self:createPrivateViewReceiveItem(message.Message[i])
			if receiveItem then
				local timeItem = self:createTimeListItem(message.Message[i].Time, self.data.privateListViewSize.width, true)
				self.controls.privateListView:pushBackCustomItem(timeItem)
				self.controls.privateListView:pushBackCustomItem(receiveItem)
			end
		end	
	end
	self.controls.privateListView:refreshView()
	self.controls.privateListView:scrollToBottom(0.1, true)
end

function ChatLayer:getCurrentTime()
	local tm = os.date("*t")
	local time = tm.hour..":"..tm.min..":"..tm.sec
	return time
end

function ChatLayer:createBubbleFont(s, isSend)
	local row,str = Common.StringLinefeed(s, 22)
	local label = Common.systemFont(str, 1, 1, 20)
	local labelSize = label:getContentSize()
	label:setColor(cc.c3b(0, 0, 0))
	label:setAnchorPoint(0.5, 0.5)
	label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setLineBreakWithoutSpace(false)

    local bubbleBg = nil
    if isSend then
		bubbleBg = ccui.ImageView:create("image/ui/img/btn/btn_1423.png")
	else
		bubbleBg = ccui.ImageView:create("image/ui/img/btn/btn_1422.png")
	end
   	bubbleBg:setScale9Enabled(true)
 	bubbleBg:setAnchorPoint(0, 1)

	if row == 1 then
		if utf8.len(str) > 1 then
			bubbleBg:setContentSize(labelSize.width + 25, labelSize.height + 15)
		end
	else
		bubbleBg:setContentSize(labelSize.width + 25, labelSize.height + 15)
	end

	local bubbleBgSize = bubbleBg:getContentSize()
	label:setPosition(cc.p(bubbleBgSize.width/2, bubbleBgSize.height/2))
    bubbleBg:addChild(label)

	return bubbleBg
end

function ChatLayer:createSystemFont(s)
	local row,str = Common.StringLinefeed(s, 33)
	local label = Common.systemFont(str, 1, 1, 20)
	label:setColor(cc.c3b(255, 255, 0))
	label:setAnchorPoint(0, 1)
	label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setLineBreakWithoutSpace(false)
	return label
end

-- 私聊对象
function ChatLayer:createPeopleWithChat(size)
	local function tableCellTouched(table, cell)
		local idx = cell:getIdx()
		if #self.data.peopleOfChat == idx + 1 then
			local friendList = GameCache.getFriendsList()
			self:updateFriendList(friendList)
			self:createFriendLayer()
			return
		end
		if cell:getChildByName("personBtn"):getChildByName("selected"):isVisible() then
			return 
		end
		for i, person in pairs(self.data.peopleOfChat) do
			if (idx+1) == i then
				person.isShow = true
				person.isNotice = false
				self.data.sendPrivateId = person.Id
				self:udatePrivateListView(person)
			else
				person.isShow = false
			end
		end
		self:updatePeopleOfChat()
	end

	local function cellSizeForTable(table, index)
		return 100, size.width
	end

	local function numberOfCellsInTableView(table)
		return #self.data.peopleOfChat
	end

	local function creteTableIcon(info)
		local iconPath = info.Icon
		local chatBtn = nil
		if iconPath ~= "" then			
			addChatBtn = self:vipSprite(info.Vip)
			addChatBtn:setScale(0.85)
			addChatBtn:setAnchorPoint(0.5, 0)
			local head = ccui.ImageView:create(Common.heroIconImgPath(iconPath))
			head:setPosition(addChatBtn:getContentSize().width/2+2, addChatBtn:getContentSize().height/2+2)
			addChatBtn:addChild(head)
			local selected = cc.Sprite:create("image/icon/border/border_selected.png")
			selected:setPosition(addChatBtn:getContentSize().width/2+2, addChatBtn:getContentSize().height/2+4)
			addChatBtn:addChild(selected)
			selected:setName("selected")
			selected:setVisible(false)
			local notice = cc.Sprite:create("image/ui/img/btn/btn_398.png")
			notice:setPosition(addChatBtn:getContentSize().width-15, addChatBtn:getContentSize().height-10)
			notice:setScale(0.9)
			addChatBtn:addChild(notice)
			notice:setName("notice")
			notice:setVisible(false)
			local delete = ccui.MixButton:create("image/ui/img/btn/btn_157.png")
			delete:setPosition(addChatBtn:getContentSize().width-10, addChatBtn:getContentSize().height-5)
			delete:setScale(1.1)
			addChatBtn:addChild(delete)
			delete:setName("delete")
			delete:setVisible(false)
			-- 删除聊天对象
			delete:addTouchEventListener(function(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					for i = 1,#self.data.peopleOfChat do
						if self.data.peopleOfChat[i].Id == info.Id then
							table.remove(self.data.peopleOfChat, i)
							self:updatePeopleOfChat()
							self.controls.privateListView:removeAllItems()
							break
						end
					end
				end
			end)
			if info.isShow then
				selected:setVisible(true)
				delete:setVisible(true)
			else
				if info.isNotice then
					notice:setVisible(true)
				end
			end
		else
			addChatBtn = ccui.ImageView:create("image/ui/img/bg/newhead.png")
			addChatBtn:setScale(0.85)
			addChatBtn:setAnchorPoint(0.5, 0)
			local s = addChatBtn:getContentSize()
			local addChatBg = cc.Sprite:create("image/ui/img/btn/btn_1285.png")
			addChatBg:setPosition(s.width/2 + 2, s.height/2 + 2)
			addChatBtn:addChild(addChatBg)
		end
		return addChatBtn
	end

	local function tableCellAtIndex(table, index)
		local cell = table:dequeueCell()
		if nil==cell then
			cell = cc.TableViewCell:new()
		else
			cell:removeAllChildren()
		end
		for i,person in pairs(self.data.peopleOfChat) do
			if i == index + 1 then
			    local headBorder = ccui.ImageView:create("image/icon/border/head_bg.png")
			    headBorder:setScale(0.85)
				cell:addChild(headBorder)
				local chatPersonbtn = creteTableIcon(person)
				chatPersonbtn:setPosition(cc.p(size.width/2, 0))
				local s = chatPersonbtn:getContentSize()
				chatPersonbtn:setName("personBtn")
				cell:addChild(chatPersonbtn)
				headBorder:setPosition(s.width/2, s.height/2-5)
			end
 		end
 		return cell	
	end

	local tableView = cc.TableView:create(cc.size(size.width, size.height-40))
	tableView:setPosition(cc.p(0, 20))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setDelegate()
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)  
	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    return tableView
end

function ChatLayer:updateFriendList(t)
	self.data.friendList = {}
	for _,obj in pairs(t) do
		local icon = obj.Icon
		local level = obj.Level
		local id = obj.RID
		local vip = obj.VIP
		local name = obj.Name
		table.insert(self.data.friendList, {["Icon"]=icon, ["Level"]=level,
			["Id"]=id, ["VIP"]=vip, ["Name"]=name})
	end
end

-- 创建好友层
function ChatLayer:createFriendLayer()
	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 180))
	self:addChild(layer)

	local bgSize = cc.size(display.width * 0.6, display.height * 0.7)
	local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
	bg:setScale9Enabled(true)
	bg:setContentSize(bgSize)
	bg:setAnchorPoint(0, 0)
	bg:setPosition(cc.p(display.width * 0.2, display.height * 0.15))
	layer:addChild(bg)

	if #self.data.friendList == 0 then
		local noFriendsAlert = cc.Node:create()
	    noFriendsAlert:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
	    bg:addChild(noFriendsAlert)
	    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
	    spri:setPosition(-140, 0)
	   	noFriendsAlert:addChild(spri)
	    local desc = Common.finalFont("你还没有好友,请先添加好友", 1, 1, 22, cc.c3b(61, 131, 172))
	    desc:setPosition(40, 0)
	    noFriendsAlert:addChild(desc)
	end

	local function tableCellTouched(table, cell)
		print(cell:getIdx())
	end

	local function cellSizeForTable(table, index)
		return 250, bgSize.width
	end

	local function numberOfCellsInTableView(table)
		return math.ceil(#self.data.friendList/3)
	end

	local function tableCellAtIndex(table, index)
		-- 创建cell
		local function createItem(cell, index)
			local function chooseChatPerson(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					local id = sender:getName()
					if id ~= nil then
					 	self:insertToPeopleOfChat(id)
					 	-- 更新聊天对象
					 	self.data.sendPrivateId = id
				 		-- 刷新聊天玩家表
						self:updatePeopleOfChat()
						-- 刷新聊天信息
						for _,person in pairs(self.data.peopleOfChat) do
							if person.Id == id then
								self:udatePrivateListView(person)
							end
						end
				 		-- 移除好友层
				 		layer:removeFromParent()
				 	end
			 	end
			end

			local posX = 50
			for i = 3 * index + 1, 3 * (index + 1) do
				if i > #self.data.friendList then
					break
				end 
				local vip = self.data.friendList[i].VIP
				local headBg = self:vipSprite(vip)
				local headBgSize = headBg:getContentSize()
				headBg:setAnchorPoint(0, 0.5)
				headBg:setPosition(posX, 150)
				cell:addChild(headBg)
				local head = ccui.ImageView:create(Common.heroIconImgPath(self.data.friendList[i].Icon))
				head:setPosition(cc.p(headBg:getContentSize().width/2, headBg:getContentSize().height/2))
				headBg:addChild(head)

				local nameLabel = Common.finalFont(self.data.friendList[i].Name, posX + headBgSize.width/2 , 85, 22, cc.c3b(0, 240, 250))
				cell:addChild(nameLabel)

				local levelLabel = Common.finalFont("LV."..tostring(self.data.friendList[i].Level), posX + headBgSize.width/2, 115, 16, cc.c3b(255, 255, 255), 1)
				cell:addChild(levelLabel)

				local chatBtn = ccui.MixButton:create("image/ui/img/btn/btn_610.png")
				chatBtn:setAnchorPoint(0.5, 1)
			    chatBtn:setTitleText("私聊")
   	 			chatBtn:setTitleFontSize(25)
				chatBtn:setPosition(cc.p(posX + headBgSize.width/2, 50))
				chatBtn:setName(self.data.friendList[i].Id)
				cell:addChild(chatBtn)
				chatBtn:addTouchEventListener(chooseChatPerson)
		
				posX = posX + 160
			end
 		end

		local cell = table:dequeueCell()
		if nil==cell then
			cell = cc.TableViewCell:new()
		else
			cell:removeAllChildren()
		end

		createItem(cell, index)

 		return cell	
	end

	local tableView = cc.TableView:create(cc.size(bgSize.width * 0.9,	bgSize.height * 0.9))
	tableView:setPosition(cc.p(30,20))
    bg:addChild(tableView)

	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setDelegate()
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)  
	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    local function onTouchBegan(touch, event)
	 	local target = event:getCurrentTarget()
    	local locationInNode = target:convertToNodeSpace(touch:getLocation())
    	local s = bgSize
    	local rect = cc.rect(display.width*0.2, display.height*0.15, bgSize.width, bgSize.height)
    	if not cc.rectContainsPoint(rect, locationInNode) then
    		layer:removeFromParent()
    	end
		return true
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function ChatLayer:vipSprite(v)
	local headBgPath = nil 
	local vip = tonumber(v)
	if vip>=0 and vip <5 then
		headBgPath = "image/ui/img/bg/newhead.png"
	elseif vip>=5 and vip<10 then
		headBgPath = "image/ui/img/bg/newhead2.png"
	elseif vip>=10 and vip<15 then
		headBgPath = "image/ui/img/bg/newhead3.png"
	elseif vip == 15 then
		headBgPath = "image/ui/img/bg/newhead4.png"
	end
	local headBg = ccui.ImageView:create(headBgPath)
	return headBg
end

function ChatLayer:insertToIconPath(rid, icon, vip, level)
	table.insert(self.data.iconPath, {["id"]=rid, ["icon"]=icon, ["vip"]=vip, ["level"]=level})
end

function ChatLayer:insertToPeopleOfChat(id)
	-- 遍历self.data.peopleOfChat, 插入聊天记录
 	local exist = false
	for _,person in pairs(self.data.peopleOfChat) do
		if person.Id == id then
			exist = true
			-- 显示状态置为true
			person.isShow = true
		else
			person.isShow = false
		end
	end
	if not exist then
		for _,friend in pairs(self.data.friendList) do
			if friend.Id == id then
				local iconPath = friend.Icon
				local vip = friend.VIP
				local level = friend.Lxevel
				table.insert(self.data.peopleOfChat, 1, {["Id"]=id, ["Icon"]=iconPath, ["Vip"]=vip, 
					["Level"]=level, ["Message"]={}, ["isShow"]=true, ["isNotice"]=false})
			end
		end
	end
end

function ChatLayer:insertToPeopleOfChat2(message)
    local sendInfo = {}
    for data in string.gmatch(message.Info, "%w+") do
        table.insert(sendInfo, data)
    end
    local id = sendInfo[1]
    local level = sendInfo[2]
    local vip = sendInfo[3]
    local icon = sendInfo[4]
	local exist = false
	for _,person in pairs(self.data.peopleOfChat) do
		if person.Id == id then
			exist = true
			-- 检查是否满MAXMESSAGECOUNT条
			if #person.Message >= MAXMESSAGECOUNT then
				table.remove(person.Message, MAXMESSAGECOUNT)
			end
			-- 插入数据
			table.insert(person.Message, 1, message)
			if person.isShow then
				person.isNotice = false	
			else
				person.isNotice = true	
			end
		end
	end
	-- 如果不存在聊天记录
	if not exist then
		local peronOfChat = {["Id"]=id, ["Icon"]=icon, ["Vip"]=vip, ["Level"]=level, ["Message"]={}, ["isShow"]=false, ["isNotice"]=true}
		table.insert(peronOfChat.Message, 1, message)
		table.insert(self.data.peopleOfChat, 1, peronOfChat)
	end
end

function ChatLayer:insertToPeopleOfChat3(id, icon, vip, level)
	-- 遍历self.data.peopleOfChat, 插入聊天记录
 	local exist = false
	for _,person in pairs(self.data.peopleOfChat) do
		if person.Id == id then
			exist = true
			-- 显示状态置为true
			person.isShow = true
		else
			person.isShow = false
		end
	end
	if not exist then
		table.insert(self.data.peopleOfChat, 1, {["Id"]=id, ["Icon"]=icon, ["Vip"]=vip, 
			["Level"]=level, ["Message"]={}, ["isShow"]=true, ["isNotice"]=false})
	end
end

function ChatLayer:updatePeopleOfChat()
	self.controls.tableViewOfChatPeople:reloadData()
end

function ChatLayer:createOthersPanel(rid, name, icon, vip, level)
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,150))
    self:addChild(layer)

    local bg = cc.Sprite:create("image/ui/img/btn/btn_1090.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)
    bg:setScale(0.1)
    bg:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))
    local bgsize = bg:getContentSize()

    local vipBg = self:vipSprite(vip)
 	vipBg:setPosition(bgsize.width*0.5, bgsize.height*0.5)
 	bg:addChild(vipBg)
    local icon1 = cc.Sprite:create(Common.heroIconImgPath(icon))
    icon1:setPosition(bgsize.width*0.5+2, bgsize.height*0.5)
    bg:addChild(icon1)

    local player_name = Common.systemFont(name,bgsize.width*0.5, bgsize.height*0.5-50, 22, nil, 1)
    bg:addChild(player_name)

    local btn_info = ccui.MixButton:create("image/ui/img/btn/btn_1094.png")
    btn_info:setPosition(bgsize.width*0.1, bgsize.height*0.9)
    bg:addChild(btn_info)
    btn_info:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Avatar.PlayerInfo", rid, function(event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    self:showOthersInfo(event.result, rid)
                end
            end)
        end
    end)
    btn_info:setScale(0.1)
    btn_info:setVisible(false)
    btn_info:runAction(cc.Sequence:create( cc.DelayTime:create(0.2), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local btn_hehe = ccui.MixButton:create("image/ui/img/btn/btn_1091.png")
    btn_hehe:setPosition(bgsize.width*0.9, bgsize.height*0.9)
    bg:addChild(btn_hehe)
    btn_hehe:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Friend.AddFriend", rid, function(event)
                if event.status == Exceptions.Nil then
                    application:showFlashNotice("交友申请已经发送给"..name.."，请等待对方回应")
                elseif event.status == Exceptions.EFriendRepeatSendRequest then
                    application:showFlashNotice("交友申请已经发送给"..name.."，请勿重复申请")
                elseif event.status == Exceptions.EFriendAlready then
                    application:showFlashNotice("你和"..name.."已经是好盆友了")

                end
            end)
        end
    end)
    btn_hehe:setScale(0.1)
    btn_hehe:setVisible(false)
    btn_hehe:runAction(cc.Sequence:create( cc.DelayTime:create(0.35), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local btn_chat = ccui.MixButton:create("image/ui/img/btn/btn_1093.png")
    btn_chat:setPosition(bgsize.width*0.9, bgsize.height*0.1)
    bg:addChild(btn_chat)
    btn_chat:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
        	layer:removeFromParent()
        	self:insertToPeopleOfChat3(rid, icon, vip, level)
    		self:updatePeopleOfChat()
			-- 刷新聊天信息
			for _,person in pairs(self.data.peopleOfChat) do
				if person.Id == rid then
					self:udatePrivateListView(person)
				end
			end
			self.controls.menuItem[2]:selected()
			self.controls.menuItem[1]:unselected()
			self.controls.menuItem[3]:unselected()
			self.controls.menuItem[2]:getChildByName(PRIVATEVIEW):setColor(cc.c3b(253, 230, 154))
			self.controls.menuItem[1]:getChildByName(WORLDVIEW):setColor(cc.c3b(174,174,170))
			self.controls.menuItem[3]:getChildByName(SYSTEMVIEW):setColor(cc.c3b(174,174,170))
			self.controls.layerMultiplex:switchTo(1)
			self.controls.privateListView:scrollToBottom(0.1, true)
        end
    end)
    btn_chat:setScale(0.1)
    btn_chat:setVisible(false)
    btn_chat:runAction(cc.Sequence:create( cc.DelayTime:create(0.5), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local btn_hero = ccui.MixButton:create("image/ui/img/btn/btn_1092.png")
    btn_hero:setPosition(bgsize.width*0.1, bgsize.height*0.1)
    bg:addChild(btn_hero)
    btn_hero:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Hero.GetFilterLevelHeroEx", {RID = rid, MinStarLevel = 5}, function ( event )
                if event.status == Exceptions.Nil and event.result ~= nil then
                    local herolayer = require("scene.main.hero.FriendAllHeroLayer").new(event.result)
                    scene:addChild(herolayer)
                elseif not event.result then
                    application:showFlashNotice("不好意思，您查看的玩家暂时没有4星及以上星将!")
                end
                
            end)
        end
    end)    
    btn_hero:setScale(0.1)
    btn_hero:setVisible(false)
    btn_hero:runAction(cc.Sequence:create( cc.DelayTime:create(0.65), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)   
end

function ChatLayer:showOthersInfo(info, rid)
    local layer = cc.LayerColor:create(cc.c4b(0,0,180,150))
    self:addChild(layer)

    local size = cc.size(615,409)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(size)
    bg:setScale(0.01)
    layer:addChild(bg)

    local action = cc.Sequence:create({cc.ScaleTo:create(0.1, 1.1),cc.ScaleTo:create(0.1, 1.0)})
    bg:runAction(action)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(size.width*0.5, size.height*0.5)
    bg:addChild(huawen)

    local top = cc.Sprite:create("image/ui/img/btn/btn_1002.png")
    top:setAnchorPoint(0.5,1)
    top:setPosition(size.width*0.5, size.height-15)
    bg:addChild(top)

    local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(595,75))
    bottom:setAnchorPoint(0.5,0)
    bottom:setPosition(size.width*0.5, 13)
    bg:addChild(bottom)

    local btn_hello = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_hello:setScale9Size(cc.size(120,56))
    btn_hello:setPosition(size.width*0.5, 50)
    btn_hello:setTitle("结识",24,cc.c3b(238,205,142))
    btn_hello:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Friend.AddFriend", rid, function(event)
                if event.status == Exceptions.Nil then
                    btn_hello:setStateEnabled(false)
                    application:showFlashNotice("交友申请已经发送给"..info.Name.."，请等待对方回应")
                elseif event.status == Exceptions.EFriendRepeatSendRequest then
                    application:showFlashNotice("交友申请已经发送给"..info.Name.."，请勿重复申请")
                elseif event.status == Exceptions.EFriendAlready then
                    application:showFlashNotice("你和"..info.Name.."已经是好盆友了")
                end
            end)
        end
    end)
    bg:addChild(btn_hello)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(size.width-15, size.height-15)
    bg:addChild(btn_close)
    btn_close:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)   


    local sp = cc.Sprite:create("image/icon/border/head_bg.png")
    sp:setPosition(75, size.height-85)
    bg:addChild(sp)

    local head = cc.Sprite:create(Common.heroIconImgPath(info.Icon))
    head:setPosition(75, size.height-85)
    bg:addChild(head)


    local head1 = cc.Sprite:create("image/icon/border/Head-portrait001.png")
    head1:setPosition(75, size.height-85)
    bg:addChild(head1)

    local headsize = head1:getContentSize()


    --vip level
    local sprite_vip = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
    sprite_vip:setPosition(headsize.width*0.5-20,0)
    head1:addChild(sprite_vip)

    local vip = Common.finalFont(""..info.VIP, 1, 1, 24, cc.c3b(255,201,60),1)
    vip:setPosition(headsize.width*0.5+20, 0)
    head1:addChild(vip)

    local str = info.Name
    local editbg = cc.Sprite:create("image/ui/img/btn/btn_1001.png")
    editbg:setPosition(size.width*0.38, size.height-50)
    bg:addChild(editbg)

    local editsize = editbg:getContentSize()
    local name = Common.systemFont(str, 1, 1, 24)
    name:setPosition(editsize.width*0.5, editsize.height*0.5-2)
    editbg:addChild(name)

    --level
    
    local label = Common.finalFont("等级：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(150, 300 )
    bg:addChild(label)
        
    local str = info.Level
    local label_level = Common.finalFont(str, 1, 1, 24, cc.c3b(21,255,21))
    label_level:setAnchorPoint(0,0.5)
    label_level:setPosition(230, 300)
    bg:addChild(label_level)

    --gender 1-男 2-女
    
    local label = Common.finalFont("性别：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(344, 300 )
    bg:addChild(label)
        
    local str = info.Gender
    local g = {"男", "女"}
    local label_gender = Common.finalFont(g[str], 1, 1, 22, cc.c3b(21,255,21))
    label_gender:setAnchorPoint(0,0.5)
    label_gender:setPosition(418, 300)
    bg:addChild(label_gender)

    --ID
    local label_Id = Common.finalFont("ID：", 1, 1, 24)
    label_Id:setAnchorPoint(cc.p(0,0.5))
    label_Id:setPosition(cc.p(344,240))
    bg:addChild(label_Id)

    local label_id = Common.finalFont("" .. rid, 1, 1, 24, cc.c3b(21,255,21))
    label_id:setAnchorPoint(cc.p(0,0.5))
    label_id:setPosition(cc.p(418,240))
    bg:addChild(label_id)

   local label = Common.finalFont("帮会：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,240 )
   bg:addChild(label)

   local label = Common.finalFont("竞技场：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,180 )
   bg:addChild(label)


    local str = "第"..info.ArenaRank.."名"
    if info.ArenaRank == 0 then
        str = "未上榜"
    end
    local label_rank = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_rank:setAnchorPoint(0,0.5)
    label_rank:setPosition(250,180)
    bg:addChild(label_rank)


    local label = Common.finalFont("服务器：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(150,120 )
    bg:addChild(label)

    local str = GameCache.ServerName
    local label_server = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_server:setAnchorPoint(0,0.5)
    label_server:setPosition(250,120)
    bg:addChild(label_server)
end

function ChatLayer:isIllegalWord(str)
    local num = string.find(str,'[^%w\128-\191\194-\239%p%s]+') 
    if num ~= nil then
        return false, "消息内容只应包含中英文,数字和标点"
    end

	local messageTable = {}
    local tempString = str
    local lowerString = string.lower(str)
    local upperString = string.upper(str)
    local length = utf8.len(str)
    for i=1,length do
        for j=i,length do
            messageTable[#messageTable+1] = utf8.sub(tempString,i,j)
        end
    end
    for i=1,length do
        for j=i,length do
            messageTable[#messageTable+1] = utf8.sub(lowerString,i,j)
        end
    end
    for i=1,length do
        for j=i,length do
            messageTable[#messageTable+1] = utf8.sub(upperString,i,j)
        end
    end

    for k,v in pairs(messageTable) do
        if BaseConfig.isIllegalWord(v) then
            return false, "消息包含敏感字符-"..v
        end
    end

    return true
end

function ChatLayer:onExit()
	if self.data.peopleOfChat then
		Common.writeFile(self.data.peopleOfChat, fileName)
	end
end


return ChatLayer