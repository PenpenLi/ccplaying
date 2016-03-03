-- 根据名称获取任意深度的的后代节点
function get_any_child(node, name)  --@return cc.Widget    
    if node.getChildByName then
        local child = node:getChildByName(name)
        if child then
            return child
        end
    end
    
    local children = node:getChildren()
    for idx, child in ipairs(children) do
        if child.getName and child:getName() == name then
            return child
        else
            local res = get_any_child(child, name)
            if res then
                return res
            end
        end
    end
end

-- 获取指定的后代节点， 参数可以为 Name, Tag, *.例:get_descendant("root", "level2", "level3", "*", "level5", 32)
function get_descendant(node, ...) --@return cc.Widget    
    print(node, ...)
    local args = {...}
    
    if #args == 0 then       
        return node
    end
    
    local arg = table.remove(args, 1)
    
    if arg == "*" then
        local children = node:getChildren()
        for idx, child in ipairs(children) do
            local res = get_descendant(child, unpack(args))
            if res then
                return res
            end
        end
        error("find * fail", 1)
    else
        local typ = type(arg)
        if typ == "string" then
            local tmpNode = node:getChildByName(arg)
            
            if tmpNode then
                return get_descendant(tmpNode, unpack(args))
            else
                error("find(" .. arg .. ") fail", 1)
                return nil
            end
        elseif typ == "number" then
            local tmpNode = node:getChildByTag(arg)
            
            if tmpNode then
                return get_descendant(tmpNode, unpack(args))
            else
                error("find(" .. arg .. ") fail", 1)
                return nil
            end
        else
            error("not except type " .. typ, 1)
        end
    end
end

--包装了一个TouchListener, 当Moved事件次数大于一定数量后，忽略
function widget_click_listener(listener, max_move_count)
    max_move_count = max_move_count or 5
    local move_count = 0
    --local startPos = nil
    
    return function(sender, eventType)
        CCLog(vardump{movePos = sender:getTouchMovePosition(), startPos = sender:getTouchBeganPosition(), type = eventType})
        if eventType == ccui.TouchEventType.began then
           -- startPos = sender:convertToWorldSpace(cc.p(sender:getPosition()))
            move_count = 0
        elseif eventType == ccui.TouchEventType.moved then
            move_count = move_count + 1
        elseif eventType == ccui.TouchEventType.ended then
            --local pos = sender:convertToWorldSpace(cc.p(sender:getPosition()))
            --local dis = math.sqrt((startPos.x - pos.x) ^ 2 + (startPos.y - pos.y) ^ 2)
            --print("moved " .. dis .. vardump({startPos, pos},"pos"))
            if move_count <= max_move_count then
                listener(sender)
            else
                print(sender:getName() .." move count " .. move_count .. ", ignore")
            end
        end            
    end
end

function print_widget_tree(node, level, result) --@return string    
    level = level or 0
    result = result or {}
    if level == 0 then
        table.insert(result, node:getName())
    end
    local children = node:getChildren()    
    local name 
    for idx, child in ipairs(children) do
        if node.getName then
            name = child:getName()
        else
            name = child:getTag()
        end
        
        table.insert(result, string.rep("   ", level + 1) .. name)
        print_widget_tree(child, level + 1, result)
    end
    if level == 0 then
        local tree = table.concat(result, "\n")
        print(tree)
    end
end

function load_animation(aniDir, scale, timeScale)
    local fileUtils = cc.FileUtils:getInstance()
    local libpath = require("tool.lib.path")

    local redirectFile = libpath.join(aniDir, "redirect.txt")
    if fileUtils:isFileExist(redirectFile) then
        local redirectTo = fileUtils:getStringFromFile(redirectFile)
        aniDir = libpath.normpath(libpath.join(aniDir, redirectTo))
        CCLog(vardump({redirectTo = redirectTo, aniDir = aniDir}, "load_animation"))
    end    

    scale = scale or 1
    local jsonPath  = libpath.join(aniDir, "skeleton.json")
    local skelPath  = libpath.join(aniDir, "skeleton.skel")
    local atlasPath = libpath.join(aniDir, "skeleton.atlas")
    
    if fileUtils:isFileExist(atlasPath) then
        if fileUtils:isFileExist(skelPath) then
            local ani = sp.SkeletonAnimation:create(skelPath, atlasPath, scale)
            if ani and timeScale then 
                ani:setTimeScale(timeScale)
            end            
            return ani
        elseif fileUtils:isFileExist(jsonPath) then
            local ani = sp.SkeletonAnimation:create(jsonPath, atlasPath, scale)
            if ani and timeScale then
                ani:setTimeScale(timeScale)
            end
            return ani
        end
    end
    return nil
end

function preload_animation(aniDir, scale, timeScale)
    local fileUtils = cc.FileUtils:getInstance()
    local libpath = require("tool.lib.path")

    local redirectFile = libpath.join(aniDir, "redirect.txt")
    if fileUtils:isFileExist(redirectFile) then
        local redirectTo = fileUtils:getStringFromFile(redirectFile)
        aniDir = libpath.normpath(libpath.join(aniDir, redirectTo))
        CCLog(vardump({redirectTo = redirectTo, aniDir = aniDir}, "preload_animation"))
    end    

    scale = scale or 1
    local jsonPath  = libpath.join(aniDir, "skeleton.json")
    local skelPath  = libpath.join(aniDir, "skeleton.skel")
    local atlasPath = libpath.join(aniDir, "skeleton.atlas")
    
    if fileUtils:isFileExist(atlasPath) then
        if fileUtils:isFileExist(skelPath) then
            sp.SkeletonDataCache:getInstance():preload(skelPath, atlasPath, scale)        
        elseif fileUtils:isFileExist(jsonPath) then
            sp.SkeletonDataCache:getInstance():preload(jsonPath, atlasPath, scale)
        end
    end
end


function load_animation_async(callback, aniDir, scale, timeScale)
    local function wrapedCallback(ani)
        if ani and not tolua.isnull(ani) then
            ani:setTimeScale(timeScale)
        end
        callback(ani)
    end

    local fileUtils = cc.FileUtils:getInstance()
    local libpath = require("tool.lib.path")

    local redirectFile = libpath.join(aniDir, "redirect.txt")
    if fileUtils:isFileExist(redirectFile) then
        local redirectTo = fileUtils:getStringFromFile(redirectFile)
        aniDir = libpath.normpath(libpath.join(aniDir, redirectTo))
        CCLog(vardump({redirectTo = redirectTo, aniDir = aniDir}, "load_animation_async"))
    end    

    scale = scale or 1
    local jsonPath  = libpath.join(aniDir, "skeleton.json")
    local skelPath  = libpath.join(aniDir, "skeleton.skel")
    local atlasPath = libpath.join(aniDir, "skeleton.atlas")
    local imagePath = libpath.join(aniDir, "skeleton.pvr.ccz")
    if not fileUtils:isFileExist(imagePath) then
        imagePath = libpath.join(aniDir, "skeleton.png")
    end
    
    if fileUtils:isFileExist(atlasPath) then       
        local aniArgs = nil
        if fileUtils:isFileExist(skelPath) then
            aniArgs = {skeleton = skelPath, atlas = atlasPath, scale = scale}
        elseif fileUtils:isFileExist(jsonPath) then
            aniArgs = {skeleton = jsonPath, atlas = atlasPath, scale = scale}
        end

        if aniArgs ~= nil and fileUtils:isFileExist(imagePath) then
            cc.TextureCache:getInstance():addImageAsync(imagePath, function(texture)  
                if texture then
                    sp.SkeletonAnimationLoader:getInstance():addAnimationAsync(aniArgs, wrapedCallback)
                else
                    callback(nil)
                end
            end)   
            return         
        else
            callback(nil)
            return
        end
    end

    callback(nil)
    return
end

local MixButton = ccui.MixButton

function MixButton:setTitle( text, size, color, outlineSize ,outlineColor)
    self:setTitleFontName(BaseConfig.fontname)
    self:setTitleFontSize(size)
    self:setTitleText(text)

    if color then
        self:setTitleColor(color)
    end
    if outlineSize then
        local label = self:getTitleRenderer()
        local outlinecolor = outlineColor or cc.c4b(0,0,0,255)
        label:enableOutline(outlinecolor, outlineSize)
    end
end

function MixButton:setChild( texture, posx, posy )
    local x = posx or 0.5
    local y = posy or 0.5
    local size = self:getContentSize()
    local child = cc.Sprite:create(texture)
    child:setPosition(size.width*x, size.height*y)
    self:addChild(child)
end

function MixButton:setScale9Size( size )
    self:setScale9Enabled(true)
    self:setContentSize(size)
end

function MixButton:setStateEnabled(value)
    self:setEnabled(value)
    self:setBright(value)
end

--[[
    注意事项: 不能在node:create()， parent:addChild(node)中间调用，这样可能node已经释放了
--]]
function start_texture_coroutine(coro)
    local textureCache = cc.Director:getInstance():getTextureCache()    
    local status, path = coroutine.resume(coro)

    local function async_callback(texture)
        local status, path = coroutine.resume(coro, texture)
        CCLog("load:", status, path, texture)
        if status then
            if path then
                textureCache:addImageAsync(path, async_callback)
            else
                coroutine.resume(coro, nil)
            end
        end
    end
    CCLog("load:", status, path)
    if path == nil then
        CCLog("path is nil:", debug.traceback())
        coroutine.resume(coro, nil)
    else
        textureCache:addImageAsync(path, async_callback)
    end
end

