
local  M = {}


function M.CreateAnimation(self, parent, x, y, heroid, effectid , rep)
    local path = nil
    if heroid == nil then
        path = "image/spine/ui_effect/"..effectid.."/skeleton"
    else
        path = string.format("image/spine/ui_effect/%d_%d/skeleton", heroid, effectid)
    end
    
    if path == nil then
        return nil
    end
    
    local r = rep or false
    local skel = path..".skel"
    local json = path..".json"
    local atlas = path .. ".atlas"

    local animation = nil

    if cc.FileUtils:getInstance():isFileExist(skel) then
            animation = sp.SkeletonAnimation:create(skel, atlas, 1.0)
    elseif cc.FileUtils:getInstance():isFileExist(json) then
            animation = sp.SkeletonAnimation:create(json, atlas, 1.0)
    else
        return nil
    end

    animation:setAnimation(0, "animation", r)
    animation:setPosition(x, y)
    parent:addChild(animation)
    return animation
end

function M.RepeatAnimation( self,node )
    node:setAnimation(0, "animation", false)
end

function M.DeleteAnimation( self,node )
    if node ~= nil then
        node:removeFromParent()
        node = nil
    end
end

function M.PauseAnimation( self, node )
    node:pause()
end

function M.ResumeAnimation ( self,node )
    node:resume()
end

return M