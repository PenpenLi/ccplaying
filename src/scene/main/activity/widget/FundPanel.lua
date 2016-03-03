local FundPanel = class("FundPanel", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    return node
end)

local ColorLabel = require("tool.helper.ColorLabel")

function FundPanel:ctor()
    self:createUI()
end

function FundPanel:createUI()
    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_335.png") 
    self.controls.bg:setAnchorPoint(0, 0.5)
    self:addChild(self.controls.bg)
    local bgSize = self.controls.bg:getContentSize()
    self.data.bgSize = bgSize

    self.controls.goodsNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.goodsNode)
    
    self.controls.finish = cc.Sprite:create("image/ui/img/btn/btn_864.png")
    self.controls.finish:setPosition(bgSize.width * 0.85, bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.finish)

    self.controls.btn_receive = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(110, 70))
    self.controls.btn_receive:setButtonBounce(false)
    self.controls.btn_receive:setCircleFont("领取", 1, 1, 30, cc.c3b(238, 205, 142), 1)
    self.controls.btn_receive:setFontOutline(cc.c3b(70, 50, 14), 1)
    self.controls.btn_receive:setPosition(bgSize.width * 0.85, bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.btn_receive)
    self.controls.btn_receive:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:buttonFunc()
        end
    end)

    self:panelDesc()
end

function FundPanel:panelDesc()
    local bgSize = self.data.bgSize 
    self.controls.gold = Common.finalFont("", 1, 1, 20, cc.c3b(255, 255, 0), 1)
    self.controls.gold:setAnchorPoint(0, 0.5)
    self.controls.gold:setPosition(bgSize.width * 0.28, bgSize.height * 0.7)
    self.controls.bg:addChild(self.controls.gold)

    self.controls.level = ColorLabel.new("", 18)
    self.controls.level:setAnchorPoint(0, 0.5)
    self.controls.level:setPosition(bgSize.width * 0.28, bgSize.height * 0.3)
    self.controls.bg:addChild(self.controls.level)
end

function FundPanel:updatePanelInfo(activityConfig, status, ownValue, compareValue)
    self.controls.finish:setVisible(true)
    self.controls.btn_receive:setTouchEnable(true)
    self.controls.btn_receive:setVisible(true)

    if ownValue >= compareValue then
        if status then
            self.controls.btn_receive:setTouchEnable(false)
            self.controls.btn_receive:setVisible(false)
            self.controls.finish:setTexture("image/ui/img/btn/btn_864.png")
        else
            self.controls.finish:setVisible(false)
        end
    else
        self.controls.btn_receive:setTouchEnable(false)
        self.controls.btn_receive:setVisible(false)
        self.controls.finish:setTexture("image/ui/img/btn/btn_863.png")
    end

    self.data.activityConfig = activityConfig

    self:updateDesc(activityConfig)
    self:updateGoodsInfo(activityConfig)
end

function FundPanel:updateDesc(activityConfig)
    self.controls.gold:setString(activityConfig.Gold.."元宝")
    self.controls.level:setString("[255,255,255]到达[=][255,138,0]"..activityConfig.Level.."级[=][255,255,255]可领取[=]")
end

function FundPanel:updateGoodsInfo(activityConfig)
    self.controls.goodsNode:removeAllChildren()

    local goodsItem = Common.getGoods({Type = BaseConfig.GT_MONEY, ID = 1001, Num = activityConfig.Gold}, false, BaseConfig.GOODS_MIDDLETYPE)
    goodsItem:setPosition(self.data.bgSize.width * 0.15, self.data.bgSize.height * 0.5)
    self.controls.goodsNode:addChild(goodsItem)
end

function FundPanel:setBgOpacity(opacity)
    self.controls.bg:setOpacity(opacity)
end

function FundPanel:setReceiveStatus()
    self.data.isBuyStatus = false
    self.controls.btn_receive:setString("领取")
end

function FundPanel:setBuyStatus(activityConfig)
    self.controls.finish:setVisible(false)
    self.controls.btn_receive:setTouchEnable(true)
    self.controls.btn_receive:setVisible(true)
    self.controls.btn_receive:setString("购买")

    self.data.isBuyStatus = true

    self:updateDesc(activityConfig)
    self:updateGoodsInfo(activityConfig)
end

function FundPanel:buttonFunc()
    if self.data.isBuyStatus then
        application:dispatchCustomEvent(AppEvent.UI.Activity.BuyFund, {})
    else
        self:ReceiveAwards()
    end
end

--[[
    领取奖励
]]
function FundPanel:ReceiveAwards()
    rpc:call("Activity.ReciveGrowthFund", self.data.activityConfig.Level, function(event)
        if event.status == Exceptions.Nil then
            application:dispatchCustomEvent(AppEvent.UI.Activity.DrawAward, 
                                                {Value = self.data.activityConfig.Level, AwardsInfo = event.result})
        end
    end)
end

return FundPanel




