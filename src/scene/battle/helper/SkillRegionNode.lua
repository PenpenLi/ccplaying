--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/8
-- Time: 下午1:09
-- To change this template use File | Settings | File Templates.
--

-- 攻击范围节点
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------
local SkillRegionNode = class("SkillRegionNode", function() return cc.Node:create() end)

function SkillRegionNode:ctor()
--    local stencil = cc.LayerColor:create(cc.c4b(0, 0, 255, 255), 1, 1)
--    stencil:setPosition(cc.p(0, 0))
--    self.stencil = stencil
--
--    local clippingNode = cc.ClippingNode:create()
--    clippingNode:setPosition(cc.p(0, 0))
--    clippingNode:setInverted(false)
--    clippingNode:setAlphaThreshold(0.5)
--    clippingNode:setStencil(stencil)
--    self:addChild(clippingNode)
--
--    self.clippingNode = clippingNode

    -- 临时用
--    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 50, 50), display.width * 2, display.height * 2)
--    colorLayer:setPosition(cc.p(-display.width, -display.height))
--    clippingNode:addChild(colorLayer)

    local background = cc.Scale9Sprite:create(cc.rect(25, 25, 192 - 50, 169 - 50), "image/spine/skill_effect/skill_region.png")
--    background:setContentSize(BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)
--    background:setPosition(cc.p(0, 0))
--    background:setAnchorPoint(cc.p(0, 0))
    self:addChild(background)

    self.background = background

    self.fullRect = cc.rect(0, 0, BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)
end

function SkillRegionNode:setRect(regionRect)
    CCLog(vardump(regionRect, "SkillRegionNode:setRect"))
    local rect = cc.rectIntersection(regionRect, self.fullRect)
--    self.stencil:setPosition(rect)
--    self.stencil:setContentSize(rect)

	local pos = cc.p(rect.x, rect.y)
    self.background:setPosition(pos.x + rect.width / 2, pos.y + rect.height / 2)
    self.background:setContentSize(rect)
end

return SkillRegionNode
