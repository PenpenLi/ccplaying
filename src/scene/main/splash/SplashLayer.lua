local SplashLayer = class("SplashLayer", BaseLayer)
local scheduler = cc.Director:getInstance():getScheduler()
local effects = require("tool.helper.Effects")

function SplashLayer:ctor()
    SplashLayer.super.ctor(self)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        if self.data.isClick then
            self.data.isClickNum = self.data.isClickNum + 1
            if 1 == self.data.isClickNum then
                self.controls.scene4Node:removeFromParent()
                self.controls.scene4Node = nil

                self.data.isClick = false

                application:pushScene("guide.CreateAvatarScene", function(name)
                    if self.controls.btn_jump then
                        self.controls.btn_jump:removeFromParent()
                        self.controls.btn_jump = nil
                    end
                    self:scene5(name)
                    self.data.isClick = true
                end)
            elseif 2 == self.data.isClickNum then
                application:enterGame()
            end
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self) 

    self.data.isClick = false
    self.data.isClickNum = 0
    self:scene1()

    Common.stopBackgroundMusic()
    Common.playSound("audio/music/start_1.mp3")

    self.controls.btn_jump = createMixScale9Sprite("image/ui/img/btn/btn_553.png", nil, nil, cc.size(125,55))
    self.controls.btn_jump:setButtonBounce(false)
    self.controls.btn_jump:setCircleFont("跳过", 1, 1, 25, cc.c3b(255,231,148), 1)
    self.controls.btn_jump:setPosition(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 50)
    self:addChild(self.controls.btn_jump, 10)
    self.controls.btn_jump:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            sender:removeFromParent()
            sender = nil
            
            application:pushScene("guide.CreateAvatarScene", function(name)
                scheduler:unscheduleScriptEntry(self.timeScheduler)
                if self.controls.scene1Node then
                    self.controls.scene1Node:removeFromParent()
                end
                if self.controls.scene2Node then
                    self.controls.scene2Node:removeFromParent()
                end
                if self.controls.scene3Node then
                    self.controls.scene3Node:removeFromParent()
                end
                if self.controls.scene4Node then
                    self.controls.scene4Node:removeFromParent()
                end
                self.data.isClickNum = 1

                self:scene5(name)
                self.data.isClick = true
            end)
        end
    end)
end

function SplashLayer:onEnterTransitionFinish()
    -- body
end

function SplashLayer:scene1()
    self.controls.scene1Node = cc.Node:create()
    self:addChild(self.controls.scene1Node)

    local cloudOutTime = 2
    self.timeScheduler = nil
    local bg = cc.Sprite:create("image/ui/splash/scene1/1.jpg")
    self.controls.scene1Node:addChild(bg)
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local scale1 = cc.ScaleTo:create(3.8, 1.2)
    local delay1 = cc.DelayTime:create(0.9)
    local fadeout2 = cc.FadeOut:create(0.2)
    local scale2 = cc.ScaleTo:create(0.2, 1.8)
    local spawn2 = cc.Spawn:create(fadeout2, scale2)
    bg:runAction(cc.Sequence:create(cc.DelayTime:create(cloudOutTime * 0.3), scale1, delay1, spawn2, cc.CallFunc:create(function()
        scheduler:unscheduleScriptEntry(self.timeScheduler)
        self.controls.scene1Node:removeFromParent()
        self.controls.scene1Node = nil
        self:scene2()
    end)))

    local descNode = cc.Node:create()
    descNode:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self.controls.scene1Node:addChild(descNode)

    local descTab = {}
    local date=os.date("%Y年%m月%d日 %H:%M:%S")
    local desc1 = Common.finalFont("公元"..date, 1, 1, 39, nil, 1)
    desc1:setAdditionalKerning(-2)
    desc1:enableOutline(cc.c4b(0,0,0,255), 4)
    desc1:setPosition(0, 100)
    descNode:addChild(desc1)
    desc1:setOpacity(0)
    descTab[1] = desc1
    self.timeScheduler = scheduler:scheduleScriptFunc(function()
        local date=os.date("%Y年%m月%d日 %H:%M:%S")
        desc1:setString("公元"..date)
    end, 1, false)
    local desc2 = Common.finalFont("帝都 - 大裤衩", 1, 1, 50, nil, 1)
    desc2:enableOutline(cc.c4b(0,0,0,255), 4)
    desc2:setPosition(0, 20)
    descNode:addChild(desc2)
    desc2:setOpacity(0)
    descTab[2] = desc2
    local descError = Common.finalFont("《天朝比惨王》", 1, 1, 39, cc.c3b(255, 239, 0), 1)
    descError:setAnchorPoint(0.5, 0)
    descError:setPosition(-100, -80)
    descNode:addChild(descError)
    descError:setOpacity(0)
    descTab[3] = descError
    local desc4 = Common.finalFont("录制现场", 1, 1, 39, cc.c3b(255, 239, 0), 1)
    desc4:setAnchorPoint(0.5, 0)
    desc4:setPosition(105, -80)
    descNode:addChild(desc4)
    desc4:setOpacity(0)
    descTab[4] = desc4

    for i=1,4 do
        local delay = cc.DelayTime:create((i - 1) * 0.2 + 0.5)
        local fadeIn = cc.FadeIn:create(2)
        descTab[i]:runAction(cc.Sequence:create(delay, fadeIn))
    end

    local descRight = Common.finalFont("《大咖秀》", 1, 1, 39, cc.c3b(255, 239, 0), 1)
    descRight:setAnchorPoint(0.5, 0)
    descRight:setPosition(-100, SCREEN_HEIGHT * 0.6)
    descNode:addChild(descRight)
    local delayRight = cc.DelayTime:create(2)
    local moveRight = cc.EaseBounceOut:create(cc.MoveTo:create(0.5, cc.p(-100, -80)))
    descRight:runAction(cc.Sequence:create(delayRight, cc.CallFunc:create(function()
        descError:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1, 0), cc.ScaleTo:create(0.1, 1, 0.3), cc.ScaleTo:create(0.1, 1, 0)))
    end), moveRight))

    local moveTime = 1.5
    local leftCloud = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    leftCloud:setOpacity(150)
    leftCloud:setPosition(SCREEN_WIDTH * 0.4, SCREEN_HEIGHT * 0.5)
    self.controls.scene1Node:addChild(leftCloud)
    local rightCloud = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    rightCloud:setOpacity(150)
    rightCloud:setPosition(SCREEN_WIDTH * 0.6, SCREEN_HEIGHT * 0.5)
    rightCloud:setFlippedX(true)
    self.controls.scene1Node:addChild(rightCloud)
    leftCloud:runAction(cc.Sequence:create(cc.MoveBy:create(moveTime * 2, cc.p(-SCREEN_WIDTH * 1.5, 0))))
    rightCloud:runAction(cc.Sequence:create(cc.MoveBy:create(moveTime * 2, cc.p(SCREEN_WIDTH * 1.5, 0))))

    leftCloud = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    leftCloud:setPosition(SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.5)
    self.controls.scene1Node:addChild(leftCloud)
    rightCloud = cc.Sprite:create("image/ui/img/btn/btn_1185.png") 
    rightCloud:setPosition(SCREEN_WIDTH * 0.8, SCREEN_HEIGHT * 0.5)
    rightCloud:setFlippedX(true)
    self.controls.scene1Node:addChild(rightCloud)
    leftCloud:runAction(cc.Sequence:create(cc.MoveBy:create(moveTime, cc.p(-SCREEN_WIDTH * 1.2, 0))))
    rightCloud:runAction(cc.Sequence:create(cc.MoveBy:create(moveTime, cc.p(SCREEN_WIDTH * 1.2, 0))))
end

function SplashLayer:scene2()
    self.controls.scene2Node = cc.Node:create()
    self:addChild(self.controls.scene2Node)

    local bg = cc.Sprite:create("image/ui/splash/scene2/1.png")
    self.controls.scene2Node:addChild(bg)
    bg:setScale(3)
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local bgSize = bg:getContentSize()

    local scale1 = cc.ScaleTo:create(2, 1.8)
    local scale2 = cc.ScaleTo:create(0.8, 1)
    local delay = cc.DelayTime:create(2)
    bg:runAction(cc.Sequence:create({scale1, scale2, delay, cc.CallFunc:create(function()
            self.controls.scene2Node:removeFromParent()
            self.controls.scene2Node = nil
            self:scene3()
    end)}))
    local di = cc.Sprite:create("image/ui/img/btn/btn_249.png")
    di:setScale(0.3)
    di:setPosition(bgSize.width * 0.5, bgSize.height * 0.47)
    bg:addChild(di)
    local zhu = sp.SkeletonAnimation:create("image/spine/splash/zhu/skeleton.skel", "image/spine/splash/zhu/skeleton.atlas")
    zhu:setPosition(bgSize.width * 0.5, bgSize.height * 0.46)
    bg:addChild(zhu)
    zhu:setMix("idle", "sing", 0.2)
    zhu:setAnimation(0, "idle", false)
    zhu:addAnimation(0, "sing", true)

    local lamplightAnim = sp.SkeletonAnimation:create("image/spine/splash/lamplight/skeleton.skel", "image/spine/splash/lamplight/skeleton.atlas")
    lamplightAnim:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    bg:addChild(lamplightAnim)
    lamplightAnim:setAnimation(0, "animation", true)

    local chair1 = cc.Sprite:create("image/ui/splash/scene2/2.png")
    chair1:setAnchorPoint(0.5, 0)
    chair1:setPosition(bgSize.width * 0.2, -50)
    bg:addChild(chair1)
    local chairSize = chair1:getContentSize()
    local people1 = cc.Sprite:create("image/ui/splash/scene2/4.png")
    people1:setPosition(chairSize.width * 0.5, chairSize.height * 0.61)
    chair1:addChild(people1)
    local chair2 = cc.Sprite:create("image/ui/splash/scene2/2.png")
    chair2:setAnchorPoint(0.5, 0)
    chair2:setPosition(bgSize.width * 0.5, -50)
    bg:addChild(chair2)
    local people2 = cc.Sprite:create("image/ui/splash/scene2/5.png")
    people2:setPosition(chairSize.width * 0.5, chairSize.height * 0.65)
    chair2:addChild(people2)
    local chair3 = cc.Sprite:create("image/ui/splash/scene2/2.png")
    chair3:setAnchorPoint(0.5, 0)
    chair3:setPosition(bgSize.width * 0.8, -50)
    bg:addChild(chair3)
    local people3 = cc.Sprite:create("image/ui/splash/scene2/6.png")
    people3:setPosition(chairSize.width * 0.5, chairSize.height * 0.63)
    chair3:addChild(people3)
    
    local bottom = cc.Sprite:create("image/ui/splash/scene2/7.png")
    bottom:setAnchorPoint(0.5, 0)
    bottom:setPosition(SCREEN_WIDTH * 0.5, -2)
    self.controls.scene2Node:addChild(bottom)
end

function SplashLayer:scene3()
    self.controls.scene3Node = cc.Node:create()
    self:addChild(self.controls.scene3Node)
    
    local rightSpri = cc.Sprite:create("image/ui/splash/scene3/2.png")
    rightSpri:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self.controls.scene3Node:addChild(rightSpri)
    local rightSize = rightSpri:getContentSize()
    
    local people = cc.Sprite:create("image/ui/splash/scene3/1.png")
    people:setPosition(rightSize.width * 0.55, rightSize.height * 0.6)
    rightSpri:addChild(people)
    local btn = cc.Sprite:create("image/ui/splash/scene3/5.png")
    btn:setPosition(rightSize.width * 0.22, rightSize.height * 0.32)
    rightSpri:addChild(btn)
    btn:setScale(1.5)
    local hand = cc.Sprite:create("image/ui/splash/scene3/3.png")
    hand:setPosition(rightSize.width * 0.19, rightSize.height * 0.4)
    rightSpri:addChild(hand)

    local rightDelay1 = cc.DelayTime:create(0.3)
    rightSpri:runAction(cc.Sequence:create({rightDelay1, cc.CallFunc:create(function()
        hand:setTexture("image/ui/splash/scene3/4.png")
        hand:setPosition(rightSize.width * 0.255, rightSize.height * 0.38)
    end), rightDelay1:clone(), cc.CallFunc:create(function()
        self.controls.scene3Node:removeFromParent()
        self.controls.scene3Node = nil
        self:scene4()
    end)}))
end

function SplashLayer:scene4()
    self.controls.scene4Node = cc.Node:create()
    self:addChild(self.controls.scene4Node)

    local bg = cc.Sprite:create("image/ui/splash/scene4/1.png")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self.controls.scene4Node:addChild(bg)
    local bgSize = bg:getContentSize()
    local chair1 = cc.Sprite:create("image/ui/splash/scene4/2.png")
    chair1:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    bg:addChild(chair1)

    local iwantyou = cc.Sprite:create("image/ui/splash/scene4/4.png")
    iwantyou:setPosition(bgSize.width * 0.5, bgSize.height * 0.48)
    bg:addChild(iwantyou)
    iwantyou:setScale(0)
    iwantyou:setOpacity(0)

    local delay1 = cc.DelayTime:create(0.5)
    local delay2 = cc.DelayTime:create(0.05)
    local orbit1 = cc.OrbitCamera:create(0.2, 1, 0, 0, 10, 0, 0) 
    local orbit2 = cc.OrbitCamera:create(0.1,1, 0, -90, 90, 0, 0)
    chair1:runAction(cc.Sequence:create({delay1, cc.CallFunc:create(function()
        chair1:setTexture("image/ui/splash/scene4/5.png")
    end), delay2, cc.CallFunc:create(function()
        chair1:setTexture("image/ui/splash/scene4/6.png")
        local people = cc.Sprite:create("image/ui/splash/scene4/3.png")
        people:setPosition(chair1:getContentSize().width * 0.5, chair1:getContentSize().height * 0.55)
        chair1:addChild(people)
    end), orbit2, cc.CallFunc:create(function()
        local showTime = 0.4
        local fadeIn = cc.FadeIn:create(showTime)
        local scale = cc.ScaleTo:create(showTime, 1.2)
        local spawn = cc.Spawn:create(fadeIn, scale)
        local scale1 = cc.ScaleTo:create(0.1, 1)
        iwantyou:runAction(cc.Sequence:create({spawn, scale1, delay1:clone(), cc.CallFunc:create(function()
            iwantyou:removeFromParent()
            iwantyou = nil

            local heroInfo = {
                ID = 1027,
                IsHeroToSoul = false,
                Num = 1,
                StarLevel = 0,
                Num = 1,
                TFP = 676,
            }
            local summonLayer = require("scene.main.splash.SummonZhu").new(heroInfo, true, function()
                self:scene41()
                self.data.isClick = true
            end)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(summonLayer)
        end)}))
    end)}))
end

function SplashLayer:scene41()
    Common.playSound("audio/music/start_2.mp3")

    local descBg = cc.Scale9Sprite:create("dummy/dialog_bg.jpg")
    descBg:setContentSize(cc.size(SCREEN_WIDTH, 200))
    descBg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.15)
    self.controls.scene4Node:addChild(descBg)

    local peopleSpri = cc.Sprite:create("image/ui/splash/scene4/7.png")
    peopleSpri:setPosition(SCREEN_WIDTH * 0.15, SCREEN_HEIGHT * 0.2)
    self.controls.scene4Node:addChild(peopleSpri)
    peopleSpri:setScale(1.5)

    local desc1 = Common.finalFont("八戒选手,我是你的导师。你有什么梦(囧)想(事)", 1, 1, 25, nil, 1)
    desc1:setAnchorPoint(0, 0.5)
    desc1:setPosition(SCREEN_WIDTH * 0.36, SCREEN_HEIGHT * 0.2)
    self.controls.scene4Node:addChild(desc1)

    local desc2 = Common.finalFont("要跟我们大家分享一下吗？", 1, 1, 25, nil, 1)
    desc2:setAnchorPoint(0, 0.5)
    desc2:setPosition(SCREEN_WIDTH * 0.36, SCREEN_HEIGHT * 0.12)
    self.controls.scene4Node:addChild(desc2)

    local look = effects:CreateAnimation(self.controls.scene4Node, 0, 0, nil, 17, true)
    look:setPosition(SCREEN_WIDTH * 0.9, SCREEN_HEIGHT * 0.08)
    
    if self.controls.btn_jump then
        self.controls.btn_jump:removeFromParent()
        self.controls.btn_jump = nil
    end
end

function SplashLayer:scene5(name)
    self.controls.scene5Node = cc.Node:create()
    self:addChild(self.controls.scene5Node)

    local bg = cc.Sprite:create("image/ui/splash/scene2/1.png")
    self.controls.scene5Node:addChild(bg)
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)

    local bgSize = bg:getContentSize()
    local zhu = sp.SkeletonAnimation:create("image/spine/splash/zhu/skeleton.skel", "image/spine/splash/zhu/skeleton.atlas")
    zhu:setPosition(bgSize.width * 0.5, bgSize.height * 0.46)
    bg:addChild(zhu)
    zhu:setAnimation(0, "idle", true)

    local descBg = cc.Scale9Sprite:create("dummy/dialog_bg.jpg")
    descBg:setContentSize(cc.size(SCREEN_WIDTH, 200))
    descBg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.15)
    self.controls.scene5Node:addChild(descBg)

    local peopleSpri = sp.SkeletonAnimation:create("image/spine/splash/zhu/skeleton.skel", "image/spine/splash/zhu/skeleton.atlas")
    peopleSpri:setPosition(SCREEN_WIDTH * 0.15, -SCREEN_HEIGHT * 0.1)
    self.controls.scene5Node:addChild(peopleSpri)
    peopleSpri:setScale(2)
    peopleSpri:setAnimation(0, "idle2", true)

    local desc1 = Common.systemFont(name.."老师,我很高兴能加入你的战队", 1, 1, 25, nil, 1)
    desc1:setAnchorPoint(0, 0.5)
    desc1:setPosition(SCREEN_WIDTH * 0.4, SCREEN_HEIGHT * 0.2)
    self.controls.scene5Node:addChild(desc1)

    local desc2 = Common.finalFont("其实我很惨的,事情是这样子的。。。", 1, 1, 25, nil, 1)
    desc2:setAnchorPoint(0, 0.5)
    desc2:setPosition(SCREEN_WIDTH * 0.4, SCREEN_HEIGHT * 0.12)
    self.controls.scene5Node:addChild(desc2)

    local look = effects:CreateAnimation(self.controls.scene5Node, 0, 0, nil, 17, true)
    look:setPosition(SCREEN_WIDTH * 0.9, SCREEN_HEIGHT * 0.08)
end

return SplashLayer
