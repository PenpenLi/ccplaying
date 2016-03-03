local AccumulatePanel = class("AccumulatePanel", require("scene.main.activity.widget.FundPanel"))

function AccumulatePanel:ctor()
    self:createUI()
end

function AccumulatePanel:createUI()
    AccumulatePanel.super.createUI(self)
    self.controls.bg:setTexture("image/ui/img/bg/bg_335.png")
    self.controls.btn_receive:setString("领取")
    self.controls.btn_receive:setPosition(self.data.bgSize.width * 0.85, self.data.bgSize.height * 0.4)
end

function AccumulatePanel:panelDesc()
    local bgSize = self.data.bgSize 

    self.controls.accumulateGold = Common.finalFont("", 1, 1, 20, cc.c3b(0, 255, 0), 1)
    self.controls.accumulateGold:setAnchorPoint(0, 0.5)
    self.controls.accumulateGold:setPosition(bgSize.width * 0.05, bgSize.height * 0.77)
    self.controls.bg:addChild(self.controls.accumulateGold)

    self.controls.purchaseGoldCount = Common.finalFont("", 1, 1, 20, cc.c3b(0, 255, 0), 1)
    self.controls.purchaseGoldCount:setPosition(bgSize.width * 0.85, bgSize.height * 0.8)
    self.controls.bg:addChild(self.controls.purchaseGoldCount)
end

function AccumulatePanel:updateDesc(activityConfig)
    self.controls.accumulateGold:setString("累计充值"..activityConfig.Gold.."元宝")
end

function AccumulatePanel:updateGoodsInfo(activityConfig)
    self.controls.goodsNode:removeAllChildren()

    for k,goodsInfo in pairs(activityConfig.Goods) do
        local distance = 65

        local awardInfo = {}
        awardInfo.ID = goodsInfo.GoodsID
        awardInfo.Type = goodsInfo.GoodsType
        awardInfo.Num = goodsInfo.Num

        local goodsItem = Common.getGoods(awardInfo, false, BaseConfig.GOODS_SMALLTYPE)
        goodsItem:setPosition(self.data.bgSize.width * 0.1 + (k - 1) * distance, self.data.bgSize.height * 0.35)
        self.controls.goodsNode:addChild(goodsItem)
    end
end

function AccumulatePanel:updatePurchaseCount(currCount, configCount)
    self.controls.purchaseGoldCount:setString(currCount.."/"..configCount)
    if currCount < configCount then
        self.data.isCanChange = false
    else
        self.data.isCanChange = true
    end
end

function AccumulatePanel:setBgOpacity(opacity)
    self.controls.bg:setOpacity(opacity)
end

function AccumulatePanel:buttonFunc()
    if self.data.isCanChange then
        self:ReceiveAwards()
    else
        application:showFlashNotice("条件未达到～")
    end
end

--[[
    领取奖励
]]
function AccumulatePanel:ReceiveAwards()
    rpc:call("Activity.AccPurchaseGift", self.data.activityConfig.Gold, function(event)
        if event.status == Exceptions.Nil then
            application:dispatchCustomEvent(AppEvent.UI.Activity.DrawAward, 
                                                {Value = self.data.activityConfig.Gold, AwardsInfo = event.result})
        end
    end)
end

return AccumulatePanel




