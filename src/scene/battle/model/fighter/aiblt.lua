function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function iskindof(obj, className)
    local t = type(obj)

    if t == "table" then
        local mt = getmetatable(obj)
        while mt and mt.__index do
            if mt.__index.__cname == className then
                return true
            end
            mt = mt.super
        end
        return false

    elseif t == "userdata" then

    else
        return false
    end
end


local cocreate = coroutine.create
local yield = coroutine.yield
local resume = coroutine.resume
local codead = function(co) return co == nil or coroutine.status(co) == "dead" end

local Composite = class("Composite")

function Composite:update() 
    print("Composite:update", self.__cname)

   if codead(self.runner) then
      self.runner = cocreate(self.execute)
   end
   
   local status, rv = resume(self.runner, self);
   
   if codead(self.runner) then 
      self.last_status = rv
   else
      self.last_status = "Running"
   end
   
   return self.last_status
end

function Composite:start()
    print("Composite:start")

   self.runner = nil
   self.last_status = nil
end

local Action = class("Action", Composite)

function Action:ctor(func) 
    print("Action:ctor")

    self.action = func
    self.runner = nil
    self.type = "Action"
    self.parent = nil
end

function Action:execute()
    print("Action:execute", self.__cname)

   return self.action()
end

local Container = class("Container", Composite)

function Container:ctor(...)
    print("Container:ctor")

    self.children = {}
    self.runner = nil
    self.type = "Container"
    self.parent = nil 
   
    for i,v in ipairs(arg) do
        self:add(v)
    end
end

function Container:add(comp)
    print("Container:add")

   if (type(comp) == "function") then
      comp = Action.new(comp)
   end

    table.insert(self.children, comp)
    comp.parent = self
    return self
end

local Sequence =  class("Sequence", Container)

function Sequence:execute() 
    print("Sequence:execute", self.__cname)

   for i,comp in ipairs(self.children) do
      comp:start()
      while comp:update() == "Running" do
         yield("Running")
      end
      
      if (comp.last_status == false) then
         return false
      end
   end
   
   return true
end

local PrioritySelector = class("PrioritySelector", Container)

function PrioritySelector:execute() 
    print("PrioritySelector:execute", self.__cname)

   for i,comp in ipairs(self.children) do
      comp:start()
      while comp:update() == "Running" do
         yield("Running")
      end
      
      if (comp.last_status == true) then
         return true
      end
   end
   
   return false
end


local AbstractDecorator = class("AbstractDecorator", Composite)

function AbstractDecorator:ctor(predicate, child)
    print("AbstractDecorator:ctor")

    if (type(child) == "function") then
      child = Action.new(child)
    end
    self.predicate = predicate
    self.child = child
end

-- Decorator isa AstractDecorator
local Decorator = class("Decorator", AbstractDecorator)

function Decorator:execute()
    print("Decorator:execute", self.__cname)

    local pred_rv = self.predicate()
    self.child:Start()
    if pred_rv then
        while self.child:update() == "Running" do
           yield("Running")
        end
        
        return self.child.last_status
    else
        return false
    end
end

-- DecoratorContinue isa AstractDecorator
local DecoratorContinue = class("DecoratorContinue", AbstractDecorator)

function DecoratorContinue:execute()
    print("DecoratorContinue:execute", self.__cname)

    local pred_rv = self.predicate()
    if pred_rv then
       self.child:start()
        while self.child:update() == "Running" do
           yield("Running")
        end
        return self.child.last_status
    else
        return true
    end
end

-- Wait isa AbstractDecorator
local Wait = class("Wait", AbstractDecorator)

function Wait:ctor(predicate, child, timeout)
    print("Wait:ctor")

    Wait.super.ctor(self, predicate, child)
    self.timeout = timeout
end

function Wait:execute()
    print("Wait:execute", self.__cname)

    local time_start = get_cur_time()
    
    while (get_cur_time() - time_start < self.timeout) do
        local pred_rv = self.predicate()
        if pred_rv then
           self.child:start()
            while self.child:update() == "Running" do
              yield("Running")
           end   
           return self.child.last_status
        end
        yield("Running")
    end
    return false
end

-- WaitContinue isa AbstractDecorator
local WaitContinue = class("WaitContinue", AbstractDecorator)

function WaitContinue:ctor(predicate, child, timeout)
    print("WaitContinue:ctor")

    WaitContinue.super.ctor(self, predicate, child)
    self.timeout = timeout
end

function WaitContinue:execute()
    print("WaitContinue:execute", self.__cname)

    local time_start = get_cur_time()
    print("get_cur_time() - time_start, self.timeout", get_cur_time() - time_start, self.timeout)
    while (get_cur_time() - time_start < self.timeout) do
        local pred_rv = self.predicate()
        if pred_rv then
           self.child:start()
            while self.child:update() == "Running" do
              yield("Running")
           end   
           return self.child.last_status
        end
        yield("Running")
    end
    return true
end

-- RepeatUntil isa AbstractDecorator
local RepeatUntil = class("RepeatUntil", AbstractDecorator)

function RepeatUntil:ctor(predicate, child, timeout)
    print("RepeatUntil:ctor")
    RepeatUntil.super.ctor(self, predicate, child)
    self.timeout = timeout
end

function RepeatUntil:execute()
    print("RepeatUntil:execute", self.__cname)

    local time_start = get_cur_time()
    
    while (get_cur_time() - time_start < self.timeout) do
        local pred_rv = self.predicate()
        if not pred_rv then
           self.child:start()
            while self.child:update() == "Running" do
              yield("Running")
           end   
           if self.child.last_status == false then return false end
            yield("Running") 
        else
            return true
        end
    end
    return false
end

local TreeWalker = class("TreeWalker")

function TreeWalker:ctor(root)
    print("TreeWalker:ctor")

    self.logic = root
end

function TreeWalker:update()
    print("TreeWalker:update")

   self.logic:update()
   
   if (self.logic.last_status ~= "Running") then
      self.logic:start()
   end
end

-- Sleep 
function Sleep(timeout)
    return WaitContinue.new(function() return false end, nil, timeout)
end

function get_cur_time() 
    local time = os.time() 
    print("time:", time)
    return time
end

local tree = TreeWalker.new(PrioritySelector.new({Sleep(1), Action.new({function() print("OK") end})}))

print(os.execute("pwd"))
for i = 1, 10 do
    print(i)
    tree:update()
end


