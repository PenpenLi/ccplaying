local MapParallaxLayer = class("MapParallaxLayer", BaseLayer)

function MapParallaxLayer:ctor()
    local js = cc.FileUtils:getInstance():getStringFromFile("dummy/Map/json/compoent.json")
    local cjson = require("cjson")
    local map = cjson.decode(js)

    local  voidNode = cc.ParallaxNode:create()

    local scene_count = map.Header.sceneCount
    local scene_width = map.Header.sceneSize.width
    local scene_height = map.Header.sceneSize.height

    for i = 1, scene_count do
        for j = 1, #map.Body.scenes[i].regions do
            local view = cc.Node:create()
            local zorder = map.Body.scenes[i].regions[j].z
            view:setLocalZOrder(zorder)
            local velocity = map.Body.scenes[i].regions[j].velocity
            for k = 1, #map.Body.scenes[i].regions[j].components do
                local sprite = cc.Sprite:create("dummy/Map/image/" .. map.Body.scenes[i].regions[j].components[k].image)
                local offx = map.Body.scenes[i].regions[j].components[k].position.x
                local offy = map.Body.scenes[i].regions[j].components[k].position.y
                sprite:setPosition(offx + (i-1)*scene_width, offy)
                view:addChild(sprite)
            end
            voidNode:addChild(view, 0, cc.p(velocity, 1), cc.p(0,0))
        end
    end

    local  go = cc.MoveBy:create(22.72, cc.p(-3408,0) )
    local  goBack = go:reverse()
    local  seq = cc.Sequence:create( go, goBack)
    voidNode:runAction( (cc.RepeatForever:create(seq) ))

    voidNode:setContentSize(cc.size(scene_count * scene_width, scene_height))
    self:addChild(voidNode)
end

function MapParallaxLayer:onCleanup()
    if self.data.deaccelerateScrollingEntryID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.data.deaccelerateScrollingEntryID)
        self.data.deaccelerateScrollingEntryID = nil
    end
end

return MapParallaxLayer