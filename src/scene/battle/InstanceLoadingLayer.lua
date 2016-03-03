--
-- Author: keyring
-- Date: 2014-11-29 14:27:24
--

local LoadingLayer = class("LoadingLayer", BaseLayer)

function LoadingLayer:ctor(nodeInfo)
    self.tectureTotal = 0
    self.textureCount = 0
    self.nodeInfo = nodeInfo

    self.percent = 0

    self:setupUI()
end

function LoadingLayer:onEnter()
    
end

function LoadingLayer:onExit()

end

function LoadingLayer:onUpdate(delta)

end


function LoadingLayer:setupUI()
    local mapname = self.nodeInfo.map
    local _ = string.find(mapname, "_")
    if _ then
        mapname = string.sub(mapname, 1, _-1)
    end
    
    -- print(mapname)
    local path = "image/instance/"..mapname .. ".jpg"
	local bg_sprite = cc.Sprite:create(path)
    if bg_sprite then
        bg_sprite:setScale(2)
        bg_sprite:setPosition(display.cx, display.cy)
        self:addChild(bg_sprite)
    end

    self.visibleNode = cc.Node:create()
    self:addChild(self.visibleNode)

    local spriteHalo = cc.Sprite:create("image/ui/img/btn/btn_843.png")
    spriteHalo:setPosition(display.cx, display.cy + 100)
    spriteHalo:setScale(5)
    self.visibleNode:addChild(spriteHalo)

    local spriteBoard = cc.Sprite:create("image/ui/img/btn/btn_1078.png")
    spriteBoard:setAnchorPoint(cc.p(0.07, 0.5))
    spriteBoard:setPosition(display.cx - 248, display.cy + 175)
    spriteBoard:setRotation(350)
    self.visibleNode:addChild(spriteBoard)

    self.board = spriteBoard

    local spriteWhiteBoard = cc.Sprite:create("image/ui/img/btn/btn_1079.png")
    spriteWhiteBoard:setPosition(display.cx, 320)
    self.visibleNode:addChild(spriteWhiteBoard)

    local labelChapter = Common.finalFont(string.format("第%d季", self.nodeInfo.chapterID), 0 , 0 , 24, cc.c3b(70, 74, 75), nil)
    labelChapter:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER) 
    labelChapter:setColor(cc.c3b(70, 74, 75))
    labelChapter:setPosition(cc.p(display.cx - 230, display.cy + 81))
    labelChapter:setAnchorPoint(cc.p(0, 0.5))
    self.visibleNode:addChild(labelChapter)

    local labelNodeName = Common.finalFont(self.nodeInfo.nodeName, 0 , 0 , 22, cc.c3b(70, 74, 75), nil)
    labelNodeName:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelNodeName:setColor(cc.c3b(240, 139, 84))
    labelNodeName:setPosition(cc.p(display.cx + 100, display.cy + 81))
    labelNodeName:setAnchorPoint(cc.p(0, 0.5))
    self.visibleNode:addChild(labelNodeName)


    local labelStory = Common.finalFont("" .. self.nodeInfo.story, 0 , 0 , 19, cc.c3b(70, 74, 75), nil)
    labelStory:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelStory:setDimensions(400, 200)

    labelStory:setColor(cc.c3b(123, 132, 134))
    labelStory:setPosition(cc.p(display.cx + 8, display.cy - 40))
    labelStory:setAnchorPoint(cc.p(0.5, 0.5))
    self.visibleNode:addChild(labelStory)

    local clippingNode = cc.ClippingRectangleNode:create(cc.rect(display.cx - 780 / 2,  60 - 79 / 2, 780, 79))
    self:addChild(clippingNode)

    local progressNode = cc.Node:create()
    progressNode:setContentSize(cc.size(780, 79))
    progressNode:setPosition(display.cx, 60)
    clippingNode:addChild(progressNode)

    local spriteProgress1 = cc.Sprite:create("image/ui/img/btn/btn_1083.png")
    spriteProgress1:setPosition(display.cx, 60)
    clippingNode:addChild(spriteProgress1)

    local spriteProgress2 = cc.Sprite:create("image/ui/img/btn/btn_1083.png")
    spriteProgress2:setPosition(display.cx - 780, 60)
    clippingNode:addChild(spriteProgress2)

    local spriteProgress3 = cc.Sprite:create("image/ui/img/btn/btn_1083.png")
    spriteProgress3:setPosition(display.cx - 780 * 2, 60)
    clippingNode:addChild(spriteProgress3)

    spriteProgress1:runAction(cc.Sequence:create({
        cc.MoveBy:create(2 * 0.5, cc.p(780 * 0.5, 0)),
        cc.CallFunc:create(function() 
            spriteProgress1:runAction(cc.RepeatForever:create(cc.Sequence:create({
                cc.MoveBy:create(2, cc.p(780, 0)),
                cc.Place:create(cc.p(display.cx - 780, 60)),
                cc.MoveBy:create(4, cc.p(780 * 2, 0)),
            })))
        end),
    }))

    spriteProgress2:runAction(cc.Sequence:create({
        cc.MoveBy:create(2 * 1.5, cc.p(780 * 1.5, 0)),
        cc.CallFunc:create(function() 
            spriteProgress2:runAction(cc.RepeatForever:create(cc.Sequence:create({
                cc.MoveBy:create(2, cc.p(780, 0)),
                cc.Place:create(cc.p(display.cx - 780, 60)),
                cc.MoveBy:create(4, cc.p(780 * 2, 0)),
            })))
        end),
    }))

    spriteProgress3:runAction(cc.Sequence:create({
        cc.MoveBy:create(2 * 2.5, cc.p(781 * 2.5, 0)),
        cc.CallFunc:create(function() 
            spriteProgress3:runAction(cc.RepeatForever:create(cc.Sequence:create({
                cc.MoveBy:create(2, cc.p(780, 0)),
                cc.Place:create(cc.p(display.cx - 780, 60)),
                cc.MoveBy:create(4, cc.p(780 * 2, 0)),
            })))
        end),
    }))

    local spriteRightWheel = cc.Sprite:create("image/ui/img/btn/btn_1080.png")
    spriteRightWheel:setPosition(display.cx + 390 - 50 / 2, 60)
    self:addChild(spriteRightWheel)
    spriteRightWheel:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))

    local spriteLeftWheel1 = cc.Sprite:create("image/ui/img/btn/btn_1081.png")
    spriteLeftWheel1:setPosition(display.cx - 390 + 50 / 2, 60)
    self:addChild(spriteLeftWheel1)
    spriteLeftWheel1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -360)))

    local spriteLeftWheel2 = cc.Sprite:create("image/ui/img/btn/btn_1082.png")
    spriteLeftWheel2:setPosition(display.cx - 390 + 50 / 2, 60)
    self:addChild(spriteLeftWheel2)
    spriteLeftWheel2:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))

    -- self:loadMapData(self.params[1].map)
end

function LoadingLayer:setProgress(progress)
    if not tolua.isnull(self) then
       self.percent = progress

       if progress >= 100 then
            CCLog("setProgress", progress)
            self.board:runAction(cc.EaseElasticOut:create(cc.RotateBy:create(0.8, 10), 0.3))

            local delay = cc.DelayTime:create(0.05)
            local move1 = cc.MoveBy:create(0.05, cc.p(0, -5))
            local move2 = cc.MoveBy:create(0.05, cc.p(0, 8))
            local move3 = cc.MoveBy:create(0.03, cc.p(0, -3))
            self.visibleNode:runAction(cc.Sequence:create(delay, move1, move2, move3))

            self:runAction(cc.Sequence:create({
                cc.DelayTime:create(1.2),
                cc.RemoveSelf:create(),
            }))
        end
    end
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
                cache:addImageAsync(path, function() end)
            end
        end
    end
end

function LoadingLayer:onExit()

end

function LoadingLayer:onEnterTransitionFinish()
    
end

return LoadingLayer