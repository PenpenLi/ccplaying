--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/8
-- Time: 下午2:17
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-7-17
-- Time: 下午2:51
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleUtils = require("scene.battle.helper.Utils")
-------------------------------------------------------------------------------

local SHAPE_SIZE = {
    [enums.SkillAreaShape.Circle ] = { width = 235, height = 235, },   -- 圆
    [enums.SkillAreaShape.Rect   ] = { width = 92, height = 92, },   -- 矩形
    [enums.SkillAreaShape.Fan60  ] = { width = 200, height = 260, },   -- 扇形（60度）
    [enums.SkillAreaShape.Fan90  ] = { width = 200, height = 280, },   -- 扇形（90度）
    [enums.SkillAreaShape.Cross  ] = { width = 479, height = 479, },   -- 十字形
    [enums.SkillAreaShape.Diamond] = { width = 163, height = 116, },   -- 菱形
}

local function get_cross_rect_width(bitmap)
    local width = bitmap:width()
    local height = bitmap:height()

    local midX = math.floor(width / 2)
    local y = math.floor(height / 4)

    local minX = midX
    while minX < width do
        if not bitmap:get(y, minX) then
            break
        end
        minX = minX + 1
    end

    local cwidth = (minX - midX) * 2

    return cwidth
end
-- 攻击范围拖放节点
local CLICK_MAX_TIME = 1.0

local SkillAreaNode = class("SkillAreaNode", function() return cc.Node:create() end)

--[[
    cell: 英雄所在的单元格
    direction:英雄的朝向
    area: 英雄的技能作用范围
    region: 英雄的技能作用范围的可选区域
--]]
function SkillAreaNode:ctor(skillData, heroCell, centerCell, direction, areaBitmap, regionRect, battleModel, isTeammate, isShadow)
    CCLog(vardump({shape = skillData.shape, heroCell = heroCell, centerCell = centerCell, direction = direction, regionRect = regionRect}, "SkillAreaNode:ctor"))
    --CCLog("area",areaBitmap:tostring())
    self.areaInfo = BattleUtils.getSkillArea(skillData.id)
    self.shape = skillData.shape
    self.heroCell = heroCell
    self.centerCell = centerCell
    self.direction = direction
    self.regionRect = regionRect
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

    self:drawShape(skillData.shape, isTeammate)

    self:setPosition(BattleConfig.PPOS(cc.p(BattleConfig.getCellPos(centerCell.x, centerCell.y))))

    if not isShadow then
        self:registerTouchListener()
    end
    
    self:registerNodeHandler()

    self.lastCell = centerCell
end

function SkillAreaNode:drawShape(shape, isTeammate)
    --十字形，用两个矩形来模拟
    local pathFormatStr = isTeammate and "image/spine/skill_effect/skillShape/team_%d/" or "image/spine/skill_effect/skillShape/%d/"
    if shape == enums.SkillAreaShape.Cross then
        local cwidth = get_cross_rect_width(self.area)
        local shapeAniPath = string.format(pathFormatStr, enums.SkillAreaShape.Rect)
        local horizontal = load_animation(shapeAniPath)
        if horizontal then
            self:addChild(horizontal)
            horizontal:setAnimation(0, "animation", true)
            local width = SHAPE_SIZE[enums.SkillAreaShape.Rect].width
            local height = SHAPE_SIZE[enums.SkillAreaShape.Rect].height
            horizontal:setScaleX(cwidth / width)
            horizontal:setScaleY(self.area:height() / height)
        end


        local vertical = load_animation(shapeAniPath)
        if vertical then
            self:addChild(vertical)
            vertical:setAnimation(0, "animation", true)
            vertical:setRotation(90)

            local width = SHAPE_SIZE[enums.SkillAreaShape.Rect].width
            local height = SHAPE_SIZE[enums.SkillAreaShape.Rect].height
            vertical:setScaleX(cwidth / width)
            vertical:setScaleY(self.area:height() / height)
        end

        return
    end

    local shapeAniPath = string.format(pathFormatStr, shape)
    local animation = load_animation(shapeAniPath)
    if animation then
        self:addChild(animation)

        animation:setAnimation(0, "animation", true)
        local width = SHAPE_SIZE[shape].width
        local height = SHAPE_SIZE[shape].height
        animation:setScaleX(self.area:width() / width)
        animation:setScaleY(self.area:height() / height)

        CCLog(vardump({width = width, height = height, awidth = self.area:width(), aheight = self.area:height(), scaleX = self.area:width() / width, scaleY = self.area:height() / height}, "shapeAniPath"))
    else
        local areaInfo = self.areaInfo
        local draw = cc.DrawNode:create()
        self:addChild(draw)

        local color = cc.c4f(1.0, 0.0, 0.0, 0.5)
        if shape == enums.SkillAreaShape.Circle then
            draw:drawSolidCircle(cc.p(0 ,0), areaInfo.width / 2, math.pi/2, 50, 1.0, areaInfo.height / areaInfo.width, color)
        elseif shape == enums.SkillAreaShape.Rect then
            local width = areaInfo.width / 2
            local height = areaInfo.height / 2

            local points = {{x = -width, y = -height}, {x = width, y = -height}, {x = width, y = height}, {x = -width, y = height}}
            draw:drawPolygon(points, #points, cc.c4f(1,0,0,1), 1, color)
        elseif shape == enums.SkillAreaShape.Fan60 then
            local points = {cc.p(0, 0)}
            for i = -30, 30 do
                local x = 100 * math.cos(math.rad(i))
                local y = 100 * math.sin(math.rad(i))
                table.insert(points, {x = x, y = y})
            end

            draw:drawPolygon(points, #points, color, 1, color)
        elseif shape == enums.SkillAreaShape.Fan90 then
            local points = {cc.p(0, 0)}
            for i = -45, 45 do
                local x = 100 * math.cos(math.rad(i))
                local y = 100 * math.sin(math.rad(i))
                table.insert(points, {x = x, y = y})
            end

            draw:drawPolygon(points, #points, color, 1, color)
        elseif shape == enums.SkillAreaShape.Cross then
            local cwidth = get_cross_rect_width(self.area)
            local width = areaInfo.width / 2
            local height = cwidth / 2

            local points = {{x = -width, y = -height}, {x = width, y = -height}, {x = width, y = height}, {x = -width, y = height}}
            draw:drawPolygon(points, #points, color, 1, color)

            local points = {{x = -height, y = -width}, {x = height, y = -width}, {x = height, y = width}, {x = -height, y = width}}
            draw:drawPolygon(points, #points, color, 1, color)

        elseif shape == enums.SkillAreaShape.Diamond then
            local width = areaInfo.width / 2
            local height = areaInfo.height / 2

            local points = {{x = -width, y = 0}, {x = 0, y = -height}, {x = width, y = 0}, {x = 0, y = height}}
            draw:drawPolygon(points, #points, color, 1, color)
        end
    end
end

function SkillAreaNode:updateHeroCell(cell, regionRect)
    self.regionRect = regionRect
end

function SkillAreaNode:pointInArea(point)
    local pos = point -- BattleConfig.BPOS(point)

    --local x, y = point.x, point.y
    local x, y = pos.x, pos.y

    local width  = self.areaInfo.width
    local height = self.areaInfo.height

    local absX = x + width / 2
    local absY = y + height / 2

    if absX < 0 or absX > width then
        return false
    end

    if absY < 0 or absY > height then
        return false
    end

    --CCLog(vardump({point = point, absX = absX, absY = absY, width = width, height = height, area = self.area}, "SkillAreaNode:pointInArea(point)"))
    return self.area:get(absX, absY)
end

function SkillAreaNode:pointInRegionRect(point)
    return cc.rectContainsPoint(self.regionRect, point)
end

function SkillAreaNode:setCallback(onDragDrop, onDragCancel, onDrageChange, cleanupCallback, userdata)
    self.onDragDropCallback = onDragDrop
    self.onDragCancelCallback = onDragCancel
    self.onDragChange = onDrageChange
    self.cleanupCallback = cleanupCallback
    self.userdata = userdata

    self:skillAreaChange(cc.p(self:getPosition()), "init")
end

function SkillAreaNode:registerNodeHandler()
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

function SkillAreaNode:registerTouchListener()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCanelled), cc.Handler.EVENT_TOUCH_CANCELLED)

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function SkillAreaNode:onEnter()
end

function SkillAreaNode:onExit()
end

function SkillAreaNode:onCleanup()
    self:stopTimer()

    if self.cleanupCallback then
        self.cleanupCallback()
    end
end

function SkillAreaNode:onEnterTransitionFinish()

end

function SkillAreaNode:onExitTransitionStart()

end

-- 开始计时
function SkillAreaNode:startTimer()
    self:stopTimer()

    self.useTime = 0

    local scheduler = cc.Director:getInstance():getScheduler()
    local scheduleEntryID = scheduler:scheduleScriptFunc(handler(self, self.onUpdate), 1 / 60, false)
    self.scheduleEntryID = scheduleEntryID
end

-- 结束计时
function SkillAreaNode:stopTimer()
    if self.scheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end
end

-- 计时
function SkillAreaNode:onUpdate(delta)
    if self.useTime == nil then
        self.useTime = delta
    else
        self.useTime = self.useTime + delta
    end
end

function SkillAreaNode:onTouchBegan(touch, event)
    CCLog("onTouchBegan")   

    local location = touch:getLocation()
    local pos = self:convertToNodeSpace(location)

    self:skillAreaChange(pos, "begin")

    CCLog(vardump({pos = pos, width = self.areaInfo.width, height = self.areaInfo.height}, "Touch Began"))
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

function SkillAreaNode:onTouchMoved(touch, event)
    CCLog("onTouchMoved")

    local curPos = touch:getLocation()
    local startPos = touch:getStartLocation()
    local pos = cc.pAdd(self.dragStartPos, cc.p(curPos.x - startPos.x, curPos.y - startPos.y))
    self:setPosition(pos)
    self:skillAreaChange(pos, "move")
end

function SkillAreaNode:onTouchEnded(touch, event)
    CCLog("onTouchEnded")
    local curPos = cc.p(self:getPosition())
    local battlePos = BattleConfig.BPOS(curPos)

    local areaInfo = self.areaInfo

    local rect = self.regionRect
    local areaBitmap = self.area

    self:skillAreaChange(curPos, "end")

    areaBitmap:resize(BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)
    areaBitmap:move(battlePos.x - areaInfo.width / 2, battlePos.y - areaInfo.height / 2)

    if self.onDragDropCallback and not areaBitmap:isRectEmpty(rect.x, rect.y, rect.width, rect.height) then
        self.onDragDropCallback({dragNode = self, data = self.userdata, pos = curPos})
    else
        self:cancel()
    end
end

function SkillAreaNode:done()
    if self.onDragDropCallback then
        self.onDragDropCallback({dragNode = self, data = self.userdata, pos = cc.p(self:getPosition())})
    end
end

function SkillAreaNode:cancel()
    if self.onDragCancelCallback then
        self.onDragCancelCallback({dragNode = self, data = self.userdata})
    end
end

function SkillAreaNode:onTouchCanelled(touch, event)
    self.touchCount = 0
    self:stopTimer()

    if self.onDragCancelCallback then
        self.onDragCancelCallback({dragNode = self, data = self.userdata})
    end
end

function SkillAreaNode:skillAreaChange(pos, chgType)
    if self.onDragChange then
        self.onDragChange(pos, chgType, self.userdata)
    end
end

return SkillAreaNode


