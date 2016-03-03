local CheckGoodsInfo = class("CheckGoodsInfo", function()
    return cc.Node:create()
end)

-- 签到状态：未签、已签到但VIP等级不足、VIP等级满足且已签到
local NOTCHECKSTATUS = 0
local HALFCHECKSTATUS = NOTCHECKSTATUS + 1
local ALLCHECKSTATUS = HALFCHECKSTATUS + 1

local ZOrder1 = 1
local ZOrder2 = ZOrder1 + 1

function CheckGoodsInfo:ctor(goodsInfo)
    self.goodsInfo = goodsInfo
    self.isTouchEnable = false

    self.bg = cc.Sprite:create("image/ui/img/btn/btn_412.png")
    self.bg:setOpacity(0)
    self:addChild(self.bg)

    self.goodsItem = Common.getGoods(goodsInfo, false, 1)
    self:addChild(self.goodsItem)

    self.getLabel = load_animation("image/spine/skill_effect/ragebox/blue/", 1)
    self.getLabel:setScale(0.9)
    self.getLabel:setAnimation(0, "animation", true)
    self.getLabel:setVisible(false)
    self:addChild(self.getLabel, ZOrder1)

    self.size = cc.size(100, 100)

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            if self.isTouchEnable then
                self:setScale(0.9)
                if self.func then
                    self.func(self, 0)
                end
                
            end
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
            if self.isTouchEnable then
                self:setScale(0.9)
            end
        else
            self:setScale(1)
        end
    end

    local function onTouchEnded(touch, event)
        self:setScale(1)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            if self.isTouchEnable then
                if self.func then
                    local isAddDay = true
                    if HALFCHECKSTATUS == self.todayStatus then
                        isAddDay = false
                    end
                    self.func(self, 2, isAddDay)
                end
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.bg)
end

function CheckGoodsInfo:getContentSize()
    return self.bg:getContentSize()
end

function CheckGoodsInfo:setDailyCheck(checkCount, todayStatus)
    self.checkCount = checkCount
    self.todayStatus = todayStatus

    self.bangou = cc.Node:create()
    local bg = cc.Sprite:create("image/ui/img/btn/btn_813.png")
    self.bangou:addChild(bg)
    local gou = cc.Sprite:create("image/ui/img/btn/btn_504.png")
    self.bangou:addChild(gou)
    self:addChild(self.bangou)

    self.gou = cc.Node:create()
    bg = cc.Sprite:create("image/ui/img/btn/btn_813.png")
    self.gou:addChild(bg)
    gou = cc.Sprite:create("image/ui/img/btn/btn_502.png")
    self.gou:addChild(gou)
    self:addChild(self.gou)

    self:setSignIn(NOTCHECKSTATUS)
    self:setVipLevel(self.goodsInfo)

    if todayStatus > NOTCHECKSTATUS then
        if self.goodsInfo.Count < checkCount then
            self:setSignIn(ALLCHECKSTATUS)
        end
        if self.goodsInfo.Count == checkCount then
            self:setSignIn(todayStatus)
        end

        if todayStatus == HALFCHECKSTATUS then
            if GameCache.Avatar.VIP >= self.goodsInfo.DoubleVIPLevel then
                if self.goodsInfo.Count == checkCount then
                    self.getLabel:setVisible(true)
                    self:setTouchEnable(true)
                    self:setSignIn(HALFCHECKSTATUS)
                end
            end
        end
    else
        if self.goodsInfo.Count < (checkCount + 1) then
            self:setSignIn(ALLCHECKSTATUS)
        end
        if self.goodsInfo.Count == (checkCount + 1) then
            self:setTouchEnable(true)
            self.getLabel:setVisible(true)
            self:setSignIn(todayStatus)
        end
    end
end

function CheckGoodsInfo:setAccCheck(CheckCount, AwardsCount)
    if CheckCount >= AwardsCount then
        self:setTouchEnable(true)
        self.getLabel:setVisible(true)
    else
        self:setTouchEnable(false)
    end
end

function CheckGoodsInfo:setGoodsInfo()
    if GameCache.Avatar.VIP >= self.goodsInfo.DoubleVIPLevel then
        self:setSignIn(ALLCHECKSTATUS)
    else
        self:setSignIn(HALFCHECKSTATUS)
    end
    self:setTouchEnable(false)
    self.getLabel:setVisible(false)
end

function CheckGoodsInfo:setSignIn(status)
    if status == NOTCHECKSTATUS then
        self.bangou:setVisible(false)
        self.gou:setVisible(false)
    elseif status == HALFCHECKSTATUS then
        self.bangou:setVisible(true)
        self.gou:setVisible(false)
    elseif status == ALLCHECKSTATUS then
        self.bangou:setVisible(false)
        self.gou:setVisible(true)
    end
end

function CheckGoodsInfo:setVipLevel(goodsInfo)
    if goodsInfo.DoubleVIPLevel > 0 then
        local vipLevelSpri = cc.Sprite:create("image/ui/img/btn/btn_503.png")
        vipLevelSpri:setPosition(-self.size.width * 0.27, self.size.height * 0.27)
        self:addChild(vipLevelSpri, ZOrder2)

        local vipLevel = Common.finalFont("V"..goodsInfo.DoubleVIPLevel.."双倍", 1, 1, 15, cc.c3b(255, 220, 20), 1)
        vipLevel:setAdditionalKerning(-2)
        vipLevel:setRotation(-44)
        vipLevel:setPosition(-self.size.width * 0.3, self.size.height * 0.35)
        self:addChild(vipLevel, ZOrder2)
    end
end

function CheckGoodsInfo:setTouchEnable(value)
    self.isTouchEnable = value
end

function CheckGoodsInfo:addTouchEventListener(event)
    self.func = event
end

return CheckGoodsInfo


