local BattleMapManager= class("BattleMapManager")

local MAP_TYPE = "lua"

local SceneDir = {
    HORIZONTAL = 0,
    --VERTICAL   = 1,
    UPWARD = 1,
    DOWNWARD = 2,
}

function BattleMapManager:ctor(mapName, nearNode, middleNode, farNode)
    self.mapName = mapName
    self.nearNode = nearNode
    self.middleNode = middleNode
    self.farNode = farNode

    self.farView = nil
    self.middleView = nil
    self.nearView = nil

    self.roundOffsetPercent = {}

    self.data = {}
    self.sprites = {}
    self.scrollView = nil

    self.inited = false

    self.loadingProgress = function(percent) end
end

function BattleMapManager:setLoadingCallback(callback)
    self.loadingProgress = callback
end

function BattleMapManager:unscheduleLoadMap()
    if self.scheduleEntryID ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        CCLog("scheduler:unscheduleScriptEntry(", self.scheduleEntryID, ")")
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end
end

function BattleMapManager:scheduleLoadMap()
    if tolua.isnull(self) then
        CCLog(debug.traceback())
        return
    end

    local scheduler = cc.Director:getInstance():getScheduler()

    if self.scheduleEntryID ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduleEntryID)
        self.scheduleEntryID = nil
    end

    local updateFunc = function()
        coroutine.resume(self._load_thread)
    end

    local scheduleEntryID = scheduler:scheduleScriptFunc(updateFunc, 1.0 / 60, false)
    self.scheduleEntryID = scheduleEntryID
end

function BattleMapManager:hideOutOfRegion()
    local screenWidth = display.width
    local screenHight = display.height

    local count = 0
    for _, sprite in ipairs(self.sprites) do        
        local box = sprite:getBoundingBox()

        local parent = sprite:getParent()
        local lbPos = parent:convertToWorldSpace(cc.p(box.x, box.y))
        local rtPos = parent:convertToWorldSpace(cc.p(box.x + box.width, box.y + box.height))
        local left = lbPos.x
        local bottom = lbPos.y
        local top = rtPos.x
        local right = rtPos.y

        if left > screenWidth or right < 0 or bottom > screenHight or top < 0 then
            sprite:setVisible(false)
            count = count + 1
        end 

        --CCLog(vardump({box = box, worldPos = worldPos, left = left, right = right, top = top, bottom = bottom, right = right, hide = left > screenWidth or right < 0 or bottom > screenHight or top < 0 }, "sprite region"))
    end
    CCLog("BattleMapManager:hideOutOfRegion()", count)
end

function BattleMapManager:resetHide()
    for _, sprite in ipairs(self.sprites) do
        sprite:setVisible(true)
    end
end

function BattleMapManager:loadMap(completeCallback)
    local mapName = self.mapName
    CCLog("BattleMapManager:loadMap:", mapName)

    local mapData

    if MAP_TYPE == "json" then
        local mapJsonPath = mapName and string.format("image/map/json/%s.json", mapName) or "image/map/json/LG_map.json"

        if not cc.FileUtils:getInstance():isFileExist(mapJsonPath) then
            CCLog(mapJsonPath, "not found, use image/map/json/SLYS_map.json")
            mapJsonPath = "image/map/json/SLYS_map.json"
        end

        local jsData = cc.FileUtils:getInstance():getStringFromFile(mapJsonPath)
        mapData = json.decode(jsData)
    elseif MAP_TYPE == "lua" then
        local mapLuaPath = mapName and string.format("image/map/lua/%s.lua", mapName) or "image/map/lua/LG_map.lua"

        local status
        status, mapData = pcall(require, mapLuaPath)
        if not status then
            status, mapData = pcall(require, "image/map/lua/SLYS_map.lua")
        end

        mapData = require(mapLuaPath)
        package.loaded[mapLuaPath] = nil -- clear module cache
    end

    local header = mapData.Header
    local body = mapData.Body

    local function calc_comp_count(body)
        local count = 0
        for _, scene in ipairs(body.scenes) do
            for _, region in ipairs(scene.regions) do
                count = count + #region.components
            end
        end

        return count
    end
    self.totalCompCount = calc_comp_count(body)
    self.loadCompCount = 0

    self.header = header

    CCLog("Map Header:", vardump(header))
    -- TODO:
    if header.sceneDir == nil then
        header.sceneDir = SceneDir.HORIZONTAL
    end

    self.loadViewCount = 0
    local function load_callback(name)
        self.loadViewCount = self.loadViewCount + 1
        print("load map view", name, "complete", self.loadViewCount)

        if self.loadViewCount == 3 then
            self:init()
            completeCallback()
            print("load map complete")
        end
    end

    local mapDir = "image/map/"

    local farView = self:loadMapLayer(header, body, mapDir, "far", self.farNode, "farView", load_callback)
    -- self.farNode:addChild(farView, -1)
    -- self.farView = farView

    local middleView = self:loadMapLayer(header, body, mapDir, "mid", self.middleNode, "middleView", load_callback)
    -- self.middleNode:addChild(middleView, -1)
    -- self.middleView = middleView

    local nearView = self:loadMapLayer(header, body, mapDir, "near", self.nearNode, "nearView", load_callback)
    -- self.nearNode:addChild(nearView, -1)
    -- self.nearView = nearView
end

function BattleMapManager:init()
    if self:isHorizontal() then
        self.roundOffsetPercent[1] = 0.333
        self.roundOffsetPercent[2] = 0.666
        self.roundOffsetPercent[3] = 1.0
    elseif self:isUpWard() then
        CCLog("jump to buttom")
        self.farView:jumpToBottom()
        self.middleView:jumpToBottom()
        self.nearView:jumpToBottom()

        self.roundOffsetPercent[1] = 0
        self.roundOffsetPercent[2] = 0.5
        self.roundOffsetPercent[3] = 1.0
    elseif self:isDownWard() then
        self.roundOffsetPercent[1] = 0
        self.roundOffsetPercent[2] = 0.5
        self.roundOffsetPercent[3] = 1.0
    end

    self.inited = true
end

function BattleMapManager:isInited()
    return self.inited
end

function BattleMapManager:setRoundOffsetPercent(roundIndex, percent)
    self.roundOffsetPercent[roundIndex] = percent
    CCLog(vardump({self.roundOffsetPercent}, "setRoundOffsetPercent"))
end

function BattleMapManager:getRoundOffsetPercent(roundIndex)
    CCLog(vardump({self.roundOffsetPercent}, "getRoundOffsetPercent"))
    return self.roundOffsetPercent[roundIndex]
end

function BattleMapManager:getMiddleLayer()
    local parallaxNode = self.middleView:getChildByName("parallaxNode")
    local layer = parallaxNode:getChildByName("mid")
    return layer
end

function BattleMapManager:getNearLayer()
    local parallaxNode = self.nearView:getChildByName("parallaxNode")
    local layer = parallaxNode:getChildByName("near")
    return layer
end

function BattleMapManager:getFarLayer()
    local parallaxNode = self.farView:getChildByName("parallaxNode")
    local layer = parallaxNode:getChildByName("far")
    return layer
end

function BattleMapManager:getMapSize()
    return self.middleView:getInnerContainerSize()
end

function BattleMapManager:getScrollableWidth()
    local innerSize = self.farView:getInnerContainerSize()
    local contentSize = self.farView:getContentSize()
    return innerSize.width - contentSize.width
end

function BattleMapManager:getScrollableHeight()
    local innerSize = self.farView:getInnerContainerSize()
    local contentSize = self.farView:getContentSize()
    return innerSize.height - contentSize.height
end

function BattleMapManager:getRoundOffset(roundIndex)
    if self:isHorizontal() then
        local width = self:getScrollableWidth()
        local percent = self:getRoundOffsetPercent(roundIndex)
        local offsetX = width * percent
        return cc.p(offsetX, 0)
    elseif self:isVertical() then
        local height = self:getScrollableHeight()
        local percent = self:getRoundOffsetPercent(roundIndex)
        local offsetY = height * percent
        return cc.p(0, offsetY)
    else
        assert(0, "示知地图方向")
    end
end

function BattleMapManager:getPercentHorizontal()
    local width = self:getScrollableWidth()
    local innerContainer = self.farView:getInnerContainer()
    local posX = innerContainer:getPositionX()

    local percent = posX * 1.0 / width
    return -percent
end

function BattleMapManager:getPercentUpWard()
    local height = self:getScrollableHeight()
    local innerContainer = self.farView:getInnerContainer()
    local posY = innerContainer:getPositionY()

    local percent = 1.0 - (posY + height) / height
    CCLog("BattleMapManager:getPercentUpWard()", vardump({height = height, posY = posY, percent = percent}))
    return percent
end

function BattleMapManager:getPercentDownWard()
    local height = self:getScrollableHeight()
    local innerContainer = self.farView:getInnerContainer()
    local posY = innerContainer:getPositionY()

    local percent = (height + posY) * 1.0 / height
    CCLog("BattleMapManager:getPercentDownWard()", vardump({height = height, posY = posY, percent = percent}))
    return percent
end

function BattleMapManager:getPercent()
    if self:isHorizontal() then
        return self:getPercentHorizontal()
    elseif self:isUpWard() then
        return self:getPercentUpWard()
    elseif self:isDownWard() then
        return self:getPercentDownWard()
    else
        assert(0, "示知地图方向")
    end
end

function BattleMapManager:isHorizontal()
    return self.header.sceneDir == SceneDir.HORIZONTAL
end

function BattleMapManager:isVertical()
    return self.header.sceneDir == SceneDir.UPWARD or self.header.sceneDir == SceneDir.DOWNWARD
end

function BattleMapManager:isUpWard()
    return self.header.sceneDir == SceneDir.UPWARD
end

function BattleMapManager:isDownWard()
    return self.header.sceneDir == SceneDir.DOWNWARD
end

function BattleMapManager:scrollToPercentHorizontal(percent, time)
    self.farView:scrollToPercentHorizontal(percent, time, false)
    self.middleView:scrollToPercentHorizontal(percent, time, false)
    self.nearView:scrollToPercentHorizontal(percent, time, false)
end

function BattleMapManager:scrollToPercentUpWard(percent, time)
    self.farView:scrollToPercentVertical(100.0 - percent, time, false)
    self.middleView:scrollToPercentVertical(100.0 - percent, time, false)
    self.nearView:scrollToPercentVertical(100.0 - percent, time, false)
end

function BattleMapManager:scrollToPercentDownWard(percent, time)
    self.farView:scrollToPercentVertical(percent, time, false)
    self.middleView:scrollToPercentVertical(percent, time, false)
    self.nearView:scrollToPercentVertical(percent, time, false)
end

function BattleMapManager:scrollToPercent(percent, time)
    CCLog("BattleMapManager:scrollToPercent(", percent, ", ", time, ")")

    if self:isHorizontal() then
        self:scrollToPercentHorizontal(percent, time)
    elseif self:isUpWard() then
        self:scrollToPercentUpWard(percent, time)
    elseif self:isDownWard() then
        self:scrollToPercentDownWard(percent, time)
    else
        assert(false, "未知地图方向")
    end
end

function BattleMapManager:jumpToPercentHorizontal(percent, time)
    self.farView:jumpToPercentHorizontal(percent)
    self.middleView:jumpToPercentHorizontal(percent)
    self.nearView:jumpToPercentHorizontal(percent)
end

function BattleMapManager:jumpToPercentVertical(percent, time)
    if self:isUpWard() then
        self.farView:jumpToPercentVertical(100.0 - percent)
        self.middleView:jumpToPercentVertical(100.0 - percent)
        self.nearView:jumpToPercentVertical(100.0 - percent)
    else
        self.farView:jumpToPercentVertical(percent)
        self.middleView:jumpToPercentVertical(percent)
        self.nearView:jumpToPercentVertical(percent)
    end
end

function BattleMapManager:jumpToPercent(percent, time)
    if self:isHorizontal() then
        self:jumpToPercentHorizontal(percent, time)
    elseif self:isVertical() then
        self:jumpToPercentVertical(percent, time)
    else
        assert(false, "未知地图方向")
    end
end

function BattleMapManager:loadMapLayer(header, body, mapDir, layerName, parentNode, viewName, callback)
    local libpath = require("tool.lib.path")
    local scrollView = ccui.ScrollView:create()
    --scrollView:setDirection(ccui.ScrollViewDir.both)
    scrollView:setDirection(self:isHorizontal() and ccui.ScrollViewDir.horizontal or ccui.ScrollViewDir.vertical)
    scrollView:setInnerContainerSize(cc.size(header.sceneSize.width * header.sceneCount, header.sceneSize.height))
    scrollView:setContentSize(cc.size(display.width, display.height))
    scrollView:setClippingEnabled(true)
    scrollView:setTouchEnabled(false)

    parentNode:addChild(scrollView, -1)
    self[viewName] = scrollView

    local parallaxNode = cc.ParallaxNode:create()
    local mapSize = cc.size(header.sceneSize.width * header.sceneCount, header.sceneSize.height)
    parallaxNode:setContentSize(mapSize)
    parallaxNode:setName("parallaxNode")
    scrollView:getInnerContainer():addChild(parallaxNode)

--    local rationsX = {far = 0.8, mid = 1, near = 1.2 }
--    local function speed(velocity)
--        return (80 + velocity * 2) / 100
--    end
    -- cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
    
    local coro = coroutine.create(function()
        local textureCache = cc.Director:getInstance():getTextureCache()
        for sceneIdx, scene in ipairs(body.scenes) do
            local baseX = header.sceneSize.width * (sceneIdx - 1)
            for regionIdx, region in ipairs(scene.regions) do
                if string.find(region.name, layerName) then
                    local regionLayer= cc.Layer:create()
                    regionLayer:setPosition(cc.p(baseX, 0))
                    regionLayer:setContentSize(cc.size(region.size.width, region.size.height))
                    regionLayer:setName(region.name)
                    --local rationX =  rationsX[region.name]
                    --CCLog("ration ", regionIdx, region.name, ":", rationX)
                    --parallaxNode:addChild(regionLayer, region.z, cc.p(rationX, 1), cc.p(0, 0))
                    parallaxNode:addChild(regionLayer, region.z, cc.p(region.velocity, region.velocity), cc.p(0, 0))

                    if region.name == "far" and region.z ~= 0 then
                        regionLayer:setLocalZOrder(-1000)
                        regionLayer:setGlobalZOrder(-1000)
                    elseif region.name == "near" and region.z ~= 0 then
                        regionLayer:setLocalZOrder(-1000)
                        regionLayer:setGlobalZOrder(1000)
                    end

                    for _, comp in ipairs(region.components) do                        
                        --CCLog("comp:", mapDir, vardump(comp))
                        if comp.isEffect then
                            local path = libpath.join(mapDir, "effect", comp.image)
                            
                            local ani = assert(load_animation(path), path)
                            ani:setPosition(baseX + comp.position.x, comp.position.y)
                            ani:setScale(comp.scale)
                            ani:setLocalZOrder(comp.z)
                            if comp.flipX then
                                ani:setRotationSkewX(180)
                            end

                            if comp.flipY then
                                ani:setRotationSkewY(180)
                            end
                            ani:setAnimation(0, "animation", true)
        
                            regionLayer:addChild(ani)
                        else
                            local path = libpath.join(mapDir, "image", comp.image)
                            --print("path:", path)

                            local sprite = assert(cc.Sprite:createWithTexture(coroutine.yield(path)), path)
                            sprite:setPosition(baseX + comp.position.x, comp.position.y)
                            sprite:setScale(comp.scale)
                            sprite:setLocalZOrder(comp.z)
                            sprite:setFlippedX(comp.flipX)
                            sprite:setFlippedY(comp.flipY)
                            regionLayer:addChild(sprite)

                            table.insert(self.sprites, sprite)
                        end     

                        self.loadCompCount = self.loadCompCount + 1            
                        self.loadingProgress(self.loadCompCount * 100 / self.totalCompCount)   
                    end
                end
            end
        end

        coroutine.yield(nil)

        callback(layerName)
    end)

    start_texture_coroutine(coro)
    -- cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    return scrollView
end

return BattleMapManager