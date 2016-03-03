--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-7-17
-- Time: 下午2:51
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------
-- 攻击范围拖放节点
local CLICK_MAX_TIME = 1.0

local ScopeDragNode = class("ScopeDragNode", function() return cc.DrawNode:create() end)

--[[
    cell: 英雄所在的单元格
    direction:英雄的朝向
    area: 英雄的技能作用范围
    scope: 英雄的技能作用范围的选择区域
--]]
function ScopeDragNode:ctor(heroCell, centerCell, direction, areaBitmap, scopeBitmap, battleModel, isTeammate)
    CCLog(vardump({heroCell = heroCell, centerCell = centerCell, direction = direction, area = areaBitmap:tostring(), scope = scopeBitmap:tostring()}, "ScopeDragNode:ctor"))
    self.heroCell = heroCell
    self.centerCell = centerCell
    self.direction = direction
    self.scope = scopeBitmap
    self.area = areaBitmap
    self.battleModel = battleModel

    self.dragStartPos = nil
    self.scheduleEntryID = nil
    self.useTime = nil
    self.touchCount = 0
    self.onDragDropCallback = nil
    self.onDragCancelCallback = nil
    self.userdata = nil
    self.areaCircle = nil

    if self.area:num_bits_set() == 1 then
        self:drawCircle(cc.c4f(250 / 255.0, 10 / 255.0, 10 / 255.0, 0.65))
    else
        self:drawArea(areaBitmap, isTeammate and "green" or "red")
    end

    self:setPosition(cc.p(BattleConfig.getCellPos(centerCell.x, centerCell.y)))

    self:registerTouchListener()
    self:registerNodeHandler()

    self.lastCell = centerCell
end

function ScopeDragNode:drawArea(areaBitmap, color)
    CCLog("draw area:", areaBitmap and areaBitmap:tostring() or tostring(areaBitmap))
    local cellImg = color == "red" and "image/spine/skill_effect/atk_red.png" or "image/spine/skill_effect/atk_green.png"

    for absY = 0, (BattleConfig.Y_CELL_COUNT * 2 - 1) - 1  do
        for absX = 0, (BattleConfig.X_CELL_COUNT * 2 - 1) - 1 do
            if areaBitmap:get(absX, absY) then
                local x = absX - (BattleConfig.X_CELL_COUNT - 1)
                local y = absY - (BattleConfig.Y_CELL_COUNT - 1)

                local rect = self:getCellRect(x, y)
                local sprite = cc.Sprite:create(cellImg)
                local size = sprite:getContentSize()
                sprite:setOpacity(200)
                sprite:setScaleX(rect.width / size.width)
                sprite:setScaleY(rect.height / size.height)
                sprite:ignoreAnchorPointForPosition(true)
                sprite:setPosition(rect)
                sprite:setContentSize(rect)
                self:addChild(sprite)
            end
        end
    end
end

function ScopeDragNode:updateHeroCell(cell, scope)
    self.scope = scope
end

function ScopeDragNode:drawCenterCell(color)
    local rect = self:getCellRect(0, 0)
    self:drawRect(rect, color)
end

function ScopeDragNode:pointInArea(point)
    local cell = BattleConfig.getCellOfPos(point.x, point.y)

    local absX = cell.x + (BattleConfig.X_CELL_COUNT - 1)
    local absY = cell.y + (BattleConfig.Y_CELL_COUNT - 1)

    CCLog(vardump({cell = cell, absCell = {absX, absY}, area = self.area:tostring()}, "ScopeDragNode:pointInArea(point)"))
    return self.area:get(absX, absY)
end

function ScopeDragNode:pointInScope(point)
    local cell = BattleConfig.getCellOfPos(point.x, point.y)
    if cell then
        local xrange = self.scope[cell.y]
        if xrange then
            if cell.x >= xrange.start and cell.x < xrange.start + xrange.len then
                return true
            end
        end
    end
    return false
end

function ScopeDragNode:posInScope(cell)
    CCLog(vardump({cell = cell, scope = self.scope:tostring()}, "ScopeDragNode:posInScope"))
    if cell then
        return self.scope:get(cell.x, cell.y)
    end
    return false
end

function ScopeDragNode:setCallback(onDragDrop, onDragCancel, onDrageChange, userdata)
    self.onDragDropCallback = onDragDrop
    self.onDragCancelCallback = onDragCancel
    self.onDragChange = onDrageChange
    self.userdata = userdata

    self:scopeChange(self.lastCell or self.centerCell)
end

function ScopeDragNode:registerNodeHandler()
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        elseif event == "cleanup" then
            self:onCleanup()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function ScopeDragNode:registerTouchListener()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCanelled), cc.Handler.EVENT_TOUCH_CANCELLED)

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function ScopeDragNode:onEnter()
end

function ScopeDragNode:onExit()
end

function ScopeDragNode:onCleanup()
    self:stopTimer()
end

function ScopeDragNode:onEnterTransitionFinish()

end

function ScopeDragNode:onExitTransitionStart()

end

-- 开始计时
function ScopeDragNode:startTimer()
    self:stopTimer()

    self.useTime = 0

    local scheduler = cc.Director:getInstance():getScheduler()
    local scheduleEntryID = scheduler:scheduleScriptFunc(handler(self, self.onUpdate), 1 / 60, false)
    self.scheduleEntryID = scheduleEntryID
end

-- 结束计时
function ScopeDragNode:stopTimer()
    if self.scheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end
end

-- 计时
function ScopeDragNode:onUpdate(delta)
    if self.useTime == nil then
        self.useTime = delta
    else
        self.useTime = self.useTime + delta
    end
end

function ScopeDragNode:drawRect(rect, color)
    local bl = cc.p(rect.x, rect.y)
    local tl = cc.p(rect.x, rect.y + rect.height)
    local tr = cc.p(rect.x + rect.width, rect.y + rect.height)
    local br = cc.p(rect.x + rect.width, rect.y)
    self:drawPolygon({bl, tl, tr, br}, 4, color, 0, color)
end

function ScopeDragNode:drawRects(rects, color)
    local cellImg = color == "red" and "image/spine/skill_effect/atk_red.png" or "image/spine/skill_effect/atk_green.png"
    for idx, rect in ipairs(rects) do
        local sprite = cc.Sprite:create(cellImg)
        local size = sprite:getContentSize()
        sprite:setOpacity(200)
        sprite:setScaleX(rect.width / size.width)
        sprite:setScaleY(rect.height / size.height)
        sprite:ignoreAnchorPointForPosition(true)
        sprite:setPosition(rect)
        sprite:setContentSize(rect)
        self:addChild(sprite)
        --self:drawRect(rect, color)
    end
end

function ScopeDragNode:drawCircle(color)
    if self.areaCircle == nil then
        local areaCircle = {}
        local CELL_WIDTH = BattleConfig.CELL_WIDTH
        local CELL_HEIGHT = BattleConfig.CELL_HEIGHT
        for i = 1, 360 do
            local r = math.rad(i)
            local x = math.cos(r) * CELL_WIDTH
            local y = math.sin(r) * CELL_HEIGHT
            table.insert(areaCircle, cc.p(x, y))
        end
        self.areaCircle = areaCircle
    end

    self:drawPolygon(self.areaCircle, #self.areaCircle, color, 0, color)
end

-- 获取一个单元格的矩形区域 (0, 0)的单元格，在中心位置，相当于向左向下都偏移了半格
function ScopeDragNode:getCellRect(x, y)
    local CELL_WIDTH = BattleConfig.CELL_WIDTH
    local CELL_HEIGHT = BattleConfig.CELL_HEIGHT

    local left = x * CELL_WIDTH - CELL_WIDTH * 0.5
    local bottom = y * CELL_HEIGHT - CELL_HEIGHT * 0.5
    local rect = cc.rect(left, bottom, CELL_WIDTH, CELL_HEIGHT)
    return rect
end

function ScopeDragNode:getCellColors(x, y)
    if y > 5 then
        y = 5
     elseif y < 0 then
        y = 0
    end

    local bl = cc.c4f(1, 0, 0, (y + 0) / 5)
    local tl = cc.c4f(1, 0, 0, (y + 1) / 5)
    local tr = cc.c4f(1, 0, 0, (y + 1) / 5)
    local br = cc.c4f(1, 0, 0, (y + 0) / 5)

    return {bl, tl, tr, br}
end

function ScopeDragNode:onTouchBegan(touch, event)
    CCLog("onTouchBegan")
    local location = touch:getLocation()
    local pos = self:convertToNodeSpace(location)

    if self:pointInArea(pos) then
        local x, y = self:getPosition()

        self.dragStartPos = cc.p(x, y)
        self.touchCount = self.touchCount + 1

        self:startTimer()
        return true
    else
        self:cancel()
        return false
    end
end

function ScopeDragNode:onTouchMoved(touch, event)
    CCLog("onTouchMoved")

    local cell = BattleConfig.getCellOfPos(self:getPosition())
    local curPos = touch:getLocation()
    local startPos = touch:getStartLocation()
    local pos = cc.pAdd(self.dragStartPos, cc.p(curPos.x - startPos.x, curPos.y - startPos.y))
    self:setPosition(pos)
    if self:posInScope(cell) then
        if self.lastCell then
            local lastCell = self.lastCell
            if lastCell.x ~= cell.x or lastCell.y ~= cell.y then
                self:scopeChange(cell)
                self.lastCell = cell
            end
        else
            self:scopeChange(cell)
            self.lastCell = cell
        end
    end
end

function ScopeDragNode:nearestScope(cell)
    local scope = self.scope

    CCLog(vardump({cell = cell, scope = scope}, "nearestScope"))
    local x, y
    local xrange = scope[cell.y]
    if xrange == nil then
        local nearY = nil
        local minDisY = nil
        for y, _ in pairs(scope) do
            local disY = math.abs(y - cell.y)
            if minDisY == nil or minDisY > disY then
                minDisY = disY
                nearY = y
            end
        end

        xrange = assert(scope[nearY])
        y = nearY
    else
        y = cell.y
    end

    x = cell.x
    
    return {x = x, y = y}
end

function ScopeDragNode:nearestCellOfPos(point)
    local x, y = point.x, point.y

    local cellX = math.ceil(x / BattleConfig.CELL_WIDTH)
    local cellY = math.ceil(y / BattleConfig.CELL_HEIGHT)

    return {x = cellX, y = cellY}
end

-- 自动调整为最近的cell位置
function ScopeDragNode:adjustPosition()
    local battleModel = self.battleModel
    local x, y = self:getPosition()
    local point = cc.p(x, y)
    CCLog(vardump({point = point}, "ScopeDragNode:adjustPosition()"))
    local nearCell = self:nearestCellOfPos(point)
    return nearCell
end

function ScopeDragNode:absoluteScope(relativeScope, cell)
    local absScope = {}
    for y, xrange in pairs(relativeScope) do
        absScope[cell.y + y] = {start = xrange.start + cell.x, len = xrange.len}
    end
    return absScope
end

function ScopeDragNode:validArea(scope, area, areaPos)
    local validArea = {}

    if type(scope) == "table" then
        area = self:absoluteScope(area, areaPos)
        for sy, srange in pairs(scope) do
            local arange = area[sy]
            if arange then
                local sstart = srange.start
                local send = sstart + srange.len - 1

                local astart = arange.start
                local aend = astart + arange.len

                local start = math.max(sstart, astart)
                local end_ = math.min(send, aend)
                if end_ >= start then
                   validArea[sy] = {start = start, len = end_ - start}
                end
            end
        end
    elseif type(scope) == "userdata" then
        local scopeBitmap = scope
        local areaBitmap = area

        areaBitmap:move(-(BattleConfig.X_CELL_COUNT - areaPos.x - 1), -(BattleConfig.Y_CELL_COUNT - areaPos.y - 1))
        areaBitmap:resize(BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT)

        validArea = scopeBitmap:band(areaBitmap)
    end

    CCLog("ScopeDragNode:validArea", vardump({validArea = validArea:tostring(), scope = scope:tostring(), area = area:tostring()}))
    return validArea
end

function ScopeDragNode:onTouchEnded(touch, event)
    CCLog("onTouchEnded")
    local startPos = touch:getStartLocation()
    local curPos = touch:getLocation()

    local cell = self:adjustPosition()

    CCLog(vardump({touch = self.touchCount, time = self.useTime}))
    local len = cc.pGetDistance(startPos, curPos)
    local CELL_SIZE = math.min(BattleConfig.CELL_WIDTH, BattleConfig.CELL_HEIGHT)
    CCLog("scope cell:", inspect({cell = cell, scope = self.scope, area = self.area, count = self.touchCount, useTime = self.useTime, len = len, size = CELL_SIZE}))

--    local area = self:absoluteScope(self.area, cell)
    local validArea = self:validArea(self.scope, self.area, cell)
    CCLog("valid area:", validArea:tostring())
    if validArea:num_bits_set() > 0 then
        if self.onDragDropCallback then
            self.onDragDropCallback({pos = touch:getLocation(), dragNode = self, data = self.userdata, cell = cell, area = validArea})
        end
    else
        self:cancel()
    end
end

function ScopeDragNode:done()
    if self.onDragDropCallback then
        self.onDragDropCallback({dragNode = self, data = self.userdata, cell = self.centerCell, area = self.area})
    end
end

function ScopeDragNode:cancel()
    if self.onDragCancelCallback then
        self.onDragCancelCallback({dragNode = self, data = self.userdata})
    end
end

function ScopeDragNode:onTouchCanelled(touch, event)
    self.touchCount = 0
    self:stopTimer()

    if self.onDragCancelCallback then
        self.onDragCancelCallback({dragNode = self, data = self.userdata})
    end
end

function ScopeDragNode:scopeChange(cell)
    if self.onDragChange then
        self.onDragChange(cell, self.userdata)
    end
end

return ScopeDragNode


