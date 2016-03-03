local WoodBuild = class("WoodBuild", require("scene.main.home.widget.BuildNode"))
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

function WoodBuild:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildConfig = BaseConfig.getHomeWood(buildInfo.Level)
    self.data.maxLevel = BaseConfig.homeWoodMaxLevel
    self.data.buildName = "木料公司"
    self.data.buildDesc = "本公司生产的木料主要用于各个建筑的升级"
    WoodBuild.super.ctor(self, number, buildInfo, isOwnHome, topNode)

    self.data.firstPanelCenterSpri = "image/ui/img/btn/btn_1109.png"
end

function WoodBuild:createBuildAccessory()
    WoodBuild.super.createBuildAccessory(self)
    self.controls.canCollect:setChildTexture("image/ui/img/btn/btn_1109.png")    
end

function WoodBuild:upgradeDetailPanel(panel, panelSize)
    local produceSpri = cc.Sprite:create("image/ui/img/btn/btn_1109.png")
    produceSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.78)
    panel:addChild(produceSpri)
    produceSpri:setScale(0.5)

    local afterConfig = BaseConfig.getHomeWood(self.data.buildInfo.Level)
    if self.data.buildInfo.Level < self.data.maxLevel then
        afterConfig = BaseConfig.getHomeWood(self.data.buildInfo.Level + 1)
    end

    WoodBuild.super.upgradeDetailPanel(self, panel, panelSize, afterConfig)
end

function WoodBuild:buildDetailPanel2(panel, panelSize)
    local produceSpri = cc.Sprite:create("image/ui/img/btn/btn_1109.png")
    produceSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.8)
    panel:addChild(produceSpri)
    produceSpri:setScale(0.5)

    WoodBuild.super.buildDetailPanel2(self, panel, panelSize, 5)
end

function WoodBuild:updateBuild()
    self.data.buildConfig = BaseConfig.getHomeWood(self.data.buildInfo.Level)
    local capacity = self.data.buildInfo.Capacity / self.data.buildConfig.Capacity * 100
    self.controls.scrollBar_capacity:setPercent(capacity)

    WoodBuild.super.updateBuild(self)
end

function WoodBuild:collect()
    WoodBuild.super.collect(self)
    if self:isCanCollect() then
        rpc:call("Home.Collect", self.data.buildNumber, function (event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                local WoodInfo = event.result
                application:showIconNotice(WoodInfo)
                self:syncHomeData()

                if not self.controls.collectEffect then
                    self.controls.collectEffect = load_animation("image/spine/ui_effect/34/")
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

return WoodBuild




