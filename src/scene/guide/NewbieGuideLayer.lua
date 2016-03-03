--
-- Author: keyring
-- Date: 2015-05-19 09:15:53
--
local NewbieGuideLayer = class("NewbieGuideLayer", function (  )
    local self = cc.Layer:create()
    local function onNodeEvent(event)

        if event == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return self
end)
local EffectManager = require("tool.helper.Effects")
local GUIDE_STEP_DATA = require("scene.guide.NewbieGuideConfig")
local ColorLabel = require("tool.helper.NewColorLabel")

function NewbieGuideLayer:ctor()
    GameCache.NewbieGuide.State = true

    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self, 1)
    self:setName("GUIDE_LAYER")
    self:setVisible(false)

    local clickCount = 1
    local cancelCount = 20

    local layer = cc.Layer:create()
    self:addChild(layer)

    local clipper = cc.ClippingNode:create()
    clipper:setInverted(true)
    clipper:setAlphaThreshold(0)
    layer:addChild(clipper)

    local layercolor = cc.LayerColor:create(cc.c4b(0,0,0,100))
    clipper:addChild(layercolor)

    local stencil = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1137.png")
    stencil:setContentSize(cc.size(0,0))
    clipper:setStencil(stencil)

    local effect = nil

    local xiaomei = load_animation("image/spine/fairy/1005/")
    xiaomei:setScale(0.8)
    if not GameCache.isExamine then
        xiaomei:setAnimation(0, "idl_1", true)
    end
    xiaomei:setVisible(false)
    self:addChild(xiaomei)

    local yun = cc.Sprite:create("image/ui/img/btn/btn_1154.png")
    xiaomei:addChild(yun)

    local dialogbox = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1153.png")
    dialogbox:setAnchorPoint(0,0.5)
    dialogbox:setVisible(false)
    dialogbox:setContentSize(cc.size( 400, 130 ))
    self:addChild(dialogbox)

    local label_dialog = ColorLabel.new("", 30, 340, true)--Common.finalFont("", 200, 65, 30)
    label_dialog:setVisible(false)
    label_dialog:setAnchorPoint(0,0.5)
    -- label_dialog:setContentSize(cc.size(340,100))
    -- label_dialog:setDimensions( 340, 100 )
    self:addChild(label_dialog)

    local RECT = cc.rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)
    local RECT2 = nil
    local BIG_STEP = GameCache.NewbieGuide.Step + 1

    local GuideData = GUIDE_STEP_DATA[BIG_STEP]

    self.openGuideListener = application:addEventListener(AppEvent.UI.NewbieGuide.OpenGuide,function ( event )  -- step by step

        self:setVisible(true)

        CCLog(GameCache.NewbieGuide.SStep)
        local stepdata = GuideData.steps[GameCache.NewbieGuide.SStep]


        if effect and not tolua.isnull(effect) then
           effect:removeFromParent()
        end

        -- 获取当前步骤的数据
        local x = stepdata.x
        local y = stepdata.y
        local width = stepdata.width
        local height = stepdata.height 

        if stepdata.text_box then
            xiaomei:setVisible(true)
            dialogbox:setVisible(true)
            label_dialog:setVisible(true)

            local picX = stepdata.text_box.picX
            local picY = stepdata.text_box.picY

            if stepdata.text_box.icon_dir == "left" then
                xiaomei:setRotationSkewY(0)
                dialogbox:setFlippedX(false)
                label_dialog:setAnchorPoint(0,0.5)

                xiaomei:setPosition(picX, picY)
                dialogbox:setPosition(picX+70, picY+130 )
                label_dialog:setPosition(picX+115,picY+130)
                
            elseif stepdata.text_box.icon_dir ==  "right" then
                xiaomei:setRotationSkewY(180)
                dialogbox:setFlippedX(true)
                label_dialog:setAnchorPoint(1,0.5)

                xiaomei:setPosition(picX, picY)
                dialogbox:setPosition(picX-70, picY+130 )
                label_dialog:setPosition(picX-110,picY+130)
            end
       
            label_dialog:setString(stepdata.text_box.text)
        else
            xiaomei:setVisible(false)
            dialogbox:setVisible(false)
            label_dialog:setVisible(false)
        end

        if stepdata.audio then
            Common.stopAllSounds()
            local path = "audio/effect/"..stepdata.audio..".mp3"
            Common.playSound(path)
        end


        if stepdata.guide then
            local x1 = stepdata.guide.x1
            local y1 = stepdata.guide.y1
            if stepdata.guide.guide_type == "click" then
                effect = EffectManager:CreateAnimation(self, x1, y1, nil, 1, true)
            elseif stepdata.guide.guide_type == "slide1" then
                effect = EffectManager:CreateAnimation(self, x1, y1, nil, 5, true)
            elseif stepdata.guide.guide_type == "slide2" then
                effect = EffectManager:CreateAnimation(self, x1, y1, nil, 6, true)
            elseif stepdata.guide.guide_type == "slide3" then
                effect = EffectManager:CreateAnimation(self, x1, y1, nil, 7, true) 
            end              
        end

        local rect = cc.rect(x-width*0.5, y-height*0.5, width, height)

        RECT = rect

        if stepdata.rect2 then
            local x, y, w, h = stepdata.rect2.x, stepdata.rect2.y, stepdata.rect2.width, stepdata.rect2.height
            RECT2 = cc.rect(x, y, w, h)
        end

        stencil:setPosition(x,y)
        stencil:setContentSize(cc.size(width,height))
    end)

    self.closeGuideListener = application:addEventListener(AppEvent.UI.NewbieGuide.CloseGuide, function ( event )

        self:setVisible(false)
        CCLog(GameCache.NewbieGuide.SStep)

                    
        -- local record_point = GameCache.NewbieGuide.Step + GameCache.NewbieGuide.SStep/10
        rpc:call("Guide.ReportClientStep", "Newbee Guide: "..GameCache.NewbieGuide.Step.."-"..GameCache.NewbieGuide.SStep , function ( event )
                
        end)

        GameCache.NewbieGuide.SStep = GameCache.NewbieGuide.SStep + 1
        if GameCache.NewbieGuide.SStep > #GuideData.steps then
            -- 存档
            GameCache.NewbieGuide.Step = GameCache.NewbieGuide.Step + 1


            rpc:call("Guide.SetCurStep", GameCache.NewbieGuide.Step , function ( event )
                
            end)
            
            BIG_STEP = GameCache.NewbieGuide.Step + 1
            GameCache.NewbieGuide.SStep = 1
            GuideData = GUIDE_STEP_DATA[BIG_STEP]
        end

     
        RECT = cc.rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)
        RECT2 = nil
    end)



    local listener = cc.EventListenerTouchOneByOne:create()
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = self:convertToNodeSpace(touch:getLocation())

        if cc.rectContainsPoint(RECT, locationInNode) then
            listener:setSwallowTouches(false)
        elseif RECT2 and cc.rectContainsPoint(RECT2, locationInNode) then
            listener:setSwallowTouches(false)
        else
            listener:setSwallowTouches(true)
        end
        return true
    end



    -- local function onTouchEnded(touch, event)

    -- end

    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    -- listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function NewbieGuideLayer:onExit(  )

    application:removeEventListener(self.openGuideListener) 
    application:removeEventListener(self.closeGuideListener)  
 
    self:removeFromParent()
    GameCache.NewbieGuide.State = false
end


return NewbieGuideLayer