local ExchangeBuild = class("ExchangeBuild", require("scene.main.home.widget.BuildNode"))
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

function ExchangeBuild:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildConfig = BaseConfig.getHomeDecoration(buildInfo.Level)
    ExchangeBuild.super.ctor(self, number, buildInfo, isOwnHome, topNode)

    self.data.buildName = "兑换商店"
end

function ExchangeBuild:createBuildAccessory()
	-- self.controls.build:setNorGLProgram(false)

    self.controls.buildName = Common.finalFont(self.data.buildName, 1, 1, 20, cc.c3b(80, 253, 255), 1)
    self.controls.buildName:setAdditionalKerning(-2)
    self:addChild(self.controls.buildName)
    self.controls.buildName:setPosition(0, self.data.buildSize.height * 0.25)
end

function ExchangeBuild:buildFunc()
    -- application:showFlashNotice("这里是兑换商店") 
    local layer = require("scene.main.ExchangeMall").new(BaseConfig.MALL_TYPE_HOME, function()
        application:dispatchCustomEvent(AppEvent.UI.Home.SyncHomeData, {})
    end)
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)
end

function ExchangeBuild:producePanel(buildPanelNode, panelSize)
    
end

function ExchangeBuild:updateBuildInfo()
    
end

function ExchangeBuild:updateBuild()
    
end

function ExchangeBuild:updatePanel()
    
end

return ExchangeBuild




