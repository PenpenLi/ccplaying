--
-- Author: keyring
-- Date: 2014-11-29 14:27:24
--

local LoadingLayer = class("LoadingLayer", BaseLayer)

function LoadingLayer:ctor(scene, ...)
    self.tectureTotal = 0
    self.textureCount = 0
    self.scene = scene
    self.params = {...}
    
    self.percent = 0
end

function LoadingLayer:onEnter()
    -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    self:setupUI()
end

function LoadingLayer:update(delta)
	-- CCLog("hehe")
end


function LoadingLayer:setupUI()
	local bg_sprite = cc.Sprite:create("image/ui/loading/loadingbg_1.jpg")
    -- bg_sprite:setAnchorPoint(0,0)

    bg_sprite:setScale()
    bg_sprite:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self:addChild(bg_sprite)
    local size = bg_sprite:getContentSize()
    local scaleX = SCREEN_WIDTH / size.width
    local scaleY = SCREEN_HEIGHT / size.height
    bg_sprite:setScaleX(scaleX)
    bg_sprite:setScaleY(scaleY)

    local sprite = cc.Sprite:create("image/ui/loading/loading_2.png")
    sprite:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.3)
    self:addChild(sprite)

    local barback = cc.Sprite:create("image/ui/loading/loading_4.png")
    barback:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.2)
    self:addChild(barback)

    local expbar = ccui.LoadingBar:create("image/ui/loading/loading_3.png")
    expbar:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.2)
    self.bar = expbar
    self.bar:setPercent(1)
    self:addChild(expbar)

	local co = coroutine.create(function ( percent )
		repeat
			self.bar:setPercent(percent)
			coroutine.yield()
		until percent==100
		
	end)

    table.insert(self.params, co)

    local delay = cc.DelayTime:create(2)
    local event = cc.CallFunc:create(function ( )
        
        application:replaceScene(self.scene, unpack(self.params))
    end)
    self:runAction(cc.Sequence:create({delay,event}))
    -- self:loadMapData(self.params[1].map)
end

function LoadingLayer:loadMapData(mapName)
    CCLog("LoadingLayer:loadMap:", mapName)
    local mapJsonPath = mapName and string.format("image/map/json/%s.json", mapName) or "image/map/json/LG_map.json"

    if not cc.FileUtils:getInstance():isFileExist(mapJsonPath) then
        mapJsonPath = "image/map/json/LG_map.json"
    end

    local jsData = cc.FileUtils:getInstance():getStringFromFile(mapJsonPath)
    local mapData = json.decode(jsData)

    local body = mapData.Body

    for sceneIdx, scene in ipairs(body.scenes) do
        for regionIdx, region in ipairs(scene.regions) do
            self.tectureTotal = self.tectureTotal + #region.components
        end
    end

    local mapImgPath = "image/map/image/"
    self:loadMapTexture(body, mapImgPath)

end

function LoadingLayer:loadMapTexture(body, imageDir)
    local cache = cc.Director:getInstance():getTextureCache()
    for sceneIdx, scene in ipairs(body.scenes) do
        for regionIdx, region in ipairs(scene.regions) do
            for _, comp in ipairs(region.components) do
                local path = imageDir .. comp.image
                cache:addImageAsync(path, function (  )
                	self.textureCount = self.textureCount + 1
                	local percent = self.textureCount/self.tectureTotal * 100
                	self.bar:setPercent(percent)
                	if percent == 100 then
                		local delay = cc.DelayTime:create(0.1)
        				local event = cc.CallFunc:create(function ( )
                            -- application:popScene()
                            -- application:pushScene(self.scene, unpack(self.params))
            				application:replaceScene(self.scene, unpack(self.params))
        				end)
        				self:runAction(cc.Sequence:create({delay,event}))
                		
                	end
                	
                end)
            end
        end
    end
end


function LoadingLayer:onExit()

end


function LoadingLayer:onEnterTransitionFinish()
    
end

return LoadingLayer