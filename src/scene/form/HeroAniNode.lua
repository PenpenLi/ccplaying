--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-9-3
-- Time: 上午11:25
-- To change this template use File | Settings | File Templates.
--
local HeroAction = require("tool.helper.HeroAction")
local BattleUtils = require("scene.battle.helper.Utils")
-------------------------------------------------------------------------------

local HeroAniNode = class("HeroAniNode", function() return cc.Node:create() end)

function HeroAniNode:ctor(heroID, isNpc)
    self.heroID = heroID
    self.isNpc = isNpc

    if not isNpc then
        local heroData = assert(GameCache.GetHero(heroID), string.format("HeroID:%s", heroID))
        local heroBaseData = assert(BaseConfig.GetHero(heroID, heroData.StarLevel),  string.format("HeroID:%s", heroID))

        self.heroData = heroData
        self.heroBaseData = heroBaseData
    else
        local monsterData = assert(BaseConfig.GetMonster(heroID), string.format("MonsterID:%d", heroID))
        self.heroData = BattleUtils.monsterToHeroData(monsterData)
        self.heroBaseData = BattleUtils.monsterToHeroBaseData(monsterData)
    end

    self.slot = nil
    self.handlers = {}
    self:setupUI()

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        elseif event == "cleanup" then
            self:onCleanup()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function HeroAniNode:getHeroID()
    return self.heroData.ID
end

function HeroAniNode:getTFP()
    -- TODO:
    return self.heroData.TFP or 0
end

function HeroAniNode:onEnter()
end

function HeroAniNode:onExit()
end

function HeroAniNode:onCleanup()
    for _, handler in ipairs(self.handlers) do
        self:getEventDispatcher():removeEventListener(handler)
    end
end

function HeroAniNode:onEnterTransitionFinish()
end

function HeroAniNode:onExitTransitionStart()
end

function HeroAniNode:removeHandlerOnCleanup(handler)
    table.insert(self.handlers, handler)
end

function HeroAniNode:getDragData()
    local HeroDragData = require("scene.formation.HeroDragData")

    local dragData = HeroDragData.new(self.heroData)
    dragData:setSrcType("slot")
    dragData:setSrcNode(self)
    dragData:setSlot(self.slot)

    return dragData
end

function HeroAniNode:setSlot(x, y)
    local slot
    if type(x) == "table" then
        slot = x
    else
        slot = {x = x, y = y }
    end
    
    self.slot = slot
end

function HeroAniNode:getElemType()
    return self.heroBaseData.wx
end

function HeroAniNode:getShadowImage()
    local shadowImages = {
        [1] = "image/ui/img/btn/btn_385.png",
        [2] = "image/ui/img/btn/btn_383.png",
        [3] = "image/ui/img/btn/btn_386.png",
        [4] = "image/ui/img/btn/btn_384.png",
        [5] = "image/ui/img/btn/btn_387.png",
    }

    local shadowImage = "image/ui/img/btn/btn_279.png"
    shadowImage = shadowImages[self:getElemType()] or shadowImage

    return shadowImage
end

function HeroAniNode:getSlot()
    return self.slot
end

function HeroAniNode:getHeroRes(  )
    return self.heroBaseData.res
end

function HeroAniNode:getSkinInfo()
    if not self.isNpc then
        local equipInfo = self.heroData.Equip 

        if equipInfo then
            local SkinType = {["ARM"] = 1, ["HAT"] = 2, ["COAT"] = 4}

            local skinInfo = { 
                ["Arm"]  = equipInfo[SkinType.ARM].SkinID, 
                ["Hat"]  = equipInfo[SkinType.HAT].SkinID, 
                ["Coat"] = equipInfo[SkinType.COAT].SkinID,
            }

            return skinInfo
        else
            return { 
                ["Arm"]  = 0, 
                ["Hat"]  = 0, 
                ["Coat"] = 0,
            }
        end
    else
        local equipInfo = self.heroData.equip or {}

        local skinInfo = { 
            ["Arm"]  = equipInfo[1], 
            ["Hat"]  = equipInfo[2], 
            ["Coat"] = equipInfo[3],
        }

        return skinInfo
    end    
end

function HeroAniNode:setupUI()
    local heroMoveMode = self.heroBaseData.move or enums.HeroMoveMode.Walk
    if heroMoveMode == enums.HeroMoveMode.Cloud then
        local coundAni = load_animation("image/spine/skill_effect/cloud/", 0.85)
        coundAni:addAnimation(0, "animation", true)
        self:addChild(coundAni)
    end

    local heroRes = self:getHeroRes()
    local skinInfo = self:getSkinInfo()
    
    local heroAni = self.isNpc and CreatePlayer(0, 0, heroRes, skinInfo) or CreateHero(0, 0, self.heroBaseData.id, skinInfo)
    local scale = self.heroBaseData.scale and self.heroBaseData.scale / 10000.0 or 1
    heroAni:setScale(scale * 0.85)
    --heroAni:setToSetupPose()
    heroAni:addAnimation(0, "idle", true)
    self:addChild(heroAni)
    --heroAni:setDebugBonesEnabled(true)

    local hpBgSprite = cc.Sprite:create("image/ui/img/btn/btn_232.png")
    hpBgSprite:setPosition(cc.p(0, 135))
    hpBgSprite:setScale(0.8)
    self:addChild(hpBgSprite)
    self.hpBg = hpBgSprite
    hpBgSprite:setVisible(false)

    local bgImage = "image/ui/img/btn/btn_231.png"
    local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
    hpBar:setPosition(cc.p(0, 135))
    hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hpBar:setScale(0.8)
    --hpBar:setReverseDirection(true)
    hpBar:setMidpoint(cc.p(0, 1))
    hpBar:setBarChangeRate(cc.p(1, 0))
    hpBar:setPercentage(100)
    self:addChild(hpBar)
    self.hpBar = hpBar
    hpBar:setVisible(false)

    local battleTypeMap = {
        [1001] = "image/ui/img/btn/btn_650.png",
        [1002] = "image/ui/img/btn/btn_649.png",
        [1003] = "image/ui/img/btn/btn_648.png",
    }
    local skillID = self.heroBaseData.atkSkill

    local height = self:getHeroHeight()
    local spriteBattleType = cc.Sprite:create(battleTypeMap[skillID])
    spriteBattleType:setPosition(cc.p(-40, height * 0.6))
    self:addChild(spriteBattleType)

--    local battleTypeInfoMap = {
--        [1001] = {name = "近战", color = cc.c3b(10, 200, 10)},
--        [1002] = {name = "远程", color = cc.c3b(10, 200, 200)},
--        [1003] = {name = "超远", color = cc.c3b(200, 10, 10)}
--    }
--    local skillID = self.heroBaseData.atkSkill
--    local labelTitle = cc.LabelTTF:create(battleTypeInfoMap[skillID].name, "Arial", 20, cc.size(80, 28), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
--    labelTitle:setColor(battleTypeInfoMap[skillID].color)
--    labelTitle:setPosition(cc.p(56 / 2, 29 / 2))
--    labelTitle:setAnchorPoint(cc.p(0.5, 0.5))
--    spriteBattleType:addChild(labelTitle)

end

function HeroAniNode:getAniJsonPath()
    local path = string.format("Hero/Ani/%s/skeleton.skel", self.heroBaseData.res)
    if cc.FileUtils:getInstance():isFileExist(path) then
        return path
    end

    path = string.format("Hero/Ani/%s/skeleton.json", self.heroBaseData.res)
    if cc.FileUtils:getInstance():isFileExist(path) then
        return path
    end

    path = "Hero/Ani/xj_1000/skeleton.json"
    return path
end

function HeroAniNode:getAniAtlasPath()
    local path = string.format("Hero/Ani/%s/skeleton.atlas", self.heroBaseData.res)
    if cc.FileUtils:getInstance():isFileExist(path) then
        return path
    end
    path = "Hero/Ani/xj_1000/skeleton.atlas"
    return path
end

function HeroAniNode:getHeroHeight()
    return 150
end

function HeroAniNode:showHP(hp)
    self.heroTowerHP = hp

    hp = hp or self.heroData.HP
    local total = self.heroData.HP
    local percent = math.ceil(hp * 100 / total)
    self.hpBar:setPercentage(math.min(100, percent))
    self.hpBg:setVisible(true)
    self.hpBar:setVisible(true)
end

return HeroAniNode
