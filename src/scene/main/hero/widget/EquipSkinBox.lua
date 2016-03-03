local EquipSkinBox = class("EquipSkinBox", function()
    local self = cc.Node:create()
    self.controls = {}
    self.handlers = {}
    return self
end)

function EquipSkinBox:ctor(heroInfo, goodsInfo, isWear)
    self.heroInfo = heroInfo
    self.goodsInfo = goodsInfo

    self:createUI()

    self.controls.bg:setScaleY(0)
    self.controls.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.06, 1, 1.2), cc.ScaleTo:create(0.1, 1, 1)))

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            self:onExit()
        end
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.controls.bg)
end

function EquipSkinBox:onExit()
    self.controls.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 1, 1.2), cc.ScaleTo:create(0.05, 1, 0), 
        cc.CallFunc:create(function()
        self:removeFromParent()
        self = nil
    end)))
end

function EquipSkinBox:createUI()
    local bgSize = cc.size(380, 240)
    self.controls.bg = ccui.ImageView:create()
    self.controls.bg:setScale9Enabled(true)
    self.controls.bg:loadTexture("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(bgSize)
    self:addChild(self.controls.bg)

    local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, self.goodsInfo, BaseConfig.GOODS_SMALLTYPE)
    goodsItem:setPosition(bgSize.width * 0.15, bgSize.height - 60)
    goodsItem:setTouchEnable(false)
    self.controls.bg:addChild(goodsItem)

    local equipConfig = BaseConfig.GetEquip(self.goodsInfo.ID, self.goodsInfo.StarLevel)
    local starDta = Common.getHeroStarLevelColor(self.goodsInfo.StarLevel)
    local name = Common.finalFont(equipConfig.name, 1, 1, 22, starDta.Color, 1)
    name:setPosition(bgSize.width * 0.5, bgSize.height - 50)
    self.controls.bg:addChild(name)

    local skin = Common.finalFont("(时装)", 1, 1, 18, nil, 1)
    skin:setAnchorPoint(1, 0.5)
    skin:setPosition(bgSize.width * 0.92, bgSize.height - 40)
    self.controls.bg:addChild(skin)

    local time = Common.finalFont("时效:永久", 1, 1, 18, nil, 1)
    time:setPosition(bgSize.width * 0.5, bgSize.height - 80)
    self.controls.bg:addChild(time)

    local row1, desc1 = Common.StringLinefeed(equipConfig.desc, 16)
    local desc = Common.finalFont(desc1, 1, 1, 18, nil, 1)
    desc:setAnchorPoint(0, 1)
    desc:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.controls.bg:addChild(desc)
    desc:setPosition(bgSize.width * 0.08, bgSize.height - 105)

    local btn_skin = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 62))
    btn_skin:setCircleFont("装上", 1, 1, 25, cc.c3b(226, 204, 169))
    btn_skin:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    btn_skin:setPosition(bgSize.width * 0.5, 50)
    self.controls.bg:addChild(btn_skin)
    btn_skin:addTouchEventListener(function(sender, eventType, inside)
        if eventType == ccui.TouchEventType.ended and inside then
            local equipConfig = BaseConfig.GetEquip(self.goodsInfo.ID, self.goodsInfo.StarLevel)
            local skinType = equipConfig.type / 2
            local heroEquipTab = self.heroInfo.Equip
            local heroSkinInfo = self.heroInfo.SkinStatus[skinType]
            local skinListTab = self.heroInfo.SkinList

            if (0 ~= heroSkinInfo.ID) and (heroSkinInfo.ID == self.goodsInfo.ID) then
                application:showFlashNotice("不能穿戴相同的装备~")
                return
            end

            local p = {
                HeroID = self.heroInfo.ID,
                SkinID = self.goodsInfo.ID,
            }
            rpc:call("Hero.InstallSkin", p, function(event)
                if event.status == Exceptions.Nil then
                    -- 先把SkinStatus中当前的时装信息加入SkinList(如果SkinStatus中存有时装)，
                    -- 再将新时装信息存入SkinStatus中，再从SkinList中删除新时装信息，
                    -- 因为装上时装必定是已勾选显示，所以最后还要把Equip中对应的装备SkinID变为新时装的ID
                    if (0 ~= heroSkinInfo.ID) then
                        local currSkinInfo = {}
                        currSkinInfo.ID = heroSkinInfo.ID
                        currSkinInfo.StarLevel = heroSkinInfo.StarLevel
                        currSkinInfo.IsActive = true
                        table.insert(skinListTab, currSkinInfo)
                    end

                    heroSkinInfo.ID = self.goodsInfo.ID
                    heroSkinInfo.StarLevel = self.goodsInfo.StarLevel
                    heroSkinInfo.IsShow = true

                    for k,equipInfo in pairs(skinListTab) do
                        if equipInfo.ID == heroSkinInfo.ID then
                            table.remove(skinListTab, k)
                            break
                        end
                    end

                    heroEquipTab[equipConfig.type].SkinID = heroSkinInfo.ID

                    local skinData = {
                        EquipType = equipConfig.type,
                        SkinID = heroSkinInfo.ID
                    }
                    application:dispatchCustomEvent(AppEvent.UI.Hero.ChangeSkin, skinData)
                    application:dispatchCustomEvent(AppEvent.UI.Hero.UpdateWearSkin, {SkinType = skinType, SkinInfo = heroSkinInfo})
                    application:dispatchCustomEvent(AppEvent.UI.Hero.RefreshSkin, {EquipType = skinType})
                    CCLog("======heroInfo======", vardump(self.heroInfo))
                    self:onExit()
                end
            end)
        end
    end)
end

return EquipSkinBox

