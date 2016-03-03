local FragCompound = class("FragCompound", BaseLayer)

-- 由于碎片属于道具类，无法区别装备碎片和时装碎片(与读取配置有关)
-- 现在暂且用ID区分，ID大于3000的即为时装碎片
local PropsIDLimit = 3000

function FragCompound:ctor(goodsInfo, parentView)
    self.data.goodsItem = goodsInfo
    self.data.parentView = parentView
    self.data.goodsInfo = goodsInfo:getGoodsInfo()

    self:createUI()
    self:showData()

    self.data.isCanCompound = true
end

function FragCompound:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_138.png") 
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    self.controls.compoundNum = Common.finalFont("最多合成1000个", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.compoundNum:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.85)
    self.controls.bg:addChild(self.controls.compoundNum)
    local tiao = cc.Sprite:create("image/ui/img/btn/btn_585.png") 
    tiao:setPosition(self.data.bgSize.width * 0.17, self.data.bgSize.height * 0.85)
    self.controls.bg:addChild(tiao)
    tiao = cc.Sprite:create("image/ui/img/btn/btn_585.png") 
    tiao:setScaleX(-1)
    tiao:setPosition(self.data.bgSize.width * 0.83, self.data.bgSize.height * 0.85)
    self.controls.bg:addChild(tiao)

    self.controls.goodsFrag = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, self.data.goodsInfo)
    self.controls.goodsFrag:setTips(true)
    self.controls.goodsFrag:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.65)
    self.controls.bg:addChild(self.controls.goodsFrag)
    self.controls.fragNum = Common.finalFont("10/20", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.fragNum:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.47)
    self.controls.bg:addChild(self.controls.fragNum)
    local price = cc.Sprite:create("image/ui/img/btn/btn_035.png") 
    price:setPosition(self.data.bgSize.width * 0.18, self.data.bgSize.height * 0.35)
    self.controls.bg:addChild(price)
    self.controls.oneMoney = Common.finalFont("10000", 1, 1, 25, cc.c3b(198, 93, 42))
    self.controls.oneMoney:setPosition(self.data.bgSize.width * 0.23, self.data.bgSize.height * 0.35)
    self.controls.oneMoney:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.oneMoney)
    

    local jiantou = cc.Sprite:create("image/ui/img/btn/btn_586.png") 
    jiantou:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.65)
    self.controls.bg:addChild(jiantou)

    if self.data.goodsInfo.ID > PropsIDLimit then
        local compoundId = BaseConfig.GetProps(self.data.goodsInfo.ID).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local skinInfo = {}
        skinInfo.ID = fragToEquipConfig.productID
        skinInfo.StarLevel =  fragToEquipConfig.starLevel
        self.controls.goodsEquip = GoodsInfoNode.new(BaseConfig.GOODS_SKIN, skinInfo)
        self.controls.goodsEquip:setPosition(self.data.bgSize.width * 0.72, self.data.bgSize.height * 0.65)
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
        self.controls.goodsEquip:setPosition(self.data.bgSize.width * 0.72, self.data.bgSize.height * 0.65)
        self.controls.bg:addChild(self.controls.goodsEquip)
    end
    self.controls.equipName = Common.finalFont("XXXXX", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.equipName:setPosition(self.data.bgSize.width * 0.72, self.data.bgSize.height * 0.47)
    self.controls.bg:addChild(self.controls.equipName)
    price = cc.Sprite:create("image/ui/img/btn/btn_035.png") 
    price:setPosition(self.data.bgSize.width * 0.63, self.data.bgSize.height * 0.35)
    self.controls.bg:addChild(price)
    self.controls.allMoney = Common.finalFont("999999", 1, 1, 25, cc.c3b(198, 93, 42))
    self.controls.allMoney:setPosition(self.data.bgSize.width * 0.68, self.data.bgSize.height * 0.35)
    self.controls.allMoney:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.allMoney)

    local btn_one = createMixScale9Sprite("image/ui/img/btn/btn_584.png", nil, nil, cc.size(155, 66))
    btn_one:setCircleFont("合成1次", 1, 1, 25)
    btn_one:setPosition(self.data.bgSize.width * 0.27, self.data.bgSize.height * 0.18)
    self.controls.bg:addChild(btn_one)
    btn_one:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if (GameCache.Avatar.Coin >= self.data.onePrice) 
                and (self.data.allNum >= self.data.needPropsNum) then
                if self.data.isCanCompound then
                    self.data.isCanCompound = false
                    self:CompoundEquip(self.data.goodsInfo.ID, 1, self.data.onePrice)
                end
            else
                local isMinusNum = Common.isCostMoney(1002, self.data.onePrice)
                if isMinusNum then
                    application:showFlashNotice("个数不足~!")
                end
            end
        end
    end)

    local btn_more = createMixScale9Sprite("image/ui/img/btn/btn_584.png", nil, nil, cc.size(155, 66))
    btn_more:setCircleFont("全部合成", 1, 1, 25)
    btn_more:setPosition(self.data.bgSize.width * 0.73, self.data.bgSize.height * 0.18)
    self.controls.bg:addChild(btn_more)
    btn_more:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if 0 == self.data.totalCount then
                if self.data.allNum >= self.data.needPropsNum then
                    application:showFlashNotice("银币不足~!")
                else
                    application:showFlashNotice("个数不足~!")
                end
                return 
            end

            if (GameCache.Avatar.Coin >= self.data.totalPrice)
                and (self.data.allNum >= self.data.needPropsNum) then
                self:CompoundEquip(self.data.goodsInfo.ID, self.data.totalCount, self.data.totalPrice)
            else
                Common.isCostMoney(1002, self.data.totalPrice)
            end
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

function FragCompound:showData()
    self.data.allNum = self.data.goodsInfo.Num
    local compoundId = BaseConfig.GetProps(self.data.goodsInfo.ID).useValue
    local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
    self.data.onePrice = fragToEquipConfig.coin
    if fragToEquipConfig.material == self.data.goodsInfo.ID then
        self.data.needPropsNum = fragToEquipConfig.num
    else
        self.data.needPropsNum = 0
        CCLog("装备ID和碎片合成ID不相等")
    end
    local totalCountByCoin = math.floor(GameCache.Avatar.Coin / self.data.onePrice)
    local totalCountByNum = math.floor(self.data.goodsInfo.Num / self.data.needPropsNum)
    self.data.totalCount = (totalCountByCoin >= totalCountByNum) and totalCountByNum or totalCountByCoin
    self.data.totalPrice = self.data.onePrice * self.data.totalCount
    if self.data.goodsInfo.ID > PropsIDLimit then
        self.data.fragEquipName = BaseConfig.GetSkin(fragToEquipConfig.productID).Name
    else
        self.data.fragEquipName = BaseConfig.GetEquip(fragToEquipConfig.productID, fragToEquipConfig.starLevel).name
    end

    self.controls.compoundNum:setString("最多合成"..self.data.totalCount.."个")
    self.controls.fragNum:setString(self.data.allNum.."/"..self.data.needPropsNum)
    self.controls.oneMoney:setString(self.data.onePrice)
    self.controls.equipName:setString(self.data.fragEquipName)
    self.controls.allMoney:setString(Common.numConvert(self.data.totalPrice))
end

function FragCompound:updatePanelInfo(compoundNum)
    self.data.totalCount = self.data.totalCount - compoundNum
    self.data.allNum = self.data.allNum - self.data.needPropsNum * compoundNum
    self.data.totalPrice = self.data.onePrice * self.data.totalCount

    self.controls.compoundNum:setString("最多合成"..self.data.totalCount.."个")
    self.controls.fragNum:setString(self.data.allNum.."/"..self.data.needPropsNum)
    self.controls.allMoney:setString(Common.numConvert(self.data.totalPrice))
end

function FragCompound:updateFragAndEquip(id, compoundNum, equipTab)
    --碎片减少
    self.data.goodsItem:setNum(self.data.allNum)
    GameCache.minusFrag(id, compoundNum * self.data.needPropsNum)
    if 0 == self.data.allNum then
        self.data.parentView:updateView()
    end
    self.data.goodsItem:setFragAlert()
    
    --装备增加 -- 判断是否有此装备(有此替换数量，没有则添加)
    GameCache.resetEquip(equipTab)
end

-- 碎片合成
function FragCompound:CompoundEquip(id, compoundNum, costCoin)
    rpc:call("Props.CompoundEquip", {ID = id, Count = compoundNum}, function(event)
        if event.status == Exceptions.Nil then
            local equipTab = event.result.Equip
            self:updatePanelInfo(compoundNum)
            self:updateFragAndEquip(id, compoundNum, equipTab)
            application:dispatchCustomEvent(AppEvent.UI.Package.isFragCompound, {})
            application:showFlashNotice("合成成功~!")

            self.data.isCanCompound = true
        end
    end)
end

return FragCompound

