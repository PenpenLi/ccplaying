--本模块是战斗里面最重要的控制模块 针对的对象是单体 参数接受为一个单体 敌方群体 
--
local FightingController = class("HeroController")
local GameObject = require("libs.GameObject")

local MAX_SCREEN_GRID_X = 21
local MAX_SCREEN_GRID_Y = 14
local wGrid = display.widthInPixels / MAX_SCREEN_GRID_X
local hGrid = display.heightInPixels / MAX_SCREEN_GRID_Y

function FightingController:ctor(hero,targets)
     GameObject.extend(self)
     self.hero = hero
     self.targets = targets
     self.target = self.hero
     self.heroScope = DummyData.AttackRangeBaseConfig[self.hero.model:getId()]
     
     local cls = self.hero.model.class
     self.hero.model:addEventListener(cls.REST_EVENT,function(event)
          if #self.targets > 0 then
             if self:judgeScope() and self.target ~= self.hero then
                self.hero.model:ready()
             else
                self:matchTarget()
             end
          else
             if self.hero.model:getEid() < 1000 then 
                self.hero.view:moveUp()
             end
          end
--            self:matchTarget()
--            CCLog("--------REST DEBUG---------------")
     end)

     self.hero.model:addEventListener(cls.CHANGE_HP_EVENT,function(event)
     
     end)
     
     self.hero.model:addEventListener(cls.READY_EVENT,function(event)
--            if self.target.model:getLv1Attr().hp > 0 then
--                self.hero.model:hit()
--            else
--                self.hero.model:rest()
--            end
     end)

     --XXX:移植3.0后本模块逻辑出现问题 正在解决中    
     self.hero.view.sprite:registerSpineEventHandler(function(event)
          if self.hero.model:getState() == "attackable" and event.type == "complete" and event.loopCount >= 1 then
             if self.target.model:getLv1Attr().hp > 0 and self:judgeScope() and self.hero ~= self.target then
                self.hero.model:hit()
             else
                self.hero.model:rest()
             end
          elseif event and event.eventData and event.eventData.name == "attacking" then
             local dhp = self.hero.model:getLv1Attr().atk
             self.target.view:setDhp(dhp)
--             if self.target.view and not tolua.isnull(self.target.view) then
--                self.target.view:setShake()
--             end
             self.target.model:increaseRp()
             self.target.model:decreaseHp(dhp)
             if self.target.model:getLv1Attr().hp <= 0 then
                self.target.model:dead()
                if #self.targets > 0 then
                   for i = 1,#self.targets do
                       if self.targets[i] == self.target then
                          table.remove(self.targets,i)
                       end
                   end
                 end
                 self.target = self.hero
                 self.hero.model:rest()
              else
                 self.hero.model:ready()
              end
           end
     end) 
     self:matchTarget()
end

--仇恨目标匹配
function FightingController:matchTarget() --@return typeOrObject

    self.target = self.hero
    if #self.targets > 0 then
       self.target = self.targets[1]
       local distance = math.abs(self.target.model:getPos().x - self.hero.model:getPos().x)
                      + math.abs(self.target.model:getPos().y - self.hero.model:getPos().y)
       for i = 1,#self.targets do
           local temp = math.abs(self.targets[i].model:getPos().x - self.hero.model:getPos().x)
                      + math.abs(self.targets[i].model:getPos().y - self.hero.model:getPos().y)
           if distance > temp then
               distance = temp
               self.target = self.targets[i]
           end
       end
     self:controllMove()
     else
--         self.hero.model:rest()

         CCLog("----Controller End And Next Scene ---------") 

     end
     
end

--判断攻击范围
function FightingController:judgeScope() --@return typeOrObject
    local array = {}
    for i,v in ipairs(self.heroScope) do
        if self.hero.model:getEid() < 1000 then
           array[i] = { x = self.hero.model:getPos().x + v[1], y = self.hero.model:getPos().y + v[2]}
        else
           array[i] = { x = self.hero.model:getPos().x - v[1], y = self.hero.model:getPos().y - v[2]}
        end
    end
    
    for i = 1,#array do
        if array[i].x == self.target.model:getPos().x and array[i].y == self.target.model:getPos().y then

           return true
        end
    end

    return false
end

--控制移动
function FightingController:controllMove() --@return typeOrObject

	local offx,offy = 0,0
	
	if self.hero.model:getPos().x < self.target.model:getPos().x then
	   offx = 0 + 1
	   self.hero.model:moveRight()
	elseif self.hero.model:getPos().x == self.target.model:getPos().x then
	   offx = 0
	else
	   offx = 0 - 1
	   self.hero.model:moveLeft()
	end
	
	if self.hero.model:getPos().y < self.target.model:getPos().y then
	   offy = 0 + 1
	   self.hero.model:moveUp()
	elseif self.hero.model:getPos().y == self.target.model:getPos().y then
	   offy = 0
	else
	   offy = 0 - 1
	   self.hero.model:moveDown()
	end
	
	local pos = {x = offx , y = offy}
	self.hero.view:setMovePos(pos)
	
    if offx == 0 and offy == 0 then
       self.hero.model:ready()
    else
       self.hero.model:move()
    end
	
end

return FightingController