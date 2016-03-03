--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-12-29
-- Time: 上午11:34
-- To change this template use File | Settings | File Templates.
--

local FighterModel = require("scene.battle.model.fighter.FighterModel")
-------------------------------------------------------------------------------

local InstanceModel = class("InstanceFighter", FighterModel)

function InstanceModel:ctor()
    InstanceModel.super.ctor(self, "instance")
end

function InstanceModel:isAttackableType()
    return true
end

function InstanceModel:isHittableType()
    return false
end

function InstanceModel:isMovableType()
    return false
end

function InstanceModel:isMissable()
    return false
end

function InstanceModel:canMatched()
    return false
end

function InstanceModel:getFormulaParams()
    return {}
end

return InstanceModel