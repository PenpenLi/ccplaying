local SaleDialog = class("SaleDialog", BaseLayer)

local ColorLabel = require("tool.helper.ColorLabel")

function SaleDialog:ctor(currGoods, goodsItem, currView, parentView)
    self.data.currName = 0
    self.data.currGoodsInfo = currGoods
    self.data.goodsItem = goodsItem
    self.data.goodsInfo = goodsItem:getGoodsInfo()
    self.data.goodsConfig = goodsItem:getGoodsConfigInfo()
    self.data.currView = currView
    self.data.parentView = parentView

    self:createUI()
    self:Showdata()
end

function SaleDialog:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_137.png") 
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    local tiao = cc.Sprite:create("image/ui/img/btn/btn_585.png") 
    tiao:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.78)
    self.controls.bg:addChild(tiao)
    tiao = cc.Sprite:create("image/ui/img/btn/btn_585.png") 
    tiao:setScaleX(-1)
    tiao:setPosition(self.data.bgSize.width * 0.8, self.data.bgSize.height * 0.78)
    self.controls.bg:addChild(tiao)

    local goodsName = Common.finalFont(self.data.goodsConfig.name, 1, 1, 25, cc.c3b(72, 106, 167))
    goodsName:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.78)
    self.controls.bg:addChild(goodsName)

    local subtract = createMixSprite("image/ui/img/btn/btn_587.png")
    subtract:setPosition(self.data.bgSize.width * 0.15, self.data.bgSize.height * 0.57)
    self.controls.bg:addChild(subtract)
    subtract:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.currName > 0 then
                self.data.currName = self.data.currName - 1
                self:Showdata()
            end
        end
    end)

    local add = createMixSprite("image/ui/img/btn/btn_582.png")
    add:setPosition(self.data.bgSize.width * 0.65, self.data.bgSize.height * 0.57)
    self.controls.bg:addChild(add)
    add:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.currName < self.data.currGoodsInfo.Num then
                self.data.currName = self.data.currName + 1
                self:Showdata()
            end
        end
    end)

    local max = createMixSprite("image/ui/img/btn/btn_583.png")
    max:setPosition(self.data.bgSize.width * 0.82, self.data.bgSize.height * 0.57)
    self.controls.bg:addChild(max)
    max:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.data.currName = self.data.currGoodsInfo.Num
            self:Showdata()
        end
    end)

    self.controls.showNum = ColorLabel.new("", 20, nil, true)
    self.controls.showNum:setPosition(self.data.bgSize.width * 0.4, self.data.bgSize.height * 0.57)
    self.controls.bg:addChild(self.controls.showNum)

    local price = cc.Sprite:create("image/ui/img/btn/btn_035.png") 
    price:setPosition(self.data.bgSize.width * 0.2, self.data.bgSize.height * 0.26)
    self.controls.bg:addChild(price)
    self.controls.showPrice = Common.finalFont("", 1, 1, 25, cc.c3b(72, 106, 167))
    self.controls.showPrice:setPosition(self.data.bgSize.width * 0.25, self.data.bgSize.height * 0.26)
    self.controls.showPrice:setAnchorPoint(0, 0.5)
    self.controls.bg:addChild(self.controls.showPrice)

    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_584.png", nil, nil, cc.size(114, 66))
    btn_sure:setCircleFont("确定", 1, 1, 25)
    btn_sure:setPosition(self.data.bgSize.width * 0.76, self.data.bgSize.height * 0.26)
    self.controls.bg:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:SaleProps(self.data.currGoodsInfo.ID, self.data.currName)
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

function SaleDialog:Showdata()
    self.controls.showPrice:setString(self.data.currName * self.data.currGoodsInfo.price)
    self.controls.showNum:setString("[72, 106, 167]"..self.data.currName.."[=][198, 93, 42]/"..self.data.currGoodsInfo.Num.."[=]")
end

--[[
    出售道具
]]-- 
function SaleDialog:SaleProps(id, number)
    rpc:call("Props.SaleProps", {ID = id, Num = number}, function(event)
        if event.status == Exceptions.Nil then
            local goodsNum = event.result
            local tab = nil
            local isProps = true
            if self.data.currView == 2 then
                tab = GameCache.GetAllFrag()
                isProps = false
            elseif self.data.currView == 3 then
                tab = GameCache.GetAllProps()
            end
            for k,v in pairs(tab) do
                if self.data.currGoodsInfo.ID == v.ID then
                    v.Num = goodsNum
                    -- view重用时，goodsItem中的goodsInfo会被替换，判断当前goodsID是不是和view可视区域中的goodsInfo.ID相同
                    if self.data.currGoodsInfo.ID == self.data.goodsInfo.ID then
                        self.data.goodsItem:setNum(self.data.goodsItem.Num)
                        self.data.goodsItem:setFragAlert()
                    end
                    if v.Num <= 0 then
                        if isProps then
                            GameCache.minusProps(v.ID, 0)
                        else
                            GameCache.minusFrag(v.ID, 0)
                        end
                        self.data.parentView:updateView()
                    end
                    break
                end
            end
            application:dispatchCustomEvent(AppEvent.UI.Package.isFragCompound, {})
            self:exitAction()
        end
    end)
end

return SaleDialog

