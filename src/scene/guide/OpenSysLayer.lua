--
-- Author: keyring
-- Date: 2015-09-24 10:06:41
--

local OpenSysLayer = class("OpenSysLayer", function (  )
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
local GUIDE_STEP_DATA = require("scene.guide.OpenSysConfig")
local ColorLabel = require("tool.helper.NewColorLabel")

function OpenSysLayer:ctor()
    

    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self, 1)
    self:setName("OPENSYS_LAYER")
    self:setVisible(false)

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
    local BIG_STEP = GameCache.OpenSystem.Step

    local GuideData = GUIDE_STEP_DATA[BIG_STEP]

    self.openGuideListener = application:addEventListener(AppEvent.UI.NewbieGuide.OpenSystem,function ( event )  -- step by step

		if not GameCache.OpenSystem.State then
			return
		end
        self:setVisible(true)

        CCLog(GameCache.OpenSystem.SStep)
        local stepdata = GuideData.steps[GameCache.OpenSystem.SStep]


        if effect and not tolua.isnull(effect) then
           effect:removeFromParent()
        end

        -- 获取当前步骤的数据
        local x = stepdata.x
        local y = stepdata.y
        local width = stepdata.width
        local height = stepdata.height 
        self.justShow = stepdata.justshow or false

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
                label_dialog:setPosition(picX-115,picY+130)
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
            end              
        end

        local rect = cc.rect(x-width*0.5, y-height*0.5, width, height)

        RECT = rect

        stencil:setPosition(x,y)
        stencil:setContentSize(cc.size(width,height))
    end)

    self.closeGuideListener = application:addEventListener(AppEvent.UI.NewbieGuide.CloseSystem, function ( event )

        self:setVisible(false)
        CCLog(GameCache.OpenSystem.SStep)

        rpc:call("Guide.ReportClientStep", "Open System: "..GameCache.OpenSystem.Step.."-"..GameCache.OpenSystem.SStep , function ( event )
                
        end)

        GameCache.OpenSystem.SStep = GameCache.OpenSystem.SStep + 1
        if GameCache.OpenSystem.SStep > #GuideData.steps then
            GameCache.OpenSystem.State = false
            GameCache.NewbieGuide.State = false
            GameCache.OpenSystem.Step = 0
            GameCache.OpenSystem.SStep = 1
        end
     
        RECT = cc.rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)
    end)


    local listener = cc.EventListenerTouchOneByOne:create()
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = self:convertToNodeSpace(touch:getLocation())

        if cc.rectContainsPoint(RECT, locationInNode) then
            listener:setSwallowTouches(false)
        else
            listener:setSwallowTouches(true)
        end
        return true
    end



    local function onTouchEnded(touch, event)
    	if self.justShow then
    		Common.CloseSystemLayer( {GameCache.OpenSystem.Step} )
    		self.justShow = false
    	end
    end

    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function OpenSysLayer:onExit(  )

    application:removeEventListener(self.openGuideListener) 
    application:removeEventListener(self.closeGuideListener)  
    application:removeEventListener(self.resetGuideListener)  
    self:removeFromParent()
end


return OpenSysLayer