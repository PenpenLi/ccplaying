--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/1/29
-- Time: 下午3:01
-- To change this template use File | Settings | File Templates.
--

local FighterView = class("FighterView", function() return cc.Node:create() end)

function FighterView:ctor()

end

function FighterView:setTimeScale(timeScale)
	CCLog("TODO:FighterView:setTimeScale()")
end

function FighterView:hpChange()
    CCLog("TODO:FighterView:hpChange()")
end

function FighterView:updateHPBar()
    CCLog("TODO:FighterView:updateHPBar()")
end

function FighterView:updateHPPercent(percent)
    CCLog("TODO:FighterView:updateHPBarPercent()")
end

function FighterView:playHitAnimation()
    CCLog("TODO:FighterView:playHitAnimation()")
end

function FighterView:inAttackScope(inScope, isTeammate)
    CCLog("TODO:FighterView:inAttackScope()")
end

function FighterView:pauseBattle()
    CCLog("TODO:FighterView:pauseBattle()")
end

function FighterView:resumeBattle()
    CCLog("TODO:FighterView:resumeBattle()")
end


return FighterView