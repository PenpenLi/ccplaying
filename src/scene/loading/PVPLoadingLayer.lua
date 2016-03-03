local PVPLoadingLayer = class("PVPLoadingLayer", BaseLayer)
local CalHeroAttr = require("tool.helper.CalHeroAttr")
local heroaction = require("tool.helper.HeroAction")

function PVPLoadingLayer:ctor(ownForm, enemyForm, callFunc)
    PVPLoadingLayer.super.ctor(self)

    local leftDistance = SCREEN_WIDTH * 0.5 - 157
    local left_bg = cc.Sprite:create("image/ui/img/bg/bg_300.png")
    left_bg:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT * 0.5)
    self:addChild(left_bg)

    local rightDistance = SCREEN_WIDTH * 0.5 + 129
    local right_bg = cc.Sprite:create("image/ui/img/bg/bg_301.png")
    right_bg:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 0.5)
    self:addChild(right_bg)

    self.controls.leftCircle = cc.Sprite:create("image/ui/img/bg/bg_303.png")
    left_bg:addChild(self.controls.leftCircle)
    self.controls.leftCircle:setScale(SCREEN_WIDTH / 1136)
    self.controls.leftCircle:setPosition(300, 300)
    self.controls.leftCircle:setVisible(false)

    self.controls.rightCircle = cc.Sprite:create("image/ui/img/bg/bg_302.png")
    right_bg:addChild(self.controls.rightCircle)
    self.controls.rightCircle:setScale(SCREEN_WIDTH / 1136)
    self.controls.rightCircle:setPosition(560, 180)
    self.controls.rightCircle:setVisible(false)

    local leftTFP = cc.Sprite:create("image/ui/img/btn/btn_1288.png")
    leftTFP:setPosition(180, 170)
    left_bg:addChild(leftTFP)

    self.controls.leftTFP = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    self.controls.leftTFP:setAdditionalKerning(-6)
    self.controls.leftTFP:setPosition(295, 170)
    left_bg:addChild(self.controls.leftTFP)
    self.controls.leftTFP:setString(0)
    self.controls.leftTFP:setScale(0.7)

    local rightTFP = cc.Sprite:create("image/ui/img/btn/btn_1288.png")
    rightTFP:setPosition(530, 450)
    right_bg:addChild(rightTFP)

    self.controls.rightTFP = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    self.controls.rightTFP:setAdditionalKerning(-6)
    self.controls.rightTFP:setPosition(645, 450)
    right_bg:addChild(self.controls.rightTFP)
    self.controls.rightTFP:setString(enemyForm.EnemyInfo.TFP)
    self.controls.rightTFP:setScale(0.7)

    local leftBG = cc.Scale9Sprite:create("image/ui/img/btn/btn_1155.png")
    leftBG:setContentSize(cc.size(280, 50))
    leftBG:setPosition(320, 560)
    left_bg:addChild(leftBG)
    local leftName = Common.finalFont(GameCache.Avatar.Name, 1, 1, 25, cc.c3b(229, 179, 101), 1)
    leftName:setAnchorPoint(0, 0.5)
    leftName:setPosition(20, 25)
    leftBG:addChild(leftName)
    local leftLevel = Common.finalFont("LV."..GameCache.Avatar.Level, 1, 1, 25, cc.c3b(229, 179, 101), 1)
    leftLevel:setAnchorPoint(0, 0.5)
    leftLevel:setPosition(180, 25)
    leftBG:addChild(leftLevel)

    local rightBG = cc.Scale9Sprite:create("image/ui/img/btn/btn_1155.png")
    rightBG:setContentSize(cc.size(280, 50))
    rightBG:setPosition(550, 70)
    right_bg:addChild(rightBG)
    local rightName = Common.finalFont(enemyForm.EnemyInfo.Name, 1, 1, 25, cc.c3b(229, 179, 101), 1)
    rightName:setAnchorPoint(0, 0.5)
    rightName:setPosition(20, 25)
    rightBG:addChild(rightName)
    local rightLevel = Common.finalFont("LV."..enemyForm.EnemyInfo.Level, 1, 1, 25, cc.c3b(229, 179, 101), 1)
    rightLevel:setAnchorPoint(0, 0.5)
    rightLevel:setPosition(180, 25)
    rightBG:addChild(rightLevel)

    local moveTime = 0.3
    local leftBgMove = cc.MoveTo:create(moveTime, cc.p(leftDistance, SCREEN_HEIGHT * 0.5))
    local rightBgMove = cc.MoveTo:create(moveTime, cc.p(rightDistance, SCREEN_HEIGHT * 0.5))
    left_bg:runAction(cc.Sequence:create(leftBgMove))
    right_bg:runAction(cc.Sequence:create({rightBgMove, cc.CallFunc:create(function()
        self.controls.leftCircle:setVisible(true)
        self.controls.rightCircle:setVisible(true)
        self:createHero(ownForm, enemyForm)
    end)}))

    self:runAction(cc.Sequence:create({cc.DelayTime:create(2), cc.CallFunc:create(function()
            callFunc()
    end)}))

    self.data.posTabs = {{220, 10}, {50, 60}, {410, 60}, {140, 110}, {300, 110}}
    self.data.colorTab = {cc.c4f(1, 1, 1, 1), cc.c4f(0.7, 0.7, 0.7, 1), cc.c4f(0.7, 0.7, 0.7, 1), 
                            cc.c4f(0.5, 0.5, 0.5, 1), cc.c4f(0.5, 0.5, 0.5, 1)}

    local vsSprite = cc.Sprite:create("image/ui/img/btn/btn_1262.png")
    vsSprite:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(vsSprite)
    vsSprite:setOpacity(0)
    vsSprite:setScale(6)

    local delay = cc.DelayTime:create(1.2)
    local spawnTime = 0.4
    local fadeIn = cc.FadeIn:create(spawnTime)
    local scale0 = cc.ScaleTo:create(0.2, 0.8)
    local scale1 = cc.ScaleTo:create(0.1, 1.3)
    local scale2 = cc.ScaleTo:create(0.1, 1)
    local seqScale = cc.Sequence:create(scale0, scale1, scale2)
    local spawn = cc.Spawn:create(fadeIn, seqScale)
    vsSprite:runAction(cc.Sequence:create({delay, spawn}))
end

function PVPLoadingLayer:onEnterTransitionFinish()
    -- body
end

function PVPLoadingLayer:createHero(ownForm, enemyForm)
    for k,formInfo in pairs(ownForm.Hero) do
        local scaleConfig = BaseConfig.GetHeroScale(formInfo.ID)
        local heroScale = scaleConfig.ShowScale / 10000
        local heroAnim = heroaction.new(self.data.posTabs[k][1], SCREEN_HEIGHT * 2, formInfo.ID)
        heroAnim:setScale(heroScale * 0.8)
        self.controls.leftCircle:addChild(heroAnim)
        heroAnim.animation:setAnimation(0,"victory",true)
        heroAnim.animation:setColorFactor(self.data.colorTab[k])

        local delay = cc.DelayTime:create((k - 1) * 0.15)
        local move = cc.MoveTo:create(0.1, cc.p(self.data.posTabs[k][1], self.data.posTabs[k][2]))
        heroAnim:runAction(cc.Sequence:create({delay, move, cc.CallFunc:create(function()
            self:changeTFP(k, ownForm)
            heroAnim:setLocalZOrder(SCREEN_HEIGHT - self.data.posTabs[k][2])
            self.controls.leftCircle:runAction(cc.Sequence:create(cc.Shake:create(0.05, 10)))
        end)}))
    end

    for k,heroInfo in pairs(enemyForm.HeroList) do
        local scaleConfig = BaseConfig.GetHeroScale(heroInfo.ID)
        local heroScale = scaleConfig.ShowScale / 10000
        local heroAnim = heroaction.new(self.data.posTabs[k][1], SCREEN_HEIGHT * 2, heroInfo.ID, heroInfo)
        heroAnim:setScaleX(-heroScale * 0.8)
        heroAnim:setScaleY(heroScale * 0.8)
        heroAnim:setLocalZOrder(SCREEN_HEIGHT - self.data.posTabs[k][2])
        self.controls.rightCircle:addChild(heroAnim)
        heroAnim.animation:setAnimation(0,"victory",true)
        heroAnim.animation:setColorFactor(self.data.colorTab[k])

        local delay = cc.DelayTime:create((k - 1) * 0.15)
        local move = cc.MoveTo:create(0.1, cc.p(self.data.posTabs[k][1], self.data.posTabs[k][2]))
        heroAnim:runAction(cc.Sequence:create({delay, move, cc.CallFunc:create(function()
            heroAnim:setLocalZOrder(SCREEN_HEIGHT - self.data.posTabs[k][2])
            self.controls.rightCircle:runAction(cc.Sequence:create(cc.Shake:create(0.05, 10)))
        end)}))
    end
end

function PVPLoadingLayer:changeTFP(idx, ownFormInfo)
    local form = {}
    form.Hero = {}
    form.Fairy = ownFormInfo.Fairy and ownFormInfo.Fairy.ID or nil

    for k,v in pairs(ownFormInfo.Hero) do
        if k <= idx then
            table.insert(form.Hero, v)
        end
    end

    self.controls.leftTFP:setString(CalHeroAttr.FormTFP(form))
    self.controls.leftTFP:stopAllActions()
    self.controls.leftTFP:setScale(0.7)
    local scale1 = cc.ScaleTo:create(0.1, 1.2)
    local scale2 = cc.ScaleTo:create(0.05, 0.7)
    self.controls.leftTFP:runAction(cc.Sequence:create(scale1, scale2))
end

return PVPLoadingLayer
