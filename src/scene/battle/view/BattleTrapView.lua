--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/19
-- Time: 上午10:00
-- To change this template use File | Settings | File Templates.
--

local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterView = require("scene.battle.view.FighterView")

local TAG_IMAGE_BASE = 10000
-------------------------------------------------------------------------------
local BattleTrapView = class("BattleTrapView", FighterView)

function BattleTrapView:ctor(trapID, cell, range)
    self._trapID = trapID
    self._cell = cell
    self._range = range
    
    self:setupUI()
end

function BattleTrapView:setupUI()
    local trapID = self._trapID
    local aniPath = string.format("image/map/trap/%d/", trapID)

    local trapAni = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
    if trapAni then
        local pos = cc.p(((self._range / 2) - 0.5) * BattleConfig.CELL_WIDTH, 0)
        trapAni:setAnimation(0, "idle", true)
        trapAni:setPosition(pos)
        self:addChild(trapAni)
        self.trapAni = trapAni
    else
        CCLog("加载陷阱动画失败", aniPath)
    end
end

function BattleTrapView:attack()
    CCLog("BattleTrapView:attack()")
    if self.trapAni then
        self.trapAni:setAnimation(0, "atk", true)
        self.trapAni:addAnimation(0, "move", true)
    end
end

function BattleTrapView:idle()
    CCLog("BattleTrapView:attack()")
    if self.trapAni then
        self.trapAni:setAnimation(0, "idle", true)
    end
end

function BattleTrapView:inAttackScope(inScope, isTeammate)
    if self.trapAni then
        if inScope then
            if isTeammate then
                self.trapAni:setColorFactor(cc.c4f(0.5, 255, 0.5, 1))
            else
                self.trapAni:setColorFactor(cc.c4f(255, 0.5, 0.5, 1))
            end

            local selectMark = cc.Sprite:create("image/ui/img/btn/btn_1177.png")
            selectMark:setName("selectMark")
            selectMark:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.MoveBy:create(0.3, cc.p(0, -10)), cc.MoveBy:create(0.3, cc.p(0, 10))})))
            selectMark:setPosition(cc.p(0, 220))
            self:addChild(selectMark)
        else
            self.trapAni:setColorFactor(cc.c4f(1, 1, 1, 1))
        end
    end
end

function BattleTrapView:magicCircleAdded(skillID)

end

function BattleTrapView:magicCircleRemoved(skillID)
    
end

return BattleTrapView