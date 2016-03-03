-- 攻击范围节点
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------
local ScopeGridNode = class("ScopeGridNode", function() return cc.DrawNode:create() end)

function ScopeGridNode:ctor(battleModel)
    self.battleModel = battleModel
end

function ScopeGridNode:drawRect(rect, color)
    local bl = cc.p(rect.x, rect.y)
    local tl = cc.p(rect.x, rect.y + rect.height)
    local tr = cc.p(rect.x + rect.width, rect.y + rect.height)
    local br = cc.p(rect.x + rect.width, rect.y)
    self:drawPolygon({bl, tl, tr, br}, 4, color, 0, color)
end

function ScopeGridNode:drawRects(rects, color)
    for idx, rect in ipairs(rects) do
        self:drawRect(rect)
    end
end

function ScopeGridNode:drawScope(scope, color)
    if type(scope) == "table" then
        self:drawCellScope(scope, color)
    elseif type(scope) == "userdata" then
        self:drawBitmapScope(scope, color)
    else
        assert(false, "scope type:" .. type(scope))
    end
end

function ScopeGridNode:drawCellScope(scope, color)
    local battleModel = self.battleModel
    for y, xrange in pairs(scope) do
        for x = xrange.start, xrange.start + xrange.len - 1 do

            local rect = BattleConfig.getCellRect(x, y)
            local sprite = cc.Sprite:create("image/spine/skill_effect/atk_black.png")
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

function ScopeGridNode:drawBitmapScope(bitmap, color)
    local battleModel = self.battleModel
    for y = 0, bitmap:height() - 1 do
        for x = 0, bitmap:width() - 1 do
            if bitmap:get(x, y) then
                local rect = BattleConfig.getCellRect(x, y)
                local sprite = cc.Sprite:create("image/spine/skill_effect/atk_black.png")
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

return ScopeGridNode
