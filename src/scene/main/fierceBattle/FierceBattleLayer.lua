local FierceBattleLayer = class("FierceBattleLayer", BaseLayer)

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

function FierceBattleLayer:ctor(info)
    self:createFixedUI()
    self:updateData()
end

function FierceBattleLayer:createFixedUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local bgSize = cc.size(940, 546)
    local panelBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panelBg:setContentSize(bgSize)
    panelBg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(panelBg)
    local animBg = cc.Sprite:create("image/ui/img/bg/bg_257.png")
    animBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    panelBg:addChild(animBg, bgZOrder)
    self.controls.bg = cc.Node:create()
    panelBg:addChild(self.controls.bg, bgZOrder)

    local title = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_993.png")
    title:setTouchEnable(false)
    title:setPosition(bgSize.width * 0.5, bgSize.height * 0.98)
    self.controls.bg:addChild(title)

    local infoBg = cc.Sprite:create("image/ui/img/bg/bg_258.png")
    infoBg:setPosition(bgSize.width * 0.48, bgSize.height * 0.84)
    self.controls.bg:addChild(infoBg)
    local info = {ID = GameCache.Avatar.Icon}
    local head = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info)
    head:setTouchEnable(false)
    head:setPosition(bgSize.width * 0.28, bgSize.height * 0.82)
    self.controls.bg:addChild(head)
    local score = Common.finalFont("赛季积分:", bgSize.width * 0.4, bgSize.height * 0.87, 20, nil, 1)
    self.controls.bg:addChild(score)
    self.controls.score = Common.finalFont("1000", bgSize.width * 0.45, bgSize.height * 0.87, 25, cc.c3b(151, 255, 74), 1)
    self.controls.score:setAdditionalKerning(-2)
    self.controls.score:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.score)
    local seq = Common.finalFont("个人排名:", bgSize.width * 0.62, bgSize.height * 0.87, 20, nil, 1)
    self.controls.bg:addChild(seq)
    self.controls.seq = Common.finalFont("1000", bgSize.width * 0.67, bgSize.height * 0.87, 25, cc.c3b(151, 255, 74), 1)
    self.controls.seq:setAdditionalKerning(-2)
    self.controls.seq:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.seq)
    local mostWin = Common.finalFont("最高连胜:", bgSize.width * 0.4, bgSize.height * 0.78, 20, nil, 1)
    self.controls.bg:addChild(mostWin)
    self.controls.mostWin = Common.finalFont("5", bgSize.width * 0.45, bgSize.height * 0.78, 25, cc.c3b(151, 255, 74), 1)
    self.controls.mostWin:setAdditionalKerning(-2)
    self.controls.mostWin:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.mostWin)
    local times = Common.finalFont("剩余次数:", bgSize.width * 0.62, bgSize.height * 0.78, 20, nil, 1)
    self.controls.bg:addChild(times)
    self.controls.times = Common.finalFont("5".."/".."20", bgSize.width * 0.67, bgSize.height * 0.78, 25, cc.c3b(151, 255, 74), 1)
    self.controls.times:setAdditionalKerning(-2)
    self.controls.times:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.times)

    local leftPanel = cc.Sprite:create("image/ui/img/bg/bg_267.png")
    leftPanel:setFlippedX(true)
    leftPanel:setPosition(bgSize.width * 0.12, bgSize.height * 0.5)
    self.controls.bg:addChild(leftPanel)
    local btnFunc = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            CCLog("-------------------", name)
        end
    end
    local pathTab = {"image/ui/img/btn/btn_466.png", "image/ui/img/btn/btn_188.png", "image/ui/img/btn/btn_069.png", "image/ui/img/btn/btn_200.png"}
    local nameTab = {"我的阵容", "排行榜", "兑换商店", "对战记录"}
    for i=1,4 do
        local btn = createMixSprite(pathTab[i])
        btn:setPosition(bgSize.width * 0.08, bgSize.height * 0.8 - (i - 1) * bgSize.height * 0.2)
        self.controls.bg:addChild(btn)
        btn:setButtonBounce(false)
        btn:setCircleFont(nameTab[i], 1, 1, 20, nil, 1)
        btn:setFontPos(0.5, 0)
        btn:setName(nameTab[i])
        btn:addTouchEventListener(btnFunc)
    end

    local rightPanel = cc.Sprite:create("image/ui/img/bg/bg_267.png")
    rightPanel:setPosition(bgSize.width * 0.85, bgSize.height * 0.5)
    self.controls.bg:addChild(rightPanel)
    local award = createMixScale9Sprite("image/ui/img/btn/btn_877.png",nil,nil,cc.size(44, 128))
    award:setTouchEnable(false)
    award:setCircleFont("每\n日\n奖\n励", 1, 1, 25, cc.c3b(255, 234, 0), 1)
    award:setPosition(bgSize.width * 0.81, bgSize.height * 0.48)
    self.controls.bg:addChild(award)
    local awardBg = cc.Sprite:create("image/ui/img/btn/btn_991.png")
    awardBg:setPosition(bgSize.width * 0.92, bgSize.height * 0.5)
    self.controls.bg:addChild(awardBg)
    self.controls.bar = ccui.LoadingBar:create("image/ui/img/btn/btn_992.png")
    self.controls.bar:setRotation(90)
    self.controls.bar:setPercent(100)
    self.controls.bar:setPosition(bgSize.width * 0.912, bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.bar)
    local function boxFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            CCLog("-------------------", tag)
        end
    end
    self.controls.awardBoxTab = {}
    for i=1,3 do
        local bg = cc.Sprite:create("image/ui/img/btn/btn_994.png")
        bg:setPosition(bgSize.width * 0.915, bgSize.height * 0.765 - (i - 1) * bgSize.height * 0.265)
        self.controls.bg:addChild(bg)
        local box = createMixSprite("image/ui/img/bg/box_1_0.png")
        box:setPosition(bgSize.width * 0.915, bgSize.height * 0.765 - (i - 1) * bgSize.height * 0.265)
        self.controls.bg:addChild(box)
        box:setTag(i)
        self.controls.awardBoxTab[i] = box
        box:addTouchEventListener(boxFunc)
        local chang = Common.finalFont(i.."场", 1, 1, 20, nil, 1)
        chang:setPosition(bgSize.width * 0.915, bgSize.height * 0.71 - (i - 1) * bgSize.height * 0.265)
        self.controls.bg:addChild(chang)
    end

    local buttomBg = cc.Sprite:create("image/ui/img/bg/bg_250.png")
    buttomBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.15)
    self.controls.bg:addChild(buttomBg)
    buttomBg:setScale(0.5)
    self.controls.join = createMixSprite("image/ui/img/btn/btn_593.png")
    self.controls.join:setCircleFont("进入战场", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    self.controls.join:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    self.controls.join:setPosition(bgSize.width * 0.5, bgSize.height * 0.15)
    self.controls.bg:addChild(self.controls.join)
    self.controls.join:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            
        end
    end)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgSize.width*0.96, bgSize.height*1.04)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
    self.controls.bg:addChild(btn_close, btnZOrder)
end

function FierceBattleLayer:updateData()


end

return FierceBattleLayer