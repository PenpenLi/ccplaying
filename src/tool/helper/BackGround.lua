local BackGround = class("BackGround", BaseLayer)

local MAX_MAP_WIDTH = 1136



function BackGround:ctor(fillPath)
   BackGround.super.ctor(self)
   local js = cc.FileUtils:getInstance():getStringFromFile(fillPath)
   local cjson = require("cjson")
   local map = json.decode(js)

   self.parallaxNode = cc.ParallaxNode:create()
   local far_view = cc.Node:create()
   local middle_view = cc.Node:create()
   local near_view = cc.Node:create()
   local current_scene = 1
   local next_scene = current_scene + 1
   local middle_velocity = 0
   local far_velocity = 0
   local near_velocity = 0
   for i = current_scene,next_scene do
       for j = 1,#map.Body.scenes[i].regions do 
           local temp_name = map.Body.scenes[i].regions[j].name
           local temp_z = map.Body.scenes[i].regions[j].z
           local temp_velocity = map.Body.scenes[i].regions[j].velocity
           if temp_name == "far_view" then
                  far_view:setLocalZOrder(temp_z)                 
           elseif temp_name == "middle_view" then
                  middle_view:setLocalZOrder(temp_z)                
           else
                  near_view:setLocalZOrder(temp_z)                 
           end
           for k = 1,#map.Body.scenes[i].regions[j].components do
               local bg = cc.Sprite:create("Map" .. map.Body.scenes[i].regions[j].components[k].image)
               local offx = map.Body.scenes[i].regions[j].components[k].position.x
               local offy = map.Body.scenes[i].regions[j].components[k].position.y
               if i >= 2 then 
                 bg:setPosition(offx + 1136, offy)
               else
                 bg:setPosition(offx, offy)
               end
               if temp_name == "far_view" then
                  far_view:addChild(bg)
                  far_velocity = temp_velocity 
               end
               if temp_name == "middle_view" then
                  middle_view:addChild(bg)
                  middle_velocity = temp_velocity
               end
               if temp_name == "near_view" then
                  near_view:addChild(bg)
                  near_velocity = temp_velocity
               end
              
           end
       end
   end
   
   local far_ratio = middle_velocity * far_velocity
   local near_ratio = middle_velocity * near_velocity
   
   while far_ratio > 1 do
         far_ratio = far_ratio / 10
   end
   
   while near_ratio > 1 do
         near_ratio = near_ratio / 10
   end

   self.parallaxNode:setContentSize(CCSize(MAX_MAP_WIDTH * 2, 640))
   self.parallaxNode:addChild(far_view, 0, cc.p(far_ratio, 1), cc.p(0, 0))
   self.parallaxNode:addChild(middle_view, 0, cc.p(1, 1), cc.p(0, 0))
   self.parallaxNode:addChild(near_view, 0, cc.p(near_ratio, 1), cc.p(0, 0))

   self.parallaxNode:setPosition(0, 0)
   self:addChild(self.parallaxNode)
end

function BackGround:pushFigure()
    self.parallaxNode:runAction(cc.MoveBy:create(10,cc.p(-MAX_MAP_WIDTH,0)))
end

return BackGround