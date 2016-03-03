local EquipInfo = class("EquipInfo", require("tool.helper.GoodsInfoIcon"))

function EquipInfo:ctor(equipInfo, heroInfo, size, getHeroInfoFunc, isCompare)
    if getHeroInfoFunc then
        self.data.getHeroInfoFunc = getHeroInfoFunc
    end
    self.data.isCompare = isCompare
    EquipInfo.super.ctor(self, BaseConfig.GOODS_EQUIP, equipInfo, size)

    if self.data.isCompare then
        self.controls.up = cc.Sprite:create("image/ui/img/btn/btn_277.png")
        self.controls.up:setPosition(-self.data.size.width * 0.3, self.data.size.height * 0.3)
        self:addChild(self.controls.up)
    end

    self.controls.masking = cc.Sprite:create("image/ui/img/btn/btn_813.png")
    self.controls.masking:setScale(0.88)
    self:addChild(self.controls.masking)
    self.controls.masking:setVisible(false)

    self.controls.canCompound = Common.finalFont("可合成", 1, 1, 18, cc.c3b(0, 255, 0), 1)
    self.controls.canCompound:setAdditionalKerning(-2)
    self.controls.canCompound:setAnchorPoint(0, 0)
    self.controls.canCompound:setPosition(-self.data.size.width * 0.45, -self.data.size.height * 0.45)
    self:addChild(self.controls.canCompound, 1)
    self.controls.canCompound:setVisible(false)

    self:setGoodsInfo(equipInfo, heroInfo)
    self:setNum()

end

function EquipInfo:setSpecialEffect(visible)
    self.data.isSpecialEquip = visible

    if self.controls.specialEffect then
        self.controls.specialEffect:removeFromParent()
        self.controls.specialEffect = nil
    end
    if visible then
        self.controls.specialEffect = sp.SkeletonAnimation:create("image/spine/ui_effect/32/skeleton.skel", "image/spine/ui_effect/32/skeleton.atlas")
        self.controls.specialEffect:setAnimation(0, "animation", true)
        self:addChild(self.controls.specialEffect)
        self.controls.specialEffect:setScale((2 - self.data.sizeType)  * 0.1 + 0.7)  
    end
end

function EquipInfo:setGoodsInfo(equipInfo, heroInfo)
    EquipInfo.super.setGoodsInfo(self, equipInfo)

    if heroInfo then
        self.data.heroInfo = heroInfo
    else
        if self.data.getHeroInfoFunc then
            self.data.heroInfo = self.data.getHeroInfoFunc()
        end
    end

    local isSpecial = self:isSpecial(self.data.heroInfo.ID)
    self:setSpecialEffect(isSpecial)

    if self.data.isCompare then
        self.controls.up:setScale(0)
        local isHigh = self:isHighHeroEquip(equipInfo, self.data.heroInfo)
        if isHigh then
            self.controls.up:setScale(1)
        end
    end
end

function EquipInfo:isSpecial(heroID)
    local equipConfig = self.data.goodsConfigInfo
    if 0 ~= (#equipConfig.heroList) then
        for k1,v1 in pairs(equipConfig.heroList) do
            if v1 == heroID then
                return true
            end
        end
        return false
    end
end

function EquipInfo:isHighHeroEquip(equipInfo, heroInfo)
    local function getEquipFtpValue(config, level)
        if config.type == 1 then
            return config.atk + math.floor(((level - 1) * config.atkGrow)/10000)
        elseif config.type == 2 then
            return config.def + math.floor(((level - 1) * config.defGrow)/10000)
        elseif config.type == 3 then
            return config.mp + math.floor(((level - 1) * config.mpGrow)/10000)
        elseif config.type == 4 then
            return config.hp + math.floor(((level - 1) * config.hpGrow)/10000)
        else
            return config.talent
        end
    end
    local currEquipConfig = self.data.goodsConfigInfo
    local currHeroEquipInfo = heroInfo.Equip[currEquipConfig.type]

    if currHeroEquipInfo.ID ~= 0 then
        local currHeroEquipConfig = BaseConfig.GetEquip(currHeroEquipInfo.ID, currHeroEquipInfo.StarLevel)
        local currHeroEquipValue = getEquipFtpValue(currHeroEquipConfig, currHeroEquipInfo.Level)
        local currEquipValue = getEquipFtpValue(currEquipConfig, currHeroEquipInfo.Level)
        if currEquipValue > currHeroEquipValue then
            return true
        end
    else
        return true
    end
    
    return false
end

function EquipInfo:setNum(num)
    EquipInfo.super.setNum(self, num)
    if 0 == self.data.goodsInfo.Num then
        self.controls.canCompound:setVisible(self:isFragCompound(self.data.goodsInfo.ID))
        self:setState(1)
        if self.controls.specialEffect then
            self.controls.specialEffect:setVisible(false)
        end
    else
        self.controls.canCompound:setVisible(false)
        self:setState(0)
    end
end

function EquipInfo:setState(state)
    for k,child in pairs(self:getChildren()) do
        if child.setState then
            child:setState(state)
        end
    end
    if 1 == state then
        self.controls.masking:setVisible(true)
    else
        self.controls.masking:setVisible(false)
    end
end

function EquipInfo:isFragCompound(id)
    local propsInfo = GameCache.GetFrag(id)
    if propsInfo then
        local compoundId = BaseConfig.GetProps(id).useValue
        local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
        local compoundNum = fragToEquipConfig.num

        if propsInfo.Num >= compoundNum then
            return true
        else
            return false
        end
    else
        return false
    end
end

return EquipInfo


