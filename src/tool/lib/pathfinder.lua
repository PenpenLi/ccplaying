local NODE_F, NODE_H, NODE_G, NODE_X, NODE_Y, NODE_OPEN, NODE_VALID, NODE_PARENT, NODE_NUM = 1, 2, 3, 4, 5, 6, 7, 8, 9

local abs = math.abs
local min = math.min

local heap = require("tool.lib.heap")

local function heuristic(cx, cy, gx, gy)
    local dy, dx = abs(gy - cy), abs(gx - cx)
    return min(dy, dx) * 14 + abs(dy - dx) * 10
end

local function cost(fx, fy, tx, ty, goalX, goalY)
	if abs(fx - tx) == 1 and abs(fy - ty) == 1 then
		return 14
	else
		return 10
	end
end

local function neighbours(map, x, y, diagonal)
	local N_x , N_y  = x - 1, y 
    local E_x , E_y  = x    , y + 1
    local S_x , S_y  = x + 1, y 
    local W_x , W_y  = x    , y - 1
    local NE_x, NE_y = x - 1, y + 1
    local SE_x, SE_y = x + 1, y + 1
    local SW_x, SW_y = x + 1, y - 1
    local NW_x, NW_y = x - 1, y - 1

    local adjacent = {}

    -- 正角
	if not map:get(N_x, N_y) then
		table.insert(adjacent, {N_x, N_y})
	end
	if not map:get(E_x, E_y)  then
		table.insert(adjacent, {E_x, E_y})
	end
	if not map:get(S_x, S_y) then
		table.insert(adjacent, {S_x, S_y})
	end
	if not map:get(W_x, W_y) then
		table.insert(adjacent, {W_x, W_y})
	end

	-- 斜角
	if diagonal then
		if not map:get(NE_x, NE_y) and not map:get(N_x, N_y) and not map:get(E_x, E_y) then
			table.insert(adjacent, {NE_x, NE_y})
		end
		if not map:get(SE_x, SE_y) and not map:get(S_x, S_y) and not map:get(E_x, E_y) then
			table.insert(adjacent, {SE_x, SE_y})
		end
		if not map:get(SW_x, SW_y) and not map:get(S_x, S_y) and not map:get(W_x, W_y) then
			table.insert(adjacent, {SW_x, SW_y})
		end
		if not map:get(NW_x, NW_y) and not map:get(N_x, N_y) and not map:get(W_x, W_y) then
			table.insert(adjacent, {NW_x, NW_y})
		end
	end

	return adjacent
end

local function newCounter(num)
	return function()
		num = num + 1
		return num
	end
end

local function findPath(map, startX, startY, goalX, goalY, heuristic, cost, neighbours, isGoal, limit)
	limit = limit or 65535
	local counter = newCounter(0)

	if isGoal == nil then
		isGoal = function(cx, cy, gx, gy)
			return cx == gx and cy == gy 
		end
	end

	local width = map:width()
	local height = map:height()

	local openList = heap(function(nodeA, nodeB) return nodeA[NODE_F] < nodeB[NODE_F] end)

	local startH = heuristic(startX, startY, goalX, goalY)
	local startNode = {
						[NODE_F] = 0 + startH, 
						[NODE_H] = startH, 
						[NODE_G] = 0, 
						[NODE_X] = startX, 
						[NODE_Y] = startY, 
						[NODE_OPEN] = true, 
						[NODE_VALID] = true, 
						[NODE_PARENT] = -1,
						[NODE_NUM] = counter(),
					}

	local nodes = {[startX + startY * width] = startNode}
	openList:insert(startNode)

	local best = startNode
	while not openList:empty() do
		local curNode = openList:pop()
		curNode[NODE_OPEN] = false
		local cx, cy = curNode[NODE_X], curNode[NODE_Y]
		local cur_index = cx + cy * width
		--print("currentNode:", cx, cy)

		-- 找到目标
		if isGoal(cx, cy, goalX, goalY) then
			best = curNode
			break
		end

		for idx, neighbor_pos in ipairs(neighbours(map, cx, cy, true)) do			
			local nx, ny = neighbor_pos[1], neighbor_pos[2]
			local neighbor_index = nx + ny * width

			local neighbor_g = curNode[NODE_G] + cost(cx, cy, nx, ny, goalX, goalY)
			local neighbor = nodes[neighbor_index]
			if neighbor == nil then
				local neighbor_h = heuristic(nx, ny, goalX, goalY)
                local neighbor = {
                				[NODE_F] = neighbor_g + neighbor_h, 
                				[NODE_H] = neighbor_h, 
                				[NODE_G] = neighbor_g, 
                				[NODE_X] = nx, 
                				[NODE_Y] = ny, 
                				[NODE_OPEN] = true,
                				[NODE_VALID] = true, 
                				[NODE_PARENT] = cur_index,
                				[NODE_NUM] = counter(),
                			}

                nodes[neighbor_index] = neighbor
                openList:insert(neighbor)
                if neighbor_h < best[NODE_H] then
                    best = neighbor
                end

                if neighbor[NODE_NUM] > limit then
                	break
                end
			elseif neighbor_g < neighbor[NODE_G] then
				if neighbor[NODE_OPEN] then
                    neighbor[NODE_VALID] = false
                    
                    local new_neighbor = {
                    	[NODE_F] = neighbor_g + neighbor[NODE_H],
        				[NODE_H] = neighbor[NODE_H], 
        				[NODE_G] = neighbor_g, 
        				[NODE_X] = nx, 
        				[NODE_Y] = ny, 
        				[NODE_OPEN] = true, 
        				[NODE_VALID] = true,
        				[NODE_PARENT] = cur_index,
        				[NODE_NUM] = counter(),
                	}
                    nodes[neighbor_index] = new_neighbor     
                    openList:insert(new_neighbor)
	            else
                    neighbor[NODE_F] = neighbor_g + neighbor[NODE_H]
                    neighbor[NODE_G] = neighbor_g
                    neighbor[NODE_PARENT] = cur_index
                    neighbor[NODE_OPEN] = true
                    openList:insert(neighbor)
				end
			end
		end

		while not openList:empty() and not openList:top()[NODE_VALID] do
			openList:pop()
        end
	end

	local path = {}
    current = best
    while current[NODE_PARENT] ~= -1 do
    	local cx, cy = current[NODE_X], current[NODE_Y]
    	table.insert(path, 1, {x = cx, y = cy})
        current = nodes[current[NODE_PARENT]]
    end

    return path
end

return {
	heuristic = heuristic, 
	cost = cost, 
	neighbours = neighbours,
	findPath = findPath,
}
