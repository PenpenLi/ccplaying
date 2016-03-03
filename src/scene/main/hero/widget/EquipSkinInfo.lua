local EquipSkinInfo = class("EquipSkinInfo", require("tool.helper.GoodsInfoIcon"))

function EquipSkinInfo:ctor(equipInfo, heroInfo, size)
    EquipSkinInfo.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, size)


    self.controls.lock = cc.Node:create()
    self:addChild(self.controls.lock)
    local masking = cc.Sprite:create("image/ui/img/btn/btn_813.png")
    masking:setScale(0.88)
    self.controls.lock:addChild(masking)
    local lock = cc.Sprite:create("image/ui/img/btn/btn_1159.png")
    lock:setAnchorPoint(1, 0)
    lock:setPosition(self.data.size.width * 0.45, -self.data.size.height * 0.45)
    self.controls.lock:addChild(lock)

    self:setGoodsInfo(equipInfo, heroInfo)
end

function EquipSkinInfo:setGoodsInfo(equipInfo, heroInfo)
    EquipSkinInfo.super.setGoodsInfo(self, equipInfo)
    if heroInfo then
        self.data.heroInfo = heroInfo
    end

    if equipInfo.IsActive then
        self.controls.lock:setVisible(false)
    else
        self.controls.lock:setVisible(true)
    end
end

function EquipSkinInfo:activeNotice()
    local runningScene = cc.Director:getInstance():getRunningScene()
    local node = cc.Node:create()
    runningScene:addChild(node)

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(cc.size(450, 320))
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)
    bg:setOpacity(230)
    local bgSize = bg:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(bgSize.width * 0.5, bgSize.height * 0.95)
    bg:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(bgSize.width * 0.5, bgSize.height * 0.95)
    bg:addChild(dian)

    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(bgSize.width * 0.5, bgSize.height * 0.95)
    bg:addChild(dian)

    local desc = Common.finalFont("亲,狗策划规定激活需要银币", 1, 1, 20, nil, 1)
    desc:setPosition(bgSize.width * 0.5, bgSize.height * 0.7)
    bg:addChild(desc)

    local coinSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    coinSpri:setPosition(bgSize.width * 0.43, bgSize.height * 0.5)
    bg:addChild(coinSpri)

    local costPrice = 1000
    local cost = Common.finalFont(costPrice, 1, 1, 20, cc.c3b(151, 255, 74), nil)
    cost:setPosition(bgSize.width * 0.55, bgSize.height * 0.5)
    bg:addChild(cost)

    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(bgSize.width * 0.5, bgSize.height * 0.22)
    bg:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local p = {
                HeroID = self.data.heroInfo.ID,
                SkinID = self.data.goodsInfo.ID,
            }
            rpc:call("Hero.ActivateSkin", p, function(event)
                if event.status == Exceptions.Nil then
                    self.data.goodsInfo.IsActive = true
                    self:setGoodsInfo(self.data.goodsInfo)
                    node:removeFromParent()
                    node = nil
                end
            end)
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            node:removeFromParent()
            node = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end

return EquipSkinInfo


