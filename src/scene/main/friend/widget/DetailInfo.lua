local DetailInfo = class("DetailInfo", function()
    return cc.Node:create()
end)

local Head_Texture_VIP = { "image/ui/img/bg/newhead.png", "image/ui/img/bg/newhead2.png", "image/ui/img/bg/newhead3.png" }

function DetailInfo:ctor(friendInfo)
    self.friendInfo = friendInfo
    self:createUI()
    self:setChooseBorder(false)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            self.beganX = touch:getLocation().x
            return true
        end
        return false
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            self.endX = touch:getLocation().x
            local delta = math.abs(self.endX - self.beganX)
            if delta < 20 then
                if self.func then
                    self.func(self)
                end
            end
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.bg)

end

function DetailInfo:createUI()
    local headbg1 = cc.Sprite:create("image/icon/border/head_bg.png")
    self:addChild(headbg1)

    local headPath =  string.format("image/icon/head/xj_%d.png", self.friendInfo.Icon)
    local headSpri = cc.Sprite:create(headPath)
    self:addChild(headSpri)

    self.bg = cc.Sprite:create("image/icon/border/border_star_00.png")
    self.bg:setPosition(-4, -4)
    self:addChild(self.bg)
    self.size = self.bg:getContentSize()

    if self.friendInfo.VIP < 15 then
        self.bg:setTexture(Head_Texture_VIP[math.floor(self.friendInfo.VIP/5)+1])
    else
        self.bg:setTexture("image/ui/img/bg/newhead4.png")
    end

    self.border = cc.Sprite:create("image/icon/border/border_selected.png")
    self:addChild(self.border)

    -- 暂时取消在线状态
    -- if self.friendInfo.IsOnline then
    --     local onLine = Common.finalFont("在线", 0 , self.size.height * 0.4, 18, cc.c3b(255, 198, 62), 1)
    --     self:addChild(onLine)
    -- end

    local level = Common.finalFont("Lv."..self.friendInfo.Level, 0 , 0, 20, nil, 1)
    level:setPosition(0, -self.size.height * 0.5)
    level:setAnchorPoint(0.5, 0)
    self:addChild(level)

    local name = Common.systemFont(self.friendInfo.Name, 0 , -self.size.height * 0.7, 25, cc.c3b(72, 106, 167))
    self:addChild(name)
end

function DetailInfo:setNamePos(x, y)
    self.name_lab:setPosition(x, y)
end

function DetailInfo:setChooseBorder(visible)
    self.border:setVisible(visible)
end

function DetailInfo:downButton(bg_texture, touBg_texture, child_texture)
    self.btn = createMixSprite(bg_texture, touBg_texture, child_texture)
    self.btn:setButtonBounce(false)
    self.btn:setPosition(0, -self.size.height * 1.3)
    self:addChild(self.btn)
end

function DetailInfo:getButton()
    return self.btn
end

function DetailInfo:getFriendInfo()
    return self.friendInfo
end

function DetailInfo:addTouchEventListener(event)
    self.func = event
end

return DetailInfo

