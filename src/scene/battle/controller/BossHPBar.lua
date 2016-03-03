local BossHPBar = class("BossHPBar", function() return cc.Node:create() end)

local HP_BAR_IMAGE_LIST = {
    "btn_1277",
    "btn_1278",
    "btn_1279",
    "btn_1280",
    "btn_1281",
}

local function hp_bar_tube_count(hp)
    if hp < 1  * 10000 then
        return 2
    elseif hp < 2  * 10000 then
        return 3
    elseif hp < 10 * 10000 then
        return 4
    else
        return 5
    end
end

local function tube_range_list(count)
    if count == 2 then
        return {{0, 50}, {50, 100}}
    elseif count == 3 then
        return {{0, 33}, {33, 66}, {66, 100}}
    elseif count == 4 then
        return {{0, 25}, {25, 50}, {50, 75}, {75, 100}}
    elseif count == 5 then
        return {{0, 20}, {20, 40}, {40, 60}, {60, 80}, {80, 100}}
    else
        error(string.format("count %d is invalid", count))
    end
end

local function tube_range_index(rangeList, fullPercent)
    for idx, range in ipairs(rangeList) do
        local start = range[1]
        local stop = range[2]
        if fullPercent >= start and fullPercent <= stop then
            return idx
        end
    end
    return 1
end

function BossHPBar:ctor(modelAttr)
    self.tubeCount = hp_bar_tube_count(modelAttr.fullHP)
    self.tubeIndex = self.tubeCount
    self.fullPercent = 100
    self.tubePercent = 100
    self.tubeRangeList = tube_range_list(self.tubeCount)

    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/border.plist")

    local starLevel = modelAttr.starLevel
    --local heroHeadBorder = cc.Sprite:create(string.format("image/icon/border/border_star_%d.png", starLevel))
    local heroHeadBorder = cc.Sprite:createWithSpriteFrameName(string.format("border_star_%d.png", starLevel))
    heroHeadBorder:setPosition(cc.p(-160, 0))
    heroHeadBorder:setScale(0.8)
    self:addChild(heroHeadBorder, 8)
    
    local heroRes = modelAttr.heroRes
    local heroHeadIcon = cc.Sprite:create(string.format("image/icon/head/%s.png", heroRes))
    heroHeadIcon:setPosition(cc.p(-160, 0))
    heroHeadIcon:setScale(0.8)
    self:addChild(heroHeadIcon, 9)

    local heroBossIcon = cc.Sprite:create("image/ui/img/btn/btn_1297.png")
    heroBossIcon:setPosition(cc.p(-160, -25))
    self:addChild(heroBossIcon, 9)

    local hpBgSprite = cc.Sprite:create("image/ui/img/btn/btn_1282.png")
    hpBgSprite:setPosition(cc.p(20, 0))
    self:addChild(hpBgSprite)
    self.hpBg = hpBgSprite

    self.hpBarShadowList = {}
    self.hpBarList = {}

    for idx = 1, self.tubeCount do
        local image = HP_BAR_IMAGE_LIST[idx]
        local imagePath = string.format("image/ui/img/btn/%s.png", image)

        -- local shadowImage = cc.Sprite:create(imagePath)
        -- shadowImage:setColor(cc.c3b(150, 150, 150))
        -- local hpBarShadow = cc.ProgressTimer:create(shadowImage)
        -- hpBarShadow:setPosition(cc.p(0, 0))
        -- hpBarShadow:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        -- hpBarShadow:setMidpoint(cc.p(0, 1))
        -- hpBarShadow:setBarChangeRate(cc.p(1, 0))
        -- hpBarShadow:setPercentage(self.tubePercent)
        -- self:addChild(hpBarShadow)
        -- self.hpBarShadowList[idx] = hpBarShadow

        local sprite = cc.Sprite:create(imagePath)
        local hpBar = cc.ProgressTimer:create(sprite)
        hpBar:setPosition(cc.p(20, 0))
        hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        hpBar:setMidpoint(cc.p(0, 1))
        hpBar:setBarChangeRate(cc.p(1, 0))
        hpBar:setPercentage(self.tubePercent)
        self:addChild(hpBar, idx)
        self.hpBarList[idx] = hpBar
    end
end

function BossHPBar:updatePercent(fullPercent)
    CCLog("BossHPBar:updatePercent(", fullPercent, ")")
    local tubeCount = self.tubeCount
    local prevTubeIndex = self.tubeIndex

    local tubeIndex = tube_range_index(self.tubeRangeList, fullPercent)

    local range = self.tubeRangeList[tubeIndex]

    self.tubeIndex = tubeIndex
    CCLog(vardump({prevTubeIndex, tubeIndex}))

    local prevTubePercent = self.tubePercent
    local tubePercent = (fullPercent - range[1]) * tubeCount
    self.tubePercent = tubePercent

    if prevTubeIndex == tubeIndex then
        local hpBar = self.hpBarList[tubeIndex]

        local useTime = 0.5 * (math.abs(prevTubePercent - tubePercent) / 100.0)
        hpBar:runAction(cc.ProgressTo:create(useTime, tubePercent))
        CCLog(vardump{tubeIndex, "progressTo", tubePercent})
    else
        if tubeIndex < prevTubeIndex then
            local hpBar = self.hpBarList[prevTubeIndex]

            local useTime = 0.5 * (prevTubePercent / 100.0)
            hpBar:runAction(cc.ProgressTo:create(useTime, 0))
            CCLog(vardump{prevTubeIndex, "progressTo", 0})

            local totalDelay = useTime
            for index = prevTubeIndex - 1, tubeIndex + 1, -1 do
                local hpBar = self.hpBarList[index]

                local useTime = 0.5
                hpBar:runAction(cc.Sequence:create({cc.DelayTime:create(totalDelay), cc.ProgressTo:create(useTime, 0)}))
                CCLog(vardump{index, "progressTo", 0, "delay", totalDelay})
                totalDelay = totalDelay + useTime
            end

            local hpBar = self.hpBarList[tubeIndex]
            local useTime = 0.5 * (tubePercent / 100.0)
            hpBar:runAction(cc.Sequence:create({cc.DelayTime:create(totalDelay), cc.ProgressTo:create(useTime, tubePercent)}))
            CCLog(vardump{tubeIndex, "progressTo", 0, "delay", totalDelay})
        else

        end
    end
end

return BossHPBar
