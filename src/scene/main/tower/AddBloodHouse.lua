local AddBloodHouse = class("AddBloodHouse", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")

function AddBloodHouse:ctor(clinic, heroList, clickSlotFunc)
    self.data.clinic = clinic
    self.data.heroList = heroList
    self.data.canCureHeroList = self:getCanCureHeroList()

    self.data.clickSlotFunc = clickSlotFunc

    self.controls.bloodHouseTab = {}

    self:createUI()
end

function AddBloodHouse:isHeroInClinic(heroID)
    for _, slot in ipairs(self.data.clinic) do
        if slot.HeroID == heroID then
            return true
        end
    end
    return false
end

function AddBloodHouse:getCanCureHeroList()
    local result = {}
    -- dump(self.data.heroList)
    for i, v in ipairs(self.data.heroList) do
        local heroInfo = GameCache.GetHero(v.ID)
        local isInClinic = self:isHeroInClinic(v.ID)
        -- CCLog("------------HP: ", heroInfo.HP, ", ", v.RemainHP)
        
        -- if v.RemainHP < heroInfo.HP and v.RemainHP > 0 and isInClinic == false then
        if v.RemainHP < v.FullHP and v.RemainHP > 0 and isInClinic == false then
            -- CCLog("isInClinic: ", v.ID, isInClinic)
            table.insert(result, v)
        end
    end
    -- dump(result)
    return result
end

function AddBloodHouse:getHurtHero(heroID)
    for _, v in ipairs(self.data.heroList) do
        if v.ID == heroID then
            return v
        end
    end
    return nil
end

function AddBloodHouse:createUI()
    local shieldLayer = Common.createClickLayer(10, 10, 0, 0)
    self:addChild(shieldLayer)

    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 200), SCREEN_WIDTH, SCREEN_HEIGHT)
    layerColor:setPosition(SCREEN_WIDTH/2 - layerColor:getContentSize().width / 2, 
                            SCREEN_HEIGHT/2 - layerColor:getContentSize().height / 2)
    self:addChild(layerColor)

    local ccSize = cc.size(872, 458)
    self.bg = ccui.ImageView:create()
    self.bg:setScale9Enabled(true)
    self.bg:loadTexture("image/ui/img/bg/bg_139.png")
    self.bg:setSize(ccSize)
    self.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.bg)

    local bgbg = cc.Sprite:create("image/ui/img/bg/bg_286.png")
    bgbg:setPosition(ccSize.width * 0.5, ccSize.height * 0.5)
    self.bg:addChild(bgbg)

    local title = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_923.png")
    title:setTouchEnable(false)
    title:setChildPos(0.54, 0.5)
    title:setPosition(ccSize.width * 0.5, ccSize.height * 0.97)
    self.bg:addChild(title)
    local add = cc.Sprite:create("image/ui/img/btn/btn_919.png")
    add:setPosition(-50, 0)
    title:addChild(add)

    local logo = cc.Sprite:create("image/ui/img/btn/btn_924.png")
    logo:setPosition(ccSize.width * 0.18, ccSize.height * 0.63)
    self.bg:addChild(logo)

    local descBg = cc.Sprite:create("image/ui/img/bg/bg_285.png")
    descBg:setPosition(ccSize.width * 0.19, ccSize.height * 0.14)
    self.bg:addChild(descBg)
    local descString = "[42,63,102]队伍每过关一次,医务室内的星将就自动回复[=][255,84,0]25%[=][42,63,102]的血量[=]"
    local desc = ColorLabel.new(descString, 20, 13, true)
    desc:setPosition(ccSize.width * 0.19, ccSize.height * 0.14)
    self.bg:addChild(desc)

    local eventDispatcher = self:getEventDispatcher()
    for i=1,4 do
        local bg = cc.Sprite:create("image/ui/img/bg/bg_284.png")
        bg:setTag(i)
        local posX, posY = ((i - 1) % 2) * 260 + ccSize.width * 0.53, ccSize.height * 0.68 - (math.floor((i - 1) / 2)) * 190
        bg:setPosition(posX, posY)
        self.bg:addChild(bg)

        if i == 4 then
            local vipbg = cc.Sprite:create("image/ui/img/btn/btn_1138.png")
            vipbg:setPosition(posX + 60, posY + 80)
            self.bg:addChild(vipbg)
        end
        table.insert(self.controls.bloodHouseTab, bg)

        -- 判断是可添加还是上锁
        local isUnLock = self.data.clinic[i].IsUnlock
        if isUnLock then
            self:addPillImg(bg, true)
        else
            self:addPillImg(bg)
        end

        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end

        local function onTouchEnd(touch, event)
            local target = event:getCurrentTarget()
            local tag = target:getTag()
            CCLog("tag: ", tag)
            -- 是否能治疗
            -- 是否有星将正在接受治疗
            if self.data.clinic[tag].IsUnlock then
                if 0 == self.data.clinic[tag].HeroID then
                    if #self.data.canCureHeroList > 0 then
                        local ccSize = cc.size(878, 458)
                        local view = require("scene.main.tower.widget.HeroView").new(tag, ccSize, handler(self, self.addBloodHero), self.data.canCureHeroList)
                        view:setPosition(SCREEN_WIDTH * 0.5 - ccSize.width * 0.5, SCREEN_HEIGHT * 0.5 - ccSize.height * 0.5)
                        local scene = cc.Director:getInstance():getRunningScene()
                        scene:addChild(view)
                    else
                        application:showFlashNotice("你没有受伤的星将哟～")
                    end
                else
                    self.data.clickSlotFunc(tag, handler(self, self.removeBloodHero))
                end
            elseif tag < 4 then
                local desc = ""
                if 1 == tag then
                    desc = "该床位通过第5关后开启"
                elseif 2 == tag then
                    desc = "该床位通过第15关后开启"
                elseif 3 == tag then
                    desc = "该床位通过第27关后开启"
                end
                application:showFlashNotice(desc)
            else
                local layer = require("tool.helper.CommonLayer").ToBuyVIP("VIP5开启该床位~", function()
                    self:removeFromParent()
                    self = nil
                end)
                self:addChild(layer)
            end
        end
        local listener1 = cc.EventListenerTouchOneByOne:create()
        listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
        listener1:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, bg)
    end

    for k,v in pairs(self.data.clinic) do
        if 0 ~= v.HeroID then
            local heroInfo = GameCache.GetHero(v.HeroID)  
            local hurtHero = self:getHurtHero(v.HeroID)
            self:addBloodHero(k, heroInfo, hurtHero.RemainHP, heroInfo.HP)
        end
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local startpos = target:convertToNodeSpace(touch:getStartLocation())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
            self:removeFromParent()
            self = nil
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.bg)
end

function AddBloodHouse:addBloodHero(slotID, heroInfo, remainHP, HP)
    self.data.clinic[slotID].HeroID = heroInfo.ID
    self.data.canCureHeroList = self:getCanCureHeroList()

    local bg = self.controls.bloodHouseTab[slotID]

    local hero = require("scene.main.tower.widget.HeroGoodsInfo").new(heroInfo)
    hero:setBlood(remainHP, HP)
    hero:setTouchEnable(false)
    hero:setTag(2)
    hero:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.6)
    bg:addChild(hero)
end

function AddBloodHouse:removeBloodHero(slotID)
    self.data.clinic[slotID].HeroID = 0
    self.data.canCureHeroList = self:getCanCureHeroList()

    local bg = self.controls.bloodHouseTab[slotID]
    local child = bg:getChildByTag(2)
    if child then
        self.controls.bloodHouseTab[slotID]:removeChild(child)
    end
    self:addPillImg(bg, true)
end

function AddBloodHouse:addPillImg(bg, isUnLock)
    local pillImg = cc.Sprite:create("image/ui/img/btn/btn_922.png")
    pillImg:setTag(1)
    pillImg:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.6)
    bg:addChild(pillImg)

    local addImg = nil
    if isUnLock then
        addImg = cc.Sprite:create("image/ui/img/btn/btn_300.png")
        addImg:setPosition(pillImg:getContentSize().width * 0.5, pillImg:getContentSize().height * 0.5)
        pillImg:addChild(addImg)
    else
        addImg = cc.Sprite:create("image/ui/img/btn/btn_1159.png")
        addImg:setPosition(pillImg:getContentSize().width * 0.5, pillImg:getContentSize().height * 0.5)
        pillImg:addChild(addImg)
    end

end

function AddBloodHouse:onEnter()

end

return AddBloodHouse
