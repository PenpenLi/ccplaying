local MixSprite = class("MixSprite", function()
    return cc.Node:create()
end)

function MixSprite:ctor(bg_texture, bg_touchTexture, child_texture, isSprite, size)
    self.b_t = bg_texture
    if bg_touchTexture then
        self.b_tt = bg_touchTexture
    else
        self.b_tt = bg_texture
    end
    self.c_t = child_texture
    self.c_x = child_x
    self.c_y = child_y
    self.setTouchEnabled = true
    self.isBounceTouchEnd = true
    if nil == self.c_t then
        self.isChild = false
    else
        self.isChild = true
    end
    if isSprite then
        self:Sprite()
    else
        self:Scale9Sprite(size)
    end
    self.scaleAction = nil
    
    self.listener = cc.EventListenerTouchOneByOne:create()
    self.listener:registerScriptHandler(handler(self, self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
    self.listener:registerScriptHandler(handler(self, self.onTouchMoved),cc.Handler.EVENT_TOUCH_MOVED )
    self.listener:registerScriptHandler(handler(self, self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED )
    self.listener:registerScriptHandler(handler(self, self.onTouchCancelled),cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener, self.bg)
end

function MixSprite:onTouchBegan(touch, event)
    local target = event:getCurrentTarget()
    local locationInNode = target:convertToNodeSpace(touch:getLocation())
    local s = target:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)

    if not self.setTouchEnabled then
        return false
    end
    if cc.rectContainsPoint(rect, locationInNode) then
        if not self.scaleValue then
            self.scaleValue = self:getScale()
        end
    
        if self.scaleAction then
            self:stopAction(self.scaleAction)
            self:setScale(self.scaleValue)
        end
        self.scaleAction = self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, self.scaleValue * 0.9)))
        if self.func then
            self.func(self, ccui.TouchEventType.began)
        end
        return true
    end
    return false
end

function MixSprite:onTouchMoved(touch, event)
    local target = event:getCurrentTarget()
    local locationInNode = target:convertToNodeSpace(touch:getLocation())
    local s = target:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)
    
    local isIn = nil
    if cc.rectContainsPoint(rect, locationInNode) then
        self:setScale(self.scaleValue * 0.9)
        isIn = true
    else
        self:setScale(self.scaleValue)
        isIn = false
    end
    if self.func then
        self.func(self, ccui.TouchEventType.moved, isIn)
    end
end

function MixSprite:onTouchEnded(touch, event)
    local target = event:getCurrentTarget()
    local locationInNode = target:convertToNodeSpace(touch:getLocation())
    local s = target:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)

    local isIn = nil
    if self.scaleAction then
        self:stopAction(self.scaleAction)
    end
    if cc.rectContainsPoint(rect, locationInNode) then
        Common.playSound("audio/effect/common_click_feedback.mp3")
        if self.isBounceTouchEnd then
            local scale1 = cc.ScaleTo:create(0.05, self.scaleValue * 1.2, self.scaleValue * 0.8)
            local scale2 = cc.ScaleTo:create(0.03, self.scaleValue * 0.9, self.scaleValue * 1.1)
            local scale3 = cc.ScaleTo:create(0.03, self.scaleValue * 1, self.scaleValue * 1)
            self.scaleAction = self:runAction(cc.Sequence:create(scale1, scale2, scale3))
        else
            self:setScale(self.scaleValue)
        end
        isIn = true
    else
        self:setScale(self.scaleValue)
        isIn = false
    end
    if self.func then
        self.func(self, ccui.TouchEventType.ended, isIn)
    end
end

function MixSprite:onTouchCancelled(touch, event)
    if self.func then
        self.func(self, ccui.TouchEventType.canceled)
    end
end

function MixSprite:Sprite()
    self.bg = cc.Sprite:create(self.b_t)
    self:addChild(self.bg)

    self.bgTouch = cc.Sprite:create(self.b_tt)
    self:addChild(self.bgTouch)

    if self.isChild then
        self.child = cc.Sprite:create(self.c_t)
        self:addChild(self.child)
    end
    self:setNormalStatus()
end

function MixSprite:Scale9Sprite(size)
    self.bg = cc.Scale9Sprite:create(self.b_t)
    self.bg:setContentSize(size)
    self:addChild(self.bg)

    self.bgTouch = cc.Scale9Sprite:create(self.b_tt)
    self.bgTouch:setContentSize(size)
    self:addChild(self.bgTouch)

    if self.isChild then
        self.child = cc.Sprite:create(self.c_t)
        self:addChild(self.child)
    end
    self:setNormalStatus()
end

function MixSprite:setTexture(texture)
    self.bg:setTexture(texture)
    self.bgTouch:setTexture(texture)
end

function MixSprite:setChildTexture(texture)
    if self.isChild then
        self.c_t = texture
        self.child:setTexture(self.c_t)
    end
end

function MixSprite:setFont(text , x , y, size, color, outline)
    self.label = Common.finalFont(text , x , y, size, color, outline)
    self.label:setPosition(x, y)
    if x == 1 and y == 1 then
        self.label:setPosition(0, 0)
    end
    self:addChild(self.label)
end

function MixSprite:setCircleFont(text , x , y, size, color, outline)
    self.label = Common.finalFont(text , x , y, size, color, outline)
    self.label:setPosition(x, y)
    if x == 1 and y == 1 then
        self.label:setPosition(0, 0)
    end
    self:addChild(self.label)
end

function MixSprite:setNormalStatus()
    self.bg:setVisible(true)
    self.bgTouch:setVisible(false)
end

function MixSprite:setTouchStatus()
    self.bg:setVisible(false)
    self.bgTouch:setVisible(true)
end

function MixSprite:setNorGLProgram(value)
    -- if value then
    --     program = cc.GLProgram:create("image/ui/img/gray.vsh", "image/ui/img/normal.fsh")
    -- else
    --     program = cc.GLProgram:create("image/ui/img/gray.vsh", "image/ui/img/gray.fsh")
    -- end
    -- program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
    -- program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    -- program:link()
    -- program:updateUniforms()
    -- self.bg:setGLProgram( program )
    -- self.bgTouch:setGLProgram( program )
    -- if self.isChild then
    --     self.child:setGLProgram( program )
    -- end

    local state = 1
    if value then
        state = 0
    end
    self.bg:setState(state)
    self.bgTouch:setState(state)
    if self.isChild then
        self.child:setState( state )
    end
end

function MixSprite:setColor(color)
    self.bg:setColor(color)
    if self.isChild then
        self.child:setColor(color)
    end
end

function MixSprite:setChildPos(scaleX, scaleY)
    local size = self.bg:getContentSize()
    if self.isChild then
        self.child:setPosition(size.width * (scaleX - 0.5), size.height * (scaleY - 0.5))
    end
end

function MixSprite:setFontPos(scaleX, scaleY)
    local size = self.bg:getContentSize()
    self.label:setPosition(size.width * (scaleX - 0.5), size.height * (scaleY - 0.5))
end

function MixSprite:setBgScale(value)
    self.bg:setScale(value)
    self.bgTouch:setScale(value)
end

function MixSprite:setBgTouchAnchorPoint(x, y)
    self.bgTouch:setAnchorPoint(x, y)
end

function MixSprite:setString(text)
    if self.label then
        self.label:setString(text)
    end
end

function MixSprite:setFontColor(color)
    if self.label then
        self.label:setColor(color)
    end
end

function MixSprite:setFontOutline(color, outline)
    if self.label then
        self.label:enableOutline(color, outline)
    end
end

function MixSprite:setFontRotation(rotation)
    if self.label then
        self.label:setRotation(rotation)
    end
end

function MixSprite:setName(name)
    self.name = name
end

function MixSprite:setChildTextureVisible(visible)
    if self.child then
        self.child:setVisible(visible)
    end
end

function MixSprite:setTouchEnable(value)
    self.setTouchEnabled = value
end

function MixSprite:setButtonBounce(value)
    self.isBounceTouchEnd = value
end

function MixSprite:setAnchorPoint(x, y)
    self.bg:setAnchorPoint(x, y)
end

function MixSprite:setSwallowTouches(value)
    self.listener:setSwallowTouches(value)
end

function MixSprite:addTouchEventListener(event)
    self.func = event
end

function MixSprite:getBg()
    return self.bg
end

function MixSprite:getChild()
    if self.child then
        return self.child
    end
end

function MixSprite:getFont()
    if self.label then
        return self.label
    end
end

function MixSprite:getContentSize()
    return self.bg:getContentSize()
end

function MixSprite:getName()
    return self.name
end

function createMixSprite(bg_texture, bg_touchTexture, child_texture)
    local button = MixSprite.new(bg_texture, bg_touchTexture, child_texture, true)
    return button
end

function createMixScale9Sprite(bg_texture, bg_touchTexture, child_texture, size)
    local button = MixSprite.new(bg_texture, bg_touchTexture, child_texture, false, size)
    return button
end





