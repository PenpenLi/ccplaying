--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/1/19
-- Time: 上午10:39
-- To change this template use File | Settings | File Templates.
--

local ComboHitModel = class("ComboHitModel")

-- heroModel BUFF拥有者 attackerModel: 施法者
function ComboHitModel:ctor(heroModel, attackData)
    self.heroModel = heroModel
    self.attackData = attackData
    self.leftCount = assert(attackData.skillData.extraAffectValue)
end

function ComboHitModel:release()
    CCLog("多重攻击数据剩余:", self.leftCount)
    if self.leftCount > 0 then
        self.heroModel:doSubComboHitAttack(self.attackData)
        self.leftCount = self.leftCount - 1
        return true
    end

    return false
end

return ComboHitModel


