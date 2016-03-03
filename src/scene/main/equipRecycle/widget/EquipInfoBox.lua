local EquipInfoBox = class("EquipInfoBox", require("tool.helper.CommonTips"))

function EquipInfoBox:ctor(equipInfo, node, callFunc)
    if equipInfo.Type == BaseConfig.GT_EQUIP then
        EquipInfoBox.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, node)
    elseif equipInfo.Type == BaseConfig.GT_PROPS then
        EquipInfoBox.super.ctor(self, BaseConfig.GOODS_FRAG, equipInfo, node)
    end

    self.data.callFunc = callFunc

    self:createUI()
end

function EquipInfoBox:createUI()
    self:updateGoods(self.data.goodsInfo, 80)

    local btn_intensify = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(150, 62))
    btn_intensify:setCircleFont("放入炼化炉", 1, 1, 25, cc.c3b(226, 204, 169))
    btn_intensify:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    btn_intensify:setPosition(self.data.size.width * 0.5, 60)
    self.controls.bg:addChild(btn_intensify)
    btn_intensify:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.data.callFunc then
                self.data.callFunc()
            end
            self:onExit()
        end
    end)
end

return EquipInfoBox

