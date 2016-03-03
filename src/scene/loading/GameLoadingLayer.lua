local GameLoadingLayer = class("GameLoadingLayer", BaseLayer)

function GameLoadingLayer:ctor()
    GameLoadingLayer.super.ctor(self)
    
    local widget = ccs.GUIReader:getInstance():widgetFromJsonFile("Game/SplashScreen.json")
       
    self:addChild(widget)
    self.controls.widget = widget

end

return GameLoadingLayer
