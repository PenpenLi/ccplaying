local GoodsView = class("GoodsView", require("tool.helper.CommonView"))

local EQUIP_VIEW, FRAG_VIEW, PROP_VIEW = 1, 2, 3

function GoodsView:ctor(currView, ccSize, posX, posY, func)
    self.currView = currView
    local goodsTabs, goodsType = self:getGoodsInfoTabs()
    self.goodsType = goodsType

    GoodsView.super.ctor(self, ccSize, posX, posY, goodsTabs, 5, 110, 108, function(GoodsInfo)
        local goodsItem = GoodsInfoNode.new(self.goodsType, GoodsInfo)
        goodsItem:setFragAlert()
        goodsItem:setNum()
        return goodsItem
    end, func, true, 1) 

end

function GoodsView:getGoodsInfoTabs()
    local goodsTabs = {}
    local goodsType = nil 

    if self.currView == EQUIP_VIEW then
        local equipTabs = GameCache.GetAllEquip()
        for k,v in pairs(equipTabs) do
            table.insert(goodsTabs, v)
        end
        table.sort(goodsTabs, Common.equipSort)
        goodsType =  BaseConfig.GOODS_EQUIP
    elseif self.currView == FRAG_VIEW then
        local fragTabs = GameCache.GetAllFrag()
        for k,v in pairs(fragTabs) do
            table.insert(goodsTabs, v)
        end
        table.sort(goodsTabs, handler(self, self.fragSort))
        goodsType =  BaseConfig.GOODS_FRAG
    elseif self.currView == PROP_VIEW then
        local propsTabs = GameCache.GetAllProps()
        for k,v in pairs(propsTabs) do
            table.insert(goodsTabs, v)
        end
        table.sort(goodsTabs, Common.propsSort)
        goodsTabs = self:propSort(goodsTabs)
        goodsType =  BaseConfig.GOODS_PROPS
    end

    return goodsTabs, goodsType
end

function GoodsView:updateView()
    local goodsTabs = self:getGoodsInfoTabs()
    GoodsView.super.updateView(self, goodsTabs)
end

function GoodsView:fragSort(a, b)
    local aConfig = BaseConfig.GetProps(a.ID)
    local bConfig = BaseConfig.GetProps(b.ID)

    local aCompoundId = BaseConfig.GetProps(a.ID).useValue
    local aFragToEquipConfig = BaseConfig.GetFragToEquip(aCompoundId)
    local aCompoundNum = aFragToEquipConfig.num
    local aValue = a.Num / aCompoundNum

    local bCompoundId = BaseConfig.GetProps(b.ID).useValue
    local bFragToEquipConfig = BaseConfig.GetFragToEquip(bCompoundId)
    local bCompoundNum = bFragToEquipConfig.num
    local bValue = b.Num / bCompoundNum

    if aValue == bValue then
        if aConfig.type == bConfig.type then
            if aConfig.quality == bConfig.quality then
                return a.ID < b.ID
            else
                return aConfig.quality < bConfig.quality
            end
        else
            return aConfig.type < bConfig.type
        end
    else
        return aValue > bValue
    end
    
end

function GoodsView:propSort(goodsTabs)
    local type11Tabs = {}
    local type12Tabs = {}
    local elseTabs = {}
    local tempTabs = {}
    for k,v in pairs(goodsTabs) do
        local config = BaseConfig.GetProps(v.ID, v.StarLevel)
        if config.type == 11 then
            table.insert(type11Tabs, v)
        elseif config.type == 12 then
            table.insert(type12Tabs, v)
        else
            table.insert(elseTabs, v)
        end
    end
    for k,v in pairs(type11Tabs) do
        table.insert(tempTabs, v)
    end
    for k,v in pairs(type12Tabs) do
        table.insert(tempTabs, v)
    end
    for k,v in pairs(elseTabs) do
        table.insert(tempTabs, v)
    end
    return tempTabs
end

return GoodsView

