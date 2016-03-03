local SkillIcon = class("SkillIcon", function()
    local node = cc.Node:create()
    node.data = {}
    node.controls = {}
    return node
end)

function SkillIcon:ctor(bg_texture, child_texture)
    self.controls.bg = cc.Sprite:create(bg_texture)
    self:addChild(self.controls.bg)
    self.controls.bg:setScale(0.92)

    if child_texture then
        self.controls.child = cc.Sprite:create(child_texture)
        self:addChild(self.controls.child)
    end

    self.controls.posNode = cc.Node:create()
    self.controls.posNode:setPosition(-60, 0)
    self:addChild(self.controls.posNode)

    self.data.isOpen = false
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        self.scaleValue = self:getScale()
        self:setScale(self.scaleValue)
        if cc.rectContainsPoint(rect, locationInNode) then
            self.controls.tips = require("tool.helper.CommonTips").new(BaseConfig.GOODS_SKILL, self.data.skillInfo, self.controls.posNode)
            self.controls.tips:setName("hero_tip")
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(self.controls.tips)
            self.controls.tips:show(self.controls.posNode, self.data.skillInfo)

            self.data.isOpen = true
            self:setScale(self.scaleValue * 0.98)
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if (not cc.rectContainsPoint(rect, locationInNode)) and (self.data.isOpen) then
            self.controls.tips:hide()
            self.data.isOpen = false
            self:setScale(self.scaleValue)
        end
    end

    local function onTouchEnded(touch, event)
        local scene = cc.Director:getInstance():getRunningScene()
        local tips = scene:getChildByName("hero_tip")
        if self.data.isOpen and tips then
            self.controls.tips:hide()
        end
        self:setScale(self.scaleValue)
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.controls.bg)
end

function SkillIcon:setSkillInfo(skillInfo)
    self.data.skillInfo = skillInfo
end

function SkillIcon:setChildTexture(texture)
    if self.controls.child then
        self.controls.child:setTexture(texture)
    else
        self.controls.child = cc.Sprite:create(texture)
        self:addChild(self.controls.child)
    end
end

function SkillIcon:setPos(x, y)
    self.controls.posNode:setPosition(x, y)
end


return SkillIcon





