local EditAlertBox = class("EditAlertBox",function ()
    return cc.Node:create()
end)

function EditAlertBox:ctor(text, callback)
    self.text = text
    self.callback = callback

    self.layerColor = cc.LayerColor:create(cc.c4b(255, 255, 255, 180), display.width, display.height)
    self:addChild(self.layerColor)

    self.bg = cc.LayerColor:create(cc.c4b(255, 0, 0, 250), 300, 400)
    self.bg:setPosition(display.width / 2 - self.bg:getContentSize().width / 2, 
                        display.height / 2 - self.bg:getContentSize().height / 2)
    self:addChild(self.bg)

    self.label = Common.finalFont(self.text, self.bg:getContentSize().width / 2, 
                                    self.bg:getContentSize().height - 100, 40)
    self.bg:addChild(self.label)

    self.content = cc.EditBox:create(cc.size(250, 55), cc.Scale9Sprite:create("image/ui/img/btn/btn_011.png"))
    self.content:setPosition(display.width / 2 - self.content:getContentSize().width / 2, 
                        display.height / 2 - self.content:getContentSize().height / 2)
    self.content:setAnchorPoint(0 , 0)
    self.content:setFontSize(30)
    self.content:setMaxLength(50)
    self.content:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self:addChild(self.content)

    self.btn_yes = createMixSprite("image/ui/img/btn/btn_011.png")
    self.btn_yes:setAnchorPoint(0 , 0)
    self.btn_yes:setPosition(20 , 20)
    self.btn_yes:setFont("确认", 1, 1)
    self.bg:addChild(self.btn_yes)
    self.btn_yes:setName("yes")
    self.btn_yes:addTouchEventListener(handler(self, self.onButtonClicked))

    self.btn_no = createMixSprite("image/ui/img/btn/btn_011.png")
    self.btn_no:setAnchorPoint(1 , 0)
    self.btn_no:setPosition(self.bg:getContentSize().width - 20 , 20)
    self.btn_no:setFont("取消", 1, 1)
    self.bg:addChild(self.btn_no)
    self.btn_no:setName("no")
    self.btn_no:addTouchEventListener(handler(self, self.onButtonClicked))

    local function onTouchBegan(touch, event)
        return true
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.btn_yes)

end

function EditAlertBox:onButtonClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if "yes" == name then
            self.callback(self)
        end
        self:removeFromParent()
        self = nil
    end
end

function EditAlertBox:getEditText()
    return self.content:getText()
end

function createEditAlertBox(text, callback)
    local alert = EditAlertBox.new(text, callback)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene then
        scene:addChild(alert)
    end
    return alert
end



