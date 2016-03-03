local FightingView = class("FightingView",BaseLayer)

local MAX_SCREEN_GRID_X = 21
local MAX_SCREEN_GRID_Y = 14
local wGrid = display.widthInPixels / MAX_SCREEN_GRID_X
local hGrid = display.heightInPixels / MAX_SCREEN_GRID_Y
local gridSwitch = false

--TODO:人物受到攻击的抖动效果 后续会整理修改
local function shakeAction(distanceX)
    local action = cc.Sequence:create({cc.MoveBy:create(0.1, cc.p(distanceX, 0)), cc.MoveBy:create(0.1, cc.p(-distanceX, 0))})
    return cc.EaseBounceOut:create(action)
end

--视图模块 只做视图的处理 
function FightingView:ctor(ui,heroModel)--@return typeOrObject
    FightingView.super.ctor(self)
    self.container = cc.Node:create()
--    self.grid ={}
    self.draw_scope = {}
	self.ui = ui
	self.heroModel = heroModel
	self.dhp = 0
	self.pos = {x = 0, y = 0}
	self.heroScope = DummyData.AttackRangeBaseConfig[self.heroModel:getId()]
	--CCLog("---- row debug -----" .. self.pos.row)
	self.sprite = nil
	
    self:heroScopeTransform()
    self:setSprite()
	self:addChild(self.container)
	
	local cls = self.heroModel.class
	self.heroModel:addEventListener(cls.CHANGE_STATE_EVENT, function (event) 
	    self:updateSprite(self.heroModel:getState())
	end)
	self.heroModel:addEventListener(cls.MOVE_EVENT,function (event) --@return typeOrObject
	--XXX:回调造成的卡顿 移动到controller部分 实现更好的控制
        local moveto = cc.MoveBy:create(1,cc.p(self.pos.x * wGrid,self.pos.y * hGrid))
        local torest = cc.CallFunc:create(function()
              self.heroModel:rest()
              self:heroScopeTransform()           
        end) 
        local seqence = cc.Sequence:create(moveto,torest)
        self.sprite:runAction(seqence)
	end)
	--TODO:血条的建立 后续会添加修改
--	  self.bgleft = cc.Sprite:create("images/common/green.png")
--    self.bgleft:setScale(0.3)
--    self.bgleft:setAnchorPoint(0.5, 0.5)
--    self.container:addChild(self.bgleft)
--    self.left = cc.ProgressTimer:create(cc.Sprite:create("images/common/red.png"))
--    self.left:setAnchorPoint(0.5, 0.5)
--    self.left:setScale(0.3)
--    self.container:addChild(self.left)
      
end

--建立并导入骨骼 
function FightingView:setSprite() --@return typeOrObject

	self.sprite = sp.SkeletonAnimation:create("images/spine/sp" .. self.heroModel:getId() .. "/skeleton.json", "images/spine/sp" .. self.heroModel:getId() .. "/skeleton.atlas", 1)
	--self.sprite:setTimeScale(0.2)
    self.sprite:setSkin("Normal")
    self.sprite:setToSetupPose()
    self.sprite:setPosition(0,0)
    self.sprite:setMix("walk","stand",0.2)
    self.sprite:setMix("stand", "walk", 0.2)
    self.sprite:addAnimation(0, "stand", true)
    self.sprite:setScale(0.25)
    self.sprite:setLocalZOrder(20)
    if self.heroModel:getEid() >= 1000 then
       self.sprite:setRotationSkewY(180)
    end
    self.container:addChild(self.sprite)
    
end

function FightingView:updateSprite(state) --@return typeOrObject
	if state == "idle" or "attackable" then
	   self.sprite:addAnimation(0, "stand", true)
	   self.sprite:setTimeScale(0.4)
	end
	if state == "disappear" then
	   self.sprite:removeFromParent(true)
	end
	if state == "run" then
	   self.sprite:addAnimation(0, "walk", true)
       self.sprite:setTimeScale(0.7)

	end
	if state == "attack" then
       self.sprite:addAnimation(0, "attack", false)
       self.sprite:setTimeScale(0.5)
    end
end

function FightingView:setShake() --@return typeOrObject
	local shakeDistance = display.widthInPixels / MAX_SCREEN_GRID_X / 2
    self.sprite:runAction(shakeAction(self.heroModel:getEid() < 1000 and shakeDistance or -shakeDistance))
end

--TODO:以下两个函数用于接受临时的视图数据变量
function FightingView:setDhp(dhp) --@return typeOrObject
	self.dhp = dhp
end

function FightingView:setMovePos(pos) --@return typeOrObject
    self.pos = pos
end

--人物攻击范围视图生成
function FightingView:heroScopeTransform()

   local array = {}
   for i, v in ipairs(self.heroScope) do
     --TODO:这个判断函数会继续加强特征 后续会改换
       if self.heroModel:getEid() < 1000 then
          array[i] = { x = self.pos.x + v[1], y = self.pos.y + v[2]}
       else
          array[i] = { x = self.pos.x - v[1] , y = self.pos.y - v[2]}
       end
   end

   self.draw_scope = self.draw_scope or {}

   if #self.draw_scope > 0 then
      for i = 1, #self.draw_scope do
          self.container:removeChild(self.draw_scope[i])
      end
      self.draw_scope = {}
   end
       
       
   if gridSwitch then
      for i = 1, #array do
          local x = wGrid / 2 + (array[i].x - 1) * wGrid
          local y = hGrid / 2 + (array[i].y - 1) * hGrid
          local rect = {cc.p(0,hGrid),cc.p(wGrid,hGrid),cc.p(wGrid,0), cc.p(0,0)}
          local color = cc.c4f(1.0, 0.0, 1.0, 0.3)
          self.draw_scope[i] = cc.DrawNode:create()
          self.draw_scope[i]:drawPolygon(rect,4,color,0,color)
          self.draw_scope[i]:setPosition(x,y)
          self.draw_scope[i]:setLocalZOrder(10)
          self.container:addChild(self.draw_scope[i])
      end
   end
   
end

function FightingView:moveUp() --@return typeOrObject
    CCLog("SCENE TEST=======" ..  self.heroModel:getState())
    if self.ui.sceneOrder <= self.ui.sceneCount - 1 then
	   local moveto = cc.MoveBy:create(1,cc.p(0,700))
	   local fadeout = cc.FadeOut:create(0.5)
	   local fadein = cc.FadeIn:create(0.5)
	   local seq = cc.Sequence:create(fadeout,fadein)
	   local spa = cc.Spawn:create(moveto,seq)
	   local todown = cc.CallFunc:create(function()
             self:moveDown()        
       end) 
       local sequence = cc.Sequence:create(spa,todown)
	   self.sprite:runAction(sequence)
    end
end

function FightingView:moveDown() --@return typeOrObject
    CCLog("-----hero down-----:" .. self.heroModel:getEid())
	local oldX = self.heroModel:getPos().x
	local oldY = self.heroModel:getPos().y
	local newY = self.ui.bzList[self.heroModel:getEid() + 14].y
    local newX = self.ui.bzList[self.heroModel:getEid() + 14].x
    local distance = (newX - oldX) * wGrid
    local moveto = cc.MoveBy:create(1,cc.p(distance,-700 + (newY - oldY)* hGrid))
    local fadeout = cc.FadeOut:create(0.5)
    local fadein = cc.FadeIn:create(0.5)
    local seq = cc.Sequence:create(fadeout,fadein)
    local spa = cc.Spawn:create(moveto,seq)
    local toback = cc.CallFunc:create(function()
          self:moveBack()   
          if self.heroModel == self.ui.heros[#self.ui.heros].model then
             self.ui.bg:pushFigure()
          end     
    end) 
    local sequence = cc.Sequence:create(spa,toback)
    self.sprite:runAction(sequence)
    --self.heroModel:setPos(pos)
end

function FightingView:moveBack()
   self.sprite:addAnimation(0, "walk", true)
   self.sprite:setTimeScale(0.4)
   local distance = 12 * wGrid
   local moveto = cc.MoveBy:create(10,cc.p(-distance,0))
   local tostop = cc.CallFunc:create(function()
         self.sprite:addAnimation(0, "stand", true)
         self.sprite:setTimeScale(0.4)
         local newY = self.ui.bzList[self.heroModel:getEid() + 5].y
         local newX = self.ui.bzList[self.heroModel:getEid() + 5].x
         local pos = {x = newX,y = newY}
         self.heroModel:setPos(pos)
         self.ui.count = self.ui.count + 1
         --self.heroModel:rest()
         CCLog("ALL:" .. #self.ui.heros .. "NOW" .. self.ui.count)
         CCLog("STATE TEST:" .. self.heroModel:getState())
         if self.ui.count == #self.ui.heros then
            self.ui:nextScene()
            self.ui.count = 0
         end
        
   end) 
   local sequence = cc.Sequence:create(moveto,tostop)
    self.sprite:runAction(sequence)
end

return FightingView