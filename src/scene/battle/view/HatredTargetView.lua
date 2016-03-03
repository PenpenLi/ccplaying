--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/5/18
-- Time: 下午7:02
-- To change this template use File | Settings | File Templates.
--

local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterView = require("scene.battle.view.FighterView")

------------------------------------------------------------------------------
local HatredTargetView = class("HatredTargetView", FighterView)

function HatredTargetView:ctor(res, showHPBar)
    self.res = res
    self.showHPBar = showHPBar

    self:setupUI()
end

function HatredTargetView:setupUI()
    local ani = load_animation("image/spine/hatred/", 1, BattleConfig.SPEED_RATIO)
    ani:setAnimation(0, "animation", true)
    self.aniNode = ani
    self:addChild(self.aniNode)

    local hpBarPos = cc.p(0, 80)

    local hpBgSprite = cc.Sprite:create("image/ui/img/btn/btn_232.png")
    hpBgSprite:setPosition(hpBarPos)
    hpBgSprite:setScale(0.8)
    self:addChild(hpBgSprite)
    self.hpBg = hpBgSprite

    local bgImage = "image/ui/img/btn/btn_230.png"
    local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
    hpBar:setPosition(hpBarPos)
    hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hpBar:setScale(0.8)
    hpBar:setMidpoint(cc.p(0, 1))
    hpBar:setBarChangeRate(cc.p(1, 0))
    hpBar:setPercentage(100)
    self:addChild(hpBar)
    self.hpBar = hpBar

    hpBgSprite:setVisible(self.showHPBar)
    hpBar:setVisible(self.showHPBar)
end

function HatredTargetView:attack()
    CCLog("HatredTargetView:attack()")
end

function HatredTargetView:idle()
    CCLog("HatredTargetView:attack()")
end

function HatredTargetView:inAttackScope(inScope, isTeammate)
    if self.aniNode then
        if inScope then
            if isTeammate then
                self.aniNode:setColorFactor(cc.c4f(0.5, 255, 0.5, 1))
            else
                self.aniNode:setColorFactor(cc.c4f(255, 0.5, 0.5, 1))
            end
        else
            self.aniNode:setColorFactor(cc.c4f(1, 1, 1, 1))
        end
    end
end

function HatredTargetView:updateHPBar()
    --    local hp = self.model:getHP()
    --    local total = self.model:getFullHP()
    --
    --    local percent = math.floor(hp * 100 / total)
    --    self.hpBar:setPercentage(percent)
end

function HatredTargetView:updateHPPercent(percent)
    self.hpBar:setPercentage(percent)
end


function HatredTargetView:hpChange(hp, restraint, critical)
    if hp == 0 then
        return --self:immune()
    end

    local hintNode = cc.Node:create()
    hintNode:setCascadeOpacityEnabled(true)

    local height = math.max(27 * 1.5, 39, 28)
    local width = 0
    if critical then
        hintNode:setContentSize(cc.size(360, 50 + 39))
        hintNode:setAnchorPoint(cc.p(0.5, 0.5))
        hintNode:setPosition(cc.p(0, 170))

        local sprite = cc.Sprite:create("res/image/ui/img/btn/btn_1059.png")
        sprite:setPosition(cc.p(360 / 2, 65))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        hintNode:addChild(sprite)

        local atlasPath = "image/ui/img/btn/btn_1292.png"
        local sign = hp > 0 and ":" or "" -- --string.chr(string.byte("9")+1)
        local hp_str = sign .. "" .. math.abs(math.floor(hp))
        local label = cc.LabelAtlas:_create(hp_str, atlasPath, 31, 39,  string.byte("0"))
        label:setScale(1)
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPosition(cc.p(360 / 2, 20))
        hintNode:addChild(label, 9999)

        self:addChild(hintNode)
        --table.insert(self.actionNodeList, hintNode)
        hintNode:setScale(0.7)
        hintNode:runAction(cc.Sequence:create({
            cc.Spawn:create({cc.MoveBy:create(0.25, cc.p(0, 70)), cc.ScaleTo:create(0.25, 1.3)}),
            cc.ScaleTo:create(0.05, 1),
            cc.DelayTime:create(0.4),
            cc.Spawn:create({cc.MoveBy:create(0.4, cc.p(0, 40)), cc.FadeOut:create(0.4)}),
            --cc.CallFunc:create(function() table.removeItem(self.actionNodeList, hintNode) end),
            cc.RemoveSelf:create(),
        }))
    else
        if restraint then
            local atlasPath = "image/ui/img/btn/btn_469.png"
            local label = cc.LabelAtlas:_create("23", atlasPath, 27, 28,  string.byte("0"))
            label:setColor(cc.c3b(255, 10, 10))
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(cc.p(width, height / 2))
            hintNode:addChild(label)

            width = width + 54
        end

        local atlasPath = hp > 0 and "image/atlas/numgreen.png" or "image/atlas/numred.png"
        local sign = hp > 0 and ":" or "" -- --string.chr(string.byte("9")+1)
        local hp_str = sign .. "" .. math.abs(math.floor(hp))
        local label
        if hp > 0 then
            label = cc.LabelAtlas:_create(hp_str, "image/atlas/numgreen.png", 18, 27,  string.byte("0"))
            label:setScale(1.5)
        else
            label = cc.LabelAtlas:_create(hp_str, "image/atlas/numred.png", 30, 39,  string.byte("0"))
            label:setScale(0.75)
        end

        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(cc.p(width, height / 2))
        hintNode:addChild(label, 9999)
        width = width + #hp_str * 27 * 1.5

        hintNode:setContentSize(cc.size(width, height))
        hintNode:setAnchorPoint(cc.p(0.5, 0.5))
        hintNode:setPosition(cc.p(0, 160))

        self:addChild(hintNode)
        --table.insert(self.actionNodeList, hintNode)
        hintNode:runAction(cc.Sequence:create({
            cc.MoveBy:create(0.4, cc.p(0, 70)),
            cc.DelayTime:create(0.4),
            cc.Spawn:create({
                cc.MoveBy:create(0.2, cc.p(0, 30)),
                cc.FadeOut:create(0.2),
            }),
            --cc.CallFunc:create(function() table.removeItem(self.actionNodeList, hintNode) end),
            cc.RemoveSelf:create(),
        }))
    end

    self:updateHPBar()
end

function HatredTargetView:die()
    self:runAction(cc.Sequence:create({
        cc.FadeOut:create(0.5),
        cc.DelayTime:create(0.1),
        cc.RemoveSelf:create(),
    }))
end

function HatredTargetView:magicCircleAdded(skillID)

end

function HatredTargetView:magicCircleRemoved(skillID)

end

return HatredTargetView


