local HeroView = class("HeroView", require("tool.helper.CommonView"))

function HeroView:ctor(slotID, ccSize, chooseFunc, heroTab)
    self.slotID = slotID
    self.chooseFunc = chooseFunc
    self.canCureHeroTab = heroTab
    self.heroTab = {}
    self.handlers = {}

    self.bg = ccui.ImageView:create()
    self.bg:setScale9Enabled(true)
    self.bg:loadTexture("image/ui/img/bg/bg_139.png")
    self.bg:setContentSize(ccSize)
    self.bg:setPosition(ccSize.width * 0.5, ccSize.height * 0.5)
    self:addChild(self.bg)

    local desc = createMixSprite("image/ui/img/btn/btn_608.png", nil, "image/ui/img/btn/btn_1162.png")
    desc:setPosition(ccSize.width * 0.5, ccSize.height * 0.98)
    self.bg:addChild(desc)

    -- Common.finalFont("请选择一个受伤星将", ccSize.width * 0.5, ccSize.height * 0.98, 25)
    -- self.bg:addChild(desc)

    for k,v in pairs(self.canCureHeroTab) do
        local heroValue = GameCache.GetHero(v.ID)
        if heroValue then
            table.insert(self.heroTab, heroValue)
        end
    end

    HeroView.super.ctor(self, cc.size(ccSize.width - 20, ccSize.height - 80), 20, 30, self.heroTab, 7, 120, 120, handler(self, self.getGoodsItem), handler(self, self.touchEvent), false, 1) 

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            self:removeFromParent()
            self = nil
        end
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.bg)
end

function HeroView:getGoodsItem(goodsInfo)
    local hero = require("scene.main.tower.widget.HeroGoodsInfo").new(goodsInfo)
    local currBlood = nil
    local allBlood = nil
    for k,v in pairs(self.canCureHeroTab) do
        if v.ID == goodsInfo.ID then
            currBlood = v.RemainHP
        end
    end
    for k,v in pairs(self.heroTab) do
        if v.ID == goodsInfo.ID then
            allBlood = v.HP
        end
    end
    hero:setBlood(currBlood, allBlood)
    return hero
end

function HeroView:touchEvent(goodsItem)
    self:ClickHero(self.slotID, goodsItem)
end

--[[
    选中治疗的星将
]]
function HeroView:ClickHero(slotID, goodsItem)
    local heroInfo = goodsItem:getGoodsInfo()
    rpc:call("Tower.PutHeroInClinic", {ID = slotID, HeroID = heroInfo.ID}, function(event)
        if event.status == Exceptions.Nil then
            self.chooseFunc(self.slotID, heroInfo, goodsItem.data.currBlood, goodsItem.data.allBlood)
            self:removeFromParent()
            self = nil
        end
    end)
end

return HeroView
