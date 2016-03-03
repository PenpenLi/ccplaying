local GameObject = require("libs.GameObject")
local FightingModel = class("FightingModel")

FightingModel.CHANGE_STATE_EVENT = "CHANGE_STATE_EVENT"         
FightingModel.START_EVENT        = "START_EVENT"                
FightingModel.READY_EVENT        = "READY_EVENT"                
FightingModel.ATTACT_EVENT       = "ATTACT_EVENT"               
FightingModel.MOVE_EVENT         = "MOVE_EVENT"                
FightingModel.REST_EVENT         = "REST_EVENT"                 
FightingModel.DEAD_EVENT         = "DEAD_EVENT"                 
FightingModel.CHANGE_HP_EVENT    = "CHANGE_HP_EVENT"           
FightingModel.CHANGE_RP_EVENT    = "CHANGE_RP_EVENT"            
FightingModel.KILLATTACK_EVENT   = "KILLATTACK_EVENT"

function FightingModel:ctor(properties, events, callbacks)
  GameObject.extend(self)
  

  local dispatcher = cc.EventDispatcher:new()
  dispatcher:retain()
  dispatcher:setEnabled(true) 
  self.dispatcher = dispatcher 
  
  self.eid = 0
  self.id = 0
  self.level = 0
  self.pos = cc.p(0,0)
  self.enhance = 1
  self.lv1Attr = {
     hp = 0,
     atk = 0,
     def = 0,
     fa = 0,
  }

  self:addComponent("libs.StateMachine")                     
  self.fsm_ = self:getComponent("libs.StateMachine")
  
  local defaultEvents = {                                                 
       {name = "start", from = "none", to = "idle"},                       
       {name = "move", from = "idle", to = "run"},                           
       {name = "ready", from = "*", to = "attackable"},                    
       {name = "hit", from = "attackable", to = "attack"},                   
       {name = "killhit", from = "*", to = "killattack"},
       {name = "rest", from = "*", to = "idle"},                          
       {name = "dead", from = "*", to = "disappear"}
                                
   }
 
   table.insertTo(defaultEvents, totable(events))

   local defaultCallbacks = {                                               
        onchangestate = handler(self, self.onChangeState_),                 
        onstart       = handler(self, self.onStart_),                        
        onmove        = handler(self, self.onMove_),                         
        onready       = handler(self, self.onReady_),                       
        onhit         = handler(self, self.onHit_),                         
        onrest        = handler(self, self.onRest_),                        
        ondead        = handler(self, self.onDead_),                         
        onkillhit     = handler(self, self.onKillHit_),                     
    }
    table.merge(defaultCallbacks, totable(callbacks))   
    

    self.fsm_:setupState({
        events = defaultEvents,                                             
        callbacks = defaultCallbacks
    })
    self.fsm_:doEvent("start")  
    
end

function FightingModel:addEventListener(name, callback)
    local listener = cc.EventListenerCustom:create(name, callback)
    self.dispatcher:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

function FightingModel:dispatchEvent(event) --@return typeOrObject
	local custemEvent = cc.EventCustom:new(event.name)
	for k, v in pairs(event) do
	   if k ~= "name" then
	       custemEvent[k] = v
	   end
	end
	self.dispatcher:dispatchEvent(custemEvent)
end
---------base data ---------------
function FightingModel:create(eid,id,level,enhance,pos,lv1Attr)
   self.eid = eid
   self.id = id
   self.level = level
   self.enhance = self.enhance
   self.pos = pos
  
   self.lv1Attr = lv1Attr

  
end

function FightingModel:getEid()
  return self.eid
end

function FightingModel:setEid(eid)
    self.eid = eid
end

function FightingModel:getId()
  return self.id
end

function FightingModel:setId(id) --@return typeOrObject
	self.id = id
end

function FightingModel:getLevel() --@return typeOrObject
  return self.level
end

function FightingModel:setLevel(level) --@return typeOrObject
	self.level = level
end

function FightingModel:getPos() --@return typeOrObject

	return self.pos
end

function FightingModel:setPos(pos) --@return typeOrObject
	self.pos = pos
end

function FightingModel:getEnhance() --@return typeOrObject
	return self.enhance
end

function FightingModel:setEnhance(enhance) --@return typeOrObject
	self.enhance = enhance
end

function FightingModel:getLv1Attr() --@return typeOrObject
	return self.lv1Attr
end

function FightingModel:setLv1Attr(lv1Attr) --@return typeOrObject
	self.lv1Attr = lv1Attr
end

function FightingModel:getState() --@return typeOrObject
	return self.fsm_:getState()
end
------ base function ----------------
function FightingModel:increaseRp() --@return typeOrObject
	self:dispatchEvent({name = FightingModel.CHANGE_RP_EVENT})
end

function FightingModel:decreaseRp() --@return typeOrObject
	self:dispatchEvent({name = FightingModel.CHANGE_RP_EVENT})
end

function FightingModel:moveUp() --@return typeOrObject
	self.pos.y = self.pos.y + 1
end

function FightingModel:moveRight() --@return typeOrObject
	self.pos.x = self.pos.x + 1
end

function FightingModel:moveDown() --@return typeOrObject
	self.pos.y = self.pos.y - 1
end

function FightingModel:moveLeft() --@return typeOrObject
	self.pos.x = self.pos.x - 1
end

function FightingModel:decreaseHp(dhp) --@return typeOrObject
    if self.lv1Attr.hp > 0 then
	   self.lv1Attr.hp = self.lv1Attr.hp - dhp
	   self:dispatchEvent({name = FightingModel.CHANGE_HP_EVENT})
	end
	if self.lv1Attr.hp <= 0 then
	   self:dispatchEvent({name = FightingModel.DEAD_EVENT})
	end
end
----- state function --------
function FightingModel:move() --@return typeOrObject
	self.fsm_:doEvent("move")
end

function FightingModel:ready() --@return typeOrObject
	self.fsm_:doEvent("ready")
end

function FightingModel:hit()
    self.fsm_:doEvent("hit")
end

function FightingModel:rest() --@return typeOrObject
	self.fsm_:doEvent("rest")
end

function FightingModel:dead() --@return typeOrObject
	self.fsm_:doEvent("dead")
end

function FightingModel:killHit() --@return typeOrObject
	self.fsm_:doEvent("killhit")
end
-------- dispatch function --------
function FightingModel:onChangeState_(event) --@return typeOrObject
	event = {name = FightingModel.CHANGE_STATE_EVENT, from = event.from, to = event.to}
	self:dispatchEvent(event)
end

function FightingModel:onStart_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.START_EVENT})
end

function FightingModel:onMove_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.MOVE_EVENT})
end

function FightingModel:onReady_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.READY_EVENT})
end

function FightingModel:onHit_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.ATTACT_EVENT})
end

function FightingModel:onKillHit_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.KILLATTACK_EVENT,model = self})
end

function FightingModel:onRest_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.REST_EVENT})
end

function FightingModel:onDead_(event) --@return typeOrObject
	self:dispatchEvent({name = FightingModel.DEAD_EVENT})
end

return FightingModel