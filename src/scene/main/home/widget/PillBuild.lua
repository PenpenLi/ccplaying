local PillBuild = class("PillBuild", require("scene.main.home.widget.BuildNode"))
local effects = require("tool.helper.Effects")
local ColorLabel = require("tool.helper.ColorLabel")

local buildOpenLevel = 25
local bigOpenLevel = 3

function PillBuild:ctor(number, buildInfo, isOwnHome, topNode)
    self.data.buildConfig = BaseConfig.getHomePill(buildInfo.Level)
    self.data.maxLevel = BaseConfig.homePillMaxLevel
    self.data.buildName = "升星丹厂"
    self.data.buildDesc = "本厂专职制造装备和星将升星必备之升星丹"
    PillBuild.super.ctor(self, number, buildInfo, isOwnHome, topNode)

    self.data.firstPanelCenterSpri = "image/ui/img/btn/btn_1236.png"
end

function PillBuild:createBuildAccessory()
    local selfBuildLevel = GameCache.Avatar.Level
    if self.data.isOwnHome then
        if selfBuildLevel < buildOpenLevel then
            self.controls.build:setNorGLProgram(false)
        end
    else
        local enemyBuildLevel = self.data.enemyInfo.Level
        if (selfBuildLevel < buildOpenLevel) or (enemyBuildLevel < buildOpenLevel) then
            self.controls.build:setNorGLProgram(false)
        end

    end

    PillBuild.super.createBuildAccessory(self)
    self.controls.canCollect:setChildTexture("image/ui/img/btn/btn_1236.png")    
end

function PillBuild:buildFunc()
    local selfBuildLevel = GameCache.Avatar.Level
    if self.data.isOwnHome then
        if selfBuildLevel < buildOpenLevel then
            application:showFlashNotice("上仙,你到了"..buildOpenLevel.."级就可以使用了")
        else
            PillBuild.super.buildFunc(self)
        end
    else
        local enemyBuildLevel = self.data.enemyInfo.Level
        if (selfBuildLevel < buildOpenLevel) and (enemyBuildLevel < buildOpenLevel) then
            application:showFlashNotice("上仙,你到了"..buildOpenLevel.."级就可以使用了")
        elseif selfBuildLevel < buildOpenLevel then
            application:showFlashNotice("上仙,你到了"..buildOpenLevel.."级就可以使用了")
        elseif enemyBuildLevel < buildOpenLevel then
            application:showFlashNotice("对方尚未开启该建筑")
        else
            PillBuild.super.buildFunc(self)
        end
    end
end

function PillBuild:upgradeDetailPanel(panel, panelSize)
    local produceSpri = cc.Sprite:create("image/ui/img/btn/btn_1236.png")
    produceSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.8)
    panel:addChild(produceSpri)
    produceSpri:setScale(0.5)

    local afterConfig = BaseConfig.getHomePill(self.data.buildInfo.Level)
    if self.data.buildInfo.Level < self.data.maxLevel then
        afterConfig = BaseConfig.getHomePill(self.data.buildInfo.Level + 1)
    end

    PillBuild.super.upgradeDetailPanel(self, panel, panelSize, afterConfig)
end

function PillBuild:buildDetailPanel2(panel, panelSize)
    local produceSpri = cc.Sprite:create("image/ui/img/btn/btn_1236.png")
    produceSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.8)
    panel:addChild(produceSpri)
    produceSpri:setScale(0.5)

    PillBuild.super.buildDetailPanel2(self, panel, panelSize, 6)
end

function PillBuild:buildFirstPanel()
    PillBuild.super.buildFirstPanel(self, 150, -50)
end

function PillBuild:updateBuild()
    self.data.buildConfig = BaseConfig.getHomePill(self.data.buildInfo.Level)
    local capacity = self.data.buildInfo.Capacity / self.data.buildConfig.Capacity * 100
    self.controls.scrollBar_capacity:setPercent(capacity)
    PillBuild.super.updateBuild(self)
end

function PillBuild:collect()
    PillBuild.super.collect(self)
    if self:isCanCollect() then
        rpc:call("Home.Collect", self.data.buildNumber, function (event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                local pillTabs = event.result
                application:showIconNotice(pillTabs)
                self:syncHomeData()

                if not self.controls.collectEffect then
                    self.controls.collectEffect = load_animation("image/spine/ui_effect/35/")
                    self.controls.collectEffect:setAnimation(0, "animation", false)
                    self.controls.collectEffect:setPosition(self:getPositionX() - 10, self:getPositionY() + self.data.buildSize.height * 0.6)
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

return PillBuild




