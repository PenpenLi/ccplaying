local TabView = class("TabView", require("tool.helper.CommonView"))

--[[
    isEquipMent -- 显示装备或者宝物
    isShowRecycleUI -- 显示炼化或者剥离
]]
function TabView:ctor(ccSize, posX, posY,  isEquipMent, isShowRecycleUI)
    self.isEquipMent = isEquipMent
    self.isShowRecycleUI = isShowRecycleUI
    self.itemTab = {}
    self.isLevelSort = true

    if self.isShowRecycleUI then
        self:equipDivide()
        TabView.super.ctor(self, ccSize, posX, posY, self.data.infoTab, 3, 110, 110, handler(self, self.createItem), handler(self, self.itemTouchEvent), false, 1)
    else
        self:heroDivide()
        TabView.super.ctor(self, ccSize, posX, posY, self.data.infoTab, 2, 160, 130, handler(self, self.createHeroItem), handler(self, self.heroTouchEvent), false, 1)
    end

end

-------------------炼化-------------------------
function TabView:equipDivide()
    self.data.infoTab = {}
    if self.isEquipMent then
        self.data.infoTab = GameCache.GetEquipment()
    else
        local fragTabs = GameCache.GetAllFrag()
        for k,v in pairs(fragTabs) do
            table.insert(self.data.infoTab, v)
        end
    end
    table.sort(self.data.infoTab, handler(self, self.equipSort))
end

function TabView:createItem(equipInfo)
    local item = require("scene.main.equipRecycle.widget.EquipGoodsInfo").new(equipInfo)
    item:setChooseBorderVisible(false)
    item:setNum(equipInfo.Num)
    return item
end

function TabView:itemTouchEvent(equipItem)
    local equipInfo = equipItem.data.goodsInfo
    local function recycleAction()
        local recycleLayer = self:getParent():getParent():getParent()
        -- 将item的坐标转换为以recycleLayer.controls.stoveBG为父节点的坐标
        local wordPos = equipItem:convertToWorldSpace(cc.p(0, 0))
        local pos = recycleLayer.controls.recycleStoveBG:convertToNodeSpace(wordPos)
        local isMove = recycleLayer:fromListMoveToStove(equipInfo, pos)
        if isMove then
            equipInfo.Num = equipInfo.Num - 1
            equipItem:setNum(equipInfo.Num)
            if equipInfo.Num < 1 then
                self:removeItem(equipInfo)
            end
        end
    end

    local function recycleTipsAction()
        local boxShow = require("scene.main.equipRecycle.widget.EquipInfoBox").new(equipInfo, self, recycleAction)
        boxShow.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        local runningScene = cc.Director:getInstance():getRunningScene()
        runningScene:addChild(boxShow)
    end

    application:dispatchCustomEvent(AppEvent.UI.Recycle.isShowTips, {NotShowFunc = recycleAction, ShowFunc = recycleTipsAction})
end

function TabView:removeItem(equipInfo)
    for k1,v1 in pairs(self.data.infoTab) do
        if (v1.ID == equipInfo.ID) and (v1.StarLevel == equipInfo.StarLevel) then
            table.remove(self.data.infoTab, k1) 
            break
        end
    end
    if equipInfo.Type == BaseConfig.GT_EQUIP then
        GameCache.minusEquip(equipInfo.ID, equipInfo.StarLevel, 0)
    elseif equipInfo.Type == BaseConfig.GT_PROPS then
        GameCache.minusFrag(equipInfo.ID, 0)
    end
    self:updateView(self.data.infoTab)
end

function TabView:addItem(equipInfo)
    local isHaveItem = false

    for k,v in pairs(self.data.infoTab) do
        if (v.ID == equipInfo.ID) and (v.StarLevel == equipInfo.StarLevel) then
            isHaveItem = true
            v.Num = v.Num + 1
            break
        end
    end

    if not isHaveItem then
        if equipInfo.Type == BaseConfig.GT_EQUIP then
            GameCache.addEquip(equipInfo.ID, equipInfo.StarLevel, 1)
        elseif equipInfo.Type == BaseConfig.GT_PROPS then
            GameCache.addProps(equipInfo, false, 1)
        end
        self:equipDivide()
    end
    
    self:updateView(self.data.infoTab)
end

function TabView:equipSort(a, b)
    local a_fragToEquipConfig = BaseConfig.GetFragToEquip(a.ID)
    local a_equipStarLevel = a_fragToEquipConfig.starLevel

    local b_fragToEquipConfig = BaseConfig.GetFragToEquip(b.ID)
    local b_equipStarLevel = b_fragToEquipConfig.starLevel

    local a_config = BaseConfig.GetEquip(a.ID, a_equipStarLevel)
    local b_config = BaseConfig.GetEquip(b.ID, b_equipStarLevel)
    if a_equipStarLevel == b_equipStarLevel then
        if a_config.talent == b_config.talent then
            return a.ID < b.ID
        else
            return a_config.talent < b_config.talent
        end
    else
        return a_equipStarLevel < b_equipStarLevel
    end
end

-------------------剥离-------------------------
function TabView:heroDivide()
    self.data.infoTab = {}

    local allHero = GameCache.GetAllHero()
    for k,v in pairs(allHero) do
        local isHaveEquip = false
        for i=1,4 do
            local equipInfo = v.Equip[i]
            if equipInfo.ID ~= 0 then
                isHaveEquip = true
                break
            end
        end

        if isHaveEquip then
            table.insert(self.data.infoTab, v)
        end
    end
    table.sort(self.data.infoTab, handler(self, self.heroStarLevelSort))
end

function TabView:createHeroItem(heroInfo)
    local heroItem = GoodsInfoNode.new(BaseConfig.GOODS_HERO, heroInfo)
    heroItem:setLevel("center")
    heroItem:setWx()
    return heroItem
end

function TabView:heroTouchEvent(heroItem)
    heroItem:setChooseBorderVisible(true)
    local recycleLayer = self:getParent():getParent():getParent()
    recycleLayer:updateHeroEquipInfo(heroItem.data.goodsInfo)
end

function TabView:updateHeroList(equipInfo)
    for k,v in pairs(self.data.infoTab) do
        if (v.ID == equipInfo.ID) and (v.StarLevel == equipInfo.StarLevel) then
            table.remove(self.data.infoTab, k)
            break
        end
    end
    self:updateView(self.data.infoTab)
end

function TabView:setHeroLevelSort()
    table.sort(self.data.infoTab, handler(self, self.heroLevelSort))
    self:updateView(self.data.infoTab)
end

function TabView:setHeroStarLevelSort()
    table.sort(self.data.infoTab, handler(self, self.heroStarLevelSort))
    self:updateView(self.data.infoTab)
end

function TabView:resetUpdate()
    self:equipDivide()
    self:updateView(self.data.infoTab)
end

function TabView:heroLevelSort(a, b)
    if a.Level == b.Level then
        if a.StarLevel == b.StarLevel then
            local aConfig = BaseConfig.GetHero(a.ID, a.StarLevel)
            local bConfig = BaseConfig.GetHero(b.ID, b.StarLevel)
            if aConfig.talent == bConfig.talent then
                return aConfig.wx < aConfig.wx
            else
                return aConfig.talent > bConfig.talent
            end
        else
            return a.StarLevel > b.StarLevel
        end
    else
        return a.Level > b.Level
    end
end

function TabView:heroStarLevelSort(a, b)
    if a.StarLevel == b.StarLevel then
        if a.Level == b.Level then
            local aConfig = BaseConfig.GetHero(a.ID, a.StarLevel)
            local bConfig = BaseConfig.GetHero(b.ID, b.StarLevel)
            if aConfig.talent == bConfig.talent then
                return aConfig.wx < aConfig.wx
            else
                return aConfig.talent > bConfig.talent
            end
        else
            return a.Level > b.Level
        end
    else
        return a.StarLevel > b.StarLevel
    end
end

return TabView

