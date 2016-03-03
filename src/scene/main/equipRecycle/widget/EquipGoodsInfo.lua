local EquipGoodsInfo = class("EquipGoodsInfo", require("tool.helper.GoodsInfoIcon"))

function EquipGoodsInfo:ctor(equipInfo, sizeType)
    if equipInfo.Type then
        if equipInfo.Type == BaseConfig.GT_EQUIP then
            EquipGoodsInfo.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, sizeType)
        elseif equipInfo.Type == BaseConfig.GT_PROPS then
            EquipGoodsInfo.super.ctor(self, BaseConfig.GOODS_FRAG, equipInfo, sizeType)
        end
    else
        EquipGoodsInfo.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, sizeType)
    end
    self.isEquipChoose = false
end

function EquipGoodsInfo:setEquipChooseVisible(visible)
    self.isEquipChoose = visible
    if nil == self.ChooseSpri then
        self.ChooseSpri = cc.Sprite:create("image/ui/img/btn/btn_502.png")
        self:addChild(self.ChooseSpri)
    end
    self.ChooseSpri:setVisible(self.isEquipChoose)
end

function EquipGoodsInfo:setName(name)
    if self.controls.name then
        self.controls.name:setString(name)
    else
        self.controls.name = Common.finalFont(name, 0, -self.data.size.height * 0.52, 25, cc.c3b(255, 126, 56))
        self.controls.name:setAnchorPoint(0.5, 1)
        self:addChild(self.controls.name)
    end
end

function EquipGoodsInfo:setCloseBtn()
    self.controls.closeBtn = ccui.Button:create("image/ui/img/btn/btn_157.png")
    local size = self.data.size
    self.controls.closeBtn:setPosition(size.width * 0.45, -size.height * 0.45)
    self:addChild(self.controls.closeBtn)
    self.controls.closeBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:setHideCloseBtn()
            local scale = cc.ScaleBy:create(0.2, 0)
            local rotate = cc.RotateBy:create(0.2 , 360)

            self:runAction(cc.Sequence:create(cc.Spawn:create(scale, rotate), cc.CallFunc:create(function()
                local equipInfo = {}
                equipInfo.Type = self.data.goodsInfo.Type
                equipInfo.ID = self.data.goodsInfo.ID
                equipInfo.StarLevel = self.data.goodsInfo.StarLevel
                equipInfo.Num = 1

                self.func(self:getTag(), equipInfo)
                self:removeFromParent()
                self = nil
            end)))
        end
    end)
end

function EquipGoodsInfo:setHideCloseBtn()
    self.controls.closeBtn:runAction(cc.Sequence:create(cc.Hide:create()))
end

function EquipGoodsInfo:setFadeAction()
    self:setOpacity(0)
    local action1 = cc.FadeIn:create(1)
    local action1Back = action1:reverse()
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action1Back)))
end

function EquipGoodsInfo:AutoMoveToStoveAction()
    local posX, posY = self:getPosition()
    local actionHeight = 80
    self:setPosition(posX, posY + actionHeight)

    self.controls.head:setOpacity(0)
    self.controls.starLevel:setOpacity(0)
    if self.controls.headBG then
        self.controls.headBG:setOpacity(0)
    end

    local actionTime = 0.2
    local fadeIn = cc.FadeIn:create(actionTime)
    local move = cc.MoveBy:create(actionTime, cc.p(0, -actionHeight))
    self.controls.head:runAction(cc.Spawn:create(fadeIn, move))
    self.controls.starLevel:runAction(cc.Spawn:create(fadeIn:clone(), move:clone())) 

    local delay = cc.DelayTime:create(actionTime)
    self:runAction(cc.Sequence:create(delay,cc.CallFunc:create(function()
        self:setPosition(posX, posY)
        self.controls.head:setPosition(0, 0)
        self.controls.starLevel:setPosition(0, 0)
        self:setCloseBtn()
    end))) 

end

function EquipGoodsInfo:stopFadeAction()
    self:stopAllActions()
end

function EquipGoodsInfo:addRemoveEvent(event)
    self.func = event
end

return EquipGoodsInfo


