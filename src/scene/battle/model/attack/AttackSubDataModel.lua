--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-12-15
-- Time: 下午4:27
-- To change this template use File | Settings | File Templates.
--

local AttackSubDataModel = class("AttackSubDataModel")

function AttackSubDataModel:ctor(attackData, targetFighter)
    self.attackData = attackData
    self.targetFighter = targetFighter

    self.value = 0
    self.valid = true
    self.stoped = false
    self.extraDamageValue = 0
    self.extraDamageRatio = 0
    self.formulaParams = nil
    self.extraBuffProbability = 0
end

function AttackSubDataModel:getFormulaParams()
    if self.formulaParams == nil then
        self.formulaParams = self.attackData:generateFormulaParams(self.targetFighter)
    end

    return self.formulaParams
end

function AttackSubDataModel:setExtraDamageValue(value)
    self.extraDamageValue = value
end

function AttackSubDataModel:incExtraDamageValue(value)
    self.extraDamageValue = self.extraDamageValue + value
end

function AttackSubDataModel:setExtraDamageRatio(value)
    self.extraDamageRatio = value
end

function AttackSubDataModel:incExtraDamageRatio(value)
    self.extraDamageRatio = self.extraDamageRatio + value
end

function AttackSubDataModel:setExtraBuffProbability(value)
    self.extraBuffProbability = value
end

function AttackSubDataModel:incExtraBuffProbability(value)
    self.extraBuffProbability = self.extraBuffProbability + value
end

function AttackSubDataModel:setValidation(valid)
    self.valid = valid
end

function AttackSubDataModel:isValidation()
    return self.valid
end

function AttackSubDataModel:setStoped(stoped)
    self.stoped = stoped
end

function AttackSubDataModel:isStoped()
    return self.stoped
end

function AttackSubDataModel:getValue()
    return self.value
end

function AttackSubDataModel:setValue(value)
    self.value = value
end

return AttackSubDataModel
