local EquipDecompose = class("EquipDecompose", BaseLayer)

-- 由于碎片属于道具类，无法区别装备碎片和时装碎片(与读取配置有关)
-- 现在暂且用ID区分，ID大于3000的即为时装碎片
local PropsIDLimit = 3000

function EquipDecompose:ctor(goodsInfo, parentView)
    self.data.goodsItem = goodsInfo
    self.data.parentView = parentView
    self.data.goodsInfo = goodsInfo:getGoodsInfo()

    self:createUI()
    self:showData()

    self.data.isCanDecompose = true
end

function EquipDecompose:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_138.png") 
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    self.controls.fjNum = Common.finalFont("", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.fjNum:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.85)
    self.controls.bg:addChild(self.controls.fjNum)
    local tiao = cc.Sprite:create("image/ui/img/btn/btn_585.png") 
    tiao:setPosition(self.data.bgSize.width * 0.17, self.data.bgSize.height * 0.85)
    self.controls.bg:addChild(tiao)
    tiao = cc.Sprite:create("image/ui/img/btn/btn_585.png") 
    tiao:setScaleX(-1)
    tiao:setPosition(self.data.bgSize.width * 0.83, self.data.bgSize.height * 0.85)
    self.controls.bg:addChild(tiao)

    if self.data.goodsInfo.ID > PropsIDLimit then
        local compoundId = BaseConfig.GetProps(self.data.goodsInfo.ID).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local skinInfo = {}
        skinInfo.ID = fragToEquipConfig.productID
        skinInfo.StarLevel =  fragToEquipConfig.starLevel
        self.controls.goodsEquip = GoodsInfoNode.new(BaseConfig.GOODS_SKIN, skinInfo)
        self.controls.goodsEquip:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.65)
        self.controls.bg:addChild(self.controls.goodsEquip)
    else
        local compoundId = BaseConfig.GetProps(self.data.goodsInfo.ID).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local equipID = fragToEquipConfig.productID
        local equipStarLevel =  fragToEquipConfig.starLevel
        local equipInfo = GameCache.GetEquip(equipID, equipStarLevel)
        if not equipInfo then
            equipInfo = {}
            equipInfo.ID = equipID
            equipInfo.StarLevel = equipStarLevel
            equipInfo.Type = BaseConfig.GT_EQUIP
            equipInfo.Num = 0
        end
        self.controls.goodsEquip = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, equipInfo)
        self.controls.goodsEquip:setTips(true)
        self.controls.goodsEquip:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.65)
        self.controls.bg:addChild(self.controls.goodsEquip)
    end
    self.controls.equipName = Common.finalFont("", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.equipName:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.47)
    self.controls.bg:addChild(self.controls.equipName)

    self.controls.goodsFrag = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, self.data.goodsInfo)
    self.controls.goodsFrag:setTips(true)
    self.controls.goodsFrag:setPosition(self.data.bgSize.width * 0.72, self.data.bgSize.height * 0.65)
    self.controls.bg:addChild(self.controls.goodsFrag)
    self.controls.fragNum = Common.finalFont("", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.fragNum:setPosition(self.data.bgSize.width * 0.72, self.data.bgSize.height * 0.47)
    self.controls.bg:addChild(self.controls.fragNum)

    local jiantou = cc.Sprite:create("image/ui/img/btn/btn_586.png") 
    jiantou:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.65)
    self.controls.bg:addChild(jiantou)

    local btn_one = createMixScale9Sprite("image/ui/img/btn/btn_584.png", nil, nil, cc.size(155, 66))
    btn_one:setCircleFont("分解1次", 1, 1, 25)
    btn_one:setPosition(self.data.bgSize.width * 0.27, self.data.bgSize.height * 0.18)
    self.controls.bg:addChild(btn_one)
    btn_one:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended and self.data.isCanDecompose then
            self.data.isCanDecompose = false
            self:fjEquip(1)
        end
    end)

    local btn_more = createMixScale9Sprite("image/ui/img/btn/btn_584.png", nil, nil, cc.size(155, 66))
    btn_more:setCircleFont("全部分解", 1, 1, 25)
    btn_more:setPosition(self.data.bgSize.width * 0.73, self.data.bgSize.height * 0.18)
    self.controls.bg:addChild(btn_more)
    btn_more:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended and self.data.isCanDecompose then
            self.data.isCanDecompose = false
            self:fjEquip(self.data.goodsInfo.Num)
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
            self:exitAction()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.bg)
end

function EquipDecompose:showData()
    local compoundId = BaseConfig.GetProps(self.data.goodsInfo.ID).useValue
    local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
    if fragToEquipConfig.material == self.data.goodsInfo.ID then
        self.data.fjPropsNum = fragToEquipConfig.num
    else
        self.data.fjPropsNum = 0
        CCLog("装备ID和碎片合成ID不相等")
    end
    self.data.fjPropsNum = math.ceil(self.data.fjPropsNum * 0.7)
    if self.data.goodsInfo.ID > PropsIDLimit then
        self.data.fragEquipName = BaseConfig.GetSkin(fragToEquipConfig.productID).Name
    else
        self.data.fragEquipName = BaseConfig.GetEquip(fragToEquipConfig.productID, fragToEquipConfig.starLevel).name
    end

    self.controls.fjNum:setString("最多分解"..self.data.goodsInfo.Num * self.data.fjPropsNum.."个")
    self.controls.fragNum:setString(self.data.fjPropsNum.."个")
    self.controls.equipName:setString(self.data.fragEquipName)
end

function EquipDecompose:updateFragAndEquip(fjNum, equipFragTab)
    --碎片增加
    equipFragTab.Type = BaseConfig.GT_PROPS
    GameCache.addProps(equipFragTab, true)

    --装备减少
    GameCache.minusEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel, fjNum)
    self.data.goodsItem:setNum()
    if 0 == self.data.goodsInfo.Num then
        self.data.parentView:updateView()
        self:exitAction()
    end

    self.controls.fjNum:setString("最多分解"..self.data.goodsInfo.Num * self.data.fjPropsNum.."个")
    self.controls.fragNum:setString(self.data.fjPropsNum.."个")
end

function EquipDecompose:fjEquip(fjNum)
    rpc:call("Equip.Decompose", {ID = self.data.goodsInfo.ID, Num = fjNum}, function(event)
        if event.status == Exceptions.Nil then
            local equipFragTab = event.result
            self:updateFragAndEquip(fjNum, equipFragTab)
            application:showFlashNotice("分解成功~!")

            self.data.isCanDecompose = true
        end
    end)
end

return EquipDecompose

