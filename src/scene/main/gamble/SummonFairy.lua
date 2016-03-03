local SummonFairy = class("SummonFairy", function()
    local node = cc.Node:create()
    node.data = {}
    return node
end)
local animate = require("tool.helper.HeroAction")
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

function SummonFairy:ctor(info, endFunc)
    self.data.fairyInfo = info
    self.data.endFunc = endFunc
    self.data.fairyConfig = BaseConfig.GetFairy(self.data.fairyInfo.ID)
    self.data.isCanExit = false

    self:createFairyUI()
    local number = math.random(1, 2)
    Common.playSound(string.format("audio/fairy/xn_%02d.mp3", number))

    local fairyInfo = {}
    fairyInfo.Exp = 0
    fairyInfo.ID = self.data.fairyInfo.ID
    fairyInfo.Level = 1
    fairyInfo.Name = BaseConfig.GetFairy(fairyInfo.ID).Name
    fairyInfo.SkillLevel = {1, 1}
    GameCache.AllFairy[fairyInfo.ID] = fairyInfo
end

function SummonFairy:createFairyUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local summonBg = cc.Sprite:create("image/ui/img/bg/bg_293.png")
    summonBg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    summonBg:setScaleX(SCREEN_WIDTH / 568)
    summonBg:setScaleY(SCREEN_HEIGHT / 320)
    self:addChild(summonBg)
    self.data.bgSize = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
    summonBg:setOpacity(0)

    local heartAnim = sp.SkeletonAnimation:create("image/spine/ui_effect/43/skeleton.skel", "image/spine/ui_effect/43/skeleton.atlas")
    heartAnim:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 100)
    self:addChild(heartAnim)
    heartAnim:setAnimation(0, "animation", true)

    local light = cc.Sprite:create("image/ui/img/btn/btn_640.png")
    light:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5)
    self:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
    light:runAction(rep)

    local getSpri = cc.Sprite:create("image/ui/img/btn/btn_1209.png")
    getSpri:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.82)
    self:addChild(getSpri)

    local fairyAnim = sp.SkeletonAnimation:create("image/spine/fairy/"..self.data.fairyInfo.ID.."/skeleton.skel", "image/spine/fairy/"..self.data.fairyInfo.ID.."/skeleton.atlas")
    fairyAnim:setPosition(self.data.bgSize.width * 0.5 - 10, self.data.bgSize.height * 0.35)
    self:addChild(fairyAnim)
    fairyAnim:setMix("idl_1", "atk", 0.1)
    fairyAnim:setMix("atk", "idl_1", 0.5)
    if not GameCache.isExamine then
        fairyAnim:setAnimation(0, "idl_1", true)
    end
    fairyAnim:setScale(0)

    local nameBg = cc.Sprite:create("image/ui/img/bg/bg_154.png")
    nameBg:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.29)
    self:addChild(nameBg)
    nameBg:setScaleX(0)
    
    local name = Common.finalFont(self.data.fairyConfig.Name, 1, 1, 35, nil, 1)
    name:enableOutline(cc.c4b(63,31,0,255), 2)
    name:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.295)
    self:addChild(name)
    name:setVisible(false)

    local shuoming = Common.finalFont("给仙女送礼物会有惊喜哟~", 1, 1, 25, nil, 1)
    shuoming:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.15)
    self:addChild(shuoming)
    shuoming:setVisible(false)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        if self.data.isCanExit then
            self.data.isCanExit = false
            summonBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function()
                if self.data.endFunc then
                    self.data.endFunc()
                end
                self:removeFromParent()
                self = nil
            end)))
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, summonBg) 

    local function nameActionEndFunc()
        name:setVisible(true)
        shuoming:setVisible(true)
        self.data.isCanExit = true
    end

    local function bgActionEndFunc()
        local scale1 = cc.ScaleTo:create(0.18, 1.2, 1)
        local scale2 = cc.ScaleTo:create(0.1, 0.8, 1)
        local scale3 = cc.ScaleTo:create(0.08, 1, 1)
        nameBg:runAction(cc.Sequence:create(scale1, scale2, scale3, cc.CallFunc:create(nameActionEndFunc)))
        fairyAnim:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.8), cc.CallFunc:create(function()
            if not GameCache.isExamine then
                fairyAnim:setAnimation(0, "atk", false)
                fairyAnim:addAnimation(0, "idl_1", true)
            end
        end)))
    end

    summonBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.CallFunc:create(bgActionEndFunc)))
end

return SummonFairy

