local UpgradeSuccess = class("UpgradeSuccess", function()
    local node = cc.Node:create()
    node.data = {}
    node.controls = {}
    return node
end)
local scheduler = cc.Director:getInstance():getScheduler()
local SkillIcon = require("scene.main.hero.widget.SkillIcon")

local bgZOrder = 2

function UpgradeSuccess:ctor(heroInfo, afterTFP, endFunc)
    self.data.heroInfo = heroInfo
    self.data.afterTFP = afterTFP
    self.controls.endFunc = endFunc

    self.data.isChangeTFP = false
    self.data.isUpgradeSkill = false
    self.data.currTFP = self.data.heroInfo.TFP
    self.data.addNum = math.ceil((self.data.afterTFP - self.data.currTFP) / 10)
    
    self:createUI()
    self:skillDesc()
    self:playAction()
    self.controls.changeTfp = scheduler:scheduleScriptFunc(handler(self, self.changeTFP), 1 / 60, false)
    Common.playSound("audio/effect/map_battle_win.mp3")
end

function UpgradeSuccess:createUI()
    local function swallowLayer()
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,230), SCREEN_WIDTH, SCREEN_HEIGHT)
        self:addChild(layer)

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    end
    swallowLayer()


    local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    light:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8)
    self:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
    light:runAction(rep)

    local bg1 = cc.Scale9Sprite:create("image/ui/img/bg/bg_164.png")
    bg1:setContentSize(cc.size(938, 383))
    bg1:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.48)
    self:addChild(bg1)

    local tiao1 = cc.Sprite:create("image/ui/img/btn/btn_639.png")
    tiao1:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.47)
    self:addChild(tiao1)
    local tiao2 = cc.Sprite:create("image/ui/img/btn/btn_639.png")
    tiao2:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.36)
    self:addChild(tiao2)

    self.controls.upgrade = cc.Sprite:create("image/ui/img/bg/bg_160.png")
    self.controls.upgrade:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.78)
    self:addChild(self.controls.upgrade)
    local upgradeSize = self.controls.upgrade:getContentSize()
    local upSpri = cc.Sprite:create("image/ui/img/btn/btn_634.png")
    upSpri:setName("up")
    upSpri:setAnchorPoint(0.5, 0)
    upSpri:setPosition(upgradeSize.width * 0.25, upgradeSize.height * 0.35)
    upSpri:setScale(0.1)
    self.controls.upgrade:addChild(upSpri)
    local upStarSpri = cc.Sprite:create("image/ui/img/btn/btn_635.png")
    upStarSpri:setPosition(upgradeSize.width * 0.58, upgradeSize.height * 0.75)
    self.controls.upgrade:addChild(upStarSpri)

    local id = self.data.heroInfo.ID
    local beforeStarData = Common.getHeroStarLevelColor(self.data.heroInfo.StarLevel - 1)
    local afterStarData = Common.getHeroStarLevelColor(self.data.heroInfo.StarLevel)

    self.controls.head1 = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = id, StarLevel = self.data.heroInfo.StarLevel - 1})
    self.controls.head1:setTouchEnable(false)
    self.controls.head1:setPosition(SCREEN_WIDTH*0.4, SCREEN_HEIGHT*0.62)
    self:addChild(self.controls.head1)
    local headSize = self.controls.head1:getContentSize()
    local starLabel1 = cc.LabelAtlas:_create(beforeStarData.StarNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
    starLabel1:setAnchorPoint(0.5, 0.5)
    starLabel1:setPosition(-headSize.width * 0.24, -headSize.height * 0.65)
    self.controls.head1:addChild(starLabel1)
    local star1 = cc.Sprite:create("image/ui/img/btn/btn_638.png")
    star1:setScale(0.9)
    star1:setPosition(0, -headSize.height * 0.65)
    self.controls.head1:addChild(star1)
    if "" ~= beforeStarData.Additional then
        local additional = string.sub(beforeStarData.Additional, 2, 2)
        local addSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
        addSpri:setAnchorPoint(0, 0.5)
        addSpri:setPosition(star1:getPositionX() + star1:getContentSize().width * 0.48, -headSize.height * 0.65)
        self.controls.head1:addChild(addSpri)
        local addNumber = cc.LabelAtlas:_create(additional, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
        addNumber:setAnchorPoint(0, 0.5)
        addNumber:setPosition(addSpri:getPositionX() + addSpri:getContentSize().width * 0.5, -headSize.height * 0.65)
        self.controls.head1:addChild(addNumber)
    end

    self.controls.starTo = cc.Sprite:create("image/ui/img/btn/btn_359.png")
    self.controls.starTo:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.62)
    self:addChild(self.controls.starTo)

    self.controls.head2 = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = id, StarLevel = self.data.heroInfo.StarLevel})
    self.controls.head2:setTouchEnable(false)
    self.controls.head2:setPosition(SCREEN_WIDTH*0.6, SCREEN_HEIGHT*0.62)
    self:addChild(self.controls.head2)
    local starLabel2 = cc.LabelAtlas:_create(afterStarData.StarNum, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
    starLabel2:setAnchorPoint(0.5, 0.5)
    starLabel2:setPosition(-headSize.width * 0.24, -headSize.height * 0.65)
    self.controls.head2:addChild(starLabel2)
    local star2 = cc.Sprite:create("image/ui/img/btn/btn_638.png")
    star2:setScale(0.9)
    star2:setPosition(0, -headSize.height * 0.65)
    self.controls.head2:addChild(star2)
    if "" ~= afterStarData.Additional then
        local additional = string.sub(afterStarData.Additional, 2, 2)
        local addSpri = cc.Sprite:create("image/ui/img/btn/btn_637.png")
        addSpri:setAnchorPoint(0, 0.5)
        addSpri:setPosition(star2:getPositionX() + star2:getContentSize().width * 0.48, -headSize.height * 0.65)
        self.controls.head2:addChild(addSpri)
        local addNumber = cc.LabelAtlas:_create(additional, "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
        addNumber:setAnchorPoint(0, 0.5)
        addNumber:setPosition(addSpri:getPositionX() + addSpri:getContentSize().width * 0.5, -headSize.height * 0.65)
        self.controls.head2:addChild(addNumber)
    end

    self.controls.tfpName = Common.finalFont("战力", 1, 1, 25, cc.c3b(255, 237, 135), 1)
    self.controls.tfpName:enableOutline(cc.c4b(0,6,21,255), 1)
    self.controls.tfpName:setPosition(SCREEN_WIDTH*0.32, SCREEN_HEIGHT*0.42)
    self:addChild(self.controls.tfpName)

    self.controls.beforeTFP = Common.finalFont(self.data.heroInfo.TFP, 1, 1, 25, cc.c3b(249, 195, 48), 1)
    self.controls.beforeTFP:enableOutline(cc.c4b(75,4,2,255), 1)
    self.controls.beforeTFP:setPosition(SCREEN_WIDTH*0.4, SCREEN_HEIGHT*0.42)
    self:addChild(self.controls.beforeTFP)

    self.controls.tfpTo = cc.Sprite:create("image/ui/img/btn/btn_359.png")
    self.controls.tfpTo:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.42)
    self:addChild(self.controls.tfpTo)

    self.controls.afterTFP = Common.finalFont(self.data.heroInfo.TFP, 1, 1, 25, cc.c3b(15, 223, 39), 1)
    self.controls.afterTFP:enableOutline(cc.c4b(75,4,2,255), 1)
    self.controls.afterTFP:setPosition(SCREEN_WIDTH*0.6, SCREEN_HEIGHT*0.42)
    self:addChild(self.controls.afterTFP)

    self.controls.skillPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_161.png")
    self.controls.skillPanel:setContentSize(cc.size(445, 82))
    self.controls.skillPanel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.28)
    self:addChild(self.controls.skillPanel)

    local size = self.controls.skillPanel:getContentSize()
    self.controls.skill = SkillIcon.new("image/icon/border/border_star_3.png")
    self.controls.skill:setPosition(size.width * 0.15, size.height * 0.5)
    self.controls.skill:setScale(0.8)
    self.controls.skillPanel:addChild(self.controls.skill, bgZOrder)
    self.controls.skill:setPos(60, 0)

    self.controls.skilltype = Common.finalFont("天赋技能:", 1, 1)
    self.controls.skilltype:setPosition(size.width * 0.25, size.height * 0.5)
    self.controls.skilltype:setAnchorPoint(0, 0.5)
    self.controls.skillPanel:addChild(self.controls.skilltype)

    self.controls.skillName = Common.finalFont("天涯", 1, 1, nil, cc.c3b(255, 220, 20))
    self.controls.skillName:setPosition(self.controls.skilltype:getPositionX() + self.controls.skilltype:getContentSize().width * 1.1, size.height * 0.5)
    self.controls.skillName:setAnchorPoint(0, 0.5)
    self.controls.skillPanel:addChild(self.controls.skillName)

    self.controls.skillLevel = Common.finalFont("提升至".."6".."级", 1, 1)
    self.controls.skillLevel:setPosition(size.width * 0.82, size.height * 0.5)
    self.controls.skillLevel:setAnchorPoint(0, 0.5)
    self.controls.skillPanel:addChild(self.controls.skillLevel)

    self.controls.btn = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(150, 62))
    self.controls.btn:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.1)
    self.controls.btn:setCircleFont("确定", 1, 1, 25, cc.c3b(226, 204, 169), 1)
    self.controls.btn:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    self:addChild(self.controls.btn)
    self.controls.btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.controls.endFunc()
            self:removeFromParent()
            self = nil
        end
    end)
end

function UpgradeSuccess:skillDesc()
    local configInfo = BaseConfig.GetHero(self.data.heroInfo.ID, self.data.heroInfo.StarLevel)
    local beforeUpstarConfig = BaseConfig.GetHeroUpstar(self.data.heroInfo.StarLevel - 1)
    local curUpstarConfig = BaseConfig.GetHeroUpstar(self.data.heroInfo.StarLevel)
    local beforeTf = beforeUpstarConfig.TfSkill
    local beforeNor = beforeUpstarConfig.NorSkill
    local currTf = curUpstarConfig.TfSkill
    local currNor = curUpstarConfig.NorSkill

    local skillConfig = nil
    local skillLevel = nil
    if currTf > beforeTf then
        self.data.isUpgradeSkill = true
        self.controls.skilltype:setString("天赋技能:")
        skillConfig = BaseConfig.GetHeroSkill(configInfo.tfSkill, currTf)
        local name = skillConfig.name
        self.controls.skillName:setString(name)
        self.controls.skillLevel:setPositionX(self.controls.skillName:getPositionX() + self.controls.skillName:getContentSize().width * 1.2)
        self.controls.skillLevel:setString("提升至"..currTf.."级")
        skillLevel = currTf
    elseif currNor > beforeNor then
        self.data.isUpgradeSkill = true
        self.controls.skilltype:setString("普通技能:")
        skillConfig = BaseConfig.GetHeroSkill(configInfo.norSkill, currNor)
        local name = skillConfig.name
        self.controls.skillName:setString(name)
        self.controls.skillLevel:setPositionX(self.controls.skillName:getPositionX() + self.controls.skillName:getContentSize().width * 1.2)
        self.controls.skillLevel:setString("提升至"..currNor.."级")
        skillLevel = currNor
    else
        self.data.isUpgradeSkill = false
        self.controls.skillPanel:setVisible(false)
        return
    end
    self.controls.skill:setChildTexture("image/icon/skill/"..skillConfig.Res..".png")
    local skillInfo = {}
    skillInfo.config = skillConfig
    skillInfo.Level = skillLevel
    self.controls.skill:setSkillInfo(skillInfo)
end

function UpgradeSuccess:playAction()
    self.controls.upgrade:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.78)
    self.controls.head1:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.62)
    self.controls.starTo:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.62)
    self.controls.head2:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.62)
    self.controls.tfpName:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.42)
    self.controls.beforeTFP:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.42)
    self.controls.tfpTo:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.42)
    self.controls.afterTFP:setPosition(SCREEN_WIDTH*0.4, SCREEN_HEIGHT*0.42)
    self.controls.afterTFP:setOpacity(0)
    self.controls.btn:setScale(0)
    self.controls.skillPanel:setPosition(-SCREEN_WIDTH, SCREEN_HEIGHT*0.28)

    local time1 = 0.5
    local upFunc = cc.CallFunc:create(function()
        local upSpri = self.controls.upgrade:getChildByName("up")
        if upSpri then
            local scale11 = cc.ScaleTo:create(0.1, 1.2, 1.8)
            local scale12 = cc.ScaleTo:create(0.1, 0.9, 0.8)
            local scale13 = cc.ScaleTo:create(0.1, 1.1, 1.4)
            local scale14 = cc.ScaleTo:create(0.1, 0.95, 0.9)
            local scale15 = cc.ScaleTo:create(0.1, 1, 1)
            upSpri:runAction(cc.Sequence:create(scale11, scale12, scale13, scale14, scale15))
        end
    end)
    self.controls.upgrade:runAction(cc.Sequence:create(cc.EaseBounceOut:create(
                                    cc.MoveBy:create(time1, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.5, 0))), upFunc))

    local delay2 = cc.DelayTime:create(time1)
    local time2 = time1 + 0.1
    self.controls.head1:runAction(cc.Sequence:create(delay2,
                                    cc.MoveBy:create(time2 - time1, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.4, 0))))

    local delay3 = cc.DelayTime:create(time2)
    local time3 = time2 + 0.1
    self.controls.starTo:runAction(cc.Sequence:create(delay3,
                                    cc.MoveBy:create(time3 - time2, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.5, 0))))

    local delay4 = cc.DelayTime:create(time3)
    local time4 = time3 + 0.1
    self.controls.head2:runAction(cc.Sequence:create(delay4,
                                    cc.MoveBy:create(time4 - time3, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.6, 0))))

    local delay5 = cc.DelayTime:create(time4)
    local time5 = time4 + 0.1
    self.controls.tfpName:runAction(cc.Sequence:create(delay5,
                                    cc.MoveBy:create(time5 - time4, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.32, 0))))

    local delay6 = cc.DelayTime:create(time5)
    local time6 = time5 + 0.1
    self.controls.beforeTFP:runAction(cc.Sequence:create(delay6,
                                    cc.MoveBy:create(time6 - time5, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.4, 0))))

    local delay7 = cc.DelayTime:create(time6)
    local time7 = time6 + 0.1
    self.controls.tfpTo:runAction(cc.Sequence:create(delay7,
                                    cc.MoveBy:create(time7 - time6, cc.p(SCREEN_WIDTH + SCREEN_WIDTH*0.5, 0))))

    local fun1 = cc.CallFunc:create(function()
        self.data.isChangeTFP = true
    end)
    local delay8 = cc.DelayTime:create(time7)
    local time8 = time7 + 0.3
    self.controls.afterTFP:runAction(cc.Sequence:create(delay8, cc.Spawn:create(cc.FadeIn:create(time8 - time7), cc.JumpBy:create(time8 - time7, cc.p(SCREEN_WIDTH*0.6 - SCREEN_WIDTH*0.4, 0), 50, 1)),
                                    fun1))
end

function UpgradeSuccess:changeTFP()
    if self.data.isChangeTFP then
        self.data.currTFP = self.data.currTFP + self.data.addNum
        if self.data.currTFP >= self.data.afterTFP then
            self.data.isChangeTFP = false
            self.data.currTFP = self.data.afterTFP
            scheduler:unscheduleScriptEntry(self.controls.changeTfp)

            local func = cc.CallFunc:create(function()
                if self.data.isUpgradeSkill then
                    self.controls.skillPanel:runAction(cc.Sequence:create(
                            cc.MoveBy:create(0.1, cc.p(SCREEN_WIDTH + SCREEN_WIDTH * 0.5, 0))))
                end
                self.controls.btn:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.3), cc.ScaleTo:create(0.08, 1)))
            end)
            self.controls.afterTFP:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 2), cc.ScaleTo:create(0.08, 1), func))   
        end
        self.controls.afterTFP:setString(self.data.currTFP)
    end
end

return UpgradeSuccess

