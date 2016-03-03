local SwallowTrumpInfo = class("SwallowTrumpInfo", require("tool.helper.GoodsInfoIcon"))

function SwallowTrumpInfo:ctor(equipInfo)
    SwallowTrumpInfo.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, BaseConfig.GOODS_MIDDLETYPE)
    self:setNum()
    self:ChooseSprite()
    self:setIsChoose(false)
end

function SwallowTrumpInfo:setIsChoose(visible)
    self.data.isChoose = visible
    self.controls.chooseBg:setVisible(visible)
    self.controls.chooseSpri:setVisible(visible)
end

function SwallowTrumpInfo:ChooseSprite()
	self.controls.chooseBg = cc.Sprite:create("image/ui/img/btn/btn_813.png")
	self.controls.chooseBg:setScale(0.88)
    self:addChild(self.controls.chooseBg)
    self.controls.chooseSpri = cc.Sprite:create("image/ui/img/btn/btn_502.png")
    self:addChild(self.controls.chooseSpri)
end

return SwallowTrumpInfo


