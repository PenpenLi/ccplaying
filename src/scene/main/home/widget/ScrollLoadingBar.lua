local ScrollLoadingBar = class("ScrollLoadingBar", function()
    local node = cc.Node:create()

    local function onNodeEvent(event)
        if event == "enter" then
            node:onEnter()
        elseif event == "exit" then
            node:onExit()
        elseif event == "cleanup" then
            node:onCleanup()
        elseif event == "enterTransitionFinish" then
            node:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            node:onExitTransitionStart()
        end
    end
    node:registerScriptHandler(onNodeEvent)
    return node
end)
local effects = require("tool.helper.Effects")

function ScrollLoadingBar:ctor()
    self.bg = cc.Sprite:create("image/ui/img/btn/btn_1114.png")
    self.bg:setAnchorPoint(0, 0)
    self:addChild(self.bg)
    self.bgSize = self.bg:getContentSize()

    self.clippingNode = cc.ClippingNode:create()
    self.clippingNode:setAlphaThreshold(0.5)
    self.clippingNode:setStencil(self.bg)
    self:addChild(self.clippingNode)

    self.scrollEffect = load_animation("image/spine/ui_effect/31/")
    self.scrollEffect:setAnimation(0, "animation", true)
    self.scrollEffect:setPosition(-self.bgSize.width * 0.5, self.bgSize.height * 0.5)
    self.clippingNode:addChild(self.scrollEffect)
end

function ScrollLoadingBar:setPercent(value)
    local value = (value / 100 >= 1) and 1 or (value / 100) 
    local posX = -self.bgSize.width * 0.5 + self.bgSize.width * value
    self.scrollEffect:setPositionX(posX)
    if value < 1 then
        self:setIsScroll(true)
    else
        self:setIsScroll(false)
    end
end

function ScrollLoadingBar:setIsScroll(value)
    local node = self:getChildByName("node")
    if node then
        node:stopAllActions()
        node:removeFromParent()
        node = nil
    end
    node = cc.Node:create()
    node:setName("node")
    self:addChild(node)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(1/60), cc.CallFunc:create(function()
        self.scrollEffect:setPaused(not value)
    end)))
end

function ScrollLoadingBar:getContentSize()
    return self.bgSize
end

return ScrollLoadingBar




