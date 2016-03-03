--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-11
-- Time: 下午3:05
-- To change this template use File | Settings | File Templates.
--
local CommonTool = require("tool.helper.Common")
-------------------------------------------------------------------------------

local BattlePauseLayer = class("BattlePauseLayer", BaseLayer)

function BattlePauseLayer:ctor(controller)
    BattlePauseLayer.super.ctor(self)

    self.controller = controller
    self:setupUI()
    self:makeModel()
end

function BattlePauseLayer:onEnterTransitionFinish()

end

function BattlePauseLayer:setupUI()
    local maskLayer = cc.LayerColor:create(cc.c4b(50, 50, 50, 100))
    self:addChild(maskLayer)

    local bgImage = cc.Sprite:create("image/ui/img/bg/bg_250.png")
    bgImage:setPosition(cc.p(display.cx, display.cy))
    bgImage:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(bgImage)

    local btnSize = cc.size(168, 69)

    local btnExit = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btnExit:setScale9Enabled(true)
    btnExit:setContentSize(btnSize)
    btnExit:setPosition(display.cx - 100,display.cy)
--    btnExit:setTitleFontSize(18)
--    btnExit:setTitleText("退出战斗")
    btnExit:addTouchEventListener(widget_click_listener(function(sender)
        self.controller:battleBreakOff()
        Common.ResetGuideLayer({big = 3, small = 2})
        Common.ResetGuideLayer({big = 5, small = 2})
        Common.ResetGuideLayer({big = 10, small = 2})
        Common.OpenGuideLayer({3, 5, 10})
        application:popScene()
        -- application:popScene()
    end))

    local iconExit = cc.Sprite:create("image/ui/img/btn/btn_963.png")
    iconExit:setPosition(cc.p(btnSize.width * 0.18, btnSize.height * 0.5))
    btnExit:addChild(iconExit)

    local labelExit = CommonTool.finalFont("退出战斗", 0 , 0 , 24, cc.c3b(255, 255, 255), 1)
    labelExit:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelExit:setDimensions(130, 30)
    labelExit:setColor(cc.c3b(223, 184, 109))
    labelExit:setPosition(cc.p(btnSize.width * 0.6, btnSize.height * 0.5))
    labelExit:setAnchorPoint(cc.p(0.5, 0.5))

    btnExit:addChild(labelExit)
    self:addChild(btnExit)

    local btnContinue = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btnContinue:setScale9Enabled(true)
    btnContinue:setContentSize(btnSize)
    btnContinue:setPosition(display.cx + 100,display.cy)
--    btnContinue:setTitleFontSize(18)
--    btnContinue:setTitleText("继续战斗")
    btnContinue:addTouchEventListener(widget_click_listener(function(sender)
        self.controller:resumeBattle()
        self:removeFromParent()
    end))

    local iconContinue = cc.Sprite:create("image/ui/img/btn/btn_964.png")
    iconContinue:setPosition(cc.p(btnSize.width * 0.18, btnSize.height * 0.5))
    btnContinue:addChild(iconContinue)

    local labelContinue = CommonTool.finalFont("继续战斗", 0 , 0 , 24, cc.c3b(255, 255, 255), 1)
    labelContinue:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelContinue:setDimensions(130, 30)
    labelContinue:setColor(cc.c3b(223, 184, 109))
    labelContinue:setPosition(cc.p(btnSize.width * 0.6, btnSize.height * 0.5))
    labelContinue:setAnchorPoint(cc.p(0.5, 0.5))
    btnContinue:addChild(labelContinue)

    self:addChild(btnContinue)
end

return BattlePauseLayer
