local EquipView = class("EquipView", require("tool.helper.CommonView"))
local EquipInfo = require("scene.main.hero.widget.EquipInfo")
local EquipSkinInfo = require("scene.main.hero.widget.EquipSkinInfo")
local effects = require("tool.helper.Effects")

--[[
    isEquipment -- 是否显示装备
        true -- 显示装备，false -- 显示法宝
]]
function EquipView:ctor(heroInfo, isEquipment, ccSize, isSkin)
    self.heroInfo = heroInfo
    self.isEquipment = isEquipment
    self.ccSize = ccSize
    self.isSkin = isSkin

    self.infoTab = self:getFiltrateGoodsTab(self.heroInfo)
    EquipView.super.ctor(self, ccSize, 0, 10, self.infoTab, 4, 95, 96, handler(self, self.getGoodsItem), handler(self, self.touchEvent), false, 2) 
end

function EquipView:getGoodsItem(goodsInfo)
    local goodsItem = nil
    if self.isSkin then
        goodsItem = EquipSkinInfo.new(goodsInfo, self.heroInfo, BaseConfig.GOODS_MIDDLETYPE)
    else
        goodsItem = EquipInfo.new(goodsInfo, self.heroInfo, BaseConfig.GOODS_MIDDLETYPE, handler(self, self.getHeroInfo), true)
    end
    return goodsItem
end

function EquipView:touchEvent(goodsItem)
    Common.CloseGuideLayer({7})
    local goodsInfo = goodsItem:getGoodsInfo()
    local boxShow = nil
    if self.isSkin then
        if not goodsInfo.IsActive then
            goodsItem:activeNotice()
            return
        end
        boxShow = require("scene.main.hero.widget.EquipSkinBox").new(self.heroInfo, goodsInfo)
    else
        boxShow = require("scene.main.hero.widget.EquipInfoBox").new(self.heroInfo, goodsInfo, false, goodsItem)
    end
    boxShow.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    application:dispatchCustomEvent(AppEvent.UI.Hero.AddChildNode, {Child = boxShow})
    Common.OpenGuideLayer({7})
end

function EquipView:updateView(equipTypeID, heroInfo)
    if equipTypeID then
        self.typeID = equipTypeID
    else
        if self.isSkin then
            self.typeID = BaseConfig.ET_ARM
        else
            if self.isEquipment then
                self.typeID = BaseConfig.ET_ARM
            else
                self.typeID = BaseConfig.ET_MAGIC
            end
        end
    end

    self.heroInfo = heroInfo or self.heroInfo
    self.infoTab = self:getFiltrateGoodsTab(self.heroInfo)
    local infoTab = self:chooseEquipSort(self.typeID)
    EquipView.super.updateView(self, infoTab)
end

function EquipView:getHeroInfo()
    return self.heroInfo
end

function EquipView:getFiltrateGoodsTab(heroInfo)
    local infoTab = {}

    if not self.isSkin then
        if self.isEquipment then
            local equipTab = GameCache.GetEquipment()
            for k,v in pairs(equipTab) do
                local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
                local herolist = equipConfigInfo.heroList
                for k1,v1 in pairs(herolist) do
                    local heroConfigInfo = BaseConfig.GetHero(heroInfo.ID, heroInfo.StarLevel)
                    if heroInfo.ID == v1 then
                        if equipConfigInfo.type == BaseConfig.ET_ARM then
                            if (heroConfigInfo.armType == equipConfigInfo.subType) then
                                table.insert(infoTab, v)
                            end
                        else
                            table.insert(infoTab, v)
                        end
                    end
                end
                if #herolist == 0 then
                    if equipConfigInfo.type == BaseConfig.ET_ARM then
                        local heroConfigInfo = BaseConfig.GetHero(heroInfo.ID, heroInfo.StarLevel)
                        if heroConfigInfo.armType == equipConfigInfo.subType then
                            table.insert(infoTab, v)
                        end
                    else
                        table.insert(infoTab, v)
                    end
                end
            end
        else
            local trumpTab = GameCache.GetTrump()
            for k,v in pairs(trumpTab) do
                local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
                local herolist = equipConfigInfo.heroList
                for k1,v1 in pairs(herolist) do
                    if heroInfo.ID == v1 then
                        table.insert(infoTab, v)
                    end
                end
                if #herolist == 0 then
                    table.insert(infoTab, v)
                end
            end
        end
        table.sort(infoTab, Common.equipSort)
    else
        local skinTabs = heroInfo.SkinList or {}
        infoTab = skinTabs
        table.sort(infoTab, Common.skinSort)
    end
    return infoTab
end

function EquipView:chooseEquipSort(typeID)
    local tempTab = {}

    local appointTab = {} -- 指定id的装备
    local remainTab = {} -- 除指定id的装备之外

    if not self.isSkin then
        for k,v in pairs(self.infoTab) do
            local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
            if equipConfigInfo.type == typeID then
                table.insert(appointTab, v)
            else
                table.insert(remainTab, v)
            end
        end
    else
        for k,v in pairs(self.infoTab) do
            local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
            if equipConfigInfo.type == (typeID * 2) then
                table.insert(appointTab, v)
            else
                table.insert(remainTab, v)
            end
        end
    end
    
    for k,v in pairs(appointTab) do
        table.insert(tempTab, v)
    end
    for k,v in pairs(remainTab) do
        table.insert(tempTab, v)
    end

    return tempTab
end

return EquipView

