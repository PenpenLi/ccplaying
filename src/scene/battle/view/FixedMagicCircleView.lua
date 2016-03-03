--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-5
-- Time: 下午2:51
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------
local FixedMagicCircleView = class("FixedMagicCircleView", function() return cc.DrawNode:create() end)

function FixedMagicCircleView:ctor(skillID)
    --self.model = model
    self.skillID = skillID
    self.aniList = {}

    self:setupUI()
end

function FixedMagicCircleView:setupUI()
    local skillID = self.skillID

    local fileUtils = cc.FileUtils:getInstance()
    local hasAni = false


    local floorImgPath = string.format("image/spine/skill_effect/magic/%d/bottom/floor.png", skillID)
    local floorAniPath = string.format("image/spine/skill_effect/magic/%d/bottom/", skillID)
    local floorAni = load_animation(floorAniPath, 1, BattleConfig.SPEED_RATIO)
    if floorAni then
        table.insert(self.aniList, floorAni)
        local floorAniName = "fixed_magic_bottom_" .. skillID
        floorAni:setName(floorAniName)
        floorAni:setAnimation(0, "animation", true)
        
        if skillID == 2001 then
            -- TODO:
            floorAni:setAnimation(0, "jianyu", true)

            local onSpineEvent = function(event)
                Common.playSound(cc.FileUtils:getInstance():fullPathForFilename("res/audio/effect/ball_drop.mp3"), false)
            end
            floorAni:registerSpineEventHandler(onSpineEvent, sp.EventType.ANIMATION_EVENT)
        end

        floorAni:setLocalZOrder(1)
        self:addChild(floorAni)
        floorAni:setPosition(cc.p(0, 0))
        floorAni:setTimeScale(1)
        floorAni:setScale(1)

        hasAni = true
    elseif fileUtils:isFileExist(floorImgPath) then
        local magicFloor = cc.Sprite:create(floorImgPath)
        magicFloor:setLocalZOrder(1)
        self:addChild(magicFloor)
    end

    local magicAniPath = string.format("image/spine/skill_effect/magic/%d/top/", skillID)
    local magicAni = load_animation(magicAniPath, 1, BattleConfig.SPEED_RATIO)
    if magicAni then
        table.insert(self.aniList, magicAni)
        local magicName = "fixed_magic_top_" .. skillID
        magicAni:setName(magicName)
        magicAni:setAnimation(0, "animation", true)

        magicAni:setLocalZOrder(1)
        self:addChild(magicAni)
        magicAni:setPosition(cc.p(0, 0))
        magicAni:setTimeScale(1)
        magicAni:setScale(1)

        hasAni = true
    end

    if not hasAni then
        CCLog("没有找到魔法阵", skillID)
--        local area = self.model.attackData:absArea()
--
--        self:drawArea(area, "red")
--        self.areaRects = self:calcScopeRects(area)
--        self:drawRects(self.areaRects, cc.c4f(1, 0, 0, 0.8))
    end
end

--function FixedMagicCircleView:drawArea(areaBitmap, color)
--    CCLog("draw area:", areaBitmap:tostring())
--    local cellImg = color == "red" and "image/spine/skill_effect/atk_red.png" or "image/spine/skill_effect/atk_green.png"
--
--    for absY = 0, (BattleConfig.Y_CELL_COUNT * 2 - 1) - 1  do
--        for absX = 0, (BattleConfig.X_CELL_COUNT * 2 - 1) - 1 do
--            if areaBitmap:get(absX, absY) then
--                local x = absX - (BattleConfig.X_CELL_COUNT - 1)
--                local y = absY - (BattleConfig.Y_CELL_COUNT - 1)
--
--                local rect = BattleConfig.getCellRect(x, y)
--                local sprite = cc.Sprite:create(cellImg)
--                local size = sprite:getContentSize()
--                sprite:setOpacity(200)
--                sprite:setScaleX(rect.width / size.width)
--                sprite:setScaleY(rect.height / size.height)
--                sprite:ignoreAnchorPointForPosition(true)
--                sprite:setPosition(rect)
--                sprite:setContentSize(rect)
--                self:addChild(sprite)
--            end
--        end
--    end
--end

--function FixedMagicCircleView:drawRects(rects, color)
--    for idx, rect in ipairs(rects) do
--        self:drawRect(rect, color)
--    end
--end

--function FixedMagicCircleView:drawRect(rect, color)
--    local bl = cc.p(rect.x, rect.y)
--    local tl = cc.p(rect.x, rect.y + rect.height)
--    local tr = cc.p(rect.x + rect.width, rect.y + rect.height)
--    local br = cc.p(rect.x + rect.width, rect.y)
--    self:drawPolygon({bl, tl, tr, br}, 4, color, 0, color)
--end
--
--
--function FixedMagicCircleView:getCellRect(x, y)
--    return BattleConfig.getCellRect(x, y)
--end

--function FixedMagicCircleView:calcScopeRects(scope)
--    local rects = {}
--    for y, xrange in pairs(scope) do
--        for x = xrange.start, xrange.start + xrange.len - 1 do
--            local rect = BattleConfig.getCellRect(x, y)
--            table.insert(rects, rect)
--        end
--    end
--    return rects
--end

function FixedMagicCircleView:pauseBattle()
    for _, ani in ipairs(self.aniList) do
        ani:pause()
    end
end

function FixedMagicCircleView:resumeBattle()
    for _, ani in ipairs(self.aniList) do
        ani:resume()
    end
end

return FixedMagicCircleView