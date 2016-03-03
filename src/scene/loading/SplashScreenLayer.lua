local SplashScreenLayer = class("SplashScreenLayer", BaseLayer)

function SplashScreenLayer:ctor()
    SplashScreenLayer.super.ctor(self)

    local newLayer = cc.LayerColor:create(cc.c4b(255,255,255,255)); 
    self:addChild(newLayer)
 
    local bg = cc.Sprite:create("ccplaying/copyright.png")
    bg:setAnchorPoint(cc.p(0.5, 0))
    bg:setPosition(cc.p(SCREEN_WIDTH * 0.5, 0))
    newLayer:addChild(bg)

    local banner = sp.SkeletonAnimation:create("ccplaying/skeleton.skel", "ccplaying/skeleton.atlas")
    banner:setName("animation")
    banner:setPosition(cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5))
    newLayer:addChild(banner)
    banner:addAnimation(0, "animation", false)
    banner:registerSpineEventHandler(function ( event )
        application:enterScene("login.LoginScene")
    end, sp.EventType.ANIMATION_COMPLETE)

    Common.playSound("ccplaying/CCPlaying.mp3", false)
end

function SplashScreenLayer:onEnterTransitionFinish()

end

return SplashScreenLayer