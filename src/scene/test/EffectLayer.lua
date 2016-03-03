local EffectLayer = class("EffectLayer", BaseLayer)
local effects = require("tool.helper.Effects")


function EffectLayer:ctor()
    EffectLayer.super.ctor(self)
    local layercolor = cc.LayerColor:create(cc.c4b(130, 30, 30, 255))
    self:addChild(layercolor)

    -- local btn_stop = ccui.Button:create("image/ui/img/btn/btn_053.png")
    local btn_stop = ccui.MixButton:create("image/ui/img/btn/btn_053.png")
    btn_stop:setPosition(450,50)
    -- btn_stop:setScale(1.2)
    -- btn_stop:setTitleFontOutline(cc.c4b(0,0,0,255),2)
    -- btn_stop:getTitle():enableOutline(cc.c4b(255,0,0,255), 2)
    -- btn_stop:setTitleFontName("fonts/game-sc.ttf")
    -- btn_stop:setTitleText("停止")
    -- btn_stop:setTitleFontSize(30)
    btn_stop:setTitle( "text", 30)
    btn_stop:setPressedActionEnabled(true)
    btn_stop:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("hehehe")
            
        end
    end)
    self:addChild(btn_stop)


    local hehe = cc.Sprite:create("image/ui/img/btn/btn_053.png")
    hehe:setPosition(480,320)
    hehe:setOpacity(0)
    self:addChild(hehe)
    hehe:runAction(cc.FadeIn:create(5))

    local label = cc.Label:createWithTTF("大爷", "fonts/game-sc.ttf",22)
    hehe:addChild(label)


end

function EffectLayer:onCleanup()
    if self.data.deaccelerateScrollingEntryID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.data.deaccelerateScrollingEntryID)
        self.data.deaccelerateScrollingEntryID = nil
    end
end

return EffectLayer