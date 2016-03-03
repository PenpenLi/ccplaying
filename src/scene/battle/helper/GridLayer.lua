-- 地图背影格子(调度用)
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local GridLayer = class("GridLayer", function() return cc.Layer:create() end)

function GridLayer:ctor(rect, xcellCount, ycellCount, color1, color2, degree)
    self._cells = {}
    local gridNode = cc.DrawNode:create()
    self:addChild(gridNode)

    local CELL_WIDTH = rect.width / xcellCount
    local CELL_HEIGHT = rect.height / ycellCount

    self.CELL_WIDTH = CELL_WIDTH
    self.CELL_HEIGHT = CELL_HEIGHT

    local basePos = cc.p(rect.x, rect.y)
    for x = 0, xcellCount - 1 do
        for y = 0, ycellCount - 1 do
            local color = ((x + y) % 2 == 1) and color1 or color2

            -- local left = x  * CELL_WIDTH
            -- local right = (x + 1) * CELL_WIDTH
            -- local bottom = y * CELL_HEIGHT
            -- local top = (y + 1) * CELL_HEIGHT

            local rect   = BattleConfig.getCellRect(x, y)
            local left   = cc.rectGetMinX(rect)
            local right  = cc.rectGetMaxX(rect)
            local bottom = cc.rectGetMinY(rect) + CELL_HEIGHT / 7
            local top    = cc.rectGetMaxY(rect) - CELL_HEIGHT / 7

            local bl = BattleConfig.PPOS(cc.pAdd(basePos, cc.p(left, bottom)))
            local bm = BattleConfig.PPOS(cc.pAdd(basePos, cc.p((left + right) / 2, bottom - CELL_HEIGHT / 4)))
            local tl = BattleConfig.PPOS(cc.pAdd(basePos, cc.p(left, top)))
            local tm = BattleConfig.PPOS(cc.pAdd(basePos, cc.p((left + right) / 2, top + CELL_HEIGHT / 4)))
            local tr = BattleConfig.PPOS(cc.pAdd(basePos, cc.p(right, top)))
            local br = BattleConfig.PPOS(cc.pAdd(basePos, cc.p(right, bottom)))

            gridNode:drawPolygon({bl, tl, tm, tr, br, bm}, 6, color, 0, color)

            local center = cc.pAdd(basePos, cc.p(left + CELL_WIDTH / 2, bottom + CELL_HEIGHT / 2))
            local rect = cc.rect(bl.x, bl.y, CELL_WIDTH, CELL_HEIGHT)
            self._cells[x .. "_" .. y] = {bl = bl, tl = tl, tr = tr, br = br, center = center, rect = rect}

            if x == 0 then
                if y == 0 or y == math.floor(ycellCount / 2) or y == ycellCount -1 then
                    local label = cc.LabelAtlas:_create("" .. y, "image/atlas/numred.png", 30, 39,  string.byte("0"))
                    label:setPosition(BattleConfig.PPOS(cc.pAdd(basePos, cc.p((left + right) / 2, (top + bottom) / 2))))
                    label:setAnchorPoint(cc.p(0.5, 0.5))
                    self:addChild(label)
                end
            end

            if y == 0 then
                if x == 0 or x == math.floor(xcellCount / 2) or x == xcellCount -1 then
                    local label = cc.LabelAtlas:_create("" .. x, "image/atlas/numred.png", 30, 39, string.byte("0"))
                    label:setPosition(BattleConfig.PPOS(cc.pAdd(basePos, cc.p((left + right) / 2, (top + bottom) / 2))))
                    label:setAnchorPoint(cc.p(0.5, 0.5))
                    self:addChild(label)
                end
            end
        end
    end

    self:setRotationSkewX(degree)
end

function GridLayer:getCell(x, y)
    return self._cells[x .. "_" .. y]
end

return GridLayer