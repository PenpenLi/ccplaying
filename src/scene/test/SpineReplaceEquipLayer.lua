local LayerReplaceEquip = class("LayerReplaceEquip", BaseLayer)

function LayerReplaceEquip:ctor()
    LayerReplaceEquip.super.ctor(self)
    local layercolor = cc.LayerColor:create(cc.c4b(0,0,0,255))
    self:addChild(layercolor)

    local btn_replace = ccui.Button:create("dummy/images/common/btn_01.png", "dummy/images/common/btn_01.png", "dummy/images/common/btn_02.png")
    btn_replace:setPosition(250,50)
    btn_replace:setTitleText("换脑袋")
    btn_replace:setTitleFontSize(24)
    btn_replace:setName("head")
    btn_replace:setPressedActionEnabled(true)
    btn_replace:addTouchEventListener(handler(self, self.handleReplaceEquip))
    self:addChild(btn_replace)

    local btn_replace = ccui.Button:create("dummy/images/common/btn_01.png", "dummy/images/common/btn_01.png", "dummy/images/common/btn_02.png")
    btn_replace:setPosition(450,50)
    btn_replace:setTitleText("换装备")
    btn_replace:setTitleFontSize(24)
    btn_replace:setName("body")
    btn_replace:setPressedActionEnabled(true)
    btn_replace:addTouchEventListener(handler(self, self.handleReplaceEquip))
    self:addChild(btn_replace)

    local btn_replace = ccui.Button:create("dummy/images/common/btn_01.png", "dummy/images/common/btn_01.png", "dummy/images/common/btn_02.png")
    btn_replace:setPosition(650,50)
    btn_replace:setTitleText("换武器")
    btn_replace:setTitleFontSize(24)
    btn_replace:setName("equip")
    btn_replace:setPressedActionEnabled(true)
    btn_replace:addTouchEventListener(handler(self, self.handleReplaceEquip))
    self:addChild(btn_replace)

    which = false
    animation = sp.SkeletonAnimation:create("image/skin/1016/skeleton.json", "image/skin/1016/skeleton.atlas", 0.5)
    animation:addAnimation(0, "atk_ko", true)
    animation:setTimeScale(0.5)
    animation:setPosition(450, 150)
    animation:setOpacityModifyRGB(true)
    self:addChild(animation)

end

function LayerReplaceEquip:onEnter()
    local eventDispatcher = self:getEventDispatcher()

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMoved(touch, event)

    end

    local  function onTouchEnded(touch, event)
        if self._removeListenerOnTouchEnded then
            eventDispatcher:removeEventListener(self._listener)
        end

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    self._listener = listener
    listener:setSwallowTouches(true)

    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function LayerReplaceEquip:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)
end

function LayerReplaceEquip:handleReplaceEquip(sender, eventType)

    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if which then
            if name == "head" then
                animation:replaceAllAttachmentInAtlas("image/skin/1016/hat/skeleton.atlas")
                animation:replaceAllAttachmentInAtlas("image/skin/1016/hat/hat_1001/skeleton.atlas")
            elseif name == "body" then
                animation:replaceAllAttachmentInAtlas("image/skin/1016/coat/skeleton.atlas")
                animation:replaceAllAttachmentInAtlas("image/skin/1016/coat/coat_1001/skeleton.atlas")
            elseif name == "equip" then
                animation:replaceAllAttachmentInAtlas("image/skin/1016/arm/arm_1001/skeleton.atlas")
            end
        else
            if name == "head" then
                animation:replaceAllAttachmentInAtlas("image/skin/1016/hat/skeleton.atlas")
                animation:replaceAllAttachmentInAtlas("image/skin/1016/hat/hat_1002/skeleton.atlas")
            elseif name == "body" then
                animation:replaceAllAttachmentInAtlas("image/skin/1016/coat/skeleton.atlas")
                animation:replaceAllAttachmentInAtlas("image/skin/1016/coat/coat_1002/skeleton.atlas")
            elseif name == "equip" then
                animation:replaceAllAttachmentInAtlas("image/skin/1016/arm/arm_1002/skeleton.atlas")
            end
        end

        which = not which
    end
end



return LayerReplaceEquip