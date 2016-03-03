local HeroInfoShowPanel = class("HeroInfoShowPanel", BaseLayer)
local SkillIcon = require("scene.main.hero.widget.SkillIcon")

local MINPERCENT = 10

function HeroInfoShowPanel:ctor(heroID)
    self.data.heroID = heroID
    self:createFixedUI()

    Common.removeTopSwallowLayer()
end

function HeroInfoShowPanel:onEnter()
    self:updateInfo()
end

function HeroInfoShowPanel:createFixedUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    self.data.bgSize = cc.size(955, 605)
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(self.data.bgSize)
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)

    local fringe = cc.Scale9Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setContentSize(self.data.bgSize)
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height)
    self.controls.bg:addChild(fringe)

    local leftPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    leftPanel:setContentSize(cc.size(528, 586))
    leftPanel:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(leftPanel)

    local heroBg = cc.Sprite:create("image/ui/img/bg/bg_184.png")
    heroBg:setPosition(self.data.bgSize.width * 0.17, self.data.bgSize.height * 0.58)
    self.controls.bg:addChild(heroBg)

    local typeBg = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    typeBg:setScaleX(0.6)
    typeBg:setPosition(self.data.bgSize.width * 0.42, self.data.bgSize.height * 0.91)
    self.controls.bg:addChild(typeBg)
    typeBg = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    typeBg:setScaleX(0.6)
    typeBg:setPosition(self.data.bgSize.width * 0.42, self.data.bgSize.height * 0.845)
    self.controls.bg:addChild(typeBg)   

    local controls_type = Common.finalFont("[战斗类型]", self.data.bgSize.width * 0.37, self.data.bgSize.height * 0.91, nil, cc.c3b(230, 191, 124))
    self.controls.bg:addChild(controls_type)
    local controls_armType = Common.finalFont("[武器]", self.data.bgSize.width * 0.13, self.data.bgSize.height * 0.37, nil, cc.c3b(230, 191, 124))
    self.controls.bg:addChild(controls_armType)
    local controls_specialty = Common.finalFont("[战斗专长]", self.data.bgSize.width * 0.37, self.data.bgSize.height * 0.845, nil, cc.c3b(230, 191, 124))
    self.controls.bg:addChild(controls_specialty)

    local descBg = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    descBg:setScaleX(0.54)
    descBg:setPosition(self.data.bgSize.width * 0.43, self.data.bgSize.height * 0.76)
    self.controls.bg:addChild(descBg)
    local desc = Common.finalFont("属性评价", self.data.bgSize.width * 0.43, self.data.bgSize.height * 0.76, nil, cc.c3b(78, 160, 190))
    self.controls.bg:addChild(desc)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.76)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(self.data.bgSize.width * 0.52, self.data.bgSize.height * 0.76)
    self.controls.bg:addChild(line)

    local attrSpri = cc.Sprite:create("image/ui/img/btn/btn_674.png")
    attrSpri:setPosition(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.68)
    self.controls.bg:addChild(attrSpri)
    attrSpri = cc.Sprite:create("image/ui/img/btn/btn_676.png")
    attrSpri:setPosition(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.6)
    self.controls.bg:addChild(attrSpri)
    attrSpri = cc.Sprite:create("image/ui/img/btn/btn_677.png")
    attrSpri:setPosition(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.52)
    self.controls.bg:addChild(attrSpri)
    attrSpri = cc.Sprite:create("image/ui/img/btn/btn_675.png")
    attrSpri:setPosition(self.data.bgSize.width * 0.34, self.data.bgSize.height * 0.44)
    self.controls.bg:addChild(attrSpri) 

    local bottomPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_185.png")
    bottomPanel:setContentSize(cc.size(505, 178))
    bottomPanel:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.18)
    self.controls.bg:addChild(bottomPanel)

    local rightPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    rightPanel:setContentSize(cc.size(416, 586))
    rightPanel:setPosition(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(rightPanel)

    local detailName = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_792.png")
    detailName:setTouchEnable(false)
    detailName:setPosition(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.905)
    self.controls.bg:addChild(detailName)
    local line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(self.data.bgSize.width * 0.7, self.data.bgSize.height * 0.905)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_652.png")
    line:setPosition(self.data.bgSize.width * 0.84, self.data.bgSize.height * 0.905)
    self.controls.bg:addChild(line)

    local nj = createMixSprite("image/ui/img/btn/btn_781.png")
    nj:setTouchEnable(false)
    nj:setCircleFont("怒气技能", 1, 1, 20, cc.c3b(78, 160, 190))
    nj:setPosition(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.83)
    self.controls.bg:addChild(nj)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(self.data.bgSize.width * 0.65, self.data.bgSize.height * 0.83)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(self.data.bgSize.width * 0.89, self.data.bgSize.height * 0.83)
    self.controls.bg:addChild(line)

    local desc = createMixSprite("image/ui/img/btn/btn_781.png")
    desc:setTouchEnable(false)
    desc:setCircleFont("星将升星能提升以下法术技能", 1, 1, 20, cc.c3b(78, 160, 190))
    desc:setPosition(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.53)
    self.controls.bg:addChild(desc)
    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(self.data.bgSize.width * 0.59, self.data.bgSize.height * 0.53)
    self.controls.bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(self.data.bgSize.width * 0.95, self.data.bgSize.height * 0.53)
    self.controls.bg:addChild(line)

    local line = cc.Sprite:create("image/ui/img/btn/btn_783.png")
    line:setPosition(self.data.bgSize.width * 0.77, self.data.bgSize.height * 0.275)
    self.controls.bg:addChild(line)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.97, self.data.bgSize.height * 0.97)
    self.controls.bg:addChild(btn_close)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateHeroList, {})
            self:removeFromParent()
            self = nil
        end
    end)

    self:heroInfoUI()
    self:skillInfoUI()
end

function HeroInfoShowPanel:heroInfoUI()
    local bgSize = self.data.bgSize

    local heroStarLevel = BaseConfig.GetSoul(self.data.heroID).starLevel
    local heroConfig = BaseConfig.GetHero(self.data.heroID, heroStarLevel)

    local starAttr = Common.getHeroStarLevelColor(heroStarLevel)
    local nameColor = starAttr.Color
    local starNum = starAttr.StarNum
    local starDesc = starAttr.Additional

    local starLevelPath = string.format("image/icon/border/panel_border_star_%d.png", heroStarLevel)
    local heroStarLevelBg = cc.Sprite:create(starLevelPath)
    heroStarLevelBg:setPosition(bgSize.width * 0.17, bgSize.height * 0.885)
    self.controls.bg:addChild(heroStarLevelBg)

    local heroName = Common.finalFont(heroConfig.name..starDesc, bgSize.width * 0.17, bgSize.height * 0.885, 30, nameColor, 2)
    heroName:setAdditionalKerning(-2)
    self.controls.bg:addChild(heroName)

    for i=1,6 do
        local star = createMixSprite("image/ui/img/btn/btn_399.png", "image/ui/img/btn/btn_439.png")
        star:setTouchEnable(false)
        local starBg = star:getBg()
        starBg:setScale(0.58)
        star:setPosition(bgSize.width * 0.08, bgSize.height * 0.56 + 20 * i)
        self.controls.bg:addChild(star)
        if i > starNum then
            star:setTouchStatus()
        else
            star:setNormalStatus()
        end
    end

    local wx = cc.Label:createWithCharMap("image/ui/img/btn/btn_410.png", 31, 31,  string.byte("1"))
    wx:setAnchorPoint(0.5, 0.5)
    wx:setPosition(bgSize.width * 0.27, bgSize.height * 0.75)
    self.controls.bg:addChild(wx)
    wx:setString(heroConfig.wx)

    local typeStr = BaseConfig.BATTLE_TYPE_NAME[(heroConfig.atkSkill - 1000)] 
    local controls_type = Common.finalFont(typeStr, bgSize.width * 0.48, bgSize.height * 0.91)
    self.controls.bg:addChild(controls_type)
    local armTypeStr = BaseConfig.ARM_TYPE_NAME[heroConfig.armType]
    local controls_armType = Common.finalFont(armTypeStr, bgSize.width * 0.2, bgSize.height * 0.37)
    self.controls.bg:addChild(controls_armType)
    local controls_specialty = Common.finalFont(heroConfig.specialty, bgSize.width * 0.48, bgSize.height * 0.845)
    self.controls.bg:addChild(controls_specialty)

    local barSize = cc.size(170, 28)
    local barBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1178.png")
    barBg:setContentSize(barSize)
    barBg:setAnchorPoint(0, 0.5)
    barBg:setPosition(bgSize.width * 0.36, bgSize.height * 0.68)
    self.controls.bg:addChild(barBg)
    barBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1178.png")
    barBg:setContentSize(barSize)
    barBg:setAnchorPoint(0, 0.5)
    barBg:setPosition(bgSize.width * 0.36, bgSize.height * 0.6)
    self.controls.bg:addChild(barBg)
    barBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1178.png")
    barBg:setContentSize(barSize)
    barBg:setAnchorPoint(0, 0.5)
    barBg:setPosition(bgSize.width * 0.36, bgSize.height * 0.52)
    self.controls.bg:addChild(barBg)
    barBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1178.png")
    barBg:setContentSize(barSize)
    barBg:setAnchorPoint(0, 0.5)
    barBg:setPosition(bgSize.width * 0.36, bgSize.height * 0.44)
    self.controls.bg:addChild(barBg)

    local barSize = cc.size(170, 25)
    local bar_star = ccui.LoadingBar:create("image/ui/img/bg/line_04.png")
    bar_star:setAnchorPoint(0, 0.5)
    bar_star:setPosition(bgSize.width * 0.36, bgSize.height * 0.68)
    bar_star:setScale9Enabled(true)
    bar_star:setContentSize(barSize)
    self.controls.bg:addChild(bar_star)
    bar_star:setPercent(heroConfig.atkScore)
    bar_star = ccui.LoadingBar:create("image/ui/img/bg/line_04.png")
    bar_star:setAnchorPoint(0, 0.5)
    bar_star:setPosition(bgSize.width * 0.36, bgSize.height * 0.6)
    bar_star:setScale9Enabled(true)
    bar_star:setContentSize(barSize)
    self.controls.bg:addChild(bar_star)
    bar_star:setPercent(heroConfig.defkScore)
    bar_star = ccui.LoadingBar:create("image/ui/img/bg/line_04.png")
    bar_star:setAnchorPoint(0, 0.5)
    bar_star:setPosition(bgSize.width * 0.36, bgSize.height * 0.52)
    bar_star:setScale9Enabled(true)
    bar_star:setContentSize(barSize)
    self.controls.bg:addChild(bar_star)
    bar_star:setPercent(heroConfig.hpScore)
    bar_star = ccui.LoadingBar:create("image/ui/img/bg/line_04.png")
    bar_star:setAnchorPoint(0, 0.5)
    bar_star:setPosition(bgSize.width * 0.36, bgSize.height * 0.44)
    bar_star:setScale9Enabled(true)
    bar_star:setContentSize(barSize)
    self.controls.bg:addChild(bar_star)
    bar_star:setPercent(heroConfig.mpScore)

    for i=1,16 do
        local s = cc.Sprite:create("image/ui/img/btn/btn_001.png")
        s:setScaleY(2.5)
        s:setPosition(bgSize.width * 0.395 + (i - 1)%4 * 35, 
                    bgSize.height * 0.68 - math.floor((i - 1)/4) * bgSize.height * 0.08)
        self.controls.bg:addChild(s)
    end

    local scaleConfig = BaseConfig.GetHeroScale(self.data.heroID)
    local heroScale = scaleConfig.ShowScale / 10000
    local heroOffset = scaleConfig.Offset
    local heroAnim = require("tool.helper.HeroAction").new(bgSize.width * 0.17 + heroOffset[1], bgSize.height * 0.45 + heroOffset[2], self.data.heroID)
    heroAnim:setScale(heroScale)
    self.controls.bg:addChild(heroAnim)

    local soulItem = GoodsInfoNode.new(BaseConfig.GOODS_SOUL, {ID = self.data.heroID}, BaseConfig.GOODS_MIDDLETYPE)
    soulItem:setTips(true)
    soulItem:setPosition(bgSize.width * 0.08, bgSize.height * 0.18)
    self.controls.bg:addChild(soulItem)

    self.controls.soulNum = Common.finalFont("", bgSize.width * 0.245, bgSize.height * 0.24, 20, cc.c3b(255, 194, 1), 1)
    self.controls.bg:addChild(self.controls.soulNum)

    local barSize = cc.size(200, 23)
    local barBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1178.png")
    barBg:setContentSize(barSize)
    barBg:setAnchorPoint(0, 0.5)
    barBg:setPosition(bgSize.width * 0.14, bgSize.height * 0.18)
    self.controls.bg:addChild(barBg)
    self.controls.bar_soul = ccui.LoadingBar:create("image/ui/img/bg/line_01.png")
    self.controls.bar_soul:setAnchorPoint(0, 0.5)
    self.controls.bar_soul:setPosition(bgSize.width * 0.14, bgSize.height * 0.18)
    self.controls.bar_soul:setScale9Enabled(true)
    self.controls.bar_soul:setContentSize(cc.size(200, 20))
    self.controls.bg:addChild(self.controls.bar_soul)

    local btn_get = createMixScale9Sprite("image/ui/img/btn/btn_818.png", "image/ui/img/btn/btn_819.png", nil, cc.size(163, 56))
    btn_get:setButtonBounce(false)
    btn_get:setFont("获取途径" , 1, 1, 25, cc.c3b(248, 216, 136))
    btn_get:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_get:setPosition(bgSize.width * 0.445, bgSize.height * 0.18)
    btn_get:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tips = require("scene.main.hero.widget.GetGoodsWayBox").new(BaseConfig.GOODS_SOUL, 
                                                    {ID = self.data.heroID, Type = BaseConfig.GOODS_MIDDLETYPE},
                                                    self)
            tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(tips)
        end
    end)
    self.controls.bg:addChild(btn_get)
end

function HeroInfoShowPanel:skillInfoUI()
    local bgSize = self.data.bgSize

    local heroStarLevel = BaseConfig.GetSoul(self.data.heroID).starLevel
    local heroConfig = BaseConfig.GetHero(self.data.heroID, heroStarLevel)

    local rpSkillID = heroConfig.rpSkill
    local rpSkillLevel = 1
    local rpConfig = BaseConfig.GetHeroSkill(rpSkillID, rpSkillLevel)
    local rpSkillSpri = SkillIcon.new("image/icon/border/border_star_3.png")
    rpSkillSpri:setChildTexture("image/icon/skill/"..rpConfig.Res..".png")
    rpSkillSpri:setPosition(bgSize.width * 0.63, bgSize.height * 0.68)
    self.controls.bg:addChild(rpSkillSpri)
    local skillInfo = {}
    skillInfo.config = rpConfig
    skillInfo.Level = rpSkillLevel
    rpSkillSpri:setSkillInfo(skillInfo)
    local lab_rpSkillName = Common.finalFont("", bgSize.width * 0.69, bgSize.height * 0.72, 20)
    lab_rpSkillName:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(lab_rpSkillName)
    lab_rpSkillName:setString("怒技 - ".. rpConfig.name)
    local lab_rpSkillLevel = Common.finalFont("", bgSize.width * 0.69, bgSize.height * 0.64, 20, cc.c3b(255,247,174))
    lab_rpSkillLevel:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(lab_rpSkillLevel)
    lab_rpSkillLevel:setString(rpSkillLevel.."级")

    local  norSkillID = heroConfig.norSkill
    local  norSkillLevel = 1
    local  norConfig = BaseConfig.GetHeroSkill(norSkillID, norSkillLevel)
    local norSkillSpri = SkillIcon.new("image/icon/border/border_star_3.png")
    norSkillSpri:setChildTexture("image/icon/skill/"..norConfig.Res..".png")
    norSkillSpri:setPosition(bgSize.width * 0.63, bgSize.height * 0.39)
    self.controls.bg:addChild(norSkillSpri)
    local skillInfo = {}
    skillInfo.config = norConfig
    skillInfo.Level = norSkillLevel
    norSkillSpri:setSkillInfo(skillInfo)
    local lab_norSkillName = Common.finalFont("", bgSize.width * 0.69, bgSize.height * 0.43, 20)
    lab_norSkillName:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(lab_norSkillName)
    lab_norSkillName:setString("普技 - ".. norConfig.name)
    local lab_norSkillLevel = Common.finalFont("", bgSize.width * 0.69, bgSize.height * 0.35, 20, cc.c3b(255,247,174))
    lab_norSkillLevel:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(lab_norSkillLevel)
    lab_norSkillLevel:setString(norSkillLevel.."级")

    local  tfSkillID = heroConfig.tfSkill
    local  tfSkillLevel = 1
    local  tfConfig = BaseConfig.GetHeroSkill(tfSkillID, tfSkillLevel)
    local tfSkillSpri = SkillIcon.new("image/icon/border/border_star_3.png")
    tfSkillSpri:setChildTexture("image/icon/skill/"..tfConfig.Res..".png")
    tfSkillSpri:setPosition(bgSize.width * 0.63, bgSize.height * 0.16)
    self.controls.bg:addChild(tfSkillSpri)
    local skillInfo = {}
    skillInfo.config = tfConfig
    skillInfo.Level = tfSkillLevel
    tfSkillSpri:setSkillInfo(skillInfo)
    local lab_tfSkillName = Common.finalFont("", bgSize.width * 0.69, bgSize.height * 0.2, 20)
    lab_tfSkillName:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(lab_tfSkillName)
    lab_tfSkillName:setString("天赋 - ".. tfConfig.name)
    local lab_tfSkillLevel = Common.finalFont("", bgSize.width * 0.69, bgSize.height * 0.12, 20, cc.c3b(255,247,174))
    lab_tfSkillLevel:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(lab_tfSkillLevel)
    lab_tfSkillLevel:setString(tfSkillLevel.."级")
end

function HeroInfoShowPanel:updateInfo()
    local heroStarLevel = BaseConfig.GetSoul(self.data.heroID).starLevel
    local needSoulNum = BaseConfig.GetHeroNeedSoulCount(heroStarLevel)
    local haveNum = GameCache.GetSoul(self.data.heroID).Num

    self.controls.soulNum:setString(haveNum.."/"..needSoulNum)
    local percent = haveNum / needSoulNum * 100
    percent = percent > MINPERCENT and percent or MINPERCENT
    self.controls.bar_soul:setPercent(percent)
end

return HeroInfoShowPanel
