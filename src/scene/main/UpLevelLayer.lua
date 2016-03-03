--
-- Author: keyring
-- Date: 2014-11-06 21:16:36
--
local UpLevelLayer = class("UpLevelLayer", BaseLayer)

function UpLevelLayer:ctor(tab)
    UpLevelLayer.super.ctor(self)

    local LastLevel = tab[1]
    local CurrLevel = tab[2]
    local LastLimit = tab[3]
    local CurrLimit = tab[4]
    local LastPower = tab[5]
    local CurrPower = tab[6]

    if CurrLevel % 5 == 0 then
        application:dispatchCustomEvent(AppEvent.UI.MainLayer.RefreshOthers, true)
    end

    local layer = cc.Layer:create()
    self:addChild(layer)

    local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    light:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.85)
    layer:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
    light:runAction(rep)

    -- 升级了
    -- layer:setScale(1.05)
    local layer_event = cc.CallFunc:create(function ( )
        local action = cc.Sequence:create({cc.ScaleTo:create(0.01, 1.0),cc.ScaleTo:create(0.02, 1.05),cc.ScaleTo:create(0.02, 1.0),cc.ScaleTo:create(0.02, 1.05),cc.ScaleTo:create(0.02, 1.0),cc.ScaleTo:create(0.02, 1.05),cc.ScaleTo:create(0.02, 1.0)})
        layer:runAction(action)     
    end)


    local bg = cc.Sprite:create("image/ui/img/bg/bg_164.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.43)
    layer:addChild(bg)

    local bgsize = bg:getContentSize()

    local icon = cc.Sprite:create("image/ui/img/btn/btn_636.png")
    icon:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.85)
    icon:setScale(0.1)
    
    layer:addChild(icon)


    local sidai = cc.Sprite:create("image/ui/img/bg/bg_160.png")
    sidai:setPosition(bgsize.width*0.5, bgsize.height+5)
    bg:addChild(sidai)

    local sidaisize = sidai:getContentSize()

    local up = cc.Sprite:create("image/ui/img/btn/btn_634.png")
    up:setAnchorPoint(0.5,0)
    up:setPosition(sidaisize.width*0.22, sidaisize.height*0.4)
    sidai:addChild(up)

    icon:runAction(cc.Sequence:create({cc.ScaleTo:create(0.1, 1.2),cc.ScaleTo:create(0.05, 1.0), cc.DelayTime:create(0.3), cc.CallFunc:create(function (  )
        local action = cc.Sequence:create({cc.ScaleTo:create(0.12, 1, 1.5),cc.ScaleTo:create(0.05, 1.0)})
        up:runAction(action)  
    end)}))


	local label = Common.finalFont("Lv."..LastLevel, 1,1,22,nil,1)
    -- label:setColor(cc.c3b(202,227,242))
    -- label:enableOutline(cc.c4b(0,0,0,255), 2)
    label:setAnchorPoint(0,0.5)
    label:setPosition(400, 320)
    bg:addChild(label)

    -- label = Common.finalFont(""..LastLevel, 1,1,28,nil,2)
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(445, 320)
    -- bg:addChild(label)

    local icon = cc.Sprite:create("image/ui/img/btn/btn_340.png")
    icon:setPosition(505, 320)
    bg:addChild(icon)
    
    label = Common.finalFont("Lv."..CurrLevel, 1,1,22,cc.c3b(118,251,60))
    label:setAnchorPoint(0,0.5)
    label:enableOutline(cc.c4b(75,4,2,255), 1)
    label:setPosition(540, 320)
    bg:addChild(label)

    -- label = Common.finalFont(""..CurrLevel, 1,1,28,cc.c3b(118,251,60))
    -- label:setAnchorPoint(0,0.5)
    -- label:enableOutline(cc.c4b(75,4,2,255), 2)
    -- label:setPosition(585, 320)
    -- bg:addChild(label)

    local line = cc.Sprite:create("image/ui/img/btn/btn_639.png")
    line:setPosition(bgsize.width*0.5, 250)
    bg:addChild(line)

    label = Common.finalFont("星将等级上限", 1,1,26,cc.c3b(255,237,135))
    label:setAnchorPoint(1,0.5)
    label:setPosition(390, 200)
    bg:addChild(label)

    local label = Common.finalFont("Lv."..LastLimit, 1,1,20, nil, 1)
    -- label:setColor(cc.c3b(202,227,242))
    -- label:enableOutline(cc.c4b(0,0,0,255), 2)
    label:setAnchorPoint(0,0.5)
    label:setPosition(405, 200)
    bg:addChild(label)

    -- label = Common.finalFont(""..LastLimit, 1,1,26, nil, 1)
    -- -- label:setColor(cc.c3b(202,227,242))
    -- -- label:enableOutline(cc.c4b(0,0,0,255), 2)
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(450, 200)
    -- bg:addChild(label)

    local icon = cc.Sprite:create("image/ui/img/btn/btn_340.png")
    icon:setPosition(505, 200)
    bg:addChild(icon)
    
    label = Common.finalFont("Lv."..CurrLimit, 1,1,20,cc.c3b(118,251,60))
    -- label:enableOutline(cc.c4b(75,4,2,255), 1)
    label:setAnchorPoint(0,0.5)
    label:setPosition(545, 200)
    bg:addChild(label)

    -- label = Common.finalFont(""..CurrLimit, 1,1,26,cc.c3b(118,251,60))
    -- label:enableOutline(cc.c4b(75,4,2,255), 1)
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(585, 200)
    -- bg:addChild(label)

    local line = cc.Sprite:create("image/ui/img/btn/btn_639.png")
    line:setPosition(bgsize.width*0.5, 155)
    bg:addChild(line)

    label = Common.finalFont("当前体力值", 1,1,26,cc.c3b(255,237,135))
    label:setAnchorPoint(1,0.5)
    label:setPosition(390, 105)
    bg:addChild(label)

    local label = Common.finalFont(""..LastPower, 1,1,22,nil,1)
    label:setPosition(440, 105)
    bg:addChild(label)
    local icon = cc.Sprite:create("image/ui/img/btn/btn_340.png")
    icon:setPosition(505, 105)
    bg:addChild(icon)
    
    label = Common.finalFont(""..CurrPower, 1,1,22,cc.c3b(118,251,60))
    -- label:enableOutline(cc.c4b(75,4,2,255), 1)
    -- label:setAnchorPoint(0,0.5)
    label:setPosition(575, 105)
    bg:addChild(label)


    local line = cc.Sprite:create("image/ui/img/btn/btn_639.png")
    line:setPosition(bgsize.width*0.5, 55)
    bg:addChild(line)


    local btnImage = "image/ui/img/btn/btn_553.png"
    local btnBackToMap = createMixSprite(btnImage)
    btnBackToMap:setCircleFont("确定",1,1,30,cc.c3b(226,204,169),2)
    btnBackToMap:setFontPos(0.5,0.5)
    btnBackToMap:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.1)
    layer:addChild(btnBackToMap)
    btnBackToMap:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if CurrLevel <= 40 then
                local config = BaseConfig.GetSystemOpen(CurrLevel)
                if config then
                    layer:removeFromParent()
                    layer = nil
                    self:OpenNewEntry( config, CurrLevel )
                    return
                end                
            end
            application:popScene()
        end
    end)





    local function onTouchBegan(touch, event)
     	return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

end

function UpLevelLayer:OpenNewEntry( config, Level )
    local layer = cc.Layer:create()
    self:addChild(layer)

    local panel = cc.Sprite:create("image/ui/img/btn/btn_1207.png")
    panel:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    panel:setScaleY(0.01)
    layer:addChild(panel)

    local panelsize = panel:getContentSize()

    local panelaction = cc.ScaleTo:create(0.2, 1)
    panel:runAction(panelaction)

    local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    light:setPosition(panelsize.width*0.5, panelsize.height*0.6)
    panel:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
    light:runAction(rep)

    local bg = cc.Sprite:create("image/ui/open/"..config.Res.."/bg.png")
    bg:setPosition(panelsize.width*0.5, panelsize.height*0.5)
    panel:addChild(bg)
    bg:setScale(0.01)

    local bgaction = cc.Sequence:create(cc.DelayTime:create(0.25), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1))
    bg:runAction(bgaction)

    local bgsize = bg:getContentSize()

    local title = cc.Sprite:create("image/ui/img/btn/btn_1208.png")
    title:setPosition(panelsize.width*0.5, panelsize.height)
    panel:addChild(title)  

    local label_bg = cc.Sprite:create("image/ui/img/btn/btn_1166.png")
    label_bg:setPosition(panelsize.width*0.5, 0)
    label_bg:setOpacity(0)
    panel:addChild(label_bg)

    local labelsize = label_bg:getContentSize()

    -- local action = cc.Sequence:create( cc.DelayTime:create(0.5), cc.ScaleTo:create(0.5, 3, 1) )
    label_bg:runAction(cc.Sequence:create( cc.DelayTime:create(0.8), cc.FadeIn:create(0.2) ))

    local label = Common.finalFont(""..config.Name, labelsize.width*0.5, labelsize.height*0.5, 28, cc.c3b(220,229,120))
    label:setOpacity(0)
    label_bg:addChild(label)

    label:runAction(cc.Sequence:create( cc.DelayTime:create(1), cc.FadeIn:create(0.2) ))

    local desc = Common.finalFont(""..config.Desc, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.1, 28)
    layer:addChild(desc)

    application:dispatchCustomEvent(AppEvent.UI.MainLayer.OpenSystem, {system = config.System, level = Level})
    GameCache.NewbieGuide.State = true




    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        if GameCache.NewbieGuide.Step ~= 3 then
            cc.Director:getInstance():popToRootScene()
            GameCache.OpenSystem.Step = config.System
            GameCache.OpenSystem.State = true
        else
            application:popScene()
        end

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function UpLevelLayer:onEnterTransitionFinish( ... )
    -- body
end

function UpLevelLayer:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)
end

function UpLevelLayer:onCleanup()

end

return UpLevelLayer