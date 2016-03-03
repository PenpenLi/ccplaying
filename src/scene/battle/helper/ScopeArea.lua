--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/4/17
-- Time: 下午6:10
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local bitmap = require("bitmap")
-------------------------------------------------------------------------------

local BattleCellScope = class("BattleCellScope")

--[[
    cell = {x = x, y = y }
    scopeCells = { {x, y}, {x, y}, ...}
--]]
function BattleCellScope:ctor(centerCell, scopeCells)
    local numX = BattleConfig.X_CELL_COUNT
    local numY = BattleConfig.Y_CELL_COUNT

    local bits = bitmap.new(numX * numY)
    self.bits = bits
    self.center = centerCell
    self.cells = scopeCells

    self:init()
end

function BattleCellScope:init()
    local numX = BattleConfig.X_CELL_COUNT

    local bits = self.bits
    local scopeCells = self.cells
    local centerCell = self.center

    bits:zero()
    if #scopeCells == 0 then -- 长度为0表示全部
        bits:fill()
    else
        for _, item in ipairs(scopeCells) do
            local rx = item[1]
            local ry = item[2]

            local ax = rx + centerCell.x
            local ay = ry + centerCell.y

            bits:set(ax + ay * numX)
        end
    end
end

function BattleCellScope:setCenterCell(cell)
    self.center = cell
    self:init()
end

function BattleCellScope:setScopeCells(scopeCells)
    self.cells = scopeCells
    self:init()
end

function BattleCellScope:getAbs(x, y)
    local numX = BattleConfig.X_CELL_COUNT
    return self.bits:get(x + y * numX)
end

function BattleCellScope:setAbs(x, y, val)
    local numX = BattleConfig.X_CELL_COUNT
    if val then
        self.bits:set(x + y * numX, 1)
    else
        self.bits:clear(x + y * numX, 1)
    end
end

function BattleCellScope:relCellToAbs(x, y)
    local centerCell = self.center
    local ax = x - centerCell.x
    local ay = y - centerCell.y

    return ax, ay
end

function BattleCellScope:getRel(x, y)
    local ax, ay = self:relCellToAbs(x, y)

    return self:getAbs(ax, ay)
end

function BattleCellScope:setRel(x, y, val)
    local ax, ay = self:relCellToAbs(x, y)

    return self:setAbs(ax, ay)
end

function BattleCellScope:intersection(battleCellScope)

end

return BattleCellScope

