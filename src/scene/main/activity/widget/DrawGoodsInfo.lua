local DrawGoodsInfo = class("DrawGoodsInfo", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    return node
end)

local UNFINISHSTATUS = 0
local RECEIVESTATUS = UNFINISHSTATUS + 1
local FINISHSTATUS = RECEIVESTATUS + 1

local rearZOrder = 1
local frontZOrder = rearZOrder + 1

local bgSize = cc.size(88, 88)

function DrawGoodsInfo:ctor(goodsInfo, isCard)
    self.data.goodsInfo = {}
    self.controls.frontNode = cc.Node:create()
    self:addChild(self.controls.frontNode, frontZOrder)
    self.controls.rearNode = cc.Node:create()
    self:addChild(self.controls.rearNode, rearZOrder)

    self.data.isFliping = false -- 是否正在翻转
    self.data.isFront = true -- 是否处于正面

    if isCard then
        self.data.isLight = goodsInfo.IsLight
        self.data.childGoodsInfo = goodsInfo.Reward
        self.data.goodsInfo.Type = goodsInfo.IconType
        self.data.goodsInfo.ID = goodsInfo.IconID
        self.data.goodsInfo.StarLevel = 5
    else
        self.data.status = goodsInfo.Status
        self.data.goodsInfo = goodsInfo.Reward
    end

    self.controls.goodsItem = Common.getGoods(self.data.goodsInfo, false, BaseConfig.GOODS_MIDDLETYPE)
    self.controls.frontNode:addChild(self.controls.goodsItem)
    if self.controls.goodsItem.setNumVisible then
        self.controls.goodsItem:setNumVisible(false)
    end
    if self.controls.goodsItem.setTips then
        self.controls.goodsItem:setTips(false)
    end

    if isCard then
        self.controls.light = cc.Sprite:create("image/ui/img/btn/btn_813.png")
        self.controls.light:setScale(0.8)
        self.controls.frontNode:addChild(self.controls.light)
        self.controls.light:setVisible(not self.data.isLight)

        self.controls.rearBg = cc.Sprite:create("image/ui/img/bg/bg_210.png")
        self.controls.rearBg:setScale(0.9)
        self.controls.rearNode:addChild(self.controls.rearBg, rearZOrder)

        self.controls.award = Common.getGoods(self.data.childGoodsInfo, false, BaseConfig.GOODS_SMALLTYPE)
        if self.controls.award.setTouchEnable then
            self.controls.award:setTouchEnable(false)
        end
        if self.controls.award.setTips then
            self.controls.award:setTips(false)
        end
        self.controls.rearNode:addChild(self.controls.award, rearZOrder)
    else
        self.controls.receive = load_animation("image/spine/skill_effect/ragebox/blue/", 1)
        self.controls.receive:setScale(0.8)
        self.controls.receive:setAnimation(0, "animation", true)
        self:addChild(self.controls.receive, frontZOrder)

        self.controls.finish = cc.Sprite:create("image/ui/img/btn/btn_502.png")
        self:addChild(self.controls.finish, frontZOrder)

        self.controls.receive:setVisible(false)
        self.controls.finish:setVisible(false)
        if RECEIVESTATUS == self.data.status then
            self.controls.receive:setVisible(true)
        elseif FINISHSTATUS == self.data.status then
            self.controls.finish:setVisible(true)
        end
    end
    
end

function DrawGoodsInfo:setLight(visible)
    self.data.isLight = visible
    self.controls.light:setVisible(not self.data.isLight)
end

function DrawGoodsInfo:isFront()
    return self.data.isFront
end

function DrawGoodsInfo:getRewardInfo()
    return self.data.childGoodsInfo
end

function DrawGoodsInfo:setChooseBorderVisible(visible)
    self.controls.goodsItem:setChooseBorderVisible(visible)
end

function DrawGoodsInfo:setSetDesc(number)
    local desc = Common.finalFont("第"..number.."套", 1, 1, 20, nil, 1)
    desc:setPosition(0, -bgSize.height * 0.5)
    self:addChild(desc, frontZOrder)
end

function DrawGoodsInfo:setTips(visible)
    if self.controls.goodsItem.setTips then
        self.controls.goodsItem:setTips(visible)
    end
end

function DrawGoodsInfo:setNumVisible(visible)
    if self.controls.goodsItem.setNumVisible then
        self.controls.goodsItem:setNumVisible(visible)
    end
end

function DrawGoodsInfo:setReceive()
    self.data.status = RECEIVESTATUS
    self.controls.receive:setVisible(true)
end

function DrawGoodsInfo:setFinish()
    self.data.status = FINISHSTATUS
    self.controls.finish:setVisible(true)
    self.controls.receive:setVisible(false)
end

function DrawGoodsInfo:isLight()
    return self.data.isLight
end

function DrawGoodsInfo:isReceive()
    if RECEIVESTATUS == self.data.status then
        return true
    else
        return false
    end
end

function DrawGoodsInfo:isFinish()
    if FINISHSTATUS == self.data.status then
        return true
    else
        return false
    end
end

function DrawGoodsInfo:flipAction()
    local function palyAction(firstNode, seconeNode, isFront)
        firstNode:setScale(1)
        seconeNode:setScale(0)
        local orbit1 = cc.OrbitCamera:create(0.2,1, 0, 0, 80, 0, 0) 
        local orbit11 = cc.OrbitCamera:create(0.01,1, 0, -90, 90, 0, 0)
        local delay1 = cc.DelayTime:create(3)
        local func1 = cc.CallFunc:create(function()
            firstNode:setScale(0)
            seconeNode:setScale(1)
            local orbit2 = cc.OrbitCamera:create(0.2,1, 0, -90, 90, 0, 0)
            func2 = cc.CallFunc:create(function()
                firstNode:setScale(0.85)
                if isFront then
                    self.data.isFront = false
                    self.data.isFliping = false
                else
                    firstNode:stopAllActions()
                    seconeNode:stopAllActions()
                    self.data.isFront = true
                    self.data.isFliping = false
                end
                seconeNode:setLocalZOrder(frontZOrder)
                firstNode:setLocalZOrder(rearZOrder)
            end)
            seconeNode:runAction(cc.Sequence:create(orbit2, func2))
        end)
        local func11 = cc.CallFunc:create(function()
            if isFront then
                palyAction(self.controls.rearNode, self.controls.frontNode)
            end
        end)
        firstNode:runAction(cc.Sequence:create(orbit1, func1, orbit11, delay1, func11))
    end
    if not self.data.isFliping then
        self.data.isFliping = true
        if self.data.isFront then
            palyAction(self.controls.frontNode, self.controls.rearNode, true)
        else
            self.controls.frontNode:stopAllActions()
            self.controls.rearNode:stopAllActions()
            self.controls.frontNode:setScale(0)
            self.controls.rearNode:setScale(0)
            palyAction(self.controls.rearNode, self.controls.frontNode)
        end
    end
end

function DrawGoodsInfo:addTouchEventListener(event)
    self.controls.goodsItem:addTouchEventListener(event)
end

return DrawGoodsInfo


