local SummonHero = class("SummonHero", BaseLayer)
local animate = require("tool.helper.HeroAction")
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

local effectZOrder = 2

function SummonHero:ctor(heroInfo, isShowHero, endFunc)
    self.data.heroInfo = heroInfo
    self.data.isShowHero = isShowHero -- 判断是显示星将还是魂魄
    self.data.endFunc = endFunc
    self.data.heroConfig = BaseConfig.GetHero(self.data.heroInfo.ID, self.data.heroInfo.StarLevel)
    self.data.isCanExit = false

    self:createHeroUI()
    Common.playSound("audio/effect/hero_show.mp3")
    Common.removeTopSwallowLayer()
end

function SummonHero:onEnterTransitionFinish()
end

function SummonHero:createHeroUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local starData = Common.getHeroStarLevelColor(self.data.heroInfo.StarLevel)
    local starNum = starData.StarNum
    local bgPath = nil
    if starNum == 1 then
        bgPath = "image/ui/img/bg/bg_145.jpg"
    elseif starNum == 2 then
        bgPath = "image/ui/img/bg/bg_146.jpg"
    elseif starNum == 3 then
        bgPath = "image/ui/img/bg/bg_147.jpg"
    elseif starNum == 4 then
        bgPath = "image/ui/img/bg/bg_148.jpg"
    end

    local summonBg = cc.Sprite:create(bgPath)
    summonBg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(summonBg)
    self.data.bgSize = summonBg:getContentSize()
    summonBg:setOpacity(0)

    local lightEffect = effects:CreateAnimation(summonBg, self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5, nil, 27, true)

    local light = cc.Sprite:create("image/ui/img/btn/btn_640.png")
    light:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5)
    summonBg:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
    light:runAction(rep)

    local starEffect = effects:CreateAnimation(summonBg, self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5, nil, 28, true)
    starEffect:setLocalZOrder(effectZOrder)

    local getSpri = cc.Sprite:create("image/ui/img/btn/btn_612.png")
    getSpri:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.82)
    summonBg:addChild(getSpri)

    local heroWx = cc.Label:createWithCharMap("image/ui/img/btn/btn_410.png", 31, 31,  string.byte("1"))
    heroWx:setScale(1.2)
    heroWx:setPosition(self.data.bgSize.width * 0.35, self.data.bgSize.height * 0.7)
    summonBg:addChild(heroWx)
    heroWx:setString(self.data.heroConfig.wx)

    local animBg = cc.Sprite:create("image/ui/img/btn/btn_613.png")
    animBg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.4)
    summonBg:addChild(animBg)

    local skins = { ["Arm"] = 0, ["Hat"] = 0, ["Coat"] = 0}
    local animation = animate.new(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.42, self.data.heroInfo.ID, skins)
    animation:setTouchEnabled(false)
    summonBg:addChild(animation)

    local nameBg = cc.Sprite:create("image/ui/img/bg/bg_154.png")
    nameBg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.29)
    summonBg:addChild(nameBg)
    nameBg:setScaleX(0)
    
    local name = Common.finalFont(self.data.heroConfig.name, 1, 1, 35, nil, 1)
    name:enableOutline(cc.c4b(63,31,0,255), 2)
    name:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.295)
    summonBg:addChild(name)
    name:setVisible(false)

    local halfSpace = 20
    local beginPosx = self.data.bgSize.width * 0.5 - (starNum - 1) * halfSpace
    local starSpriTab = {}
    for i=1,starNum do
        local star = cc.Sprite:create("image/ui/img/btn/btn_614.png")
        star:setPosition(beginPosx + (i - 1) * halfSpace * 2, self.data.bgSize.height * 0.24)
        summonBg:addChild(star)
        star:setScale(0.01)
        starSpriTab[i] = star
    end
    
    if not self.data.isShowHero then
        self.heroDesc1 = Common.finalFont("", 1, 1, 25, nil, 1)
        self.heroDesc1:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.15)
        summonBg:addChild(self.heroDesc1)
        self.heroDesc1:setString("已拥有此星将,自动转化为星将魂魄"..self.data.heroInfo.Num.."个")
        self.heroDesc1:setOpacity(0)

        self.heroDesc2 = Common.finalFont("", 1, 1, 25, nil, 1)
        self.heroDesc2:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.08)
        summonBg:addChild(self.heroDesc2)
        self.heroDesc2:setString("魂魄可用于星将升星")
        self.heroDesc2:setOpacity(0)
    else
        -- 由于召唤或者合成的星将信息不一致，此操作为了使星将信息保持格式一致
        if GameCache.GetHero(self.data.heroInfo.ID) then
            self.data.heroInfo = GameCache.GetHero(self.data.heroInfo.ID)
        end
        local detailBg = cc.Sprite:create("image/ui/img/btn/btn_588.png")
        detailBg:setScaleX(4.5)
        detailBg:setScaleY(1.4)
        detailBg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.14)
        summonBg:addChild(detailBg)

        local arm = ColorLabel.new("", 25)
        arm:setPosition(self.data.bgSize.width * 0.4, self.data.bgSize.height * 0.14)
        summonBg:addChild(arm)
        arm:setString("[255,255,255]武器:[=][255,178,66]"..BaseConfig.ARM_TYPE_NAME[self.data.heroConfig.armType].."[=]")
        local ftp = ColorLabel.new("", 25)
        ftp:setPosition(self.data.bgSize.width * 0.6, self.data.bgSize.height * 0.14)
        summonBg:addChild(ftp)
        ftp:setString("[255,255,255]战力:[=][255,178,66]"..self.data.heroInfo.TFP.."[=]")
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        if self.data.isCanExit then
            self.data.isCanExit = false
            self:exit(summonBg)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, summonBg) 

    local function nameActionEndFunc()
        name:setVisible(true)
        for k,v in pairs(starSpriTab) do
            local time1 = 0.15
            local time2 = 0.06
            local time3 = 0.06
            local time4 = 0.02
            local time5 = 0.02
            local scale11 = cc.ScaleTo:create(time1, 1.2)
            local scale12 = cc.ScaleTo:create(time2, 0.8)
            local scale13 = cc.ScaleTo:create(time3, 1.1)
            local scale14 = cc.ScaleTo:create(time4, 0.9)
            local scale15 = cc.ScaleTo:create(time5, 1)
            local delay = cc.DelayTime:create((time1+time2+time3+time4+time5) * (k - 1))
            v:runAction(cc.Sequence:create(delay, scale11, scale12, scale13, scale14, scale15, cc.CallFunc:create(function()
                if k == (#starSpriTab) then
                    self.data.isCanExit = true
                    if not self.data.isShowHero then
                        local function fontAction(fontLab)
                            local length = fontLab:getStringLength() - 1
                            for i=0,length do
                                local font = fontLab:getLetter(i)
                                if font then
                                    local delay1 = cc.DelayTime:create(0.03 * i)
                                    local fadeIn = cc.FadeIn:create(0.05)
                                    font:runAction(cc.Sequence:create(delay1, fadeIn))
                                end
                            end
                        end
                        fontAction(self.heroDesc1)
                        fontAction(self.heroDesc2)
                    end
                    self:playHeroSound(animation)
                end
            end)))
        end
    end

    local function bgActionEndFunc()
        local scale1 = cc.ScaleTo:create(0.18, 1.2, 1)
        local scale2 = cc.ScaleTo:create(0.1, 0.8, 1)
        local scale3 = cc.ScaleTo:create(0.08, 1, 1)
        nameBg:runAction(cc.Sequence:create(scale1, scale2, scale3, cc.CallFunc:create(nameActionEndFunc)))
    end

    summonBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.CallFunc:create(bgActionEndFunc)))
end

function SummonHero:exit(summonBg)
    summonBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function()
        summonBg:setVisible(false)
        if self.data.endFunc then
            self.data.endFunc()
        end
        Common.removeTopSwallowLayer()
        self:removeFromParent()
        self = nil
    end)))
end

function SummonHero:playHeroSound(heroAnim)
    heroAnim:playSound()
end

return SummonHero

