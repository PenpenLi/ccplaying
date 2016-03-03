local BattleController = require("scene.battle.controller.BattleController")

local BattleLayer = class("BattleLayer", BaseLayer)

function BattleLayer:ctor(params, attackerFormInfo, progressFunc)
    BattleLayer.super.ctor(self)  

    local controller = BattleController.new(params, attackerFormInfo, progressFunc)
    self:addChild(controller)
    self.controls.controller = controller
end

function BattleLayer:setLoadingCallback(callback)
    self.controls.controller:setLoadingCallback(callback)
end

function BattleLayer:onEnterTransitionFinish()

end

function BattleLayer:onCleanup()
    sp.SkeletonDataCache:getInstance():trace()
end

return BattleLayer