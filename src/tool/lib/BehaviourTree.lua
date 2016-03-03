local Action = class("Action")

function Action:ctor(task, desc)
    self.task = task
end

function Action:update(creatureAI)
    local ret =  self.task(creatureAI) and true or false
    return ret
end

local Condition = class("Condition")

function Condition:ctor(condition, desc)
    self.condition = condition
end

function Condition:update(creatureAI)
    local ret = self.condition(creatureAI) and true or false
    return ret
end

local Selector = class("Selector")

function Selector:ctor(children)
    self.children = children
end

function Selector:update(creatureAI)
    for i,v in ipairs(self.children) do
        local status = v:update(creatureAI)
        if status then
            return status
        end
    end
end

local Sequence = class("Sequence")

function Sequence:ctor(children)
    self.children = children
end

function Sequence:update(creatureAI)
    for i = 1, #self.children do
        local status = self.children[i]:update(creatureAI)
        if not status then
            return status
        end
    end
    return true
end

local ActionLog = class("ActionLog")

function ActionLog:ctor(task, desc)
    self.task = task
    self.desc = tostring(desc or "")
end

function ActionLog:update(creatureAI)
    local ret =  self.task(creatureAI) and true or false
    CCLogf("Action(%s) return %s", self.desc, tostring(ret))
    return ret
end

local ConditionLog = class("ConditionLog")

function ConditionLog:ctor(condition, desc)
    self.condition = condition
    self.desc = tostring(desc or "")
end

function ConditionLog:update(creatureAI)
    local ret = self.condition(creatureAI) and true or false
    CCLogf("Condition(%s) return %s", self.desc, tostring(ret))
    return ret
end

local SelectorLog = class("SelectorLog")

function SelectorLog:ctor(children)
    self.children = children
end

function SelectorLog:update(creatureAI)
    for i,v in ipairs(self.children) do
        local status = v:update(creatureAI)
        if status then
            CCLogf("Selector return %s", tostring(status))
            return status
        end
    end
end

local SequenceLog = class("SequenceLog")

function SequenceLog:ctor(children)
    self.children = children
end

function SequenceLog:update(creatureAI)
    for i = 1, #self.children do
        local status = self.children[i]:update(creatureAI)
        if not status then
            CCLogf("Selector return %s", tostring(status))
            return status
        end
    end
    CCLogf("Selector return true")
    return true
end

local BehaviourTree = {
    Action = Action,
    Condition = Condition,
    Selector = Selector,
    Sequence = Sequence,

    ActionLog = ActionLog,
    ConditionLog = ConditionLog,
    SelectorLog = SelectorLog,
    SequenceLog = SequenceLog,
}

return BehaviourTree
