local RockStick = class("RockStick", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    local function onNodeEvent(event)
        if event == "cleanup" then
            node:onCleanup()
        end
    end
    node:registerScriptHandler(onNodeEvent)
    return node
end)
local scheduler = cc.Director:getInstance():getScheduler()

local CENTER_POS = 0
local MOVE_DISTANCE = 60
local UP_HEIGHTDISTANCE = 0
local DOWN_HEIGHTDISTANCE = 0

function RockStick:ctor()
    self.data.isCanMoveBall = true
    self.data.isAutoBack = false

    self.controls.scheduler = scheduler:scheduleScriptFunc(handler(self, self.detectionBallLocation), 0, false)


    local bg = cc.Sprite:create("image/ui/img/btn/btn_1266.png")
    self:addChild(bg)
    local bgSize = bg:getContentSize()

    self.controls.stick = cc.Sprite:create("image/ui/img/btn/btn_1267.png")
    self.controls.stick:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    self.controls.stick:setAnchorPoint(0.5, 0)
    bg:addChild(self.controls.stick)

    CENTER_POS = bgSize.height * 0.5
    UP_HEIGHTDISTANCE = CENTER_POS + MOVE_DISTANCE
    DOWN_HEIGHTDISTANCE = CENTER_POS - MOVE_DISTANCE

    self.controls.ball = cc.Sprite:create("image/ui/img/btn/btn_1268.png")
    self.controls.ball:setPosition(bgSize.width * 0.5, UP_HEIGHTDISTANCE)
    bg:addChild(self.controls.ball)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if (cc.rectContainsPoint(rect, locationInNode)) and (self.data.isCanMoveBall) then
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local previousPos = touch:getPreviousLocation()
        local currPos = cc.p(self.controls.ball:getPositionX(), self.controls.ball:getPositionY())
        local deltaPos = touch:getDelta()
        local nowPos = cc.p(currPos.x, currPos.y + deltaPos.y)

        self:changeBallStatus(nowPos.y)
    end

    local function onTouchEnded(touch, event)
        self.data.isAutoBack = true

        local endY = self.controls.ball:getPositionY()
        if endY < CENTER_POS then
            if self.data.func then
                local distance = CENTER_POS - endY
                distance = (distance < 3) and 3 or distance
                local speed = 0.6 / distance
                self.data.func(self, speed)
            end
        end

        local move = cc.MoveTo:create(0.2, cc.p(bgSize.width * 0.5, UP_HEIGHTDISTANCE))
        self.controls.ball:runAction(cc.Sequence:create({move, cc.CallFunc:create(function()
            self.data.isAutoBack = false
        end)}))
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.ball)
end

function RockStick:onCleanup()
    scheduler:unscheduleScriptEntry(self.controls.scheduler)
end

-- 手动移动摇杆时小球状态
function RockStick:changeBallStatus(posY)
    posY = (posY > UP_HEIGHTDISTANCE) and UP_HEIGHTDISTANCE or posY
    posY = (posY < DOWN_HEIGHTDISTANCE) and DOWN_HEIGHTDISTANCE or posY
    self.controls.ball:setPositionY(posY)

    if posY > CENTER_POS then
        self.controls.stick:setRotation(0)
    else
        self.controls.stick:setRotation(180)
    end

    local scaleOff = 1 + (MOVE_DISTANCE - math.abs((posY - CENTER_POS))) / 600
    self.controls.ball:setScale(scaleOff)
end

-- 摇杆自动返回初始位置的过程改变小球状态
function RockStick:detectionBallLocation()
    if self.data.isAutoBack then
        local posY = self.controls.ball:getPositionY()
        self:changeBallStatus(posY)
    end
end

function RockStick:setBallTouchEnabled(value)
    self.data.isCanMoveBall = value
    if value then
        self.controls.ball:setColor(cc.c3b(255, 255, 255))
    else
        self.controls.ball:setColor(cc.c3b(100, 100, 100))
    end
end

function RockStick:addFinishEventListener(event)
    self.data.func = event
end

return RockStick


