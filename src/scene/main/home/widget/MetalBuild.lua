local MetalBuild = class("MetalBuild", require("scene.main.home.widget.BuildNode"))
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

function MetalBuild:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildConfig = BaseConfig.getHomeMetal(buildInfo.Level)
    self.data.maxLevel = BaseConfig.homeMetalMaxLevel
    self.data.buildName = "造币公司"
    self.data.buildDesc = "造币公司生产银币，有钱就能任性。硬通货哦"
    MetalBuild.super.ctor(self, number, buildInfo, isOwnHome, topNode)

    self.data.firstPanelCenterSpri = "image/ui/img/btn/btn_1063.png"
end

function MetalBuild:createBuildAccessory()
    MetalBuild.super.createBuildAccessory(self)
    self.controls.canCollect:setChildTexture("image/ui/img/btn/btn_1063.png")    
end

function MetalBuild:upgradeDetailPanel(panel, panelSize)
    local produceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    produceSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.78)
    panel:addChild(produceSpri)

    local afterConfig = BaseConfig.getHomeMetal(self.data.buildInfo.Level)
    if self.data.buildInfo.Level < self.data.maxLevel then
        afterConfig = BaseConfig.getHomeMetal(self.data.buildInfo.Level + 1)
    end

    MetalBuild.super.upgradeDetailPanel(self, panel, panelSize, afterConfig)
end

function MetalBuild:buildDetailPanel2(panel, panelSize)
    local produceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    produceSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.8)
    panel:addChild(produceSpri)

    MetalBuild.super.buildDetailPanel2(self, panel, panelSize, 4)
end

function MetalBuild:buildFirstPanel()
    MetalBuild.super.buildFirstPanel(self, -50, 0)
end

function MetalBuild:updateBuild()
    self.data.buildConfig = BaseConfig.getHomeMetal(self.data.buildInfo.Level)
    local capacity = self.data.buildInfo.Capacity / self.data.buildConfig.Capacity * 100
    self.controls.scrollBar_capacity:setPercent(capacity)

    MetalBuild.super.updateBuild(self)
end

function MetalBuild:collect()
    MetalBuild.super.collect(self)
    if self:isCanCollect() then
        rpc:call("Home.Collect", self.data.buildNumber, function (event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                local metalInfo = event.result
                application:showIconNotice(metalInfo)
                self:syncHomeData()

                if not self.controls.collectEffect then
                    self.controls.collectEffect = load_animation("image/spine/ui_effect/36/")
                    self.controls.collectEffect:setAnimation(0, "animation", false)
                    self.controls.collectEffect:setPosition(self:getPositionX(), self:getPositionY() + self.data.buildSize.height * 0.6)
                    self.controls.topNode:addChild(self.controls.collectEffect)
                    self.controls.collectEffect:setTimeScale(1)
                    self.controls.collectEffect:setScale(0.6)
                else
                    self.controls.collectEffect:setAnimation(0, "animation", false)
                end
            end
        end)
    else
        application:showFlashNotice("当前容量为空")
    end
end

return MetalBuild




