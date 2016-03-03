--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/4/25
-- Time: 下午3:04
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local PathFinder = class("PathFinder")

function PathFinder:ctor(fighter, enemy, battleModel)
    self.fighter = fighter
    self.enemy = enemy
    self.battleModel = battleModel
end

function PathFinder:reset()
    local src_cell = self.fighter:getCell()
    self:setStartPoint(src_cell.x, src_cell.y)

    local enemy_cell = self.enemy:getCell()
    if src_cell.x ~= enemy_cell.x then
        local midX =  math.floor((src_cell.x + enemy_cell.x) / 2)
        self:setEndPoint(midX, enemy_cell.y)
    else
        if self.fighter:getDirection() == "right" then
            self:setEndPoint(enemy_cell.y + 1, enemy_cell.y)
        else
            self:setEndPoint(enemy_cell.y - 1, enemy_cell.y)
        end
    end

    local startNode = self.startNode
    self.nextNode = startNode
    self.openList = {}
    self.closedList = {}
    table.insert(self.closedList, startNode)
    local startAdj = self:checkWalkable(self:getAdjacent(startNode.x, startNode.y, startNode))
    self:addToOpenList(startAdj)
    self.time = 0
    self.complete = false
    self.status = "Seaching"
end

function PathFinder:isWalkable(x, y)
    local battleModel = self.battleModel
    local fighter = self.fighter

    if x < 0 or x >= BattleConfig.X_CELL_COUNT then
        return false
    end

    if y < 0 or y >= BattleConfig.Y_CELL_COUNT then
        return false
    end

    return battleModel:isWalkable(x, y, fighter)
--    if battleModel:isGridUsed(x, y, fighter) then
--        return false
--    end
--
--    if battleModel:isGridToBeUse(x, y) then
--        return false
--    end

--    return true
end

function PathFinder:setStartPoint(newX, newY)
    local startNode = { x = newX, y = newY, g = 0 }
    self.startNode = startNode
end

function PathFinder:setEndPoint(newX, newY)
    local endNode = { x = newX, y = newY, g = 0 }
    self.endNode = endNode
end

function PathFinder:setEnemy(enemy)
    self.enemy = enemy
end

function PathFinder:getAdjacent(x, y, parent)
    local battleModel = self.battleModel
    local fighter = self.fighter

    local adj = {}
    if self:isWalkable(x, y - 1) then
        if self:isWalkable(x - 1, y) then
            adj.topLeft = { x = x - 1, y = y - 1, g = 14 + parent.g, parent = parent}
        end
        if self:isWalkable(x + 1, y) then
            adj.topRight = { x = x + 1, y = y - 1, g = 14 + parent.g, parent = parent}
        end
    end
    if self:isWalkable(x, y + 0) then
        if self:isWalkable(x - 1, y) then
            adj.bottomLeft = { x = x - 1, y = y + 1, g = 14 + parent.g, parent = parent}
        end
        if self:isWalkable(x + 1, y) then
            adj.bottomRight = { x = x + 1, y = y + 1, g = 14 + parent.g, parent = parent}
        end
    end
    adj.up = { x = x, y = y - 1, g = 10 + parent.g, parent = parent}
    adj.left = { x = x - 1, y = y, g = 10 + parent.g, parent = parent}
    adj.right = { x = x + 1, y = y, g = 10 + parent.g, parent = parent}
    adj.down = { x = x, y = y + 1, g = 10 + parent.g, parent = parent}
    return adj
end

function PathFinder:getAdjacentInOpen(currentNode)
    local adj = self:getAdjacent(currentNode.x, currentNode.y, currentNode)
    local adjInOpen = {}
    for _, adjacent in pairs(adj) do
        for _, node in ipairs(self.openList) do
            if adjacent.x == node.x and adjacent.y == node.y then
                table.insert(adjInOpen, node)
            end
        end
    end
    return adjInOpen
end

function PathFinder:checkIfShorter(currentNode, adjacent)
    local adj = self:getAdjacent(currentNode.x, currentNode.y, currentNode)
    local adjInOpen = self:getAdjacentInOpen(currentNode)
    if #adjInOpen > 0 then
        for _, openAdjacent in ipairs(adjInOpen) do
            for _, newAdjacent in ipairs(adj) do
                if (openAdjacent.x == newAdjacent.x and openAdjacent.y == newAdjacent.y) then
                    local currentG = openAdjacent.g
                    local newG = newAdjacent.g
                    if newG < currentG then
                        adjacent.parent = currentNode
                        adjacent.g = newG
                    end
                end
            end
        end
    end
end

function PathFinder:checkWalkable(nodes)
    local battleModel = self.battleModel

    local walkable = {}
    for _, node in pairs(nodes) do
        local x = node.x
        local y = node.y
        if x >= 0  and x < BattleConfig.X_CELL_COUNT and y >= 0 and y < BattleConfig.Y_CELL_COUNT then
            if self:isWalkable(node.x, node.y) then
                table.insert(walkable, node)
            end
        end
    end
    return walkable
end


function PathFinder:addToOpenList(newNodes)
    for _, newNode in pairs(newNodes) do
        local alreadyInList = false
        for _, node in ipairs(self.openList) do
            if node.x == newNode.x and node.y == newNode.y then
                alreadyInList = true
            end
            for _, closedNode in ipairs(self.closedList) do
                if newNode.x == closedNode.x and newNode.y == closedNode.y then
                    alreadyInList = true
                end
            end
        end
        if not alreadyInList then
            table.insert(self.openList, newNode)
        end
    end
end

function PathFinder:getH(node)
    local endNode = self.endNode
    local xDifference = 10 * ( math.abs(node.x - endNode.x))
    local yDifference = 10 * ( math.abs(node.y - endNode.y))
    return  xDifference + yDifference
end


function PathFinder:getF(node)
    return node.g + self:getH(node)
end


function PathFinder:findNextNode()
    local lowestF = 999999999
    local nextNode = nil
    local openIndex = nil
    for i, node in ipairs(self.openList) do
        if self:getF(node) <= lowestF then
            lowestF = self:getF(node)
            nextNode = node
            openIndex = i
        end
    end
    return nextNode, openIndex
end

function PathFinder:calcEndNode(enemy)
    local ecell = enemy:getCell()
    local mcell = self.fighter:getCell()

    local startX = mcell.x
    local startY = mcell.y

    local endX = ecell.x
    local endY = ecell.y

    local midY = math.floor((startY + endY) / 2)

    local diffX = endX - startX
    local absDiffX = math.abs(diffX)
    if absDiffX <= 1 then
        if self.fighter:getDirection() == "right" then
            self:setEndPoint(endX - diffX, midY)
        else
            self:setEndPoint(endX - diffX, midY)
        end
    else
        local addtion = 0.5
        if self.fighter:getDirection() == "right" then
            addtion = -0.5
        end

        local midX = math.floor(endX + startX + addtion) / 2
        self:setEndPoint(midX, midY)
    end
end


function PathFinder:findPath(maxStepCount)
--    local pathfinder = require("pathfinder")
--    local pf = pathfinder.new()
--    local function reachable(x, y)
--        return self:isWalkable(x, y)
--    end
--
--    local config = {
--        row = BattleConfig.Y_CELL_COUNT,
--        col = BattleConfig.X_CELL_COUNT,
--        start = self.startNode,
--        goal = self.endNode,
--        allow_corner = false,
--        reachable = reachable,
--    }
--
--    local ok, result = pf:search(config)
--    CCLog(vardump({status = ok, result = result}))
--    if ok then
--        self.status = "Found"
--        self.complete = true
--
--        CCLog(vardump(result, "Path"))
--        return result
--    else
--        self.status = "Emptry"
--        self.complete = true
--
--        return {}
--    end

    local nextNode = self.nextNode
    local endNode = self.endNode
    local openIndex
    local closedList = self.closedList
    local openList = self.openList
    local newAdj

    local stepCount = 0

    local startNode = self.startNode
    local battleModel = self.battleModel
    local map = {}
    for y = 0, BattleConfig.Y_CELL_COUNT do
        local row = {}
        for x = 0, BattleConfig.X_CELL_COUNT - 1 do
            local bit = "0"

            if x == startNode.x and y == startNode.y then
                bit = "s"
            elseif x == endNode.x and y == endNode.y then
                bit = "d"
            elseif  not self:isWalkable(x, y) then
                bit = "1"
            end

            table.insert(row, bit)
        end

        table.insert(row, "\n")
        table.insert(map, row)
    end

    local function printMap(map)
        local ms = {}
        for y = BattleConfig.Y_CELL_COUNT - 1, 0, -1 do
            local rs = table.concat(map[y + 1])
            table.insert(ms, rs)
        end
        CCLog("\n" .. table.concat(ms))
    end

    printMap(map)

    while not self.complete do
        stepCount = stepCount + 1

        --CCLog(vardump({nextNode = {x = nextNode.x, y = nextNode.y, g = nextNode.g}, startPos = self.startPos, endPos = endNode}, "nextNode"))
        map[nextNode.y + 1][nextNode.x + 1] = "*"
        printMap(map)
        if stepCount > maxStepCount then
            self.status = "Breaking"
            self.complete = true
            break
        end

        if not (nextNode.x == endNode.x and nextNode.y == endNode.y) then
            nextNode, openIndex = self:findNextNode()

            if nextNode then
                self.nextNode = nextNode

                table.insert(closedList, nextNode)
                table.remove(openList, openIndex)
                if #openList == 0 then
                    self.status = "Not found"
                    self.complete = true
                end
                newAdj = self:checkWalkable(self:getAdjacent(nextNode.x, nextNode.y, nextNode))
                self:addToOpenList(newAdj)
                for _, openNode in ipairs(openList) do
                    self:checkIfShorter(nextNode, openNode)
                end
            else
                self.status = "Block"
                self.complete = true
            end
        else
            self.nextNode = nextNode

            self.status = "Found"
            self.complete = true
        end
    end
end

function PathFinder:getPath()
    local path = {}


    local nextNode = self.nextNode
    local startNode = self.startNode

    CCLog(vardump(nextNode), "PathFinder:getPath")
    local nodeParent = nextNode.parent
    while nodeParent and (not (nodeParent.x == startNode.x and nodeParent.y == startNode.y)) do
        table.insert(path, {x = nodeParent.x, y = nodeParent.y})
        nodeParent = nodeParent.parent
    end

    return path
end

return PathFinder
