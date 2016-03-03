local Effects = require("tool.helper.Effects")
local BattleHelper = require("scene.battle.helper.BattleHelper")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleModel = require("scene.battle.model.BattleModel")
local HeroAction = require("tool.helper.HeroAction")
local BattleConfig = require("scene.battle.helper.BattleConfig")
local FighterView = require("scene.battle.view.FighterView")
local HPBar = require("scene.battle.helper.HPBar")
-------------------------------------------------------------------------------

-- 英雄动画动作的track index
-- local ANI_TRACK_STATE  = 0
-- local ANI_TRACK_ATTACK = 1
-- local ANI_TRACK_HIT    = 2

local ANI_TYPE_STATES = {["idle"] = true, ["move"] = true, ["victory"] = true, ["defense"] = true}
local ANI_TYPE_ATTACKS = {["atk_ko"] = true, ["atk_still"] = true, ["atk1"] = true, ["atk2"] = true, ["atk3"] = true}
local ANI_TYPE_HITS = {["hit"] = true, ["float"] = true}

local BattleHeroView = class("BattleHeroView", FighterView)

function BattleHeroView:ctor(modelAttr)
    self._paused = false

    self.modelAttr = modelAttr

    self._eventDispatcher = nil
    self._autoHideHpBar = true

    -- 暂停/恢复使用
    self.aniNodeList = {}
    self.actionNodeList = {}

    self:setupUI()
    self.animationCallbacks = {}
    self.heroStateAni = "idle"
    self.lastHeroAni = ""
    self.attackData = nil
    self.inAttacking = false
    self.heroScale = 1

    self.buffRefCount = {}
    self.magicRefCount = {}
    self.continuousHitList = {}
end

function BattleHeroView:setTimeScale(timeScale)
    self.heroAni:setTimeScale(timeScale)
end

function BattleHeroView:getName()
    return self.modelAttr.name
end

function BattleHeroView:getBuffCount(affect)
    local count = self.buffRefCount[affect]
    if count == nil then
        return 0
    else
        return count
    end
end

function BattleHeroView:incBuffCount(affect)
    local count = self.buffRefCount[affect]
    if count == nil then
        self.buffRefCount[affect] = 1
    else
        self.buffRefCount[affect] = count + 1
    end
end

function BattleHeroView:decBuffCount(affect)
    local count = self.buffRefCount[affect]
    if count ~= nil then
        count = count -1
        if count <= 0 then
            self.buffRefCount[affect] = nil
        else
            self.buffRefCount[affect] = count
        end
    end
end

function BattleHeroView:getMagicCount(skillID)
    local count = self.magicRefCount[skillID]
    if count == nil then
        return 0
    else
        return count
    end
end

function BattleHeroView:incMagicCount(skillID)
    local count = self.magicRefCount[skillID]
    if count == nil then
        self.magicRefCount[skillID] = 1
    else
        self.magicRefCount[skillID] = count + 1
    end
end

function BattleHeroView:decMagicCount(skillID)
    local count = self.magicRefCount[skillID]
    if count ~= nil then
        count = count -1
        if count <= 0 then
            self.magicRefCount[skillID] = nil
        else
            self.magicRefCount[skillID] = count
        end
    end
end

function BattleHeroView:setAutoHideHPBar(val)
    self._autoHideHpBar = val

    self.hpBar:setVisible(not val)
    -- self.hpBg:setVisible(not val)
    -- self.hpBarShadow:setVisible(not val)
    -- self.hpBar:setVisible(not val)
end

function BattleHeroView:getAutoHideHPBar()
    return self._autoHideHpBar
end

function BattleHeroView:setupUI()
    local coro = coroutine.create(function()
        local heroShadow = cc.Sprite:createWithTexture(coroutine.yield("image/ui/img/btn/btn_249.png"))
        heroShadow:setScale(0.24)
        self:addChild(heroShadow)
        self.shadow = heroShadow

        local heroMoveMode = self.modelAttr.moveMode
        CCLog(self.modelAttr.name, " move mode:", heroMoveMode)
        if heroMoveMode == enums.HeroMoveMode.Cloud then
            local coundAni = assert(load_animation("image/spine/skill_effect/cloud/", 1, BattleConfig.SPEED_RATIO),  "load clound animation fail!")
            coundAni:addAnimation(0, "animation", true)
            self:addChild(coundAni, 1)

            table.insert(self.aniNodeList, coundAni)
        end

        local clippingNode = cc.ClippingRectangleNode:create(cc.rect(-display.width, 0, display.width * 2, display.height))
        clippingNode:setPosition(cc.p(0, 0))
        clippingNode:setClippingEnabled(false)
        self:addChild(clippingNode)
        self.clippingNode = clippingNode

        local heroAni = self:createHeroAni()
    --    local aniNames = {"move", "idle", "atk1", "atk2", "atk3", "atk_ko", "hit" }
    --    for _, ani1 in ipairs(aniNames) do
    --        for _, ani2 in ipairs(aniNames) do
    --            heroAni:setMix(ani1, ani2, 0.05)
    --        end
    --    end
        --heroAni:setMix("atk_ko", "atk_still", 0.01)

        heroAni:clearTrack(0)
        heroAni:setAnimation(0, "idle", true)
        self.clippingNode:addChild(heroAni)
        heroAni:registerSpineEventHandler(handler(self, self.onHeroSpineEvent_start), sp.EventType.ANIMATION_START)
        heroAni:registerSpineEventHandler(handler(self, self.onHeroSpineEvent_end), sp.EventType.ANIMATION_END)
        heroAni:registerSpineEventHandler(handler(self, self.onHeroSpineEvent_event), sp.EventType.ANIMATION_EVENT)
        self.heroAni = heroAni

        if self.modelAttr.isReplication then
            heroAni:setScale(heroAni:getScale() * 0.8)
        end
        self.heroScale = heroAni:getScale()

        heroAni:setTimeScale(1)
        --CCLog(vardump({boundingBox = heroAni:getBoundingBox(), heroName = self.modelAttr.name}))

        local name = self.modelAttr.name
        -- local label = cc.LabelTTF:create(name, "Arial", 15)
        -- label:setColor(self.modelAttr.teamSide == "left" and cc.c3b(255, 0, 0) or cc.c3b(0, 0, 255))
        -- label:setPosition(cc.p(0, math.random(150, 250)))
        -- self:addChild(label)
        -- self.label = label
        -- label:setVisible(false)

        -- local labelBuff = cc.LabelTTF:create("", "Arial", 12)
        -- labelBuff:setPosition(cc.p(0, 190))
        -- labelBuff:setColor(cc.c3b(0, 0, 255))
        -- self:addChild(labelBuff)
        -- self.labelBuff = labelBuff

        -- -- TODO:测试用
        -- labelBuff:setVisible(false)

        self.hpBar = HPBar.new(self.modelAttr.isBoss, self.modelAttr.teamSide)
        self:addChild(self.hpBar)

        -- local isBoss = self.modelAttr.isBoss
        -- if isBoss then
        --     local iconBoss = cc.Sprite:create("image/ui/img/btn/btn_363.png")
        --     iconBoss:setPosition(cc.p(-50, 185))
        --     iconBoss:setScale(0.5)
        --     self:addChild(iconBoss)
        --     self.iconBoss = iconBoss
        -- end

        -- local hpBgSprite = cc.Sprite:create(isBoss and "image/ui/img/btn/btn_222.png" or "image/ui/img/btn/btn_232.png")
        -- hpBgSprite:setPosition(cc.p(0, 185))
        -- hpBgSprite:setScale(0.8)
        -- self:addChild(hpBgSprite)
        -- self.hpBg = hpBgSprite

        -- local hpBarShadow = cc.ProgressTimer:create(cc.Sprite:create(isBoss and "image/ui/img/btn/btn_224.png" or "image/ui/img/btn/btn_223.png"))
        -- hpBarShadow:setPosition(cc.p(0, 185))
        -- hpBarShadow:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        -- hpBarShadow:setScale(0.8)
        -- hpBarShadow:setMidpoint(cc.p(0, 1))
        -- hpBarShadow:setBarChangeRate(cc.p(1, 0))
        -- hpBarShadow:setPercentage(100)
        -- self:addChild(hpBarShadow)
        -- self.hpBarShadow = hpBarShadow

        -- local bgImage = "image/ui/img/btn/btn_231.png"
        -- if self.modelAttr.teamSide == "right" then
        --     if isBoss then
        --         bgImage = "image/ui/img/btn/btn_221.png"
        --     else
        --         bgImage = "image/ui/img/btn/btn_230.png"
        --     end
        -- end

        -- local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
        -- hpBar:setPosition(cc.p(0, 185))
        -- hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        -- hpBar:setScale(0.8)
        -- hpBar:setMidpoint(cc.p(0, 1))
        -- hpBar:setBarChangeRate(cc.p(1, 0))
        -- hpBar:setPercentage(100)
        -- self:addChild(hpBar)
        -- self.hpBar = hpBar

        -- self.hpBg:setVisible(false)
        -- self.hpBarShadow:setVisible(false)
        -- self.hpBar:setVisible(false)

        local direction = self.modelAttr.direction
        if direction == "left" then
            self.heroAni:setRotationSkewY(180)
        else
            self.heroAni:setRotationSkewY(0)
        end
    --
    --    table.insert(self.aniNodeList, hitAni)
    end)

    start_texture_coroutine(coro)
end

function BattleHeroView:createHeroAni()
    local heroID = self.modelAttr.heroID
    local skinInfo = self.modelAttr.skinInfo

    local player = self.modelAttr.isMonster and CreatePlayer(0, 0, self.modelAttr.heroRes, skinInfo) or CreateHero(0, 0, heroID, skinInfo)
    player:setScale(player:getScale() * 0.9 * (self.modelAttr.scale or 1))
    return player
end

function BattleHeroView:setDirection(direction)
    assert(direction == "left" or direction == "right")
    if direction == "left" then
        self.heroAni:setRotationSkewY(180)
    else
        self.heroAni:setRotationSkewY(0)
    end
end

function BattleHeroView:onSubHitEvent()
    CCLog("BattleHeroView:onSubHitEvent()")
    local attackData = self.attackData

    if self.attackData then
        local skillData = attackData.skillData
        local heroID = self.modelAttr.heroID
        local skillID = skillData.id

        if not BattleConfig.heroSkillIsBulletAttack(heroID, skillID)
                and skillData.durationType == enums.SkillDurationMode.Instant and
                skillData.type == enums.SkillType.RageSkill and
                skillData.affect == enums.SkillAffectType.Damage
        then
            local targetHeroList = attackData:getTargetFighterList()
            local skillID = attackData.skillData.id

            CCLog(attackData.skillData.name, "目标数:", #targetHeroList)

            for _, heroModel in ipairs(targetHeroList) do
                local view = heroModel:getView()
                if view and not tolua.isnull(view) then
                    view:playHitAnimation(skillID, false)
                    CCLog(attackData.attacker:getName(), "sub hit:", heroModel:getName())
                end
            end
        end
    end
end

function BattleHeroView:onHeroSpineEvent_start(event)
    -- if event.trackIndex == ANI_TRACK_STATE then
    --     self.heroStateAni = event.animation
    -- elseif event.trackIndex == ANI_TRACK_ATTACK then
    --     self.inAttacking = true
    -- end

    local name = event.animation
    if ANI_TYPE_STATES[name] then
        self.heroStateAni = name
    elseif ANI_TYPE_ATTACKS[name] then
        self.inAttacking = true
    end
    self.lastHeroAni = name

    CCLog(vardump(event, self.modelAttr.name .. " heroSpineEvent"), os.clock())
end

function BattleHeroView:onHeroSpineEvent_end(event)
--    if string.find(event.animation, "atk_") then
--        self._model:onAttackEnd()
--    end

    -- if event.trackIndex == ANI_TRACK_ATTACK then
    --     self.inAttacking = false

    --     local stateAni = "idle"
    --     if self.heroStateAni ~= "" then
    --         stateAni = self.heroStateAni
    --     end

    --     self.heroAni:setAnimation(0, stateAni, true)
    -- end

    if ANI_TYPE_ATTACKS[event.animation] then
        self.inAttacking = false

        local stateAni = "idle"
        if self.heroStateAni ~= "" then
            stateAni = self.heroStateAni
        end

        self.heroAni:addAnimation(0, stateAni, true)
    end
    self.lastHeroAni = ""

    self:onAnimationEnd(event.animation)
    CCLog(vardump(event, self.modelAttr.name .. " heroSpineEvent"), os.clock())
end

function BattleHeroView:onHeroSpineEvent_event(event)
    -- self:onSubHitEvent()

--    local attackingModel = self._model._attackingModel
--    if attackingModel:inAttacking() then
--        attackingModel:onAttackComplete()
--    end
    -- CCLog(vardump(event, self.modelAttr.name .. " heroSpineEvent"), os.clock())


    local name = event.animation
    local callback = self.animationCallbacks[name]
    self.animationCallbacks[name] = nil
    if callback then        
        callback()
    end
end

function BattleHeroView:onAnimationEnd(name)
    local callback = self.animationCallbacks[name]
    if callback then
        callback()
    end
end

function BattleHeroView:setEventDispatcher(dispatcher)
    self._eventDispatcher = dispatcher
end

function BattleHeroView:dispatchEvent(eventName, data)
    local event = cc.EventCustom:new(eventName)
    event.data = data

    self._eventDispatcher:dispatchEvent(event)
end

function BattleHeroView:addEventListener(name, callback)
    local listener = cc.EventListenerCustom:create(name, callback)
    self._eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

function BattleHeroView:setLabel(text)
    --self.label:setString(text)
end

function BattleHeroView:updateHPPercent(percent)
    self.hpBar:updatePercent(percent)
    -- self.hpBar:runAction(cc.Sequence:create({
    --     cc.ProgressTo:create(0.5, percent),
    --     cc.CallFunc:create(function()
    --         self.hpBarShadow:runAction(cc.ProgressTo:create(0.1, percent))
    --     end),
    -- }))

    -- if percent > 0 then
    --     self.hpBg:setVisible(true)
    --     self.hpBarShadow:setVisible(true)
    --     self.hpBar:setVisible(true)

    --     if self._autoHideHpBar then
    --         self.hpBg:runAction(cc.Sequence:create({
    --             cc.DelayTime:create(3),
    --             cc.Hide:create(),
    --         }))
    --         self.hpBar:runAction(cc.Sequence:create({
    --             cc.DelayTime:create(3),
    --             cc.CallFunc:create(function() self.hpBarShadow:setVisible(false) end),
    --             cc.Hide:create(),
    --         }))
    --     end
    -- else
    --     self.hpBg:setVisible(false)
    --     self.hpBarShadow:setVisible(false)
    --     self.hpBar:setVisible(false)
    -- end

    if percent > 0 then
        self.hpBar:setVisible(true)

        if self._autoHideHpBar then
            self.hpBar:runAction(cc.Sequence:create({
                cc.DelayTime:create(3),
                cc.Hide:create(),
            }))
        end
    else
        self.hpBar:setVisible(false)
    end
end

function BattleHeroView:attackBegin(attackData, callback, battleModel)
    -- 冰冻中
    if self:getBuffCount(enums.BuffAffectType.Frozen) > 0 then
        if callback then
            callback()
        end
        return
    end

    CCLog(self.modelAttr.name, "attack:skillID = ".. attackData.skillData.id)
    self.attackData = attackData

    local skillData = attackData.skillData

    self:playAttackSound(skillData.type)

    local skillAniMap = {
        [enums.SkillType.NormAttack] = "atk1",
        [enums.SkillType.NormSkill] = "atk3",
        -- [enums.SkillType.InnateSkill] = "atk3",
        [enums.SkillType.RageSkill] = "atk_ko",
    }
    local atkAni = skillAniMap[skillData.type]
    --CCLog(vardump({m = self.modelAttr.isMonster, n = skillData.type == enums.SkillType.NormAttack, c = attackData.isNormAttackCritical}, "heroView:attackBegin"))
    if (not self.modelAttr.isMonster) and skillData.type == enums.SkillType.NormAttack and attackData.isNormAttackCritical then
        atkAni = "atk2"
    end

    -- 没有这个动作
    if self.heroAni:getAnimationDuration(atkAni) == 0 then
        CCLog("没有这个动作", atkAni)
        if callback then
            callback()
        end

        return
    end

    self.animationCallbacks[atkAni] = callback
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, atkAni, false)
    self.heroAni:addAnimation(0, self.heroStateAni, true)
    --CCLog(self.modelAttr.name, [[ self.heroAni:setAnimation(0, atkAni, false) ]])

--    local state = self._model:getState()
--    CCLog("attacking state:", state)
--    if state == "move" then
--        self.heroAni:addAnimation(0, "move", true)
--        --CCLog(self.modelAttr.name, [[ self.heroAni:addAnimation(0, "move", true) ]])
--    else
--        self.heroAni:addAnimation(0, "idle", true)
--        --CCLog(self.modelAttr.name, [[ self.heroAni:addAnimation(0, "idle", true) ]])
--    end

--    local label = cc.LabelTTF:create(skillData.name, "Arial", 25)
--    label:setColor(cc.c3b(0, 0, 255))
--    label:setPosition(cc.p(0, 150))
--    self:addChild(label, 9999)
--
--    table.insert(self.actionNodeList, label)
--    label:runAction(cc.Sequence:create({
--        cc.MoveBy:create(0.4, cc.p(0, 50)),
--        cc.DelayTime:create(0.3),
--        cc.CallFunc:create(function() table.removeItem(self.actionNodeList, label) end),
--        cc.RemoveSelf:create(),
--    }))

--    if skillData.type == enums.SkillType.RageSkill then
--        local label = cc.LabelTTF:create("怒", "Arial", 40)
--        label:setColor(cc.c3b(255, 0, 0))
--        label:setPosition(cc.p(0, 170))
--        self:addChild(label, 9999)
--
--        table.insert(self.actionNodeList, label)
--        label:runAction(cc.Sequence:create({
--            cc.MoveBy:create(0.4, cc.p(0, 60)),
--            cc.DelayTime:create(1),
--            cc.CallFunc:create(function() table.removeItem(self.actionNodeList, label) end),
--            cc.RemoveSelf:create(),
--        }))
--    end
end

function BattleHeroView:playAttackAnimation(skillID)
    local path = string.format("image/spine/skill_effect/skill/%d/", skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        self.heroAni:addChild(skillAni)
        skillAni:setAnimation(0, "animation", false)
        table.insert(self.aniNodeList, skillAni)
        skillAni:registerSpineEventHandler(function(event)
            skillAni:runAction(cc.Sequence:create({
                cc.CallFunc:create(function() table.removeItem(self.aniNodeList, skillAni) end),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)
    end

    local path = string.format("image/spine/skill_effect/skill/%d/bottom", skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        self.heroAni:addChild(skillAni, -1)
        skillAni:setAnimation(0, "animation", false)
        table.insert(self.aniNodeList, skillAni)
        skillAni:registerSpineEventHandler(function(event)
            skillAni:runAction(cc.Sequence:create({
                cc.CallFunc:create(function() table.removeItem(self.aniNodeList, skillAni) end),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)
    end

    local path = string.format("image/spine/skill_effect/skill/%d/top/", skillID)
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        self.heroAni:addChild(skillAni)
        skillAni:setAnimation(0, "animation", false)
        table.insert(self.aniNodeList, skillAni)
        skillAni:registerSpineEventHandler(function(event)
            skillAni:runAction(cc.Sequence:create({
                cc.CallFunc:create(function() table.removeItem(self.aniNodeList, skillAni) end),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)
    end
end

function BattleHeroView:playAttackSound(skillType)
    local heroID = self.modelAttr.heroID

    if self.modelAttr.isMonster then
        local heroRes = self.modelAttr.heroRes
        if string.sub(heroRes, 1, 3) == "xj_" then
            heroID = tonumber(string.sub(heroRes, 4), 10)
        end
    end

    local soundInfo = BaseConfig.GetSoundHero(heroID)
    local soundFile = nil

    local hasSound = false
    if soundInfo then
        --CCLog("sound file", vardump(soundInfo))
        if skillType == enums.SkillType.NormAttack then
            soundFile = soundInfo.AtkSkill
        elseif skillType == enums.SkillType.NormSkill then
            soundFile = soundInfo.NorSkill
        elseif skillType == enums.SkillType.RageSkill then
            soundFile = soundInfo.RpSkill
        end

        if soundFile then
            Common.playSound(cc.FileUtils:getInstance():fullPathForFilename("audio/hero/" .. soundFile .. ".mp3"), false)
            hasSound = true
        end
    else
        --CCLog("no sound file", heroID, skillType)
    end

    if not hasSound then
        local soundFile = "ack_0" .. math.random(0, 7)
        Common.playSound(cc.FileUtils:getInstance():fullPathForFilename("audio/hero/" .. soundFile .. ".mp3"), false)
    end
end

function BattleHeroView:playHitSound(heroID, skillType)
    local soundInfo = BaseConfig.GetSoundHero(heroID)
    local soundFile = nil

    local hasSound = false
    if soundInfo then
        --CCLog("sound file", vardump(soundInfo))
        if skillType == enums.SkillType.NormAttack then
            soundFile = soundInfo.AtkSkill
        elseif skillType == enums.SkillType.NormSkill then
            soundFile = soundInfo.NorSkill
        elseif skillType == enums.SkillType.RageSkill then
            soundFile = soundInfo.RpSkill
        end

        if soundFile then
            Common.playSound(cc.FileUtils:getInstance():fullPathForFilename("audio/hero/" .. soundFile .. ".mp3"), false)
            hasSound = true
        end
    end
end

function BattleHeroView:attackComplete(attackData)
    local skillID = attackData.skillData.id

    local function playEffect()
    end
end

function BattleHeroView:attackBreakOff(attackData)
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, self.lastStateAni, true)
    self.attackData = nil
end

function BattleHeroView:onContinuousSkillBegin(skillID)
    local function playContinuousSkillAni()
        self.heroAni:clearTrack(0)
        self.heroAni:setAnimation(0, "atk_still", true)

        if skillID == 1319 then
            local animation = load_animation("res/image/spine/skill_effect/skill/1319")
            animation:setAnimation(0, "animation", true)
            animation:setName("atk_still_ani")
            self.heroAni:addChild(animation)
        end
    end

    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(BattleConfig.TIME_UNIT * 3),
        cc.CallFunc:create(playContinuousSkillAni),
    }))
end

function BattleHeroView:onContinuousSkillEnd(skillID)   
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, self.heroStateAni, true)

    if skillID == 1319 then
        self.heroAni:removeChildByName("atk_still_ani")
    end
end

function BattleHeroView:performRageSkill(attackData)
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, "atk_ko", false)
    self.heroAni:addAnimation(0, self.heroStateAni, true)
end

function BattleHeroView:playHitAnimation(skillID, floatEnable)
    local skillData = BaseConfig.GetHeroSkill(skillID, 1)
    local defense = self:getBuffCount(enums.BuffAffectType.AddDEFRatio) > 0

    if floatEnable and skillData.Cickflt and skillData.Cickflt > 0 then
        if self.lastHeroAni ~= "float" then
            self:float()
            self.heroAni:runAction(cc.Sequence:create({
                cc.JumpTo:create(0.4, cc.p(0, 0), 180, 1),
                cc.Place:create(cc.p(0, 0)),
            }))
        end
    else            
        if (not defense) and (not self.inAttacking) and (self.heroAni:getChildByName("atk_still_ani") == nil) then
            self.heroAni:clearTrack(0)
            self.heroAni:setAnimation(0, "hit", false)
            self.heroAni:addAnimation(0, self.heroStateAni, true)
        end
    end

    local skillAni = load_animation(string.format("image/spine/skill_effect/hit/%d/", skillID), 1, BattleConfig.SPEED_RATIO)
    if not skillAni then
        skillAni = load_animation(string.format("image/spine/skill_effect/hit/%d/", 1000), 1, BattleConfig.SPEED_RATIO)
    end
    skillAni:setPosition(cc.p(0, 0))
    skillAni:setAnimation(0, "animation", false)
    skillAni:setLocalZOrder(0)
    self:addChild(skillAni)

    
    if skillID == 1348 or skillID == 1319 then
        -- 雷震子 二郎神
        self:playHitSound(1048, enums.SkillType.RageSkill)
    end
    
    if skillID == 1346 or skillID == 1348 or skillID == 1319 then -- 电击和烧焦
        self.heroAni:setVisible(false)
        self.heroAni:runAction(cc.Sequence:create({
            cc.DelayTime:create(skillAni:getAnimationDuration("animation")), 
            cc.CallFunc:create(function() 
                self.heroAni:setVisible(true)
            end)}
        ))
    end

    table.insert(self.aniNodeList, skillAni)
    skillAni:registerSpineEventHandler(function(event)
        skillAni:runAction(cc.Sequence:create({
            cc.Hide:create(),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function() table.removeItem(self.aniNodeList, skillAni) end),
            cc.RemoveSelf:create(),
        }))
    end, sp.EventType.ANIMATION_END)
end

function BattleHeroView:playDropCoin()
    local skillAni = load_animation("image/spine/skill_effect/dropcoin", 1, BattleConfig.SPEED_RATIO)
    skillAni:setPosition(cc.p(0, 0))
    skillAni:setAnimation(0, "animation", false)
    skillAni:setLocalZOrder(0)
    self:addChild(skillAni)   

    table.insert(self.aniNodeList, skillAni)
    skillAni:registerSpineEventHandler(function(event)
        skillAni:runAction(cc.Sequence:create({
            cc.Hide:create(),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function() table.removeItem(self.aniNodeList, skillAni) end),
            cc.RemoveSelf:create(),
        }))
    end, sp.EventType.ANIMATION_END)
end

function BattleHeroView:hit(damage, skillID, restraint, critical)
    CCLog(string.format("受攻: {伤害:%d, 技能:%d}", damage, skillID))

    self:playHitAnimation(skillID, true)
    self:hpChange(-damage, restraint, critical)
--    self:updateHPBar()
end

function BattleHeroView:float()
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, "float", false)
    self.heroAni:addAnimation(0, self.heroStateAni, true)
end

function BattleHeroView:miss()
    local atlasPath = "image/ui/img/btn/btn_469.png"
    local label = cc.LabelAtlas:_create("01", atlasPath, 27, 28,  string.byte("0"))

    label:setPosition(cc.p(0, 150))
    self:addChild(label, 9999)

    table.insert(self.actionNodeList, label)
    label:runAction(cc.Sequence:create({
        cc.MoveBy:create(0.4, cc.p(0, 50)),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() table.removeItem(self.actionNodeList, label) end),
        cc.RemoveSelf:create(),
    }))
end

function BattleHeroView:immune()
    local atlasPath = "image/ui/img/btn/btn_469.png"
    local label = cc.LabelAtlas:_create("45", atlasPath, 27, 28,  string.byte("0"))
    
    label:setPosition(cc.p(0, 150))
    self:addChild(label, 9999)

    table.insert(self.actionNodeList, label)
    label:runAction(cc.Sequence:create({
        cc.MoveBy:create(0.4, cc.p(0, 50)),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() table.removeItem(self.actionNodeList, label) end),
        cc.RemoveSelf:create(),
    }))
end

function BattleHeroView:crit()
    local sprite = cc.Sprite:create("image/ui/img/btn/btn_470.png")
    sprite:setPosition(cc.p(0, 150))
    self:addChild(sprite, 9999)

    table.insert(self.actionNodeList, sprite)
    sprite:runAction(cc.Sequence:create({
        cc.MoveBy:create(0.4, cc.p(0, 50)),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() table.removeItem(self.actionNodeList, sprite) end),
        cc.RemoveSelf:create(),
    }))
end

function BattleHeroView:hitBuffAffect(affect)
    self:immune()
--    local affectName = {
--        [enums.BuffAffectType.MetalShield ] = "金属性护盾",
--        [enums.BuffAffectType.WoodShield ] = "木属性护盾",
--        [enums.BuffAffectType.WaterShield] = "水属性护盾",
--        [enums.BuffAffectType.FireShield ] = "火属性护盾",
--        [enums.BuffAffectType.EarthShield] = "土属性护盾",
--        [enums.BuffAffectType.SpellShield] = "法术盾",
--    }
--    local name = affectName[affect] or string.format("BUFF效果:%d", affect)
--    local label = cc.LabelTTF:create(name, "Arial", 28)
--    label:setColor(cc.c3b(0, 0, 255))
--    label:setPosition(cc.p(0, 150))
--    self:addChild(label, 9999)
--
--    table.insert(self.actionNodeList, label)
--    label:runAction(cc.Sequence:create({
--        cc.MoveBy:create(0.5, cc.p(0, 50)),
--        cc.DelayTime:create(0.8),
--        cc.CallFunc:create(function() table.removeItem(self.actionNodeList, label) end),
--        cc.RemoveSelf:create(),
--    }))
end

function BattleHeroView:resurrect()
    local resurrectionAni = load_animation("image/spine/skill_effect/resurrection/", 1, BattleConfig.SPEED_RATIO)
    resurrectionAni:setAnimation(0, "animation", false)
    self:addChild(resurrectionAni)
    table.insert(self.aniNodeList, resurrectionAni)
    resurrectionAni:registerSpineEventHandler(function(event)
        CCLog(vardump(event, "resurrect ani"))
        self:runAction(cc.Sequence:create({
            cc.CallFunc:create(function() table.removeItem(self.aniNodeList, resurrectionAni) end),
            cc.CallFunc:create(function() resurrectionAni:removeFromParent() end),
        }))
    end, sp.EventType.ANIMATION_END)
end

function BattleHeroView:treated(hp)
    self:removeChildByName("ani_treated_floor")
    self:removeChildByName("ani_treated")

    local tratedFloorAni = load_animation("image/spine/skill_effect/treated/bottom/", 0.75, BattleConfig.SPEED_RATIO)
    tratedFloorAni:setName("ani_treated_floor")
    tratedFloorAni:setTimeScale(0.4)
    tratedFloorAni:setAnimation(0, "animation", false)
    self:addChild(tratedFloorAni, -1)
    table.insert(self.aniNodeList, tratedFloorAni)
    tratedFloorAni:registerSpineEventHandler(function(event)
        CCLog(vardump(event, "treated floor ani"))
        self:runAction(cc.Sequence:create({
            cc.CallFunc:create(function() table.removeItem(self.aniNodeList, tratedFloorAni) end),
            cc.CallFunc:create(function() tratedFloorAni:removeFromParent() end),
        }))
    end, sp.EventType.ANIMATION_COMPLETE)

    local tratedAni = load_animation("image/spine/skill_effect/treated/top/", 0.75, BattleConfig.SPEED_RATIO)
    tratedAni:setName("ani_treated")
    tratedAni:setTimeScale(0.4)
    tratedAni:setAnimation(0, "animation", false)
    self:addChild(tratedAni)
    table.insert(self.aniNodeList, tratedAni)
    tratedAni:registerSpineEventHandler(function(event)
        CCLog(vardump(event, "treated ani"))
        self:runAction(cc.Sequence:create({
            cc.CallFunc:create(function() table.removeItem(self.aniNodeList, tratedAni) end),
            cc.CallFunc:create(function() tratedAni:removeFromParent() end),
        }))
    end, sp.EventType.ANIMATION_COMPLETE)
end

function BattleHeroView:friendGuard()
    local function fadeIn()
        local fadeinAni = load_animation("image/spine/ui_effect/8/", 1, BattleConfig.SPEED_RATIO)
        fadeinAni:setTimeScale(2)
        fadeinAni:setAnimation(0, "animation", false)
        self:addChild(fadeinAni)

        table.insert(self.aniNodeList, fadeinAni)
        fadeinAni:registerSpineEventHandler(function(event)
            self:runAction(cc.CallFunc:create(function()
                self.heroAni:runAction(cc.FadeIn:create(0.05))
                table.removeItem(self.aniNodeList, fadeinAni)
                fadeinAni:removeFromParent()
            end))
        end, sp.EventType.ANIMATION_COMPLETE)
    end

    fadeIn()
end

function BattleHeroView:relineup(pos)
    self:removeChildByName("ani_treated_floor")
    self:removeChildByName("ani_treated")
    
    local function fadeIn()
        local fadeinAni = load_animation("image/spine/ui_effect/8/", 1, BattleConfig.SPEED_RATIO)
        fadeinAni:setTimeScale(2)
        fadeinAni:setAnimation(0, "animation", false)
        self:addChild(fadeinAni)

        table.insert(self.aniNodeList, fadeinAni)
        fadeinAni:registerSpineEventHandler(function(event)
            self:runAction(cc.CallFunc:create(function()
                self.heroAni:runAction(cc.FadeIn:create(0.05))
                table.removeItem(self.aniNodeList, fadeinAni)
                fadeinAni:removeFromParent()
            end))
        end, sp.EventType.ANIMATION_COMPLETE)
    end

    local fadeoutAni = load_animation("image/spine/ui_effect/9/", 1, BattleConfig.SPEED_RATIO)
    fadeoutAni:setTimeScale(2)
    fadeoutAni:setAnimation(0, "animation", false)
    self:addChild(fadeoutAni)
    table.insert(self.aniNodeList, fadeoutAni)
    fadeoutAni:registerSpineEventHandler(function(event)
        self:runAction(cc.Sequence:create({
            cc.CallFunc:create(function()
                self.heroAni:runAction(cc.FadeOut:create(0.05))
                table.removeItem(self.aniNodeList, fadeoutAni)
                fadeoutAni:removeFromParent()
                self:setPosition(pos)
                fadeIn()
            end),
        }))
    end, sp.EventType.ANIMATION_COMPLETE)
end


function BattleHeroView:teleport()
    local fadeoutAni = load_animation("image/spine/ui_effect/9/", 1, BattleConfig.SPEED_RATIO)
    fadeoutAni:setAnimation(0, "animation", false)
    self:addChild(fadeoutAni)
    table.insert(self.aniNodeList, fadeoutAni)
    fadeoutAni:registerSpineEventHandler(function(event)
        self:runAction(cc.Sequence:create({
            cc.CallFunc:create(function()
                table.removeItem(self.aniNodeList, fadeoutAni)
                fadeoutAni:removeFromParent()
            end),
        }))
    end, sp.EventType.ANIMATION_COMPLETE)
end

function BattleHeroView:die()
    self:resumeBattle()
    self:continuousHitClear()
    
    if self.eggAni then
        self.eggAni:setVisible(false)
    end

    self.heroAni:stopAllActions()
    self.heroAni:setVisible(false)

    local deadType = BaseConfig.GetDead(self.modelAttr.heroRes)
    local aniPath = deadType == 2 and "image/spine/skill_effect/death/" or  "image/spine/skill_effect/die/"
    local dieAni = load_animation(aniPath, 0.75, BattleConfig.SPEED_RATIO)
    dieAni:setTimeScale(0.6)
    dieAni:setAnimation(0, "animation", false)
    dieAni:setCascadeOpacityEnabled(true)
    self:addChild(dieAni)
    
    dieAni:runAction(cc.FadeOut:create(3.0))

    table.insert(self.aniNodeList, dieAni)
    dieAni:registerSpineEventHandler(function(event)
        CCLog(vardump(event, "die ani"))
        self:runAction(cc.Sequence:create({
            cc.FadeOut:create(3.0),
            cc.CallFunc:create(function() table.removeItem(self.aniNodeList, dieAni) end),
            cc.CallFunc:create(function() dieAni:removeFromParent() end),
        }))
    end, sp.EventType.ANIMATION_COMPLETE)
    self:runAction(cc.Sequence:create({
        cc.DelayTime:create(3.0),
        cc.RemoveSelf:create(),
    }))

    self.shadow:setVisible(false)
    self.hpBar:setVisible(false)
    -- if self.iconBoss then
    --     self.iconBoss:setVisible(false)
    -- end
    -- self.hpBar:setVisible(false)
    -- self.hpBarShadow:setVisible(false)
    -- self.hpBg:setVisible(false)
end

function BattleHeroView:expired(fadeoutTime)
    self:resumeBattle()

    self:runAction(cc.Sequence:create({
        cc.FadeOut:create(fadeoutTime),
        cc.RemoveSelf:create(),
    }))
end

function BattleHeroView:buffAddedAni(skillID)
    local fileUtils = cc.FileUtils:getInstance()

    local buffAddAni = load_animation(string.format("image/spine/skill_effect/buffadd/%d/", skillID), 1, BattleConfig.SPEED_RATIO)
    if buffAddAni then
        buffAddAni:setAnimation(0, "animation", false)
        self:addChild(buffAddAni)
        table.insert(self.aniNodeList, buffAddAni)
        buffAddAni:registerSpineEventHandler(function(event)
            self:runAction(cc.Sequence:create({
                cc.CallFunc:create(function() table.removeItem(self.aniNodeList, buffAddAni) end),
                cc.CallFunc:create(function() buffAddAni:removeFromParent() end),
            }))
        end, sp.EventType.ANIMATION_END)
    else
        local topAni = load_animation(string.format("image/spine/skill_effect/buffadd/%d/top/", skillID), 1, BattleConfig.SPEED_RATIO)
        if topAni then
            topAni:setTimeScale(1)
            topAni:setAnimation(0, "animation", false)
            topAni:setLocalZOrder(self.heroAni:getLocalZOrder() + 1)
            self:addChild(topAni)
            table.insert(self.aniNodeList, topAni)
            topAni:registerSpineEventHandler(function(event)
                self:runAction(cc.Sequence:create({
                    cc.CallFunc:create(function() table.removeItem(self.aniNodeList, topAni) end),
                    cc.CallFunc:create(function() topAni:removeFromParent() end),
                }))
            end, sp.EventType.ANIMATION_COMPLETE)
        end

        local bottomAni = load_animation(string.format("image/spine/skill_effect/buffadd/%d/bottom/", skillID), 1, BattleConfig.SPEED_RATIO)
        if bottomAni then
            bottomAni:setTimeScale(1)
            bottomAni:setAnimation(0, "animation", false)
            bottomAni:setLocalZOrder(self.heroAni:getLocalZOrder() - 1)
            self:addChild(bottomAni)
            table.insert(self.aniNodeList, bottomAni)
            bottomAni:registerSpineEventHandler(function(event)
                self:runAction(cc.Sequence:create({
                    cc.CallFunc:create(function() table.removeItem(self.aniNodeList, bottomAni) end),
                    cc.CallFunc:create(function() bottomAni:removeFromParent() end),
                }))
            end, sp.EventType.ANIMATION_END)
        end
    end
end

function BattleHeroView:buffAdded(buffModel)
    self:buffChanged()
    
    local skillID = buffModel:getSkillID()
    self:buffAddedAni(skillID)

    local buffID = buffModel:getBuffID()
    local buffData = buffModel:getBuffData()

    self:incBuffCount(buffData.affect)

    if buffData.affect == enums.BuffAffectType.AddDEFRatio and skillID == 1329 then
        self.heroAni:clearTrack(0)
        self.heroAni:setAnimation(0, "defense", true)
    end

    -- 隐身
    if buffData.affect == enums.BuffAffectType.Hide then
        self.heroAni:setOpacity(128)
    end

    -- 冰冻
    if buffData.affect == enums.BuffAffectType.Frozen then
        self.heroAni:setPaused(true)

        self:onAnimationEnd("atk_ko")
    end

    -- 禁锢
    if buffData.affect == enums.BuffAffectType.Shackle then
        self.heroAni:setVisible(false)
    end

    local resID = buffData.res
    if resID == 0 then
        return
    end

    -- 资源为3001BUFF特殊处理
    --if resID == 3001 then
    --    self:fallIntoTrap()
    --    return
    --end

    CCLog("buffAdded: resID", resID)
    local fileUtils = cc.FileUtils:getInstance()
    local aniPath = string.format("image/spine/skill_effect/buff/%d/", resID)
    local topAniPath   = string.format("image/spine/skill_effect/buff/%d/top/", resID)
    local bottomAniPath   = string.format("image/spine/skill_effect/buff/%d/bottom/", resID)

    local buffAni = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
    if buffAni then
        buffAni:setName("buffAni_" .. buffID)
        buffAni:setAnimation(0, "animation", true)
        buffAni:setLocalZOrder(1)
        self.heroAni:addChild(buffAni)

        local buffPos = BattleConfig.getHeroBuffPos(0, resID)

        buffAni:setPosition(buffPos)
        buffAni:setTimeScale(1)
        buffAni:setScale(1)

        table.insert(self.aniNodeList, buffAni)
    else
        local buffTopAni = load_animation(topAniPath, 1, BattleConfig.SPEED_RATIO)
        if buffTopAni then
            buffTopAni:setName("buffAni_top_" .. buffID)
            buffTopAni:setAnimation(0, "animation", true)
            buffTopAni:setLocalZOrder(1)
            self.heroAni:addChild(buffTopAni)

            local buffPos = BattleConfig.getHeroBuffPos(0, resID)

            buffTopAni:setPosition(buffPos)
            buffTopAni:setTimeScale(1)
            buffTopAni:setScale(1)

            table.insert(self.aniNodeList, buffTopAni)
        end

        local buffBottomAni = load_animation(bottomAniPath, 1, BattleConfig.SPEED_RATIO)
        if buffBottomAni then
            buffBottomAni:setName("buffAni_bottom_" .. buffID)
            buffBottomAni:setAnimation(0, "animation", true)
            buffBottomAni:setLocalZOrder(-1)
            self.heroAni:addChild(buffBottomAni)

            local buffPos = BattleConfig.getHeroBuffPos(0, resID)

            buffBottomAni:setPosition(buffPos)
            buffBottomAni:setTimeScale(1)
            buffBottomAni:setScale(1)

            table.insert(self.aniNodeList, buffBottomAni)
        end
    end

--        local label = cc.LabelTTF:create(buffModel:getBuffDesc(), "Arial", 20)
--        label:setColor(cc.c3b(255, 255, 0))
--        label:setPosition(cc.p(0, 150))
--        self:addChild(label, 9999)
--
--        table.insert(self.actionNodeList, label)
--        label:runAction(cc.Sequence:create({
--            cc.Spawn:create({
--                cc.MoveBy:create(0.4, cc.p(0, 50)),
--                cc.ScaleBy:create(0.4, 0.9),
--            }),
--            cc.DelayTime:create(0.4),
--            cc.FadeOut:create(0.2),
--            cc.CallFunc:create(function() table.removeItem(self.actionNodeList, label) end),
--            cc.RemoveSelf:create(),
--        }))
--

end

function BattleHeroView:buffRemoved(buffModel)
    CCLog("buffRemoved " .. buffModel:getBuffDesc())
    -- TODO:
    local skillID = buffModel:getSkillID()
    local buffData = buffModel.buffData

    self:decBuffCount(buffData.affect)

    if buffData.affect == enums.BuffAffectType.AddDEFRatio and skillID == 1329 then
        CCLog("idle", self:getName())
        self.heroAni:setAnimation(0, "idle", true)
    end

    if buffData.affect == enums.BuffAffectType.Hide then
        local buffRefCount = self:getBuffCount(buffData.affect)
        CCLog("隐身BUFF数量", buffRefCount)
        if buffRefCount == 0 then
            self.heroAni:setOpacity(255)
        end
    end

    if buffData.affect == enums.BuffAffectType.Frozen then        
        local buffRefCount = self:getBuffCount(buffData.affect)
        CCLog("冰冻BUFF数量", buffRefCount)
        if buffRefCount == 0 then
            self.heroAni:setPaused(false)
        end
    end

    if buffData.affect == enums.BuffAffectType.Shackle then        
        local buffRefCount = self:getBuffCount(buffData.affect)
        CCLog("禁锢BUFF数量", buffRefCount)
        if buffRefCount == 0 then
            self.heroAni:setVisible(true)
        end
    end

    local buffData = buffModel:getBuffData()
    local resID = buffData.res
    -- 资源为3001BUFF特殊处理
    if resID == 3001 then
        self:getOutOfTrap()
        return
    end

    local buffID = buffModel:getBuffID()
    local names = {"buffAni_", "buffAni_top_", "buffAni_bottom_"}
    for _, name in ipairs(names) do
        local buffAniName = name .. buffID
        local buffAniNode = self.heroAni:getChildByName(buffAniName)
        if buffAniNode and not tolua.isnull(buffAniNode) then
            table.removeItem(self.aniNodeList, buffAniNode)
            buffAniNode:removeFromParent()
        end
    end
--
--    self:buffChanged()
end

function BattleHeroView:buffReplaced(oldBuffModel, newBuffModel)
    CCLog("buffReplaced" .. oldBuffModel:getBuffDesc())

--    local label = cc.LabelTTF:create(buffModel:getBuffDesc(), "Arial", 20)
--    label:setColor(cc.c3b(255, 255, 0))
--    label:setPosition(cc.p(0, 150))
--    self:addChild(label, 9999)
--
--    label:runAction(cc.Sequence:create({
--        cc.Spawn:create({
--            cc.ScaleTo:create(0.6, 0.8),
--            cc.FadeOut:create(0.6),
--            cc.MoveBy:create(0.6, cc.p(0, 100)),
--        }),
--        cc.DelayTime:create(0.5),
--        cc.RemoveSelf:create(),
--    }))

    self:buffChanged()
end

function BattleHeroView:magicCircleAdded(skillID)
    self:incMagicCount(skillID)
    local refCount = self:getMagicCount(skillID) 
    CCLog(string.format("+ 魔法阵[%d]计数:%d", skillID, refCount))
    if refCount == 1 then
        local aniPath = string.format("image/spine/skill_effect/magic/%d/", skillID)
        local magicAni = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
        if magicAni then
            local magicName = "follow_magic_" .. skillID
            magicAni:setName(magicName)
            magicAni:setAnimation(0, "animation", true)
            magicAni:setLocalZOrder(1)
            self:addChild(magicAni)
            magicAni:setPosition(cc.p(0, 250))
            magicAni:setTimeScale(1)
            magicAni:setScale(1)

            table.insert(self.aniNodeList, magicAni)
        end

        local aniBottomPath = string.format("image/spine/skill_effect/magic/%d/bottom/", skillID)
        local magicBottomAni = load_animation(aniBottomPath, 1, BattleConfig.SPEED_RATIO)
        if magicBottomAni then
            local magicName = "follow_magic_bottom_" .. skillID
            magicBottomAni:setName(magicName)
            magicBottomAni:setAnimation(0, "animation", true)
            magicBottomAni:setLocalZOrder(-10000)
            self:addChild(magicBottomAni)
            magicBottomAni:setPosition(cc.p(0, 0))
            magicBottomAni:setTimeScale(1)
            magicBottomAni:setScale(1)

            table.insert(self.aniNodeList, magicBottomAni)
        end
    end
end

function BattleHeroView:magicCircleRemoved(skillID)
    self:decMagicCount(skillID)
    local refCount = self:getMagicCount(skillID) 
    CCLog(string.format("- 魔法阵[%d]计数:%d", skillID, refCount))
    if refCount == 0 then
        local magicName = "follow_magic_" .. skillID
        local magicNode = self:getChildByName(magicName)
        if magicNode and not tolua.isnull(magicNode) then
            table.removeItem(self.aniNodeList, magicNode)
            magicNode:removeFromParent()
        end

        local magicBottomName = "follow_magic_bottom_" .. skillID
        local magicBottomNode = self:getChildByName(magicName)
        if magicBottomNode and not tolua.isnull(magicBottomNode) then
            table.removeItem(self.aniNodeList, magicBottomNode)
            magicBottomNode:removeFromParent()
        end
    end
end

function BattleHeroView:continuousSkillBegin(skillID)

end

function BattleHeroView:continuousSkillEnd(skillID)

end

function BattleHeroView:continuousHitBegin(skillID)
    table.insert(self.continuousHitList, skillID)

    local aniPath = string.format("image/spine/skill_effect/continuoushit/%d/top/", skillID)
    local skillAni = load_animation(aniPath, 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        local aniName = "continuous_hit_ani_" .. skillID
        skillAni:setName(aniName)
        skillAni:setAnimation(0, "animation", true)
        skillAni:setLocalZOrder(1)
        self:addChild(skillAni)

        table.insert(self.aniNodeList, skillAni)
    end

    local fileUtils = cc.FileUtils:getInstance()
    local aniBottomPath = string.format("image/spine/skill_effect/continuoushit/%d/bottom/floor.png", skillID)
    if fileUtils:isFileExist(aniBottomPath) then
        local aniBGImg = cc.Sprite:create(aniBottomPath)
        local aniBgName = "continuous_hit_bg_" .. skillID
        aniBGImg:setName(aniBgName)
        aniBGImg:setLocalZOrder(-1)
        self:addChild(aniBGImg)
    end
end

function BattleHeroView:continuousHitEnd(skillID)
    table.removeItem(self.continuousHitList, skillID)

    local aniBgName = "continuous_hit_bg_" .. skillID
    local aniName = "continuous_hit_ani_" .. skillID

    local bgNode = self:getChildByName(aniBgName)
    if bgNode and not tolua.isnull(bgNode) then
        bgNode:removeFromParent()
    end

    local aniNode = self:getChildByName(aniName)
    if aniNode and not tolua.isnull(aniNode) then
        table.removeItem(self.aniNodeList, aniNode)
        aniNode:removeFromParent()
    end
end

function BattleHeroView:continuousHitClear()
    for _, skillID in ipairs(self.continuousHitList) do
        self:continuousHitEnd(skillID)
    end
end

function BattleHeroView:buffChanged()
    -- TODO:
--    if true then
--        local descList = {}
--        local buffList = self._model:getBuffManager():getActiveBuffList()
--        for _, buffModel in ipairs(buffList) do
--            local desc = buffModel:getBuffDesc()
--            table.insert(descList, desc)
--        end
--
--        self.labelBuff:setString(table.concat(descList, "\n"))
--    end
end

function BattleHeroView:reset()
--    local direction = self._model:getDirection()
--    self.heroAni:setPosition(cc.p(0, 0))
--    if direction == "left" then
--        self.heroAni:setRotationSkewY(180)
--        self.hitAni:setPosition(cc.p(-10, 50))
--    else
--        self.heroAni:setRotationSkewY(0)
--        self.hitAni:setPosition(cc.p(10, 50))
--    end
end

function BattleHeroView:ready()
    if self.heroStateAni == "idle" then
        return
    end
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, "idle", true)
end

function BattleHeroView:idle()
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, "idle", true)
end

function BattleHeroView:walk(immediately)
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, "move", true)
--    if immediately or self.heroStateAni ~= "move" then
--        self.heroAni:setAnimation(ANI_TRACK_STATE, "move", true)
--    else
--        self.heroAni:addAnimation(ANI_TRACK_STATE, "move", true)
--    end
end

function BattleHeroView:win()
    self.heroAni:clearTrack(0)
    self.heroAni:setAnimation(0, "victory", true)

     Common.playSound("audio/effect/hero_show.mp3")
end

function BattleHeroView:inAttackScope(inScope, isTeammate)
    if inScope then
        if isTeammate then
            self.heroAni:setColorFactor(cc.c4f(0.5, 255, 0.5, 1))
        else
            self.heroAni:setColorFactor(cc.c4f(255, 0.5, 0.5, 1))
        end
        
        local selectMark = cc.Sprite:create("image/ui/img/btn/btn_1177.png")
        selectMark:setName("selectMark")
        selectMark:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.MoveBy:create(0.3, cc.p(0, -10)), cc.MoveBy:create(0.3, cc.p(0, 10))})))
        selectMark:setPosition(cc.p(0, 220))
        self:addChild(selectMark)
    else
        self.heroAni:setColorFactor(cc.c4f(1, 1, 1, 1))

        local selectMark = self:getChildByName("selectMark")
        if selectMark ~= nil then
            selectMark:removeFromParent()
        end
    end
end

function BattleHeroView:timeout()
    self.heroAni:setPaused(true)
end

function BattleHeroView:pauseBattle()
    self.heroAni:setPaused(true)

    for _, actionNode in ipairs(self.actionNodeList) do
        actionNode:pause()
    end

    for _, aniNode in ipairs(self.aniNodeList) do
        if not tolua.isnull(aniNode) then
            aniNode:setPaused(true)
        end
    end

    self:pause()

    self._paused = true
end

function BattleHeroView:resumeBattle()
    if self:getBuffCount(enums.BuffAffectType.Frozen) == 0 then
        self.heroAni:setPaused(false)
    end
    
    for _, actionNode in ipairs(self.actionNodeList) do
        actionNode:resume()
    end

    for _, aniNode in ipairs(self.aniNodeList) do
        if not tolua.isnull(aniNode) then
            aniNode:setPaused(false)
        end
    end

    self:resume()

    self._paused = false
end

function BattleHeroView:hpChange(hp, restraint, critical)
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

        self:addChild(hintNode, 9999)
        table.insert(self.actionNodeList, hintNode)
        hintNode:setScale(0.7)
        hintNode:runAction(cc.Sequence:create({
            cc.Spawn:create({cc.MoveBy:create(0.25, cc.p(0, 70)), cc.ScaleTo:create(0.25, 1.3)}),
            cc.ScaleTo:create(0.05, 1),
            cc.DelayTime:create(0.3),
            cc.Spawn:create({cc.MoveBy:create(0.3, cc.p(0, 40)), cc.FadeOut:create(0.3)}),
            cc.CallFunc:create(function() table.removeItem(self.actionNodeList, hintNode) end),
            cc.RemoveSelf:create(),
        }))
    else
        if restraint then
            local atlasPath = "image/ui/img/btn/btn_469.png"
            local label = cc.LabelAtlas:_create("23", atlasPath, 27, 28,  string.byte("0"))
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(cc.p(width, height / 2))
            hintNode:addChild(label)

            width = width + 54
        end

        local sign = hp > 0 and ":" or "" -- --string.chr(string.byte("9")+1)
        local hp_str = sign .. "" .. math.abs(math.floor(hp))
        local label
        if hp > 0 then
            label = cc.LabelAtlas:_create(hp_str, "image/atlas/numgreen.png", 18, 27,  string.byte("0"))
            label:setScale(1.2)
        else
            label = cc.LabelAtlas:_create(hp_str, "image/atlas/numred.png", 30, 39,  string.byte("0"))
            label:setScale(0.6)
        end

        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(cc.p(width, height / 2))
        hintNode:addChild(label, 9999)
        width = width + #hp_str * 27 * 1.5

        hintNode:setContentSize(cc.size(width, height))
        hintNode:setAnchorPoint(cc.p(0.5, 0.5))
        hintNode:setPosition(cc.p(0, 160))

        self:addChild(hintNode, 9999)
        table.insert(self.actionNodeList, hintNode)
        hintNode:runAction(cc.Sequence:create({
            cc.ScaleTo:create(0.2, 1.3),
            cc.Spawn:create({
                cc.MoveBy:create(0.5, cc.p(0, 70)),
                cc.FadeTo:create(0.5, 0.3),
            }),
            cc.CallFunc:create(function() table.removeItem(self.actionNodeList, hintNode) end),
            cc.RemoveSelf:create(),
        }))
    end
end

-- 状态变化
function BattleHeroView:stateChanged(old, new)
    --self.label:setString(new)

    if new == "ready" then
        self:ready()
    elseif new == "walk" then
        self:walk()
    end
end

-- 随机说话
function BattleHeroView:randomDialogue(dialogueArray)
    local len = #dialogueArray
    local index = math.random(1, len)
    local text = dialogueArray[index]

    self:dialogue(text)
end

-- 说话
function BattleHeroView:dialogue(message)
    local pos = cc.p(30, 170)
    local bg = cc.Sprite:create("image/spine/skill_effect/msg_talk.png")
    bg:setScale(0.1)
    bg:setPosition(pos)
    self:addChild(bg, 9999)

    local text = cc.LabelTTF:create(message, "Arial", 15)
    text:setGlobalZOrder(9999)
    text:setDimensions(cc.size(100, 90 ))
    text:setPosition(cc.p(126 / 2, 113 / 2 + 20))
    text:setAnchorPoint(cc.p(0.5, 0.5))
    if #message < 20 then
        text:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    else
        text:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    end

    text:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    bg:addChild(text)

    bg:runAction(cc.Sequence:create({
        cc.EaseElasticOut:create(cc.ScaleTo:create(0.6, 1.2)),
        cc.DelayTime:create(4),
        cc.EaseElasticIn:create(cc.ScaleTo:create(0.5, 0.1)),
        cc.RemoveSelf:create(),
    }))
end

-- 变成蛋了
function BattleHeroView:turnIntoEgg()
    local eggAni = load_animation("image/spine/skill_effect/egg/", 1, BattleConfig.SPEED_RATIO)
    eggAni:setAnimation(0, "animation", true)
    self:addChild(eggAni)
    self.eggAni = eggAni

    self.heroAni:setVisible(false)
end

-- 被炮台保护，位置上升一些
function BattleHeroView:protectByturret()
    self.heroAni:setPosition(cc.p(0, 20))
end

-- 失去炮台保护，位置复原
function BattleHeroView:loseProtectionOfTurret()
    self.heroAni:setPosition(cc.p(0, 0))
end

-- 掉入陷阱中去，身体下沉，脚不显示
function BattleHeroView:fallIntoTrap()
    self.heroAni:setPosition(cc.p(0, -30))
    self.clippingNode:setClippingEnabled(true)
end

-- 从b陷阱中出来，身体恢复
function BattleHeroView:getOutOfTrap()
    self.heroAni:setPosition(cc.p(0, 0))
    self.clippingNode:setClippingEnabled(false)
end

function BattleHeroView:playReplicationAnimation()
    local path = string.format("image/spine/skill_effect/replication/")
    local skillAni = load_animation(path, 1, BattleConfig.SPEED_RATIO)
    if skillAni then
        self.heroAni:setVisible(false)
        self:addChild(skillAni)
        skillAni:setVisible(false)
        skillAni:runAction(cc.Sequence:create({
            cc.Show:create(),
            cc.CallFunc:create(function()
                skillAni:setAnimation(0, "animation", false)
            end),
        }))

        skillAni:registerSpineEventHandler(function(event)
            skillAni:setVisible(false)
            skillAni:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.01),
                self.heroAni:setVisible(true),
                cc.RemoveSelf:create(),
            }))
        end, sp.EventType.ANIMATION_END)
    else
        CCLog("load animation fail:", path, "not found")
    end
end
return BattleHeroView
