local TrumpGoodsInfo = class("TrumpGoodsInfo", require("tool.helper.GoodsInfoIcon"))

function TrumpGoodsInfo:ctor(type, equipInfo, size)
    TrumpGoodsInfo.super.ctor(self, type, equipInfo, size)

    
end

function TrumpGoodsInfo:setName(name)
    self.data.goodsInfo.Name = name or self.data.goodsConfigInfo.name
    if self.controls.name then
        self.controls.name:setString(self.data.goodsInfo.Name)
    else
        self.controls.name = Common.finalFont(self.data.goodsInfo.Name, 0, -self.data.size.height * 0.62, 20)
        self:addChild(self.controls.name)
    end
end

function TrumpGoodsInfo:showFragNum(num)
    self.data.goodsInfo.FragNum = num or self.data.goodsInfo.FragNum
    if self.controls.fragNum then
        self.controls.fragNum:setString(self.data.goodsInfo.FragNum)
    else
        self.controls.fragNum = Common.finalFont(self.data.goodsInfo.FragNum, self.data.size.width * 0.5, -self.data.size.height * 0.5, 25, nil, 1)
        self.controls.fragNum:setAnchorPoint(1, 0)
        self:addChild(self.controls.fragNum)
    end
    if 0 == self.data.goodsInfo.FragNum then
        self.controls.fragNum:setColor(cc.c3b(255, 0, 0))
    else
        self.controls.fragNum:setColor(cc.c3b(255, 255, 255))
    end
end

function TrumpGoodsInfo:setNum()
    local ownGoodsInfo = GameCache.GetEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
    if nil == self.controls.num then
        self.controls.num = Common.finalFont("", self.data.size.width * 0.5, -self.data.size.height * 0.48, 20, nil, 1)
        self.controls.num:setAnchorPoint(1, 0)
        self:addChild(self.controls.num)
    end

    if ownGoodsInfo then
        self.controls.num:setString(ownGoodsInfo.Num)
    else
        self.controls.num:setString("0")
    end
end

function TrumpGoodsInfo:setPropsNum()
   TrumpGoodsInfo.super.setNum(self)
end

function TrumpGoodsInfo:setString(text)
    -- self.controls.name:setString(text)
end

function TrumpGoodsInfo:getName()
    return self.data.goodsConfigInfo.name
end

function TrumpGoodsInfo:getBG()
    return self.controls.starLevel
end

function TrumpGoodsInfo:getGoodsID()
    return self.data.goodsInfo.ID
end

function TrumpGoodsInfo:getGoodsNum()
    return self.data.goodsInfo.FragNum
end

function TrumpGoodsInfo:getPropsNum()
    return self.data.goodsInfo.Num
end

function TrumpGoodsInfo:isMoreEnergyStep()
    local currID = (GameCache.Avatar.EnergyStep - 1) * 6 + GameCache.Avatar.EnergyAttrNum
    if currID >= self.data.goodsInfo.EnergyID then
        if currID == self.data.goodsInfo.EnergyID then
            if GameCache.Avatar.EnergyAttrNum == 0 then
                return true
            else
                return false
            end
        end
        return true
    end

    return false
end

function TrumpGoodsInfo:setState()
    if (self:isMoreEnergyStep()) then
        self:setNum()
    else
        self.controls.head:setState(1)
        self.controls.starLevel:setState(1)
    end
end

return TrumpGoodsInfo
