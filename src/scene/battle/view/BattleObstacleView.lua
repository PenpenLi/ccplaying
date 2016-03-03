--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-3
-- Time: 下午2:49
-- To change this template use File | Settings | File Templates.
--

local BattleModel = require("scene.battle.model.BattleModel")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterView = require("scene.battle.view.FighterView")

local TAG_IMAGE_BASE = 10000
-------------------------------------------------------------------------------
local BattleObstacleView = class("BattleObstacleView", FighterView)

function BattleObstacleView:ctor(obstacleID, cell, res, obstacleType)
    self:setCascadeOpacityEnabled(true)
    
    self:setRotationSkewX(-BattleConfig.BEVEL_ANGLE)
    self.resType = nil -- image or ani
    self.cell = cell
    self.res = res

    local ps, pe = string.find(res, ".png")

    if pe == #res then
        self.resType = "image"
        CCLog("Image Obstacle")
        self:loadImage(res)
    else
        self.resType = "ani"
        CCLog("ANI Obstacle")
        local aniPath = string.format("image/map/obstacle/%s/", res)
        local obstacle = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
        if obstacle then
            obstacle:addAnimation(0, "animation", true)
            self:addChild(obstacle)
        end
    end

    -- TODO:附加特效，先写死
    if obstacleID == 1002 then
        local effect = load_animation("image/map/obstacle/BQ_effect/", 1, BattleConfig.SPEED_RATIO)
        if effect then
            effect:addAnimation(0, "animation", true)
            self:addChild(effect)
            effect:setPosition(cc.p(0, BattleConfig.CELL_HEIGHT * 3))
        end
    end

    local hpBarPos = cc.p(0, 80)

    self.showHPBar = false

    if obstacleType == enums.ObstacleType.Precipice then
        self.showHPBar = false
    end

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
    hpBar:setVisible(false)

    hpBgSprite:setVisible(self.showHPBar)
    hpBar:setVisible(self.showHPBar)
end

function BattleObstacleView:loadImage(res)
    CCLog("BattleObstacleView:loadImage:", res)
    CCLog("BattleObstacleView:loadImage:", res)
    local path = string.format("image/map/obstacle/%s", res)
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return
    end

    local imageTag = TAG_IMAGE_BASE

    local oldSprite = self:getChildByTag(imageTag)
    if oldSprite then
        oldSprite:removeFromParent()
    end

    local spirte = cc.Sprite:create(path)
    spirte:setGlobalZOrder(103)
    spirte:setAnchorPoint(cc.p(0.5, 0.5))
    spirte:setPosition(cc.p(0, BattleConfig.CELL_HEIGHT * 2))
    self:addChild(spirte, ((5 + 4)  * 10000), imageTag)
end

function BattleObstacleView:getCell()
    return self.cell
end

function BattleObstacleView:hit(damage, skillID, restraint)

end

function BattleObstacleView:updateHPPercent(hpPercent)
    self.hpBar:setPercentage(hpPercent)
    
    local res = self.res

    if hpPercent < 25 then
        if self.resType == "image" then
            local ps, pe = string.find(res, "_1")
            self:loadImage(string.sub(res, 1, ps - 1) .. "_4" .. string.sub(res, pe + 1))
        elseif self.resType == "ani" then
            -- TODO:
        end
    elseif hpPercent < 50 then
        if self.resType == "image" then
            local ps, pe = string.find(res, "_1")
            self:loadImage(string.sub(res, 1, ps - 1) .. "_3" .. string.sub(res, pe + 1))
        elseif self.resType == "ani" then
            -- TODO:
        end
    elseif hpPercent < 75 and hpPercent > 35 then
        if self.resType == "image" then
            local ps, pe = string.find(res, "_1")
            self:loadImage(string.sub(res, 1, ps - 1) .. "_2" .. string.sub(res, pe + 1))
        elseif self.resType == "ani" then
            -- TODO:
        end
    end
end

function BattleObstacleView:hpChange(hp)
    local atlasPath = hp > 0 and "image/atlas/numgreen.png" or "image/atlas/numred.png"
    local sign = hp > 0 and ":" or "" -- --string.chr(string.byte("9")+1)
    local label
    local hp_str = sign .. "" .. math.abs(math.floor(hp))
    if hp > 0 then
        label = cc.LabelAtlas:_create(hp_str, "image/atlas/numgreen.png", 18, 27,  string.byte("0"))
    else
        label = cc.LabelAtlas:_create(hp_str, "image/atlas/numred.png", 30, 39,  string.byte("0"))
        label:setScale(0.75)
    end

    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(cc.p(0, 250))
    self:addChild(label, 999999)

    label:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveBy:create(0.4, cc.p(0, 50)),
            cc.ScaleBy:create(0.4, 0.9),
        }),
        cc.DelayTime:create(0.4),
        cc.Spawn:create({
            cc.MoveBy:create(0.2, cc.p(0, 30)),
            cc.FadeOut:create(0.2),
        }),
        cc.RemoveSelf:create(),
    }))

end

return BattleObstacleView