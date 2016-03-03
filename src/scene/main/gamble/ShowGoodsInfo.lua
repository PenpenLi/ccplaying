local ShowGoodsInfo = class("ShowGoodsInfo", BaseLayer)
local effects = require("tool.helper.Effects")

local scheduler = cc.Director:getInstance():getScheduler()

local buttomZOrder = 2
local topZOrder = buttomZOrder + 1
local swallowZOrder = topZOrder + 1

function ShowGoodsInfo:ctor(goodsList, size)
    self.data.goodsTabs = goodsList
    self.data.currPlayNum = 1
    self.data.playTotal = (#goodsList)
    self:createUI()
    self:createMeteor()

    local openEffect = effects:CreateAnimation(self, SCREEN_WIDTH * 0.5 - size.width * 0.16, SCREEN_HEIGHT * 0.5 + size.height * 0.14, nil, 26, false)
    openEffect:registerSpineEventHandler(function ( event )
        self.data.isPlayAction = true
    end, sp.EventType.ANIMATION_COMPLETE)
    Common.playSound("audio/effect/sphere_explosion5.mp3")
    self.data.playSpeedCount = 1
    self.data.playSpeed = 16
    self.data.lowestSpeed = 8
    self.controls.playAction = scheduler:scheduleScriptFunc(handler(self, self.playActionEvent), 1/60, false)
end

function ShowGoodsInfo:onCleanup()
    scheduler:unscheduleScriptEntry(self.controls.playAction)
end

function ShowGoodsInfo:createUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    swallowLayer:setName("swallowLayer")
    self:addChild(swallowLayer, swallowZOrder)

    self.controls.bg = cc.Sprite:create("image/ui/img/bg/star_bg.jpg")
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    self.controls.sure = createMixSprite("image/ui/img/btn/btn_593.png")
    self.controls.sure:setCircleFont("确定" , 1, 1, 25, cc.c3b(226,204,169))
    self.controls.sure:setAnchorPoint(0.5, 0.5)
    self.controls.sure:setPosition(SCREEN_WIDTH * 0.5, 50)
    self:addChild(self.controls.sure, topZOrder)
    self.controls.sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            Common.OpenGuideLayer( {4,5} )
            self:removeFromParent()
            self = nil
        end
    end)
    self.controls.sure:setScale(0)

    self.controls.bg:setOpacity(0)
    local fadeIn = cc.FadeIn:create(1)
    self.controls.bg:runAction(fadeIn)
end

function ShowGoodsInfo:createMeteor()
    local isRepeatPlay = true
    local beginPos = {{self.data.bgSize.width * 0.7}, {self.data.bgSize.width * 0.8}, {self.data.bgSize.width * 0.95}, {self.data.bgSize.width * 1.1}}
    local starNum = math.random(1, 3)

    for i=1,starNum do
        local star = cc.Sprite:create("image/ui/img/btn/btn_589.png")
        self.controls.bg:addChild(star)
        local scaleValue = math.random(1, 2)
        star:setScale(scaleValue)

        local posIdx = math.random(1, (#beginPos))
        local beginPosX = beginPos[posIdx][1]
        local beginPosY = self.data.bgSize.height * 1.1
        star:setPosition(beginPosX, beginPosY)
        table.remove(beginPos, posIdx)

        local lengthRom = math.random(3, 6)
        local length = self.data.bgSize.width * 0.1 * lengthRom
        local endPosX = beginPosX - length / (math.cos(math.rad(45)))
        local endPosY = beginPosY - length * (math.sin(math.rad(45)))
        local time = 2
        local move = cc.MoveTo:create(time, cc.p(endPosX, endPosY))
        local fadeout = cc.FadeOut:create(time)
        local spawn = cc.Spawn:create(move, fadeout)
        local remove = cc.RemoveSelf:create()
        star:runAction(cc.Sequence:create(spawn, cc.CallFunc:create(function()
            if isRepeatPlay then
                isRepeatPlay = false
                self:createMeteor()
            end
        end), remove))
    end
end

function ShowGoodsInfo:playActionEvent(dt)
    if (self.data.isPlayAction) and ((self.data.playSpeedCount % self.data.playSpeed) == 0) then
        if self.data.currPlayNum > self.data.playTotal then
            self.data.isPlayAction = false
            self.controls.sure:setScale(1)
            local swallow = self:getChildByName("swallowLayer")
            if swallow then
                swallow:removeFromParent()
            end
        else
            Common.playSound("audio/effect/arena_open_player.mp3")
            self:createGoods(self.data.currPlayNum)
            self.data.currPlayNum = self.data.currPlayNum + 1
            if self.data.playSpeed > self.data.lowestSpeed then
                self.data.playSpeed = self.data.playSpeed - 1
            end
            self.data.playSpeedCount = 1
        end
    end
    self.data.playSpeedCount = self.data.playSpeedCount + 1
end

function ShowGoodsInfo:createGoods(currPlayNum)
    local goodsInfo = self.data.goodsTabs[currPlayNum]

    local goodsItem = nil
    if (goodsInfo.IsHeroToSoul) or (goodsInfo.Type == BaseConfig.GT_HERO) then
        self.data.isPlayAction = false
        
        if goodsInfo.Type == BaseConfig.GT_HERO then
            GameCache.addNewHero(goodsInfo.ID, goodsInfo.StarLevel)

            local summonLayer = require("scene.main.gamble.SummonHero").new(goodsInfo, true, function()
                self.data.isPlayAction = true
            end)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(summonLayer)

            goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_HERO, goodsInfo)
            goodsItem:setTips(true)
        elseif goodsInfo.Type == BaseConfig.GT_SOUL then
            GameCache.addSoul(goodsInfo)

            if goodsInfo.IsHeroToSoul then
                local summonLayer = require("scene.main.gamble.SummonHero").new(goodsInfo, false, function()
                    self.data.isPlayAction = true
                end)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(summonLayer)
            end

            goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_SOUL, goodsInfo)
            goodsItem:setTips(true)
            goodsItem:setNum()
        end
    else
        goodsItem = Common.getGoods(goodsInfo, true)
    end
    
    goodsItem:setScale(0)
    self:addChild(goodsItem, topZOrder)
    local space = SCREEN_WIDTH * 0.16
    if self.data.playTotal > 1 then
        if self.data.playTotal < 10 then
            goodsItem:setPosition((currPlayNum - 1)%5 * space + SCREEN_WIDTH * 0.18,SCREEN_HEIGHT * 0.6)
        elseif self.data.playTotal < 20 then
            goodsItem:setPosition((currPlayNum - 1)%5 * space + SCREEN_WIDTH * 0.18,SCREEN_HEIGHT * 0.7 - math.floor((currPlayNum - 1)/5) * 200)
        else
            goodsItem:setPosition((currPlayNum - 1)%5 * space + SCREEN_WIDTH * 0.18,SCREEN_HEIGHT * 0.83 - math.floor((currPlayNum - 1)/5) * 120)
        end
    else
        goodsItem:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.6)
    end
    self:playGoodsAction(goodsInfo, goodsItem)
end

function ShowGoodsInfo:playGoodsAction(goodsInfo, goodsItem)
    local starData = Common.getHeroStarLevelColor(goodsInfo.StarLevel)
    local starNum = starData.StarNum
    local spriPath = nil
    if starNum >= 3 then
        if starNum < 4 then
            spriPath = "image/ui/img/btn/btn_597.png"
        elseif starNum < 5 then
            spriPath = "image/ui/img/btn/btn_596.png"
        elseif starNum < 6 then
            spriPath = "image/ui/img/btn/btn_594.png"
        else
            spriPath = "image/ui/img/btn/btn_595.png"
        end
    end
    if (goodsInfo.Type ~= BaseConfig.GT_SOUL) and spriPath then
        local posX, posY = goodsItem:getPosition()
        local quan = cc.Sprite:create(spriPath)
        quan:setPosition(posX, posY)
        self:addChild(quan, buttomZOrder)
        local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
        quan:runAction(rep)
    end

    local flicker = sp.SkeletonAnimation:create("image/spine/skill_effect/rageclick/skeleton.skel", "image/spine/skill_effect/rageclick/skeleton.atlas", 1)
    flicker:setAnimation(0, "animation", false)
    flicker:setPosition(0, 20)
    goodsItem:addChild(flicker)

    local spawnTime = 0.2
    local scale1 = cc.ScaleTo:create(spawnTime, 1.4)
    local scale2 = cc.ScaleTo:create(0.1, 1)
    local orbit = cc.OrbitCamera:create(spawnTime,1, 0, 0, 720, 0, 0)
    goodsItem:runAction(cc.Sequence:create(cc.Spawn:create(scale1, orbit), scale2))
end

return ShowGoodsInfo




