local SoulGoodsInfo = class("SoulGoodsInfo", require("tool.helper.GoodsInfoIcon"))
local HeroTip = require("tool.helper.HeroTip")
local ColorLabel = require("tool.helper.ColorLabel")

function SoulGoodsInfo:ctor(heroInfo)
    SoulGoodsInfo.super.ctor(self, BaseConfig.GOODS_SOUL, heroInfo, BaseConfig.GOODS_MIDDLETYPE)

    self.controls.chooseBg = cc.Sprite:create("image/ui/img/btn/btn_813.png")
	self.controls.chooseBg:setScale(0.88)
    self:addChild(self.controls.chooseBg)
    self.controls.chooseBg:setVisible(false)
    self.controls.chooseSpri = cc.Sprite:create("image/ui/img/btn/btn_502.png")
    self:addChild(self.controls.chooseSpri)
    self.controls.chooseSpri:setVisible(false)

    self.data.isLongTouchEnable = true

    self:addTouchEventListener(function(sender, eventType, isIn)
    	if eventType == ccui.TouchEventType.began then
            self:onTouchBegan()
        end
        if eventType == ccui.TouchEventType.moved then
            self:onTouchMoved(isIn)
        end
        if eventType == ccui.TouchEventType.ended then
            self:onTouchEnded()
        end
    end)
end

function SoulGoodsInfo:setGoodsInfo(goodsInfo, goodsType)
    SoulGoodsInfo.super.setGoodsInfo(self, goodsInfo, goodsType)
    if self.controls.wxBG then
    	self.controls.wxBG:setVisible(false)
        self.controls.wx:setVisible(false)
    end
end

function SoulGoodsInfo:onTouchBegan()
	if self.data.isLongTouchEnable then
		self:stopAllActions()
	    self:runAction(cc.Sequence:create({
	        cc.DelayTime:create(0.5),
	        cc.CallFunc:create(function() 
	            cc.Director:getInstance():getRunningScene():removeChildByName("hero_tip")
	            self:showTips()
	        end),
	    }))
	end
end

function SoulGoodsInfo:onTouchMoved(isIn)
	if self.data.isLongTouchEnable and (not isIn) then
		self:stopAllActions()
        cc.Director:getInstance():getRunningScene():removeChildByName("hero_tip")
	end
end

function SoulGoodsInfo:onTouchEnded()
	if self.data.isLongTouchEnable then
		self:stopAllActions()
	    cc.Director:getInstance():getRunningScene():removeChildByName("hero_tip")

	    if self.data.showTouchEndFunc then
	    	self.data.showTouchEndFunc(self, self.data.goodsInfo)
	    end
	end
end

function SoulGoodsInfo:setLongTouchEnable(value)
	self.data.isLongTouchEnable = value
end

function SoulGoodsInfo:setIsChoose(visible)
    self.data.goodsInfo.IsResearch = visible
    self.controls.chooseBg:setVisible(visible)
    self.controls.chooseSpri:setVisible(visible)
end

function SoulGoodsInfo:setChooseStatus()
	if self.data.goodsInfo.ResearchSlot > 0 then
		self.controls.chooseBg:setVisible(true)
    	self.controls.chooseSpri:setVisible(true)
    else
    	self.controls.chooseBg:setVisible(false)
    	self.controls.chooseSpri:setVisible(false)
	end
end

function SoulGoodsInfo:setCancelButton()
	self.controls.btn_cancel = ccui.Button:create("image/ui/img/btn/btn_157.png")
	self.controls.btn_cancel:setPosition(self.data.size.width * 0.45, self.data.size.height * 0.45)
	self:addChild(self.controls.btn_cancel)
	self.controls.btn_cancel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.cancelResearchFunc then
            	self.data.cancelResearchFunc(self.data.slot, self.data.goodsInfo)
            end
        end
    end)
end

function SoulGoodsInfo:setCancelButtonVisible(visible)
	self.controls.btn_cancel:setVisible(visible)
end

function SoulGoodsInfo:setCollectNum()
	if not self.controls.collectNumLab then
		self.controls.collectNumLab = ColorLabel.new("", 22)
		self.controls.collectNumLab:setPosition(0, -self.data.size.height * 1)
	    self:addChild(self.controls.collectNumLab)

	    local move1 = cc.MoveBy:create(0.6, cc.p(0, 5))
        self.controls.collectNumLab:runAction(cc.RepeatForever:create(cc.Sequence:create({move1, move1:reverse()})))
	end
    self.controls.collectNumLab:setString("[255,255,255]预计产量:[=][151,255,74]"..self.data.goodsInfo.Num.."[=]")
end

-- 展示中星将的点击事件
function SoulGoodsInfo:addShowTouchEndEventListener(event)
	self.data.showTouchEndFunc = event
end

-- 研究中星将的取消事件
function SoulGoodsInfo:addCancelResearchEventListener(slot, event)
	self.data.slot = slot
	self.data.cancelResearchFunc = event
end

return SoulGoodsInfo

