local DigestPanel = class("DigestPanel", function()
    local self = cc.Node:create()
    self.controls = {}
    self.data = {}
    return self
end)
local heroaction = require("tool.helper.HeroAction")

local attrZOrder = 1
local attributeZOrder = attrZOrder + 1

local HEROANIMTAG = 10

function DigestPanel:ctor(sortID, allHero)
    self.data.heroSortId = sortID
    self.data.allHero = allHero
    self.data.size = cc.size(520, 600)
    self:createFixedUI()

    self.data.isInLeft = true
    self.data.isMove = false
    self.data.isNeedShowNearAnim = true
end

function DigestPanel:createFixedUI()
    local size = self.data.size

    local function allAttribute()
        self.controls.attributeBG = cc.Scale9Sprite:create("image/ui/img/btn/btn_415.png")
        self.controls.attributeBG:setContentSize(cc.size(468, 95))
        self.controls.attributeBG:setPosition(0, -size.height * 0.28)
        self:addChild(self.controls.attributeBG, attributeZOrder)
        self.controls.attributeBG:setOpacity(0)

        local currPanelSize = self.controls.attributeBG:getContentSize()
        local mode = cc.Sprite:create("image/ui/img/btn/btn_447.png")
        mode:setScaleX(2)
        self.controls.clippingNode = cc.ClippingNode:create()
        self.controls.clippingNode:setAlphaThreshold(0.5)
        self.controls.clippingNode:setStencil(mode)
        self.controls.clippingNode:setPosition(5, -size.height * 0.29)
        self:addChild(self.controls.clippingNode, attributeZOrder)

        self.controls.attrPanelNode = cc.Node:create()
        self.controls.clippingNode:addChild(self.controls.attrPanelNode)
        local controls_type = Common.finalFont("类型", -currPanelSize.width * 0.45, currPanelSize.height * 0.2, nil, cc.c3b(230, 191, 124))
        self.controls.attrPanelNode:addChild(controls_type)
        self.controls.type = Common.finalFont("远程", -currPanelSize.width * 0.34, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.type)
        local controls_armType = Common.finalFont("武器", -currPanelSize.width * 0.2, currPanelSize.height * 0.2, nil, cc.c3b(230, 191, 124))
        self.controls.attrPanelNode:addChild(controls_armType)
        self.controls.armType = Common.finalFont("短柄", -currPanelSize.width * 0.1, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.armType)
        local controls_specialty = Common.finalFont("战斗专长", -currPanelSize.width * 0.405, -currPanelSize.height * 0.2, nil, cc.c3b(230, 191, 124))
        self.controls.attrPanelNode:addChild(controls_specialty)
        self.controls.specialty = Common.finalFont("输出", -currPanelSize.width * 0.3, -currPanelSize.height * 0.2)
        self.controls.specialty:setAnchorPoint(0, 0.5)
        self.controls.attrPanelNode:addChild(self.controls.specialty)

        local line = cc.Sprite:create("image/ui/img/btn/btn_414.png")
        line:setPosition(0, 0)
        self.controls.attrPanelNode:addChild(line)
        line = cc.Sprite:create("image/ui/img/btn/btn_414.png")
        line:setPosition(currPanelSize.width * 0.5, 0)
        self.controls.attrPanelNode:addChild(line)

        local controls_hp = cc.Sprite:create("image/ui/img/btn/btn_673.png")
        controls_hp:setPosition(currPanelSize.width * 0.06, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_hp)
        self.controls.hp = Common.finalFont("999999", currPanelSize.width * 0.165, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.hp)
        local controls_def = cc.Sprite:create("image/ui/img/btn/btn_676.png")
        controls_def:setPosition(currPanelSize.width * 0.06, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_def)
        self.controls.def = Common.finalFont("999999", currPanelSize.width * 0.165, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.def)
        local controls_atk = cc.Sprite:create("image/ui/img/btn/btn_674.png")
        controls_atk:setPosition(currPanelSize.width * 0.295, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_atk)
        self.controls.atk = Common.finalFont("999999", currPanelSize.width * 0.4, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.atk)
        local controls_mp = cc.Sprite:create("image/ui/img/btn/btn_675.png")
        controls_mp:setPosition(currPanelSize.width * 0.295, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_mp)
        self.controls.mp = Common.finalFont("999999", currPanelSize.width * 0.4, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.mp)

        local controls_hit = cc.Sprite:create("image/ui/img/btn/btn_677.png")
        controls_hit:setPosition(currPanelSize.width * 0.56, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_hit)
        self.controls.hit = Common.finalFont("999999", currPanelSize.width * 0.665, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.hit)
        local controls_miss = cc.Sprite:create("image/ui/img/btn/btn_780.png")
        controls_miss:setPosition(currPanelSize.width * 0.56, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_miss)
        self.controls.miss = Common.finalFont("999999", currPanelSize.width * 0.665, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.miss)
        local controls_crit = cc.Sprite:create("image/ui/img/btn/btn_678.png")
        controls_crit:setPosition(currPanelSize.width * 0.795, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_crit)
        self.controls.crit = Common.finalFont("999999", currPanelSize.width * 0.9, currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.crit)
        local controls_ten = cc.Sprite:create("image/ui/img/btn/btn_679.png")
        controls_ten:setPosition(currPanelSize.width * 0.795, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(controls_ten)
        self.controls.ten = Common.finalFont("999999", currPanelSize.width * 0.9, -currPanelSize.height * 0.2)
        self.controls.attrPanelNode:addChild(self.controls.ten)

        self.controls.tfp = Common.finalFont("", 210, 60, 30, cc.c3b(255, 194, 1), 1)
        self.controls.tfp:setAnchorPoint(0.5, 0)
        self.controls.tfp:setAdditionalKerning(-2)
        self.controls.tfp:setPosition(self.data.size.width * 0.05, -self.data.size.height * 0.2)
        self:addChild(self.controls.tfp, attributeZOrder)

        local delayNode = cc.Node:create()
        self:addChild(delayNode)
        local delay = cc.DelayTime:create(0.3)
        local callFunc = cc.CallFunc:create(function()
            local animSize = cc.size(250, 240)
            self.controls.heroAnimView = self:createAnimView(animSize)
            self.controls.heroAnimView:setPosition(-self.data.size.width * 0.23, -self.data.size.height * 0.12)
            self:addChild(self.controls.heroAnimView, attrZOrder)
            local currPageIdx = self.data.heroSortId - 1
            self:createHeroAnim(currPageIdx)
            self.controls.heroAnimView:scrollToPage(currPageIdx)

            local animBG = self:createAnimBG(animSize)
            animBG:setPosition(-self.data.size.width * 0.26, -self.data.size.height * 0.12)
            self:addChild(animBG, attrZOrder)

            local layerColor = Common.createClickLayer(animSize.width, animSize.height, -self.data.size.width * 0.23, -self.data.size.height * 0.12) 
            self:addChild(layerColor, attrZOrder)
        end)
        local removeSelf = cc.RemoveSelf:create()

        delayNode:runAction(cc.Sequence:create({delay, callFunc, removeSelf}))
    end
    allAttribute()

    local function createArrowBtns()
        self.controls.left_btn = ccui.Button:create("image/ui/img/btn/btn_1005.png", "image/ui/img/btn/btn_1005.png")
        self.controls.left_btn:setName("left")
        self.controls.left_btn:setScale(0.8)
        self.controls.left_btn:setPosition(-self.data.size.width * 0.45,  -self.data.size.height * 0.28)
        self:addChild(self.controls.left_btn, attributeZOrder)
        self.controls.left_btn:setVisible(false)

        self.controls.right_btn = ccui.Button:create("image/ui/img/btn/btn_1005.png", "image/ui/img/btn/btn_1005.png")
        self.controls.right_btn:setName("right")
        self.controls.right_btn:setRotation(180)
        self.controls.right_btn:setScale(0.8)
        self.controls.right_btn:setPosition(self.data.size.width * 0.45,  -self.data.size.height * 0.28)
        self:addChild(self.controls.right_btn, attributeZOrder)

        local move1 = cc.MoveBy:create(1, cc.p(-5, 0))
        local move1_reverse = move1:reverse()
        local move2 = cc.MoveBy:create(1, cc.p(5, 0))
        local move2_reverse = move2:reverse()
        self.controls.left_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move1_reverse)))
        self.controls.right_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(move2, move2_reverse)))
    end
    createArrowBtns()

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            self.beganX = touch:getLocation().x
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            local moveSpace = self.controls.attributeBG:getContentSize().width * 0.5
            local leftMoveSpace = -moveSpace
            local rightMoveSpace = moveSpace

            self.endX = touch:getLocation().x
            local delta = self.endX - self.beganX
            if delta > 10 then
                CCLog("============rightMove==============")
                if not self.data.isMove then
                    if not self.data.isInLeft then
                        self.controls.left_btn:setVisible(false)
                        self.data.isMove = true
                        self.controls.attrPanelNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(rightMoveSpace,0)), cc.CallFunc:create(function()
                            self.controls.right_btn:setVisible(true)
                            self.data.isInLeft = true
                            self.data.isMove = false
                        end)))
                    end
                end
            elseif delta < -10 then
                CCLog("============leftMove==============")
                if not self.data.isMove then
                    if self.data.isInLeft then
                        self.controls.right_btn:setVisible(false)
                        self.data.isMove = true
                        self.controls.attrPanelNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(leftMoveSpace,0)), cc.CallFunc:create(function()
                            self.controls.left_btn:setVisible(true)
                            self.data.isInLeft = false
                            self.data.isMove = false
                        end)))
                    end
                end
            end

        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.attributeBG)
end

function DigestPanel:updateHeroInfo(heroInfo, configInfo)
    self.data.chooseHeroInfo = heroInfo
    self.data.chooseHeroConfigInfo = configInfo

    self.data.currTFP = self.data.chooseHeroInfo.TFP
    self:updateAttribute(self.data.chooseHeroInfo.HP,
                        self.data.chooseHeroInfo.Def,
                        self.data.chooseHeroInfo.Atk,
                        self.data.chooseHeroInfo.MP,
                        self.data.chooseHeroInfo.Hit,
                        self.data.chooseHeroInfo.Miss,
                        self.data.chooseHeroInfo.Crit,
                        self.data.chooseHeroInfo.Ten,
                        self.data.chooseHeroInfo.TFP)
end

function DigestPanel:createAnimBG(ccSize)
    local animBg = ccui.ImageView:create()
    animBg:setScale9Enabled(true)
    animBg:loadTexture("image/ui/img/btn/btn_438.png")
    animBg:setSize(ccSize)
    animBg:setAnchorPoint(0, 0)
    animBg:setOpacity(0)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            return true
        end
        return false
    end
    local function onTouchMoved(touch, event)
        if self.data.isNeedShowNearAnim then
            self.data.isNeedShowNearAnim = false
            local currPageIdx = self.data.heroSortId - 1
            self:createHeroAnim(currPageIdx, true)
        end
    end
    local function onTouchEnded(touch, event)
        self.data.isNeedShowNearAnim = true
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, animBg)

    return animBg
end

function DigestPanel:createAnimView(ccSize)
    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setSize(ccSize)

    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageIdx = sender:getCurPageIndex()
            self:createHeroAnim(pageIdx)
            if self.data.heroSortId ~= (pageIdx + 1) then
                self.data.heroSortId = pageIdx + 1
                application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateHeroInfo, {SortID = self.data.heroSortId})
            end
        end
    end 

    for i = 1, (#self.data.allHero) do
        local layout = ccui.Layout:create()
        layout:setSize(ccSize)

        local imageView = ccui.ImageView:create()
        imageView:setScale9Enabled(true)
        imageView:loadTexture("image/ui/img/btn/btn_438.png")
        imageView:setSize(ccSize)
        imageView:setPosition(ccSize.width * 0.5, ccSize.height * 0.5)
        layout:addChild(imageView)
        imageView:setOpacity(0)
        pageView:addPage(layout)
    end
    pageView:addEventListenerPageView(pageViewEvent)

    if GameCache.NewbieGuide.State then
        pageView:setEnabled(false)
    end

    return pageView
end

function DigestPanel:createHeroAnim(pageIdx, isShowNearAnim)
    local function getHeroAnim(pageLayout, idx, isShow)
        local scaleConfig = BaseConfig.GetHeroScale(self.data.allHero[idx + 1].ID)
        local heroScale = scaleConfig.ShowScale / 10000
        local heroOffset = scaleConfig.Offset
        local pageSize = self.controls.heroAnimView:getContentSize()
        local heroAnim = nil
        if not pageLayout.isHaveAnim then
            heroAnim = heroaction.new(pageSize.width * 0.5 + heroOffset[1], pageSize.height * 0.12 + heroOffset[2], self.data.allHero[idx + 1].ID)
            heroAnim:setScale(heroScale)
            heroAnim:setTag(HEROANIMTAG)
            pageLayout:addChild(heroAnim)
            pageLayout.isHaveAnim = true
        else
            heroAnim = pageLayout:getChildByTag(HEROANIMTAG)
        end
        if isShow then
            heroAnim:setPositionY(pageSize.height * 0.12 + heroOffset[2])
            heroAnim:setVisible(true)
        else
            heroAnim:setPositionY(SCREEN_HEIGHT * 2)
            heroAnim:setVisible(false)
        end
    end

    local currPageLayout = self.controls.heroAnimView:getPage(pageIdx)
    getHeroAnim(currPageLayout, pageIdx, true)

    local firstIdx = 0
    local lastIdx = (#self.data.allHero) - 1
    if pageIdx ~= firstIdx then
        local idx = pageIdx - 1
        local beforePageLayout = self.controls.heroAnimView:getPage(idx)
        getHeroAnim(beforePageLayout, idx, isShowNearAnim)
    end

    if pageIdx ~= lastIdx then
        local idx = pageIdx + 1
        local rightNum = (idx + 2) > lastIdx and (lastIdx) or (idx + 2)
        for i=idx, rightNum do
            local afterPageLayout = self.controls.heroAnimView:getPage(i)
            getHeroAnim(afterPageLayout, i, isShowNearAnim)
        end
    end
end

function DigestPanel:updateAttribute(hp, def, atk, mp, hit, miss, crit, ten, tfp)
    self.controls.type:setString(BaseConfig.BATTLE_TYPE_NAME[(self.data.chooseHeroConfigInfo.atkSkill - 1000)])
    self.controls.specialty:setString(self.data.chooseHeroConfigInfo.specialty)
    self.controls.armType:setString(BaseConfig.ARM_TYPE_NAME[self.data.chooseHeroConfigInfo.armType])

    local value = tfp - self.data.currTFP
    self.data.currTFP = tfp
    self.controls.hp:setString(hp)
    self.controls.def:setString(def)
    self.controls.atk:setString(atk)
    self.controls.mp:setString(mp)
    self.controls.hit:setString(hit)
    self.controls.miss:setString(miss)
    self.controls.crit:setString(crit)
    self.controls.ten:setString(ten)
    self.controls.tfp:setString(tfp)

    self.controls.tfp:stopAllActions()
    self.controls.tfp:setScale(1)
    self.controls.tfp:setOpacity(255)
    if value > 0 then
        local scale1 = cc.ScaleTo:create(0.2, 2)
        local scale2 = cc.ScaleTo:create(0.02, 1)
        self.controls.tfp:runAction(cc.Sequence:create(scale1, scale2))
    elseif value < 0 then
        local fade = cc.FadeOut:create(0.1)
        local fade_reverse = fade:reverse()
        local rep = cc.Repeat:create(cc.Sequence:create(fade:clone(), fade_reverse:clone()), 4)
        self.controls.tfp:runAction(rep)
    end
end

function DigestPanel:setBottomPanelPos(x, y)
    self.controls.attributeBG:setPosition(x, y)
    self.controls.clippingNode:setPosition(x, y)
    self.controls.left_btn:setPosition(x - self.data.size.width * 0.48, y)
    self.controls.right_btn:setPosition(x + self.data.size.width * 0.48, y)
end

function DigestPanel:changeSkin(equipType, equipID)
    local currPageLayout = self.controls.heroAnimView:getPage(self.data.heroSortId - 1)
    local heroAnim = currPageLayout:getChildByTag(HEROANIMTAG)
    heroAnim:changeSkin(equipType, equipID)
end

return DigestPanel
