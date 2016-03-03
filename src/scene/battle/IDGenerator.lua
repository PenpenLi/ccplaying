--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/5
-- Time: 上午11:22
-- To change this template use File | Settings | File Templates.
--

local lastID = 1

local IDGenerator = {

}

function IDGenerator.genID()
    local newID = lastID
    lastID = lastID + 1

    return newID
end

return IDGenerator