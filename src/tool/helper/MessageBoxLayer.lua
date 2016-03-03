local BaseLayer = require("tool.helper.BaseLayer")
local MessageBoxLayer = class("MessageBoxLayer", BaseLayer)

function MessageBoxLayer:ctor(title, text, buttons, callback, data)
    MessageBoxLayer.super.ctor(self)
    
    buttons = buttons or {"确定"}
    callback = callback or function() end

    self.data.buttons = buttons
    self.data.callback = callback
    self.data.userdata = data

    local btncount = #buttons

    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(SCREEN_WIDTH*0.6,SCREEN_HEIGHT*0.5)
    self:addChild(bg)
    local size = bg:getContentSize()

    local function init_text( title, content )
        local t = title or ""
        local label_title = Common.finalFont(t, 1,1, 24)
        label_title:setPosition(size.width*0.5,size.height*0.88)
        label_title:setColor(cc.c3b(220, 70, 20))
        bg:addChild(label_title)
        t = content or ""
        local label_content = Common.finalFont(t, 1,1, 22)
        label_content:setPosition(size.width*0.5,size.height*0.6)
        bg:addChild(label_content)
    end

    if btncount == 1 then

        init_text(title, text)
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_553.png")
        btn:setTitle(self.data.buttons[1],26)
        btn:setName("button_1")
        btn:addTouchEventListener(handler(self, self.onButtonClicked))
        btn:setPosition(size.width*0.5, size.height*0.2)
        bg:addChild(btn)

    elseif btncount == 2 then

        init_text(title, text)
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_553.png")
        btn:setTitle(self.data.buttons[1],26)
        btn:setName("button_2")
        btn:addTouchEventListener(handler(self, self.onButtonClicked))
        btn:setPosition(size.width*0.25, size.height*0.2)
        bg:addChild(btn)

        btn = ccui.MixButton:create("image/ui/img/btn/btn_553.png")
        btn:setTitle(self.data.buttons[2],26)
        btn:setName("button_1")
        btn:addTouchEventListener(handler(self, self.onButtonClicked))
        btn:setPosition(size.width*0.75, size.height*0.2)
        bg:addChild(btn)

    elseif btncount == 3 then

    else
        error("1-2个按钮", 1)
    end

    local function onTouchBegan(touch, event)
            return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)


end

function MessageBoxLayer:onButtonClicked(sender, eventType, index)
    local data = self.data.userdata
    if eventType == ccui.TouchEventType.ended then
        local senderName = sender:getName()
        if senderName == "button_1" then
            self.data.callback(1, data, self.data.buttons[1])
        elseif senderName == "button_2" then
            self.data.callback(2, data, self.data.buttons[2])
        elseif senderName == "button_3" then
            self.data.callback(3, data, self.data.buttons[3])
        else
            error("出错的了", 1)
        end
        self:removeFromParent()
    end
end

function MessageBoxLayer.show(title, text, buttons, callback, data)
    local msgbox = MessageBoxLayer.new(title, text, buttons, callback, data)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene then
        scene:addChild(msgbox,1)
    end
    return msgbox
end

return MessageBoxLayer