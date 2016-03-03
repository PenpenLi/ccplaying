--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-12-2
-- Time: 下午7:42
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
-------------------------------------------------------------------------------

local FighterView = require("scene.battle.view.FighterView")

local BattleFairyView = class("BattleFairyView", FighterView)

function BattleFairyView:ctor(eventDispatcher, teamSide, skillID1, skillID2, headIconPath)
    self.eventDispatcher = eventDispatcher

    self.enabled = false
    self.teamSide = teamSide
    self.skillID1 = skillID1
    self.skillID2 = skillID2
    self.headIconPath = headIconPath
    self.inCooling = true

    self:setupUI()
end

function BattleFairyView:setupUI()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/zd.plist")

    -- local coro = coroutine.create(function()
        local fileUtils = cc.FileUtils:getInstance()

        local fairyNode = cc.Node:create()
        self:addChild(fairyNode)
        self.fairyNode = fairyNode

        --local spriteFairyBg = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1024.png"))
        local spriteFairyBg = cc.Sprite:createWithSpriteFrameName("btn_1024.png")        
        spriteFairyBg:setPosition(cc.p(0, 0))
        fairyNode:addChild(spriteFairyBg)
        self.fairyBG = spriteFairyBg

        --local cdBarBG = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_1020.png"))
        local cdBarBG = cc.Sprite:createWithSpriteFrameName("btn_1020.png")
        cdBarBG:setPosition(cc.p(-1, -57))
        fairyNode:addChild(cdBarBG, 1)

        local skillCDImge = "image/ui/img/btn/btn_1023.png"
        --local skillCDBar = cc.ProgressTimer:create(cc.Sprite:createWithTexture(coroutine.yield(skillCDImge)))
        local skillCDBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("btn_1023.png"))
        skillCDBar:setPosition(cc.p(2, -52))
        skillCDBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        skillCDBar:setMidpoint(cc.p(0, 0))
        skillCDBar:setBarChangeRate(cc.p(1, 0))
        skillCDBar:setReverseProgress(false)
        skillCDBar:setPercentage(0)
        fairyNode:addChild(skillCDBar, 2)
        self.cdBar = skillCDBar

        local imagePath = self.headIconPath
        CCLog("path:", imagePath)
        local spriteFairyHead = cc.Sprite:create(imagePath)
        spriteFairyHead:setPosition(cc.p(0, 0))
        fairyNode:addChild(spriteFairyHead)
        self.fairyHead = spriteFairyHead

        local headSize = spriteFairyHead:getContentSize()
        --local spriteFairyIcon = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_647.png"))
        local spriteFairyIcon = cc.Sprite:createWithSpriteFrameName("btn_647.png")
        spriteFairyIcon:setPosition(cc.p(headSize.width / 2, 10))
        spriteFairyHead:addChild(spriteFairyIcon)

        --local spriteHalo = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_917.png"))
        local spriteHalo = cc.Sprite:createWithSpriteFrameName("btn_917.png")
        spriteHalo:setPosition(cc.p(40, 25))
        spriteHalo:setRotation(-45)
        spriteHalo:setAnchorPoint(cc.p(0.5, 0.5))
        fairyNode:addChild(spriteHalo)
        spriteHalo:setVisible(false)
        self.spriteHalo = spriteHalo

        
        local skillID1 = self.skillID1
        local skillImg1 = string.format("image/icon/skill/sk_%d.png", skillID1)

        if not fileUtils:isFileExist(skillImg1) then
            skillImg1 = "image/icon/skill/sk_1001.png"
        end

        --local stencil1BG = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_788.png"))
        local stencil1BG = cc.Sprite:createWithSpriteFrameName("btn_788.png")
        stencil1BG:setPosition(cc.p(70, 0))
        self:addChild(stencil1BG)
        self.skillNode1 = stencil1BG
        self.skillNode1:setVisible(false)

        --local buttonCircle1 = cc.Sprite:createWithTexture(coroutine.yield("image/icon/border/border_circle_02.png"))
        local buttonCircle1 = cc.Sprite:createWithSpriteFrameName("border_circle_02.png")
        buttonCircle1:setPosition(cc.p(43, 43))
        buttonCircle1:setScale(0.85)
        stencil1BG:addChild(buttonCircle1)

        local aniCircle1 = load_animation("image/spine/fairy/circle/")
        aniCircle1:setPosition(cc.p(43, 43))
        aniCircle1:setScale(0.85)
        aniCircle1:setAnimation(0, "animation", true)
        stencil1BG:addChild(aniCircle1)

        --local stencil1 = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_788.png"))
        local stencil1 = cc.Sprite:createWithSpriteFrameName("btn_788.png")
        stencil1:setScale(0.9)
        local clippingNode1 = cc.ClippingNode:create()
        clippingNode1:setPosition(cc.p(43, 43))
        clippingNode1:setInverted(false)
        clippingNode1:setAlphaThreshold(0.5)
        clippingNode1:setStencil(stencil1)
        stencil1BG:addChild(clippingNode1)

        local skillButton1 = ccui.Button:create(skillImg1)
        skillButton1:setPosition(cc.p(0, 0))
        skillButton1:setTitleFontSize(24)
        skillButton1:addTouchEventListener(widget_click_listener(function(sender)
            if self.enabled then
                self:releaseSkill(1)
            end
        end))
        clippingNode1:addChild(skillButton1)

        local skillID2 = self.skillID2
        local skillImg2 = string.format("image/icon/skill/sk_%d.png", skillID2)

        if not fileUtils:isFileExist(skillImg2) then
            skillImg2 = "image/icon/skill/sk_1001.png"
        end

        --local stencil2BG = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_788.png"))
        local stencil2BG = cc.Sprite:createWithSpriteFrameName("btn_788.png")
        stencil2BG:setPosition(cc.p(0, 70))
        self:addChild(stencil2BG)
        self.skillNode2 = stencil2BG
        self.skillNode2:setVisible(false)

        --local buttonCircle2 = cc.Sprite:createWithTexture(coroutine.yield("image/icon/border/border_circle_02.png"))
        local buttonCircle2 = cc.Sprite:createWithSpriteFrameName("border_circle_02.png")
        buttonCircle2:setPosition(cc.p(43, 43))
        buttonCircle2:setScale(0.85)
        stencil2BG:addChild(buttonCircle2)

        local aniCircle2 = load_animation("image/spine/fairy/circle/")
        aniCircle2:setPosition(cc.p(43, 43))
        aniCircle2:setScale(0.85)
        aniCircle2:setAnimation(0, "animation", true)
        stencil2BG:addChild(aniCircle2)

        --local stencil2 = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_788.png"))
        local stencil2 = cc.Sprite:createWithSpriteFrameName("btn_788.png")
        stencil2:setScale(0.9)
        local clippingNode2 = cc.ClippingNode:create()
        clippingNode2:setPosition(cc.p(43, 43))
        clippingNode2:setInverted(false)
        clippingNode2:setAlphaThreshold(0.5)
        clippingNode2:setStencil(stencil2)
        stencil2BG:addChild(clippingNode2)

        local skillButton2 = ccui.Button:create(skillImg2)
        skillButton2:setPosition(cc.p(0, 0))
        skillButton2:setTitleFontSize(24)
        skillButton2:addTouchEventListener(widget_click_listener(function(sender)
            if self.enabled then
                self:releaseSkill(2)
            end
        end))

        clippingNode2:addChild(skillButton2)

        self.skillButton1 = skillButton1
        self.skillButton2 = skillButton2

    --    local rageSkillCDImge = "image/ui/img/btn/btn_788.png"
    --    local cdBar = cc.ProgressTimer:create(cc.Sprite:create(rageSkillCDImge))
    --    cdBar:setScale(0.7)
    --    cdBar:setOpacity(100)
    --    cdBar:setPosition(cc.p(0, 0))
    --    cdBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    --    cdBar:setMidpoint(cc.p(0, 1))
    --    cdBar:setBarChangeRate(cc.p(0, 1))
    --    cdBar:setPercentage(0)
    --    self:addChild(cdBar)
    --    self.cdBar = cdBar
    -- end)

    -- start_texture_coroutine(coro)
end

function BattleFairyView:update()
--    local leftTime = self.model.coolTimeLeft
--    local CD = self.model.COOL_TIME
--    local cdPercent = 100 - math.floor(leftTime / CD * 100)
--
--    self.cdBar:setPercentage(cdPercent)
end

function BattleFairyView:updateCDPercent(percent)
    self.cdBar:setPercentage(percent)
end

function BattleFairyView:cool()
    self.inCooling = false

    self.fairyHead:stopAllActions()
    self.skillNode1:stopAllActions()
    self.skillNode2:stopAllActions()

    self.fairyHead:runAction(cc.ScaleTo:create(0.4, 0.5))

    self.skillNode1:setScale(0)
    self.skillNode2:setScale(0)
    self.skillNode1:runAction(cc.Sequence:create({
        cc.Show:create(),
        cc.ScaleTo:create(0.18, 1.2),
        cc.ScaleTo:create(0.08, 0.9),
        cc.ScaleTo:create(0.05, 1.05),
        cc.ScaleTo:create(0.05, 1),
    }))
    self.skillNode2:runAction(cc.Sequence:create({
        cc.Show:create(),
        cc.ScaleTo:create(0.18, 1.2),
        cc.ScaleTo:create(0.08, 0.9),
        cc.ScaleTo:create(0.05, 1.05),
        cc.ScaleTo:create(0.05, 1),
    }))

    self.spriteHalo:setVisible(true)
end

function BattleFairyView:releaseSkill(index)
    --self.model:releaseSkill(index)
    if not self.inCooling then
        self.inCooling = true
        self.eventDispatcher:dispatchEvent(AppEvent.UI.Battle.FairySkillCommand, {teamSide = self.teamSide, index = index})
    end
end

function BattleFairyView:skillReleased()
    self.fairyHead:stopAllActions()
    self.skillNode1:stopAllActions()
    self.skillNode2:stopAllActions()

    local scale1 = cc.ScaleTo:create(0.18, 1.1)
    local scale2 = cc.ScaleTo:create(0.05, 0.9)
    local scale3 = cc.ScaleTo:create(0.05, 1)
    self.fairyHead:runAction(cc.Sequence:create(scale1, scale2, scale3))

    self.skillNode1:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.2, 0.3),
        cc.Hide:create(),
    }))
    self.skillNode2:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.2, 0.3),
        cc.Hide:create(),
    }))

    self.spriteHalo:setVisible(false)
end

function BattleFairyView:setEnabled(val)
    self.enabled = val
end

return BattleFairyView